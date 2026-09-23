extends Node3D

# --- Prototype 002A - Step A7 (based on Prototype 001 Stages 10-12) ---
# The AI proposes. Godot constructs. Godot validates. The player sees both.

const SUPPORTED_HELP := "I can: design a closed race track from your description, or clear the world."

@onready var input_box: LineEdit = $UI/CommandPanel/VBoxContainer/InputBox
@onready var build_button: Button = $UI/CommandPanel/VBoxContainer/BuildButton
@onready var status_label: Label = $UI/CommandPanel/VBoxContainer/StatusLabel
@onready var ui_layer: CanvasLayer = $UI

var controller: GameController
var interpreter: AIInterpreter
var history_log: RichTextLabel
var metrics_log: RichTextLabel

# The player text currently being processed, so results can be matched to it.
var pending_request: String = ""
# Where the pending command came from: typed by hand, or composed by the AI.
var pending_source: Dictionary = {}


func _ready() -> void:
	controller = GameController.new()
	add_child(controller)
	controller.log_message.connect(_on_controller_log)
	controller.setup(self)

	interpreter = AIInterpreter.new()
	add_child(interpreter)
	interpreter.interpretation_ready.connect(_on_interpretation_ready)
	interpreter.interpretation_failed.connect(_on_interpretation_failed)

	controller.track_measured.connect(_on_track_measured)

	_build_history_panel()
	_build_metrics_panel()

	build_button.pressed.connect(_on_build_pressed)
	input_box.text_submitted.connect(_on_text_submitted)

	if interpreter.is_available():
		status_label.text = "Status: Ready. Tell me what you want."
	else:
		status_label.text = "Status: No API key. Raw JSON only."

	print("Main ready. AI pipeline and history active.")
	print("Track log: ", TrackLog.location())


func _on_build_pressed() -> void:
	_handle_request(input_box.text)


func _on_text_submitted(_submitted_text: String) -> void:
	_handle_request(input_box.text)


func _handle_request(raw_request: String) -> void:
	var request := raw_request.strip_edges()

	if request == "":
		status_label.text = "Status: Type something first."
		return

	# Don't accept a new request while the AI is still answering the last one.
	if interpreter.busy:
		status_label.text = "Still thinking about the last request..."
		return

	pending_request = request
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
	_execute_json(json_text)


func _on_interpretation_failed(reason: String) -> void:
	status_label.text = reason
	print("AI FAILED: ", reason)
	_record(pending_request, reason, "error")


func _on_controller_log(text: String) -> void:
	# Status line shows only the first line; the history panel shows everything.
	status_label.text = "Executed: " + text.split("\n")[0]
	print("Controller: ", text)
	var kind := "error" if text.contains("failed") else "ok"
	_record(pending_request, text, kind)


# Every command reaches the game through here - AI or hand-typed, no difference.
func _execute_json(json_text: String) -> void:
	var parsed := CommandParser.parse(json_text)

	# The AI honestly said it can't do this. Explain, don't execute.
	if parsed["unsupported"]:
		status_label.text = "I don't know how to do that yet."
		print("UNSUPPORTED: ", parsed["error"])
		_record(pending_request, "Not supported yet: " + str(parsed["error"]) + "\n" + SUPPORTED_HELP, "unsupported")
		return

	if not parsed["ok"]:
		status_label.text = "Rejected: " + str(parsed["error"])
		print("REJECTED: ", parsed["error"])
		_record(pending_request, "REJECTED: " + str(parsed["error"]), "error")
		return

	# So the experiment record keeps what was asked and exactly what was sent.
	controller.current_request = pending_request
	controller.current_raw = json_text
	controller.current_source = pending_source
	controller.execute(parsed["command"], parsed["parameters"])


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
		style = str(intent["style"]) + " circuit"
	_metric("REQUESTED", style)

	if valid:
		_metric("RESULT", "Valid circuit", METRIC_GOOD_COLOUR)
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
