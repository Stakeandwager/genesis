extends Node
class_name GameController

# --- Prototype 001 - Stages 4-6: Command dispatch with real geometry ---

signal log_message(text: String)

var track_builder: TrackBuilder


func setup(world_root: Node3D) -> void:
	track_builder = TrackBuilder.new()
	track_builder.name = "TrackBuilder"
	world_root.add_child(track_builder)


func execute(command: String, parameters: Dictionary) -> void:
	match command:
		"CREATE_TRACK":
			log_message.emit(track_builder.build(parameters))
		"MODIFY_TRACK":
			_modify_track(parameters)
		"SPAWN_OPPONENTS":
			log_message.emit("SPAWN_OPPONENTS not implemented yet")
		"CLEAR_WORLD":
			track_builder.clear()
			log_message.emit("CLEAR_WORLD")
		_:
			log_message.emit("No handler for: " + command)


func _modify_track(parameters: Dictionary) -> void:
	var corner: int = int(parameters.get("corner", 1))
	var difficulty: String = str(parameters.get("difficulty", "medium"))
	log_message.emit(track_builder.modify_corner(corner, difficulty))
