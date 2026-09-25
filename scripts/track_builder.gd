extends Node3D
class_name TrackBuilder

const SEGMENT_WIDTH := 12.0
const SEGMENT_THICKNESS := 0.5

var corner_nodes: Array[Node3D] = []

func build(parameters: Dictionary) -> String:
	clear()
	var corners: int = int(parameters.get("corners", 4))
	return "CREATE_TRACK corners=%d" % corners

func modify_corner(corner_index: int, difficulty: String) -> String:
	return "MODIFY_TRACK corner=%d difficulty=%s" % [corner_index, difficulty]

func clear() -> void:
	for child in get_children():
		child.queue_free()
	corner_nodes.clear()

func has_track() -> bool:
	return not corner_nodes.is_empty()

func get_start_position() -> Vector3:
	if corner_nodes.is_empty():
		return Vector3.ZERO
	return corner_nodes[0].position

func get_start_direction() -> Vector3:
	if corner_nodes.size() < 2:
		return Vector3.FORWARD
	return (corner_nodes[1].position - corner_nodes[0].position).normalized()
