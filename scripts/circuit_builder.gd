extends Node3D
class_name CircuitBuilder

# --- Prototype 002A - Steps A2 and A4: Chain sections into road ---
# Each section starts exactly where the previous one ended, facing the same way.
# Sections never choose their own coordinates; the sequence decides placement.
# All geometry comes from TrackGeometry, the same maths the closure solver uses.

const ROAD_WIDTH := 12.0
# Lifted well clear of the ground: older GPUs have coarse depth precision
# at long camera distances, and a road too close to the ground disappears.
const ROAD_HEIGHT := 1.5

# Each section type gets its own road colour, so the composition is visible.
const SECTION_COLOURS := {
	"straight": Color(0.10, 0.10, 0.12),
	"corner": Color(0.95, 0.78, 0.22),
	"hairpin": Color(0.95, 0.36, 0.24),
	"chicane": Color(0.82, 0.36, 0.78),
}

var built := false
var centreline := PackedVector3Array()
var last_report: Dictionary = {}


# sections must already be validated. mark_end shows an orange post where the
# track stops, for tracks that don't close.
func build(sections: Array, mark_end := true) -> Dictionary:
	clear()

	var pos := Vector3.ZERO
	var heading := 0.0
	var total_length := 0.0
	var bounds_min := Vector2(INF, INF)    # (x, z)
	var bounds_max := Vector2(-INF, -INF)

	for i in sections.size():
		var s: Dictionary = sections[i]
		var samples := TrackGeometry.sample(pos, heading, s)
		total_length += TrackGeometry.section_length(s)
		_add_road_piece(i, str(s["type"]), samples)

		for sample in samples:
			var p: Vector3 = sample[0]
			centreline.append(p)
			bounds_min = Vector2(minf(bounds_min.x, p.x), minf(bounds_min.y, p.z))
			bounds_max = Vector2(maxf(bounds_max.x, p.x), maxf(bounds_max.y, p.z))

		var end_sample: Array = samples[samples.size() - 1]
		pos = end_sample[0]
		heading = end_sample[1]

	_add_start_line()
	if mark_end:
		_add_end_marker(pos)
	built = true

	last_report = {
		"section_count": sections.size(),
		"total_length": total_length,
		"end_position": pos,
		"end_gap": Vector2(pos.x, pos.z).length(),
		"heading_error": rad_to_deg(wrapf(heading, -PI, PI)),
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


# --- visuals ---

func _add_road_piece(index: int, type: String, samples: Array) -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var half := ROAD_WIDTH * 0.5
	var lift := Vector3.UP * ROAD_HEIGHT

	for k in samples.size() - 1:
		var p0: Vector3 = samples[k][0]
		var h0: float = samples[k][1]
		var p1: Vector3 = samples[k + 1][0]
		var h1: float = samples[k + 1][1]
		var l0 := p0 - TrackGeometry.right(h0) * half + lift
		var r0 := p0 + TrackGeometry.right(h0) * half + lift
		var l1 := p1 - TrackGeometry.right(h1) * half + lift
		var r1 := p1 + TrackGeometry.right(h1) * half + lift
		# Winding chosen so the road faces up, towards the light.
		for v in [l0, l1, r0, r0, l1, r1]:
			st.set_normal(Vector3.UP)
			st.add_vertex(v)

	var piece := MeshInstance3D.new()
	piece.name = "Section_%d_%s" % [index + 1, type]
	piece.mesh = st.commit()
	piece.material_override = _material(SECTION_COLOURS.get(type, Color(0.1, 0.1, 0.12)))
	add_child(piece)


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
