extends Node
class_name GameController

# --- Prototype 002A - Step A1 ---
# CREATE_TRACK with "sections" takes the new composition path.
# CREATE_TRACK without "sections" still builds the Prototype 001 ring,
# so everything that worked in 001 keeps working.

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
			if parameters.has("sections"):
				_create_composed_track(parameters)
			else:
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


# Step A1: validate only. Geometry arrives in step A2.
func _create_composed_track(parameters: Dictionary) -> void:
	var check := SectionValidator.validate(parameters)

	if not check["ok"]:
		var problems: Array = check["errors"]
		var lines := PackedStringArray()
		lines.append("CREATE_TRACK failed: composition rejected (%d problem(s))" % problems.size())
		for problem in problems:
			lines.append("- " + str(problem))
		log_message.emit("\n".join(lines))
		return

	var summary: Dictionary = check["summary"]
	var counts: Dictionary = summary["counts"]
	log_message.emit(
		"CREATE_TRACK composition valid: %d sections (%d straight, %d corner, %d hairpin, %d chicane)\nnet turn %+.0f deg, direction change %.0f deg\ngeometry not built yet (step A2)"
		% [summary["section_count"], counts["straight"], counts["corner"], counts["hairpin"], counts["chicane"], summary["net_turn"], summary["direction_change"]]
	)


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
