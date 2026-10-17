extends SceneTree

# --- 045: what the record says was PROPOSED ---
#
# HANDOVER named the next assistant task as asking every suite in tests/ what
# IT cannot see, with the four axes 041-044 produced - values, direction,
# input shape, LAYER - and predicted that the readback and the RECORD would be
# the layers nobody had probed, "because they return strings rather than
# verdicts". This is the record, and the prediction holds.
#
# THE RULE: a command's record is part of the command (TRAPS 25). HANDOVER's
# own candidate list said of it: "ledger_said_test enumerates the whitelist,
# so this one may well be whole; worth confirming rather than assuming."
# CONFIRMED, AND IT WAS NOT WHOLE.
#
# WHAT IT COST, measured headless before anything was changed, by sending one
# request per whitelisted command through main._handle_request and reading the
# ledger back off disk:
#
#   CREATE_DUNGEON    proposed_rooms, proposed_doors, proposed_things, attempt
#   CREATE_TRACK      proposed_sections, proposed_metrics, attempt
#   ORDER             proposed_goal
#   SHUT / OPEN       proposed_door
#   EQUIP             proposed_spec
#   MODIFY_TRACK      proposed_change
#   SPAWN_OPPONENTS   proposed_grid
#   CREATE_TRACK (ringless)  proposed_ring
#   CREATE_FARM       (nothing)
#   PLAN              (nothing)
#
# A farm's record carried "world", "intent" and "command" and nothing else,
# accepted or refused. A plan's carried "steps" on the way OUT - the steps it
# DID, a construction-layer field - so a plan refused at step 2 of 3 left an
# entry naming the problem and never the plan.
#
# THE PROPOSAL IS NOT LOST AND THIS SUITE DOES NOT CLAIM IT WAS. "raw_command"
# holds the whole JSON answer for every command, so a farm's zones have always
# been in the ledger as a string. The claim is about SHAPE: an auditor reading
# the ledger BY FIELD met a farm that proposed nothing, which is exactly the
# argument 036 and 037 both made about "intent" (three shapes in one field)
# and the owner accepted. Nothing in the repository reads a "proposed_" field
# except "proposed_metrics", so the cost today falls on a reader of the file
# and not on Genesis - said here rather than dressed up.
#
# WHY NO SUITE SAW IT, WHICH IS THE PART WORTH KEEPING. ledger_said_test asks
# the right question of the right list - every command in
# CommandParser.allowed_commands() leaves a record whose id the ledger
# resolves - and its own header says what it does not ask: "NOT ASSERTED,
# deliberately: no wording anywhere... This asserts that the record EXISTS."
# It is correct, its list is the whole list, and the record's CONTENTS were
# never asked for by anything: grep finds "proposed_" in exactly one test
# before this one, as a fixture in session_test. A fifth blind spot, and it is
# not one of the four axes: 041's was the probe's VALUES, 042's the sweep's
# DIRECTION, 043's the input's SHAPE, 044's the LAYER, and this one is the
# QUESTION - existence asked where content was owed.
#
# AND THE FIX IS THE CLASS, NOT THE TWO DOORS (TRAPS 11). The three
# "proposed_" fields were written out BY HAND in DungeonModule.record_fields()
# and the fourth in RacingModule's, and in neither case in WorldModule, the
# base they both extend - which is why the third world had none. The reading
# is now WorldModule.proposal_record(), off lists(), which is the module's own
# declaration of what a request may carry. So a world added later records its
# proposal without its author writing a line, and that is the half of this
# that is LATENT rather than measured: there is no fourth world yet.
#
# IT ALSO MADE A FALSE COMMENT TRUE. Readback.intent_of() said "what
# WorldModule.record_fields() and RacingModule.record_fields() each did by
# hand... Both readers are now this one." There were THREE readers:
# DungeonModule.record_fields() read "intent" by hand with its own typeof()
# test. Behaviourally identical, so nothing was wrong in front of a player -
# which is how it survived - but the claim was false from the commit that
# wrote it (TRAPS 14, where 043 and 044 each found one). The hand-written
# reader is gone.
#
# WHAT THIS SUITE ASSERTS
#
# 1. THE FINDING, DRIVEN: every command on the whitelist leaves a record
#    carrying its proposal in a "proposed_" field, with the value EQUAL to
#    what the request sent. Keyed on CommandParser.allowed_commands(), so a
#    command added later with no row here FAILS and is never skipped - the
#    guard 033 put in ledger_said_test, which is the suite this one stands
#    beside. CLEAR_WORLD is the single declared exception and is named in the
#    table with its reason, not left out of it.
# 2. THE CLASS, off each world's OWN declaration: for every module in
#    WorldRegistry.modules() and every entry in its lists(), record_fields()
#    carries "proposed_<key>". A world that declares a list and forgets to
#    record it fails here without this file being edited.
# 3. AS SENT, NOT AS RESOLVED. A value the validator would refuse - a 500 m
#    zone, a fractional room, a "zones" that is not a list at all - is in the
#    record exactly as it arrived. A record that cleaned up the request would
#    be evidence of a request nobody made (TRAPS 8, one layer along).
# 4. THE REGRESSION, both directions. Dungeon's and racing's records are
#    unchanged by the move: the key SETS are typed out here as facts rather
#    than read from the function under test, and racing still carries NO
#    "world" key, which is the one thing its override now exists for.
#
# WHAT IT DOES NOT ASSERT, asked in the same breath as writing it
#
# - NO MODEL SENT ANY OF THIS. Every request here was typed by hand; this
#   harness has no API key. That a model ever sends a farm worth auditing is
#   not measured here.
# - IT ASSERTS NOTHING ABOUT "raw_command", which carried this data all along.
#   A suite that proved the zones were "in the ledger" would pass against the
#   pre-045 code and prove nothing (TRAPS 6).
# - "attempt" on a farm record is LATENT. FarmModule has no
#   correction_feedback(), so _may_revise() is false and no farm has ever had
#   a second attempt. It is asserted as present and 1, which is a fact about
#   the shape and not a demonstration that a farm can revise.
# - WHETHER A FIELD IS USEFUL TO A HUMAN READING THE LEDGER is not a thing a
#   test can answer. The owner reads these files; see HANDOVER.
# - The driven half enters through main._handle_request only. The module half
#   calls record_fields() directly. Nothing here runs on Windows or in the
#   editor.

