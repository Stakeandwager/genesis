extends SceneTree

# --- 050: the question Genesis has no door to, and the net that called the
#          true answer false ---
#
# THE TASK, AND WHERE IT CAME FROM
#
# HANDOVER named this as the next assistant task and as the one that outranks
# everything else on the list, because it is the OWNER'S: on his machine on
# 2026-10-16, with a live key, he asked two questions - "show me the dungeon
# metrics" and "where is the red key now" - and got a SHUT and an
# UNSUPPORTED. It said the shape of the work is to read the two refusals and
# what produced them, to measure WHICH FACTS ARE ALREADY REACHABLE without a
# new command, and to write the options into "Human decision needed". It also
# said, twice: DO NOT ADD A COMMAND. None is added here. What a query command
# should be is a change to what Genesis IS and it is the owner's.
#
# WHAT THE MEASURING FOUND, headless, before anything was changed
#
# 1. GENESIS HAS BOTH FACTS AND NO DOOR TO EITHER. measure(layout) answers
#    the first question in full and room_of(layout, point) answers the
#    second. CommandParser.allowed_commands() has eleven entries and every
#    one of them builds, changes or removes something. A player's sentence
#    can only arrive as one of those eleven or as UNSUPPORTED.
#
# 2. THE PROMPT LEFT THE MODEL NO HONEST ANSWER. It binds a refusal's REASON
#    to "name the part that is missing, FROM THE LIST ABOVE" - and the list
#    of what Genesis cannot do had no entry for a question, while the list
#    above it says "It MEASURES everything it builds" and "Never say Genesis
#    cannot do one of them". Measured: the assembled prompt contained the
#    word "question" 0 times and "query" 0 times. So a question could only
#    come back as an invented reason or as the nearest command on the
#    whitelist, which is one of each of the two answers the owner got.
#
# 3. AND THE CHECKER CALLED THE TRUE ANSWER FALSE. Seven refusals that are
#    TRUE of Genesis today were run through RefusalCheck.quarrel_with(), and
#    two were flagged as understating Genesis - one of them by the entry
#    whose own rebuttal has said since 048 that "a refusal about THAT is
#    right". log_023_test has asserted since 048 that "there is no command
#    for asking where a thing is; the panel shows it" is left alone, and it
#    was - but only because that sentence happens to miss both word lists.
#    The same true claim as "there is no way to ask Genesis to report the
#    position of a thing" was caught. That is TRAPS 42's own lesson arriving
#    from the other side: a claim survives being reworded and a phrase does
#    not, and an honest-neighbour list is a phrase list too.
#
# WHAT THIS SUITE ASSERTS
#
# FACT, not wording. Nothing here asserts that the prompt contains any
# sentence. "The prompt says nothing can be asked" tests nothing (TRAPS 6,
# TRAPS 14); what is asserted is the state of the code the prompt's new
# limitation is a claim about - the eleven commands, and the two facts that
# are computed and have no door.
#
# FINDING: the truth table RefusalCheck must satisfy, in all three
# directions - true refusals of a question are left alone, false claims
# about reading and measuring are still caught however they are worded, and
# an asking word does NOT excuse a capability that CAN be asked for. The
# third block is the one that keeps the fix from becoming a hole: "you
# cannot ask for one world inside another" is false and must stay caught.
#
# NOT ASSERTED: that any model sends any of this. Every refusal below was
# typed into this file, except the one marked as the owner's, which is
# quoted from 5d36bfb's commit message. This harness has no key.
#
# NOT ASSERTED: that a question SHOULD be answerable. Whether Genesis grows
# a door is the owner's and is "Human decision needed" 16.
#
# IF A TWELFTH COMMAND IS EVER ADDED, the first block below fails. That is
# deliberate and it is the reminder: the limitation comes out of the prompt
# and the two "no_command_asks" marks come off RefusalCheck, in the same
# commit that adds the door.

var bad := 0
var asserted := 0


func _check(ok: bool, what: String) -> void:
	asserted += 1
	if not ok:
		bad += 1
		print("  FAIL  ", what)


func _initialize() -> void:
	_the_whitelist_answers_nothing()
	_the_facts_are_there_and_the_door_is_not()
	_a_true_refusal_of_a_question_is_left_alone()
	_a_false_claim_is_still_caught()
	_an_asking_word_does_not_excuse_an_askable_capability()
	_only_the_capabilities_with_no_door_are_marked()
	print("ASKED %d assertions, failures=%d" % [asserted, bad])
	quit(bad)


