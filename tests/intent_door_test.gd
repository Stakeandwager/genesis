extends SceneTree

# --- 037: is every field the prompt offers read where it is sent? ---
#
# HANDOVER named the next assistant task as 036's `offset` finding asked of
# every field rather than of the one it was found at: for every field any
# handler or builder reads out of the AI's parameters, is it named in the
# assembled prompt, and is it checked by something?
#
# Asked in BOTH directions, because the cheap half is the one that found
# something. 036's `offset` is a field the code READS that the prompt never
# offers. The reverse is a field the PROMPT OFFERS that the code never reads,
# and that is strictly worse: the model is instructed to send it, so it
# arrives on real requests and goes in the bin. Measured against the
# assembled prompt, SIX of its JSON skeletons carry "intent": three worlds
# and all three tools. Three read it. The three EQUIP skeletons did not -
# not in game_controller._equip, not in ToolRegistry, not in CarTool,
# BootsTool or LookTool.
#
# WHAT THAT COST, measured headless and not inferred:
#   - No EQUIP record in the ledger carried an "intent" key AT ALL, so the
#     style a player described for a tool was absent from the one artefact
#     this project exists to keep.
#   - main._on_track_measured reads record["intent"]["style"] for the
#     "REQUESTED" line the player sees. Every EQUIP ever made showed
#     "REQUESTED: not stated". A farm carrying the identical field showed
#     "smallholding".
#   - An "intent" that was a string, a list, a number or null was accepted in
#     silence, while the other five doors refused it and named the field.
#
# WHAT THIS ASSERTS, AND WHAT IT DOES NOT (TRAPS 6)
#
# FINDING, and it is the one that catches the fault rather than its wording:
# for every command whose skeleton in AIInterpreter.assembled_prompt() offers
# "intent", a request carrying {"style": LABEL} leaves a record whose
# intent.style IS that label. Against the pre-037 code this fails three
# times, once per tool, because the key is not there at all.
#
# FINDING. The same six doors refuse an intent that is not an object, and the
# refusal NAMES THE FIELD. The field name, never the sentence: every refusal
# in Genesis may be rewritten without touching this file.
#
# FINDING. An absent intent is still accepted by all six. The fix above is a
# field being read, not a field becoming required, and a suite that did not
# say so could be satisfied by making every request carry one.
#
# FINDING. Readback.intent_problem() and intent_of() are the one place the
# question is asked, exercised directly over every JSON type a model can
# write where an object belongs.
#
# GUARD. The doors are ENUMERATED from the prompt, by reading its skeletons
# for the field. A world or tool added later whose skeleton offers "intent"
# has no row here and FAILS rather than passing unexamined - which is the
# property that would have caught this in 004, when EQUIP was written.
#
# NOT ASSERTED, deliberately: any wording. Not the refusal's sentence, not
# the example in it, not the "REQUESTED" line's phrasing.
#
# NOT ASSERTED: that a model sends "intent" at all, or that what it puts in
# "style" is any good. No model has sent any request in this file; every one
# was typed by hand, and a headless harness has no key and no model. That
# half is the owner's editor session.

