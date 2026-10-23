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

	for line in lines:
		print(line)
	print("INTENT DOOR %d assertions, failures=%d" % [asserted, failures.size()])
	quit(failures.size())