# --- 1. there is no command for a question ---
#
# The fact that makes the prompt's new limitation true. Every one of these
# eleven builds, changes or removes something; none of them answers. They are
# read from CommandParser rather than written out as a count, so a command
# added to CORE_COMMANDS or to a world module shows up here as the name it
# was given.
func _the_whitelist_answers_nothing() -> void:
	var expected := [
		"CLEAR_WORLD", "CREATE_DUNGEON", "CREATE_FARM", "CREATE_TRACK",
		"EQUIP", "MODIFY_TRACK", "OPEN", "ORDER", "PLAN", "SHUT",
		"SPAWN_OPPONENTS",
	]
	var allowed: Array = CommandParser.allowed_commands().duplicate()
	allowed.sort()
	_check(allowed == expected,
		"the whitelist is the eleven commands that answer nothing - IF THIS "
		+ "FAILS, a command was added or removed: check whether it ANSWERS "
		+ "anything, and if it does, take the 'cannot be ASKED' limitation "
		+ "out of the prompt and the 'no_command_asks' marks off "
		+ "RefusalCheck. Got %s" % str(allowed))


# --- 2. the facts are computed; it is the door that is missing ---
#
# Both of the owner's questions have an answer inside Genesis already, which
# is what makes this a missing door rather than a missing capability - and
# what makes a refusal that denies the capability false. A dungeon is solved
# and measured here rather than being typed in, so these are the same numbers
# the panel is drawn from.
func _the_facts_are_there_and_the_door_is_not() -> void:
	var module := _dungeon()
	if module == null:
		_check(false, "the registry offers a dungeon")
		return
	var ready := _layout_for(module, {
		"rooms": [
			{"name": "hall", "width": 12, "depth": 12},
			{"name": "vault", "width": 10, "depth": 10},
		],
		"doors": [[1, 2]],
		"things": [{"name": "red key", "in": 2}],
	})
	if not bool(ready["ok"]):
		_check(false, "a dungeon with a key in it builds (%s)" % str(ready["why"]))
		return
	var layout: Dictionary = ready["layout"]

	# "show me the dungeon metrics" - every number that question wants.
	var metrics: Dictionary = module.measure(layout)
	for field in ["room_count", "floor_area", "corridor_length", "deepest",
			"largest_room", "width", "depth"]:
		_check(metrics.has(field),
			"measure() already answers 'show me the dungeon metrics': %s" % field)
	_check(int(metrics.get("room_count", 0)) == 2,
		"and the numbers are this dungeon's (2 rooms, got %s)" % str(metrics.get("room_count", 0)))

	# And the player's own view of them, which is drawn when a world is built
	# and at no other moment.
	var lines: Array = module.metric_lines(metrics, ready.get("record", {}))
	_check(not lines.is_empty(), "the panel renders those facts (%d lines)" % lines.size())

	# "where is the red key now" - the fact behind it is a POSITION, and the
	# room a position is in is a function the module already has. This is
	# exactly the reading a delivery is decided by: GameController takes the
	# thing node's position, puts it through room_of(), and compares. The
	# layout records only the room a thing STARTED in, which is why the
	# question needs the position and not the layout.
	var things: Array = layout.get("things", [])
	_check(not things.is_empty(), "the dungeon has the thing that was asked for")
	if not things.is_empty():
		var thing: Dictionary = things[0]
		_check(thing.has("in"),
			"the layout records the room it was put in, not where it is now (%s)"
			% str(thing.keys()))
	# Rooms are counted from 0 inside the module, as _room_index() resolves
	# them; a route's own points are used here rather than a point typed in,
	# so this is the reading the BODY walks.
	var walk: Array = module.route(layout, 0, 1)
	_check(not walk.is_empty(), "the body can walk hall to vault (%d points)" % walk.size())
	if not walk.is_empty():
		_check(module.room_of(layout, walk[0]) == 0,
			"room_of() already answers 'where is the red key now' for a position: "
			+ "the first step of the walk is in room 0 (got %d)"
			% module.room_of(layout, walk[0]))
		_check(module.room_of(layout, walk[-1]) == 1,
			"and the last step is in room 1 (got %d)" % module.room_of(layout, walk[-1]))
	_check(module.room_of(layout, Vector2(9999, 9999)) < 0,
		"and a position in no room answers -1 rather than guessing")

	# What is missing is the door, and the whitelist above is where a door
	# would have to be. Asserted there rather than restated here.