# --- 115: the model's input has TWO parts, and the question above has only
#          ever been asked of one of them ---
#
# This file, prompt_bounds_test, 113 and 114 all ask the same shape of
# question - is what the code does stated where the model can read it? - and
# all four ask it of AIInterpreter.assembled_prompt(). That artefact is the
# SYSTEM instructions. It is not what the model is sent. When a world is
# standing, main.gd:199-204 hands controller.last_build to interpret(), which
# builds a SECOND piece - AIInterpreter._with_world() - and sends it as the
# request. So the model's input is assembled_prompt() PLUS a block naming the
# command the standing world was built from, parameters and all.
#
# WHY THAT MATTERS AND IS NOT BOOKKEEPING. 114's live entry named
# npc_goals.gd:241 - "there is no door between the hall and the vault" - as a
# candidate prompt gap of TRAPS 111's shape, on the reading that the SHUT
# line "nowhere says the pair named must actually be joined". 115 drove it:
# the refusal is real and reachable, for SHUT and for OPEN, by name and by
# number. But it is NOT a gap, because WHICH pairs are joined is a fact about
# the standing world, and the standing world is in the request. A model that
# names a pair the block does not list has ignored something it was told.
#
# AND THE CLASS IS NOT ONE REFUSAL. Enumerated off NpcGoals and
# GameController in 115 under a definition written first - a refusal is a
# STANDING-WORLD refusal when the condition that fires it reads the world
# already standing, rather than only the shape or values of the request; a
# refusal whose condition is request-shape but whose sentence LISTS the
# standing world is not one. The count is FOURTEEN, and what each one reads:
#
#   whether a dungeon is standing   3  the block's "command" carries it
#   the room count and room names   4  the block's "rooms"
#   the thing names, or none        2  the block's "things"
#   the door pairs                  1  the block's "doors"  <- 114's candidate
#   WHICH doors are currently SHUT  2  NOT in the block
#   a node, and a thing's position
#     at this instant               2  in no artefact at all
#
# So TEN of the fourteen rest on facts _with_world() carries, which is why
# the guard below is on the block and not on the door (TRAPS 11). The other
# four are named in HANDOVER's 115 entry rather than guarded here, and none
# of them has TRAPS 111's shape: each is the world's answer to a legal
# request, not a rule the model was never told.
#
# THE SHUT STATE IS DRIVEN AND NOT INFERRED. last_build is written when a
# world is BUILT and _set_door does not touch it, so after a SHUT the
# layout's "shut" list holds the door and the block is byte-identical and
# does not contain the word. Measured in 115; the prompt already tells the
# model that a saved world "comes back as it was BUILT, not as it was LEFT".
#
# WHAT THIS ASSERTS, AND WHAT IT DOES NOT (TRAPS 6)
#
# FINDING, and it is the row that holds the refusal the entry was about: the
# set of room pairs SHUT ACCEPTS is EXACTLY the set of pairs the block names
# as doors. Not a sentence, not a substring - two sets, compared. It fails if
# _with_world stops carrying "doors", if the block's numbering stops being
# the numbering SHUT reads, or if validate_door starts accepting a pair
# nothing joins.
#
# FINDING. Every room name and every thing name the block carries is one an
# ORDER takes, and one it does not carry is refused. Same shape, for the
# other two facts the fourteen refusals rest on.
#
# FINDING. The block is not inside the standing instructions and the
# standing instructions are not inside the block, and the door pairs of the
# standing world appear in neither. That is the two-parts fact itself,
# measured rather than asserted about wording. IF THIS FAILS, somebody has
# moved the standing world into assembled_prompt() - which would be a
# reasonable thing to do - and HANDOVER's 115 entry, TRAPS 113 and this
# header all need rewriting rather than this assertion deleting.
#
# GUARD. Two non-vacuity rows, because the set comparison passes when both
# sets are empty and that is exactly how its first draft passed: the block
# must name at least one door, and the dungeon must have at least one pair of
# rooms with no door between them. Written after the draft passed with both
# sets empty, which is TRAPS 6 caught by a guard rather than by a re-read.
#
# NOT ASSERTED. That a live model reads the block. No request leaves this
# container, there is no key here, and nothing here measures what a model
# does with what it is told. What is measured is what it is told.
#
var main: Node3D
var lines: Array = []
var failures: Array = []
var asserted := 0

const ROOMS := "{\"name\": \"hall\", \"width\": 12, \"depth\": 12}, {\"name\": \"vault\", \"width\": 12, \"depth\": 12}"

