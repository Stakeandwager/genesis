extends SceneTree

# 036 - does every command the whitelist admits have a VALIDATOR?
#
# WHY THIS SUITE EXISTS
#
# HANDOVER named this as the fourth question off CommandParser's own list,
# after described (032), recorded (033) and reachable-from-the-prompt (033).
# The answer is no, and what "no validator" turned out to MEAN is the finding:
# not a missing function, but four conversions that THROW.
#
# Every number in a request arrives through JSON.parse, and a model writes
# null, {} and [] where a number belongs - 029 established that, and fixed it
# in all five validators. GDScript's int() and float() have no constructor for
# those three: the call does not return 0, it throws, and a throw ABANDONS the
# function and leaves the caller holding the constructor's default. 029 asked
# that question of every field of every VALIDATOR. The commands that have no
# validator are exactly the places nobody asked, and measured headless before
# anything was changed:
#
#   MODIFY_TRACK  "corner": {} / [] / null     NO RECORD AT ALL, and an
#                 (game_controller.gd:1225)    understanding record still
#                                              pointing at its id - 033's
#                                              dangling reference, back
#   CREATE_TRACK  "corners": {} / [] / null    a record whose only reason is
#   (sectionless) (track_builder.gd:26)        THE EMPTY STRING, after the
#                                              world had already been cleared
#   PLAN step     "around": {} / [] / null     the plan refused for the worlds
#                 (world_registry.gd:56)       OVERLAPPING - a sentence about
#                                              geometry, for a field Genesis
#                                              could not read. "around" is in
#                                              the PROMPT: the model is told
#                                              to write it
#   PLAN step     "offset": {"x": null}        the world built and never
#                 (game_controller.gd:914)     positioned, silently
#   SPAWN_OPPONENTS "count": {} / [] / null    unreachable: has_track() is
#                 (game_controller.gd:1246)    always false, so the guard
#                                              above returns first
#
# The safe reading was already in the repository, and in the function directly
# above two of these: TrackBuilder.readback() and OpponentBuilder.readback()
# have read "corner" and "count" through Readback.as_number() since 032, which
# the validators' comments call "the one place in Genesis that answers the
# type question". The handlers two files along typed int() out by hand. That
# is TRAPS 28's shape in a handler rather than in a prompt.
#
# WHAT IS ASSERTED, AND WHY EACH IS A FACT RATHER THAN A FORM OF WORDS
#
#   1. EVERY command on CommandParser.allowed_commands() leaves at least one
#      record under the id its request was given, for EVERY one of six values
#      that are not numbers in EVERY field the table below names. This is
#      033's invariant, asked of malformed requests rather than sound ones -
#      and it is what MODIFY_TRACK failed.
#   2. No reason in any of those records is the empty string, and none is
#      whitespace. A record that exists and says nothing is not a record of
#      anything. This is what the sectionless CREATE_TRACK failed.
#   3. Every "about" in an understanding record names an id some record
#      carries. 033 asserted this for sound requests; a request that throws
#      is how the dangling reference came back.
#   4. Where a command REFUSES for the shape of a field, some reason NAMES
#      THE FIELD - the key, as the AI wrote it. Not the sentence: the field.
#      Every sentence in Genesis may be rewritten without touching this file.
#   5. The sound case still works. Every command's well-formed request still
#      reaches the same category it reached before, read from a table of
#      categories rather than of wording, so a suite that passed by refusing
#      everything would fail here.
#   6. A plan with a GOOD "around" still builds and still says one world is
#      inside another. Assertion 4 would otherwise be satisfiable by
#      refusing every plan that mentions the field.
#   7. 094: EVERY record this run leaves in the ledger whose own category
#      begins with FAILED_ carries at least one sentence that is not blank.
#      Assertion 2 holds only the blank half - it walks the list, so an EMPTY
#      list passes it (TRAPS 75, measured in TRAPS 86) - and this is the other
#      half. The condition is read off the record's own category, so no probe
#      is required to refuse and nothing is written down beside the table. See
#      the long note on _refusals_say_something for the two measurements taken
#      before it was asserted, and for what it does not hold.
#
# THE TABLE IS KEYED ON THE WHITELIST. A command added to CORE_COMMANDS or to
# a world module with no row here FAILS this suite and is never skipped, the
# way ledger_said_test's is - because the fault this suite exists for is a
# command nobody asked the question of.
#
# NOT ASSERTED, deliberately:
#   - No wording, anywhere. See assertion 4.
#   - Not that a bad value is REFUSED. Three of these commands build nothing
#     whatever they are sent, so "refused" is not the right word for them and
#     a suite demanding it would be asserting a design decision. What is
#     demanded is a record, a non-empty reason and a resolvable id.
#     094: assertion 7 does not change that. It asks nothing of a command that
#     answers some other way; it reads the records that DID refuse and holds
#     them to saying so. A command that writes no FAILED_ record is never
#     asked a question by it.
#   - Not that a plan step's "offset" is refused. Measured: it is a WORKING
#     placement-by-coordinate (an offset of 150 moves a world to x = 150),
#     and the prompt says "never give coordinates" and never names it - the
#     one line in the prompt containing the word is a CHICANE's sideways
#     step, which is a different field behind SectionValidator. So no
#     prompted request reaches it, a refusal would be unreachable, and
#     whether the prompt should offer it or the validator refuse it is the
#     owner's (HANDOVER, "Human decision needed" 8). What 036 changed is
#     only that reading it cannot throw.

