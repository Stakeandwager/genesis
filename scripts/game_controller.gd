extends Node
class_name GameController

# --- Prototype 001 - Stages 4-7 ---

signal log_message(text: String)

var track_builder: TrackBuilder
var opponent_builder: OpponentBuilder


func setup(world_root: Node3D) -> void:
	track_builder = TrackBuilder.new()
	track_builder.name = "TrackBuilder"
	world_root.add_child(track_builder)

	opponent_builder = OpponentBuilder.new()
	opponent_builder.name = "OpponentBuilder"
	world_root.add_child(opponent_builder)


func execute(command: String, parameters: Dictionary) -> void:
	match command:
		"CREATE_TRACK":
			opponent_builder.clear()
			log_message.emit(track_builder.build(parameters))
		"MODIFY_TRACK":
			_modify_track(parameters)
		"SPAWN_OPPONENTS":
			_spawn_opponents(parameters)
		"CLEAR_WORLD":
			track_builder.clear()
			opponent_builder.clear()
			log_message.emit("CLEAR_WORLD")
		_:
			log_message.emit("No handler for: " + command)


func _modify_track(parameters: Dictionary) -> void:
	var corner: int = int(parameters.get("corner", 1))
	var difficulty: String = str(parameters.get("difficulty", "medium"))
	log_message.emit(track_builder.modify_corner(corner, difficulty))


func _spawn_opponents(parameters: Dictionary) -> void:
	if not track_builder.has_track():
		log_message.emit("SPAWN_OPPONENTS failed: build a track first")
		return

	var count: int = int(parameters.get("count", 1))
	log_message.emit(opponent_builder.spawn(
		count,
		track_builder.get_start_position(),
		track_builder.get_start_direction()
	))
