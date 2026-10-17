extends SceneTree

# --- 054: the refusals the CONTROLLER returns - which can no legal request
#          reach, and does each of those fire when handed a violation? ---
#
# THE TASK, AND WHERE IT CAME FROM
#
# HANDOVER named this as the next assistant task, and 053 named it twice: the
# two questions it asked of the WORLD MODULES' twelve refusal branches, asked
# of the ones GameController, main.gd and ExperimentRunner return. 053
# enumerated those and declared them NOT_ASKED rather than leaving them to
# look covered, and said they "need a scene tree and a whitelist walk rather
# than a module sweep". They do. This file stands up main.gd, drives real
# requests through it, and reports what came back.
#
# THE TWO QUESTIONS, IN 053's ORDER, BECAUSE THE SECOND IS ONLY INTERESTING
# WHEN THE FIRST SAYS NO:
#
#   (1) can any request a player can send produce it?
#       Measured by sending one, not argued from a reading of the code.
#   (2) handed an input that DOES violate it, does the check fire?
#       The half that tells an unreachable guard apart from a broken one.
#
# THE LIST IS BRANCHES AND NOT NAMES, which is 053's own hardest-won lesson
# and TRAPS 11's rule. 053 found FAILED_LAYOUT returned from three places for
# three different reasons, and said that a table with one row per NAME "would
# have hidden two of them". Seven controller names are twenty-eight branches.
# FAILED_SCHEMA alone is eleven. So every row below is a BRANCH, and the
# enumeration counts call SITES in the source rather than distinct names.
#
# THE ANSWER IS TWENTY-TWO REACHABLE, FIVE GUARDS, ONE THAT NEEDS A KEY, and
# all five guards fire when handed a violation. No dead refusal in the
# controller either. Why each guard is out of reach - the part a sweep alone
# cannot say, because a sweep that missed a shape looks exactly like a bound
# that holds - is a fact about this repository's own lists, asserted as such:
#
#   FAILED_NO_HANDLER        every command CommandParser.allowed_commands()
#   (the execute() _ branch)  admits has either an unguarded case in
#                             execute() or a module in WorldRegistry, so
#                             find() never comes back null. Walked below over
#                             the whitelist and the case list READ OFF the
#                             source, so a twelfth command cannot be admitted
#                             without this suite answering for it.
#   FAILED_SCHEMA            SPAWN_OPPONENTS' "count must be a number". It
#   (SPAWN_OPPONENTS count)   stands AFTER the has_track() guard, and
#                             TrackBuilder.corner_nodes is appended to
#                             nowhere in scripts/ - grepped below, not
#                             remembered - so has_track() is always false and
#                             the guard above returns first. The comment at
#                             that line has said so since 036, and
#                             stub_claims_test has asserted the BUILDER's
#                             half since 032 - corner_nodes empty before and
#                             after a build, has_track() false. What is new
#                             here is the grep across scripts/ rather than
#                             one instance after one build, and question 2.
#   FAILED_NOTHING_BUILT     SPAWN_OPPONENTS' "built nothing". Out of reach
#   (SPAWN_OPPONENTS spawn)   for the SAME reason, four lines further down,
#                             and NOT labelled. See the finding below.
#   FAILED_SCENE             ORDER's "there is nobody to order about here".
#   (ORDER: no module)        It needs WorldRegistry.find(standable.command)
#                             to come back null while rooms exist. Every
#                             module in the registry reports its own
#                             command() in its standable, and NpcGoals
#                             refuses an ORDER with no rooms one step earlier
#                             with FAILED_SCHEMA - measured.
#   FAILED_SCENE             ORDER's "the lamp is not in the world any more".
#   (ORDER: thing gone)       It needs a thing listed in standable.things
#                             whose node is dead. Asserted as the invariant
#                             it guards: over build, SHUT, OPEN, a carry in
#                             progress and a SHUT during one, every thing in
#                             standable.things has a valid node.
#
# AND THE FINDING IS THE ONE THAT WAS NOT LABELLED. FAILED_NOTHING_BUILT's
# own comment in game_controller.gd names "the three Prototype 001 paths" as
# the ones that answer to it. Measured: only TWO of the three can be reached.
# SPAWN_OPPONENTS' is unreachable for exactly the reason the comment four
# lines above its SCHEMA sibling already gives - has_track() is always false
# - and that label was put on one member of the pair and not on the other,
# which is TRAPS 11 at the scale of two adjacent lines. Nothing is wrong on
# any request today: the category still has two live answers. What was wrong
# is that a reader counting live answers from the comment would get three.
#
# AND THE REPOSITORY ALREADY DISAGREED WITH ITSELF ABOUT IT, which is the
# part worth keeping. stub_claims_test has said since 032, in its header,
# that nothing fills corner_nodes and that this is "the reason
# SPAWN_OPPONENTS can never run" - and it asserts it. So one file knew the
# branch was out of reach while another file's comment counted it among
# three live answers, for twenty-two commits, with neither reading the
# other. The label here is not new information; it is the information
# arriving where a reader of that category would meet it.
#
# MEASURED BESIDE IT, AND IT IS WHY TWO BRANCHES LOOKED UNREACHABLE AT FIRST:
# main.gd stands up an UNRECORDED starter circuit at launch
# (controller.show_unrecorded, main.gd:135), and that sets `drivable`. So on
# a fresh session has_drivable() is TRUE before any request, and both
# MODIFY_TRACK and SPAWN_OPPONENTS answer with their composed-track branch.
# Their OTHER branches - MODIFY_TRACK's "corner must be a number" and both
# stubs' "nothing built" - are reachable only after the world has been
# cleared. Reachable, so they are REACHABLE rows; the fixtures below clear
# first and say why. What that means for a player - that the first
# MODIFY_TRACK of a session is refused for a track he never asked for - is a
# sentence about what Genesis says, so it is in HANDOVER under "Human
# decision needed" 2 and not changed here.
#
# WHAT THIS SUITE ASSERTS, AND WHAT IT DOES NOT (TRAPS 6, TRAPS 14)
#
# Nothing here asserts a sentence. A comment saying "unreachable" passes
# against a guard that fires and against one that cannot. What is asserted is
# that a named request produces the category, that a violation handed to a
# guard produces the category, and that the fact putting each guard out of
# reach still holds.
#
# TWO PAIRS SHARE A CATEGORY AND A COMMAND, and this file says so rather than
# claiming more resolution than it has. MODIFY_TRACK has two FAILED_SCENE/
# FAILED_NOTHING_BUILT routes and SPAWN_OPPONENTS has two FAILED_SCENE ones;
# which branch runs is decided by has_drivable() and has_track(), which the
# fixture sets and the code reads. So each fixture asserts the scene state it
# established AND the category that came back. It does not read a line
# number, and it cannot tell two branches apart that the same state selects.
#
# THE ENUMERATION IS MECHANICAL AND FAILS CLOSED, which is 053's pattern. The
# branches are not typed out from a reading of the code: the three controller
# files are read and every refusal CALL SITE is collected with the category
# it names. A site with no row here FAILS, and a row here for a site that no
# longer exists FAILS - so a twenty-ninth branch cannot be added without
# these two questions being asked of it, and this table cannot go stale.
# The three sites that pass a MODULE's category through (_prepare_world's
# pre, solved and post) are counted as PASSTHROUGH and declared, not
# silently dropped: they are refusal_reach_test's twelve branches arriving at
# the controller, and they are that file's to answer for. main.gd's
# record_rejection("UNSUPPORTED") is not a FAILED_ category at all and is
# named here for the same reason.
#
# NOT ANSWERED HERE, AND SAID SO RATHER THAN GUESSED: FAILED_AI. Question 1
# needs a live API key and an API that fails, and this harness has neither;
# nothing below claims it is reachable or that it is not. Question 2 IS
# answered - ExperimentRunner is handed MAX_RETRIES + 1 failures and the
# record is read off the ledger - so the row says exactly that much.

