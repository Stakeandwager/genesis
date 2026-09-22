extends RefCounted
class_name ClosureSolver

# --- Prototype 002A - Step A4: Closure solver (Amendments E and F) ---
# Adjusts corner and hairpin angles, and straight lengths, each by at most
# 20%, until the circuit ends on the start line facing the start direction.
#
# There are usually many ways to close a track. The solver picks the one
# that changes the AI's proposal least: the smallest total of squared
# relative changes. Chicanes are never changed.
#
# It never exceeds its limits, and never reports a success it didn't achieve.
# The AI proposes. Godot constructs. Godot validates. Godot measures.

const MAX_ANGLE_ADJUSTMENT := 0.20
const MAX_LENGTH_ADJUSTMENT := 0.20
const MAX_ITERATIONS := 60
const STEP := 0.0001

# What the solver aims for.
const AIM_DISTANCE := 0.05     # metres
const AIM_HEADING := 0.05      # degrees

# Protocol 002 section 17: what counts as closed.
const CLOSURE_FRACTION := 0.005        # 0.5% of track length
const MIN_ABSOLUTE_TOLERANCE := 2.0    # metres, floor for small tracks
const HEADING_TOLERANCE := 3.0         # degrees


# sections must already have passed SectionValidator and FeasibilityGate.
# target_turn_deg is the gate's +360 or -360.
static func solve(sections: Array, target_turn_deg: float) -> Dictionary:
	# The numbers the solver may change, as relative changes u (0 = as proposed).
	var vars: Array = []
	var proposed_length := 0.0
	for i in sections.size():
		var s: Dictionary = sections[i]
		proposed_length += TrackGeometry.section_length(s)
		match str(s["type"]):
			"straight":
				vars.append({"index": i, "kind": "length", "base": float(s["length"]), "limit": MAX_LENGTH_ADJUSTMENT})
			"corner", "hairpin":
				vars.append({"index": i, "kind": "angle", "base": float(s["angle"]), "limit": MAX_ANGLE_ADJUSTMENT})

	var n := vars.size()
	var u := PackedFloat64Array()
	u.resize(n)
	var locked: Array = []
	locked.resize(n)
	locked.fill(false)

	var target := deg_to_rad(target_turn_deg)
	# Heading error is weighted so a radian of heading counts like a typical
	# radius worth of distance; otherwise position would dominate.
	var weight := maxf(50.0, proposed_length / TAU)

	var r := _residual(sections, vars, u, target, weight)
	var iterations := 0

	while iterations < MAX_ITERATIONS and not _reached(r, weight, AIM_DISTANCE, AIM_HEADING):
		iterations += 1

		var free: Array = []
		for k in n:
			if not locked[k]:
				free.append(k)
		if free.size() < 3:
			break

		# How the end pose responds to each free number.
		var cols: Array = []
		for k in free:
			var nudged := u.duplicate()
			nudged[k] += STEP
			cols.append((_residual(sections, vars, nudged, target, weight) - r) / STEP)

		# Smallest-change solution of the linearised problem:
		#   u_free_new = J^T (J J^T)^-1 (J u_free - r)
		var m := [[0.0, 0.0, 0.0], [0.0, 0.0, 0.0], [0.0, 0.0, 0.0]]
		var rhs := -r
		for c in cols.size():
			var col: Vector3 = cols[c]
			rhs += col * u[free[c]]
			for a in 3:
				for b in 3:
					m[a][b] += col[a] * col[b]
		var mat := Basis(
			Vector3(m[0][0], m[1][0], m[2][0]),
			Vector3(m[0][1], m[1][1], m[2][1]),
			Vector3(m[0][2], m[1][2], m[2][2])
		)
		if absf(mat.determinant()) < 1e-12:
			break
		var y := mat.inverse() * rhs

		# Step towards that solution, backing off if it overshoots.
		var improved := false
		for scale in [1.0, 0.5, 0.25, 0.1]:
			var trial := u.duplicate()
			for c in cols.size():
				var k: int = free[c]
				var wanted: float = (cols[c] as Vector3).dot(y)
				var limit: float = vars[k]["limit"]
				trial[k] = clampf(u[k] + scale * (wanted - u[k]), -limit, limit)
			var trial_r := _residual(sections, vars, trial, target, weight)
			if trial_r.length() < r.length():
				u = trial
				r = trial_r
				improved = true
				break
		if not improved:
			break

		# A number that has reached its limit stays there.
		for k in n:
			if absf(u[k]) >= float(vars[k]["limit"]) - 1e-9:
				locked[k] = true

	# --- report ---
	var adjusted := _apply(sections, vars, u)
	var final_length := 0.0
	var final_net := 0.0
	var proposed_net := 0.0
	for i in adjusted.size():
		final_length += TrackGeometry.section_length(adjusted[i])
		if str(adjusted[i]["type"]) in ["corner", "hairpin"]:
			final_net += float(adjusted[i]["angle"])
			proposed_net += float(sections[i]["angle"])

	var max_angle := 0.0
	var max_length := 0.0
	for k in n:
		if vars[k]["kind"] == "angle":
			max_angle = maxf(max_angle, absf(u[k]))
		else:
			max_length = maxf(max_length, absf(u[k]))

	var distance := Vector2(r.x, r.y).length()
	var heading_error := absf(rad_to_deg(r.z / weight))
	var tolerance := maxf(final_length * CLOSURE_FRACTION, MIN_ABSOLUTE_TOLERANCE)
	var closed := distance <= tolerance and heading_error <= HEADING_TOLERANCE

	return {
		"ok": closed,
		"category": "" if closed else "FAILED_CLOSURE",
		"sections": adjusted,
		"iterations": iterations,
		"closure_distance": distance,
		"closure_heading_error": heading_error,
		"distance_tolerance": tolerance,
		"heading_tolerance": HEADING_TOLERANCE,
		"max_angle_adjustment": max_angle,
		"max_length_adjustment": max_length,
		"angle_limit": MAX_ANGLE_ADJUSTMENT,
		"length_limit": MAX_LENGTH_ADJUSTMENT,
		"proposed_length": proposed_length,
		"final_length": final_length,
		"proposed_net_turn": proposed_net,
		"final_net_turn": final_net,
	}


# --- helpers ---

static func _apply(sections: Array, vars: Array, u: PackedFloat64Array) -> Array:
	var out: Array = []
	for s in sections:
		out.append((s as Dictionary).duplicate())
	for k in vars.size():
		var i: int = vars[k]["index"]
		var value: float = float(vars[k]["base"]) * (1.0 + u[k])
		if vars[k]["kind"] == "length":
			out[i]["length"] = value
		else:
			out[i]["angle"] = value
	return out


# End-pose error as (x, z, weighted heading); all zero means closed.
static func _residual(sections: Array, vars: Array, u: PackedFloat64Array, target: float, weight: float) -> Vector3:
	var pose := TrackGeometry.end_pose(_apply(sections, vars, u))
	var p: Vector3 = pose[0]
	return Vector3(p.x, p.z, (float(pose[1]) - target) * weight)


static func _reached(r: Vector3, weight: float, distance: float, heading_deg: float) -> bool:
	return Vector2(r.x, r.y).length() <= distance and absf(rad_to_deg(r.z / weight)) <= heading_deg
