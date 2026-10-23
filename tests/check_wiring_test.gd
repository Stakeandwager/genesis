extends SceneTree

# --- 055: which checks in Genesis can be proved CONNECTED? ---
#
# THE TASK, AND WHERE IT CAME FROM
#
# HANDOVER named this as the next assistant task: the class question behind
# "Human decision needed" 18. 053 found that FarmModule._check_reachable()
# is called from inside solve() on the layout solve() has just built, so
# nothing can hand it a violating input - delete the call and every suite
# still passes. 054 asked the same of the five controller guards and found
# all five have a door. Nobody had asked it of the rest.
#
# THE QUESTION IS NOT "DOES THE CHECK FIRE". 053 and 054 answered that one:
# every refusal in Genesis fires when handed the thing it names. This asks
# the other half, and it is a question about the CALL rather than about the
# check: if this call stopped refusing tomorrow, would any suite say so?
# A check that fires and is not wired in refuses nothing. A check that is
# wired in and that no test reaches through the GAME'S door is a check the
# suite is not holding - and the two look identical from the green line at
# the bottom of a test run.
#
# THE METHOD, AND IT IS 053'S
#
# Take one call site. Make it stop refusing - force its ok, or drop the
# branch that returns the refusal - in a THROWAWAY COPY of the repository,
# run every suite, and diff the result lines against a baseline taken the
# same way. Then put the copy back. Fourteen call sites were done one at a
# time. Nothing in this repository was edited to measure it and no guard was
# removed from Genesis.
#
# THE FIRST ATTEMPT GOT FOUR ANSWERS WRONG, AND THE REASON IS WORTH MORE
# THAN THE ANSWERS. The runs were done two and three at a time to save
# wall-clock. Every copy of this project has the same config/name in
# project.godot, so every copy shares ONE Godot user:// directory: one
# user://track_log.jsonl and one user://worlds. Two suites running at once
# write over each other's ledger. ledger_test and intent_door_test duly
# failed in run after run and were read as "the guard is held" - they were
# reading another run's ledger. Re-measured one at a time, with user://
# cleared before every run including the baseline, LoadCheck and
# RefusalCheck turned out NOT to be held at all. See TRAPS 50.
#
# THE ANSWER: FOURTEEN CALL SITES, TEN HELD, FOUR NOT - AND ONLY ONE OF THE
# FOUR IS THE FARM'S PROBLEM
#
#   HELD BEFORE 055 (wiring out the call failed a suite, named in the table):
#     racing's SectionValidator, FeasibilityGate and SeparationCheck;
#     ORDER's and SHUT/OPEN's goal validators; EQUIP's tool validator;
#     and the controller's validate and pre_check and post_check steps.
#
#   HELD, BUT ONLY BY A SUITE MOST RUNS SKIP: the controller's solve step at
#     game_controller.gd:1158. Force solved["ok"] and all 59 fast suites
#     pass; session_test catches it, and session_test runs only with --all
#     because it takes minutes. 055's fixture holds it in a fast suite too.
#     What it does NOT do is build the track - this file said it did until
#     the fixture was run against the wire-out (TRAPS 14). The unclosable
#     circuit goes on to post_check and comes back FAILED_SEPARATION
#     instead, so the cost of the missing refusal, on this circuit, is a
#     refusal under the WRONG NAME. That is why the fixture asserts the
#     category and not merely that nothing was built.
#
#   NOT HELD BEFORE 055, AND ALL THREE HAVE A DOOR - nothing walked it:
#     LoadCheck.compare   at main.gd:618. The one build whose right answer
#                         was written down in advance (025). Replace the
#                         verdict with a constant RESTORED and all 61 suites
#                         pass, --all included. load_check_test calls
#                         LoadCheck.compare directly, fourteen times, and
#                         never through /load.
#     RefusalCheck        at main.gd:298. 023's answer to a refusal that
#                         denies something Genesis does. Hand the caller an
#                         empty quarrel list and all 61 suites pass.
#                         asked_test, limits_test and log_023_test call
#                         quarrel_with() directly and never through an
#                         UNSUPPORTED answer.
#     ToolRegistry        at tool_registry.gd:47. The readback's choice
#                         between the spec the validator produced and the
#                         spec that was merely heard. Switch the validated
#                         branch off and all 61 suites pass.
#
#   NO DOOR AT ALL, and it is still the only one: FarmModule._check_reachable.
#     Re-measured here and it is unchanged from 053 - wiring it out is caught
#     by nothing. Where it should live is "Human decision needed" 18 and it
#     is the owner's; nothing was moved.
#
# --- 056: THE TWO ROWS 055 LEFT UNMEASURED, AND THEY ANSWER OPPOSITELY ---
#
# 055 left three rows unanswered and said so rather than letting them look
# covered. 056 measured the two that could be measured, by 055's method -
# one wire-out at a time in a throwaway copy, every suite with --all, the
# result lines diffed, user:// cleared before each run.
#
#   GameController.finish_order  HELD HARD. The delivery verdict, which is
#     what PROTOCOL's "never accept the carrier's claim as proof of
#     delivery" is about. Wire out its call at main.gd:692 and SEVEN suites
#     say so: false_delivery_test (5 failures), interference_test (2),
#     carry_test, ledger_test, order_test, repeat_test, and
#     ledger_audit_test throws on the record that is no longer written.
#     false_delivery_test reaches it through main.npc.halt() - the NPC's own
#     stopped_walking signal, which IS the door the game walks - not through
#     the direct finish_order() calls that also appear in that file. So this
#     was already held through the real door by six suites and nobody had
#     written it down. The row said NOT_ASKED, which was honest: it meant
#     not measured, never unheld.
#
#   main._on_revision_requested  HELD BY NOTHING. Wire out the connect at
#     main.gd:80 and all 62 suites pass, --all included; the diff against
#     the baseline is EMPTY. The fixture at 3e below holds it now, and the
#     reason nothing could have held it before is TRAPS 52 - see that
#     fixture's own header, because it is a different shape from the three
#     above and worth reading as such.
#
# So after 056 every row in the table below carries a MEASURED verdict
# except one: experiment_runner.gd:_on_ai_failed, which needs a live key and
# an API that fails. Counted off the table, not remembered.
#
# WHY 055'S THREE WERE INVISIBLE, WHICH IS THE PART WORTH KEEPING
#
# (These are the three under "NOT HELD BEFORE 055" above, not 056's two:
# 056's unheld one has a different cause and its own account at the fixture.)
#
# Every one of the three has a suite that tests the check itself, thoroughly, by
# calling it directly. load_check_test is 236 lines about LoadCheck. What
# none of them does is walk the door the game walks. A unit test proves a
# check FIRES; only a request through the real door proves it is REACHED.
# TRAPS 49 states the rule.
#
# And ToolRegistry's is the sharper case, because a door existed and the
# inputs sent through it could not have shown the difference: boots_test
# reads back {"weight": 130.0} and log_022_test reads back a REFUSED look.
# A weight of 130.0 is identical whether it comes from the validator or from
# what was heard, so the branch was invisible to every input the suite had.
# Of eight sampled legal specs, five read back differently through the two
# paths - "the ordinary RED car" against "the ordinary red car".
#
# WHAT THIS SUITE ASSERTS, AND WHAT IT DOES NOT (TRAPS 6, TRAPS 14)
#
# Nothing here asserts a sentence, and nothing here asserts a verdict in the
# table - a verdict is a measurement taken once, with the method above, and
# a test that asserted it would be asserting a comment. What is asserted is:
#
#   1. the enumeration still matches the source, both ways;
#   2. for every row marked NO_DOOR, the structural fact that makes it one -
#      that the function is called from one place and that place is in its
#      own file. Give it a door and this suite moves.
#   3. the four doors nothing walked, walked: a tampered save file loaded
#      through /load, an UNSUPPORTED answer that denies a capability
#      Genesis has, a circuit that cannot close sent through main.gd, and
#      a tool spec the validator normalises. Each reads the LEDGER or the
#      readback for the evidence, not a status line.
#
# What it does NOT assert: that the nine already-held rows are still held.
# That is the other suites' job and the table says which one each time.
# It also does not notice a check that answers in some third shape - see
# the enumeration's limit below.
#
# THE ENUMERATION IS MECHANICAL AND FAILS CLOSED, which is 053's pattern.
# Every scripts/*.gd is read, split into functions, and every function whose
# body returns a verdict key - "ok", "errors", "category" or "outcome" - is
# collected. A function in the source with no row FAILS and a row naming a
# function that is gone FAILS, so a thirty-sixth check cannot be added
# without this question being asked of it.
#
# ITS LIMIT, SAID RATHER THAN LEFT TO BE FOUND: a check that answers in some
# other shape is not caught by that rule. RefusalCheck.quarrel_with() is one
# - it answers with an Array of quarrels - and it is in BY_HAND below,
# declared rather than discovered. A check written tomorrow in a third shape
# would be missed, and the honest size of that hole is one function today.
#
# AND IT WAS RUN AGAINST BROKEN CODE BEFORE IT WAS BELIEVED (052's lesson):
# eleven deliberate faults, one at a time, every one caught. The evidence is
# in the 055 section of HANDOVER.
#
# ONE OF THE ELEVEN FOUND A FAULT IN THIS FILE'S OWN FIRST DRAFT, AND IN
# 053'S. Both asked "does this module override solve()" with
# Script.get_script_method_list(). That list includes INHERITED methods, so
# every module answered yes to every WorldModule method - FarmModule, which
# defines neither pre_check() nor post_check(), answered yes to both. The
# assertion could not fail, which is TRAPS 6 in the guard rather than in the
# code, and 053 had written it precisely so that a fourth world would be
# asked. Both files now read the module's own source instead, and this one
# declares in BASE_OVERRIDES which module defines which step - so the farm's
# two fall-throughs are written down rather than papered over. TRAPS 51.

