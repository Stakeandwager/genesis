extends Node3D

# --- Prototype 001 - Stage 9: Natural language -> AI -> validated command ---

@onready var input_box: LineEdit = $UI/CommandPanel/VBoxContainer/InputBox
@onready var build_button: Button = $UI/CommandPanel/VBoxContainer/BuildButton
@onready var status_label: Label = $UI/CommandPanel/VBoxContainer/StatusLabel

var controller: GameController
var interpreter: AIInterpreter


func _ready() -> void:
	controller = GameController.new()
	add_child(controller)
	controller.log_message.connect(_on_controller_log)
	controller.setup(self)

	interpreter = AIInterpreter.new()
	add_child(interpreter)
	interpreter.interpretation_ready.connect(_on_interpretation_ready)
	interpreter.interpretation_failed.connect(_on_interpretation_failed)

	build_button.pressed.connect(_on_build_pressed)
	input_box.text_submitted.connect(_on_text_submitted)

	if interpreter.is_available():
		status_label.text = "Status: Ready. Tell me what you want."
	else:
		status_label.text = "Status: No API key. Raw JSON only."

	print("Main ready. AI pipeline active.")


func _on_build_pressed() -> void:
	_handle_request(input_box.text)


func _on_text_submitted(_submitted_text: String) -> void:
	_handle_request(input_box.text)


func _on_controller_log(text: String) -> void:
	status_label.text = "Executed: " + text
	print("Controller: ", text)


func _handle_request(raw_request: String) -> void:
	var request := raw_request.strip_edges()

	if request == "":
		status_label.text = "Status: Type something first."
		return

	print("Player input: ", request)
	input_box.text = ""

	# Raw JSON still works - useful for debugging without spending API calls.
	if request.begins_with("{"):
		_execute_json(request)
		return

	if not interpreter.is_available():
		status_label.text = "No API key - type raw JSON instead"
		return

	status_label.text = "Thinking..."
	interpreter.interpret(request)


func _on_interpretation_ready(json_text: String) -> void:
	_execute_json(json_text)


func _on_interpretation_failed(reason: String) -> void:
	status_label.text = "AI failed: " + reason
	print("AI FAILED: ", reason)


# Every command reaches the game through here - AI or hand-typed, no difference.
func _execute_json(json_text: String) -> void:
	var parsed := CommandParser.parse(json_text)

	if not parsed["ok"]:
		status_label.text = "Rejected: " + str(parsed["error"])
		print("REJECTED: ", parsed["error"])
		return

	controller.execute(parsed["command"], parsed["parameters"])
