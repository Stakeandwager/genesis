extends SceneTree

# --- 044: the reference said back, at the layer that says it back ---
#
# HANDOVER named the next assistant task as the audit 041 began, 042 and 043
# continued, at the rules 043 did not ask, carrying 043's own question to each
# of them: CAN EVERYTHING THAT NEEDS THIS FUNCTION ACTUALLY REACH IT?
#
# Asked of TRAPS 20 and 30's rule - "a value from the AI is converted through
# Readback.as_number(), never a bare int() or float()" - the answer is that
# the rule holds where it was put. Every bare conversion left in the scripts
# is either downstream of a validator that rewrote the value as a float
# (SectionValidator returns a `clean` array, so TrackGeometry's float() calls
# never see a request) or reads Genesis's own bookkeeping. That is a clean
# answer and it is not this suite.
#
# What the question found instead is the rule one door along, and the answer
# is "only where the fault was found" FOR THE FOURTH COMMIT RUNNING.
#
# THE RULE: a reference by POSITION is a whole number, and one that is not is
# refused with the range named rather than truncated in silence (TRAPS 34,
# fixed in 040 through Readback.ordinal_index()). 040 enumerated five doors
# off the prompt and carried the reading to all five. EVERY ONE OF THOSE FIVE
# IS A VALIDATOR OR A HANDLER. There are six READBACKS beside them that say
# the same reference back to the player, and all six went on calling int() by
# hand.
#
# AND THE REASON IS THE SHAPE OF THE ANSWER, NOT THE SCOPE OF THE FILE.
# ordinal_index() returns a resolved INDEX, or -1. A readback cannot use that:
# its whole job is to show what Genesis HEARD so a dropped or misread clause
# is visible (TRAPS 8), so it must say the value the request CARRIED and never
# the thing that value resolves to. The one reading was unreachable at the
# layer that needed it most - which is 043's question answered a second way.
# Readback.position_said() is the readback's reading of the same fact.
#
# WHAT IT COST, measured headless against the pre-044 code:
#
#   ORDER    "room": 2.9      "to send someone to room 2"
#   ORDER    "room": 0.5      "to send someone to room 0"   (no dungeon has one)
#   ORDER    "room": 99.9     "to send someone to room 99"
#   ORDER    carry, 2.9       "to have the key carried to room 2"
#   SHUT     [1, 2.9]         "between the 1 and the 2.9"
#   MODIFY_TRACK "corner":2.9 "to make corner 2 hard"
#   SPAWN_OPPONENTS 1.5       "to put an opponent on the track"
#   CREATE_DUNGEON "in": 2.9  "with a key in the vault"      (room 2, named)
#   PLAN     "around": 1.5    "one inside the other"
#
# Next to each of those, in the same exchange, the refusal 040 and 041 built
# says the number exactly: "there is no room 2.9", "thing 1: 'key' is in room
# 2.9", "'around' must be a whole step number (1 to 1), not 1.5". TWO
# SENTENCES ABOUT ONE REQUEST, DISAGREEING ABOUT THE NUMBER - and the one the
# player is invited to check is the one that was wrong. That is the fault this
# suite is the door for, and it is asserted as AGREEMENT between the two
# layers rather than as a phrase, so rewording either leaves it green.
#
# WHY NO SUITE SAW IT, WHICH IS THE PART WORTH KEEPING. procedure_test does
# exactly what 040 set out to do: it probes 1.5, 2.9, count + 0.5 and 0.5 at
# all five reference doors and asserts each is refused with "whole" and the
# range named. Seven assertions a door, green every run since 040. EVERY ONE
# OF THEM GOES THROUGH _resolve(), WHICH IS THE VALIDATOR. The suite is
# correct, its values are the right values, its class is the whole class - and
# the LAYER beside it was never asked. TRAPS 6 for the fourth commit running,
# and in a fourth costume: 041's blind spot was the probe's VALUES, 042's was
# the sweep's DIRECTION, 043's was the input's SHAPE, and this one is the
# LAYER. Genesis keeps four evidence layers apart on purpose (PROTOCOL
# section 2) and a suite that asks one of them has not asked the others.
#
# WHAT THIS SUITE ASSERTS: that each readback names the reference exactly as
# the request carried it, AND does not name the position below it - the two
# directions, because a check for what should be there cannot see what should
# not (TRAPS 36, and 043's own first draft); that the readback and the refusal
# for the SAME request name the same number, which is the property that was
# broken and is independent of both sentences' wording; that a whole, legal
# reference still reads as it always did, so this is not a licence to stop
# resolving; what position_said() says, as facts about numbers typed in here
# rather than read from the function under test; and a sweep over every door
# at once with the truncated position matched on a word boundary.
#
# WHAT IT DOES NOT ASSERT. No model sent any of this; every value was typed
# by hand. Nothing ran on Windows or in the editor: what is measured is the
# string a function returns, not what a person reads on screen. Whether "to
# put 2.9 opponents on the track" is better PROSE than "an opponent" is a
# judgement a test cannot make - what it can make is that the sentence does
# not name a count the request never carried, and that is what it checks.
#
# WHAT THIS SUITE'S OWN SWEEP IS BLIND TO, which is the question 042 raised
# about every sweep in tests/ and is worth asking of a new one in the same
# breath. The sweep matches "<noun> <truncated>", so it can only see a door
# whose pre-044 sentence used the NOUN. SHUT and OPEN did not: they put a room
# NUMBER through _place(), the definite article's reader, so [1, 2.9] read
# "between the 1 and the 2.9" - the number said faithfully and then dressed as
# a room's name. Measured: the sweep reports 81 truncations against the pre-044
# code and NOT ONE of them is at those two doors. They are caught, by the
# assertion that the sentence names the reference WITH ITS NOUN - which is why
# that assertion is there as well as the sweep, and why a door's fault can be
# a different fault from its neighbour's.
#
# AND THIS SUITE'S OWN FIRST DRAFT MEASURED ITS FIXTURE, for the third commit
# running that a new suite walked into the fault it is about. The SHUT and
# OPEN probes put room 1 on the other side of the door and then asserted that
# "room 1" is absent from the sentence - so nine values a door reported a
# fault that was the fixture's. The other side is a NAME now. Measured: with
# the collision in place the suite failed 5 times against the POST-044 code,
# which is a suite reporting on itself.