var asserted := 0
var bad := 0
var main: Node3D
var notes: Array = []

# What the verdicts mean. A row's verdict must be one of these.
#
#   CONNECTED      wiring the call out failed a named suite, before 055.
#   CONNECTED_055  nothing caught it before 055; a fixture below does now.
#   NO_DOOR        nothing can hand the check a violating input.
#   BASE_DEFAULT   WorldModule's or ToolModule's default, overridden by every
#                  module in the registry - asserted by reflection below.
#   REPORTS        answers whether a file operation worked. It refuses no
#                  request, so there is no guard here to wire out.
#   NEEDS_KEY      cannot be answered in this harness. 054's row, unchanged.
#   CONNECTED_056  nothing caught it before 056; 056's fixture does now.
#   NOT_ASKED      not measured. Said rather than left looking covered.
const VERDICTS := ["CONNECTED", "CONNECTED_055", "CONNECTED_056", "NO_DOOR",
	"BASE_DEFAULT", "REPORTS", "NEEDS_KEY", "NOT_ASKED"]

# --- the table: one row per verdict-returning function in scripts/ ---
#
# [verdict, the call site measured and what happened]
const DECLARED := {
	"boots_tool.gd:validate": ["CONNECTED_055",
		"EQUIP's refusal (W09) failed controller_reach_test; the readback's branch (W14) was held by nothing"],
	"car_tool.gd:validate": ["CONNECTED_055",
		"EQUIP's refusal (W09) failed controller_reach_test; the readback's branch (W14) was held by nothing"],
	"look_tool.gd:validate": ["CONNECTED_055",
		"EQUIP's refusal (W09) failed controller_reach_test; the readback's branch (W14) was held by nothing"],
	"tool_module.gd:validate": ["BASE_DEFAULT",
		"every tool in ToolRegistry overrides it - by reflection below"],
	"closure_solver.gd:solve": ["CONNECTED",
		"the controller's solve step (W13) was caught by session_test, which runs only with --all; 055's fixture holds it in a fast suite too"],
	"command_parser.gd:parse": ["CONNECTED",
		"controller_reach_test drives FAILED_PARSE through main.gd"],
	"dungeon_module.gd:validate": ["CONNECTED",
		"W10 failed controller_reach_test, intent_door_test and procedure_test"],
	"dungeon_module.gd:pre_check": ["CONNECTED", "W11 failed controller_reach_test"],
	"dungeon_module.gd:solve": ["CONNECTED",
		"the controller's solve step (W13), caught only by session_test under --all"],
	"dungeon_module.gd:post_check": ["CONNECTED", "W12 failed controller_reach_test"],
	"experiment_runner.gd:_on_ai_failed": ["NEEDS_KEY",
		"054's row: it needs a live key and an API that fails"],
	"farm_module.gd:validate": ["CONNECTED", "W10, as the dungeon's"],
	"farm_module.gd:solve": ["CONNECTED",
		"the controller's solve step (W13), caught only by session_test under --all"],
	"farm_module.gd:_check_reachable": ["NO_DOOR",
		"053's: called inside solve() on the layout solve() built. HANDOVER 'Human decision needed' 18"],
	"feasibility_gate.gd:check": ["CONNECTED", "W03 failed refusal_reach_test"],
	"game_controller.gd:_prepare_world": ["CONNECTED",
		"its four steps are W10, W11, W13 and W12"],
	"game_controller.gd:finish_order": ["CONNECTED",
		"the delivery verdict. 056 wired out its call at main.gd:692: SEVEN suites said so - false_delivery_test (5), interference_test (2), carry_test, ledger_test, order_test, repeat_test, and ledger_audit_test threw on the missing record"],
	"game_controller.gd:record_load_check": ["CONNECTED_055",
		"the load fixture below reads the record it writes"],
	"load_check.gd:compare": ["CONNECTED_055", "W01 was held by nothing, --all included"],
	"main.gd:_on_revision_requested": ["CONNECTED_056",
		"056 wired out its connect at main.gd:80 and all 62 suites passed, --all included. The revision fixture below holds it"],
	"npc_goals.gd:validate": ["CONNECTED", "W07 failed controller_reach_test"],
	"npc_goals.gd:validate_door": ["CONNECTED",
		"W08 failed controller_reach_test, interference_test and panel_refused_test"],
	"racing_module.gd:validate": ["CONNECTED",
		"W05 failed container_door_test, intent_door_test, plan_said_test and prompt_bounds_test"],
	"racing_module.gd:pre_check": ["CONNECTED", "W03 and W11"],
	"racing_module.gd:solve": ["CONNECTED",
		"the controller's solve step (W13), caught only by session_test under --all"],
	"racing_module.gd:post_check": ["CONNECTED", "W04 and W12"],
	"section_validator.gd:_result": ["CONNECTED",
		"validate()'s only exit, so W05 is its measurement"],
	"separation_check.gd:check": ["CONNECTED", "W04 failed refusal_reach_test"],
	"world_module.gd:validate": ["BASE_DEFAULT",
		"every module defines its own; read off their source below"],
	"world_module.gd:pre_check": ["BASE_DEFAULT",
		"the FARM uses this one - it defines no pre_check. It refuses nothing, so there is no guard here to wire out"],
	"world_module.gd:solve": ["BASE_DEFAULT",
		"every module defines its own, which is what puts its FAILED_LAYOUT out of reach (053)"],
	"world_module.gd:post_check": ["BASE_DEFAULT",
		"the FARM uses this one - it defines no post_check. It refuses nothing, so there is no guard here to wire out"],
	"world_store.gd:save_world": ["REPORTS", "says whether a file was written"],
	"world_store.gd:load_world": ["REPORTS", "says whether a file was read"],
	"world_store.gd:remove_world": ["REPORTS", "says whether a file was there"],
}

