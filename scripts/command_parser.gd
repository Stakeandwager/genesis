extends RefCounted
class_name CommandParser

# The built-in commands, plus one for every registered world module. A module
# that is not registered cannot be asked for at all.
const CORE_COMMANDS := [
	"CREATE_TRACK",
	"MODIFY_TRACK",
	"SPAWN_OPPONENTS",
	"CLEAR_WORLD",
]


static func allowed_commands() -> Array:
	return CORE_COMMANDS + WorldRegistry.commands()

static func parse(json_text: String) -> Dictionary:
	var result := {"ok": false, "unsupported": false, "command": "", "parameters": {}, "error": ""}
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
	if command == "UNSUPPORTED":
		result["unsupported"] = true
		var reason := "no reason given"
		if data.has("parameters") and typeof(data["parameters"]) == TYPE_DICTIONARY:
			reason = str(data["parameters"].get("reason", reason))
		result["error"] = reason
		return result
	if not command in allowed_commands():
		result["error"] = "Rejected command: " + command
		return result
	var parameters := {}
	if data.has("parameters") and typeof(data["parameters"]) == TYPE_DICTIONARY:
		parameters = data["parameters"]
	result["ok"] = true
	result["command"] = command
	result["parameters"] = parameters
	return result
