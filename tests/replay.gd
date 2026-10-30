extends SceneTree

# Replays every October record's raw_command through GameController and
# writes the records, log messages and closure feedback it produced.
# REPLAY_VIA_MODULE=1 sends CREATE_TRACK-with-sections through the generic
# world path (_create_world with the registered module) instead of execute().

var feedbacks: Array = []
var messages: Array = []


# --- 099a: REPLAY_LOG is a file, so every field in it is whatever it says ---
#
# 099 closed this class in scripts/session_report.gd, the one consumer of the
# ledger there. ITS GREP WAS OVER `scripts/`, AND THE RULE IS NOT ABOUT A
# DIRECTORY: it is "a reader of a record that came off a FILE converts rather
# than assumes". This file is the other member. Its input is named from
# OUTSIDE the process by REPLAY_LOG, so it is not even the ledger this game
# wrote - it is whatever file the owner pointed it at.
#
# AND WHAT IT COST HERE IS NOT WHAT IT COST THERE. In session_report a type
# error abandoned summarise() and left an empty report. Here it abandons
# _initialize(), AND A SCRIPT ERROR IN A SceneTree ABORTS _initialize BEFORE
# quit() IS EVER REACHED - so this tool did not fail, it HUNG until the
# harness's 600 s timeout killed it. That is the exact fault the comment
# thirty lines below describes, and TRAPS 13 is about, reached in this same
# file by a different field.
#
# MEASURED on 867d89b, each field alone with its own throwaway copy and its
# own config/name, three fields against six types - ELEVEN OF EIGHTEEN RUNS
# CAME BACK rc=124 WITH NOTHING WRITTEN:
#
#   source      null, a string, an array, a number    rc=124, hung
#   experiment  null, a string, an array, a number    rc=124, hung
#   attempt     null, an array, a dictionary          rc=124, hung
#   attempt     a string                              rc=0, AND REPLAYED
#                                                     EVERY GROUP AS ATTEMPT
#                                                     0, because int("x") is 0
#
# The types come from the WRITERS, read off game_controller.gd rather than
# chosen: `record["source"] = current_source` and
# `record["experiment"] = current_experiment` at :205 and :206 are both typed
# `Dictionary` members, and `record["attempt"] = int(...)` at :644 is an int
# when written and a FLOAT when read back, because JSON has one number type
# and GDScript has two. That is the same pair session_report.gd's own
# "player_place" row carries, for the same reason.
#
# ONE TABLE AND ONE READER, in the shape 099 settled on, so the three cannot
# be held at two of three (TRAPS 11). It is a SECOND copy of that shape and
# not a call into the first, deliberately: SessionReport.FIELD_TYPES names the
# four fields SUMMARISE reads and its suite asserts exactly that
# correspondence by scanning the source, so adding these three to it would
# break that assertion; and `tests/` has no shared library, which is this
# project's settled convention (TRAPS 89, and source_scan_test's own header).
#
# --- 100: THE CLASS IN THIS FILE WAS FOUR, AND THE FOURTH WAS READ BY INDEX
#          RATHER THAN BY .get(), WHICH IS WHY 099a's GREP WALKED PAST IT ---
#
# 099a put three fields in the table and wrote "Three reads" in this header.
# The fourth is `revision_of`, which this file read as `first["revision_of"]`
# behind a `first.has()` guard - a BARE INDEX, not a `.get()`, so a grep for
# the shape 099a was fixing could not see it. It went into current_attempt
# untyped, so nothing threw at the door; it threw one process later, in
# scripts/.
#
# MEASURED on e1c9b6d BEFORE ANYTHING HERE WAS CHANGED, the same way: one
# real October CREATE_TRACK record carrying a real revision_of (attempt 2),
# each type alone in its own throwaway copy with its own config/name
# (TRAPS 50, 80, 88). FIVE OF FIVE WRONG TYPES CAME BACK rc=124 WITH NOTHING
# WRITTEN - the SAME COST as the three above:
#
#   revision_of  a dictionary (control)   rc=0,   REPLAY_OUT 20,281 bytes
#   revision_of  null                     rc=124, nothing written
#   revision_of  a string                 rc=124, nothing written
#   revision_of  an array                 rc=124, nothing written
#   revision_of  a number                 rc=124, nothing written
#   revision_of  a bool                   rc=124, nothing written
#
# AND THE BACKTRACE NAMES WHERE, so this is not inferred. The first error is
#   RacingModule.pre_check (res://scripts/racing_module.gd:151)
# which does `record["revision_of"].get("proposed_metrics", {})`, and it is
# reached because game_controller.gd:656-657 copies current_attempt's
# revision_of straight onto the record. The error then ABANDONS pre_check,
# which is TRAPS 96's shape: the caller read the {} it was handed as an
# answer and the second error is
#   GameController._prepare_world (res://scripts/game_controller.gd:1196)
# on `['ok']`. _initialize never reaches quit(), so the tool HANGS.
#
# THE DOOR IS HERE AND NOT IN scripts/. racing_module.gd:151 is right by the
# grace of its writers for every in-process path - main.gd:402 builds that
# dictionary - and the only way a non-Dictionary reaches it is a FILE read by
# this tool. So this file converts, and racing_module.gd is 0 lines of diff
# and is left as defence in depth, said out loud for the same reason 099a
# said it of game_controller.gd:644 (TRAPS 11).
#
# AND THESE FOUR READS ARE NOW HELD BY A SUITE IN A FULL RUN, which is what
# 099a's own live entry asked for: tests/field_type_test.gd drives _field()
# and _attempt_of() over every field in the table against every value a
# hand-edited JSON file can hold, and asserts the call sites in THIS file go
# through them. That is why both are static; see _field() below.
const FIELD_TYPES := {
	"source": [TYPE_DICTIONARY],
	"experiment": [TYPE_DICTIONARY],
	"attempt": [TYPE_INT, TYPE_FLOAT],
	"revision_of": [TYPE_DICTIONARY],
}