var failures: Array = []
var asserted := 0
var lines: Array = []


func _check(ok: bool, what: String) -> void:
	asserted += 1
	if ok:
		lines.append("PASS  " + what)
	else:
		failures.append(what)
		lines.append("FAIL  " + what)


# Whole words. "room 2.9" CONTAINS "room 2", which is the whole reason this
# suite needs a boundary test and not contains(): a check that the truncated
# position is ABSENT is exactly the check a substring test cannot make. 043's
# first draft walked into this and twelve of its assertions passed against
# the fault they were written for (TRAPS 36, TRAPS 37).
func _says(text: String, phrase: String) -> bool:
	var re := RegEx.new()
	re.compile("(^|[^0-9A-Za-z_.])%s([^0-9A-Za-z_.]|$)" % phrase.replace(" ", "[ ]").replace(".", "[.]"))
	return re.search(text) != null


# The rooms every door in this suite is asked about.
func _rooms() -> Array:
	return [{"name": "hall", "width": 12, "depth": 12},
		{"name": "vault", "width": 20, "depth": 20},
		{"name": "crypt", "width": 16, "depth": 16}]


func _farm() -> Dictionary:
	return {"zones": [{"type": "field", "width": 40, "depth": 40},
		{"type": "field", "width": 30, "depth": 30}]}


