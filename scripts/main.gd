extends Node3D

# --- Prototype 002B: driving with lap timing and checkpoint HUD ---
# --- 002E: the play loop. Once a world exists, the AI is shown it with the
#     next request, so "make it longer" changes this world instead of
#     starting again. Godot reports what actually changed, by measurement. ---
# --- 002G: /session NAME tags every log record with the tester's name;
#     /session end shows what that session showed. ---
# --- 002F: driving reaches the world only through the controller's
#     drivable_surface(), so any world that reports one can be driven. ---
# --- 002D: /race [opponents] - race computer-controlled cars round the
#     circuit. Driving now uses the track's real position, so a circuit
#     moved by a plan (a track around a farm) is driven where it stands. ---
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
var race: RaceDirector
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
# 002E: the world as it was when the pending request was sent, so what changed
# can be measured once the new version is built.
var editing_from: Dictionary = {}

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
	controller.equipped.connect(_on_equipped)

	experiment = ExperimentRunner.new()
	add_child(experiment)
	experiment.setup(self, controller, interpreter)
	experiment.progress.connect(_on_experiment_progress)
	experiment.finished.connect(_on_experiment_finished)

	checkpoint_tracker = CheckpointTracker.new()
	add_child(checkpoint_tracker)
	checkpoint_tracker.lap_completed.connect(_on_lap_completed)

	race = RaceDirector.new()
	race.name = "RaceDirector"
	add_child(race)
	race.announced.connect(_on_race_announced)

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
# AI is asked for anything. It is built by the racing module but not recorded
# or remembered, so the first request still starts a new world.
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

	controller.show_unrecorded(RacingModule.new(), {"sections": test_sections, "target_turn": 360.0})
	checkpoint_tracker.initialize(_track_centreline())
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

	# 003 Stage 2: before this input is treated as anything else, ask what it
	# says about the readback it follows. A build that works proves nothing
	# about understanding; only the player can settle that.
	if not _judge_last_readback(request):
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
	editing_from = {}
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

	# Experiments always start from nothing; players build on what they have.
	editing_from = {}
	if experiment_context.is_empty() and not controller.last_build.is_empty():
		editing_from = controller.last_build.duplicate(true)
	status_label.text = "Designing..." if editing_from.is_empty() else "Working on your world..."
	pending_source = interpreter.describe() if editing_from.is_empty() else interpreter.describe_edit()
	interpreter.interpret(request, editing_from)


func _on_interpretation_ready(json_text: String) -> void:
	revising = false
	_execute_json(json_text)


func _on_interpretation_failed(reason: String) -> void:
	revising = false
	status_label.text = reason
	print("AI FAILED: ", reason)
	_record(pending_request, reason, "error")
	TrackLog.event("ai_unavailable", {"request": pending_request, "reason": reason})


func _on_controller_log(text: String) -> void:
	# Status line shows only the first line; the history panel shows everything.
	status_label.text = "Executed: " + text.split("\n")[0]
	print("Controller: ", text)
	var kind := "error" if text.contains("failed") else "ok"
	_record(pending_request, text, kind)
	# 003 Stage 2: remember whether the readback now waiting for evidence
	# actually produced a world, so that driving or saving cannot be read as
	# acceptance of a request that built nothing.
	if not awaiting_readback.is_empty():
		awaiting_readback["built"] = kind == "ok"

	if kind == "ok" and not editing_from.is_empty() and not controller.plan_running:
		var changes := _describe_changes(editing_from, controller.last_build)
		if changes != "":
			_record(pending_request, changes, "ok")
		editing_from = {}

	# A new circuit means new checkpoints, and any race on the old one is over.
	if kind == "ok" and controller.has_drivable():
		var was_racing := race.running
		if race.running:
			race.stop()
		checkpoint_tracker.initialize(_track_centreline())
		# Changed while driving: carry on driving the new version from the start.
		if driving:
			car.auto_drive = false
			car.place_at(_track_start(), _track_heading())
			if was_racing:
				_record("race", "The track changed, so the race was stopped. Type /race to race the new version.", "unsupported")