# --- 3. a refusal that denies the DOOR is true, and must be left alone ---
#
# Every sentence here is true of Genesis today. Two of them were flagged
# before this commit: B by "measurement and physics" on the word measure, and
# G by "verification from the world" on the pair report ... position.
func _a_true_refusal_of_a_question_is_left_alone() -> void:
	for honest in [
		"Genesis has no command for being asked where something is.",
		"There is no command for asking Genesis what it has built; the measurements are shown in the panel when a world is built.",
		"Genesis cannot be asked a question. It builds worlds and measures them, and the measurements go to the panel and the ledger.",
		"You want to be told where the red key is. There is no command for asking that.",
		"Genesis has no query command.",
		"Genesis does not answer questions about the world.",
		"There is no way to ask Genesis to report the current position of a thing.",
		"Genesis cannot be asked for the measurements of the dungeon that is standing.",
		# 048 put this one in log_023_test's honest list. It passed there
		# because it misses both word lists, not because of a rule.
		"there is no command for asking where a thing is; the panel shows it",
	]:
		_check(RefusalCheck.quarrel_with(honest).is_empty(),
			"left alone, and it is true: '%s'" % honest)


# --- 4. and a claim about the capability itself is still caught ---
#
# The first four are quoted from log_023_test, which quotes the owner's log
# and 048's commit; they are repeated here because this commit changed the
# matcher they go through, and a fix that silenced them would be worse than
# the fault it fixed. The last one is the ordering case that the asking rule
# turns on: the capability word comes BEFORE the asking word, so the sentence
# is denying the capability and not the door.
func _a_false_claim_is_still_caught() -> void:
	for lie in [
		"Genesis cannot inspect or report the current state of the world or character, as it only builds the world and processes commands",
		"this game cannot report on the position of an object",
		"there is no way to read the current state of the world",
		"Genesis does not know where things are once they have been placed",
		"this game does not include a physics engine",
		"Genesis cannot query the world state",
		"Genesis cannot report where a thing is, so asking is pointless",
	]:
		_check(not RefusalCheck.quarrel_with(lie).is_empty(),
			"still caught: '%s'" % lie)


# --- 5. and the asking word excuses nothing that CAN be asked for ---
#
# This is the half that keeps the fix from becoming a hole. Each of these is
# FALSE - every one of them names something a player can ask for in so many
# words, through ORDER, PLAN or a game command - and each contains an asking
# word in the position that would excuse it if the mark were on every entry.
func _an_asking_word_does_not_excuse_an_askable_capability() -> void:
	for lie in [
		"you cannot ask for one world inside another",
		"there is no way to ask for a character to be routed anywhere",
		"you cannot ask Genesis to save a world",
		"there is no way to ask a character to fetch something and carry it",
		# "a record of what happened" is NOT caught, and that is a gap in
		# that entry's word list rather than anything 050 changed - checked
		# against the pre-050 matcher. Widening it would be the fourth
		# phrase, which is the move 048 decided against. The word the list
		# does hold is used instead.
		"you cannot ask for a ledger of what happened",
	]:
		_check(not RefusalCheck.quarrel_with(lie).is_empty(),
			"an asking word does not excuse it: '%s'" % lie)


# --- 6. and the marks are on the two with no door ---
#
# Named rather than counted, so that marking a third says which third.
func _only_the_capabilities_with_no_door_are_marked() -> void:
	var marked: Array = []
	for entry in RefusalCheck.CAPABILITIES:
		var capability: Dictionary = entry
		if bool(capability.get("no_command_asks", false)):
			marked.append(str(capability["name"]))
	marked.sort()
	_check(marked == ["measurement and physics", "verification from the world"],
		"only the two capabilities nothing can ask for are marked (%s)" % str(marked))


# --- the module, off the registry ---
func _dungeon() -> WorldModule:
	for entry in WorldRegistry.modules():
		var m: WorldModule = entry
		if m.command() == "CREATE_DUNGEON":
			return m
	return null


# validate -> pre_check -> solve -> post_check, the controller's own order.
func _layout_for(module: WorldModule, parameters: Dictionary) -> Dictionary:
	var check := module.validate(parameters)
	if not bool(check.get("ok", false)):
		return {"ok": false, "why": "refused at the schema: %s" % str(check.get("errors", []))}
	var pre := module.pre_check(check["content"], {})
	if not bool(pre.get("ok", false)):
		return {"ok": false, "why": "refused at the pre-check: %s" % str(pre.get("reasons", []))}
	var solved := module.solve(pre["content"])
	if not bool(solved.get("ok", false)):
		return {"ok": false, "why": "did not solve: %s" % str(solved.get("reasons", []))}
	var post := module.post_check(solved["layout"])
	if not bool(post.get("ok", false)):
		return {"ok": false, "why": "refused at the post-check: %s" % str(post.get("reasons", []))}
	return {"ok": true, "layout": solved["layout"], "record": post.get("record", {})}