var asserted := 0
var bad := 0
var main: Node3D
var notes: Array = []

const DUNGEON := '{"command": "CREATE_DUNGEON", "parameters": {"rooms": [{"name": "entrance", "width": 12, "depth": 12}, {"name": "store", "width": 12, "depth": 12}, {"name": "vault", "width": 12, "depth": 12}], "doors": [[1, 2], [2, 3]], "things": [{"name": "lamp", "in": 2}]}}'
const CLEAR := '{"command": "CLEAR_WORLD", "parameters": {}}'

# --- the table: one row per BRANCH ---
#
# REACHABLE  a legal request produces it, and there is a named one below.
# GUARD      no legal request produces it, and it fires when violated.
# NEEDS_KEY  question 1 cannot be answered in this harness. Question 2 is.
const BRANCHES := [
	["FAILED_SCHEMA", "ORDER: the goal does not check out", "REACHABLE"],
	["FAILED_SCHEMA", "SHUT/OPEN: the door does not check out", "REACHABLE"],
	["FAILED_SCHEMA", "EQUIP: no tool named, or a tool the game lacks", "REACHABLE"],
	["FAILED_SCHEMA", "EQUIP: the tool's own spec is out of bounds", "REACHABLE"],
	["FAILED_SCHEMA", "PLAN: intent is not an object", "REACHABLE"],
	["FAILED_SCHEMA", "PLAN: steps is not a list", "REACHABLE"],
	["FAILED_SCHEMA", "PLAN: too few or too many steps", "REACHABLE"],
	["FAILED_SCHEMA", "PLAN: a step is not a command this game has", "REACHABLE"],
	["FAILED_SCHEMA", "a world's own validator refused it", "REACHABLE"],
	["FAILED_SCHEMA", "MODIFY_TRACK: corner is not a number", "REACHABLE"],
	["FAILED_SCHEMA", "SPAWN_OPPONENTS: count is not a number", "GUARD"],
	["FAILED_SCENE", "ORDER: no module owns the standable world", "GUARD"],
	["FAILED_SCENE", "ORDER: the thing is not in the world any more", "GUARD"],
	["FAILED_SCENE", "ORDER: the thing stands in no room", "REACHABLE"],
	["FAILED_SCENE", "SHUT/OPEN: there is no dungeon", "REACHABLE"],
	["FAILED_SCENE", "PLAN: a built step, marked failed when the plan was", "REACHABLE"],
	["FAILED_SCENE", "PLAN: the plan's own refusal", "REACHABLE"],
	["FAILED_SCENE", "MODIFY_TRACK: there is a composed track", "REACHABLE"],
	["FAILED_SCENE", "SPAWN_OPPONENTS: there is a composed track", "REACHABLE"],
	["FAILED_SCENE", "SPAWN_OPPONENTS: there is no track at all", "REACHABLE"],
	["FAILED_UNWALKABLE", "ORDER: no way through, carrying", "REACHABLE"],
	["FAILED_UNWALKABLE", "ORDER: no way through, walking", "REACHABLE"],
	["FAILED_NOTHING_BUILT", "MODIFY_TRACK: no Prototype 001 ring to change", "REACHABLE"],
	["FAILED_NOTHING_BUILT", "SPAWN_OPPONENTS: no opponent is placed", "GUARD"],
	["FAILED_NOTHING_BUILT", "CREATE_TRACK: a sectionless ring is not built", "REACHABLE"],
	["FAILED_NO_HANDLER", "execute(): a whitelisted command with no case", "GUARD"],
	["FAILED_PARSE", "main.gd: the answer never became a command", "REACHABLE"],
	["FAILED_AI", "ExperimentRunner: the model failed every retry", "NEEDS_KEY"],
]