# A closed circuit: four 90 deg corners make the +360 the solver demands.
const SECTIONS := "{\"type\": \"straight\", \"length\": 200}, {\"type\": \"corner\", \"radius\": 60, \"angle\": 90}, {\"type\": \"straight\", \"length\": 200}, {\"type\": \"corner\", \"radius\": 60, \"angle\": 90}, {\"type\": \"straight\", \"length\": 200}, {\"type\": \"corner\", \"radius\": 60, \"angle\": 90}, {\"type\": \"straight\", \"length\": 200}, {\"type\": \"corner\", \"radius\": 60, \"angle\": 90}"

# One accepted request per door, with %s where the "intent" field goes, so the
# same body is sent with a sound intent, a broken one and none at all. The
# bodies are written as the AI would send them, so what is measured is the
# path a player's sentence actually takes.
func _bodies() -> Dictionary:
	return {
		"CREATE_FARM": '{"command": "CREATE_FARM", "parameters": {%s"zones": [{"type": "barn", "width": 20, "depth": 20}]}}',
		"CREATE_TRACK": '{"command": "CREATE_TRACK", "parameters": {%s"mode": "circuit", "sections": [' + SECTIONS + ']}}',
		"CREATE_DUNGEON": '{"command": "CREATE_DUNGEON", "parameters": {%s"rooms": [' + ROOMS + '], "doors": [[1, 2]]}}',
		"EQUIP car": '{"command": "EQUIP", "parameters": {%s"tool": "car", "spec": {"grip": 15}}}',
		"EQUIP boots": '{"command": "EQUIP", "parameters": {%s"tool": "boots", "spec": {"push": 300}}}',
		"EQUIP look": '{"command": "EQUIP", "parameters": {%s"tool": "look", "spec": {"skin": "tan"}}}',
	}


# PLAN is written out rather than enumerated, and the comment is the reason:
# it is the one door that reads "intent" WITHOUT the prompt offering it, so it
# cannot come out of a reading of the prompt. 036 made it the fifth door; this
# holds that behaviour so a later tidy cannot drop it on the grounds that no
# skeleton asks for the field. ledger_said_test writes out the sectionless
# CREATE_TRACK for the same kind of reason.
const PLAN_BODY := '{"command": "PLAN", "parameters": {%s"steps": [{"command": "CREATE_FARM", "parameters": {"zones": [{"type": "barn", "width": 20, "depth": 20}]}}]}}'

# Every JSON type a model writes where an object belongs. null is the one it
# writes most: a field it had nothing to say about.
const NOT_OBJECTS := ["\"rally\"", "[1, 2]", "7", "true", "null"]

# 115: a dungeon joined in a LINE, so hall and vault both exist and have no
# door between them. The pair (1, 3) is what makes the set comparison below
# able to fail, and it is the request that drives npc_goals.gd:241.
const STANDING := '{"command": "CREATE_DUNGEON", "parameters": {"rooms": [{"name": "hall", "width": 12, "depth": 12}, {"name": "middle", "width": 12, "depth": 12}, {"name": "vault", "width": 12, "depth": 12}], "doors": [[1, 2], [2, 3]], "things": [{"name": "red_key", "in": "hall"}]}}'


func _check(ok: bool, what: String) -> void:
	asserted += 1
	lines.append(("PASS  " if ok else "FAIL  ") + what)
	if not ok:
		failures.append(what)


func _initialize() -> void:
	_run.call_deferred()


# 061: the scene the game launches, loaded rather than hand-built.
#
# This function used to build a stand-in tree by hand and name each node what
# main.gd's @onready lines ask for, so the fixture SUPPLIED the names the
# suite then proved were there (TRAPS 57). 061 walked both trees and
# enumerated twelve differences between that stand-in and scenes/main.tscn -
# a missing light, environment and TitleLabel, a Ground that was a Node3D
# where the scene has a StaticBody3D, a ground slab a metre lower with
# collision the scene has not got, a camera at a different place and angle,
# an unanchored panel, three unset strings and the child order of six nodes.
# What this suite measures is now measured against the tree the game has.
#
# The scene is resolved through ProjectSettings rather than by path, so no
# suite can end up holding a scene that is no longer the game's; the setting
# itself is asserted in player_door_test.
func _make_main() -> void:
	main = load(str(ProjectSettings.get_setting("application/run/main_scene"))).instantiate()
	get_root().add_child(main)