var main: Node3D
var lines: Array = []
var failures: Array = []
var asserted := 0

# 094: counted as the probes fire, never written down beside them. It is the
# denominator for the sweep at the end: a probe that refuses for the SHAPE of
# the request puts a FAILED_SCHEMA record in the ledger, so the sweep must see
# at least this many refusals. Without it the sweep is an absence assertion
# that is greenest when it reads nothing (TRAPS 75, TRAPS 73).
var schema_refusals := 0

const ROOMS := "{\"name\": \"entrance\", \"width\": 12, \"depth\": 12}, {\"name\": \"store\", \"width\": 12, \"depth\": 12}"
const SECTIONS := "{\"type\": \"straight\", \"length\": 200}, {\"type\": \"corner\", \"radius\": 60, \"angle\": 90}, {\"type\": \"straight\", \"length\": 200}, {\"type\": \"corner\", \"radius\": 60, \"angle\": 90}, {\"type\": \"straight\", \"length\": 200}, {\"type\": \"corner\", \"radius\": 60, \"angle\": 90}, {\"type\": \"straight\", \"length\": 200}, {\"type\": \"corner\", \"radius\": 60, \"angle\": 90}"

# The six values a model writes where a number belongs. 029's list, and the
# reason it is six rather than three: a string and a bool are accepted by
# int() WITHOUT throwing, so they test the check rather than the crash, and
# an empty string is the one a dropped clause produces.
const NOT_NUMBERS := ["null", "{}", "[]", "\"two\"", "true", "\"\""]

