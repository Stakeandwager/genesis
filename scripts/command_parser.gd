extends RefCounted
class_name CommandParser

# --- Prototype 001 - Stage 3: Command validation ---
# The whitelist. Nothing outside this list can ever be executed.

const ALLOWED_COMMANDS := [
	"CREATE_TRACK",
	"MODIFY_TRACK",
	"SPAWN_OPPONENTS",
	"CLEAR_WORLD",
]


# Takes a raw JSON string, returns a validated dictionary.
# Result always has: ok (bool), command (String), parameters (Dictionary), error (String)
static func parse(json_text: String) -> Dictionary:
	var result := {
		"ok": false,
		"command": "",
		"parameters": {},
		"error": "",
	}

	var json := JSON.new()
	var parse_error := json.parse(json_text)

	if parse_error != OK:
		result["error"] = "Not valid JSON: " + json.get_error_message()
		return result

	var data = json.data

	if typeof(data) != TYPE_DICTIONARY:
		result["error"] = "JSON is not an object."
		return result

	if not data.has("command"):
		result["error"] = "Missing 'command' field."
		return result

	var command := str(data["command"]).to_upper()

	if not command in ALLOWED_COMMANDS:
		result["error"] = "Rejected command: " + command
		return result

	var parameters := {}
	if data.has("parameters") and typeof(data["parameters"]) == TYPE_DICTIONARY:
		parameters = data["parameters"]

	result["ok"] = true
	result["command"] = command
	result["parameters"] = parameters
	return result
