extends SceneTree

# Builds main.gd with a stand-in for the UI scene, then plays the game the way
# the owner does: raw JSON typed into the box, /drive, /race. Runs with
# --fixed-fps 120. Results go into member variables (lambdas copy locals).

var main: Node3D
var lines: Array = []
var failures: Array = []
var race_results: Array = []

const S := "{\"type\": \"straight\", \"length\": %d}"


func _initialize() -> void:
	_run.call_deferred()


func _check(ok: bool, what: String) -> void:
	lines.append(("PASS  " if ok else "FAIL  ") + what)
	if not ok:
		failures.append(what)


func _make_main() -> void:
	main = Node3D.new()
	main.name = "Main"
	main.set_script(load("res://scripts/main.gd"))
	var cam := Camera3D.new()
	cam.name = "Camera3D"
	cam.position = Vector3(0, 80, 120)
	main.add_child(cam)
	var ground := Node3D.new()
	ground.name = "Ground"
	main.add_child(ground)
	var box := CSGBox3D.new()
	box.name = "CSGBox3D"
	box.size = Vector3(200, 1, 200)
	box.position = Vector3(0, -0.5, 0)
	box.use_collision = true
	ground.add_child(box)
	var ui := CanvasLayer.new()
	ui.name = "UI"
	main.add_child(ui)
	var panel := PanelContainer.new()
	panel.name = "CommandPanel"
	ui.add_child(panel)
	var vb := VBoxContainer.new()
	vb.name = "VBoxContainer"
	panel.add_child(vb)
	for pair in [["InputBox", LineEdit.new()], ["BuildButton", Button.new()], ["StatusLabel", Label.new()]]:
		pair[1].name = pair[0]
		vb.add_child(pair[1])
	get_root().add_child(main)


func _type(text: String) -> void:
	main._handle_request(text)
	await process_frame
	await process_frame


func _track(sections: Array, extra := "") -> String:
	return "{\"command\": \"CREATE_TRACK\", \"parameters\": {\"mode\": \"circuit\"%s, \"sections\": [%s]}}" % [extra, ", ".join(sections)]


func _square(length: int, radius: int, corner := "corner", bank := "") -> Array:
	var out: Array = []
	for i in 4:
		out.append(S % length)
		out.append("{\"type\": \"%s\", \"radius\": %d, \"angle\": 90%s}" % [corner, radius, bank])
	return out


func _drivable() -> bool:
	var c = main.controller
	if c.has_method("has_drivable"):
		return c.has_drivable()
	return c.circuit_builder.built


func _circuit_node() -> Node3D:
	var c = main.controller
	if c.has_method("has_drivable"):
		return c.drivable["node"]
	return c.circuit_builder


func _world_children() -> int:
	var n := 0
	for c in main.controller.world_node.get_children():
		if not c.is_queued_for_deletion():
			n += 1
	return n


func _history() -> String:
	return main.history_log.get_parsed_text()


func _race(label: String, json: String, opponents: int) -> void:
	await _type(json)
	main._start_race(opponents)
	var director: RaceDirector = main.race
	# Nobody drives the player's car in a headless test. Left parked on the
	# road it blocks the opponents for ever, so it waits out of the way.
	# PARK=1 leaves it parked on the grid instead, like a tester who stopped.
	if OS.get_environment("PARK") == "":
		main.car.freeze = true
		main.car.global_position = Vector3(0.0, -200.0, 0.0)
	var laps_needed := 2
	var frames := 0
	var limit := 120 * 60 * 6
	while frames < limit:
		await physics_frame
		frames += 1
		var done := true
		for i in range(1, director.racers.size()):
			if int(director.racers[i]["lap"]) < laps_needed:
				done = false
		if done:
			break
	var laps: Array = []
	var recoveries := 0
	var where := []
	for i in range(1, director.racers.size()):
		laps.append(int(director.racers[i]["lap"]))
		recoveries += int(director.racers[i]["recoveries"])
		var car: Car = director.racers[i]["car"]
		where.append("%s r%d at (%.0f,%.1f,%.0f) idx %d" % [director.racers[i]["name"], int(director.racers[i]["recoveries"]), car.global_position.x, car.global_position.y, car.global_position.z, int(director.racers[i]["index"])])
	var ok := laps.size() == opponents and laps.all(func(l): return l >= laps_needed)
	race_results.append("%-22s opponents %d  laps %s  recoveries %d  sim %.0f s  %s" % [label, opponents, str(laps), recoveries, frames / 120.0, "; ".join(where)])
	_check(ok, "%s: every opponent completed %d laps" % [label, laps_needed])
	director.stop()
	main._stop_driving()


