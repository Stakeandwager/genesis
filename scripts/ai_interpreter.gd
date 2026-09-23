extends Node
class_name AIInterpreter

# --- Prototype 002A - Step A7: Natural language -> composed track ---
# The AI is an INTERPRETER and a COMPOSER. It never touches Godot directly.
# Its only output is a string, which must still pass the command whitelist,
# the section validator, the feasibility gate, the closure solver and the
# separation check before anything is built.
#
# Instructions are NEUTRAL (experiment option A): the AI is told the pieces
# and the rules of a closed circuit, but never what any style should look
# like. Whether "technical" becomes different geometry from "high speed" is
# exactly what the experiment measures.

signal interpretation_ready(json_text: String)
signal interpretation_failed(reason: String)

const KEY_PATH := "res://api_key.txt"

# Everything that could change the results is recorded with every track.
const MODEL := "gemini-3.1-flash-lite"
const THINKING_LEVEL := "low"
# Temperature 1.0 so that repeated requests give genuinely different designs.
const TEMPERATURE := 1.0
const PROMPT_VERSION := "002A-neutral-1"

const ENDPOINT := "https://generativelanguage.googleapis.com/v1beta/models/" + MODEL + ":generateContent"

const SYSTEM_PROMPT := """You design closed racing circuits for a Godot game by composing them from track sections.

Convert the player's request into exactly ONE JSON object. Return ONLY the JSON: no explanations, no markdown, no code fences. Never return a list of commands. If the request has several steps, return the single command for the final result; CREATE_TRACK already replaces any existing track.

COMMANDS YOU MAY USE
CREATE_TRACK - design a new closed circuit
CLEAR_WORLD - remove everything, with parameters {}
For any other request, return:
{"command": "UNSUPPORTED", "parameters": {"reason": "short explanation"}}

CREATE_TRACK FORMAT
{"command": "CREATE_TRACK", "parameters": {"mode": "circuit", "intent": {"style": STYLE}, "sections": [SECTION, SECTION, ...]}}

STYLE records how the player described the track, as a short lowercase label with underscores, in the player's own terms. If they gave no description, use "unspecified". Interpret the player's description yourself when you design the track.

SECTION TYPES (only these four, with exactly these fields)
straight: {"type": "straight", "length": L} where L is 20 to 1000 metres
corner: {"type": "corner", "radius": R, "angle": A} where R is 15 to 300 metres and A is 10 to 120 degrees
hairpin: {"type": "hairpin", "radius": R, "angle": A} where R is 10 to 60 metres and A is 120 to 200 degrees
chicane: {"type": "chicane", "radius": R, "offset": O, "direction": "left" or "right"} where R is 15 to 150 metres and O is more than 0 and at most 2 x R
Angles are signed: positive turns right, negative turns left. Never give a corner, hairpin or chicane a length; it is calculated. A chicane steps the track sideways by O metres and returns to its original direction.

RULES FOR A CLOSED CIRCUIT
- Sections join end to end, in order, starting at the start line. After the last section the track must arrive back at the start line, facing the way it started.
- Corner and hairpin angles must add up to exactly +360 (clockwise) or -360 (anticlockwise). Chicanes do not count.
- Use at least 2 straights and at least 2 corners or hairpins.
- The game can adjust each angle and each straight length by up to 20% to close the loop, so plan where every section takes the track so that it very nearly closes by itself.
- The road must never cross itself, and separate parts of the road must stay at least 18 metres apart.
"""

var http: HTTPRequest
var api_key: String = ""
var busy: bool = false


func _ready() -> void:
	http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_request_completed)
	_load_key()


func is_available() -> bool:
	return api_key != ""


# The settings behind every AI-made track, stored in the experiment record.
func describe() -> Dictionary:
	return {
		"source": "ai",
		"model": MODEL,
		"thinking_level": THINKING_LEVEL,
		"temperature": TEMPERATURE,
		"prompt_version": PROMPT_VERSION,
	}


func interpret(player_text: String) -> void:
	if busy:
		interpretation_failed.emit("Still thinking about the last request.")
		return

	if api_key == "":
		interpretation_failed.emit("No API key found in api_key.txt.")
		return

	var body := {
		"system_instruction": {
			"parts": [{"text": SYSTEM_PROMPT}]
		},
		"contents": [{
			"parts": [{"text": player_text}]
		}],
		"generationConfig": {
			"temperature": TEMPERATURE,
			"maxOutputTokens": 8000,
			"responseMimeType": "application/json",
			"thinkingConfig": {
				"thinkingLevel": THINKING_LEVEL
			}
		}
	}

	var headers := [
		"Content-Type: application/json",
		"x-goog-api-key: " + api_key,
	]

	busy = true
	var error := http.request(ENDPOINT, headers, HTTPClient.METHOD_POST, JSON.stringify(body))

	if error != OK:
		busy = false
		interpretation_failed.emit("Could not send the request. (error %d)" % error)


# --- internal ---

func _load_key() -> void:
	if not FileAccess.file_exists(KEY_PATH):
		push_warning("api_key.txt not found at " + KEY_PATH)
		return

	var file := FileAccess.open(KEY_PATH, FileAccess.READ)
	if file == null:
		push_warning("Could not open api_key.txt")
		return

	api_key = file.get_as_text().strip_edges()
	file.close()


func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	busy = false

	# The request never reached Google at all.
	if result != HTTPRequest.RESULT_SUCCESS:
		interpretation_failed.emit("Could not reach the AI. Check your internet connection.")
		print("Network result code: ", result)
		return

	var raw := body.get_string_from_utf8()

	if response_code != 200:
		print("AI error body: ", raw)
		interpretation_failed.emit(_friendly_http_error(response_code))
		return

	var json := JSON.new()
	if json.parse(raw) != OK:
		interpretation_failed.emit("The AI sent back something unreadable.")
		return

	var data = json.data

	if not data.has("candidates") or data["candidates"].is_empty():
		interpretation_failed.emit("The AI returned no answer.")
		print("AI body: ", raw)
		return

	var candidate: Dictionary = data["candidates"][0]
	if str(candidate.get("finishReason", "")) == "MAX_TOKENS":
		interpretation_failed.emit("The AI's answer was cut off before it finished.")
		return

	var parts = candidate.get("content", {}).get("parts", [])
	if parts.is_empty():
		interpretation_failed.emit("The AI returned an empty answer.")
		return

	var text: String = str(parts[0].get("text", "")).strip_edges()

	# Models sometimes wrap JSON in markdown fences despite instructions.
	var fence := "`".repeat(3)
	text = text.replace(fence + "json", "").replace(fence, "").strip_edges()

	print("AI raw output: ", text)
	interpretation_ready.emit(text)


func _friendly_http_error(code: int) -> String:
	match code:
		429:
			return "The AI is getting too many requests. Wait a minute and try again. (HTTP 429)"
		500, 502, 503, 504:
			return "The AI service is busy right now. Try again in a moment. (HTTP %d)" % code
		400:
			return "The AI did not accept the request format. (HTTP 400)"
		401, 403:
			return "The API key was refused. Check api_key.txt. (HTTP %d)" % code
		404:
			return "The AI model name is out of date. (HTTP 404)"
	return "The AI returned an unexpected error. (HTTP %d)" % code