# One field of one record, read as the default the call site names unless its
# type is one FIELD_TYPES admits. A field that is PRESENT and of a type the
# table does not admit is appended to `damaged`; an ABSENT field is not
# damage, it is a record that does not carry it. That distinction is 099's,
# and the reason is 099's: silently reading damage as absence trades a loud
# empty answer for a quietly wrong one.
#
# static, WITH `damaged` AS AN OUT-PARAMETER RATHER THAN A MEMBER, for two
# reasons said out loud. The accounting has to live in the ONE reader or it is
# at four call sites (TRAPS 11). And a static function can be driven by a
# suite WITHOUT instantiating this SceneTree: tests/field_type_test.gd calls
# it directly, which is the thing that holds these reads in a full run. An
# instance works - measured, 100 - but leaks a second SceneTree's RIDs at
# exit, and that noise would sit in the output of a suite that passes.
static func _field(r: Dictionary, field: String, fallback: Variant, damaged: Array) -> Variant:
	if not r.has(field):
		return fallback
	var value: Variant = r[field]
	if not (FIELD_TYPES[field] as Array).has(typeof(value)):
		damaged.append({"field": field, "type": type_string(typeof(value))})
		return fallback
	return value


# The dictionary assigned to controller.current_attempt, which is where two of
# the four fields live.
#
# A record with NO "attempt" key gets {}, including when it carries
# revision_of - that is what this file did before 100 and it is kept, because
# current_attempt is the attempt and a revision of nothing is not one.
#
# AND A revision_of THE TABLE DOES NOT ADMIT IS LEFT OUT rather than passed
# on as {}. An empty dictionary here would still satisfy record.has(
# "revision_of") at game_controller.gd:656, reach
# RacingModule._compare_designs through racing_module.gd:151, and produce a
# revision_comparison against a proposal that was never read - a number in
# the owner's own output that is not evidence. Absent says "not a revision",
# and `damaged` says why it is absent.
static func _attempt_of(r: Dictionary, damaged: Array) -> Dictionary:
	if not r.has("attempt"):
		return {}
	var out := {"attempt": int(_field(r, "attempt", 1, damaged))}
	var revision: Variant = _field(r, "revision_of", null, damaged)
	if typeof(revision) == TYPE_DICTIONARY:
		out["revision_of"] = revision
	return out


