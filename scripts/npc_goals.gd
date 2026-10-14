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

const GOALS := ["go_to", "carry"]

# How long a character may spend on one goal before it is given up, and how
# long it may make no progress before it is called blocked.
const MAX_SECONDS := 90.0
const STALL_SECONDS := 4.0


static func prompt_section() -> String:
	return """ORDER go_to - send a character to a room of the dungeon
{"command": "ORDER", "parameters": {"goal": "go_to", "room": ROOM}}

ORDER carry - have the character fetch a thing and take it somewhere
{"command": "ORDER", "parameters": {"goal": "carry", "thing": THING, "room": ROOM}}
THING is the name of something in the dungeon that is standing now. The character goes to it, picks it up, and takes it to ROOM. An order to carry says what the player wants carried; it does not say the thing will get there.

ROOM is the name of a room in the dungeon that is standing now, or its number counting from 1. Only rooms that exist may be named.
If the player's own words match the name of a room that exists, use that name exactly. A dungeon whose rooms are called large_hall, room_1, room_2, room_3 has a room called room_3, so "room 3" means room_3 - not the third room in the list. Counting from 1 is only for a player who says "the third room" and no name fits.
There is one character. Ordering it somewhere while it is already going somewhere replaces the old order.
This is only for a dungeon. There is nobody to order about in any other world.
An order says where the player wants the character to go. It does not say that the character will get there."""


# Check a proposed goal against the rooms that actually exist. Returns ok,
# errors and a clean goal with the room resolved to its number, so nothing
# downstream has to think about names again.
static func validate(parameters: Dictionary, rooms: Array, things: Array = []) -> Dictionary:
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

	# 015: carrying needs something to carry, named from what is actually in
	# the dungeon. A thing the AI invented is refused exactly as an invented
	# room is.
	var thing := ""
	if goal == "carry":
		var thing_names: Array = []
		for t in things:
			thing_names.append(str((t as Dictionary).get("name", "")))
		var wanted := str(parameters.get("thing", "")).to_lower().strip_edges().replace(" ", "_")
		if wanted == "":
			errors.append("carrying needs something to carry%s" % (
				" (this dungeon has %s)" % ", ".join(thing_names) if not thing_names.is_empty() else ""))
		elif thing_names.is_empty():
			errors.append("there is nothing to carry in this dungeon")
		elif not thing_names.has(wanted):
			errors.append("this dungeon has nothing called '%s' (it has %s)" % [
				str(parameters.get("thing", "")), ", ".join(thing_names)])
		else:
			thing = wanted

	if not errors.is_empty():
		return {"ok": false, "errors": errors, "goal": {}}
	return {"ok": true, "errors": [], "goal": {
		"goal": goal, "room": room, "room_name": names[room], "thing": thing}}


# "to send someone to the vault"
#
# Built from the command, like every readback in Genesis, and phrased as a
# request rather than an outcome: the player is being told what was asked for,
# not what will happen.
static func readback(parameters: Dictionary) -> String:
	var goal := str(parameters.get("goal", "")).to_lower().strip_edges()
	if goal == "carry":
		var thing := str(parameters.get("thing", "")).replace("_", " ")
		var asked_room = parameters.get("room", null)
		var where := ""
		if asked_room == null:
			where = "somewhere"
		elif typeof(asked_room) == TYPE_INT or typeof(asked_room) == TYPE_FLOAT:
			where = "room %d" % int(asked_room)
		else:
			where = _place(str(asked_room))
		if thing == "":
			return "to have something carried to %s" % where
		return "to have the %s carried to %s" % [thing, where]
	if goal != "go_to":
		return ""
	var asked = parameters.get("room", null)
	if asked == null:
		return "to send someone somewhere"
	if typeof(asked) == TYPE_INT or typeof(asked) == TYPE_FLOAT:
		return "to send someone to room %d" % int(asked)
	return "to send someone to %s" % _place(str(asked))


