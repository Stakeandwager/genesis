extends Node
class_name AIInterpreter

# --- Prototype 001 - Stages 9 & 11: Natural language -> JSON command ---
# The AI is an INTERPRETER. It never touches Godot directly.
# Its only output is a string, which the CommandParser must still validate.

signal interpretation_ready(json_text: String)
signal interpretation_failed(reason: String)

const KEY_PATH := "res://api_key.txt"
const ENDPOINT := "https://generativelanguage.googleapis.com/v1beta/models/gemini-3.5-flash:generateContent"

const SYSTEM_PROMPT := """You are the command interpreter for a Godot racing game.

Your job is to convert the player's request into exactly one valid game command.

You may ONLY use these commands:
CREATE_TRACK - parameters: length (200-3000), corners (2-12), difficulty (easy/medium/hard/extreme)
MODIFY_TRACK - parameters: corner (number, counting from 1), difficulty (easy/medium/hard/extreme)
SPAWN_OPPONENTS - parameters: count (1-12)
CLEAR_WORLD - parameters: none

Return ONLY valid JSON. No explanations. No markdown fences. No code blocks.

If the request cannot be met with these four commands, return:
{"command": "UNSUPPORTED", "parameters": {"reason": "short explanation"}}

Valid format:
{"command": "COMMAND_NAME", "parameters": {}}

Examples:
"make me a race track" -> {"command": "CREATE_TRACK", "parameters": {}}
"a long hard track with 10 corners" -> {"command": "CREATE_TRACK", "parameters": {"length": 2500, "corners": 10, "difficulty": "hard"}}
"make the second corner really difficult" -> {"command": "MODIFY_TRACK", "parameters": {"corner": 2, "difficulty": "hard"}}
"put three cars on the track" -> {"command": "SPAWN_OPPONENTS", "parameters": {"count": 3}}
"start over" -> {"command": "CLEAR_WORLD", "parameters": {}}
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
			"temperature": 0.1,
			"maxOutputTokens": 2000,
			"responseMimeType": "application/json"
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

	var parts = data["candidates"][0].get("content", {}).get("parts", [])
	if parts.is_empty():
		interpretation_failed.emit("The AI returned an empty answer.")
		return

	var text: String = str(parts[0].get("text", "")).strip_edges()

	# Models sometimes wrap JSON in markdown fences despite instructions.
	text = text.replace("```json", "").replace("```", "").strip_edges()

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
