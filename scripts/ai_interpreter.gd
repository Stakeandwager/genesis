extends Node
class_name AIInterpreter

# --- Prototype 001 - Stage 9: Natural language -> JSON command ---
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
		interpretation_failed.emit("Still thinking about the last request")
		return

	if api_key == "":
		interpretation_failed.emit("No API key found in api_key.txt")
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
		interpretation_failed.emit("Could not send request (error %d)" % error)


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


func _on_request_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	busy = false

	var raw := body.get_string_from_utf8()

	if response_code != 200:
		interpretation_failed.emit("AI returned HTTP %d" % response_code)
		print("AI error body: ", raw)
		return

	var json := JSON.new()
	if json.parse(raw) != OK:
		interpretation_failed.emit("AI response was not JSON")
		return

	var data = json.data

	# Dig the text out of Gemini's response envelope.
	if not data.has("candidates") or data["candidates"].is_empty():
		interpretation_failed.emit("AI returned no candidates")
		print("AI body: ", raw)
		return

	var parts = data["candidates"][0].get("content", {}).get("parts", [])
	if parts.is_empty():
		interpretation_failed.emit("AI returned empty content")
		return

	var text: String = str(parts[0].get("text", "")).strip_edges()

	# Models sometimes wrap JSON in markdown fences despite instructions.
	text = text.replace("```json", "").replace("```", "").strip_edges()

	print("AI raw output: ", text)
	interpretation_ready.emit(text)