# Checks that do not answer with a verdict key, so the enumeration above
# cannot find them. Declared by hand, and the suite asserts each one is
# still in its file. This is the hole in the mechanical rule, measured: it
# is one function today.
const BY_HAND := {
	"refusal_check.gd:quarrel_with": ["CONNECTED_055",
		"answers with an Array of quarrels. W02 was held by nothing"],
}

# Which world modules define each of WorldModule's four steps, and which
# fall through to the base. Read off their own source below rather than
# asked by reflection - see the header, and TRAPS 51.
const BASE_OVERRIDES := {
	"validate": ["dungeon_module.gd", "farm_module.gd", "racing_module.gd"],
	"pre_check": ["dungeon_module.gd", "racing_module.gd"],
	"solve": ["dungeon_module.gd", "farm_module.gd", "racing_module.gd"],
	"post_check": ["dungeon_module.gd", "racing_module.gd"],
}

# Rows measured in a throwaway copy. The suite does not re-measure them; it
# names them so a reader can find the run.
const CALL_SITES_MEASURED := 14
const NOT_HELD_BEFORE_055 := 5

const DUNGEON := '{"command": "CREATE_DUNGEON", "parameters": {"rooms": [{"name": "hall", "width": 20, "depth": 20}, {"name": "store", "width": 10, "depth": 10}, {"name": "vault", "width": 10, "depth": 10}], "doors": [[1, 2], [2, 3]], "things": [{"name": "lamp", "in": "store"}]}}'
# refusal_reach_test's: three 120 deg corners do add to 360, so the gate lets
# it through, and two 1000 m straights against one of 20 m are what the
# solver cannot pull closed within the 20% it is allowed.
const UNCLOSABLE := '{"command": "CREATE_TRACK", "parameters": {"sections": [{"type": "straight", "length": 1000.0}, {"type": "corner", "radius": 15.0, "angle": 120.0}, {"type": "straight", "length": 20.0}, {"type": "corner", "radius": 15.0, "angle": 120.0}, {"type": "straight", "length": 1000.0}, {"type": "corner", "radius": 15.0, "angle": 120.0}]}}'

