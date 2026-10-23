extends SceneTree

# 022 - the five faults in one editor session, each asserted by the exact
# words the owner's log printed.
#
# WHERE THESE CAME FROM
# Not from reading the code. From a long adversarial session on the owner's
# machine, typed by hand against a live API key, on hardware this harness
# cannot reach. Everything in that log RAN - a key was fetched and delivered
# and the delivery was verified from the key's own position - and the session
# still produced five sentences that were not true, or were true of something
# nobody asked about.
#
# That is the pattern worth naming: the faults a green suite misses are not
# crashes. They are confident sentences. Four of these five are a readback or
# a verdict describing something other than the request, which is the one
# thing those layers exist to prevent, and the suite that was supposed to
# protect them was written by the same hand as the code and shared its
# assumptions. So every assertion below quotes the log rather than the
# implementation.

var bad := 0


func _check(ok: bool, what: String) -> void:
	print(("PASS  " if ok else "FAIL  ") + what)
	if not ok:
		bad += 1


func _initialize() -> void:
	_defect_5_look_readback()
	_defect_4_false_revision()
	_defect_3_plan_with_an_order()
	_defect_2_articles()
	_defect_1_missing_tool()

	print("log_022_test failures=%d" % bad)
	quit(1 if bad > 0 else 0)


# --- 5: the readback described the defaults, not the request ---
#
# LOG: "give me my own face from C:\Users\Owner\Pictures\yourphoto.jpg"
#      READBACK: a plain tan head
#      EQUIP failed: there is no file at '...'
#
# The refusal is right: the file is not there. The READBACK is the fault. The
# player asked for their own face and was told Genesis understood a plain tan
# head, which is the same class of half-truth as 011 and 016 and is worse than
# saying nothing, because a player who reads it learns that the line can be
# ignored.
func _defect_5_look_readback() -> void:
	var missing := "C:\\Users\\Owner\\Pictures\\yourphoto.jpg"
	var asked := {"tool": "look", "spec": {"face": missing}}

	var said := ToolRegistry.readback(asked)
	_check(not said.contains("plain"), "a refused face is not read back as a plain head")
	_check(said.contains("face"), "a refused face is still read back as a face: '%s'" % said)

	# And the path itself never appears. Half a file path is usually somebody's
	# name, and this line goes into a log nobody asked to keep.
	_check(not said.contains("Owner") and not said.contains("yourphoto"),
		"the readback does not say the path back")

	# The refusal still happens. Describing a request is not accepting it, and
	# nothing may be built from what asked_spec returns.
	var checked: Dictionary = LookTool.new().validate(asked)
	_check(not bool(checked["ok"]), "a missing picture is still refused")

	# A value of the wrong kind entirely is left out rather than read back as
	# though it were a number.
	var nonsense := ToolRegistry.readback({"tool": "boots", "spec": {"push": "lots"}})
	_check(nonsense != "", "a nonsense spec still gets a line")

	# A spec that is legal is unchanged by any of this.
	var good := ToolRegistry.readback({"tool": "look", "spec": {"skin": "deep"}})
	_check(good.contains("deep"), "a legal look still reads back: '%s'" % good)


# --- 4: REVISED invented out of the word "actually" ---
#
# LOG: UNDERSTANDING: REVISED (SAID_REVISED) twice, on these two requests:
#   "...Confirm delivery only if the key itself is actually in room 3."
#   "...Test whether they actually do it."
#
# Neither is a revision. Neither mentions the readback it was scored against.
# The understanding layer exists to stop evidence being manufactured, and it
# was manufacturing it from an adverb - and a tester's favourite adverb at
# that, which is why two of eight requests in one session were wrong.
func _defect_4_false_revision() -> void:
	var from_the_log := [
		"Put a red key in the entrance room. Send someone to pick it up and deliver it to room 3. Confirm delivery only if the key itself is actually in room 3.",
		"Give me boots that stop me within one metre when I am moving at five metres per second. Test whether they actually do it.",
	]
	for request in from_the_log:
		var verdict: Dictionary = Understanding.judge(request, "", true)
		_check(str(verdict.get("understanding", "")) != "REVISED",
			"not a revision: '%s...'" % str(request).substr(0, 40))

	# Nor is an ordinary question containing the word.
	for innocent in [
		"does the door actually shut",
		"show me what it actually measured",
		"tell me whether the character actually arrived and how far it walked",
	]:
		var verdict: Dictionary = Understanding.judge(innocent, "", true)
		_check(str(verdict.get("understanding", "")) != "REVISED",
			"not a revision: '%s'" % innocent)

	# A real change of mind is still caught, in every position somebody puts it.
	var revisions := [
		"actually, make it a row",
		"Actually I want four rooms",
		"no, actually I changed my mind",
		"make it a row instead",
		"scratch that, build a farm",
		"I'd rather have one big hall",
		"forget that, clear it",
	]
	for said in revisions:
		var verdict: Dictionary = Understanding.judge(said, "", true)
		_check(str(verdict.get("understanding", "")) == "REVISED",
			"a revision is still caught: '%s' -> %s" % [said, str(verdict.get("understanding", "?"))])

	# And none of this touched the verdicts either side of it. A revision is
	# scored before a bare no and after a stated misreading, and both still are.
	var misread: Dictionary = Understanding.judge("You misunderstood me. I wanted two ponds, not one.", "", true)
	_check(str(misread.get("understanding", "")) == "CORRECTED", "a stated misreading is still CORRECTED")
	var denied: Dictionary = Understanding.judge("no", "", true)
	_check(str(denied.get("understanding", "")) == "DISPUTED", "a bare no is still DISPUTED")
	var quiet: Dictionary = Understanding.judge("build a farm with a barn", "", true)
	_check(str(quiet.get("understanding", "")) == "ACCEPTED_BY_SILENCE", "a new request is still silence")


