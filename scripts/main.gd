extends Node3D

# --- Prototype 002B: driving with lap timing and checkpoint HUD ---
# --- 002C: closure feedback. A circuit that misses the start line gets one
#     visible correction from the AI; /revise off turns it off. ---
# The AI proposes. Godot constructs. Godot validates. The player sees both.

const SUPPORTED_HELP := "I can: design a closed race track from your description, or clear the world."

@onready var input_box: LineEdit = $UI/CommandPanel/VBoxContainer/InputBox
@onready var build_button: Button = $UI/CommandPanel/VBoxContainer/BuildButton
@onready var status_label: Label = $UI/CommandPanel/VBoxContainer/StatusLabel
@onready var ui_layer: CanvasLayer = $UI

var controller: GameController
var interpreter: AIInterpreter
var experiment: ExperimentRunner
var checkpoint_tracker: CheckpointTracker
var car: Car
var driving := false
var history_log: RichTextLabel
var metrics_log: RichTextLabel

# The player text currently being processed, so results can be matched to it.
var pending_request: String = ""
# Where the pending command came from: typed by hand, or composed by the AI.
var pending_source: Dictionary = {}
# Which experiment run and trial the pending command belongs to, if any.
var pending_experiment: Dictionary = {}
# Which attempt the pending command is: first try, or the one correction.
var pending_attempt: Dictionary = {}
# True from the moment a correction is asked for until the AI answers.
var revising := false

# A short pause before the correction, so two requests don't arrive at the
# AI back to back (the free tier limits how fast requests may come).
const REVISION_DELAY := 4.0


func _ready() -> void:
	# The panels are built first: the controller reports as soon as it starts,
	# and there must be somewhere to write that.
	_build_history_panel()
	_build_metrics_panel()

	controller = GameController.new()
	add_child(controller)
	controller.log_message.connect(_on_controller_log)
	controller.setup(self)

	interpreter = AIInterpreter.new()
	add_child(interpreter)
	interpreter.interpretation_ready.connect(_on_interpretation_ready)
	interpreter.interpretation_failed.connect(_on_interpretation_failed)

	controller.track_measured.connect(_on_track_measured)
	controller.revision_requested.connect(_on_revision_requested)

	experiment = ExperimentRunner.new()
	add_child(experiment)
	experiment.setup(self, controller, interpreter)
	experiment.progress.connect(_on_experiment_progress)
	experiment.finished.connect(_on_experiment_finished)

	checkpoint_tracker = CheckpointTracker.new()
	add_child(checkpoint_tracker)
	checkpoint_tracker.lap_completed.connect(_on_lap_completed)

	build_button.pressed.connect(_on_build_pressed)
	input_box.text_submitted.connect(_on_text_submitted)

	if interpreter.is_available():
		status_label.text = "Status: Ready. Tell me what you want."
	else:
		status_label.text = "Status: No API key. Raw JSON only."

	# A fast car can pass straight through a barrier between physics steps,
	# so the simulation runs more often than the screen refreshes.
	Engine.physics_ticks_per_second = 120

	print("Main ready. AI pipeline and history active.")
	print("Track log: ", TrackLog.location())

	_build_startup_track()


# A small circuit with a hill in it, so there is something to drive before the
# AI is asked for anything. It uses the controller's builder: there is no
# CircuitBuilder node in the scene, the controller creates its own.
func _build_startup_track() -> void:
	var test_sections := [
		{"type": "straight", "length": 200.0},
		{"type": "corner", "radius": 60.0, "angle": 90.0},
		{"type": "uphill", "length": 120.0, "grade": 8.0},
		{"type": "crest", "length": 80.0, "grade": 5.0},
		{"type": "downhill", "length": 120.0, "grade": 8.0},
		{"type": "corner", "radius": 60.0, "angle": 90.0},
		{"type": "straight", "length": 200.0},
		{"type": "corner", "radius": 60.0, "angle": 90.0},
		{"type": "straight", "length": 320.0},
		{"type": "corner", "radius": 60.0, "angle": 90.0},
	]

	if controller.circuit_builder == null:
		return

	var report := controller.circuit_builder.build(test_sections, false)
	controller._frame_view(report["bounds_min"], report["bounds_max"])
	checkpoint_tracker.initialize(controller.circuit_builder.centreline)
	_record("startup track", "Built a test circuit with a hill. Type /drive to drive it.", "ok")