const SAVED_AS := "wiring-test-tmp"


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
# by POSITION rather than by id: a plan writes several records and two of
# them share an id (HANDOVER, "Human decision needed" 17c).
func _send(json_text: String) -> Array:
	var before := _written().size()
	main._handle_request(json_text)
	await process_frame
	await process_frame
	return _since(before)


func _local(request: String) -> Array:
	var before := _written().size()
	main._run_local_command(request)
	await process_frame
	await process_frame
	return _since(before)


func _since(before: int) -> Array:
	var all := _written()
	var mine: Array = []
	for i in range(before, all.size()):
		mine.append(all[i])
	return mine


# --- 1. the enumeration, read off the source rather than typed ---

# Every function in scripts/ whose body returns a verdict key, as
# "file.gd:function". Comments are stripped first, so a comment that
# mentions one does not invent a row.
func _verdict_functions() -> Dictionary:
	var found := {}
	var dir := DirAccess.open("res://scripts")
	if dir == null:
		return found
	var header := RegEx.create_from_string("^(static )?func ([A-Za-z_0-9]+)\\(")
	var verdict := RegEx.create_from_string("\"(ok|errors|category|outcome)\"[ \t]*:")
	for name in dir.get_files():
		if not name.ends_with(".gd"):
			continue
		var file := FileAccess.open("res://scripts/" + name, FileAccess.READ)
		if file == null:
			continue
		var lines := file.get_as_text().split("\n")
		file.close()
		var current := ""
		var body := ""
		for raw in lines:
			var line := str(raw)
			var head := header.search(line)
			if head != null:
				if current != "" and verdict.search(body) != null:
					found["%s:%s" % [name, current]] = true
				current = head.get_string(2)
				body = ""
			var hash_at := line.find("#")
			body += (line if hash_at < 0 else line.substr(0, hash_at)) + "\n"
		if current != "" and verdict.search(body) != null:
			found["%s:%s" % [name, current]] = true
	return found


# Does this script define this method itself? Read from the file, because
# Script.get_script_method_list() includes what a script INHERITS and so
# cannot tell an override from a fall-through (TRAPS 51).
#
# Read off the CODE (067). The "\n" anchors already kept a comment out of
# this one - a comment line starts with "#", so "\nfunc " cannot match it -
# and the anchors are kept for that reason; what _code_of() adds is the
# commented-out definition, "#func solve(" at the start of a line, which the
# anchors alone do not catch. See TRAPS 64.
func _defines(script_path: String, method: String) -> bool:
	var file := FileAccess.open(script_path, FileAccess.READ)
	if file == null:
		_check(false, "could not read %s" % script_path)
		return false
	var text := _code_of(file.get_as_text())
	file.close()
	return text.contains("\nfunc %s(" % method) or text.contains("\nstatic func %s(" % method)