# Every command on the whitelist, the numeric fields it reads STRAIGHT FROM
# the AI's parameters without a validator in front, and a request that is
# sound. A command whose parameters all go through a validator has an empty
# field list and is still probed for its sound case.
#
# "probe" is a format string with one %s, where the bad value goes.
func _table() -> Dictionary:
	return {
		"MODIFY_TRACK": {
			"fields": ["corner"],
			"probe": {"corner": '{"command": "MODIFY_TRACK", "parameters": {"corner": %s, "difficulty": "hard"}}'},
			"sound": '{"command": "MODIFY_TRACK", "parameters": {"corner": 2, "difficulty": "hard"}}',
		},
		"SPAWN_OPPONENTS": {
			"fields": ["count"],
			"probe": {"count": '{"command": "SPAWN_OPPONENTS", "parameters": {"count": %s}}'},
			"sound": '{"command": "SPAWN_OPPONENTS", "parameters": {"count": 8}}',
		},
		"PLAN": {
			"fields": ["around"],
			"probe": {"around": '{"command": "PLAN", "parameters": {"steps": [{"command": "CREATE_FARM", "parameters": {"zones": [{"type": "barn", "width": 20, "depth": 20}]}}, {"command": "CREATE_DUNGEON", "around": %s, "parameters": {"rooms": [' + ROOMS + '], "doors": [[1, 2]]}}]}}'},
			"sound": '{"command": "PLAN", "parameters": {"steps": [{"command": "CREATE_FARM", "parameters": {"zones": [{"type": "barn", "width": 20, "depth": 20}]}}]}}',
		},
		"CLEAR_WORLD": {
			"fields": [],
			"probe": {},
			"sound": '{"command": "CLEAR_WORLD", "parameters": {}}',
		},
		"EQUIP": {
			"fields": [],
			"probe": {},
			"sound": '{"command": "EQUIP", "parameters": {"tool": "boots", "spec": {"push": 300.0}}}',
		},
		"ORDER": {
			"fields": [],
			"probe": {},
			"sound": '{"command": "ORDER", "parameters": {"goal": "go_to", "room": "store"}}',
		},
		"SHUT": {
			"fields": [],
			"probe": {},
			"sound": '{"command": "SHUT", "parameters": {"between": ["entrance", "store"]}}',
		},
		"OPEN": {
			"fields": [],
			"probe": {},
			"sound": '{"command": "OPEN", "parameters": {"between": ["entrance", "store"]}}',
		},
		"CREATE_FARM": {
			"fields": [],
			"probe": {},
			"sound": '{"command": "CREATE_FARM", "parameters": {"zones": [{"type": "barn", "width": 20, "depth": 20}]}}',
		},
		"CREATE_DUNGEON": {
			"fields": [],
			"probe": {},
			"sound": '{"command": "CREATE_DUNGEON", "parameters": {"rooms": [' + ROOMS + '], "doors": [[1, 2]]}}',
		},
		"CREATE_TRACK": {
			"fields": [],
			"probe": {},
			"sound": '{"command": "CREATE_TRACK", "parameters": {"sections": [' + SECTIONS + '], "target_turn": 360.0}}',
		},
	}


# The sectionless CREATE_TRACK is not a separate entry on the whitelist - it
# is the same command routed by the ABSENCE of a sections list - so it cannot
# come out of the enumeration and is written out here, with this comment, the
# way ledger_said_test writes out its one hand-sent row.
func _ring_probe() -> String:
	return '{"command": "CREATE_TRACK", "parameters": {"corners": %s}}'


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


func _type(text: String) -> void:
	main._handle_request(text)
	await process_frame
	await process_frame


# Everything written to the log, read off disk, as an outsider would.
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


# Send a request and return every record written under the id it was given.
func _send(json_text: String) -> Array:
	await _type(json_text)
	var id := str(main.controller.current_record_id)
	var mine: Array = []
	for r in _written():
		if str((r as Dictionary).get("id", "")) == id:
			mine.append(r)
	return mine


# Assertions 1, 2 and 4, for one malformed request.
func _probe(label: String, json_text: String, field: String) -> void:
	var records: Array = await _send(json_text)

	# 1. A record exists.
	_check(not records.is_empty(), "%s left a record" % label)
	if records.is_empty():
		return

	# 2. No reason is empty or whitespace.
	var empty_reason := false
	var schema_refusal := false
	var names_field := false
	for r in records:
		var d: Dictionary = r
		var reasons = d.get("reasons", [])
		if typeof(reasons) != TYPE_ARRAY:
			continue
		for reason in (reasons as Array):
			if str(reason).strip_edges() == "":
				empty_reason = true
			if str(reason).contains(field):
				names_field = true
		if str(d.get("category", "")) == "FAILED_SCHEMA":
			schema_refusal = true
	_check(not empty_reason, "%s gave a reason that is not the empty string" % label)

	# 4. If it refused for the SHAPE of the request, it named the field.
	#    A command that answers some other way (it builds nothing whatever it
	#    is sent) is not required to refuse - see the header.
	if schema_refusal:
		schema_refusals += 1
		_check(names_field, "%s named '%s' in its refusal" % [label, field])


