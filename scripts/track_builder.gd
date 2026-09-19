extends Node3D
class_name TrackBuilder

# --- Prototype 001 - Stages 4 & 5: Track geometry ---
# Deliberately primitive. Visual proof only, no racing realism.

const SEGMENT_WIDTH := 12.0
const SEGMENT_THICKNESS := 0.5

var corner_nodes: Array[Node3D] = []


func build(parameters: Dictionary) -> String:
	clear()

	var length: float = float(parameters.get("length", 1000))
	var corners: int = int(parameters.get("corners", 4))
	var difficulty: String = str(parameters.get("difficulty", "medium"))

	corners = clampi(corners, 2, 12)
	length = clampf(length, 200.0, 3000.0)

	var radius: float = length / 40.0
	radius = clampf(radius, 15.0, 70.0)

	var tightness := _difficulty_to_tightness(difficulty)

	var points: Array[Vector3] = []
	for i in corners:
		var angle := TAU * (float(i) / float(corners))
		var wobble := 1.0 - (tightness * 0.35)
		points.append(Vector3(
			cos(angle) * radius,
			0.0,
			sin(angle) * radius * wobble
		))

	for i in points.size():
		var from: Vector3 = points[i]
		var to: Vector3 = points[(i + 1) % points.size()]
		_build_straight(from, to)
		_build_corner(i, from, difficulty)

	_build_start_line(points[0])

	return "CREATE_TRACK length=%d corners=%d difficulty=%s" % [int(length), corners, difficulty]


func modify_corner(corner_index: int, difficulty: String) -> String:
	if corner_nodes.is_empty():
		return "MODIFY_TRACK failed: no track exists yet"

	var index := corner_index - 1

	if index < 0 or index >= corner_nodes.size():
		return "MODIFY_TRACK failed: corner %d does not exist (track has %d)" % [corner_index, corner_nodes.size()]

	var corner := corner_nodes[index]
	var tightness := _difficulty_to_tightness(difficulty)

	var marker := corner.get_child(0) as MeshInstance3D
	var box := marker.mesh as BoxMesh
	box.size = Vector3(
		SEGMENT_WIDTH * (1.0 - tightness * 0.55),
		SEGMENT_THICKNESS + tightness * 3.0,
		SEGMENT_WIDTH * (1.0 - tightness * 0.55)
	)
	marker.material_override = _make_material(_difficulty_to_colour(difficulty))
	
	

	return "MODIFY_TRACK corner=%d difficulty=%s" % [corner_index, difficulty]


func clear() -> void:
	for child in get_children():
		child.queue_free()
	corner_nodes.clear()


func has_track() -> bool:
	return not corner_nodes.is_empty()


# --- internal helpers ---

func _build_straight(from: Vector3, to: Vector3) -> void:
	var distance := from.distance_to(to)
	print("STRAIGHT from=", from, " to=", to, " dist=", distance)

	var segment := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(SEGMENT_WIDTH, 1.2, distance)
	segment.mesh = box
	segment.material_override = _make_material(Color(0.13, 0.13, 0.16))
	add_child(segment)

	var midpoint := (from + to) * 0.5
	var direction := to - from
	var angle := atan2(direction.x, direction.z)

	segment.position = midpoint + Vector3(0.0, 2.0, 0.0)
	segment.rotation = Vector3(0.0, angle, 0.0)

	print("  -> added at ", segment.position, " visible=", segment.visible)
func _build_corner(index: int, at: Vector3, difficulty: String) -> void:
	var holder := Node3D.new()
	holder.name = "Corner_%d" % (index + 1)
	add_child(holder)

	var tightness := _difficulty_to_tightness(difficulty)

	var marker := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(
		SEGMENT_WIDTH * (1.0 - tightness * 0.55),
		SEGMENT_THICKNESS + tightness * 3.0,
		SEGMENT_WIDTH * (1.0 - tightness * 0.55)
	)
	marker.mesh = box
	marker.material_override = _make_material(_difficulty_to_colour(difficulty))
	holder.add_child(marker)

	holder.position = at + Vector3(0.0, 1.2, 0.0)
	corner_nodes.append(holder)


func _build_start_line(at: Vector3) -> void:
	var line := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(SEGMENT_WIDTH + 2.0, SEGMENT_THICKNESS + 0.6, 2.0)
	line.mesh = box
	line.material_override = _make_material(Color(0.95, 0.95, 0.95))
	line.position = at + Vector3(0.0, 1.6, 0.0)
	add_child(line)


func _difficulty_to_tightness(difficulty: String) -> float:
	match difficulty.to_lower():
		"easy":
			return 0.15
		"medium":
			return 0.45
		"hard":
			return 0.75
		"extreme":
			return 0.95
	return 0.45


func _difficulty_to_colour(difficulty: String) -> Color:
	match difficulty.to_lower():
		"easy":
			return Color(0.25, 0.65, 0.35)
		"medium":
			return Color(0.85, 0.7, 0.2)
		"hard":
			return Color(0.85, 0.3, 0.2)
		"extreme":
			return Color(0.7, 0.15, 0.6)
	return Color(0.85, 0.7, 0.2)


func _make_material(colour: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = colour
	return material