func _enumeration() -> void:
	var found := _verdict_functions()
	_check(found.size() >= 30, "read %d verdict-returning functions off scripts/" % found.size())
	for key in found:
		_check(DECLARED.has(key), "%s has a row in DECLARED" % str(key))
	for key in DECLARED:
		_check(found.has(key), "DECLARED's row for %s still names a function in scripts/" % str(key))
		var row: Array = DECLARED[key]
		_check(VERDICTS.has(str(row[0])), "%s has a verdict from the list (got '%s')" % [str(key), str(row[0])])
		_check(str(row[1]).strip_edges() != "", "%s says which call site was measured" % str(key))

	# The hand-declared one. It is not found by the rule above, so the rule
	# cannot hold it: what is asserted is that the function is still there.
	#
	# READ OFF THE CODE AND NOT THE WHOLE FILE (067). This needle has no "\n"
	# anchor in front of it, unlike _defines() below, and that difference was
	# worth a measurement rather than a guess: rename quarrel_with() through
	# scripts/ and tests/, put the BY_HAND key back to the old name, and this
	# assertion FAILS - until one comment line in refusal_check.gd says
	# "Renamed from func quarrel_with(reason)", at which point it PASSES on a
	# row that names a function nobody has. 188 assertions, failures=0, on a
	# staleness guard that was stale. See TRAPS 64.
	for key in BY_HAND:
		var parts := str(key).split(":")
		var file := FileAccess.open("res://scripts/" + parts[0], FileAccess.READ)
		_check(file != null, "BY_HAND names a file that exists: %s" % parts[0])
		if file == null:
			continue
		var text := _code_of(file.get_as_text())
		file.close()
		_check(text.contains("func %s(" % parts[1]),
			"%s is still in %s, in code and not in a comment" % [parts[1], parts[0]])
		# The reader's own negative control: prose does not answer a question
		# about what the code has, and code does.
		_check(not _code_of("# func %s(reason)\n\tvar x := 1  # func %s(\n" % [parts[1], parts[1]]).contains("func %s(" % parts[1]),
			"and the reader it uses does not see %s() in a comment, on its own line or after code" % parts[1])
		_check(_code_of("static func %s(reason: String) -> Array:\n" % parts[1]).contains("func %s(" % parts[1]),
			"while it does see it in a line of code, so the check above is not passing by seeing nothing")
		_check(not found.has(key),
			"%s is still outside the mechanical rule, which is why it is declared by hand" % str(key))

	# Which modules define each of WorldModule's four steps, read off their
	# own source. A fourth world, or a farm that grows a pre_check, moves
	# this and the BASE_DEFAULT rows above with it.
	for method in BASE_OVERRIDES:
		var defines: Array = []
		for module in WorldRegistry.modules():
			var path := str((module as Object).get_script().resource_path)
			if _defines(path, str(method)):
				defines.append(path.get_file())
		defines.sort()
		var declared: Array = (BASE_OVERRIDES[method] as Array).duplicate()
		declared.sort()
		_check(defines == declared,
			"the modules that define %s() are %s (the table says %s)" % [
				str(method), str(defines), str(declared)])
	_check((BASE_OVERRIDES["solve"] as Array).size() == WorldRegistry.modules().size(),
		"every world in the registry defines solve(), which is what puts WorldModule's own refusal out of reach")
	for tool in ToolRegistry.tools():
		var tool_path := str((tool as Object).get_script().resource_path)
		_check(_defines(tool_path, "validate"),
			"the %s tool defines validate(), so ToolModule's default is not its answer" % (tool as ToolModule).name())


# --- 2. the NO_DOOR rows, and what makes them that ---
#
# "No door" is not an opinion about the code: it is the statement that the
# check is called from one place, in its own file, on something that place
# built. The first two halves are mechanical and are asserted here, so the
# day somebody gives the farm's check a door this suite says the row has
# moved.

func _no_door_rows() -> void:
	var rows := 0
	for key in DECLARED:
		var row: Array = DECLARED[key]
		if str(row[0]) != "NO_DOOR":
			continue
		rows += 1
		var parts := str(key).split(":")
		var owner_file := str(parts[0])
		var function := str(parts[1])
		_check(function.begins_with("_"),
			"%s is private, so nothing outside %s can call it" % [function, owner_file])

		var callers := {}
		var dir := DirAccess.open("res://scripts")
		if dir == null:
			continue
		var call_pattern := RegEx.create_from_string("(^|[^A-Za-z_0-9])" + function + "[ \t]*\\(")
		for name in dir.get_files():
			if not name.ends_with(".gd"):
				continue
			var file := FileAccess.open("res://scripts/" + name, FileAccess.READ)
			if file == null:
				continue
			var lines := file.get_as_text().split("\n")
			file.close()
			for raw in lines:
				var line := str(raw)
				var hash_at := line.find("#")
				var code := line if hash_at < 0 else line.substr(0, hash_at)
				if code.begins_with("func ") or code.begins_with("static func "):
					continue
				if call_pattern.search(code) != null:
					callers[name] = true
		_check(callers.size() == 1 and callers.has(owner_file),
			"%s is called from %s alone (found %s)" % [function, owner_file, str(callers.keys())])
	_check(rows == 1, "one row is NO_DOOR and it is the farm's (found %d)" % rows)


# --- 3a. the load verdict, through /load rather than through a call ---
#
# 025 built LoadCheck because "Loaded 'vault'" was a claim about a file being
# opened dressed as a claim about a world coming back. Replace the verdict at
# main.gd:618 with a constant RESTORED and every suite passes: load_check_test
# calls compare() directly and nothing loads a world that disagrees with its
# own file. So: save a world, edit the measurements in the file on disk, load
# it, and demand that Genesis says the world is not the one that was saved.
#
# BOTH DIRECTIONS, because a check that always says DIFFERENT is no better
# than one that always says RESTORED: the honest load is asserted first.