func _on_build_pressed() -> void:
	_handle_request(input_box.text)


func _on_text_submitted(_submitted_text: String) -> void:
	_handle_request(input_box.text)


func _handle_request(raw_request: String, experiment_context: Dictionary = {}) -> void:
	var request := raw_request.strip_edges()

	if request == "":
		status_label.text = "Status: Type something first."
		return

	# Commands for the game itself, not for the AI.
	if request.begins_with("/"):
		_run_local_command(request)
		return

	if revising:
		status_label.text = "Waiting for the AI's correction..."
		return

	if experiment.running and experiment_context.is_empty():
		status_label.text = "An experiment is running. Type /stop to end it."
		return

	pending_experiment = experiment_context

	# Don't accept a new request while the AI is still answering the last one.
	if interpreter.busy:
		status_label.text = "Still thinking about the last request..."
		return

	pending_request = request
	pending_attempt = {"attempt": 1}
	print("Player input: ", request)
	input_box.text = ""

	# Raw JSON still works - useful for debugging without spending API calls.
	if request.begins_with("{"):
		pending_source = {"source": "typed"}
		_execute_json(request)
		return

	if not interpreter.is_available():
		status_label.text = "No API key - type raw JSON instead."
		_record(request, "No API key - type raw JSON instead.", "error")
		return

	status_label.text = "Designing..."
	pending_source = interpreter.describe()
	interpreter.interpret(request)


func _on_interpretation_ready(json_text: String) -> void:
	revising = false
	_execute_json(json_text)


func _on_interpretation_failed(reason: String) -> void:
	revising = false
	status_label.text = reason
	print("AI FAILED: ", reason)
	_record(pending_request, reason, "error")


func _on_controller_log(text: String) -> void:
	# Status line shows only the first line; the history panel shows everything.
	status_label.text = "Executed: " + text.split("\n")[0]
	print("Controller: ", text)
	var kind := "error" if text.contains("failed") else "ok"
	_record(pending_request, text, kind)

	# A new circuit means new checkpoints.
	if kind == "ok" and controller.circuit_builder and controller.circuit_builder.built:
		checkpoint_tracker.initialize(controller.circuit_builder.centreline)


# Every command reaches the game through here - AI or hand-typed, no difference.
func _execute_json(json_text: String) -> void:
	# So the record keeps what was asked and exactly what was sent, even when
	# the answer is refused before it becomes a command.
	controller.current_request = pending_request
	controller.current_raw = json_text
	controller.current_source = pending_source
	controller.current_experiment = pending_experiment
	controller.current_attempt = pending_attempt

	var parsed := CommandParser.parse(json_text)

	# The AI honestly said it can't do this. Explain, don't execute.
	if parsed["unsupported"]:
		status_label.text = "I don't know how to do that yet."
		print("UNSUPPORTED: ", parsed["error"])
		_record(pending_request, "Not supported yet: " + str(parsed["error"]) + "\n" + SUPPORTED_HELP, "unsupported")
		controller.record_rejection("UNSUPPORTED", str(parsed["error"]))
		return

	if not parsed["ok"]:
		status_label.text = "Rejected: " + str(parsed["error"])
		print("REJECTED: ", parsed["error"])
		_record(pending_request, "REJECTED: " + str(parsed["error"]), "error")
		controller.record_rejection("FAILED_PARSE", str(parsed["error"]))
		return

	controller.execute(parsed["command"], parsed["parameters"])


