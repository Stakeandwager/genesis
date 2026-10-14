extends RefCounted
class_name NpcGoals

# --- 014: the third whitelist ---
#
# WorldRegistry says which worlds exist. ToolRegistry says which tools exist.
# This says which GOALS exist, and it is here for the same reason both of
# those are: the AI must not be able to invent one. The day it decides a
# character can "fetch" or "attack" or "negotiate", those words have to be
# refused before they reach the game, exactly as crop_plot was.
#
# One goal for now. A whitelist with one entry is not a waste: it is the wall,
# and the wall is the point.
#
# WHAT A GOAL IS NOT
# A goal is not a promise. "go to the vault" says what was asked for, never
# what happened. Whether the character arrived is decided afterwards, by
# measuring where it ended up against the geometry - never by the character
# saying so.

const GOALS := ["go_to"]

# How long a character may spend on one goal before it is given up, and how
# long it may make no progress before it is called blocked.
const MAX_SECONDS := 90.0
const STALL_SECONDS := 4.0


static func prompt_section() -> String:
	return """ORDER go_to - send a character to a room of the dungeon
{"command": "ORDER", "parameters": {"goal": "go_to", "room": ROOM}}

ROOM is the name of a room in the dungeon that is standing now, or its number counting from 1. Only rooms that exist may be named.
There is one character. Ordering it somewhere while it is already going somewhere replaces the old order.
This is only for a dungeon. There is nobody to order about in any other world.
An order says where the player wants the character to go. It does not say that the character will get there."""


# Check a proposed goal against the rooms that actually exist. Returns ok,
# errors and a clean goal with the room resolved to its number, so nothing
# downstream has to think about names again.
static func validate(parameters: Dictionary, rooms: Array) -> Dictionary:
	var errors: Array = []
	var goal := str(parameters.get("goal", "")).to_lower().strip_edges()
	if goal == "":
		errors.append("an order needs a goal (it has %s)" % ", ".join(GOALS))
	elif not GOALS.has(goal):
		errors.append("'%s' is not something a character can be asked to do (it can %s)" % [
			goal, ", ".join(GOALS)])

	if rooms.is_empty():
		errors.append("there is nobody to order about: build a dungeon first")
		return {"ok": false, "errors": errors, "goal": {}}

	var names: Array = []
	for r in rooms:
		names.append(str((r as Dictionary).get("name", "")))

	var room := -1
	var asked = parameters.get("room", null)
	if asked == null:
		errors.append("go_to needs a room (this dungeon has %s)" % ", ".join(names))
	elif typeof(asked) == TYPE_INT or typeof(asked) == TYPE_FLOAT:
		var number := int(asked)
		if number < 1 or number > rooms.size():
			errors.append("this dungeon has %d rooms, so there is no room %d" % [rooms.size(), number])
		else:
			room = number - 1
	else:
		var wanted := str(asked).to_lower().strip_edges().replace(" ", "_")
		for i in names.size():
			if str(names[i]).to_lower().replace(" ", "_") == wanted:
				room = i
				break
		if room < 0:
			errors.append("this dungeon has no room called '%s' (it has %s)" % [str(asked), ", ".join(names)])

	if not errors.is_empty():
		return {"ok": false, "errors": errors, "goal": {}}
	return {"ok": true, "errors": [], "goal": {"goal": goal, "room": room, "room_name": names[room]}}


# "to send someone to the vault"
#
# Built from the command, like every readback in Genesis, and phrased as a
# request rather than an outcome: the player is being told what was asked for,
# not what will happen.
static func readback(parameters: Dictionary) -> String:
	var goal := str(parameters.get("goal", "")).to_lower().strip_edges()
	if goal != "go_to":
		return ""
	var asked = parameters.get("room", null)
	if asked == null:
		return "to send someone somewhere"
	if typeof(asked) == TYPE_INT or typeof(asked) == TYPE_FLOAT:
		return "to send someone to room %d" % int(asked)
	return "to send someone to the %s" % str(asked).replace("_", " ")


# What is being attempted, said once the order is accepted. Phrased as an
# attempt, not an outcome: nothing has happened yet.
static func sent_line(parameters: Dictionary) -> String:
	var said := readback(parameters)
	if said.begins_with("to send someone "):
		return "Sending someone " + said.substr(16) + "."
	return "Sent."


# What happened, in the player's words. Never said by the character.
static func outcome_line(outcome: String, room_name: String, metres: float, seconds: float) -> String:
	var where := room_name.replace("_", " ")
	match outcome:
		"ARRIVED":
			return "Got to the %s. %.0f m in %.0f seconds." % [where, metres, seconds]
		"BLOCKED":
			return "Could not get to the %s: stopped making progress after %.0f m." % [where, metres]
		"GAVE_UP":
			return "Gave up on the %s after %.0f seconds and %.0f m." % [where, seconds, metres]
		"NO_ROUTE":
			return "There is no way through to the %s." % where
	return "Nothing happened."