func _load_verdict() -> void:
	WorldStore.remove_world(SAVED_AS)
	await _send(DUNGEON)
	_check(not main.controller.last_build.is_empty(), "the fixture's dungeon was built")

	await _local("/save " + SAVED_AS)
	var saved: Dictionary = WorldStore.load_world(SAVED_AS)
	_check(bool(saved["ok"]), "the fixture's world saved")
	if not bool(saved["ok"]):
		return
	var recorded: Dictionary = (saved["world"] as Dictionary).get("metrics", {})
	_check(not recorded.is_empty(), "the save file carries the measurements taken when it was built")

	# The honest load first.
	var honest: Array = await _local("/load " + SAVED_AS)
	var verdict := _load_record(honest)
	_check(str(verdict.get("outcome", "")) == "RESTORED",
		"a world loaded from its own file comes back RESTORED (got '%s')" % str(verdict.get("outcome", "")))

	# Now the same world, with one measurement in the file made false. The
	# world rebuilt from the description is unchanged; what changed is what
	# the file claims was measured, which is exactly the case 025 is about.
	var key := ""
	for k in recorded:
		if typeof(recorded[k]) == TYPE_FLOAT or typeof(recorded[k]) == TYPE_INT:
			key = str(k)
			break
	_check(key != "", "the save file has a measurement that is a number")
	if key == "":
		return
	var was := float(recorded[key])
	_tamper(SAVED_AS, key, was + 7.0)

	var tampered: Array = await _local("/load " + SAVED_AS)
	var caught := _load_record(tampered)
	_check(str(caught.get("outcome", "")) == "DIFFERENT",
		"a world whose file disagrees with it comes back DIFFERENT (got '%s')" % str(caught.get("outcome", "")))
	var named := false
	for d in (caught.get("differences", []) as Array):
		if str((d as Dictionary).get("what", "")) == key:
			named = true
	_check(named, "the load record names the measurement that disagrees ('%s')" % key)

	WorldStore.remove_world(SAVED_AS)


func _load_record(records: Array) -> Dictionary:
	for r in records:
		var d: Dictionary = r
		if str(d.get("type", "")) == "load_check":
			return d
	return {}


# Change one measurement in a save file, leaving the description alone. The
# world that comes back is the same world; the file's claim about it is not.
func _tamper(world_name: String, key: String, value: float) -> void:
	var path := "user://worlds/%s.world.json" % world_name
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		_check(false, "the fixture could not read %s" % path)
		return
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(data) != TYPE_DICTIONARY:
		_check(false, "the fixture's save file is not an object")
		return
	var world: Dictionary = data
	var metrics: Dictionary = world.get("metrics", {})
	metrics[key] = value
	world["metrics"] = metrics
	var out := FileAccess.open(path, FileAccess.WRITE)
	if out == null:
		_check(false, "the fixture could not write %s" % path)
		return
	out.store_string(JSON.stringify(world, "\t"))
	out.close()


# --- 3b. the false-refusal check, through an UNSUPPORTED answer ---
#
# 023: a refusal is a claim about Genesis, and it was the only claim nothing
# checked. Hand main.gd an empty quarrel list at main.gd:298 and every suite
# passes - asked_test, limits_test and log_023_test all call quarrel_with()
# directly. This sends a refusal that denies a capability through the door an
# AI answer comes through, and reads the ledger.
#
# THE LIE IS BUILT FROM RefusalCheck'S OWN TABLE rather than typed out, so
# the fixture cannot go stale against a reworded entry, and the suite asserts
# the lie really is one before asking whether it was caught.

func _refusal_note() -> void:
	var denial := ""
	var capability := ""
	for entry in RefusalCheck.CAPABILITIES:
		var one: Dictionary = entry
		var denials: Array = one.get("denials", [])
		if not denials.is_empty():
			denial = str(denials[0])
			capability = str(one["name"])
			break
	_check(denial != "", "RefusalCheck has an outright denial to build a refusal from")
	if denial == "":
		return

	var reason := "I cannot build that: %s." % denial
	_check(not RefusalCheck.quarrel_with(reason).is_empty(),
		"the fixture's refusal really does understate Genesis (capability '%s')" % capability)

	var request := JSON.stringify({
		"command": "UNSUPPORTED",
		"parameters": {"reason": reason, "understood": "a world the fixture asked for"}})
	var records: Array = await _send(request)
	var noted := false
	for r in records:
		var d: Dictionary = r
		if str(d.get("category", "")) != "UNSUPPORTED":
			continue
		var quarrels = d.get("refusal_understates", [])
		if typeof(quarrels) == TYPE_ARRAY and not (quarrels as Array).is_empty():
			noted = true
	_check(noted, "the ledger's UNSUPPORTED record carries the quarrel with the refusal")

	# The other direction, so the fixture is not satisfied by a checker that
	# quarrels with everything: an honest refusal leaves no note.
	var honest := JSON.stringify({
		"command": "UNSUPPORTED",
		"parameters": {"reason": "There is no second character to compare with.",
			"understood": "a comparison of two characters"}})
	_check(RefusalCheck.quarrel_with("There is no second character to compare with.").is_empty(),
		"the fixture's honest refusal is honest")
	var clean: Array = await _send(honest)
	var marked := false
	for r in clean:
		if (r as Dictionary).has("refusal_understates"):
			marked = true
	_check(not marked, "an honest refusal leaves no quarrel in the ledger")


# --- 3c. the solve step's refusal, through main.gd ---
#
# refusal_reach_test proves a module refuses an unclosable circuit when the
# module is asked directly. controller_reach_test counts the controller's
# three module-facing sites as PASSTHROUGH and leaves them to that file. So
# nothing asked whether the controller passes a solve refusal through at all.
# Measured: force solved["ok"] and all 59 FAST suites stay green; session_test
# catches it, and session_test runs only with --all because it takes minutes.
# A guard held only by a suite most runs skip is held thinly, so this is the
# same question asked in a suite that runs every time.
#
# What is asserted is the CATEGORY and not only that nothing was built,
# because measured against the wire-out those are different questions: the
# unclosable circuit forced past the solve refusal is caught further down by
# the separation check and comes back FAILED_SEPARATION. Nothing is built
# either way; what is lost is the true reason, which is the sentence the
# player reads.

