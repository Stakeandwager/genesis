extends WorldModule
class_name FarmModule

# --- The farm module: the first world that is not a racing circuit ---
# The AI proposes what is on the farm. This module works out where everything
# goes, checks the result can actually work, measures it, and builds it.
#
# The farm's version of "the circuit must close" is: every zone must touch a
# lane, and every lane must connect to the gate. A farm you cannot drive a
# tractor around is refused, exactly as an unclosable circuit is.

const ZONE_TYPES := ["crop", "pasture", "orchard", "pond", "barn", "farmhouse", "silo", "yard"]
const BUILDINGS := ["barn", "farmhouse", "silo"]

const MIN_ZONES := 2
const MAX_ZONES := 24
const FIELD_SIDE := Vector2(20.0, 300.0)      # metres, for fields and water
const BUILDING_SIDE := Vector2(5.0, 60.0)     # metres, for buildings
const LANE_WIDTH := 6.0
const MARGIN := 12.0                          # between the fence and the zones

# Heights. A farm can be viewed from a long way up, where older graphics chips
# cannot separate two surfaces a few centimetres apart, so everything is given
# real thickness instead.
const PAD_HEIGHT := 1.0                       # the bare ground and lanes
const ZONE_HEIGHT := 1.6                      # fields sit proud of the lanes
const POND_HEIGHT := 1.3                      # water sits lower
const FENCE_HEIGHT := 2.4

const ZONE_COLOURS := {
	"crop": Color(0.83, 0.72, 0.28),
	"pasture": Color(0.42, 0.62, 0.30),
	"orchard": Color(0.24, 0.45, 0.26),
	"pond": Color(0.26, 0.46, 0.66),
	"barn": Color(0.68, 0.24, 0.20),
	"farmhouse": Color(0.86, 0.82, 0.72),
	"silo": Color(0.70, 0.72, 0.74),
	"yard": Color(0.62, 0.56, 0.44),
}

const CROP_COLOURS := {
	"corn": Color(0.87, 0.74, 0.25),
	"wheat": Color(0.88, 0.80, 0.45),
	"barley": Color(0.82, 0.76, 0.40),
	"soy": Color(0.55, 0.66, 0.32),
	"potatoes": Color(0.60, 0.52, 0.34),
	"vines": Color(0.45, 0.35, 0.50),
}


func command() -> String:
	return "CREATE_FARM"


func display_name() -> String:
	return "farm"


func prompt_section() -> String:
	return """CREATE_FARM - design a farm
{"command": "CREATE_FARM", "parameters": {"intent": {"style": STYLE}, "zones": [ZONE, ZONE, ...]}}

ZONE TYPES (only these, with exactly these fields)
crop: {"type": "crop", "crop": NAME, "width": W, "depth": D} where NAME is corn, wheat, barley, soy, potatoes or vines
pasture, orchard, pond, yard: {"type": TYPE, "width": W, "depth": D}
barn, farmhouse, silo: {"type": TYPE, "width": W, "depth": D}
Fields, water and yards are 20 to 300 metres a side. Buildings are 5 to 60 metres a side.
Use 2 to 24 zones. Do not give positions: the game works out the layout, the fence and the lanes."""


# --- what the AI proposed ---