# Everything written to the log, read back off disk, as an outsider would.
func _written() -> Array:
	var out: Array = []
	var file := FileAccess.open(TrackLog.PATH, FileAccess.READ)
	if file == null:
		return out
	while not file.eof_reached():
		var line := file.get_line().strip_edges()
		if line == "":
			continue
		var json := JSON.new()
		if json.parse(line) == OK and typeof(json.data) == TYPE_DICTIONARY:
			out.append(json.data)
	file.close()
	return out


func _type(text: String) -> void:
	main._handle_request(text)
	await process_frame
	await process_frame


# The record this request left, found by the id the request was given. The
# understanding layer's own record is skipped: it is about the record, not the
# request. ledger_said_test is what asserts there is one at all.
func _record_for(id: String) -> Dictionary:
	for r in _written():
		var rec: Dictionary = r
		if str(rec.get("id", "")) == id and str(rec.get("type", "")) != "understanding":
			return rec
	return {}


# A plan's own record, told from its steps' by the world it names. See the
# comment at the PLAN block below for why an id is not enough here.
func _plan_record(id: String) -> Dictionary:
	for r in _written():
		var rec: Dictionary = r
		if str(rec.get("id", "")) == id and str(rec.get("world", "")) == "plan":
			return rec
	return {}


func _send(body: String, intent_json: String) -> Dictionary:
	var field := "" if intent_json == "" else "\"intent\": %s, " % intent_json
	await _type(body % field)
	return _record_for(str(main.controller.current_record_id))


# --- the enumeration: which doors does the prompt offer this field at? ---
#
# Read off the assembled prompt rather than written out, so this cannot go
# stale against a world or tool added later. A skeleton line is one that
# names a command and its parameters; the tool, where there is one, is in the
# same line, because that is how the prompt distinguishes the three EQUIPs.
func _doors_the_prompt_offers() -> Array:
	var found: Array = []
	for raw_line in AIInterpreter.assembled_prompt().split("\n"):
		var line := str(raw_line)
		if not line.contains("\"command\":") or not line.contains("\"parameters\""):
			continue
		if not line.contains("\"intent\""):
			continue
		var command := _quoted_after(line, "\"command\": ")
		if command == "":
			continue
		var tool := _quoted_after(line, "\"tool\": ")
		found.append(command if tool == "" else "%s %s" % [command, tool])
	return found


# The quoted value straight after a key, or "" if the key is not there. A
# reader rather than a regular expression, because the skeletons also contain
# bare placeholders (STYLE, ROOM) that no quoting rule would survive.
func _quoted_after(line: String, key: String) -> String:
	var at := line.find(key)
	if at < 0:
		return ""
	var rest := line.substr(at + key.length())
	if not rest.begins_with("\""):
		return ""
	var end := rest.find("\"", 1)
	if end < 0:
		return ""
	return rest.substr(1, end - 1)


# 115: the one line of the world block that is a command object, found by
# PARSING rather than by the sentence above it. The block's first "{" is
# inside the quoted request on an earlier line, which is what a read that
# does not depend on wording has to survive - and the first draft of this
# read took that brace and got an empty command.
func _command_in(block: String) -> Variant:
	var json := JSON.new()
	for raw in block.split("\n"):
		var line := str(raw).strip_edges()
		if not line.begins_with("{"):
			continue
		if json.parse(line) != OK:
			continue
		if typeof(json.data) == TYPE_DICTIONARY and (json.data as Dictionary).has("parameters"):
			return json.data
	return null


# Every unordered pair of room numbers, 1 for the first room, which is how
# the prompt's own DOOR line counts them and how SHUT reads "between".
func _every_pair(count: int) -> Array:
	var out: Array = []
	for a in range(1, count + 1):
		for b in range(a + 1, count + 1):
			out.append([a, b])
	return out


