extends "res://tests/drive_test.gd"

# A scripted tester: builds, fails, asks for something impossible, changes a
# world, drives, races, loads, then ends the session. Every number in the
# report is checked against what the script did.

func _ai(json: String, request: String, source: Dictionary) -> void:
	main.pending_request = request
	main.pending_source = source
	main.pending_attempt = {"attempt": 1}
	main.editing_from = main.controller.last_build.duplicate(true)
	main._execute_json(json)
	await process_frame


func _log_lines() -> Array:
	var out: Array = []
	var f := FileAccess.open(TrackLog.PATH, FileAccess.READ)
	if f == null:
		return out
	while not f.eof_reached():
		var line := f.get_line().strip_edges()
		if line != "":
			out.append(JSON.parse_string(line))
	return out


func _run() -> void:
	if FileAccess.file_exists(TrackLog.PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TrackLog.PATH))
	_make_main()
	await process_frame
	await process_frame
	var c: GameController = main.controller
	var ai := {"source": "ai", "model": "test"}
	var farm := "{\"command\": \"CREATE_FARM\", \"parameters\": {\"zones\": [{\"type\": \"crop\", \"crop\": \"wheat\", \"width\": 80, \"depth\": 60}, {\"type\": \"barn\", \"width\": 20, \"depth\": 15}]}}"
	var rect := _track(_square(300, 60))
	var plan := "{\"command\": \"PLAN\", \"parameters\": {\"steps\": [%s, {\"command\": \"CREATE_TRACK\", \"around\": 1, \"parameters\": {\"mode\": \"circuit\", \"sections\": [%s]}}]}}" % [farm, ", ".join(_square(300, 60))]

	# Before any session: nothing tagged.
	await _ai(rect, "warm up", ai)
	main._run_local_command("/drive")
	main._stop_driving()

	main._run_local_command("/session end")
	_check(_history().contains("No session is running"), "/session end with nothing running says so")

	main._run_local_command("/session Sam Jones")
	_check(TrackLog.session.get("name", "") == "Sam Jones", "session started with a name containing a space")
	_check(c.last_build.is_empty() and c.has_drivable(), "a new session starts from the startup circuit, not the last tester's world")
	main._run_local_command("/session")
	_check(_history().contains("running since"), "/session alone reports the running session")

	await _ai("not json at all", "make me something", ai)                      # failed: parse
	main._on_interpretation_failed("The AI service is busy right now. (HTTP 503)")  # failed: AI down
	await _ai("{\"command\": \"UNSUPPORTED\", \"parameters\": {\"reason\": \"no boats\"}}", "a boat race", ai)  # cannot do
	await _ai(rect, "a rectangle track", ai)                                     # first world
	await _ai(_track(_square(400, 60)), "make it longer", {"source": "ai", "edit": "002E-edit-1"})  # a change
	# A design that misses the start line: asks for a correction, which then
	# fails too. Counted once, as one failed request.
	var open_track := _track([S % 300, "{\"type\": \"corner\", \"radius\": 60, \"angle\": 90}", S % 500, "{\"type\": \"corner\", \"radius\": 60, \"angle\": 90}",
		S % 100, "{\"type\": \"corner\", \"radius\": 60, \"angle\": 90}", S % 200, "{\"type\": \"corner\", \"radius\": 60, \"angle\": 90}"])
	await _ai(open_track, "a weird track", ai)
	main.revising = false
	main.pending_attempt = {"attempt": 2, "revision_of": {"time": "x", "proposed_metrics": {}}}
	main.pending_source = {"source": "ai", "revision": "test"}
	main._execute_json(open_track)
	await process_frame
	await _ai(plan, "a track around a farm", ai)                                 # plan: one request
	main._run_local_command("/drive")
	main._start_race(1)
	main.car.freeze = true
	main.car.global_position = Vector3(0, -200, 0)
	main._stop_driving()
	main._run_local_command("/save session-test")
	main._run_local_command("/load session-test")                                # a load, not a request
	await process_frame
	WorldStore.remove_world("session-test")

	var session_id: String = TrackLog.session["id"]
	main._run_local_command("/session end")
	var text := _history()
	print("---- report ----")
	print(text.substr(text.rfind("Session 'Sam Jones'")))
	print("----------------")

	var s := SessionReport.summarise(TrackLog.read_session(session_id))
	_check(TrackLog.session.is_empty(), "session ended")
	_check(int(s["requests"]) == 7, "7 requests counted (got %d)" % int(s["requests"]))
	_check(int(s["worlds_built"]) == 3, "3 worlds built: rectangle, longer, plan (got %d)" % int(s["worlds_built"]))
	_check(int(s["changes"]) == 1, "1 change to a world (got %d)" % int(s["changes"]))
	_check((s["failed"] as Array).size() == 3, "3 failed: bad JSON, AI busy, track that missed twice (got %d)" % (s["failed"] as Array).size())
	_check((s["cannot_do"] as Array).size() == 1 and str(s["cannot_do"][0][0]) == "a boat race", "1 thing Genesis cannot do: the boat race")
	_check(int(s["loads"]) == 1, "1 load (got %d)" % int(s["loads"]))
	_check(int(s["drove"]) == 1 and int(s["races_started"]) == 1, "drove once, started one race (drove %d, races %d)" % [int(s["drove"]), int(s["races_started"])])
	_check(str(s["first_world_request"]) == "a rectangle track" and float(s["seconds_to_first_world"]) >= 0.0, "first world is the rectangle")
	_check(bool(s["made_another"]), "made another: yes")

	# Every record written during the session carries the name; none before or after.
	var log_records := _log_lines()
	var before_tagged := 0
	var in_session := 0
	var untagged_in := 0
	var seen_start := false
	var seen_summary := false
	for r in log_records:
		var tagged: bool = typeof(r.get("session", null)) == TYPE_DICTIONARY
		if str(r.get("event", "")) == "session_start":
			seen_start = true
		if not seen_start and tagged:
			before_tagged += 1
		if seen_start and not seen_summary:
			in_session += 1
			if not tagged:
				untagged_in += 1
		if str(r.get("type", "")) == "session_summary":
			seen_summary = true
	_check(before_tagged == 0, "records before the session are not tagged, and no events were logged")
	_check(untagged_in == 0 and in_session > 10, "all %d records in the session are tagged with the tester" % in_session)
	_check(seen_summary, "the summary is saved in the log too")

	# After the session: back to untagged.
	await _ai(rect, "after", ai)
	var last: Dictionary = _log_lines()[-1]
	_check(not last.has("session"), "records after the session are not tagged")

	print("\n".join(lines))
	print("SESSION TEST failures=%d" % failures.size())
	quit(failures.size())