func validate(parameters: Dictionary) -> Dictionary:
	var errors: Array = []
	var clean: Array = []

	if parameters.has("intent") and typeof(parameters["intent"]) != TYPE_DICTIONARY:
		errors.append("intent must be an object, for example {\"style\": \"smallholding\"}")

	var raw = parameters.get("zones", null)
	if typeof(raw) != TYPE_ARRAY:
		return {"ok": false, "errors": ["zones must be a list"], "content": {}}

	var zones: Array = raw
	if zones.size() < MIN_ZONES or zones.size() > MAX_ZONES:
		errors.append("a farm needs %d to %d zones (got %d)" % [MIN_ZONES, MAX_ZONES, zones.size()])

	for i in zones.size():
		var n := i + 1
		if typeof(zones[i]) != TYPE_DICTIONARY:
			errors.append("zone %d is not an object" % n)
			continue

		var zone: Dictionary = zones[i]
		var type := str(zone.get("type", ""))
		if not type in ZONE_TYPES:
			if type == "":
				errors.append("zone %d has no type" % n)
			else:
				errors.append("zone %d: unknown type '%s' (allowed: %s)" % [n, type, ", ".join(ZONE_TYPES)])
			continue

		var limits := BUILDING_SIDE if type in BUILDINGS else FIELD_SIDE
		var width := _number(zone, "width", n, type, errors)
		var depth := _number(zone, "depth", n, type, errors)
		if is_nan(width) or is_nan(depth):
			continue

		var sized_ok := true
		for pair in [["width", width], ["depth", depth]]:
			var value: float = pair[1]
			if value < limits.x or value > limits.y:
				errors.append("zone %d (%s): %s %.0f m is outside %.0f-%.0f m" % [n, type, pair[0], value, limits.x, limits.y])
				sized_ok = false
		if not sized_ok:
			continue

		var entry := {"type": type, "width": width, "depth": depth}
		if type == "crop":
			var crop := str(zone.get("crop", "")).to_lower()
			if crop == "":
				errors.append("zone %d (crop): missing 'crop', for example corn or wheat" % n)
				continue
			if not CROP_COLOURS.has(crop):
				errors.append("zone %d (crop): '%s' is not a crop this farm grows (allowed: %s)" % [n, crop, ", ".join(CROP_COLOURS.keys())])
				continue
			entry["crop"] = crop
		clean.append(entry)

	return {
		"ok": errors.is_empty(),
		"errors": errors,
		"content": {"zones": clean},
	}


# --- where everything goes ---

# Zones are laid out in rows with lanes between them, largest first, then the
# fence is put round the lot and a gate cut into the south side.
func solve(content: Dictionary) -> Dictionary:
	var zones: Array = (content["zones"] as Array).duplicate(true)
	if zones.is_empty():
		return {"ok": false, "category": "FAILED_LAYOUT", "reasons": ["there is nothing to lay out"], "layout": {}}

	zones.sort_custom(func(a, b): return float(a["width"]) * float(a["depth"]) > float(b["width"]) * float(b["depth"]))

	# A working width wide enough for the widest zone and a sensible shape.
	var total_area := 0.0
	var widest := 0.0
	for z in zones:
		total_area += float(z["width"]) * float(z["depth"])
		widest = maxf(widest, float(z["width"]))
	var working_width := maxf(widest, sqrt(total_area) * 1.35)

	var placed: Array = []
	var cursor_x := 0.0
	var cursor_z := 0.0
	var row_depth := 0.0

	for z in zones:
		var w := float(z["width"])
		var d := float(z["depth"])
		if cursor_x > 0.0 and cursor_x + w > working_width:
			cursor_x = 0.0
			cursor_z += row_depth + LANE_WIDTH
			row_depth = 0.0
		var entry: Dictionary = z.duplicate()
		entry["x"] = cursor_x
		entry["z"] = cursor_z
		placed.append(entry)
		cursor_x += w + LANE_WIDTH
		row_depth = maxf(row_depth, d)

	var used_width := 0.0
	var used_depth := cursor_z + row_depth
	for p in placed:
		used_width = maxf(used_width, float(p["x"]) + float(p["width"]))

	# Centre everything, then put the fence round it.
	var shift := Vector2(-used_width * 0.5, -used_depth * 0.5)
	for p in placed:
		p["x"] = float(p["x"]) + shift.x
		p["z"] = float(p["z"]) + shift.y

	var layout := {
		"zones": placed,
		"fence_min": Vector2(shift.x - MARGIN, shift.y - MARGIN),
		"fence_max": Vector2(shift.x + used_width + MARGIN, shift.y + used_depth + MARGIN),
		"gate": Vector2(0.0, shift.y + used_depth + MARGIN),
		"lane_width": LANE_WIDTH,
	}

	var reach := _check_reachable(layout)
	if not reach["ok"]:
		return {"ok": false, "category": "FAILED_LAYOUT", "reasons": reach["reasons"], "layout": layout}

	return {"ok": true, "category": "", "reasons": [], "layout": layout}