# --- 3: "a dungeon of five rooms and an order, side by side" ---
#
# LOG, for a request that built a dungeon with a key in it and then had the
# key carried to room 3. An order is not side by side with anything, and the
# line never said WHICH errand - so the clause a player most needed to check
# was the one clause the readback could not describe.
func _defect_3_plan_with_an_order() -> void:
	var plan := {"steps": [
		{"command": "CREATE_DUNGEON", "parameters": {
			"rooms": [
				{"name": "large_hall", "width": 20, "depth": 20},
				{"name": "room_1", "width": 10, "depth": 10},
				{"name": "room_2", "width": 10, "depth": 10},
				{"name": "room_3", "width": 10, "depth": 10},
				{"name": "room_4", "width": 10, "depth": 10}],
			"doors": [[1, 2], [2, 3], [3, 4], [4, 5]],
			"things": [{"name": "red_key", "in": "large_hall"}]}},
		{"command": "ORDER", "parameters": {"goal": "carry", "thing": "red_key", "room": "room_3"}},
	]}

	var said := WorldRegistry.readback("PLAN", plan)
	print("      PLAN: %s" % said)
	_check(not said.contains("side by side"), "one world and an order are not side by side")
	_check(said.contains("red key"), "the plan says what is being carried: '%s'" % said)
	_check(said.contains("room 3"), "the plan says where it is going: '%s'" % said)
	_check(said.contains("dungeon") or said.contains("rooms"), "the plan still says what is built")

	# Two worlds still get their spatial line, because that is still the thing
	# a player must be able to catch: the build succeeds either way.
	var two := {"steps": [
		{"command": "CREATE_FARM", "parameters": {"zones": [{"type": "barn", "width": 20, "depth": 20}]}},
		{"command": "CREATE_DUNGEON", "parameters": {
			"rooms": [{"name": "hall", "width": 10, "depth": 10}], "doors": []}},
	]}
	_check(WorldRegistry.readback("PLAN", two).contains("side by side"),
		"two unrelated worlds are still side by side")

	var nested := {"steps": [
		{"command": "CREATE_FARM", "parameters": {"zones": [{"type": "barn", "width": 20, "depth": 20}]}},
		{"command": "CREATE_DUNGEON", "parameters": {
			"rooms": [{"name": "hall", "width": 10, "depth": 10}], "doors": [], "around": 1}},
	]}
	_check(WorldRegistry.readback("PLAN", nested).contains("one inside the other"),
		"a world around a world is still one inside the other")

	# A plan of one world reads as that world, as it always did.
	var alone := {"steps": [{"command": "CREATE_FARM", "parameters": {
		"zones": [{"type": "pond", "width": 50, "depth": 50}]}}]}
	var one := WorldRegistry.readback("PLAN", alone)
	_check(not one.contains("then") and not one.contains("side by side"),
		"a plan of one thing has no relationship to describe: '%s'" % one)