# --- every door that says a reference back, and the value it is asked ---
#
# Each entry is: the door's name, the noun it says the reference with, the
# sentence it produces for a value, and the refusal (or "" where the door has
# none) for the SAME value. Keyed on the door rather than written out as
# sentences, so a door that changes its wording stays green and a door that
# starts truncating again does not.
func _door_said(door: String, value: Variant) -> String:
	match door:
		"ORDER go_to":
			return NpcGoals.readback({"goal": "go_to", "room": value})
		"ORDER carry":
			return NpcGoals.readback({"goal": "carry", "thing": "key", "room": value})
		"SHUT between":
			# The other side is a NAME, deliberately. The first draft of this
			# suite put room 1 on the other side and then asserted that
			# "room 1" is absent, so it reported its own fixture as the
			# fault at nine values a door. A probe whose fixture can collide
			# with its assertion measures the fixture.
			return NpcGoals.door_readback({"between": ["hall", value]}, true)
		"OPEN between":
			return NpcGoals.door_readback({"between": [value, "hall"]}, false)
		"MODIFY_TRACK corner":
			return TrackBuilder.readback({"corner": value, "difficulty": "hard"})
		"CREATE_DUNGEON in":
			var d := DungeonModule.new()
			return d.readback({"rooms": _rooms(), "doors": [[1, 2], [2, 3]],
				"things": [{"name": "key", "in": value}]})
	return ""


func _door_refusal(door: String, value: Variant) -> String:
	var said := ""
	var errors: Array = []
	match door:
		"ORDER go_to":
			errors = NpcGoals.validate({"goal": "go_to", "room": value}, _rooms(), [])["errors"]
		"ORDER carry":
			errors = NpcGoals.validate({"goal": "carry", "thing": "key", "room": value},
				_rooms(), [{"name": "key", "in": 1}])["errors"]
		"SHUT between":
			errors = NpcGoals.validate_door({"between": ["hall", value]}, _rooms(),
				{"doors": [Vector2i(0, 1), Vector2i(1, 2)]})["errors"]
		"OPEN between":
			errors = NpcGoals.validate_door({"between": [value, "hall"]}, _rooms(),
				{"doors": [Vector2i(0, 1), Vector2i(1, 2)]})["errors"]
		"CREATE_DUNGEON in":
			var d := DungeonModule.new()
			errors = d.validate({"rooms": _rooms(), "doors": [[1, 2], [2, 3]],
				"things": [{"name": "key", "in": value}]})["errors"]
	for e in errors:
		said += str(e) + " "
	return said


# The nouns each door says a reference with, so the sweep below knows what
# "the position below it" would look like in that door's own words.
func _door_noun(door: String) -> String:
	if door == "MODIFY_TRACK corner":
		return "corner"
	return "room"


func _doors() -> Array:
	return ["ORDER go_to", "ORDER carry", "SHUT between", "OPEN between",
		"MODIFY_TRACK corner", "CREATE_DUNGEON in"]


# --------------------------------------------------------------------
# 1. The one reading, against the fact rather than against itself
# --------------------------------------------------------------------
func _the_one_reading() -> void:
	# Facts about numbers, typed in here. A test that asked position_said()
	# what position_said() returns would assert nothing (TRAPS 6).
	var facts := {2.9: "room 2.9", 0.5: "room 0.5", 99.9: "room 99.9",
		2.0: "room 2", 1.0: "room 1", 0.0: "room 0", 12.25: "room 12.25"}
	for value in facts:
		_check(Readback.position_said(value, "room") == str(facts[value]),
			"position_said(%s) is '%s'" % [String.num(value, 2), str(facts[value])])
	_check(Readback.position_said(3.0, "corner") == "corner 3",
		"and it says the noun it was given, not 'room'")

	# The chain: a reference is said through number_said(), which is 041's one
	# reading for every number out of a request. Asserted as agreement between
	# the two functions, so neither can be changed alone.
	for value in [2.9, 0.5, 2.0, 1.0e3, 7.125]:
		_check(Readback.position_said(value, "step") == "step " + Readback.number_said(value),
			"position_said defers to number_said at %s" % String.num(value, 3))

	# And the two layers' readings answer the same question in opposite
	# directions: exactly the values ordinal_index() refuses are the values a
	# readback must say back rather than resolve.
	for value in [2.9, 0.5, 99.9, -1.5, 3.5]:
		_check(Readback.ordinal_index(value, 3) < 0,
			"%s is no position in a list of 3, so a readback must say it rather than resolve it" % String.num(value, 2))


