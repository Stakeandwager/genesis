extends Node3D
class_name CircuitBuilder

# --- Prototype 002B: road, barriers and collision ---
# Each section starts exactly where the previous one ended. All geometry comes
# from TrackGeometry, the same maths the closure solver uses.
#
# Every piece of road and every barrier carries collision, so a car can drive
# on it. Banked sections roll their surface by the bank angle.

const ROAD_WIDTH := 12.0
# Lifted clear of the ground: older GPUs have coarse depth precision at long
# camera distances, and a road too close to the ground disappears.
const ROAD_HEIGHT := 1.5
const BARRIER_HEIGHT := 1.6
const BARRIER_THICKNESS := 0.6

const SECTION_COLOURS := {
	"straight": Color(0.10, 0.10, 0.12),
	"uphill": Color(0.16, 0.22, 0.14),
	"downhill": Color(0.20, 0.14, 0.22),
	"crest": Color(0.18, 0.20, 0.13),
	"dip": Color(0.14, 0.16, 0.22),
	"corner": Color(0.95, 0.78, 0.22),
	"hairpin": Color(0.95, 0.36, 0.24),
	"banked_corner": Color(0.95, 0.58, 0.20),
	"chicane": Color(0.82, 0.36, 0.78),
	"loop_segment": Color(0.35, 0.80, 0.90),
}

var built := false
var centreline := PackedVector3Array()
var last_report: Dictionary = {}
var start_position := Vector3.ZERO
var start_heading := 0.0


func build(sections: Array, mark_end := true) -> Dictionary:
	clear()

	var pos := Vector3.ZERO
	var heading := 0.0
	var total_length := 0.0
	var bounds_min := Vector2(INF, INF)
	var bounds_max := Vector2(-INF, -INF)

	for i in sections.size():
		var s: Dictionary = sections[i]
		var samples := TrackGeometry.sample(pos, heading, s)
		total_length += TrackGeometry.section_length(s)

		_add_road_piece(i, str(s["type"]), samples)
		_add_barriers(i, samples)

		for sample in samples:
			var p: Vector3 = sample[0]
			centreline.append(p)
			bounds_min = Vector2(minf(bounds_min.x, p.x), minf(bounds_min.y, p.z))
			bounds_max = Vector2(maxf(bounds_max.x, p.x), maxf(bounds_max.y, p.z))

		var pose := TrackGeometry.advance(pos, heading, s)
		pos = pose[0]
		heading = pose[1]

	_add_start_line()
	if mark_end:
		_add_end_marker(pos)
	built = true
	start_position = Vector3(0.0, ROAD_HEIGHT, 0.0)
	start_heading = 0.0

	last_report = {
		"section_count": sections.size(),
		"total_length": total_length,
		"end_position": pos,
		"end_gap": Vector2(pos.x, pos.z).length(),
		"heading_error": rad_to_deg(wrapf(heading, -PI, PI)),
		"height_error": pos.y,
		"bounds_min": bounds_min,
		"bounds_max": bounds_max,
	}
	return last_report


func clear() -> void:
	for child in get_children():
		child.queue_free()
	centreline.clear()
	last_report = {}
	built = false


# --- road surface ---

# The sideways direction of the road at a sample, rolled by its bank angle.
func _across(heading: float, bank: float) -> Vector3:
	return TrackGeometry.right(heading).rotated(TrackGeometry.forward(heading), bank)


func _add_road_piece(index: int, type: String, samples: Array) -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var half := ROAD_WIDTH * 0.5
	var lift := Vector3.UP * ROAD_HEIGHT

	var faces := PackedVector3Array()

	for k in samples.size() - 1:
		var a: Array = samples[k]
		var b: Array = samples[k + 1]
		var across_a := _across(a[1], a[3]) * half
		var across_b := _across(b[1], b[3]) * half
		var l0: Vector3 = a[0] - across_a + lift
		var r0: Vector3 = a[0] + across_a + lift
		var l1: Vector3 = b[0] - across_b + lift
		var r1: Vector3 = b[0] + across_b + lift
		# Winding chosen so the road faces up, towards the light.
		for v in [l0, l1, r0, r0, l1, r1]:
			st.set_normal(Vector3.UP)
			st.add_vertex(v)
			faces.append(v)

	st.generate_normals()
	var piece := MeshInstance3D.new()
	piece.name = "Section_%d_%s" % [index + 1, type]
	piece.mesh = st.commit()
	piece.material_override = _material(SECTION_COLOURS.get(type, Color(0.1, 0.1, 0.12)))
	add_child(piece)
	_add_collision("RoadBody_%d" % (index + 1), faces)


# --- barriers ---

func _add_barriers(index: int, samples: Array) -> void:
	_add_barrier_wall(index, samples, -1.0)
	_add_barrier_wall(index, samples, 1.0)


func _add_barrier_wall(index: int, samples: Array, side: float) -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var offset := ROAD_WIDTH * 0.5 + BARRIER_THICKNESS * 0.5
	var lift := Vector3.UP * ROAD_HEIGHT

	var faces := PackedVector3Array()

	for k in samples.size() - 1:
		var a: Array = samples[k]
		var b: Array = samples[k + 1]
		var base_a: Vector3 = a[0] + _across(a[1], a[3]) * offset * side + lift
		var base_b: Vector3 = b[0] + _across(b[1], b[3]) * offset * side + lift
		var top_a := base_a + Vector3.UP * BARRIER_HEIGHT
		var top_b := base_b + Vector3.UP * BARRIER_HEIGHT
		# Both faces, so the wall is solid from either side.
		for v in [base_a, top_a, base_b, base_b, top_a, top_b]:
			st.add_vertex(v)
			faces.append(v)
		for v in [base_b, top_b, base_a, base_a, top_b, top_a]:
			st.add_vertex(v)
			faces.append(v)

	st.generate_normals()
	var wall := MeshInstance3D.new()
	wall.name = "Barrier_%d_%s" % [index + 1, "left" if side < 0.0 else "right"]
	wall.mesh = st.commit()
	wall.material_override = _material(Color(0.78, 0.78, 0.80))
	add_child(wall)
	_add_collision("BarrierBody_%d_%s" % [index + 1, "left" if side < 0.0 else "right"], faces)


# Collision is built from the same triangles as the visible surface, so what
# you see is exactly what the car drives on.
func _add_collision(name_for: String, faces: PackedVector3Array) -> void:
	if faces.is_empty():
		return
	var body := StaticBody3D.new()
	body.name = name_for
	var shape := CollisionShape3D.new()
	var mesh_shape := ConcavePolygonShape3D.new()
	mesh_shape.set_faces(faces)
	shape.shape = mesh_shape
	body.add_child(shape)
	add_child(body)


# --- markers ---

func _add_start_line() -> void:
	var line := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(ROAD_WIDTH + 2.0, 0.3, 2.0)
	line.mesh = box
	line.material_override = _material(Color(0.95, 0.95, 0.95))
	line.position = Vector3(0.0, ROAD_HEIGHT + 0.15, 0.0)
	add_child(line)


func _add_end_marker(at: Vector3) -> void:
	var post := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(3.0, 6.0, 3.0)
	post.mesh = box
	post.material_override = _material(Color(0.95, 0.45, 0.15))
	post.position = at + Vector3(0.0, 3.0, 0.0)
	add_child(post)


func _material(colour: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = colour
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	return m
