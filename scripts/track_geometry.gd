extends RefCounted
class_name TrackGeometry

# --- Prototype 002A: shared track geometry ---
# The circuit builder and the closure solver both use these functions,
# so the track that is solved is exactly the track that is built.
#
# Heading convention (Amendment A): heading 0 faces -Z (away from the camera),
# positive angles turn right, i.e. clockwise when viewed from above.
# Headings accumulate without wrapping, so a full circuit ends at +/- 2*PI.

const SAMPLE_SPACING := 4.0


static func forward(heading: float) -> Vector3:
	return Vector3(sin(heading), 0.0, -cos(heading))


static func right(heading: float) -> Vector3:
	return Vector3(cos(heading), 0.0, sin(heading))


# Exact end pose [position, heading] after one section.
static func advance(pos: Vector3, heading: float, s: Dictionary) -> Array:
	match str(s["type"]):
		"straight":
			return [pos + forward(heading) * float(s["length"]), heading]
		"corner", "hairpin":
			return _arc_end(pos, heading, float(s["radius"]), deg_to_rad(float(s["angle"])))
		"chicane":
			var radius := float(s["radius"])
			var first := chicane_turn(s)
			var mid := _arc_end(pos, heading, radius, first)
			return _arc_end(mid[0], mid[1], radius, -first)
	return [pos, heading]


# Exact end pose after a whole list of sections, starting at the origin.
static func end_pose(sections: Array) -> Array:
	var pos := Vector3.ZERO
	var heading := 0.0
	for s in sections:
		var pose := advance(pos, heading, s)
		pos = pose[0]
		heading = pose[1]
	return [pos, heading]


# Samples [position, heading] along one section, for drawing.
static func sample(pos: Vector3, heading: float, s: Dictionary) -> Array:
	match str(s["type"]):
		"straight":
			return [[pos, heading], [pos + forward(heading) * float(s["length"]), heading]]
		"corner", "hairpin":
			return arc_samples(pos, heading, float(s["radius"]), deg_to_rad(float(s["angle"])))
		"chicane":
			var radius := float(s["radius"])
			var first := chicane_turn(s)
			var part_a := arc_samples(pos, heading, radius, first)
			var joint: Array = part_a[part_a.size() - 1]
			var part_b := arc_samples(joint[0], joint[1], radius, -first)
			part_b.remove_at(0)
			return part_a + part_b
	return [[pos, heading]]


static func section_length(s: Dictionary) -> float:
	match str(s["type"]):
		"straight":
			return float(s["length"])
		"corner", "hairpin":
			return float(s["radius"]) * absf(deg_to_rad(float(s["angle"])))
		"chicane":
			return 2.0 * float(s["radius"]) * absf(chicane_turn(s))
	return 0.0


# Amendment C: the signed turn of a chicane's first arc, in radians.
static func chicane_turn(s: Dictionary) -> float:
	var radius := float(s["radius"])
	var theta := acos(1.0 - float(s["offset"]) / (2.0 * radius))
	return -theta if str(s["direction"]) == "left" else theta


static func arc_samples(start: Vector3, heading: float, radius: float, turn: float) -> Array:
	var side := signf(turn)
	var centre := start + right(heading) * radius * side
	var steps := maxi(4, int(ceil(radius * absf(turn) / SAMPLE_SPACING)))
	var out: Array = []
	for k in steps + 1:
		var h := heading + turn * (float(k) / float(steps))
		out.append([centre - right(h) * radius * side, h])
	return out


static func _arc_end(start: Vector3, heading: float, radius: float, turn: float) -> Array:
	var side := signf(turn)
	var centre := start + right(heading) * radius * side
	var h := heading + turn
	return [centre - right(h) * radius * side, h]