# --------------------------------------------------------------------
# 2. Every door: said as sent, and the truncated position absent
# --------------------------------------------------------------------
func _said_as_sent() -> void:
	for door in _doors():
		var noun := _door_noun(door)
		for value in [2.9, 1.5, 3.5, 0.5]:
			var said := _door_said(door, value)
			_check(said != "", "%s: a request for %s is described at all" % [
				door, String.num(value, 2)])
			# The number the request carried, exactly.
			_check(_says(said, "%s %s" % [noun, Readback.number_said(value)]),
				"%s: %s is said back as %s" % [door, String.num(value, 2),
					Readback.position_said(value, noun)])
			# And NOT the position below it. int(2.9) is 2, and "room 2.9"
			# contains "room 2", so this is the direction a substring test
			# cannot see - matched on a word boundary instead.
			var below := "%s %d" % [noun, int(value)]
			_check(not _says(said, below),
				"%s: and never '%s', which is what int() made of it" % [door, below])

		# A number out of the list is said back too, rather than dropped: a
		# readback that loses the clause cannot be used to catch a dropped
		# one, which is the only reason it exists (TRAPS 8).
		for value in [99.0, 0.0]:
			var said := _door_said(door, value)
			_check(_says(said, "%s %s" % [noun, Readback.number_said(value)]),
				"%s: %s is out of range and still said back" % [door, String.num(value, 1)])


# --------------------------------------------------------------------
# 3. The readback and the refusal name the same number
# --------------------------------------------------------------------
# The property that was broken. Independent of both sentences' wording: it
# asserts only that the number in one is the number in the other, so either
# may be rephrased freely and neither may quietly change the value.
func _the_two_layers_agree() -> void:
	for door in _doors():
		var refusal := _door_refusal(door, 2.9)
		if refusal == "":
			lines.append("note  %s has no refusal to agree with (none exists)" % door)
			continue
		var said := _door_said(door, 2.9)
		_check(_says(refusal, "2.9"), "%s: the refusal names 2.9" % door)
		_check(_says(said, "2.9"), "%s: and the readback beside it names 2.9 too" % door)
		_check(not _says(said, "%s 2" % _door_noun(door)),
			"%s: and neither of them names %s 2" % [door, _door_noun(door)])


# --------------------------------------------------------------------
# 4. A whole, legal reference still reads as it always did
# --------------------------------------------------------------------
# This is not a licence to stop resolving. Saying a reference back as sent is
# what a readback owes for a value it cannot use; for one it can, the name is
# the more useful sentence and it must survive.
func _the_legal_case_did_not_move() -> void:
	_check(_says(NpcGoals.readback({"goal": "go_to", "room": "vault"}), "the vault"),
		"a room NAME still reads as the name")
	_check(_says(NpcGoals.readback({"goal": "go_to", "room": 2.0}), "room 2"),
		"a whole number still reads as its position")
	_check(not _says(NpcGoals.readback({"goal": "go_to", "room": 2.0}), "room 2.0"),
		"and 2 sent as a JSON float is not read back as '2.0'")
	var d := DungeonModule.new()
	var resolved := d.readback({"rooms": _rooms(), "doors": [[1, 2], [2, 3]],
		"things": [{"name": "key", "in": 2.0}]})
	_check(_says(resolved, "the vault"),
		"a thing's 'in' still resolves a usable number to the room's name")
	_check(not _says(resolved, "room 2"),
		"and does not say the number instead of the name it resolved to")
	_check(_says(OpponentBuilder.readback({"count": 2.0}), "two opponents"),
		"a whole count is still spelled in words")
	_check(_says(OpponentBuilder.readback({"count": 1.0}), "an opponent"),
		"and a count of one still agrees with its noun")


# --------------------------------------------------------------------
# 5. A count that is not whole
# --------------------------------------------------------------------
# count_of() spells a count in words, and the words are only ever right about
# a whole one: int() handed it 1 for 1.5, so "to put an opponent on the track"
# for a request that asked for one and a half.
func _a_count_that_is_not_whole() -> void:
	for value in [2.9, 1.5, 8.5]:
		var said := OpponentBuilder.readback({"count": value})
		_check(_says(said, Readback.number_said(value)),
			"SPAWN_OPPONENTS: a count of %s is said as %s" % [
				String.num(value, 2), Readback.number_said(value)])
		_check(not _says(said, "%d opponents" % int(value)) and not _says(said, "an opponent"),
			"SPAWN_OPPONENTS: and %s is not spelled as %d" % [
				String.num(value, 2), int(value)])


