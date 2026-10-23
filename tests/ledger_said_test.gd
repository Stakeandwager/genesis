extends SceneTree

# --- 033: does every command the whitelist admits LEAVE A RECORD? ---
#
# 031 asked whether every field of a readback says something. 032 asked the
# same question one layer up, of every command the whitelist admits, and
# found two with no readback at all. This asks the next question off the same
# authoritative list, and it is a different question: not what Genesis SAYS
# about a request, but whether the request is in the ledger afterwards.
#
# The ledger is the thing this project is for. A request that was accepted,
# acted on, and left no record is a hole in the one artefact that is supposed
# to be auditable without trusting the process that wrote it - and the hole
# is invisible from inside, because the player still sees a line in the log.
#
# FOUR OF ELEVEN wrote no record when the question was first asked:
# MODIFY_TRACK, SPAWN_OPPONENTS, CREATE_TRACK without a sections list, and
# CLEAR_WORLD. Worse, each one still produced an UNDERSTANDING record
# pointing back at the id the request had been given, so the ledger carried
# a reference to a record that was never written.
#
# WHAT THIS ASSERTS, AND WHAT IT DOES NOT (TRAPS 6)
#
# FINDING. Every command in CommandParser.allowed_commands() leaves at least
# one record carrying the id its request was given, and every "about" in an
# understanding record names an id some record carries. Both fail against the
# pre-033 code - four commands and four dangling references.
#
# GUARD. The table below is keyed on the whitelist itself. A command added
# later with no row here is a FAILURE and never a skip, so the suite cannot
# go quietly stale the way the readback suites could before 031.
#
# NOT ASSERTED, deliberately: no wording anywhere. What a record SAYS about a
# command is stub_claims_test's and plan_said_test's subject. This asserts
# that the record exists and that its id ties the ledger together, so every
# sentence in Genesis can be rewritten without touching this file.
#
# ALSO NOT ASSERTED: that ids are unique. They are not, and that is measured
# rather than assumed - a plan's own record and the records of its steps all
# carry the plan's id, because _prepare_world reuses current_record_id. That
# is recorded in HANDOVER as an observation; this suite checks that an id
# RESOLVES, which is the property the understanding layer actually needs.

var main: Node3D
var lines: Array = []
var failures: Array = []
var asserted := 0

const ROOMS := "{\"name\": \"entrance\", \"width\": 12, \"depth\": 12}, {\"name\": \"store\", \"width\": 12, \"depth\": 12}, {\"name\": \"vault\", \"width\": 12, \"depth\": 12}"

# A closed circuit: four 90 deg corners make the +360 the solver demands.
const SECTIONS := "{\"type\": \"straight\", \"length\": 200}, {\"type\": \"corner\", \"radius\": 60, \"angle\": 90}, {\"type\": \"straight\", \"length\": 200}, {\"type\": \"corner\", \"radius\": 60, \"angle\": 90}, {\"type\": \"straight\", \"length\": 200}, {\"type\": \"corner\", \"radius\": 60, \"angle\": 90}, {\"type\": \"straight\", \"length\": 200}, {\"type\": \"corner\", \"radius\": 60, \"angle\": 90}"


# One accepted request per command. Written as the AI would send it, so what
# is measured is the path a player's sentence actually takes.
func _requests() -> Dictionary:
	return {
		"CREATE_DUNGEON": '{"command": "CREATE_DUNGEON", "parameters": {"rooms": [%s], "doors": [[1, 2], [2, 3]], "things": [{"name": "key", "in": 2}]}}' % ROOMS,
		"CREATE_FARM": '{"command": "CREATE_FARM", "parameters": {"zones": [{"type": "barn", "width": 20, "depth": 20}]}}',
		"CREATE_TRACK": '{"command": "CREATE_TRACK", "parameters": {"sections": [%s], "target_turn": 360.0}}' % SECTIONS,
		"PLAN": '{"command": "PLAN", "parameters": {"steps": [{"command": "CREATE_FARM", "parameters": {"zones": [{"type": "barn", "width": 20, "depth": 20}]}}]}}',
		"EQUIP": '{"command": "EQUIP", "parameters": {"tool": "boots", "spec": {"push": 300.0, "colour": "red"}}}',
		"ORDER": '{"command": "ORDER", "parameters": {"goal": "go_to", "room": "vault"}}',
		"SHUT": '{"command": "SHUT", "parameters": {"between": ["entrance", "store"]}}',
		"OPEN": '{"command": "OPEN", "parameters": {"between": ["entrance", "store"]}}',
		"MODIFY_TRACK": '{"command": "MODIFY_TRACK", "parameters": {"corner": 2, "difficulty": "hard"}}',
		"SPAWN_OPPONENTS": '{"command": "SPAWN_OPPONENTS", "parameters": {"count": 8}}',
		"CLEAR_WORLD": '{"command": "CLEAR_WORLD", "parameters": {}}',
	}