# Passed through from a world module's four steps, not decided here. These
# are refusal_reach_test's twelve branches arriving at the controller.
const PASSTHROUGH_SITES := 3
# main.gd's other record_rejection. A refusal, and not a FAILED_ category.
const UNSUPPORTED_SITES := 1

const CONTROLLER_FILES := ["game_controller.gd", "main.gd", "experiment_runner.gd"]
# The two category constants game_controller.gd refuses through by name.
const CATEGORY_CONSTS := {"NOTHING_BUILT": "FAILED_NOTHING_BUILT", "NO_HANDLER": "FAILED_NO_HANDLER"}


func _check(ok: bool, what: String) -> void:
	asserted += 1
	if not ok:
		bad += 1
		print("  FAIL  ", what)


func _initialize() -> void:
	_run.call_deferred()


# --- the harness: the real main.gd, as command_schema_test stands it up ---

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


# Send a request; return every record the ledger gained because of it. Read
# by POSITION rather than by id, because a plan writes several records and
# two of them share an id (HANDOVER, "Human decision needed" 17c) - a suite
# that indexed by id would silently drop one of them.
func _send(json_text: String) -> Array:
	var before := _written().size()
	main._handle_request(json_text)
	await process_frame
	await process_frame
	var all := _written()
	var mine: Array = []
	for i in range(before, all.size()):
		mine.append(all[i])
	return mine


func _categories(records: Array) -> Array:
	var out: Array = []
	for r in records:
		var cat := str((r as Dictionary).get("category", ""))
		if cat != "" and not out.has(cat):
			out.append(cat)
	return out


# One reachable branch: a named request, the state it was sent in, and the
# category that came back. The state is asserted too, because for the two
# pairs that share a category and a command it is the state that selects the
# branch - see the header.
func _reaches(label: String, json_text: String, category: String, command: String) -> void:
	var records: Array = await _send(json_text)
	var found := false
	for r in records:
		var d: Dictionary = r
		if str(d.get("category", "")) == category and str(d.get("command", "")) == command:
			found = true
			_check(str(d.get("result", "")) == "FAILED" or str(d.get("construction", "")) == "FAILED",
				"%s: the record says the request did not succeed" % label)
			break
	_check(found, "%s: a legal request produces %s from %s (got %s)" % [
		label, category, command, str(_categories(records))])


# --- 1. the enumeration, read off the source rather than typed ---