# Assertion 3, over the records written during THIS run.
#
# Scoped on purpose. TrackLog is a file in user:// that survives between
# runs, so the whole log carries records from earlier runs of other suites -
# and, while 036 was being measured, the dangling ids the pre-fix code
# actually produced. A suite that read the whole file would report a fault
# from a previous process as a fault in this one, which is the opposite of
# what it is for.
func _ids_resolve(from: int) -> void:
	var all := _written()
	var written: Array = all.slice(mini(from, all.size()))
	# An "about" may legitimately point at a record written before this run
	# began, so the ids that COUNT as carried are read from the whole file;
	# only the references being checked are scoped to this run.
	var carried := {}
	for r in all:
		var d: Dictionary = r
		if d.has("id"):
			carried[str(d["id"])] = true
	var dangling: Array = []
	for r in written:
		var d: Dictionary = r
		var about := str(d.get("about", ""))
		if about == "":
			continue
		if not carried.has(about):
			dangling.append(about)
	_check(dangling.is_empty(),
		"every understanding record names an id some record carries (dangling: %s)" % [dangling])


# --- 094: assertion 7, the half of "a refusal names what was wrong" that this
#          file did not hold ---
#
# WHAT WAS WRONG WITH ASSERTION 2, MEASURED RATHER THAN REASONED. Assertion 2
# walks each record's reasons and asserts that none of them is the empty
# string. An empty LIST has no elements, so the loop body never runs and the
# check passes - TRAPS 75's shape inside an assertion, where zero is read as a
# pass. 089 measured it and left it: with _finish_nothing writing
# reasons = [], seven of the controller's refusals tell a player nothing at
# all and this suite is 149 assertions, failures=0, while the same file
# catches reasons = [""] with 12 failures. So "a blank sentence" was held here
# and "no sentence" was not, and the half that was missing is the one a player
# meets as a refusal with nothing under it. The table is in TRAPS 86.
#
# WHY IT WAS NOT CLOSED IN 089 OR 090, AND WHAT DISSOLVED IT. This file cannot
# demand that every probe REFUSE: three of these commands build nothing
# whatever they are sent, which this suite's own header says, so a bare
# non-empty assertion per probe would be a false alarm on correct code. 090
# read the thing that answers it: the condition does not have to be "which
# probes must refuse", it can be read off THE RECORD'S OWN CATEGORY. A record
# whose category begins with FAILED_ has refused, by its own report, and a
# refusal carrying no sentence is the fault. A command that answers some other
# way never writes such a record and is never asked. Nothing is written down
# beside the probes, which is what keeps this off TRAPS 82's shape.
#
# AND IT WAS MEASURED BEFORE IT WAS ASSERTED (TRAPS 6), because an invariant
# asserted on the strength of an argument is a guard over an assumption. Two
# measurements, both in 094:
#
#   THE LEDGER. All 74 suites were run one at a time with the lines each one
#   appended to user://track_log.jsonl captured per suite: 671 records, 146 of
#   them FAILED_, across eight distinct FAILED_ categories, and ZERO carrying
#   no sentence. 36 of those 146 are this suite's own run, which is where the
#   count below comes from.
#
#   THE PRODUCERS. All 37 "ok": false returns in scripts/ were read. Every one
#   either carries a literal non-empty array, is guarded by
#   `if not <list>.is_empty()`, or derives `ok` from `<list>.is_empty()` - so
#   no validator in Genesis can answer ok=false with nothing to say today. The
#   four `{"ok": false}` returns in _prepare_world carry no reasons key at all
#   and are internal signals, after _finish_failed has already written the
#   record. So this assertion is a guard against DRIFT and not a fault-finder,
#   and saying otherwise would be a claim this session cannot make.
#
# WHAT IT DOES NOT HOLD, said rather than left to be found:
#   - It reads the LEDGER. Eight of the sixteen FAILED_ categories in scripts/
#     reached no record in any of the 74 suites - the world modules' own
#     refusals are returned as dictionaries from pre_check, solve and
#     post_check, and refusal_reach_test holds those twelve branches directly
#     (091). This sweep says nothing about them and no machinery was copied
#     here to pretend otherwise.
#   - "It says something" is not "it says the right thing". The sentence is
#     not read for its content; assertion 4 does that for the field name, and
#     every wording check in this project lives elsewhere on purpose.
#   - The per-record count is DERIVED from the run, so it falls if the probes
#     stop refusing. That is exactly TRAPS 73's signature, and it is why the
#     denominator assertion below exists: schema_refusals is counted as the
#     probes fire, so a sweep that reads less than the probes produced is red.
#   - AND THE SWEEP IS ONLY AS WIDE AS THE REQUESTS THIS SUITE SENDS, which is
#     the limit worth knowing and was found by injecting against it rather
#     than reasoned. ORDER, SHUT, OPEN, EQUIP, CLEAR_WORLD and the three
#     CREATE_ commands all carry "fields": [] in the table, so this suite
#     sends them only SOUND requests and their validators' refusal paths are
#     never driven here at all. Measured: NpcGoals.validate made to answer
#     ok=false with errors = [] leaves this suite at 186 assertions,
#     failures=0 - SILENT - while controller_reach_test, which drives those
#     branches, is 305 assertions, failures=4. So the class is held across
#     three files and this file's share is the malformed-FIELD class per
#     whitelisted command. TRAPS 47's reachability question, asked of a sweep
#     instead of a check. TRAPS 91.
func _refusals_say_something(from: int) -> void:
	var all := _written()
	var written: Array = all.slice(mini(from, all.size()))
	var swept := 0
	for r in written:
		var d: Dictionary = r
		var category := str(d.get("category", ""))
		if not category.begins_with("FAILED_"):
			continue
		swept += 1
		_check(_says_something(d.get("reasons", [])),
			"the %s refusal of %s says something (reasons: %s)" % [
				category, str(d.get("command", "(no command)")),
				JSON.stringify(d.get("reasons", []))])
	# The tie. Both numbers are counted as they happen - one as the probes
	# fire, one as the records are read - so nothing has to be edited when a
	# probe is legitimately added or removed, and a sweep that reads nothing
	# cannot pass.
	_check(swept >= schema_refusals,
		"the sweep read every refusal the probes drew (%d refusals swept, %d probes refused for the shape)" % [
			swept, schema_refusals])