# --- closure feedback ---

# The first attempt missed the start line. Show the player, then ask the AI
# once more with what Godot measured. The answer arrives through
# _on_interpretation_ready like any other, and is checked like any other.
func _on_revision_requested(feedback: String, record: Dictionary) -> void:
	var closure: Dictionary = record.get("closure", {})
	var proposal: Dictionary = closure.get("proposal", {})
	_record(pending_request, "First attempt ended %.0f m from the start line (%.0f m after adjusting). Asking the AI for one correction..." % [
		float(proposal.get("distance", 0.0)), float(closure.get("closure_distance", 0.0))], "unsupported")
	status_label.text = "Revising..."

	pending_attempt = {
		"attempt": 2,
		"revision_of": {
			"time": record.get("time", ""),
			"category": record.get("category", ""),
			"closure_distance": closure.get("closure_distance", 0.0),
			"proposal_distance": proposal.get("distance", 0.0),
			"proposal_net_turn": proposal.get("net_turn", 0.0),
			"proposed_metrics": record.get("proposed_metrics", {}),
			"feedback": feedback,
		},
	}
	pending_source = interpreter.describe_revision()
	revising = true

	await get_tree().create_timer(REVISION_DELAY).timeout
	if not revising:
		return
	interpreter.revise(pending_request, feedback)


# --- Commands for the game itself ---

func _run_local_command(request: String) -> void:
	var parts := request.split(" ", false)
	var command := parts[0].to_lower()

	match command:
		"/experiment":
			var count := 20
			if parts.size() > 1 and parts[1].is_valid_int():
				count = parts[1].to_int()
			var reply := experiment.start(count)
			status_label.text = reply.split("\n")[0]
			_record(request, reply, "ok")
		"/stop":
			var reply := experiment.stop()
			status_label.text = reply
			_record(request, reply, "ok")
		"/status":
			var reply := experiment.status()
			status_label.text = reply
			_record(request, reply, "ok")
		"/drive":
			_start_driving()
		"/view":
			_stop_driving()
		"/save":
			_save_world(request)
		"/load":
			_load_world(request)
		"/worlds":
			_list_worlds()
		"/delete":
			_delete_world(request)
		"/revise":
			var setting := parts[1].to_lower() if parts.size() > 1 else ""
			if setting == "on" or setting == "off":
				controller.revision_enabled = setting == "on"
			var reply := "Closure feedback is %s. Type /revise on or /revise off to change it." % ("on: a circuit that misses the start line gets one correction from the AI" if controller.revision_enabled else "off: every circuit gets one attempt, as before")
			status_label.text = reply
			_record(request, reply, "ok")
		"/log":
			var reply := "Track log: " + TrackLog.location()
			status_label.text = "Track log location written to the history."
			_record(request, reply, "ok")
		_:
			var help := "Game commands: /save [name], /load [name], /worlds, /delete [name], /drive, /view, /experiment [count], /stop, /status, /revise [on|off], /log"
			status_label.text = help
			_record(request, help, "unsupported")


# --- saved worlds ---

func _save_world(request: String) -> void:
	if controller.last_build.is_empty():
		status_label.text = "Build something first, then /save a-name."
		_record(request, "There is nothing built to save yet.", "error")
		return

	var name := request.substr(5).strip_edges()
	var result := WorldStore.save_world(
		name,
		str(controller.last_build["command"]),
		controller.last_build["parameters"],
		controller.last_build.get("metrics", {}),
		str(controller.last_build.get("request", "")))
	status_label.text = result["message"]
	_record(request, result["message"], "ok" if result["ok"] else "error")


