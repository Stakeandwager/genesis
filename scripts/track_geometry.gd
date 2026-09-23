class_name TrackGeometry
extends RefCounted

## Universal Track Geometry Engine (Prototype 002B)
## Provides static sampling, vector directions, length calculations, and final pose evaluation.

# Calculate length of an individual section statically
static func section_length(section: Dictionary) -> float:
	var type = section.get("type", "straight")
	var length = section.get("length", 0.0)
	var radius = section.get("radius", 50.0)
	var angle_deg = section.get("angle", 0.0)
	
	match type:
		"straight", "uphill", "downhill", "crest", "dip":
			return length
		"corner", "hairpin", "banked_corner":
			return radius * abs(deg_to_rad(angle_deg))
		"chicane":
			return length + section.get("offset", 10.0)
		"loop_segment":
			return radius * abs(deg_to_rad(angle_deg))
		_:
			return length

# Returns the forward vector based on heading (yaw angle)
static func forward(heading: float) -> Vector3:
	return Vector3(sin(heading), 0.0, cos(heading))

# Returns the right vector perpendicular to the heading for road width extrusion
static func right(heading: float) -> Vector3:
	var fwd = forward(heading)
	return fwd.cross(Vector3.UP).normalized()

# Returns directional angle change value for chicanes used by track_metrics.gd
static func chicane_turn(section: Dictionary) -> float:
	var angle_deg = section.get("angle", 45.0)
	return float(angle_deg)

# Computes the final pose [position, heading] after traversing all track sections
static func end_pose(sections: Array) -> Array:
	var pos = Vector3.ZERO
	var heading = 0.0
	for s in sections:
		var samples = sample(pos, heading, s)
		if not samples.is_empty():
			var last = samples[samples.size() - 1]
			pos = last[0]
			heading = last[1]
	return [pos, heading]

# Sample points along a section returning an array of [position_vector3, heading, pitch, bank]
static func sample(start_pos: Vector3, start_heading: float, section: Dictionary) -> Array:
	var samples: Array = []
	var type = section.get("type", "straight")
	var length = section.get("length", 100.0)
	var radius = section.get("radius", 50.0)
	var angle_deg = section.get("angle", 90.0)
	var grade_pct = section.get("grade", 0.0)
	var bank_deg = section.get("bank", 0.0)
	
	var steps = max(int(section_length(section) / 5.0), 2)
	var heading = start_heading
	var pitch = atan(grade_pct / 100.0)
	
	match type:
		"straight", "uphill", "downhill", "crest", "dip":
			var step_len = length / float(steps)
			for i in range(steps + 1):
				var dist = i * step_len
				var p = start_pos + Vector3(sin(heading), sin(pitch) * dist, cos(heading)) * dist
				samples.append([p, heading, pitch, deg_to_rad(bank_deg)])
				
		"corner", "hairpin", "banked_corner":
			var angle_rad = deg_to_rad(angle_deg)
			var step_angle = angle_rad / float(steps)
			for i in range(steps + 1):
				var a = i * step_angle
				var h = heading + a
				var local_x = radius * (cos(heading) - cos(h))
				var local_z = radius * (sin(h) - sin(heading))
				var p = start_pos + Vector3(local_x, i * (sin(pitch) * (radius * abs(step_angle) / float(steps))), local_z)
				samples.append([p, h, pitch, deg_to_rad(bank_deg)])
				
		"chicane":
			for i in range(steps + 1):
				var t = float(i) / float(steps)
				var p = start_pos.lerp(start_pos + forward(heading) * length, t)
				samples.append([p, heading, pitch, 0.0])
				
		"loop_segment":
			var loop_rad = deg_to_rad(angle_deg)
			var step_angle = loop_rad / float(steps)
			for i in range(steps + 1):
				var a = i * step_angle
				var h = heading + a
				var p = start_pos + Vector3(sin(h) * radius, cos(a) * radius, cos(h) * radius)
				samples.append([p, h, pitch + a, 0.0])
				
	return samples