func _solve_refusal() -> void:
	var records: Array = await _send(UNCLOSABLE)
	var refused := false
	var built := false
	for r in records:
		var d: Dictionary = r
		if str(d.get("command", "")) != "CREATE_TRACK":
			continue
		if str(d.get("category", "")) == "FAILED_CLOSURE":
			refused = true
		if str(d.get("result", "")) == "VALID":
			built = true
	_check(refused, "a circuit the solver cannot close is refused through main.gd (got %s)" % str(_categories(records)))
	_check(not built, "and no record calls it a valid world")


func _categories(records: Array) -> Array:
	var out: Array = []
	for r in records:
		var cat := str((r as Dictionary).get("category", ""))
		if cat != "" and not out.has(cat):
			out.append(cat)
	return out


# --- 3d. the tool readback says back the spec the VALIDATOR produced ---
#
# TRAPS 8's rule has two halves and only one of them was held. A REFUSED
# request is said back from what was heard, never from the defaults -
# log_022_test holds that. An ACCEPTED request is said back from the spec the
# validator produced, and nothing held that, because every legal spec the
# suite sent was already in the form the validator would have returned. The
# rule is asked here of EVERY tool in the registry (TRAPS 11), and the case
# is built from each tool's own defaults rather than typed out, so a fourth
# tool is asked without this file being edited.

func _tool_readback() -> void:
	var distinguishing := 0
	for tool in ToolRegistry.tools():
		var kind := (tool as ToolModule).name()
		for field in (tool as ToolModule).defaults():
			var default_value = (tool as ToolModule).defaults()[field]
			if typeof(default_value) != TYPE_STRING or str(default_value) == "":
				continue
			# The tool's own default value, shouted. Legal by construction,
			# and the validator lower-cases it where asked_spec does not.
			var parameters := {"tool": kind, "spec": {field: str(default_value).to_upper()}}
			var checked: Dictionary = (tool as ToolModule).validate(parameters)
			if not bool(checked["ok"]):
				continue
			var from_checked := (tool as ToolModule).readback(checked["spec"])
			var from_heard := (tool as ToolModule).readback(ToolRegistry.asked_spec(tool, parameters))
			if from_checked == from_heard:
				continue
			distinguishing += 1
			_check(ToolRegistry.readback(parameters) == from_checked,
				"%s: an accepted '%s' is said back from the checked spec, not what was heard ('%s' against '%s')" % [
					kind, field, ToolRegistry.readback(parameters), from_heard])

		# And the sibling half, so the pair is held in one place: a REFUSED
		# request is still said back from what was heard. A value of the
		# right kind and the wrong content is laid over the defaults.
		for field in (tool as ToolModule).defaults():
			var default_value = (tool as ToolModule).defaults()[field]
			if typeof(default_value) != TYPE_STRING or str(default_value) == "":
				continue
			var nonsense := {"tool": kind, "spec": {field: "nothing-this-game-has"}}
			var refused: Dictionary = (tool as ToolModule).validate(nonsense)
			if bool(refused["ok"]):
				continue
			var said := ToolRegistry.readback(nonsense)
			_check(said == (tool as ToolModule).readback(ToolRegistry.asked_spec(tool, nonsense)),
				"%s: a refused '%s' is said back from what was heard" % [kind, field])
			_check(said != (tool as ToolModule).readback((tool as ToolModule).defaults()),
				"%s: and not from the defaults (TRAPS 8): '%s'" % [kind, said])
			break

	# If no tool has a field the validator normalises, the first half above
	# asserts nothing at all and would pass against a readback that ignored
	# the validator entirely. Said out loud rather than left to pass quietly.
	_check(distinguishing >= 1,
		"at least one legal spec tells the checked readback from the heard one (found %d)" % distinguishing)
	notes.append("legal specs that tell the two readback paths apart: %d" % distinguishing)


# --- 3e. the closure revision, through the controller's own signal ---
#
# 055 left this row NOT_ASKED. 056 measured it: wire out the connect at
# main.gd:80 and all 62 suites pass, --all included. Nothing held it.
#
# WHY NOTHING WALKED THIS DOOR, which is the part worth keeping. The emit at
# game_controller.gd:1168 stands behind _may_revise(), and _may_revise()
# requires current_source["source"] == "ai". That string is written in ONE
# place in Genesis - AIInterpreter.describe(), ai_interpreter.gd:250 - which
# main.gd reaches only after interpreter.is_available() passes. So the whole
# revision path is gated on the request having come from the model, and no
# harness without a key can produce that. Raw JSON sets {"source": "typed"}
# (main.gd:189). Asked of the class: the closure revision is the ONLY
# behaviour in Genesis gated on a request's provenance - grepped, two readers
# of current_source and one of them is a record field. The honest size of
# that class is one. TRAPS 52.
#
# WHAT THIS FIXTURE FAKES, STATED RATHER THAN BURIED: one field, the
# provenance label, set to what AIInterpreter.describe() would have set.
# Everything downstream is the real thing - the real unclosable circuit
# through _execute_json, the real solve refusal, the real _may_revise, the
# real emit, the real handler. What is NOT verified here and cannot be: that
# the AI is actually asked and an answer comes back. The handler calls
# interpreter.revise() after a 4 s timer, and this fixture asserts the state
# the handler has already set before that await, so no request is ever sent.
#
# AND IT ASSERTS THE CAPABILITY, NOT A SENTENCE (TRAPS 6, TRAPS 14): that
# Genesis enters the revising state, that the second attempt is numbered 2,
# and that what it carries is the distance GODOT MEASURED - read back out of
# the same record the refusal wrote, not a string the handler composed.