func _refusal_sites() -> Dictionary:
	var found := {}
	var forms := [
		"_finish_failed\\(\\s*record\\s*,\\s*(\"FAILED_[A-Z_]+\"|[A-Z_]+|[a-z_]+\\[\"category\"\\])",
		"_finish_nothing\\(\\s*(?:record|_new_record\\([^)]*\\))\\s*,\\s*(\"FAILED_[A-Z_]+\"|[A-Z_]+)",
		"record_rejection\\(\\s*(\"FAILED_[A-Z_]+\"|\"UNSUPPORTED\")",
		"\\w+\\[\"category\"\\]\\s*=\\s*(\"FAILED_[A-Z_]+\")",
		"\"category\"\\s*:\\s*(\"FAILED_[A-Z_]+\")",
	]
	for name in CONTROLLER_FILES:
		var file := FileAccess.open("res://scripts/" + name, FileAccess.READ)
		if file == null:
			continue
		var text := file.get_as_text()
		file.close()
		for raw_line in text.split("\n"):
			var line := str(raw_line)
			# A commented-out site is not a site. Checked so that the
			# explanatory comments beside these very calls - which quote the
			# category names - are not counted as branches.
			if line.strip_edges().begins_with("#"):
				continue
			for pattern in forms:
				var re := RegEx.create_from_string(pattern)
				for m in re.search_all(line):
					var arg := m.get_string(1).replace("\"", "")
					var cat := str(CATEGORY_CONSTS.get(arg, arg))
					found[cat] = int(found.get(cat, 0)) + 1
	return found


func _enumeration() -> void:
	var sites := _refusal_sites()
	var declared := {}
	for row in BRANCHES:
		var cat := str((row as Array)[0])
		declared[cat] = int(declared.get(cat, 0)) + 1

	_check(BRANCHES.size() == 28, "28 controller refusal branches declared (got %d)" % BRANCHES.size())

	# A site the source has and this table does not.
	for cat in sites:
		var name := str(cat)
		if name.begins_with("FAILED_"):
			_check(declared.has(name),
				"%s is returned by a controller file and has a row here" % name)
		else:
			# Not a FAILED_ category: the two passthroughs and UNSUPPORTED.
			pass
	# A row here for a site the source no longer has.
	for cat in declared:
		_check(sites.has(cat),
			"%s is still returned by a controller file - a row here for one nobody returns is stale" % cat)
	# And the counts, which is the half that catches a branch ADDED to a
	# category that already has rows.
	for cat in declared:
		_check(int(sites.get(cat, 0)) == int(declared[cat]),
			"%s: %d branches in the source, %d rows here" % [
				cat, int(sites.get(cat, 0)), int(declared[cat])])

	var passthrough := 0
	for cat in sites:
		if str(cat).ends_with("[category]"):
			passthrough += int(sites[cat])
	_check(passthrough == PASSTHROUGH_SITES,
		"%d sites pass a module's own category through (expected %d) - those are refusal_reach_test's" % [
			passthrough, PASSTHROUGH_SITES])
	_check(int(sites.get("UNSUPPORTED", 0)) == UNSUPPORTED_SITES,
		"main.gd rejects %d thing as UNSUPPORTED, which is not a FAILED_ category" % int(sites.get("UNSUPPORTED", 0)))

	# The two suites together have to cover every name in scripts/, or a
	# category could sit between them unanswered.
	var module_names := ["FAILED_UNREACHABLE", "FAILED_PLACEMENT", "FAILED_CORRIDOR",
		"FAILED_UNWALKABLE", "FAILED_TOO_BIG", "FAILED_LAYOUT", "FAILED_DEGREES_OF_FREEDOM",
		"FAILED_INFEASIBLE", "FAILED_CLOSURE", "FAILED_SEPARATION"]
	var dir := DirAccess.open("res://scripts")
	var every := {}
	if dir != null:
		for name in dir.get_files():
			if not name.ends_with(".gd"):
				continue
			var f := FileAccess.open("res://scripts/" + name, FileAccess.READ)
			if f == null:
				continue
			var text := f.get_as_text()
			f.close()
			var re := RegEx.create_from_string("FAILED_[A-Z][A-Z_]*")
			for m in re.search_all(text):
				every[m.get_string()] = true
	for name in every:
		var n := str(name)
		_check(declared.has(n) or module_names.has(n),
			"%s is answered for by this suite or by refusal_reach_test" % n)


# --- 2. the reachable branches, each driven through main.gd ---