# Two pairs name the same door. A pair out of parsed JSON carries floats, so
# both sides are read as whole numbers before they are compared.
func _same_pair(one: Array, two: Array) -> bool:
	if one.size() != 2 or two.size() != 2:
		return false
	var a := int(float(one[0]))
	var b := int(float(one[1]))
	var c := int(float(two[0]))
	var d := int(float(two[1]))
	return (a == c and b == d) or (a == d and b == c)


func _the_standing_world_reaches_the_model() -> void:
	await _type(STANDING)
	var controller = main.controller
	var built: Dictionary = controller.last_build
	_check(not built.is_empty(),
		"a dungeon is standing and the controller kept the command it was built from")

	# The second piece of the model's input, built by the function main.gd
	# hands last_build to. Taken from the interpreter in the scene, not from
	# a stand-in.
	var block: String = main.interpreter._with_world(
		"shut the door between the hall and the vault", built)
	var parsed = _command_in(block)
	_check(typeof(parsed) == TYPE_DICTIONARY,
		"the world the model is sent parses as one JSON command object")
	var told: Dictionary = parsed if typeof(parsed) == TYPE_DICTIONARY else {}
	_check(str(told.get("command", "")) == str(built.get("command", "")),
		"and it names the command the standing world was built from: '%s'" % str(told.get("command", "")))
	_check(told.get("parameters", {}) == built.get("parameters", {}),
		"and carries that command's parameters whole")

	var parameters: Dictionary = told.get("parameters", {})
	var rooms: Array = parameters.get("rooms", [])
	var doors: Array = parameters.get("doors", [])
	var things: Array = parameters.get("things", [])

	# What the world actually is, read off the standing world rather than off
	# the block, so the two sides of every comparison below come from
	# different places.
	var layout: Dictionary = controller.standable.get("layout", {})
	var world_rooms: Array = controller.standable.get("rooms", [])
	var world_things: Array = controller.standable.get("things", [])

	# --- the doors: what the model is told, against what SHUT takes ---
	#
	# The two non-vacuity rows come first. The set comparison below passes
	# when both sets are empty, and that is how this read's first draft
	# passed while the block it was reading was empty.
	_check(doors.size() >= 1,
		"the model is told about at least one door, so the comparison below is not vacuous")
	var pairs := _every_pair(rooms.size())
	var unnamed: Array = []
	for pair in pairs:
		var named := false
		for d in doors:
			if _same_pair(pair as Array, d as Array):
				named = true
		if not named:
			unnamed.append(pair)
	_check(unnamed.size() >= 1,
		"and about at least one pair of its rooms with NO door between them, so the comparison can fail (%s)" % JSON.stringify(unnamed))

	var accepted: Array = []
	for pair in pairs:
		var checked: Dictionary = NpcGoals.validate_door(
			{"between": (pair as Array).duplicate()}, world_rooms, layout)
		if bool(checked.get("ok", false)):
			accepted.append(pair)
	var same := accepted.size() == doors.size()
	for pair in accepted:
		var found := false
		for d in doors:
			if _same_pair(pair as Array, d as Array):
				found = true
		if not found:
			same = false
	_check(same,
		"the pairs SHUT ACCEPTS are exactly the pairs the model was told are doors (accepts %s, told %s)" % [
			JSON.stringify(accepted), JSON.stringify(doors)])

	# And the refusal 114 named as a candidate gap, driven here rather than
	# reasoned about: it fires, and the pair it fires for is one the model
	# was told about.
	# TRAPS 105: the row above says whether there IS such a pair, and this one
	# must not throw reading it when there is not - a suite that asserts a row
	# is missing and then crashes before it can print so has reported nothing.
	if unnamed.is_empty():
		_check(false, "there is no pair with no door to drive the no-door refusal with")
	else:
		var no_door: Dictionary = NpcGoals.validate_door(
			{"between": (unnamed[0] as Array).duplicate()}, world_rooms, layout)
		_check(not bool(no_door.get("ok", false)),
			"a pair the model was NOT told is a door is refused: %s" % str(no_door.get("errors", [])))

	# --- the rooms and the things: the other two facts the class rests on ---
	for r in rooms:
		var label := str((r as Dictionary).get("name", ""))
		var sent: Dictionary = NpcGoals.validate(
			{"goal": "go_to", "room": label}, world_rooms, world_things)
		_check(bool(sent.get("ok", false)),
			"a room the model was told about is a room an ORDER takes: '%s'" % label)
	var invented: Dictionary = NpcGoals.validate(
		{"goal": "go_to", "room": "cellar"}, world_rooms, world_things)
	_check(not bool(invented.get("ok", false)),
		"a room it was NOT told about is refused: %s" % str(invented.get("errors", [])))

	var somewhere := "" if rooms.is_empty() else str((rooms[0] as Dictionary).get("name", ""))
	for t in things:
		var label := str((t as Dictionary).get("name", ""))
		var carry: Dictionary = NpcGoals.validate(
			{"goal": "carry", "thing": label, "room": somewhere}, world_rooms, world_things)
		_check(bool(carry.get("ok", false)),
			"a thing the model was told about is a thing a carry takes: '%s'" % label)
	var absent_thing: Dictionary = NpcGoals.validate(
		{"goal": "carry", "thing": "lantern", "room": somewhere}, world_rooms, world_things)
	_check(not bool(absent_thing.get("ok", false)),
		"a thing it was NOT told about is refused: %s" % str(absent_thing.get("errors", [])))

	# --- two parts, neither inside the other ---
	var instructions := AIInterpreter.assembled_prompt()
	_check(not instructions.contains(block),
		"the standing instructions do NOT contain the world block, so the model's input has two parts")
	_check(not block.contains(instructions),
		"and the block does not contain the instructions either")
	_check(not instructions.contains(JSON.stringify(doors)),
		"WHICH pairs of this dungeon's rooms are joined is in neither instruction nor skeleton, only in the block (%s)" % JSON.stringify(doors))
	# Guarded for the reason the row above it is: an EMPTY parameters object
	# stringifies to "{}", which IS in the instructions, so an unguarded
	# version of this row fails for a reason other than the one it states.
	# Measured against the injection that empties the block (HANDOVER 115).
	if parameters.is_empty():
		_check(false, "the block carries nothing the standing world was built from, so there is nothing to look for")
	else:
		_check(not instructions.contains(JSON.stringify(parameters)),
			"nor is anything else the standing world was built from")