var main: Node3D
var lines: Array = []
var failures: Array = []

const ROOMS := "{\"name\": \"entrance\", \"width\": 12, \"depth\": 12}, {\"name\": \"store\", \"width\": 12, \"depth\": 12}, {\"name\": \"vault\", \"width\": 12, \"depth\": 12}"
const SECTIONS := "{\"type\": \"straight\", \"length\": 200}, {\"type\": \"corner\", \"radius\": 60, \"angle\": 90}, {\"type\": \"straight\", \"length\": 200}, {\"type\": \"corner\", \"radius\": 60, \"angle\": 90}, {\"type\": \"straight\", \"length\": 200}, {\"type\": \"corner\", \"radius\": 60, \"angle\": 90}, {\"type\": \"straight\", \"length\": 200}, {\"type\": \"corner\", \"radius\": 60, \"angle\": 90}"


# One request per whitelisted command, with the field its record must carry
# and the value that field must hold. "" for the field means the command has
# nothing to propose, and the reason is written beside it rather than left to
# be guessed at.
func _rows() -> Dictionary:
	return {
		"CREATE_DUNGEON": {
			"send": '{"command": "CREATE_DUNGEON", "parameters": {"rooms": [%s], "doors": [[1, 2], [2, 3]], "things": [{"name": "key", "in": 2}]}}' % ROOMS,
			"field": "proposed_rooms", "holds": 3,
		},
		"CREATE_FARM": {
			"send": '{"command": "CREATE_FARM", "parameters": {"zones": [{"type": "barn", "width": 20, "depth": 20}]}}',
			"field": "proposed_zones", "holds": 1,
		},
		"CREATE_TRACK": {
			"send": '{"command": "CREATE_TRACK", "parameters": {"sections": [%s], "target_turn": 360.0}}' % SECTIONS,
			"field": "proposed_sections", "holds": 8,
		},
		"PLAN": {
			"send": '{"command": "PLAN", "parameters": {"steps": [{"command": "CREATE_FARM", "parameters": {"zones": [{"type": "barn", "width": 20, "depth": 20}]}}]}}',
			"field": "proposed_steps", "holds": 1,
		},
		"EQUIP": {
			"send": '{"command": "EQUIP", "parameters": {"tool": "boots", "spec": {"push": 300.0, "colour": "red"}}}',
			"field": "proposed_spec", "holds": 2,
		},
		"ORDER": {
			"send": '{"command": "ORDER", "parameters": {"goal": "go_to", "room": "vault"}}',
			"field": "proposed_goal", "holds": 2,
		},
		"SHUT": {
			"send": '{"command": "SHUT", "parameters": {"between": ["entrance", "store"]}}',
			"field": "proposed_door", "holds": 1,
		},
		"OPEN": {
			"send": '{"command": "OPEN", "parameters": {"between": ["entrance", "store"]}}',
			"field": "proposed_door", "holds": 1,
		},
		"MODIFY_TRACK": {
			"send": '{"command": "MODIFY_TRACK", "parameters": {"corner": 2, "difficulty": "hard"}}',
			"field": "proposed_change", "holds": 2,
		},
		"SPAWN_OPPONENTS": {
			"send": '{"command": "SPAWN_OPPONENTS", "parameters": {"count": 8}}',
			"field": "proposed_grid", "holds": 1,
		},
		# The one command with nothing to propose: CLEAR_WORLD takes no
		# fields, so there is no value a record could carry. Declared here so
		# the enumeration below covers the whole whitelist and this exception
		# is a row with a reason rather than a silence.
		"CLEAR_WORLD": {
			"send": '{"command": "CLEAR_WORLD", "parameters": {}}',
			"field": "", "holds": 0,
		},
	}