# Every zone must have a lane along at least one edge, or it cannot be worked.
func _check_reachable(layout: Dictionary) -> Dictionary:
	var zones: Array = layout["zones"]
	var reasons: Array = []
	for i in zones.size():
		var z: Dictionary = zones[i]
		var touching := false
		var left := float(z["x"])
		var right := left + float(z["width"])
		var top := float(z["z"])
		var bottom := top + float(z["depth"])

		# A lane runs along an edge if nothing else is flush against it.
		for edge in ["left", "right", "top", "bottom"]:
			var blocked := false
			for j in zones.size():
				if i == j:
					continue
				var o: Dictionary = zones[j]
				var o_left := float(o["x"])
				var o_right := o_left + float(o["width"])
				var o_top := float(o["z"])
				var o_bottom := o_top + float(o["depth"])
				var overlaps_z: bool = o_top < bottom and o_bottom > top
				var overlaps_x: bool = o_left < right and o_right > left
				if edge == "left" and overlaps_z and absf(o_right - left) < 0.5:
					blocked = true
				if edge == "right" and overlaps_z and absf(o_left - right) < 0.5:
					blocked = true
				if edge == "top" and overlaps_x and absf(o_bottom - top) < 0.5:
					blocked = true
				if edge == "bottom" and overlaps_x and absf(o_top - bottom) < 0.5:
					blocked = true
			if not blocked:
				touching = true
				break

		if not touching:
			reasons.append("zone %d (%s) is walled in on every side: nothing could reach it" % [i + 1, z["type"]])

	return {"ok": reasons.is_empty(), "reasons": reasons}


# --- measurement ---

func measure(layout: Dictionary) -> Dictionary:
	var zones: Array = layout["zones"]
	var counts := {}
	for t in ZONE_TYPES:
		counts[t] = 0

	var worked_area := 0.0
	var building_area := 0.0
	var water_area := 0.0
	var largest := 0.0
	var crops := {}

	for z in zones:
		var type := str(z["type"])
		counts[type] = int(counts.get(type, 0)) + 1
		var area := float(z["width"]) * float(z["depth"])
		largest = maxf(largest, area)
		if type in BUILDINGS:
			building_area += area
		elif type == "pond":
			water_area += area
		elif type == "yard":
			pass
		else:
			worked_area += area
			if type == "crop":
				var crop := str(z.get("crop", "unknown"))
				crops[crop] = float(crops.get(crop, 0.0)) + area

	var fence := _fence(layout)
	var fence_min: Vector2 = fence[0]
	var fence_max: Vector2 = fence[1]
	var enclosed := (fence_max.x - fence_min.x) * (fence_max.y - fence_min.y)

	return {
		"zone_count": zones.size(),
		"counts": counts,
		"enclosed_area": enclosed,
		"worked_area": worked_area,
		"worked_ratio": worked_area / enclosed if enclosed > 0.0 else 0.0,
		"building_area": building_area,
		"water_area": water_area,
		"largest_zone": largest,
		"crops": crops,
		"fence_length": 2.0 * ((fence_max.x - fence_min.x) + (fence_max.y - fence_min.y)),
		"farm_width": fence_max.x - fence_min.x,
		"farm_depth": fence_max.y - fence_min.y,
	}


# --- 003: the farm as a container ---

# Where the fence actually goes. Normally that is where solve() put it, but
# a plan may have asked this farm to contain another world, and then the
# fence is pushed out to make room. The zones never move and never change
# size: the farm the player described is exactly the farm they get, with
# more land around it.
func _fence(layout: Dictionary) -> Array:
	return grown(layout["fence_min"], layout["fence_max"], layout)


func extent(layout: Dictionary) -> Vector2:
	var fence := _fence(layout)
	return (fence[1] as Vector2) - (fence[0] as Vector2)


# --- geometry ---

