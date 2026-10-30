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
	# 004: asking for a tool. Which tools exist comes from ToolRegistry, so
	# a spec for a tool that is not registered is refused like any other
	# word the game does not have.
	"EQUIP",
	# 014: sending a character somewhere. Which goals exist comes from
	# NpcGoals, so a goal that is not whitelisted is refused like any other
	# word the game does not have.
	"ORDER",
	# 018: shutting and opening a door, which a player may do at any moment,
	# including while a character is walking through it.
	"SHUT",
	"OPEN",
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
	# 096: a command of null read back "Rejected command: <NULL>" - the engine's
	# spelling, put through to_upper(), which is why a screen looking for the
	# lower-case form could not see it (TRAPS 78). Spelling only: the command is
	# rejected either way.
	var command := Readback.spelled(data["command"]).to_upper()
	if command == "UNSUPPORTED":
		result["unsupported"] = true
		result["command"] = command
		var reason := "no reason given"
		if data.has("parameters") and typeof(data["parameters"]) == TYPE_DICTIONARY:
			# 003: the parameters are kept, not just the reason, because an
			# UNSUPPORTED answer now also carries what the AI understood, and
			# Genesis must show that before explaining what it cannot do.
			result["parameters"] = data["parameters"]
			# 095: "no reason given" answered an ABSENT key and not a present and
			# empty one, so {"reason": ""} wrote a record whose only sentence was
			# the empty string and {"reason": null} wrote the six characters
			# "<null>". Measured in 094, driven through main.gd and read off the
			# ledger. This is the one refusal a player meets when Genesis says it
			# cannot do the thing at all, so it is the sharpest member of the
			# class Readback.said_or() now reads for all of them.
			reason = Readback.said_or(data["parameters"], "reason", reason)
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