func _reachable_at_launch() -> void:
	# The starter circuit, before any request. Measured rather than assumed:
	# this is the state a player's first request meets.
	_check(main.controller.has_drivable(),
		"main.gd leaves an unrecorded starter circuit standing, so has_drivable() is true before any request")
	await _reaches("MODIFY_TRACK, composed track standing",
		'{"command": "MODIFY_TRACK", "parameters": {"corner": 1}}',
		"FAILED_SCENE", "MODIFY_TRACK")
	await _reaches("SPAWN_OPPONENTS, composed track standing",
		'{"command": "SPAWN_OPPONENTS", "parameters": {"count": 4}}',
		"FAILED_SCENE", "SPAWN_OPPONENTS")


func _reachable_after_a_clear() -> void:
	await _send(CLEAR)
	_check(not main.controller.has_drivable(),
		"CLEAR_WORLD takes the starter circuit away, so the stubs' own branches are reachable")
	await _reaches("MODIFY_TRACK, corner not a number",
		'{"command": "MODIFY_TRACK", "parameters": {"corner": null}}',
		"FAILED_SCHEMA", "MODIFY_TRACK")
	await _reaches("MODIFY_TRACK, nothing to change",
		'{"command": "MODIFY_TRACK", "parameters": {"corner": 1, "difficulty": "hard"}}',
		"FAILED_NOTHING_BUILT", "MODIFY_TRACK")
	await _reaches("SPAWN_OPPONENTS, no track at all",
		'{"command": "SPAWN_OPPONENTS", "parameters": {"count": 4}}',
		"FAILED_SCENE", "SPAWN_OPPONENTS")
	await _reaches("CREATE_TRACK, sectionless ring",
		'{"command": "CREATE_TRACK", "parameters": {"corners": 4}}',
		"FAILED_NOTHING_BUILT", "CREATE_TRACK")


func _reachable_parse() -> void:
	# Three doors to one branch, all three from the typed door. A model's
	# answer reaches the same line, which this harness has no key to send.
	for probe in [["malformed JSON", '{"command": '],
			["no command field", '{}'],
			["a command the whitelist refuses", '{"command": "FLY", "parameters": {}}']]:
		var records: Array = await _send(str(probe[1]))
		var found := false
		for r in records:
			if str((r as Dictionary).get("category", "")) == "FAILED_PARSE":
				found = true
				_check(str((r as Dictionary).get("command", "")) == "",
					"FAILED_PARSE (%s): the record carries no command, because the answer never became one" % str(probe[0]))
				break
		_check(found, "FAILED_PARSE is reached by %s" % str(probe[0]))


func _reachable_equip_and_plan() -> void:
	await _reaches("EQUIP with no tool named",
		'{"command": "EQUIP", "parameters": {}}', "FAILED_SCHEMA", "EQUIP")
	await _reaches("EQUIP naming a tool the game lacks",
		'{"command": "EQUIP", "parameters": {"tool": "jetpack"}}', "FAILED_SCHEMA", "EQUIP")
	await _reaches("EQUIP with a spec out of bounds",
		'{"command": "EQUIP", "parameters": {"tool": "boots", "spec": {"push": 99999}}}',
		"FAILED_SCHEMA", "EQUIP")
	await _reaches("PLAN with a non-object intent",
		'{"command": "PLAN", "parameters": {"intent": "a string", "steps": [{"command": "CREATE_FARM", "parameters": {"zones": [{"type": "barn", "width": 20, "depth": 20}]}}]}}',
		"FAILED_SCHEMA", "PLAN")
	await _reaches("PLAN whose steps are not a list",
		'{"command": "PLAN", "parameters": {"steps": "x"}}', "FAILED_SCHEMA", "PLAN")
	await _reaches("PLAN with no steps",
		'{"command": "PLAN", "parameters": {"steps": []}}', "FAILED_SCHEMA", "PLAN")
	await _reaches("PLAN naming a command the game lacks",
		'{"command": "PLAN", "parameters": {"steps": [{"command": "NOPE"}]}}',
		"FAILED_SCHEMA", "PLAN")
	await _reaches("a world refused by its own validator",
		'{"command": "CREATE_DUNGEON", "parameters": {"rooms": [{"name": "a", "width": 1, "depth": 1}], "doors": []}}',
		"FAILED_SCHEMA", "CREATE_DUNGEON")
	await _reaches("SHUT with no dungeon",
		'{"command": "SHUT", "parameters": {"between": ["a", "b"]}}', "FAILED_SCENE", "SHUT")