# Every command reaches the game through here - AI or hand-typed, no difference.
func _execute_json(json_text: String) -> void:
	# So the record keeps what was asked and exactly what was sent, even when
	# the answer is refused before it becomes a command.
	controller.current_request = pending_request
	controller.current_raw = json_text
	controller.current_source = pending_source
	controller.current_experiment = pending_experiment
	controller.current_attempt = pending_attempt
	# 003 Stage 2: the id is made here, before the record exists, so the
	# readback can be shown with something for later evidence to point at.
	controller.current_record_id = TrackLog.next_id()

	var parsed := CommandParser.parse(json_text)

	# The AI honestly said it can't do this. Explain, don't execute.
	# 003: it still shows what it understood first. A refusal of the wrong
	# request is its own misunderstanding, and what players ask for and
	# cannot have is evidence about what Genesis should become.
	if parsed["unsupported"]:
		controller.current_readback = WorldRegistry.readback("UNSUPPORTED", parsed["parameters"])
		_show_readback()
		status_label.text = "I don't know how to do that yet."
		print("UNSUPPORTED: ", parsed["error"])
		_record(pending_request, "Not supported yet: " + str(parsed["error"]) + "\n" + SUPPORTED_HELP, "unsupported")
		controller.record_rejection("UNSUPPORTED", str(parsed["error"]))
		return

	if not parsed["ok"]:
		controller.current_readback = ""
		status_label.text = "Rejected: " + str(parsed["error"])
		print("REJECTED: ", parsed["error"])
		_record(pending_request, "REJECTED: " + str(parsed["error"]), "error")
		controller.record_rejection("FAILED_PARSE", str(parsed["error"]))
		return

	# 003: say what Genesis understood BEFORE building, so the line is shown
	# whether or not construction then succeeds, and so a build that works
	# can never be mistaken for a request that was understood.
	controller.current_readback = WorldRegistry.readback(parsed["command"], parsed["parameters"])
	_show_readback()

	controller.execute(parsed["command"], parsed["parameters"])


# The readback goes in the history panel against the request it belongs to,
# in its own colour. It is deliberately not a question: stopping the game
# after every sentence to ask YES or NO would turn playing into a form.
# 003 Stage 2: the readback whose correctness is still unsettled, and the
# request before it, so that asking again in different words can be spotted.
var awaiting_readback: Dictionary = {}
var last_judged_request := ""


# Decide what this input says about the readback before it, write that down,
# and say whether the input should carry on being handled as a request.
# "yes" is an answer, not a world called yes, so it stops here.
func _judge_last_readback(request: String) -> bool:
	if awaiting_readback.is_empty():
		# A bare yes or no with nothing to answer is not a world. Sending it
		# to the AI spends a request to be told that "confirmation of an
		# unspecified action" cannot be built, which helps nobody.
		if Understanding.is_bare_answer(request):
			status_label.text = "There is nothing to confirm just now."
			_record(request, "There is nothing to confirm just now.", "understood")
			input_box.text = ""
			return false
		last_judged_request = request
		return true

	var about := awaiting_readback
	var verdict := Understanding.judge(request, str(about.get("request", "")), bool(about.get("built", false)))
	if verdict.is_empty():
		return true

	awaiting_readback = {}
	var written := Understanding.record(about, verdict, request)
	TrackLog.append(written)
	print("UNDERSTANDING: %s (%s) about %s" % [
		str(verdict["understanding"]), str(verdict["evidence"]), str(about.get("id", ""))])

	var said := Understanding.reply(verdict)
	if said != "":
		_record(request, said, "understood")
		status_label.text = said

	last_judged_request = request
	if bool(verdict["consumed"]):
		input_box.text = ""
		return false
	return true


func _show_readback() -> void:
	var line := str(controller.current_readback)
	if line == "":
		return
	print("READBACK: ", line)
	_record(pending_request, "I understand: you want " + line + ".", "understood")
	# 003 Stage 2: this readback is now waiting to find out whether it was
	# right. Whatever the player does next is the evidence.
	awaiting_readback = {
		"id": controller.current_record_id,
		"request": pending_request,
		"readback": line,
	}


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
			if driving:
				TrackLog.event("drive")
		"/race":
			var count := 3
			if parts.size() > 1 and parts[1].is_valid_int():
				count = clampi(parts[1].to_int(), 1, 5)
			_start_race(count)
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
		"/session":
			_session(request)
		"/log":
			var reply := "Track log: " + TrackLog.location()
			status_label.text = "Track log location written to the history."
			_record(request, reply, "ok")
		_:
			var help := "Game commands: /save [name], /load [name], /worlds, /delete [name], /drive, /race [opponents], /view, /experiment [count], /stop, /status, /revise [on|off], /session [name|end], /log"
			status_label.text = help
			_record(request, help, "unsupported")


