extends Node3D

# --- Prototype 002A - Step A1 (based on Prototype 001 Stages 10-12) ---
# The AI proposes. Godot constructs. Godot validates. The player sees both.

const SUPPORTED_HELP := "I can: build a track, change a corner, add opponents, clear the world."

@onready var input_box: LineEdit = $UI/CommandPanel/VBoxContainer/InputBox
@onready var build_button: Button = $UI/CommandPanel/VBoxContainer/BuildButton
@onready var status_label: Label = $UI/CommandPanel/VBoxContainer/StatusLabel
@onready var ui_layer: CanvasLayer = $UI

var controller: GameController
var interpreter: AIInterpreter
var history_log: RichTextLabel

# The player text currently being processed, so results can be matched to it.
var pending_request: String = ""


func _ready() -> void:
	controller = GameController.new()
	add_child(controller)
	controller.log_message.connect(_on_controller_log)
	controller.setup(self)

	interpreter = AIInterpreter.new()
	add_child(interpreter)
	interpreter.interpretation_ready.connect(_on_interpretation_ready)
	interpreter.interpretation_failed.connect(_on_interpretation_failed)

	_build_history_panel()

	build_button.pressed.connect(_on_build_pressed)
	input_box.text_submitted.connect(_on_text_submitted)

	if interpreter.is_available():
		status_label.text = "Status: Ready. Tell me what you want."
	else:
		status_label.text = "Status: No API key. Raw JSON only."

	print("Main ready. AI pipeline and history active.")


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
		_execute_json(request)
		return

	if not interpreter.is_available():
		status_label.text = "No API key - type raw JSON instead."
		_record(request, "No API key - type raw JSON instead.", "error")
		return

	status_label.text = "Thinking..."
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
	panel.offset_bottom = 300.0
	ui_layer.add_child(panel)

	var box := VBoxContainer.new()
	panel.add_child(box)

	var title := Label.new()
	title.text = "COMMAND HISTORY"
	box.add_child(title)

	history_log = RichTextLabel.new()
	history_log.scroll_following = true
	history_log.size_flags_vertical = Control.SIZE_EXPAND_FILL
	history_log.custom_minimum_size = Vector2(360, 250)
	box.add_child(history_log)


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
