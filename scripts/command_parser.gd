extends RefCounted
class_name CommandParser

# The built-in commands, plus one for every registered world module. A module
# that is not registered cannot be asked for at all. CREATE_TRACK comes from
# the racing module, like CREATE_FARM comes from the farm module.
const CORE_COMMANDS := [
	"PLAN",
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
		result["command"] = command
		var reason := "no reason given"
		if data.has("parameters") and typeof(data["parameters"]) == TYPE_DICTIONARY:
			# 003: the parameters are kept, not just the reason, because an
			# UNSUPPORTED answer now also carries what the AI understood, and
			# Genesis must show that before explaining what it cannot do.
			result["parameters"] = data["parameters"]
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