# The order they are sent in. A dungeon first, so ORDER, SHUT and OPEN have
# somewhere to act; CLEAR_WORLD last, so it does not take it away again.
const ORDERED := ["CREATE_DUNGEON", "ORDER", "SHUT", "OPEN", "EQUIP",
	"CREATE_FARM", "CREATE_TRACK", "PLAN", "MODIFY_TRACK", "SPAWN_OPPONENTS",
	"CLEAR_WORLD"]


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


func _run() -> void:
	_make_main()
	await process_frame

	var whitelist: Array = CommandParser.allowed_commands()
	var table := _requests()
	var start := _written().size()

	# Every command on the list has a request here. A new command with no row
	# fails the suite rather than passing unexamined.
	for command in whitelist:
		_check(table.has(command), "there is a request for %s" % command)
	for command in table:
		_check(whitelist.has(command),
			"%s is still on the whitelist (a row for a command that has gone)" % command)
	# And the running order covers the list, so none is silently left unsent.
	for command in whitelist:
		_check(ORDERED.has(command), "%s is actually sent" % command)

	# --- the finding: one record per accepted command, under its own id ---
	var ids_sent := {}
	for command in ORDERED:
		if not table.has(command):
			continue
		await _type(table[command])
		var id := str(main.controller.current_record_id)
		ids_sent[command] = id
		var found := 0
		for r in _written():
			if str((r as Dictionary).get("id", "")) == id:
				found += 1
		_check(found >= 1, "%s left a record in the ledger under the id its request was given" % command)

	# --- the fourth path, which is the same command with other parameters ---
	# CREATE_TRACK without a "sections" list routes to Prototype 001's ring
	# instead of the racing module, and it is the one of these four a player
	# reaches by typing "make me a race track". It is not a separate entry on
	# the whitelist, so it cannot come out of the enumeration above and is
	# sent by hand - with a comment, so a later reader knows why one row is
	# written out and the rest are not.
	await _type('{"command": "CREATE_TRACK", "parameters": {"corners": 4}}')
	var ring_id := str(main.controller.current_record_id)
	var ring := 0
	for r in _written():
		if str((r as Dictionary).get("id", "")) == ring_id:
			ring += 1
	_check(ring >= 1, "a sectionless CREATE_TRACK (the Prototype 001 ring) left a record too")

	# A request has to settle before the next one judges it, and ORDER is the
	# one command that does not finish inside its own frame.
	var ticks := 0
	while ticks < Engine.physics_ticks_per_second * 5 and main.npc != null and main.npc.state == Npc.GOING:
		ticks += 1
		await physics_frame

	# --- the finding's other half: every "about" resolves ---
	var written := _written()
	var all_ids := {}
	for r in written:
		all_ids[str((r as Dictionary).get("id", ""))] = true
	var abouts := 0
	var dangling: Array = []
	for i in range(start, written.size()):
		var r: Dictionary = written[i]
		if str(r.get("type", "")) != "understanding":
			continue
		abouts += 1
		var about := str(r.get("about", ""))
		if not all_ids.has(about):
			dangling.append(about)
	_check(abouts >= 1, "the understanding layer wrote something to check (%d records)" % abouts)
	_check(dangling.is_empty(),
		"every understanding record names an id the ledger carries (dangling: %s)" % str(dangling))

	# --- and no record claims a construction it did not do ---
	# The tie, not the wording: a record whose reasons say nothing was built
	# must not also say BUILT. stub_claims_test asserts the same rule about
	# the player's line; this asserts it about the record beside it.
	var lied: Array = []
	for i in range(start, written.size()):
		var r: Dictionary = written[i]
		if str(r.get("construction", "")) != "BUILT":
			continue
		for reason in (r.get("reasons", []) as Array):
			if str(reason).contains("built nothing") or str(reason).contains("changed nothing"):
				lied.append(str(r.get("command", "")))
	_check(lied.is_empty(), "no record says BUILT beside a reason saying nothing was built (%s)" % str(lied))

	_finish()


func _finish() -> void:
	for line in lines:
		print(line)
	print("LEDGER SAID %d assertions, failures=%d" % [asserted, failures.size()])
	for f in failures:
		print("  - " + f)
	quit(1 if failures.size() > 0 else 0)