# --- 2: "Got to the room 2." and "Fetching the red key to the chamber 3." ---
#
# Both from the log. 019 put the article in one function and fixed the carry
# path; the go_to path kept its own copy and said "the room 2" again. And the
# one function only knew names beginning "room ", so when the AI called them
# chamber_1..4 it produced "the chamber 3".
func _defect_2_articles() -> void:
	var lines := [
		NpcGoals.outcome_line("ARRIVED", "room_2", 51.0, 13.0),
		NpcGoals.outcome_line("BLOCKED", "room_2", 20.0, 0.0),
		NpcGoals.outcome_line("GAVE_UP", "chamber_3", 20.0, 90.0),
		NpcGoals.outcome_line("NO_ROUTE", "chamber_3", 0.0, 0.0),
		NpcGoals.delivery_line("DELIVERED", "red_key", "chamber_3", ""),
		NpcGoals.sent_line({"goal": "carry", "thing": "red_key", "room": "chamber_3"}),
		NpcGoals.sent_line({"goal": "go_to", "room": "room_2"}),
	]
	for line in lines:
		print("      %s" % line)
		_check(not line.contains("the room ") and not line.contains("the chamber "),
			"no article on a numbered room: '%s'" % line)

	# A room with a name of its own still takes one.
	var named := NpcGoals.outcome_line("ARRIVED", "large_hall", 51.0, 13.0)
	_check(named.contains("the large hall"), "a named room still takes its article: '%s'" % named)
	var vault := NpcGoals.delivery_line("DELIVERED", "red_key", "vault", "")
	_check(vault.contains("the vault"), "'the vault' still reads as the vault: '%s'" % vault)

	# --- 031: and the INDEFINITE article, which was never asked ---
	#
	# The rule above was applied to "the" and left alone for "a". The
	# dungeon's readback puts "a" in front of a room's name and a thing's
	# name, so the same model output that produced "the chamber 3" here
	# produced "a room 1" and "a key 2" there. One fact with two renderings,
	# fixed in one of them - which is what 019 did, and what 022 found it
	# had done. Both now read Readback.is_label().
	var d := DungeonModule.new()
	var unsized := d.readback({"rooms": [
		{"name": "room_1", "width": null, "depth": null},
		{"name": "chamber_2", "width": null, "depth": null}], "doors": [[1, 2]]})
	print("      %s" % unsized)
	_check(not unsized.contains("a room 1") and not unsized.contains("a chamber 2"),
		"no article on a numbered room in a readback either: '%s'" % unsized)
	_check(unsized.contains("room 1") and unsized.contains("chamber 2"),
		"and both rooms are still named: '%s'" % unsized)

	var things := d.readback({"rooms": [
		{"name": "hall", "width": 12, "depth": 12},
		{"name": "vault", "width": 12, "depth": 12}], "doors": [[1, 2]],
		"things": [{"name": "key_2", "in": 1}, {"name": "red_key", "in": 2}]})
	print("      %s" % things)
	_check(not things.contains("a key 2"), "nor on a numbered thing: '%s'" % things)
	_check(things.contains("a red key"), "and a thing with a name still takes one: '%s'" % things)

	# The fact itself, so the two readers cannot be given different answers.
	#
	# 071: this list and said_article_test's were the same list, and both
	# held only names of ONE word plus a number - so narrowing is_label()
	# to `words.size() != 2` passed both (TRAPS 11: the same assertion in
	# two suites is two sites of one fault). A room name has no shape
	# constraint in DungeonModule.validate(), so a multi-word numbered name
	# is a name a player can be shown.
	for label in ["room 2", "room_2", "chamber 3", "level 2",
			"great hall 2", "great_hall_2", "the long hall 12"]:
		_check(Readback.is_label(label), "'%s' is a label" % label)
	for name in ["vault", "large hall", "red key", "2", "",
			"great hall", "room 2 exit"]:
		_check(not Readback.is_label(name), "'%s' is not a label" % name)


# --- 1: EQUIP with no tool field ---
#
# LOG: {"command":"EQUIP","parameters":{"intent":...,"spec":{"brake":625}}}
#      EQUIP failed: this game has no tool called '' (it has car, boots, look)
#
# The refusal is correct and the spec was good; what was missing was the one
# field that says which tool it is a spec FOR. "no tool called ''" is true and
# useless. A refusal earns its place by naming what to fix.
func _defect_1_missing_tool() -> void:
	# The prompt now says the field is required, in the EQUIP line itself, so
	# the AI is told before it is refused.
	var prompt: String = AIInterpreter.SYSTEM_PROMPT
	var equip_line := ""
	for line in prompt.split("\n"):
		if str(line).begins_with("EQUIP - "):
			equip_line = str(line)
	_check(equip_line != "", "the prompt still has an EQUIP line")
	_check(equip_line.contains("\"tool\""), "the EQUIP line names the tool field as required")

	# The two faults are two messages. This asserts the wording a player sees,
	# which is the whole of the fix: the controller's branch is exercised by
	# the strings it builds from ToolRegistry.names().
	var kinds := ", ".join(ToolRegistry.names())
	_check(kinds.contains("boots") and kinds.contains("look"),
		"the refusal can still list the tools: %s" % kinds)
	_check(ToolRegistry.find("") == null, "an empty tool name finds nothing")
	_check(ToolRegistry.find("hoverboard") == null, "an invented tool name finds nothing")
	_check(ToolRegistry.find("boots") != null, "a real tool name still finds its tool")
