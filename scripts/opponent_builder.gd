extends Node3D
class_name OpponentBuilder

var opponents: Array[Node3D] = []

func spawn(count: int, start_position: Vector3, direction: Vector3) -> String:
	clear()
	return "SPAWN_OPPONENTS count=%d" % count

func clear() -> void:
	for child in get_children():
		child.queue_free()
	opponents.clear()
