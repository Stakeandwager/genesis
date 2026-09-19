extends Node3D

# --- Prototype 001 - Stage 3: Command pipeline (still no AI) ---

@onready var input_box: LineEdit = $UI/CommandPanel/VBoxContainer/InputBox
@onready var build_button: Button = $UI/CommandPanel/VBoxContainer/BuildButton
@onready var status_label: Label = $UI/CommandPanel/VBoxContainer/StatusLabel

var controller: GameController


func _ready() -> void:
	controller = GameController.new()
	add_child(controller)
	controller.log_message.connect(_on_controller_log)

	build_button.pressed.connect(_on_build_pressed)
	input_box.text_submitted.connect(_on_text_submitted)
	status_label.text = "Status: Waiting"
	print("Main ready. Command pipeline active.")


func _on_build_pressed() -> void:
	_handle_request(input_box.text)


func _on_text_submitted(_submitted_text: String) -> void:
	_handle_request(input_box.text)


func _on_controller_log(text: String) -> void:
	status_label.text = "Executed: " + text
	print("Controller: ", text)


# For now the player types RAW JSON. The AI will supply this later.
func _handle_request(raw_request: String) -> void:
	var request := raw_request.strip_edges()

	if request == "":
		status_label.text = "Status: Type something first."
		return

	print("Player input: ", request)

	var parsed := CommandParser.parse(request)

	if not parsed["ok"]:
		status_label.text = "Rejected: " + str(parsed["error"])
		print("REJECTED: ", parsed["error"])
		input_box.text = ""
		return

	controller.execute(parsed["command"], parsed["parameters"])
	input_box.text = ""