func _load_world(request: String) -> void:
	var name := request.substr(5).strip_edges()
	var result := WorldStore.load_world(name)
	if not result["ok"]:
		status_label.text = result["message"]
		_record(request, result["message"], "error")
		return

	var world: Dictionary = result["world"]
	var command := str(world["command"]).to_upper()

	# A saved world is checked exactly like a new one: nothing is trusted
	# just because it came from a file.
	if not command in CommandParser.allowed_commands():
		var refusal := "'%s' is not a command this game has. The saved world cannot be built." % command
		status_label.text = refusal
		_record(request, refusal, "error")
		return

	pending_request = "load " + str(world.get("name", name))
	pending_source = {"source": "saved", "saved": world.get("saved", "")}
	pending_experiment = {}
	controller.current_request = pending_request
	controller.current_raw = JSON.stringify({"command": command, "parameters": world["parameters"]})
	controller.current_source = pending_source
	controller.current_experiment = {}
	controller.current_attempt = {}
	controller.execute(command, world["parameters"])


func _list_worlds() -> void:
	var names := WorldStore.list_worlds()
	if names.is_empty():
		status_label.text = "No saved worlds yet. Build something and type /save a-name."
		_record("/worlds", "No saved worlds yet. Build something and type /save a-name.", "unsupported")
		return
	var reply := "Saved worlds (%d): %s\nType /load followed by a name. Files are in %s" % [names.size(), ", ".join(names), WorldStore.location()]
	status_label.text = "%d saved worlds: %s" % [names.size(), ", ".join(names)]
	_record("/worlds", reply, "ok")


func _delete_world(request: String) -> void:
	var name := request.substr(7).strip_edges()
	var result := WorldStore.remove_world(name)
	status_label.text = result["message"]
	_record(request, result["message"], "ok" if result["ok"] else "error")


# --- driving ---

func _start_driving() -> void:
	if not controller.circuit_builder.built:
		status_label.text = "Build a track first, then /drive."
		_record("/drive", "Build a track first, then /drive.", "error")
		return

	if car == null:
		car = Car.new()
		car.name = "Car"
		add_child(car)

	car.place_at(controller.circuit_builder.start_position, controller.circuit_builder.start_heading)
	car.visible = true
	car.freeze = false
	car.camera.current = true
	driving = true

	checkpoint_tracker.initialize(controller.circuit_builder.centreline)

	# Otherwise the steering keys would be typed into the text box.
	input_box.release_focus()
	_record("/drive", "Driving. W or Up to accelerate, A and D to steer, Space handbrake, R back to the start. Click the text box and type /view to stop.", "ok")


func _stop_driving() -> void:
	driving = false
	if car:
		car.freeze = true
		car.visible = false
	if controller.camera:
		controller.camera.current = true
	status_label.text = "Back to the overhead view."
	_record("/view", "Back to the overhead view.", "ok")


func _process(_delta: float) -> void:
	if not driving or car == null:
		return
	checkpoint_tracker.update_progress(car.global_position)
	status_label.text = "%.0f km/h   lap %d   last %s   best %s   (W accelerate, A and D steer, Space handbrake, R restart)" % [
		car.speed_kmh(),
		checkpoint_tracker.lap_count,
		checkpoint_tracker.get_formatted_time(checkpoint_tracker.last_lap_time),
		checkpoint_tracker.get_formatted_time(checkpoint_tracker.best_lap_time),
	]


func _on_lap_completed(last_time: float, best_time: float) -> void:
	_record("lap", "Lap %d completed in %s (best %s)" % [
		checkpoint_tracker.lap_count,
		checkpoint_tracker.get_formatted_time(last_time),
		checkpoint_tracker.get_formatted_time(best_time),
	], "ok")


func _on_experiment_progress(text: String) -> void:
	status_label.text = text


func _on_experiment_finished(summary_text: String) -> void:
	status_label.text = "Experiment complete. Results in the history panel."
	print(summary_text)
	_record("experiment results", summary_text, "ok")


# --- Command history panel ---