func build(root: Node3D, layout: Dictionary) -> Dictionary:
	var fence := _fence(layout)
	var fence_min: Vector2 = fence[0]
	var fence_max: Vector2 = fence[1]

	# The ground inside the fence: lanes are simply what is left uncovered.
	_add_slab(root, "Ground", fence_min, fence_max, PAD_HEIGHT, Color(0.44, 0.40, 0.30))

	for i in (layout["zones"] as Array).size():
		var z: Dictionary = layout["zones"][i]
		var type := str(z["type"])
		var from := Vector2(float(z["x"]), float(z["z"]))
		var to := from + Vector2(float(z["width"]), float(z["depth"]))
		var colour: Color = ZONE_COLOURS[type]
		if type == "crop":
			colour = CROP_COLOURS.get(str(z.get("crop", "")), colour)

		if type in BUILDINGS:
			_add_building(root, "%s_%d" % [type, i + 1], from, to, colour, 14.0 if type == "silo" else 9.0)
		else:
			_add_slab(root, "%s_%d" % [type, i + 1], from, to, POND_HEIGHT if type == "pond" else ZONE_HEIGHT, colour)

	_add_fence(root, fence_min, fence_max, layout["gate"])

	return {"bounds_min": fence_min, "bounds_max": fence_max}


func _add_slab(root: Node3D, name_for: String, from: Vector2, to: Vector2, height: float, colour: Color) -> void:
	var slab := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(to.x - from.x, height, to.y - from.y)
	slab.mesh = box
	slab.name = name_for
	slab.material_override = _material(colour)
	slab.position = Vector3((from.x + to.x) * 0.5, height * 0.5, (from.y + to.y) * 0.5)
	root.add_child(slab)


func _add_building(root: Node3D, name_for: String, from: Vector2, to: Vector2, colour: Color, height: float) -> void:
	var walls := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(to.x - from.x, height, to.y - from.y)
	walls.mesh = box
	walls.name = name_for
	walls.material_override = _material(colour)
	walls.position = Vector3((from.x + to.x) * 0.5, PAD_HEIGHT + height * 0.5, (from.y + to.y) * 0.5)
	root.add_child(walls)

	var roof := MeshInstance3D.new()
	var cap := BoxMesh.new()
	cap.size = Vector3(to.x - from.x + 1.0, 0.6, to.y - from.y + 1.0)
	roof.mesh = cap
	roof.material_override = _material(colour.darkened(0.35))
	roof.position = Vector3((from.x + to.x) * 0.5, PAD_HEIGHT + height + 0.4, (from.y + to.y) * 0.5)
	root.add_child(roof)


func _add_fence(root: Node3D, from: Vector2, to: Vector2, gate: Vector2) -> void:
	var colour := Color(0.46, 0.38, 0.28)
	var post_gap := 8.0
	var gate_width := 12.0

	for side in 4:
		var start := Vector2.ZERO
		var finish := Vector2.ZERO
		match side:
			0: start = from; finish = Vector2(to.x, from.y)
			1: start = Vector2(to.x, from.y); finish = to
			2: start = to; finish = Vector2(from.x, to.y)
			3: start = Vector2(from.x, to.y); finish = from

		var length := start.distance_to(finish)
		var steps := maxi(2, int(length / post_gap))
		for k in steps + 1:
			var at := start.lerp(finish, float(k) / float(steps))
			# Leave a gap for the gate.
			if absf(at.y - gate.y) < 0.5 and absf(at.x - gate.x) < gate_width * 0.5:
				continue
			var post := MeshInstance3D.new()
			var box := BoxMesh.new()
			box.size = Vector3(0.8, FENCE_HEIGHT, 0.8)
			post.mesh = box
			post.material_override = _material(colour)
			post.position = Vector3(at.x, PAD_HEIGHT + FENCE_HEIGHT * 0.5, at.y)
			root.add_child(post)

		# A rail between the posts, so the boundary is a line and not a row of dots.
		var along := (finish - start)
		var rail := MeshInstance3D.new()
		var rail_box := BoxMesh.new()
		rail_box.size = Vector3(maxf(along.length(), 0.6), 0.5, 0.5) if absf(along.y) < 0.01 else Vector3(0.5, 0.5, maxf(along.length(), 0.6))
		rail.mesh = rail_box
		rail.material_override = _material(colour.lightened(0.1))
		rail.position = Vector3((start.x + finish.x) * 0.5, PAD_HEIGHT + FENCE_HEIGHT * 0.75, (start.y + finish.y) * 0.5)
		root.add_child(rail)


