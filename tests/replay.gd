extends SceneTree

# Replays every October record's raw_command through GameController and
# writes the records, log messages and closure feedback it produced.
# REPLAY_VIA_MODULE=1 sends CREATE_TRACK-with-sections through the generic
# world path (_create_world with the registered module) instead of execute().

var feedbacks: Array = []
var messages: Array = []

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
	var f := FileAccess.open(log_in, FileAccess.READ)
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
		controller.current_source = first.get("source", {})
		controller.current_experiment = first.get("experiment", {})
		var attempt := {"attempt": int(first.get("attempt", 1))}
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