# --- player testing sessions (002G) ---

# /session NAME starts tagging the log for one tester (ending any session
# already running), /session end stops and shows the results, and /session
# on its own says what is running.
func _session(request: String) -> void:
	var arg := request.substr(8).strip_edges()
	if arg == "":
		var reply := "No session is running. Type /session followed by the tester's name to start one."
		if not TrackLog.session.is_empty():
			reply = "Session '%s' running since %s. Type /session end to finish it and see the results." % [TrackLog.session["name"], TrackLog.session["started"]]
		status_label.text = reply
		_record(request, reply, "ok")
		return

	if arg.to_lower() == "end":
		if TrackLog.session.is_empty():
			status_label.text = "No session is running."
			_record(request, "No session is running.", "unsupported")
		else:
			_end_session(request)
		return

	# Starting a new session finishes the one before it.
	if not TrackLog.session.is_empty():
		_end_session(request)

	var name := arg.substr(0, 30)
	var started := Time.get_datetime_string_from_system()
	TrackLog.session = {"name": name, "id": "%s %s" % [name, started], "started": started}
	TrackLog.event("session_start")

	# A fresh start for every tester: nothing left over from the last person,
	# and their first request starts a new world rather than changing one.
	if driving:
		_stop_driving()
	pending_request = request
	controller.execute("CLEAR_WORLD", {})
	_build_startup_track()
	var reply := "Session '%s' started. Everything from now on is logged under that name. Type /session end when they have finished." % name
	status_label.text = reply
	_record(request, reply, "ok")


func _end_session(request: String) -> void:
	var name: String = TrackLog.session["name"]
	TrackLog.event("session_end")
	var records := TrackLog.read_session(str(TrackLog.session["id"]))
	var summary := SessionReport.summarise(records)
	var record := {"type": "session_summary", "time": Time.get_datetime_string_from_system()}
	record.merge(summary)
	TrackLog.append(record)
	TrackLog.session = {}
	var text := SessionReport.describe(name, summary)
	print(text)
	status_label.text = "Session '%s' ended. Results in the history panel." % name
	_record(request, text, "ok")


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

# 004: a new spec reaches the car already on the track, so "give it more
# grip" changes the car you are sitting in rather than the next one.
func _on_equipped(tool_name: String, spec: Dictionary) -> void:
	if tool_name == "car" and car != null:
		car.equip(spec)


func _start_driving() -> void:
	if not controller.has_drivable():
		status_label.text = "Build a track first, then /drive."
		_record("/drive", "Build a track first, then /drive.", "error")
		return

	if car == null:
		car = Car.new()
		car.name = "Car"
		add_child(car)
	# 004: whatever the player is equipped with, every time. A kit nobody
	# has changed is the default car, so this is a no-op until it is not.
	car.equip(controller.kit.get("car", {}))

	if race.running:
		race.stop()
	car.auto_drive = false
	car.place_at(_track_start(), _track_heading())
	car.visible = true
	car.freeze = false
	car.camera.current = true
	driving = true

	checkpoint_tracker.initialize(_track_centreline())

	# Otherwise the steering keys would be typed into the text box.
	input_box.release_focus()
	_record("/drive", "Driving. W or Up to accelerate, A and D to steer, Space handbrake, R back to the start. Click the text box and type /view to stop.", "ok")


func _stop_driving() -> void:
	driving = false
	if race.running:
		race.stop()
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
	if race.running:
		var left := race.countdown_left()
		if left > 0.0:
			status_label.text = "Race starts in %d..." % int(ceil(left))
		elif race.finished:
			status_label.text = "%.0f km/h   race over, finished P%d   (type /race to go again, /view to stop)" % [car.speed_kmh(), race.player_position()]
		else:
			status_label.text = "%.0f km/h   P%d of %d   lap %d of %d   (W accelerate, A and D steer, Space handbrake)" % [
				car.speed_kmh(), race.player_position(), race.racers.size(), race.player_lap(), RaceDirector.RACE_LAPS]
		return
	status_label.text = "%.0f km/h   lap %d   last %s   best %s   (W accelerate, A and D steer, Space handbrake, R restart)" % [
		car.speed_kmh(),
		checkpoint_tracker.lap_count,
		checkpoint_tracker.get_formatted_time(checkpoint_tracker.last_lap_time),
		checkpoint_tracker.get_formatted_time(checkpoint_tracker.best_lap_time),
	]