# The plan that fails when its worlds are PLACED, which is the only way to
# reach the two FAILED_SCENE branches at the end of _execute_plan: the steps
# are built and then marked failed. Two worlds with no "around" is the shape
# of the prompt's own PLAN skeleton.
func _reachable_plan_placement() -> void:
	var records: Array = await _send('{"command": "PLAN", "parameters": {"steps": [{"command": "CREATE_DUNGEON", "parameters": {"rooms": [{"name": "a", "width": 12, "depth": 12}, {"name": "b", "width": 12, "depth": 12}], "doors": [[1, 2]]}}, {"command": "CREATE_DUNGEON", "parameters": {"rooms": [{"name": "c", "width": 12, "depth": 12}, {"name": "d", "width": 12, "depth": 12}], "doors": [[1, 2]]}}]}}')
	var step_marked := 0
	var plan_refused := false
	for r in records:
		var d: Dictionary = r
		if str(d.get("category", "")) != "FAILED_SCENE":
			continue
		if str(d.get("command", "")) == "PLAN":
			plan_refused = true
		else:
			# A step whose proposal was valid and whose construction was
			# undone when the plan failed. This is the branch, and the pair
			# of answers under one id is "Human decision needed" 17c.
			if str(d.get("result", "")) == "VALID" and str(d.get("construction", "")) == "FAILED":
				step_marked += 1
	_check(plan_refused, "a plan refused when its worlds are placed returns FAILED_SCENE for the plan")
	_check(step_marked >= 1,
		"and marks each built step FAILED_SCENE with its proposal still valid (got %d)" % step_marked)


func _reachable_order() -> void:
	await _send(CLEAR)
	# With no dungeon at all an ORDER is refused one step EARLIER than the
	# "nobody to order about here" branch, by NpcGoals, as FAILED_SCHEMA.
	# Measured, and it is half of why that branch is a guard.
	await _reaches("ORDER with no dungeon",
		'{"command": "ORDER", "parameters": {"goal": "go_to", "room": 1}}',
		"FAILED_SCHEMA", "ORDER")
	await _send(DUNGEON)
	_check(main.controller.has_standable(), "a dungeon gives the controller somewhere to stand")
	await _reaches("ORDER with no room named",
		'{"command": "ORDER", "parameters": {"goal": "go_to"}}', "FAILED_SCHEMA", "ORDER")
	await _reaches("SHUT naming a room the dungeon lacks",
		'{"command": "SHUT", "parameters": {"between": ["store", "nowhere"]}}',
		"FAILED_SCHEMA", "SHUT")
	# Shut the vault off, then try to reach it on foot and carrying.
	await _send('{"command": "SHUT", "parameters": {"between": ["store", "vault"]}}')
	await _reaches("ORDER walking to a room behind a shut door",
		'{"command": "ORDER", "parameters": {"goal": "go_to", "room": "vault"}}',
		"FAILED_UNWALKABLE", "ORDER")
	await _reaches("ORDER carrying to a room behind a shut door",
		'{"command": "ORDER", "parameters": {"goal": "carry", "thing": "lamp", "room": "vault"}}',
		"FAILED_UNWALKABLE", "ORDER")


# The one branch of the three "thing" branches that a request CAN reach, and
# it took physics to find: a thing being carried is in a corridor for part of
# the errand, and a second ORDER sent at that moment is refused because the
# thing stands in no room. Measured: over one errand the lamp was sampled in
# room 1, room 2 and NO ROOM.
func _reachable_thing_in_no_room() -> void:
	await _send(CLEAR)
	await _send(DUNGEON)
	await _send('{"command": "ORDER", "parameters": {"goal": "carry", "thing": "lamp", "room": "vault"}}')
	var roomless_frames := 0
	var ordered := false
	for i in 3000:
		await process_frame
		if _thing_room() == -1:
			roomless_frames += 1
			if not ordered:
				ordered = true
				await _reaches("a second ORDER while the thing is in a corridor",
					'{"command": "ORDER", "parameters": {"goal": "carry", "thing": "lamp", "room": "entrance"}}',
					"FAILED_SCENE", "ORDER")
		if ordered and roomless_frames > 0:
			break
	_check(ordered,
		"a carried thing does stand outside every room part of the time, so that branch is reachable")


func _thing_room() -> int:
	if not main.controller.has_standable():
		return -99
	var lamp: Node3D = main.controller._thing_node("lamp")
	if lamp == null:
		return -99
	var holder: Node3D = main.controller.standable["node"]
	var local: Vector3 = holder.to_local(lamp.global_position)
	var module: WorldModule = WorldRegistry.find(str(main.controller.standable.get("command", "")))
	if module == null:
		return -99
	return module.room_of(main.controller.standable["layout"], Vector2(local.x, local.z))


# --- 3. the guards: the fact that puts each out of reach, and the fixture
#        that fires it ---