func _run() -> void:
	_make_main()
	await process_frame

	# --- Readback is the one place the question is asked ---
	_check(Readback.intent_problem({}, "x") == "", "an absent intent is nothing to complain about")
	_check(Readback.intent_problem({"intent": {}}, "x") == "", "an empty object is an object")
	_check(Readback.intent_problem({"intent": {"style": "a"}}, "x") == "", "and so is one with a style in it")
	_check(Readback.intent_of({}).is_empty(), "an absent intent reads back as an empty object")
	_check(Readback.intent_of({"intent": {"style": "a"}}).get("style", "") == "a",
		"and an object reads back as itself")
	for bad in [null, "rally", [1, 2], 7, true, 1.5]:
		var said := Readback.intent_problem({"intent": bad}, "lightweight")
		_check(said != "" and said.contains("intent"),
			"%s is refused and the field is named" % JSON.stringify(bad))
		_check(typeof(Readback.intent_of({"intent": bad})) == TYPE_DICTIONARY
			and Readback.intent_of({"intent": bad}).is_empty(),
			"%s reads back for the record as an empty object" % JSON.stringify(bad))
	# The example is rendered, not typed out beside the check, so it parses to
	# the shape the check accepts. 034's rule, applied to this door.
	var json := JSON.new()
	var example := Readback.intent_problem({"intent": "no"}, "lightweight")
	var brace := example.find("{")
	_check(brace >= 0 and json.parse(example.substr(brace)) == OK
		and typeof(json.data) == TYPE_DICTIONARY
		and Readback.intent_problem({"intent": json.data}, "x") == "",
		"the example in the refusal parses to a value the check accepts")

	# --- the enumeration, and the guard on it ---
	var offered := _doors_the_prompt_offers()
	var bodies := _bodies()
	_check(offered.size() >= 6,
		"the prompt offers 'intent' at %d doors (found: %s)" % [offered.size(), str(offered)])
	for door in offered:
		_check(bodies.has(door),
			"there is a request for %s, which the prompt offers 'intent' at" % door)
	for door in bodies:
		_check(offered.has(door),
			"%s still offers 'intent' in the prompt (a row for a door that has gone)" % door)

	# --- the finding, at every door the prompt offers the field at ---
	for door in offered:
		if not bodies.has(door):
			continue
		var body: String = bodies[door]

		# A style the player described, carried through to the ledger.
		var label := "intent_door_%s" % door.replace(" ", "_")
		var good := await _send(body, "{\"style\": \"%s\"}" % label)
		_check(str(good.get("result", "")) == "VALID", "%s: a sound request is accepted" % door)
		var carried = good.get("intent", null)
		_check(typeof(carried) == TYPE_DICTIONARY,
			"%s: the record carries an 'intent' object" % door)
		_check(typeof(carried) == TYPE_DICTIONARY and str((carried as Dictionary).get("style", "")) == label,
			"%s: and the style in it is the one that was asked for" % door)

		# No intent at all is still fine. This is a field being READ, not a
		# field becoming required.
		var absent := await _send(body, "")
		_check(str(absent.get("result", "")) == "VALID",
			"%s: a request with no intent is still accepted" % door)
		_check(typeof(absent.get("intent", null)) == TYPE_DICTIONARY,
			"%s: and its record still carries an object there" % door)

		# Anything that is not an object is refused, and the refusal names the
		# field. The field name, never the sentence.
		for bad in NOT_OBJECTS:
			var refused := await _send(body, bad)
			_check(str(refused.get("result", "")) == "FAILED",
				"%s: intent %s is refused" % [door, bad])
			var named := false
			for reason in (refused.get("reasons", []) as Array):
				if str(reason).contains("intent"):
					named = true
			_check(named, "%s: and the refusal names the field (intent %s)" % [door, bad])

	# --- PLAN, the door that reads the field the prompt does not offer ---
	#
	# The plan's OWN record is picked out by its world, not by its id, and
	# that is a measurement rather than a nicety: a plan's record and the
	# records of each of its steps all carry the SAME id, because
	# _prepare_world reuses current_record_id. Written here the first way, the
	# step's CREATE_FARM record came back instead and the style was missing
	# from it - correctly, since the step was not given one. That shared id is
	# HANDOVER's "Human decision needed" 6 and is the owner's to settle; this
	# suite reads round it and says so.
	var plan_good := await _send(PLAN_BODY, "{\"style\": \"intent_door_plan\"}")
	_check(str(plan_good.get("result", "")) == "VALID", "PLAN: a sound request is accepted")
	var plan_own := _plan_record(str(main.controller.current_record_id))
	_check(str((plan_own.get("intent", {}) as Dictionary).get("style", "")) == "intent_door_plan",
		"PLAN: the plan's own record carries the style it was given")
	for bad in NOT_OBJECTS:
		var plan_bad := await _send(PLAN_BODY, bad)
		var named := false
		for reason in (plan_bad.get("reasons", []) as Array):
			if str(reason).contains("intent"):
				named = true
		_check(str(plan_bad.get("result", "")) == "FAILED" and named,
			"PLAN: intent %s is refused and the field is named" % bad)

	# --- 115: the second half of the model's input ---
	await _the_standing_world_reaches_the_model()

	for line in lines:
		print(line)
	print("INTENT DOOR %d assertions, failures=%d" % [asserted, failures.size()])
	quit(failures.size())