func _revision_handler() -> void:
	# The label AIInterpreter.describe() sets, and nothing else changed.
	main.pending_request = "a circuit that cannot close"
	main.pending_source = {"source": "ai"}
	var records: Array = await _send_as_ai(UNCLOSABLE)
	var refused := {}
	for r in records:
		var d: Dictionary = r
		if str(d.get("category", "")) == "FAILED_CLOSURE":
			refused = d
	_check(not refused.is_empty(),
		"the unclosable circuit is still refused FAILED_CLOSURE when it came from the model (got %s)" % str(_categories(records)))
	_check(bool(refused.get("revision_pending", false)),
		"and the record says a correction is on its way")

	# The handler's work, which nothing held before 056.
	_check(main.revising, "the revision handler put Genesis into the revising state")
	var attempt: Dictionary = main.pending_attempt
	_check(int(attempt.get("attempt", 0)) == 2,
		"and the next attempt is numbered 2 (got %s)" % str(attempt.get("attempt", "absent")))
	var of: Dictionary = attempt.get("revision_of", {})
	_check(not of.is_empty(), "and it carries what it is a revision OF")
	_check(str(of.get("feedback", "")) != "",
		"and the feedback Godot wrote for the model")

	# The numbers, against the record the refusal wrote rather than against a
	# constant: a handler that carried the wrong circuit's measurements would
	# pass an assertion written as a literal.
	var closure: Dictionary = refused.get("closure", {})
	var proposal: Dictionary = closure.get("proposal", {})
	_check(is_equal_approx(float(of.get("closure_distance", -1.0)),
			float(closure.get("closure_distance", -2.0))),
		"and the closure distance Godot measured, not a number of its own (%s against %s)" % [
			str(of.get("closure_distance", "absent")), str(closure.get("closure_distance", "absent"))])
	_check(is_equal_approx(float(of.get("proposal_distance", -1.0)),
			float(proposal.get("distance", -2.0))),
		"and the proposal's distance from the start line (%s against %s)" % [
			str(of.get("proposal_distance", "absent")), str(proposal.get("distance", "absent"))])
	_check(str(main.pending_source.get("revision", "")) != "",
		"and the next request is marked as a revision")
	notes.append("revision carried: closure %.1f m, proposal %.1f m from the start line" % [
		float(of.get("closure_distance", 0.0)), float(of.get("proposal_distance", 0.0))])

	# The handler blocks further requests until the correction lands, and
	# nothing else in this suite should inherit that.
	main.revising = false
	main.pending_attempt = {}
	main.pending_source = {}


# One level in from _send(): _handle_request() stamps every raw-JSON request
# {"source": "typed"} (main.gd:189), which is the whole reason this door had
# never been walked. Everything _execute_json does is the real path.
func _send_as_ai(json_text: String) -> Array:
	var before := _written().size()
	main._execute_json(json_text)
	await process_frame
	await process_frame
	return _since(before)


func _run() -> void:
	_make_main()
	await process_frame
	await process_frame

	print("--- the enumeration ---")
	_enumeration()
	print("--- the NO_DOOR rows ---")
	_no_door_rows()
	print("--- the load verdict, through /load ---")
	await _load_verdict()
	print("--- the false-refusal check, through an UNSUPPORTED answer ---")
	await _refusal_note()
	print("--- the solve step's refusal, through main.gd ---")
	await _solve_refusal()
	print("--- the tool readback's two halves ---")
	_tool_readback()
	print("--- the closure revision, through the controller's signal ---")
	await _revision_handler()

	WorldStore.remove_world(SAVED_AS)
	for note in notes:
		print("  ", note)
	print("CHECK WIRING %d assertions, failures=%d" % [asserted, bad])
	quit(bad)


# The CODE of a .gd source: comment lines blanked and trailing comments cut,
# with the line count preserved so a scan that reports a line number still
# reports the right one. A question about what the code DOES is answered from
# this. A question about what is MENTIONED anywhere is a different question
# and reads the raw file; which one a scan is asking is decided by the
# direction of its assertion and not by habit.
#
# WHY THIS EXISTS. 066 found that the first version of record_id_test's
# session scan was satisfied by a comment saying OS.get_process_id() in
# prose, and fixed it in that one function. 067 asked the same question of
# every source scan in tests/ and MEASURED three more, each flipped from FAIL
# to PASS by one comment line. See TRAPS 64.
#
# NOT A PARSER. A "#" inside a string literal cuts the line early, which can
# only lose a code match and never invent one - so this is safe in the one
# direction that matters: nothing a comment says can make a presence check
# pass.
static func _code_of(source: String) -> String:
	var out := ""
	for raw in source.split("\n"):
		var line := str(raw)
		if line.strip_edges().begins_with("#"):
			out += "\n"
			continue
		var hash_at := line.find("#")
		out += (line if hash_at < 0 else line.substr(0, hash_at)) + "\n"
	return out