# FAILED_NO_HANDLER. The whitelist walk 053 said this needed. The case list
# is READ OFF execute()'s own source, so a command added to CORE_COMMANDS
# without a case fails this, and a case removed fails it too.
func _guard_no_handler() -> void:
	var file := FileAccess.open("res://scripts/game_controller.gd", FileAccess.READ)
	_check(file != null, "game_controller.gd can be read")
	if file == null:
		return
	var text := file.get_as_text()
	file.close()
	var start := text.find("func execute(")
	_check(start >= 0, "execute() is still in game_controller.gd")
	if start < 0:
		return
	var rest := text.substr(start)
	var stop := rest.find("\nfunc ")
	var body := rest.substr(0, stop) if stop > 0 else rest
	var unguarded := {}
	var guarded := {}
	for raw_line in body.split("\n"):
		var line := str(raw_line)
		var re := RegEx.create_from_string("^\\t\\t\"([A-Z_]+)\"")
		var m := re.search(line)
		if m == null:
			continue
		# A case with a `when` can fall through to the _ branch, so it does
		# not on its own prove the command is handled. CREATE_TRACK's does,
		# and is handled by the registry instead.
		if line.contains(" when "):
			guarded[m.get_string(1)] = true
		else:
			unguarded[m.get_string(1)] = true
	_check(unguarded.size() >= 8, "execute() has %d unguarded command cases" % unguarded.size())
	_check(guarded.has("CREATE_TRACK"),
		"CREATE_TRACK's case is guarded, so a sectioned one falls through to the registry")

	var registry := WorldRegistry.commands()
	for command in CommandParser.allowed_commands():
		var name := str(command)
		_check(unguarded.has(name) or registry.has(name),
			"%s has an unguarded case in execute() or a module in WorldRegistry, so the _ branch cannot refuse it" % name)
	_check(CommandParser.allowed_commands().size() == 11,
		"the whitelist admits %d commands, all walked" % CommandParser.allowed_commands().size())

	# And it fires. Handed a command no case matches - which the parser never
	# admits - the record comes back with the category and a reason.
	var before := _written().size()
	main.controller.execute("A_COMMAND_WITH_NO_HANDLER", {})
	await process_frame
	var all := _written()
	var fired := false
	for i in range(before, all.size()):
		var d: Dictionary = all[i]
		if str(d.get("category", "")) == "FAILED_NO_HANDLER":
			fired = true
			_check(str(d.get("command", "")) == "A_COMMAND_WITH_NO_HANDLER",
				"and the record names the command that had no handler")
	_check(fired, "handed a command with no case, execute() refuses FAILED_NO_HANDLER")


# FAILED_SCHEMA and FAILED_NOTHING_BUILT at SPAWN_OPPONENTS. Both stand after
# the has_track() guard, and has_track() reads corner_nodes, which nothing in
# scripts/ appends to. Grepped, not remembered.
func _guard_spawn_opponents() -> void:
	var appends := 0
	var dir := DirAccess.open("res://scripts")
	if dir != null:
		for name in dir.get_files():
			if not name.ends_with(".gd"):
				continue
			var f := FileAccess.open("res://scripts/" + name, FileAccess.READ)
			if f == null:
				continue
			var text := f.get_as_text()
			f.close()
			for raw_line in text.split("\n"):
				var line := str(raw_line)
				if line.strip_edges().begins_with("#"):
					continue
				if line.contains("corner_nodes.append") or line.contains("corner_nodes +="):
					appends += 1
	_check(appends == 0,
		"nothing in scripts/ puts a node in TrackBuilder.corner_nodes (found %d), so has_track() is always false" % appends)
	await _send(CLEAR)
	_check(not main.controller.track_builder.has_track(),
		"and has_track() is false after a clear, so SPAWN_OPPONENTS' own two branches are out of reach")

	# Hand it a track. This is the door those two branches have no legal way
	# in through: corner_nodes is the thing has_track() checks.
	var a := Node3D.new()
	a.position = Vector3(1, 0, 0)
	var b := Node3D.new()
	b.position = Vector3(5, 0, 0)
	main.controller.track_builder.add_child(a)
	main.controller.track_builder.add_child(b)
	main.controller.track_builder.corner_nodes.append(a)
	main.controller.track_builder.corner_nodes.append(b)
	_check(main.controller.track_builder.has_track(), "handed two corner nodes, has_track() is true")
	await _reaches("SPAWN_OPPONENTS with a track and a count that is not a number",
		'{"command": "SPAWN_OPPONENTS", "parameters": {"count": null}}',
		"FAILED_SCHEMA", "SPAWN_OPPONENTS")
	await _reaches("SPAWN_OPPONENTS with a track and a sound count",
		'{"command": "SPAWN_OPPONENTS", "parameters": {"count": 4}}',
		"FAILED_NOTHING_BUILT", "SPAWN_OPPONENTS")
	main.controller.track_builder.corner_nodes.clear()
	a.queue_free()
	b.queue_free()