func _material(colour: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = colour
	return m


# "a farm with a farmhouse, a 200 m orchard and a 300 m corn field"
#
# Zones of the same type and size are counted together, because "four 50 m
# crop fields" is what the player asked for and four separate entries is not
# how they think about it. A crop is named by what grows in it: "corn field"
# rather than "crop", since getting wheat when you asked for corn is an
# understanding failure the player must be able to see.
func readback(parameters: Dictionary) -> String:
	var raw = parameters.get("zones", null)
	if typeof(raw) != TYPE_ARRAY or (raw as Array).is_empty():
		return "a farm"

	var order: Array = []
	var groups := {}
	for entry in (raw as Array):
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var zone: Dictionary = entry
		var type := str(zone.get("type", "")).to_lower()
		if type == "":
			continue
		var width := float(zone.get("width", 0.0))
		var depth := float(zone.get("depth", 0.0))
		var name := type
		if type == "crop":
			var crop := str(zone.get("crop", "")).to_lower()
			name = (crop + " field") if crop != "" else "crop field"
		var key := "%s|%.0f|%.0f" % [name, width, depth]
		if not groups.has(key):
			groups[key] = {"name": name, "width": width, "depth": depth, "count": 0}
			order.append(key)
		groups[key]["count"] = int(groups[key]["count"]) + 1

	var parts := PackedStringArray()
	for key in order:
		var g: Dictionary = groups[key]
		var size := Readback.size_of(float(g["width"]), float(g["depth"]))
		var described := "%s %s" % [size, str(g["name"])] if size != "0 m" else str(g["name"])
		parts.append(Readback.count_of(int(g["count"]), described))

	if parts.is_empty():
		return "a farm"
	return "a farm with " + Readback.join_capped(parts)


# The panel the farm has always shown, moved here from main.gd unchanged.
func metric_lines(metrics: Dictionary, _record: Dictionary) -> Array:
	var counts: Dictionary = metrics.get("counts", {})
	var present := PackedStringArray()
	for key in counts:
		if int(counts[key]) > 0:
			present.append("%d %s" % [int(counts[key]), str(key)])

	var lines: Array = [
		["ZONES", "%d   (%s)" % [int(metrics["zone_count"]), ", ".join(present)]],
		["SIZE", "%.0f m by %.0f m" % [float(metrics["farm_width"]), float(metrics["farm_depth"])]],
		["ENCLOSED", "%.1f hectares" % (float(metrics["enclosed_area"]) / 10000.0)],
		["WORKED LAND", "%.1f ha  (%.0f%% of the farm)" % [
			float(metrics["worked_area"]) / 10000.0, float(metrics["worked_ratio"]) * 100.0]],
	]

	var crops: Dictionary = metrics.get("crops", {})
	if not crops.is_empty():
		var grown := PackedStringArray()
		for crop in crops:
			grown.append("%s %.1f ha" % [str(crop), float(crops[crop]) / 10000.0])
		lines.append(["CROPS", ", ".join(grown)])

	if float(metrics.get("building_area", 0.0)) > 0.0:
		lines.append(["BUILDINGS", "%.0f m2 of floor" % float(metrics["building_area"])])
	if float(metrics.get("water_area", 0.0)) > 0.0:
		lines.append(["WATER", "%.0f m2" % float(metrics["water_area"])])
	lines.append(["FENCE", "%.0f m around the perimeter" % float(metrics["fence_length"])])
	return lines


func _number(zone: Dictionary, key: String, n: int, type: String, errors: Array) -> float:
	if not zone.has(key):
		errors.append("zone %d (%s): missing '%s'" % [n, type, key])
		return NAN
	var value = zone[key]
	if typeof(value) != TYPE_FLOAT and typeof(value) != TYPE_INT:
		errors.append("zone %d (%s): '%s' must be a number" % [n, type, key])
		return NAN
	return float(value)
