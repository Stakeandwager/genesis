extends RefCounted
class_name CommandParser

# --- Prototype 001 - Stages 3 & 11: Command validation ---
# The whitelist. Nothing outside this list can ever be executed.
# UNSUPPORTED is recognised so it can be explained to the player,
# but it is never executed - it is not on the whitelist.

const ALLOWED_COMMANDS := [
	"CREATE_TRACK",
	"MODIFY_TRACK",
	"SPAWN_OPPONENTS",
	"CLEAR_WORLD",
]


# Result always has: ok, unsupported, command, parameters, error
static func parse(json_text: String) -> Dictionary:
	var result := {
		"ok": false,
		"unsupported": false,
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

	# The AI is honestly saying it can't do this. Explain it, never execute it.
	if command == "UNSUPPORTED":
		result["unsupported"] = true
		var reason := "no reason given"
		if data.has("parameters") and typeof(data["parameters"]) == TYPE_DICTIONARY:
			reason = str(data["parameters"].get("reason", reason))
		result["error"] = reason
		return result

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