# --- play loop ---

# What changed between two builds, from Godot's own measurements. Only facts
# that differ are listed; nothing is taken from the AI's description.
func _describe_changes(before: Dictionary, after: Dictionary) -> String:
	if after.is_empty() or after.get("parameters", {}) == before.get("parameters", {}):
		return "Nothing changed: the AI returned the same world."
	if str(before.get("command", "")) != str(after.get("command", "")):
		return "Built something new rather than changing the last world."
	var m0: Dictionary = before.get("metrics", {})
	var m1: Dictionary = after.get("metrics", {})
	if m0.is_empty() or m1.is_empty():
		return "Changed the world."
	var parts := PackedStringArray()
	if m0.has("total_length") and absf(float(m1.get("total_length", 0.0)) - float(m0["total_length"])) >= 5.0:
		parts.append("length %.0f -> %.0f m" % [float(m0["total_length"]), float(m1.get("total_length", 0.0))])
	if m0.has("minimum_radius") and absf(float(m1.get("minimum_radius", 0.0)) - float(m0["minimum_radius"])) >= 1.0:
		parts.append("tightest corner %.0f -> %.0f m radius" % [float(m0["minimum_radius"]), float(m1.get("minimum_radius", 0.0))])
	if m0.has("longest_straight") and absf(float(m1.get("longest_straight", 0.0)) - float(m0["longest_straight"])) >= 5.0:
		parts.append("longest straight %.0f -> %.0f m" % [float(m0["longest_straight"]), float(m1.get("longest_straight", 0.0))])
	var c0: Dictionary = m0.get("counts", {})
	var c1: Dictionary = m1.get("counts", {})
	for key in c1:
		if int(c1[key]) != int(c0.get(key, 0)):
			parts.append("%ss %d -> %d" % [str(key).replace("_", " "), int(c0.get(key, 0)), int(c1[key])])
	# Farms: a few headline numbers.
	for key in ["zone_count", "farm_width", "farm_depth", "enclosed_area"]:
		if m0.has(key) and m1.has(key) and absf(float(m1[key]) - float(m0[key])) >= 1.0:
			var unit := " m2" if key == "enclosed_area" else ("" if key == "zone_count" else " m")
			parts.append("%s %.0f -> %.0f%s" % [str(key).replace("_", " "), float(m0[key]), float(m1[key]), unit])
	if parts.is_empty():
		return "Changed the world, with no measured difference in size or pieces."
	return "Changed: " + ", ".join(parts)


# --- racing ---

func _start_race(count: int) -> void:
	_start_driving()
	if not driving:
		return
	var surface := controller.drivable_surface()
	var reply := race.start(surface["centreline"], surface["start_heading"], car, count, surface["road_height"])
	if race.running:
		TrackLog.event("race_start", {"opponents": count})
	status_label.text = reply
	_record("/race", reply, "ok" if race.running else "error")


func _on_race_announced(text: String) -> void:
	_record("race", text, "ok")


# The start and centreline where the drivable world actually stands. A plan
# can move it (a track around a farm); the controller converts to world space.
func _track_start() -> Vector3:
	return controller.drivable_surface().get("start_position", Vector3.ZERO)


func _track_heading() -> float:
	return float(controller.drivable_surface().get("start_heading", 0.0))


func _track_centreline() -> PackedVector3Array:
	return controller.drivable_surface().get("centreline", PackedVector3Array())


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

	# 002I: each world writes its own panel. This used to guess the world
	# from which keys it measured, which meant a new world either crashed
	# here or showed nothing until main.gd was edited.
	var module := WorldRegistry.find(str(record.get("command", "CREATE_TRACK")))
	if module:
		for line in module.metric_lines(m, record):
			_metric(str((line as Array)[0]), str((line as Array)[1]))

	if not valid:
		var why: Array = record.get("reasons", [])
		if not why.is_empty():
			_metric("REASON", str(why[0]), METRIC_BAD_COLOUR)


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
	elif kind == "understood":
		# 003: what Genesis understood, in its own colour, so the player can
		# find it without reading the result to know whether to trust it.
		colour = Color(0.60, 0.78, 0.95)

	for line in result_text.split("\n"):
		history_log.push_color(colour)
		history_log.add_text("  " + line)
		history_log.pop()
		history_log.newline()

	history_log.newline()