func _run() -> void:
	_make_main()
	await process_frame
	await process_frame
	var c: GameController = main.controller
	if OS.get_environment("ONLY_PLAN") != "":
		var farm0 := "{\"command\": \"CREATE_FARM\", \"parameters\": {\"zones\": [{\"type\": \"crop\", \"crop\": \"wheat\", \"width\": 80, \"depth\": 60}, {\"type\": \"barn\", \"width\": 20, \"depth\": 15}]}}"
		var plan0 := "{\"command\": \"PLAN\", \"parameters\": {\"steps\": [%s, {\"command\": \"CREATE_TRACK\", \"around\": 1, \"parameters\": {\"mode\": \"circuit\", \"sections\": [%s]}}]}}" % [farm0, ", ".join(_square(300, 60))]
		for k in int(OS.get_environment("ONLY_PLAN")):
			await _race("plan run %d" % (k + 1), plan0, 2)
			for car in main.race.opponents:
				pass
		print("\n".join(race_results))
		quit(0)
		return

	# Startup circuit: drivable, but not remembered as the player's world.
	_check(_drivable(), "startup circuit can be driven")
	_check(c.last_build.is_empty(), "startup circuit is not the player's world (first request is not an edit)")
	_check(main.checkpoint_tracker != null and main._track_centreline().size() > 20, "startup circuit has a centreline")

	# A farm replaces the startup circuit; there is nothing to drive.
	var farm := "{\"command\": \"CREATE_FARM\", \"parameters\": {\"zones\": [{\"type\": \"crop\", \"crop\": \"wheat\", \"width\": 80, \"depth\": 60}, {\"type\": \"barn\", \"width\": 20, \"depth\": 15}]}}"
	await _type(farm)
	_check(not _drivable(), "after a farm, nothing to drive")
	_check(_world_children() >= 1 and c.world_node.get_child(c.world_node.get_child_count() - 1).name != "CircuitBuilder", "farm is on screen")
	main._start_driving()
	_check(not main.driving and _history().contains("Build a track first"), "/drive on a farm is refused politely")

	# A track replaces the farm (the change agreed for 002F).
	var rect := _track(_square(300, 60))
	await _type(rect)
	var names := []
	for ch in c.world_node.get_children():
		if not ch.is_queued_for_deletion():
			names.append(str(ch.name))
	_check(names == ["CircuitBuilder"], "a track built after a farm replaces it (on screen: %s)" % str(names))
	_check(_drivable() and c.last_build.get("command", "") == "CREATE_TRACK", "the track is drivable and is the player's world")

	# Driving, and a change while driving puts the car back on the start line.
	main._start_driving()
	_check(main.driving, "/drive starts")
	for i in 120:
		await physics_frame
	var longer := _track(_square(400, 60))
	main.editing_from = c.last_build.duplicate(true)
	await _type(longer)
	main.editing_from = c.last_build.duplicate(true)
	var hist := _history()
	_check(main.car.global_position.distance_to(main._track_start()) < 3.0, "changing the track while driving puts the car on the new start line")
	main._stop_driving()

	# Play loop "Changed:" report (main compares before and after builds).
	main.editing_from = c.last_build.duplicate(true)
	main.pending_source = {"source": "ai"}
	main._execute_json(_track(_square(500, 60)))
	await process_frame
	_check(_history().contains("Changed: length"), "play loop reports what changed")

	# A plan: track around a farm. Driving uses where the circuit really stands.
	var plan := "{\"command\": \"PLAN\", \"parameters\": {\"steps\": [%s, {\"command\": \"CREATE_TRACK\", \"around\": 1, \"parameters\": {\"mode\": \"circuit\", \"sections\": [%s]}}]}}" % [farm, ", ".join(_square(300, 60))]
	await _type(plan)
	var moved: Vector3 = _circuit_node().global_position
	_check(_world_children() == 2, "plan: farm and track both on screen")
	_check(moved.length() > 1.0, "plan: the track was moved to surround the farm (%.0f, %.0f)" % [moved.x, moved.z])
	_check(main._track_start().distance_to(moved + Vector3(0, CircuitBuilder.ROAD_HEIGHT, 0)) < 0.01, "plan: driving starts where the moved track really is")
	await _race("track around a farm", plan, 2)

	# /save and /load round trip.
	await _type(rect)
	main._save_world("/save step3-test")
	await _type(farm)
	main._load_world("/load step3-test")
	await process_frame
	_check(_drivable() and c.last_build.get("command", "") == "CREATE_TRACK", "/load rebuilds a saved track")
	WorldStore.remove_world("step3-test")

	# CLEAR_WORLD leaves nothing to drive.
	await _type("{\"command\": \"CLEAR_WORLD\", \"parameters\": {}}")
	_check(not _drivable() and _world_children() == 0, "CLEAR_WORLD leaves nothing")

	# Races on the five reference tracks.
	await _race("rectangle", rect, 3)
	await _race("technical with chicane", _track([S % 250, "{\"type\": \"corner\", \"radius\": 40, \"angle\": 90}", S % 120,
		"{\"type\": \"chicane\", \"radius\": 30, \"offset\": 15, \"direction\": \"left\"}", S % 120, "{\"type\": \"corner\", \"radius\": 30, \"angle\": 90}",
		S % 250, "{\"type\": \"corner\", \"radius\": 40, \"angle\": 90}", S % 240, "{\"type\": \"corner\", \"radius\": 30, \"angle\": 90}"]), 3)
	await _race("round", _track(_square(30, 120)), 3)
	await _race("banked square", _track(_square(250, 70, "banked_corner", ", \"bank\": 12")), 3)
	await _race("high speed", _track(_square(700, 200)), 3)

	print("\n".join(lines))
	print("RACES")
	print("\n".join(race_results))
	print("DRIVE TEST failures=%d" % failures.size())
	quit(failures.size())
