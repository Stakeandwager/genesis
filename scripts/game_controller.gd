extends Node
class_name GameController

# --- Prototype 001 - Stage 3: Command dispatch ---
# This is the ONLY place a validated command becomes a game action.

signal log_message(text: String)


func execute(command: String, parameters: Dictionary) -> void:
	match command:
		"CREATE_TRACK":
			_create_track(parameters)
		"MODIFY_TRACK":
			_modify_track(parameters)
		"SPAWN_OPPONENTS":
			_spawn_opponents(parameters)
		"CLEAR_WORLD":
			_clear_world(parameters)
		_:
			log_message.emit("No handler for: " + command)


func _create_track(parameters: Dictionary) -> void:
	var length = parameters.get("length", 1000)
	var corners = parameters.get("corners", 4)
	var difficulty = parameters.get("difficulty", "medium")
	log_message.emit("CREATE_TRACK length=%s corners=%s difficulty=%s" % [length, corners, difficulty])


func _modify_track(parameters: Dictionary) -> void:
	var corner = parameters.get("corner", 1)
	var difficulty = parameters.get("difficulty", "medium")
	log_message.emit("MODIFY_TRACK corner=%s difficulty=%s" % [corner, difficulty])


func _spawn_opponents(parameters: Dictionary) -> void:
	var count = parameters.get("count", 1)
	log_message.emit("SPAWN_OPPONENTS count=%s" % count)


func _clear_world(_parameters: Dictionary) -> void:
	log_message.emit("CLEAR_WORLD")
