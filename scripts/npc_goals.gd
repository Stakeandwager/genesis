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
		# 040: a fraction is not room 2. int() used to make it room 2 and say
		# nothing - see Readback.ordinal_index() for the class this is one of.
		if Readback.is_fraction(asked):
			errors.append("there is no room %s: %s" % [
				Readback.number_said(asked),
				Readback.whole_number_rule("room", rooms.size())])
		else:
			var number := int(asked)
			if number < 1 or number > rooms.size():
				# 034: "this dungeon has 1 rooms". The same hand-written plural
				# as DungeonModule's door count, in the file TRAPS 10 and 23
				# both came out of.
				errors.append("this dungeon has %s, so there is no room %d" % [
					Readback.plural(rooms.size(), "room"), number])
			else:
				room = Readback.ordinal_index(asked, rooms.size())
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
		var thing := _thing(str(parameters.get("thing", "")))
		var asked_room = parameters.get("room", null)
		var where := ""
		if asked_room == null:
			where = "somewhere"
		elif typeof(asked_room) == TYPE_INT or typeof(asked_room) == TYPE_FLOAT:
			# 044: said as it was sent, never as the room it would index.
			# This was `"room %d" % int(asked_room)`.
			where = Readback.position_said(asked_room, "room")
		else:
			where = _place(str(asked_room))
		if thing == "":
			return "to have something carried to %s" % where
		return "to have %s carried to %s" % [thing, where]
	if goal != "go_to":
		return ""
	var asked = parameters.get("room", null)
	if asked == null:
		return "to send someone somewhere"
	if typeof(asked) == TYPE_INT or typeof(asked) == TYPE_FLOAT:
		# 044: the same reading as the carry branch above, and as every other
		# readback that says a reference back - see Readback.position_said().
		return "to send someone to %s" % Readback.position_said(asked, "room")
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
		var numbered := typeof(side) == TYPE_INT or typeof(side) == TYPE_FLOAT
		if numbered:
			# 040: one reading, shared with the other four doors. This was
			# int(side), so [1, 2.9] shut the door between rooms 1 and 2.
			found = Readback.ordinal_index(side, names.size())
		else:
			var wanted := str(side).to_lower().strip_edges().replace(" ", "_")
			for i in names.size():
				if str(names[i]).to_lower().replace(" ", "_") == wanted:
					found = i
					break
		if found < 0:
			# 040: and a NUMBER is not refused as though it were a name. This
			# door said "no room called '0'" and then listed the room names -
			# answering with names a model that had given a number, and never
			# naming the range, which every other reference door does
			# (TRAPS 18's rule, at the one door nobody had asked).
			if numbered:
				errors.append("this dungeon has no room %s: %s" % [
					Readback.number_said(side),
					Readback.whole_number_rule("room", names.size())])
			else:
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
			"there is no door between %s and %s" % [
				_place(str(names[int(ends[0])])), _place(str(names[int(ends[1])]))]],
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
		_side_said((raw as Array)[0]), _side_said((raw as Array)[1])]


# --- 044: a room NUMBER at this door was said as though it were a NAME ---
#
# The prompt offers either at "between", and this readback put both through
# _place(), which is the definite article's reader. is_label() says - rightly,
# and says so in its own comment - that a bare number is not a label, because
# there is no name in front of it to label. So "between": [1, 2] read back as
# "the door between the 1 and the 2", and [1, 2.9] as "the 1 and the 2.9":
# the number was said faithfully and then dressed as a room's name, at the one
# reference door where the sides are not resolved before the sentence is
# written. A number is a POSITION and is said as one, which is the reading the
# other five doors use (Readback.position_said()).
static func _side_said(side: Variant) -> String:
	if typeof(side) == TYPE_INT or typeof(side) == TYPE_FLOAT:
		return Readback.position_said(side, "room")
	return _place(str(side))


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
	var said := Readback.the(label)
	# A room nobody named is still somewhere; that part is this file's, not
	# the article's.
	return "somewhere" if said == "" else said


# A THING in a sentence, and the half of this rule that had no function at
# all. _place() has carried the definite article for a ROOM since 022 and
# the comment below outcome_line() said there was no other way to name a
# room in this file - while six sentences here wrote "the" in front of a
# THING by hand, and one wrote it in front of two ROOMS. Measured on the
# pre-043 code: "to have the key 2 carried to the vault", "The key 2 is in
# the vault.", "there is no door between the room 1 and the room 2".
static func _thing(name: String) -> String:
	return Readback.the(name)


# Why a carry could not start, which lived inline in GameController until
# 043. GameController is a Node3D and no suite can instantiate one, so these
# two sentences were the only ones in this family that nothing could read -
# and both wrote "the" in front of a thing's name by hand. 042 hit the same
# wall at /worlds and moved the sentence to WorldStore for the same reason:
# a sentence a suite cannot reach is a sentence nothing holds.
#
# "gone" is the thing no longer in the world at all; "roomless" is a thing
# in the world but outside every room.
static func missing_thing_line(thing: String, why: String) -> String:
	var what := _thing(thing)
	if why == "roomless":
		return "%s is not in any room" % what
	return "%s is not in the world any more" % what


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
	var what := _thing(thing)
	var opener := Readback.sentence_start(what)
	match outcome:
		"DELIVERED":
			return "%s is in %s." % [opener, _place(room_name)]
		"NOT_DELIVERED":
			if actually == "":
				return "%s did not get to %s. It is not in any room." % [opener, _place(room_name)]
			return "%s did not get to %s. It is in %s." % [
				opener, _place(room_name), _place(actually)]
		"INCONCLUSIVE":
			return "Cannot tell whether %s got to %s: it is not in the world any more." % [
				what, _place(room_name)]
	return "Nothing happened."


# 022: this said "the room 2" in all four branches, because it put "the" in
# by hand instead of asking _place. delivery_line had already been fixed the
# same way once (019); the lesson that did not take was that the article
# belongs in ONE function, not in every sentence that needs it.
#
# 043: and the sentence this comment used to end with - "There is now no
# other way to name a room in this file" - was FALSE when it was written and
# stayed false for twenty-one commits. validate_door's no-door refusal named
# TWO rooms with a hand-written "the", and six sentences here named a THING
# the same way, which this comment did not cover because it was written
# about rooms. A claim about the code is checked like any other claim
# (TRAPS 14); this one is now true of rooms AND things, and said_article_test
# is what keeps it true rather than this comment.
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