# A dungeon first, so ORDER, SHUT and OPEN have somewhere to act; CLEAR_WORLD
# last, so it does not take it away again.
const ORDERED := ["CREATE_DUNGEON", "ORDER", "SHUT", "OPEN", "EQUIP",
	"CREATE_FARM", "CREATE_TRACK", "PLAN", "MODIFY_TRACK", "SPAWN_OPPONENTS",
	"CLEAR_WORLD"]


func _check(ok: bool, what: String) -> void:
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


# How many pieces a proposal field holds, whatever shape it is: a list's
# members, an object's keys. The COUNT is the assertion rather than the
# contents, because a record that carried the field and emptied it would pass
# a check for presence alone.
func _size(value: Variant) -> int:
	match typeof(value):
		TYPE_ARRAY:
			return (value as Array).size()
		TYPE_DICTIONARY:
			return (value as Dictionary).size()
	return -1


func _proposal_keys(record: Dictionary) -> Array:
	var out: Array = []
	for key in record.keys():
		if str(key).begins_with("proposed_"):
			out.append(str(key))
	out.sort()
	return out


func _run() -> void:
	_make_main()
	await process_frame

	var whitelist: Array = CommandParser.allowed_commands()
	var rows := _rows()

	# --- the guard: the table is the whitelist, both ways ---
	for command in whitelist:
		_check(rows.has(command), "there is a row for %s" % command)
		_check(ORDERED.has(command), "%s is actually sent" % command)
	for command in rows:
		_check(whitelist.has(command),
			"%s is still on the whitelist (a row for a command that has gone)" % command)

	# --- 1: the finding, driven through a request ---
	for command in ORDERED:
		if not rows.has(command):
			continue
		var row: Dictionary = rows[command]
		var before := _written().size()
		await _type(str(row["send"]))
		var written := _written()
		var found := {}
		for i in range(before, written.size()):
			var r: Dictionary = written[i]
			if str(r.get("type", "")) == "understanding":
				continue
			if str(r.get("command", "")) != command:
				continue
			found = r
			break
		_check(not found.is_empty(), "%s left a record of its own to read" % command)
		if found.is_empty():
			continue
		var field := str(row["field"])
		if field == "":
			_check(_proposal_keys(found).is_empty(),
				"%s proposes nothing and records nothing (has %s)" % [command, str(_proposal_keys(found))])
			continue
		_check(found.has(field),
			"%s records what it was asked for, in %s (has %s)" % [command, field, str(_proposal_keys(found))])
		if found.has(field):
			_check(_size(found[field]) == int(row["holds"]),
				"%s's %s holds the %d it was sent (holds %d)" % [
					command, field, int(row["holds"]), _size(found[field])])

	# --- 2: the class, off every world's own declared lists ---
	# A world that declares a list and does not record it fails here, and a
	# world added later is covered without this file being edited.
	for module in WorldRegistry.modules():
		var world: WorldModule = module
		var fields := world.record_fields({}, {"attempt": 1})
		var declared: Array = world.lists()
		_check(not declared.is_empty(), "%s declares at least one list" % world.command())
		for entry in declared:
			var key := str((entry as Dictionary).get("key", ""))
			_check(fields.has("proposed_%s" % key),
				"%s records proposed_%s, the list it declares" % [world.command(), key])
		_check(int(fields.get("attempt", -1)) == 1,
			"%s records which attempt it is" % world.command())
		_check(not fields.has("revision_of"),
			"%s names no revision when there was none" % world.command())
		var revised := world.record_fields({}, {"attempt": 2, "revision_of": {"time": "x"}})
		_check(int(revised.get("attempt", -1)) == 2 and revised.has("revision_of"),
			"%s carries the attempt and what it revises when it is a revision" % world.command())

	# --- 3: as sent, not as resolved ---
	# The values here are ones a validator REFUSES. A record is what arrived,
	# so a refused design must survive in it exactly as it came.
	var farm := FarmModule.new()
	var huge := farm.record_fields({"zones": [{"type": "barn", "width": 500, "depth": 20}]}, {"attempt": 1})
	_check(_size(huge.get("proposed_zones", null)) == 1
		and float(((huge["proposed_zones"] as Array)[0] as Dictionary).get("width", 0.0)) == 500.0,
		"a zone the validator refuses is in the record at the size it was sent")
	var dungeon := DungeonModule.new()
	var fraction := dungeon.record_fields({"rooms": [], "doors": [], "things": [{"name": "key", "in": 2.9}]}, {"attempt": 1})
	_check(_size(fraction.get("proposed_things", null)) == 1
		and float(((fraction["proposed_things"] as Array)[0] as Dictionary).get("in", 0.0)) == 2.9,
		"a fractional room number is in the record as 2.9 and not as 2")
	# Not a list at all: the shape axis (043). A record of a request that was
	# refused for its SHAPE has to keep the shape it was refused for.
	var wrong_shape := farm.record_fields({"zones": "a barn"}, {"attempt": 1})
	_check(str(wrong_shape.get("proposed_zones", "")) == "a barn",
		"a 'zones' that is not a list is recorded as the string it was")
	# And an absent list is the empty list the two hand-written readers wrote,
	# never a missing key: an auditor reading by field meets one shape.
	var absent := farm.record_fields({}, {"attempt": 1})
	_check(absent.has("proposed_zones") and _size(absent["proposed_zones"]) == 0,
		"an absent list is recorded as an empty list, not as a missing field")

	# --- 4: the regression, both directions ---
	# Typed out here as facts about the records the ledger has carried since
	# 003, not read from the function under test. The move into the base must
	# add a farm's fields and change nothing else.
	var d_keys := dungeon.record_fields(
		{"rooms": [], "doors": [], "things": [], "intent": {"style": "crypt"}}, {"attempt": 1}).keys()
	d_keys.sort()
	_check(str(d_keys) == str(["attempt", "command", "intent", "proposed_doors",
		"proposed_rooms", "proposed_things", "world"]),
		"a dungeon's record carries the same seven fields it always has (%s)" % str(d_keys))
	var racing := RacingModule.new()
	var r_keys := racing.record_fields({"sections": [], "intent": {}}, {"attempt": 1}).keys()
	r_keys.sort()
	_check(str(r_keys) == str(["attempt", "command", "intent", "proposed_sections"]),
		"a circuit's record carries the same four fields it always has (%s)" % str(r_keys))
	# The one thing RacingModule.record_fields() still exists for.
	_check(not racing.record_fields({}, {"attempt": 1}).has("world"),
		"a circuit's record still carries no 'world' field")
	_check(str(racing.record_fields({}, {"attempt": 1}).get("command", "")) == "CREATE_TRACK",
		"a circuit's record still names CREATE_TRACK")
	# The intent reading that was written out by hand in the deleted override.
	for bad in [["a string", "no"], ["a list", []], ["a number", 3]]:
		var said: Dictionary = dungeon.record_fields({"intent": bad[1]}, {"attempt": 1})
		_check(typeof(said.get("intent", null)) == TYPE_DICTIONARY
			and (said["intent"] as Dictionary).is_empty(),
			"a dungeon record meets one shape in 'intent' for %s" % str(bad[0]))

	_finish()


func _finish() -> void:
	for line in lines:
		print(line)
	print("RECORD PROPOSAL failures=%d" % failures.size())
	for f in failures:
		print("  - " + f)
	quit(1 if failures.size() > 0 else 0)