# --------------------------------------------------------------------
# 6. The plan's "around": the request's question, not the placement's
# --------------------------------------------------------------------
# A readback is the interpretation layer. Whether this step asked to sit
# inside an earlier one is a fact about the REQUEST; whether the step number
# is usable is the validation layer's, and around_problem() answers it in its
# own sentence. The old line read the resolved position and so promised
# containment for 1.5 (which the schema pass then refused) and denied it for
# null (which plainly asked for it).
func _the_plan_relationship() -> void:
	var rooms := _rooms()
	for value in [1.5, 1.0, 99.0, 0.0]:
		var said := WorldRegistry.readback("PLAN", {"steps": [
			{"command": "CREATE_DUNGEON", "parameters": {"rooms": rooms, "doors": [[1, 2], [2, 3]]}},
			{"command": "CREATE_FARM", "around": value, "parameters": _farm()}]})
		_check(said.contains("one inside the other"),
			"PLAN: 'around': %s asked for containment and is described as asking for it" % String.num(value, 2))
	var absent := WorldRegistry.readback("PLAN", {"steps": [
		{"command": "CREATE_DUNGEON", "parameters": {"rooms": rooms, "doors": [[1, 2], [2, 3]]}},
		{"command": "CREATE_FARM", "parameters": _farm()}]})
	_check(absent.contains("side by side"),
		"PLAN: and a plan that asked for no containment is not told it did")

	# The two readings of "around" cannot disagree about a value again. This
	# is not reachable by a player - the schema pass refuses a fraction before
	# anything is prepared - and it is closed because the only reason
	# around_of() exists is that two readings of this field drifted once.
	for value in [1.5, 2.9]:
		_check(WorldRegistry.around_of({"around": value}) < 1,
			"around_of() does not take %s to the step below it" % String.num(value, 2))
		_check(WorldRegistry.around_problem({"around": value}, 3, 3) != "",
			"and around_problem() refuses it, as it has since 036")
	_check(WorldRegistry.around_of({"around": 2.0}) == 2,
		"while a whole step number still resolves")


# --------------------------------------------------------------------
# 7. A sweep, independent of every assertion above
# --------------------------------------------------------------------
# Every door, every value, one question: does any sentence name the position
# the value would have been truncated to? Written as a regex with a boundary
# on BOTH sides, because "room 2.9" contains "room 2" and that is the whole
# fault. A sweep that could only see one direction is TRAPS 36.
func _sweep() -> void:
	var found: Array = []
	var checked := 0
	for door in _doors():
		var noun := _door_noun(door)
		for tenth in range(11, 40):
			var value := float(tenth) / 10.0
			if value == floor(value):
				continue
			var said := _door_said(door, value)
			if said == "":
				continue
			checked += 1
			var truncated := RegEx.new()
			truncated.compile("(^|[^0-9A-Za-z_.])%s[ ]%d([^0-9.]|$)" % [noun, int(value)])
			if truncated.search(said) != null:
				found.append("%s said '%s %d' for %s" % [door, noun, int(value), String.num(value, 1)])
	_check(found.is_empty(), "sweep: %d sentences, none names a truncated position%s" % [
		checked, "" if found.is_empty() else " - %s" % "; ".join(PackedStringArray(found))])
	_check(checked >= 150, "sweep: and it actually produced sentences to read (%d)" % checked)


func _initialize() -> void:
	_the_one_reading()
	_said_as_sent()
	_the_two_layers_agree()
	_the_legal_case_did_not_move()
	_a_count_that_is_not_whole()
	_the_plan_relationship()
	_sweep()

	for line in lines:
		print(line)
	print("")
	print("SAID POSITION %d assertions, failures=%d" % [asserted, failures.size()])
	quit(failures.size())
