extends Node3D
class_name CircuitBuilder

# --- Prototype 002A - Step A2: Chain sections into road ---
# Each section starts exactly where the previous one ended, facing the same way.
# Sections never choose their own coordinates; the sequence decides placement.
#
# Heading convention (Amendment A): heading 0 faces -Z (away from the camera),
# positive angles turn right, i.e. clockwise when viewed from above.
#
# A2 builds an OPEN track and reports how far it ends from the start.
# Closing the circuit is step A4.

const ROAD_WIDTH := 12.0
# Lifted well clear of the ground: older GPUs have coarse depth precision
# at long camera distances, and a road too close to the ground disappears.
const ROAD_HEIGHT := 1.5
const SAMPLE_SPACING := 4.0

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


# sections must already be validated by SectionValidator.
func build(sections: Array) -> Dictionary:
	clear()

	var pos := Vector3.ZERO
	var heading := 0.0  # radians
	var total_length := 0.0
	var bounds_min := Vector2(INF, INF)    # (x, z)
	var bounds_max := Vector2(-INF, -INF)

	for i in sections.size():
		var s: Dictionary = sections[i]
		var type := str(s["type"])
		var samples: Array = []

		match type:
			"straight":
				var length := float(s["length"])
				samples = [[pos, heading], [pos + _forward(heading) * length, heading]]
				total_length += length

			"corner", "hairpin":
				var radius := float(s["radius"])
				var turn := deg_to_rad(float(s["angle"]))
				samples = _arc(pos, heading, radius, turn)
				total_length += radius * absf(turn)

			"chicane":
				# Amendment C: two equal and opposite arcs, net turn zero.
				var radius := float(s["radius"])
				var theta := acos(1.0 - float(s["offset"]) / (2.0 * radius))
				var first := -theta if str(s["direction"]) == "left" else theta
				var part_a := _arc(pos, heading, radius, first)
				var joint: Array = part_a[part_a.size() - 1]
				var part_b := _arc(joint[0], joint[1], radius, -first)
				part_b.remove_at(0)
				samples = part_a + part_b
				total_length += 2.0 * radius * theta

		_add_road_piece(i, type, samples)

		for sample in samples:
			var p: Vector3 = sample[0]
			centreline.append(p)
			bounds_min = Vector2(minf(bounds_min.x, p.x), minf(bounds_min.y, p.z))
			bounds_max = Vector2(maxf(bounds_max.x, p.x), maxf(bounds_max.y, p.z))

		var end_sample: Array = samples[samples.size() - 1]
		pos = end_sample[0]
		heading = end_sample[1]

	_add_start_line()
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


# --- geometry ---

func _forward(heading: float) -> Vector3:
	return Vector3(sin(heading), 0.0, -cos(heading))


func _right(heading: float) -> Vector3:
	return Vector3(cos(heading), 0.0, sin(heading))


# Returns samples [position, heading] along an arc. Positive turn = right.
func _arc(start: Vector3, heading: float, radius: float, turn: float) -> Array:
	var side := signf(turn)
	var centre := start + _right(heading) * radius * side
	var steps := maxi(4, int(ceil(radius * absf(turn) / SAMPLE_SPACING)))
	var out: Array = []
	for k in steps + 1:
		var h := heading + turn * (float(k) / float(steps))
		out.append([centre - _right(h) * radius * side, h])
	return out


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
		var l0 := p0 - _right(h0) * half + lift
		var r0 := p0 + _right(h0) * half + lift
		var l1 := p1 - _right(h1) * half + lift
		var r1 := p1 + _right(h1) * half + lift
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


# Marks where the track currently ends, until closure exists (step A4).
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