func _build_history_panel() -> void:
	var panel := PanelContainer.new()
	panel.name = "HistoryPanel"

	# Pin to the top-right corner of the screen.
	panel.anchor_left = 1.0
	panel.anchor_right = 1.0
	panel.anchor_top = 0.0
	panel.anchor_bottom = 0.0
	panel.offset_left = -390.0
	panel.offset_right = -10.0
	panel.offset_top = 10.0
	panel.offset_bottom = 250.0
	ui_layer.add_child(panel)

	var box := VBoxContainer.new()
	panel.add_child(box)

	var title := Label.new()
	title.text = "COMMAND HISTORY"
	box.add_child(title)

	history_log = RichTextLabel.new()
	history_log.scroll_following = true
	history_log.size_flags_vertical = Control.SIZE_EXPAND_FILL
	history_log.custom_minimum_size = Vector2(360, 200)
	history_log.add_theme_font_size_override("normal_font_size", 13)
	box.add_child(history_log)


# --- Track metrics panel (Protocol 002, section 53) ---

const METRIC_LABEL_COLOUR := Color(0.62, 0.68, 0.76)
const METRIC_VALUE_COLOUR := Color(0.95, 0.95, 0.95)
const METRIC_GOOD_COLOUR := Color(0.55, 0.85, 0.55)
const METRIC_BAD_COLOUR := Color(0.95, 0.5, 0.4)


func _build_metrics_panel() -> void:
	var panel := PanelContainer.new()
	panel.name = "MetricsPanel"
	panel.anchor_left = 1.0
	panel.anchor_right = 1.0
	panel.anchor_top = 0.0
	panel.anchor_bottom = 0.0
	panel.offset_left = -390.0
	panel.offset_right = -10.0
	panel.offset_top = 258.0
	panel.offset_bottom = 520.0
	ui_layer.add_child(panel)

	var box := VBoxContainer.new()
	panel.add_child(box)

	var title := Label.new()
	title.text = "TRACK MEASUREMENTS"
	box.add_child(title)

	metrics_log = RichTextLabel.new()
	metrics_log.size_flags_vertical = Control.SIZE_EXPAND_FILL
	metrics_log.custom_minimum_size = Vector2(360, 220)
	metrics_log.add_theme_font_size_override("normal_font_size", 13)
	box.add_child(metrics_log)
	_metric("", "Build a composed track to see its measurements.", METRIC_LABEL_COLOUR)


func _on_track_measured(record: Dictionary) -> void:
	metrics_log.clear()
	var valid: bool = record.get("result", "") == "VALID"

	var intent = record.get("intent", {})
	var style := "not stated"
	if typeof(intent) == TYPE_DICTIONARY and intent.has("style"):
		style = str(intent["style"])
	_metric("REQUESTED", style)

	if valid:
		_metric("RESULT", "Valid " + str(record.get("world", "circuit")), METRIC_GOOD_COLOUR)
	else:
		_metric("RESULT", "FAILED: " + str(record.get("category", "")), METRIC_BAD_COLOUR)

	var m: Dictionary = record.get("metrics", record.get("proposed_metrics", {}))
	if m.is_empty():
		var reasons: Array = record.get("reasons", [])
		if not reasons.is_empty():
			_metric("REASON", str(reasons[0]), METRIC_BAD_COLOUR)
		return
	if not valid:
		_metric("", "(measurements below describe the proposal, not a built track)", METRIC_LABEL_COLOUR)

	var counts: Dictionary = m["counts"]

	# Each kind of world measures different things, so each reads its own.
	if m.has("zone_count"):
		_show_world_metrics(m, counts)
		if not valid:
			var farm_why: Array = record.get("reasons", [])
			if not farm_why.is_empty():
				_metric("REASON", str(farm_why[0]), METRIC_BAD_COLOUR)
		return

	_metric("SECTIONS", "%d  (%d straight, %d corner, %d hairpin, %d chicane)" % [m["section_count"], counts["straight"], counts["corner"], counts["hairpin"], counts["chicane"]])
	_metric("LENGTH", "%.0f m" % m["total_length"])
	_metric("STRAIGHT RATIO", "%.0f%%" % (m["straight_ratio"] * 100.0))
	_metric("LONGEST STRAIGHT", "%.0f m" % m["longest_straight"])
	_metric("SHORTEST STRAIGHT", "%.0f m" % m["shortest_straight"])
	_metric("TIGHTEST RADIUS", "%.0f m" % m["minimum_radius"])
	_metric("DIRECTION CHANGE", "%.0f deg" % m["direction_change_total"])

	if record.has("closure"):
		var c: Dictionary = record["closure"]
		_metric("CLOSURE ERROR", "%.2f m, %.2f deg" % [c["closure_distance"], c["closure_heading_error"]])
	if record.has("separation"):
		var sep: Dictionary = record["separation"]
		_metric("SELF-INTERSECTIONS", "%d" % sep["self_intersections"])
		_metric("MIN SEPARATION", "%.1f m" % sep["minimum_separation"])
	if record.has("drift"):
		var d: Dictionary = record["drift"]
		_metric("SOLVER CHANGE", "corners %.1f%%, straights %.1f%%" % [d["max_angle_adjustment"] * 100.0, d["max_length_adjustment"] * 100.0])

	if not valid:
		var why: Array = record.get("reasons", [])
		if not why.is_empty():
			_metric("REASON", str(why[0]), METRIC_BAD_COLOUR)