# 094: byte-identical to 089's predicate in controller_reach_test and 091's in
# refusal_reach_test, and deliberately so. There is no shared library in
# tests/ - every suite stands alone, which is this project's convention and the
# reason source_scan_test holds _code_of() at file granularity rather than by
# one implementation everybody calls. The property has two halves, which is the
# whole point of it: there IS a sentence, and it is not blank.
static func _says_something(reasons: Variant) -> bool:
	if typeof(reasons) != TYPE_ARRAY or (reasons as Array).is_empty():
		return false
	for reason in (reasons as Array):
		if str(reason).strip_edges() == "":
			return false
	return true


func _run() -> void:
	_make_main()
	await process_frame

	var whitelist: Array = CommandParser.allowed_commands()
	var table := _table()
	var log_mark: int = _written().size()

	# --- the table is keyed on the whitelist, both ways ---
	for command in whitelist:
		_check(table.has(command), "there is a row for %s" % command)
	for command in table:
		_check(whitelist.has(command),
			"%s is still on the whitelist (a row for a command that has gone)" % command)

	# A dungeon first, so ORDER, SHUT and OPEN have somewhere to act.
	await _type('{"command": "CREATE_DUNGEON", "parameters": {"rooms": [%s], "doors": [[1, 2]]}}' % ROOMS)

	# --- assertion 5: every sound request still reaches the same category ---
	# Read from the code's own answer rather than from a remembered string:
	# what is asserted is that a well-formed request is NOT refused for its
	# SHAPE. A command that fails for the scene it is in (no Prototype 001
	# ring to change) is not a schema failure and never was.
	for command in whitelist:
		# 105: GUARDED, and the guard is the point rather than a tidy.
		# `table.has(command)` is asserted twenty lines up, and an assertion
		# in this suite RECORDS a failure and falls through - it does not
		# stop the run. So a command on the whitelist with no row here used
		# to arrive at `table[command]`, which THROWS, and a script error in
		# a SceneTree abandons _initialize before quit(): the process ran
		# until run_tests.sh's 600-second timeout killed it and NONE of the
		# rows this suite had already found were ever printed. Measured, not
		# reasoned - see HANDOVER 105.
		if not table.has(command):
			continue
		var row: Dictionary = table[command]
		# A dungeon before each one, so no command is judged in the world the
		# PREVIOUS command left. CLEAR_WORLD comes before ORDER on the
		# whitelist, and without this ORDER's sound request is refused for
		# having nobody to order about - a true sentence about the wrong
		# thing, and the suite would have been reporting its own running
		# order as a fault in the code.
		await _type('{"command": "CREATE_DUNGEON", "parameters": {"rooms": [%s], "doors": [[1, 2]]}}' % ROOMS)
		var records: Array = await _send(str(row["sound"]))
		_check(not records.is_empty(), "the sound %s left a record" % command)
		var schema_failed := false
		for r in records:
			if str((r as Dictionary).get("category", "")) == "FAILED_SCHEMA":
				schema_failed = true
		_check(not schema_failed, "the sound %s is not refused for its shape" % command)

	# The dungeon went with CLEAR_WORLD above; put it back for the probes.
	await _type('{"command": "CREATE_DUNGEON", "parameters": {"rooms": [%s], "doors": [[1, 2]]}}' % ROOMS)

	# --- assertions 1, 2 and 4: every unvalidated field, every non-number ---
	var driven: Array = []
	for command in whitelist:
		# 105: the same guard, for the same reason, at the second of the two
		# index reads. Fixing only the first would be the instance and not
		# the class (TRAPS 11): either one throws on its own.
		if not table.has(command):
			continue
		driven.append(command)
		var row: Dictionary = table[command]
		var probes: Dictionary = row["probe"]
		for field in probes:
			for bad in NOT_NUMBERS:
				var text: String = str(probes[field]) % bad
				await _probe("%s with '%s' = %s" % [command, field, bad], text, str(field))

	# 105: THE FLOOR UNDER THE TWO GUARDS ABOVE, and it is here because a
	# `continue` is how coverage goes missing quietly (TRAPS 6, and 078's
	# floor on the stray-template scan). The guards stop a missing row from
	# THROWING; nothing in them stops the probe loop from running over fewer
	# commands than the whitelist holds while every assertion that did run
	# passed. The gate twenty lines up names each missing command, and this
	# says in one line how wide the sweep actually was - so a reader of the
	# result never has to infer the breadth from an absence of failures.
	_check(driven.size() == whitelist.size(),
		"every command the whitelist admits was probed (%d of %d; not probed: %s)" % [
			driven.size(), whitelist.size(),
			str(whitelist.filter(func(c): return not driven.has(c)))])

	# --- "around" specifically: refused for its SHAPE, naming the field ---
	#
	# The three assertions above are deliberately weak about HOW a command
	# answers, because three of these commands build nothing whatever they
	# are sent. "around" is the exception and the reason is measured: its
	# value CHANGES WHAT GENESIS DOES, and before 036 a value Genesis could
	# not read was silently taken as 0, both worlds were placed at the
	# origin, and the plan came back refused for the worlds OVERLAPPING -
	# FAILED_SCENE, a true sentence about geometry for a request whose real
	# fault was a field. A player told their worlds overlap cannot act on it:
	# they asked for one inside the other and Genesis never read which.
	#
	# So this is the one place the suite asserts a category: a field Genesis
	# cannot read is the SHAPE of the request, which is what 029 and 030
	# established for every other numeric field in Genesis. The field name is
	# asserted; the sentence is not.
	for bad in NOT_NUMBERS:
		var plan_text: String = str((table["PLAN"]["probe"] as Dictionary)["around"]) % bad
		var records: Array = await _send(plan_text)
		var shape := false
		var named := false
		for r in records:
			var d: Dictionary = r
			if str(d.get("category", "")) == "FAILED_SCHEMA":
				shape = true
			var reasons = d.get("reasons", [])
			if typeof(reasons) == TYPE_ARRAY:
				for reason in (reasons as Array):
					if str(reason).contains("around"):
						named = true
		_check(shape, "a plan whose 'around' is %s is refused for its shape, not for the scene" % bad)
		_check(named, "and the refusal names 'around' rather than describing the consequence (%s)" % bad)

	# An out-of-range "around" is the same misleading refusal by another
	# route: a forward or self reference was silently not centred and the
	# plan was then refused for overlapping. Measured, not assumed.
	for bad_ref in ["0", "2", "7", "1.5"]:
		var plan_text: String = str((table["PLAN"]["probe"] as Dictionary)["around"]) % bad_ref
		var records: Array = await _send(plan_text)
		var shape := false
		var named := false
		for r in records:
			var d: Dictionary = r
			if str(d.get("category", "")) == "FAILED_SCHEMA":
				shape = true
			var reasons = d.get("reasons", [])
			if typeof(reasons) == TYPE_ARRAY:
				for reason in (reasons as Array):
					if str(reason).contains("around"):
						named = true
		_check(shape, "a plan whose 'around' is %s is refused for its shape" % bad_ref)
		_check(named, "and that refusal names 'around' too (%s)" % bad_ref)

	# The sectionless ring, which is not its own whitelist entry.
	for bad in NOT_NUMBERS:
		await _probe("a sectionless CREATE_TRACK with 'corners' = %s" % bad,
			_ring_probe() % bad, "corners")

	# --- assertion 6: a GOOD "around" still builds, and still says so ---
	# Without this, assertion 4 could be satisfied by refusing every plan
	# that mentions the field.
	var good_plan := '{"command": "PLAN", "parameters": {"steps": [{"command": "CREATE_FARM", "parameters": {"zones": [{"type": "barn", "width": 60, "depth": 60}]}}, {"command": "CREATE_DUNGEON", "around": 1, "parameters": {"rooms": [%s], "doors": [[1, 2]]}}]}}' % ROOMS
	var plan_records: Array = await _send(good_plan)
	var plan_built := false
	for r in plan_records:
		var d: Dictionary = r
		if str(d.get("command", "")) == "PLAN" and str(d.get("construction", "")) == "BUILT":
			plan_built = true
	_check(plan_built, "a plan with a sound 'around' still builds")

	var said := WorldRegistry.readback("PLAN", {"steps": [
		{"command": "CREATE_FARM", "parameters": {"zones": [{"type": "barn", "width": 60, "depth": 60}]}},
		{"command": "CREATE_DUNGEON", "around": 1, "parameters": {
			"rooms": [{"name": "entrance", "width": 12, "depth": 12},
				{"name": "store", "width": 12, "depth": 12}], "doors": [[1, 2]]}},
	]})
	_check(said.contains("one inside the other"),
		"and a plan with a sound 'around' still says one world goes inside the other")

	# --- the one reading: a check that looks where the builder looks ---
	# "around" may be written at the step level or inside parameters and
	# means the same thing either way (003). A check that read one place
	# would pass a step the builder then reads from the other, so both are
	# asserted against the SAME function the placement uses.
	_check(WorldRegistry.around_of({"around": 2}) == 2,
		"around_of reads the step level")
	_check(WorldRegistry.around_of({"parameters": {"around": 2}}) == 2,
		"around_of reads inside parameters")
	for bad_value in [null, {}, [], "two", true]:
		_check(WorldRegistry.around_of({"around": bad_value}) == 0,
			"around_of answers 0 rather than throwing for %s" % [bad_value])
		_check(WorldRegistry.around_problem({"around": bad_value}, 2, 2) != "",
			"around_problem finds fault with %s at the step level" % [bad_value])
		_check(WorldRegistry.around_problem({"parameters": {"around": bad_value}}, 2, 2) != "",
			"around_problem finds fault with %s inside parameters" % [bad_value])
	_check(WorldRegistry.around_problem({}, 2, 2) == "",
		"an absent 'around' is not a fault")
	_check(WorldRegistry.around_problem({"around": 1}, 2, 2) == "",
		"an 'around' naming an earlier step is not a fault")
	_check(WorldRegistry.around_problem({"around": 2}, 2, 2) != "",
		"a step cannot be asked to surround itself")
	_check(WorldRegistry.around_problem({"around": 1}, 1, 2) != "",
		"nothing comes before step 1")
	_check(WorldRegistry.around_problem({"around": 1.5}, 2, 2) != "",
		"a fractional step number is a fault")

	# --- assertion 3, over everything written above ---
	_ids_resolve(log_mark)

	# --- 094: assertion 7, over everything written above ---
	# Same scope and the same mark: every record THIS run put in the ledger,
	# never the whole file, for the reason _ids_resolve gives above.
	_refusals_say_something(log_mark)

	for line in lines:
		print(line)
	print("COMMAND SCHEMA %d assertions, failures=%d" % [asserted, failures.size()])
	for f in failures:
		print("  - " + f)
	quit(failures.size())