# FAILED_SCENE, ORDER's "nobody to order about here". It needs
# WorldRegistry.find(standable.command) to be null while rooms exist.
func _guard_order_no_module() -> void:
	for m in WorldRegistry.modules():
		var module: WorldModule = m
		_check(WorldRegistry.commands().has(module.command()),
			"%s reports a command the registry knows, so a standable it builds can always be found" % module.command())
	await _send(CLEAR)
	await _send(DUNGEON)
	_check(str(main.controller.standable.get("command", "")) == "CREATE_DUNGEON",
		"a built dungeon's standable names its own module's command")

	# Hand it a standable no module answers to.
	main.controller.standable["command"] = "NOT_A_WORLD"
	await _reaches("ORDER into a standable world no module owns",
		'{"command": "ORDER", "parameters": {"goal": "go_to", "room": "vault"}}',
		"FAILED_SCENE", "ORDER")
	main.controller.standable["command"] = "CREATE_DUNGEON"


# FAILED_SCENE, ORDER's "the thing is not in the world any more". Asserted as
# the invariant it guards, over every request that touches a thing.
func _guard_thing_gone() -> void:
	await _send(CLEAR)
	await _send(DUNGEON)
	_check(_things_all_valid(), "after a build, every thing in standable.things has a node")
	await _send('{"command": "SHUT", "parameters": {"between": ["store", "vault"]}}')
	_check(_things_all_valid(), "after a SHUT rebuilds the world, every thing still has a node")
	await _send('{"command": "OPEN", "parameters": {"between": ["store", "vault"]}}')
	_check(_things_all_valid(), "after an OPEN, every thing still has a node")
	await _send('{"command": "ORDER", "parameters": {"goal": "carry", "thing": "lamp", "room": "vault"}}')
	for i in 600:
		await process_frame
	_check(_things_all_valid(), "with an errand in progress, every thing still has a node")
	await _send('{"command": "SHUT", "parameters": {"between": ["entrance", "store"]}}')
	_check(_things_all_valid(), "and after a SHUT during an errand, every thing still has a node")

	# Hand it a dead node. The only input that makes this branch refuse.
	var things: Array = main.controller.standable.get("things", [])
	_check(not things.is_empty(), "the dungeon has a thing to take away")
	if things.is_empty():
		return
	var entry: Dictionary = things[0]
	var node = entry.get("node", null)
	if is_instance_valid(node):
		(node as Node3D).free()
	_check(not _things_all_valid(), "the lamp's node is gone and it is still listed")
	await _reaches("ORDER carrying a thing whose node is gone",
		'{"command": "ORDER", "parameters": {"goal": "carry", "thing": "lamp", "room": "vault"}}',
		"FAILED_SCENE", "ORDER")


func _things_all_valid() -> bool:
	for entry in (main.controller.standable.get("things", []) as Array):
		var t: Dictionary = entry
		if not is_instance_valid(t.get("node", null)):
			return false
	return true


# --- 4. FAILED_AI: question 2 only, and the row says so ---
#
# Question 1 needs a live key and an API that fails. What IS measurable is
# that the runner writes the category after MAX_RETRIES, so the branch is
# not dead code - handed the failure it names, it records it.
func _guard_ai() -> void:
	var runner := ExperimentRunner.new()
	get_root().add_child(runner)
	runner.running = true
	var before := _written().size()
	for i in ExperimentRunner.MAX_RETRIES + 1:
		runner._on_ai_failed("the model was unreachable")
		await process_frame
	var all := _written()
	var fired := false
	for i in range(before, all.size()):
		var d: Dictionary = all[i]
		if str(d.get("category", "")) == "FAILED_AI":
			fired = true
			_check(not (d.get("reasons", []) as Array).is_empty(),
				"and the FAILED_AI record carries the reason it was given")
	_check(fired, "handed MAX_RETRIES + 1 failures, ExperimentRunner records FAILED_AI")
	runner.running = false
	runner.queue_free()
	notes.append("FAILED_AI: question 1 not answered - this harness has no API key")


func _run() -> void:
	_make_main()
	await process_frame
	await process_frame

	_enumeration()
	await _reachable_at_launch()
	await _reachable_after_a_clear()
	await _reachable_parse()
	await _reachable_equip_and_plan()
	await _reachable_plan_placement()
	await _reachable_order()
	await _reachable_thing_in_no_room()
	await _guard_no_handler()
	await _guard_spawn_opponents()
	await _guard_order_no_module()
	await _guard_thing_gone()
	await _guard_ai()

	for line in notes:
		print("  NOTE  ", line)
	print("CONTROLLER REACH %d assertions, failures=%d" % [asserted, bad])
	quit(bad)