func _initialize() -> void:
	var out_path: String = OS.get_environment("REPLAY_OUT")
	var log_in: String = OS.get_environment("REPLAY_LOG")
	var via_module := OS.get_environment("REPLAY_VIA_MODULE") == "1"
	var log_path := ProjectSettings.globalize_path("user://track_log.jsonl")
	if FileAccess.file_exists(log_path):
		DirAccess.remove_absolute(log_path)

	var root3d := Node3D.new()
	get_root().add_child(root3d)
	var controller: GameController = GameController.new()
	root3d.add_child(controller)
	controller.setup(root3d)
	controller.log_message.connect(func(t): messages.append(t))
	controller.revision_requested.connect(func(fb, rec): feedbacks.append({"feedback": fb, "category": rec.get("category", "")}))

	var originals: Array = []
	# REPLAY_LOG unset, or naming a file that is not there, used to reach
	# f.eof_reached() on a null and throw - and a script error in a SceneTree
	# aborts _initialize before quit(), so this tool hung until the harness's
	# 600 s timeout instead of failing. Same fault as report_test's; see
	# TRAPS 13. Say what is missing and leave.
	var f := FileAccess.open(log_in, FileAccess.READ) if log_in != "" else null
	if f == null:
		push_error("replay.gd needs REPLAY_LOG to name a readable record file"
			+ (" (REPLAY_LOG is unset)" if log_in == "" else " (cannot open '%s')" % log_in))
		quit(1)
		return
	if out_path == "":
		push_error("replay.gd needs REPLAY_OUT to name where to write")
		quit(1)
		return
	while not f.eof_reached():
		var line := f.get_line().strip_edges()
		if line == "":
			continue
		var r = JSON.parse_string(line)
		if typeof(r) == TYPE_DICTIONARY and str(r.get("time", "")).begins_with("2026-10"):
			originals.append(r)
	f.close()

	# One group per execution: a plan's step records and its PLAN record
	# share one raw command, so they are collected until the PLAN record.
	var groups: Array = []
	var open_plan := false
	for r in originals:
		if open_plan:
			groups[-1].append(r)
		else:
			groups.append([r])
		var raw = JSON.parse_string(str(r.get("raw_command", "")))
		var is_plan_raw: bool = typeof(raw) == TYPE_DICTIONARY and str(raw.get("command", "")).to_upper() == "PLAN"
		open_plan = is_plan_raw and str(r.get("command", "")) != "PLAN"

	var results: Array = []
	var lines_before := 0
	var damaged: Array = []
	var group_index := 0
	for g in groups:
		var first: Dictionary = g[0]
		feedbacks = []
		messages = []
		controller.current_request = str(first.get("request", ""))
		controller.current_raw = str(first.get("raw_command", ""))
		# FOUR reads of a record off a FILE, through the one reader and the
		# one table 099 settled on in session_report.gd. 099a wrote three
		# here; `revision_of` is the fourth and lives inside _attempt_of().
		# See the header above FIELD_TYPES for what each cost before, and
		# for the backtrace that names where the fourth one threw.
		var mine: Array = []
		controller.current_source = _field(first, "source", {}, mine)
		controller.current_experiment = _field(first, "experiment", {}, mine)
		controller.current_attempt = _attempt_of(first, mine)
		for d in mine:
			(d as Dictionary)["group"] = group_index
			damaged.append(d)
		var parsed := CommandParser.parse(controller.current_raw)
		if parsed["unsupported"]:
			controller.record_rejection("UNSUPPORTED", str(parsed["error"]))
		elif not parsed["ok"]:
			controller.record_rejection("FAILED_PARSE", str(parsed["error"]))
		elif via_module and parsed["command"] == "CREATE_TRACK" and (parsed["parameters"] as Dictionary).has("sections"):
			controller._create_world(WorldRegistry.find("CREATE_TRACK"), parsed["parameters"])
		else:
			controller.execute(parsed["command"], parsed["parameters"])
		await process_frame
		var produced: Array = []
		var lf := FileAccess.open(log_path, FileAccess.READ)
		var n := 0
		while not lf.eof_reached():
			var line := lf.get_line()
			if line.strip_edges() == "":
				continue
			if n >= lines_before:
				produced.append(JSON.parse_string(line))
			n += 1
		lf.close()
		lines_before = n
		results.append({"original": g, "produced": produced, "feedbacks": feedbacks.duplicate(), "messages": messages.duplicate(), "last_build_command": controller.last_build.get("command", "")})
		group_index += 1

	var prompt := AIInterpreter.SYSTEM_PROMPT + "\n\nOTHER WORLDS YOU CAN BUILD\n" + WorldRegistry.prompt_sections()
	var out := FileAccess.open(out_path, FileAccess.WRITE)
	out.store_string(JSON.stringify({"groups": results, "prompt": prompt, "allowed": CommandParser.allowed_commands(), "damaged": damaged}))
	out.close()
	# The damage count is PRINTED and not only written, because the file is
	# read by compare.py and the person running the tool reads the terminal.
	# "damaged=" is not one of the two verdict words the runners match on
	# ("failures=", "bad="), so this file stays out of result_line_test's
	# class exactly as its NO_RESULT_LINE row at line 89 says.
	print("REPLAY DONE groups=%d damaged=%d" % [groups.size(), damaged.size()])
	for d in damaged:
		print("  DAMAGED group %s field \"%s\" was a %s, read as the default" % [
			str((d as Dictionary).get("group", "?")), str((d as Dictionary).get("field", "?")),
			str((d as Dictionary).get("type", "?"))])
	quit(0)
