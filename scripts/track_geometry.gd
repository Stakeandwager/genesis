extends RefCounted
class_name TrackGeometry

# --- Prototype 002B: shared track geometry, flat and vertical ---
# The circuit builder, the closure solver, the separation check and the metrics
# all use these functions, so what is solved is exactly what is built.
#
# Carried state is a position (x, y, z) and a heading. Height lives in
# position.y. Heading is yaw only, and accumulates without wrapping, so a
# closed circuit ends at +/- 2*PI.
#
# Heading convention (Amendment A): heading 0 faces -Z, positive angles turn
# right, that is clockwise seen from above.
#
# Which sections change what:
#   straight                       ground distance only
#   uphill, downhill               ground distance and height
#   crest, dip                     up then down, or down then up, net height 0
#   corner, hairpin, banked_corner yaw only, height unchanged
#   chicane                        steps sideways, same heading, no net yaw
#   loop_segment                   a vertical loop: pitch and height, NO yaw

const SAMPLE_SPACING := 4.0

const SLOPE_TYPES := ["uphill", "downhill", "crest", "dip"]
const STRAIGHT_FAMILY := ["straight", "uphill", "downhill", "crest", "dip"]
const YAW_TYPES := ["corner", "hairpin", "banked_corner"]


static func forward(heading: float) -> Vector3:
	return Vector3(sin(heading), 0.0, -cos(heading))


static func right(heading: float) -> Vector3:
	return Vector3(cos(heading), 0.0, sin(heading))


# Up or down. A crest rises then falls; a dip falls then rises.
static func grade_sign(type: String) -> float:
	match type:
		"uphill", "crest":
			return 1.0
		"downhill", "dip":
			return -1.0
	return 0.0


# The angle of the slope, in radians. Grade is a percentage.
static func pitch_of(section: Dictionary) -> float:
	if not str(section.get("type", "")) in SLOPE_TYPES:
		return 0.0
	return atan(float(section.get("grade", 0.0)) / 100.0)


# Path length along the road surface, not the ground distance beneath it.
static func section_length(section: Dictionary) -> float:
	var type := str(section.get("type", ""))
	match type:
		"straight", "uphill", "downhill", "crest", "dip":
			return float(section.get("length", 0.0))
		"corner", "hairpin", "banked_corner", "loop_segment":
			return float(section.get("radius", 0.0)) * absf(deg_to_rad(float(section.get("angle", 0.0))))
		"chicane":
			return 2.0 * float(section.get("radius", 0.0)) * absf(chicane_turn(section))
	return 0.0


# Height gained or lost across a section. Crests and dips return to their
# starting height, so they gain nothing.
static func height_change(section: Dictionary) -> float:
	var type := str(section.get("type", ""))
	if type == "uphill" or type == "downhill":
		return grade_sign(type) * float(section.get("length", 0.0)) * sin(pitch_of(section))
	if type == "loop_segment":
		var radius := float(section.get("radius", 0.0))
		return radius * (1.0 - cos(deg_to_rad(float(section.get("angle", 0.0)))))
	return 0.0


# Amendment C: the signed turn of a chicane's first arc, in RADIANS.
static func chicane_turn(section: Dictionary) -> float:
	var radius := float(section.get("radius", 1.0))
	var offset := float(section.get("offset", 0.0))
	var theta := acos(clampf(1.0 - offset / (2.0 * radius), -1.0, 1.0))
	return -theta if str(section.get("direction", "right")) == "left" else theta


# Exact end pose [position, heading] after one section.
static func advance(pos: Vector3, heading: float, s: Dictionary) -> Array:
	var type := str(s["type"])

	match type:
		"straight", "uphill", "downhill", "crest", "dip":
			var length := float(s.get("length", 0.0))
			var pitch := pitch_of(s)
			var run := length * cos(pitch)
			return [pos + forward(heading) * run + Vector3.UP * height_change(s), heading]

		"corner", "hairpin", "banked_corner":
			return _arc_end(pos, heading, float(s["radius"]), deg_to_rad(float(s["angle"])))

		"chicane":
			var radius := float(s["radius"])
			var first := chicane_turn(s)
			var mid := _arc_end(pos, heading, radius, first)
			return _arc_end(mid[0], mid[1], radius, -first)

		"loop_segment":
			# A vertical loop: the track pitches up and over, keeping its heading.
			var radius := float(s["radius"])
			var turn := deg_to_rad(float(s["angle"]))
			return [pos + forward(heading) * (radius * sin(turn)) + Vector3.UP * (radius * (1.0 - cos(turn))), heading]

	return [pos, heading]


static func end_pose(sections: Array) -> Array:
	var pos := Vector3.ZERO
	var heading := 0.0
	for s in sections:
		var pose := advance(pos, heading, s)
		pos = pose[0]
		heading = pose[1]
	return [pos, heading]


# Samples [position, heading, pitch, bank] along one section, for drawing.
static func sample(pos: Vector3, heading: float, s: Dictionary) -> Array:
	var type := str(s["type"])
	var bank := deg_to_rad(float(s.get("bank", 0.0)))
	var steps := maxi(2, int(ceil(section_length(s) / SAMPLE_SPACING)))
	var out: Array = []

	match type:
		"straight", "uphill", "downhill", "crest", "dip":
			var length := float(s.get("length", 0.0))
			var pitch := pitch_of(s)
			var sign := grade_sign(type)
			var run := length * cos(pitch)
			var rise := length * sin(pitch)
			for k in steps + 1:
				var t := float(k) / float(steps)
				var height := 0.0
				var shown_pitch := sign * pitch
				if type == "crest" or type == "dip":
					# Up then down, or down then up: half each way, net zero.
					height = (t * 2.0 if t <= 0.5 else (1.0 - t) * 2.0) * rise * sign * 0.5
					shown_pitch = sign * pitch if t <= 0.5 else -sign * pitch
				else:
					height = t * rise * sign
				out.append([pos + forward(heading) * (run * t) + Vector3.UP * height, heading, shown_pitch, bank])
			return out

		"corner", "hairpin", "banked_corner":
			return _arc_samples(pos, heading, float(s["radius"]), deg_to_rad(float(s["angle"])), bank)

		"chicane":
			var radius := float(s["radius"])
			var first := chicane_turn(s)
			var part_a := _arc_samples(pos, heading, radius, first, bank)
			var joint: Array = part_a[part_a.size() - 1]
			var part_b := _arc_samples(joint[0], joint[1], radius, -first, bank)
			part_b.remove_at(0)
			return part_a + part_b

		"loop_segment":
			var radius := float(s["radius"])
			var turn := deg_to_rad(float(s["angle"]))
			var fwd := forward(heading)
			for k in steps + 1:
				var a := turn * (float(k) / float(steps))
				out.append([pos + fwd * (radius * sin(a)) + Vector3.UP * (radius * (1.0 - cos(a))), heading, a, bank])
			return out

	return [[pos, heading, 0.0, bank]]


# --- internal ---

static func _arc_end(start: Vector3, heading: float, radius: float, turn: float) -> Array:
	var side := signf(turn)
	var centre := start + right(heading) * radius * side
	var h := heading + turn
	return [centre - right(h) * radius * side, h]


static func _arc_samples(start: Vector3, heading: float, radius: float, turn: float, bank: float) -> Array:
	var side := signf(turn)
	var centre := start + right(heading) * radius * side
	var steps := maxi(4, int(ceil(radius * absf(turn) / SAMPLE_SPACING)))
	var out: Array = []
	for k in steps + 1:
		var h := heading + turn * (float(k) / float(steps))
		out.append([centre - right(h) * radius * side, h, 0.0, bank])
	return out
