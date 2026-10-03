extends Node
class_name AIInterpreter

# --- Prototype 002A - Step A7: Natural language -> composed track ---
# --- 002C: one revision turn, with Godot's closure measurements ---
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
# 002C-balance-1 adds one geometry rule: travel in opposite directions must
# balance. The 002C experiments showed designs that turned through 360 deg but
# never came back, because a hairpin reverses direction without returning.
const PROMPT_VERSION := "002C-balance-1"
# Which wording of the closure feedback a revised track was given.
# feedback-2 adds Godot's test of whether ANY straight lengths could close the layout.
const REVISION_VERSION := "002C-closure-feedback-2"

const ENDPOINT := "https://generativelanguage.googleapis.com/v1beta/models/" + MODEL + ":generateContent"

const SYSTEM_PROMPT := """You design closed racing circuits for a Godot game by composing them from track sections.

Convert the player's request into exactly ONE JSON object. Return ONLY the JSON: no explanations, no markdown, no code fences. Never return a list of commands. If the request has several steps, return the single command for the final result; CREATE_TRACK already replaces any existing track.

COMMANDS YOU MAY USE
PLAN - build several things in one request
CREATE_TRACK - design a new closed circuit
CLEAR_WORLD - remove everything, with parameters {}
Other worlds you can build are listed at the end of these instructions.

A PLAN is for a request that needs more than one thing, such as a farm with a track around it:
{"command": "PLAN", "parameters": {"steps": [{"command": "CREATE_FARM", "parameters": {...}}, {"command": "CREATE_TRACK", "parameters": {...}}]}}
Up to 4 steps. A step is a normal command with its normal parameters, and a plan may not contain another plan.
To build one world around another, give the later step "around": N, where N is the number of the earlier step (1 for the first). The game works out where everything goes; never give coordinates. The surrounding world must be large enough to contain the inner one with room to spare, or the whole plan is refused.
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
- Travel in opposite directions must balance. Every metre the track travels away from the start line must be matched by a metre travelled back towards it, and every metre to the right of the start line by a metre back to the left. Angles adding up to 360 is necessary but not enough on its own: a hairpin reverses the direction of travel, but by itself carries the track back only by its own width, twice its radius.
- Use at least 2 straights and at least 2 corners or hairpins.
- The game can adjust each angle and each straight length by up to 20% to close the loop, so plan where every section takes the track so that it very nearly closes by itself.
- The road must never cross itself, and separate parts of the road must stay at least 18 metres apart.
"""

var http: HTTPRequest
var api_key: String = ""
var busy: bool = false
# The AI's last answer, kept so a revision can show the AI what it said.
# The raw parts are kept as well as the text: Gemini 3 models attach a
# "thought signature" that it expects back in the next turn.
var last_model_parts: Array = []
var last_answer_text: String = ""


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
	_send([{
		"role": "user",
		"parts": [{"text": player_text}]
	}])


# Closure feedback (002C): one more turn of the same conversation. The AI sees
# the player's request, its own previous answer, and what Godot measured, then
# proposes again. Its answer goes through every check, exactly like the first.
func revise(player_text: String, feedback: String) -> void:
	var previous: Array = last_model_parts
	if previous.is_empty():
		previous = [{"text": last_answer_text}]
	_send([
		{"role": "user", "parts": [{"text": player_text}]},
		{"role": "model", "parts": previous},
		{"role": "user", "parts": [{"text": feedback}]},
	])


# The settings behind a revised track: the same as a first attempt, plus which
# version of the feedback the AI was given.
func describe_revision() -> Dictionary:
	var d := describe()
	d["revision"] = REVISION_VERSION
	return d


func _send(contents: Array) -> void:
	if busy:
		interpretation_failed.emit("Still thinking about the last request.")
		return

	if api_key == "":
		interpretation_failed.emit("No API key found in api_key.txt.")
		return

	# Every registered world module describes its own vocabulary, so the AI
	# always knows exactly what the game can build, and nothing more.
	var instructions := SYSTEM_PROMPT + "\n\nOTHER WORLDS YOU CAN BUILD\n" + WorldRegistry.prompt_sections()

	var body := {
		"system_instruction": {
			"parts": [{"text": instructions}]
		},
		"contents": contents,
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

	# Thinking models can return more than one part; the answer is the text.
	var text := ""
	for part in parts:
		if typeof(part) == TYPE_DICTIONARY and part.has("text") and not bool(part.get("thought", false)):
			text += str(part["text"])
	text = text.strip_edges()

	# Models sometimes wrap JSON in markdown fences despite instructions.
	var fence := "`".repeat(3)
	text = text.replace(fence + "json", "").replace(fence, "").strip_edges()

	last_model_parts = parts
	last_answer_text = text

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