# Measurements for worlds that are laid out rather than driven round.
func _show_world_metrics(m: Dictionary, counts: Dictionary) -> void:
	var present := PackedStringArray()
	for key in counts:
		if int(counts[key]) > 0:
			present.append("%d %s" % [counts[key], key])
	_metric("ZONES", "%d   (%s)" % [m["zone_count"], ", ".join(present)])
	_metric("SIZE", "%.0f m by %.0f m" % [m["farm_width"], m["farm_depth"]])
	_metric("ENCLOSED", "%.1f hectares" % (float(m["enclosed_area"]) / 10000.0))
	_metric("WORKED LAND", "%.1f ha  (%.0f%% of the farm)" % [float(m["worked_area"]) / 10000.0, float(m["worked_ratio"]) * 100.0])

	var crops: Dictionary = m.get("crops", {})
	if not crops.is_empty():
		var grown := PackedStringArray()
		for crop in crops:
			grown.append("%s %.1f ha" % [crop, float(crops[crop]) / 10000.0])
		_metric("CROPS", ", ".join(grown))

	if float(m.get("building_area", 0.0)) > 0.0:
		_metric("BUILDINGS", "%.0f m2 of floor" % m["building_area"])
	if float(m.get("water_area", 0.0)) > 0.0:
		_metric("WATER", "%.0f m2" % m["water_area"])
	_metric("FENCE", "%.0f m around the perimeter" % m["fence_length"])


func _metric(label: String, value: String, colour := METRIC_VALUE_COLOUR) -> void:
	if label != "":
		metrics_log.push_color(METRIC_LABEL_COLOUR)
		metrics_log.add_text(label + "   ")
		metrics_log.pop()
	metrics_log.push_color(colour)
	metrics_log.add_text(value)
	metrics_log.pop()
	metrics_log.newline()


# kind is "ok" (green), "error" (red) or "unsupported" (amber).
func _record(player_text: String, result_text: String, kind: String) -> void:
	# add_text (not BBCode) so nothing the player types can alter the display.
	history_log.push_color(Color(0.95, 0.95, 0.95))
	history_log.add_text("> " + player_text)
	history_log.pop()
	history_log.newline()

	var colour := Color(0.55, 0.85, 0.55)
	if kind == "error":
		colour = Color(0.95, 0.5, 0.4)
	elif kind == "unsupported":
		colour = Color(0.95, 0.75, 0.3)

	for line in result_text.split("\n"):
		history_log.push_color(colour)
		history_log.add_text("  " + line)
		history_log.pop()
		history_log.newline()

	history_log.newline()