# --- 018: which door ---
# Named by the two rooms it joins, because a door has no name of its own and a
# player would say "the door between the hall and the vault".
static func validate_door(parameters: Dictionary, rooms: Array, layout: Dictionary) -> Dictionary:
	var errors: Array = []
	var names: Array = []
	for r in rooms:
		names.append(str((r as Dictionary).get("name", "")))

	var raw = parameters.get("between", null)
	if typeof(raw) != TYPE_ARRAY or (raw as Array).size() != 2:
		errors.append("a door is named by the two rooms it joins, for example {\"between\": [\"hall\", \"vault\"]} (this dungeon has %s)" % ", ".join(names))
		return {"ok": false, "errors": errors, "door": {}}

	var ends: Array = []
	for side in (raw as Array):
		var found := -1
		if typeof(side) == TYPE_INT or typeof(side) == TYPE_FLOAT:
			var number := int(side)
			if number >= 1 and number <= names.size():
				found = number - 1
		else:
			var wanted := str(side).to_lower().strip_edges().replace(" ", "_")
			for i in names.size():
				if str(names[i]).to_lower().replace(" ", "_") == wanted:
					found = i
					break
		if found < 0:
			errors.append("this dungeon has no room called '%s' (it has %s)" % [str(side), ", ".join(names)])
		ends.append(found)

	if not errors.is_empty():
		return {"ok": false, "errors": errors, "door": {}}
	if int(ends[0]) == int(ends[1]):
		return {"ok": false, "errors": ["a door joins two different rooms"], "door": {}}

	var wanted_key := DungeonModule.door_key(int(ends[0]), int(ends[1]))
	var exists := false
	for d in (layout.get("doors", []) as Array):
		var pair: Vector2i = d
		if DungeonModule.door_key(pair.x, pair.y) == wanted_key:
			exists = true
	if not exists:
		return {"ok": false, "errors": [
			"there is no door between the %s and the %s" % [
				str(names[int(ends[0])]).replace("_", " "), str(names[int(ends[1])]).replace("_", " ")]],
			"door": {}}

	return {"ok": true, "errors": [], "door": {
		"a": int(ends[0]), "b": int(ends[1]),
		"a_name": str(names[int(ends[0])]), "b_name": str(names[int(ends[1])])}}


static func door_readback(parameters: Dictionary, closed: bool) -> String:
	var raw = parameters.get("between", null)
	if typeof(raw) != TYPE_ARRAY or (raw as Array).size() != 2:
		return "to %s a door" % ("shut" if closed else "open")
	return "to %s the door between %s and %s" % [
		"shut" if closed else "open",
		_place(str((raw as Array)[0])), _place(str((raw as Array)[1]))]


static func door_line(door: Dictionary, closed: bool, changed: bool) -> String:
	var where := "between %s and %s" % [
		_place(str(door.get("a_name", ""))), _place(str(door.get("b_name", "")))]
	if not changed:
		return "The door %s was already %s." % [where, "shut" if closed else "open"]
	return "The door %s is %s now." % [where, "shut" if closed else "open"]


# A room in a sentence. "the vault" reads well; "the room 3" does not, because
# the name already says what it is.
#
# 022: the test was "begins with room ", which only ever worked for rooms the
# AI happened to call room_N. Asked to make a dungeon more interesting it
# called them chamber_1..4, and the line came out "the chamber 3". The thing
# that makes an article wrong is the NUMBER on the end, not the word in front
# of it: a numbered name is a label, and labels take no article.
static func _place(label: String) -> String:
	var said := label.replace("_", " ").strip_edges()
	if said == "":
		return "somewhere"
	var words := said.split(" ", false)
	if words.size() > 1 and str(words[words.size() - 1]).is_valid_int():
		return said
	return "the " + said


# What is being attempted, said once the order is accepted. Phrased as an
# attempt, not an outcome: nothing has happened yet.
static func sent_line(parameters: Dictionary) -> String:
	var said := readback(parameters)
	if said.begins_with("to send someone "):
		return "Sending someone " + said.substr(16) + "."
	if said.begins_with("to have "):
		return "Fetching " + said.substr(8).replace(" carried to ", " to ") + "."
	return "Sent."


# What happened, in the player's words. Never said by the character.
# What happened to a delivery, measured from where the thing ENDED UP rather
# than from anything the carrier says.
static func delivery_line(outcome: String, thing: String, room_name: String, actually: String) -> String:
	var what := thing.replace("_", " ")
	match outcome:
		"DELIVERED":
			return "The %s is in %s." % [what, _place(room_name)]
		"NOT_DELIVERED":
			if actually == "":
				return "The %s did not get to %s. It is not in any room." % [what, _place(room_name)]
			return "The %s did not get to %s. It is in %s." % [
				what, _place(room_name), _place(actually)]
		"INCONCLUSIVE":
			return "Cannot tell whether the %s got to %s: it is not in the world any more." % [
				what, _place(room_name)]
	return "Nothing happened."


# 022: this said "the room 2" in all four branches, because it put "the" in
# by hand instead of asking _place. delivery_line had already been fixed the
# same way once (019); the lesson that did not take was that the article
# belongs in ONE function, not in every sentence that needs it. There is now
# no other way to name a room in this file.
static func outcome_line(outcome: String, room_name: String, metres: float, seconds: float) -> String:
	var where := _place(room_name)
	match outcome:
		"ARRIVED":
			return "Got to %s. %.0f m in %.0f seconds." % [where, metres, seconds]
		"BLOCKED":
			return "Could not get to %s: stopped making progress after %.0f m." % [where, metres]
		"GAVE_UP":
			return "Gave up on %s after %.0f seconds and %.0f m." % [where, seconds, metres]
		"NO_ROUTE":
			return "There is no way through to %s." % where
	return "Nothing happened."
