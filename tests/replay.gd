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
const FIELD_TYPES := {
	"source": [TYPE_DICTIONARY],
	"experiment": [TYPE_DICTIONARY],
	"attempt": [TYPE_INT, TYPE_FLOAT],
}


# One field of one record, read as the default the call site names unless its
# type is one FIELD_TYPES admits.
func _field(r: Dictionary, field: String, fallback: Variant) -> Variant:
	if not r.has(field):
		return fallback
	var value: Variant = r[field]
	if not (FIELD_TYPES[field] as Array).has(typeof(value)):
		return fallback
	return value


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
	for g in groups:
		var first: Dictionary = g[0]
		feedbacks = []
		messages = []
		controller.current_request = str(first.get("request", ""))
		controller.current_raw = str(first.get("raw_command", ""))
		# 099a: three reads of a record off a FILE, through the same reader
		# and the same kind of table 099 put in session_report.gd. See the
		# header above FIELD_TYPES for what these cost before.
		controller.current_source = _field(first, "source", {})
		controller.current_experiment = _field(first, "experiment", {})
		var attempt := {"attempt": int(_field(first, "attempt", 1))}
		if first.has("revision_of"):
			attempt["revision_of"] = first["revision_of"]
		controller.current_attempt = attempt if first.has("attempt") else {}
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

	var prompt := AIInterpreter.SYSTEM_PROMPT + "\n\nOTHER WORLDS YOU CAN BUILD\n" + WorldRegistry.prompt_sections()
	var out := FileAccess.open(out_path, FileAccess.WRITE)
	out.store_string(JSON.stringify({"groups": results, "prompt": prompt, "allowed": CommandParser.allowed_commands()}))
	out.close()
	print("REPLAY DONE groups=%d" % groups.size())
	quit(0)
