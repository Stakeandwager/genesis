extends SceneTree

# --- 049: the farm's panel and the circuit's panel, against what was placed ---
#
# THE TASK, AND WHERE IT CAME FROM
#
# HANDOVER named the next assistant task: 047 asked 046's axis - *does a line
# that states a number read it from what was BUILT?* - at the DUNGEON'S panel
# and tied its nine lines to the slabs in the tree. The farm's panel and the
# circuit's were left checked against nothing: counted_said_test feeds both
# `measure(solved["layout"])`, a layout and not a construction. HANDOVER said
# the method was 047's and cheap - build the world, walk the tree, count the
# pieces, add up their areas and lengths, and put each number beside the
# panel line that states it - and predicted that the numbers would probably
# agree, with the thing to ask of each line being WHAT FACT it reads and
# whether anything else answers that question from somewhere else.
#
# It also handed over one thing READ AND NOT MEASURED: that the circuit's
# panel states a road LENGTH which 046 recorded as coming from the layout and
# not the construction, so the circuit had "at least one line whose number is
# known not to follow the world".
#
# ASKED, AND THE PREDICTION WAS RIGHT ABOUT THE NUMBERS. Measured headless
# before anything changed, every line of both panels agrees with the geometry
# actually placed. The circuit's LENGTH, the line HANDOVER singled out, was
# measured off the road surface itself - the centre of every quad of every
# Section_ mesh in the tree, added up - and came to 1176.91 m where the panel
# said 1177 m and `measure()` said 1176.99 m. The 8 cm is the road being
# drawn as chords between samples 4 m apart; it is a discretisation and it is
# not a line disagreeing with its world. The farm's eight lines agree exactly:
# 9 zone pieces, 141 x 126 m of Ground slab, 0.64 ha of worked slab, 484 m2 of
# building, 500 m2 of pond, 2400 m2 largest, 534 m of rail.
#
# THE FAULT IS NOT IN EITHER PANEL. It is in the farm the panel describes, and
# it was found by asking the audit's own question of the one number in the
# farm's layout that nothing in the panel states: the GATE.
#
# `solve()` cuts the gate into the south side of the fence it computed and
# records the point. `_fence()` draws the fence somewhere else the moment a
# plan asks the farm to hold another world - `grown()` pushes the boundary
# out about the middle - and the gate was not pushed out with it. Measured on
# a farm of a barn and a wheat field:
#
#   as solved                  10 posts on the gate's line, a 16.0 m gap
#   grown to 260 x 260 m        0 posts on that line, and no gap in its 132
#
# A farm with no way in, with the comment over solve() still saying "a gate
# cut into the south side". REACHABLE BY TYPING, which is why this is a
# finding and not a note: `grow_to()` is called by GameController for a plan
# that puts one world inside another, and *"a dungeon with a hall and a
# vault, inside a farm with a barn"* is a request HANDOVER records as working.
#
# THE RULE IS THE CLASS AND NOT THE GATE (TRAPS 11): anything a world
# positions against its own boundary is read from the boundary that is BUILT.
# Audited across both worlds that can grow - the farm's zones are deliberately
# left where they are and never touch the fence, and the dungeon positions its
# rooms and corridors against each other and only its Ground pad against the
# grown bounds, through `grown()` already - so the gate was the one place the
# rule was broken.
#
# WHAT THIS SUITE ASSERTS
#
# FINDING, and the assertion that fails against the pre-049 code: a farm has
# a gap in its fence at least the gate's width wide, on the fence's south
# side, BOTH as solved and after grow_to() - the call a plan makes. The gap is
# found by walking the posts in the tree and measuring the distance between
# them, never by asking the module where it put the gate.
#
# GUARD: the farm's panel, line by line, against the slabs in the tree, and
# the circuit's panel, line by line, against the road pieces in the tree.
# Every number is counted here by walking the tree; the panel's own reading is
# compared against it, and then looked for in the rendered line as a
# SUBSTRING, so every sentence in Genesis can be rewritten and this stays
# green (047's method).
#
# GUARD: the panel classifies a section the way the geometry does. The four
# panel readings that depend on which sections are straight and which turn -
# the straight ratio, the longest and shortest straight, the direction change
# - were decided by TrackMetrics' own copy of STRAIGHT_FAMILY and YAW_TYPES,
# where the closure solver, the feasibility gate and two suites all read
# TrackGeometry's. The copies were byte-identical, so NOTHING WAS EVER
# MISMEASURED and this suite claims otherwise nowhere. This asserts the
# consequence and not the list: enumerated from SectionValidator.SECTION_TYPES,
# a section of each type is measured, and the panel's classification of it is
# the geometry's. A type added to one list and not the other fails here.
#
# NOT ASSERTED. Nothing here is about WORDING. Nothing here asserts the road's
# chord length equals its analytic length - it cannot, and the tolerance below
# is stated as a fraction with the reason beside it. Nothing asserts that the
# rail across the gate has a gap in it: it does not, it never has on any farm,
# and what a gate should LOOK like is the owner's (HANDOVER, "Human decision
# needed"). And no model sent any request in this file.

var bad := 0
var asserted := 0

# The road is drawn as chords between samples SAMPLE_SPACING apart, so the
# surface in the tree is always a little shorter than the arc length the panel
# states. Measured on the two circuits below: 8 cm in 1177 m, and 8 cm in
# 1114 m. A fraction rather than a number of metres, because the error grows
# with the number of corners and not with the length.
const CHORD_TOLERANCE := 0.005


func _check(ok: bool, what: String) -> void:
	asserted += 1
	if not ok:
		bad += 1
		print("  FAIL  ", what)


func _close(a: float, b: float, fraction: float) -> bool:
	return absf(a - b) <= maxf(absf(a), absf(b)) * fraction + 0.001


func _initialize() -> void:
	_the_gate_is_in_the_fence_that_is_built()
	_the_farm_panel_against_its_slabs()
	_the_circuit_panel_against_its_road()
	_the_panel_classifies_a_section_as_the_geometry_does()
	print("PANEL GEOMETRY %d assertions, failures=%d" % [asserted, bad])
	quit(bad)


# --- the modules, off the registry ---
func _module(command: String) -> WorldModule:
	for entry in WorldRegistry.modules():
		var m: WorldModule = entry
		if m.command() == command:
			return m
	return null


# --- the requests, declared here and labelled as such ---
#
# No model sent either of these. The farm is two zones because the fault is
# about the fence and not about what is inside it; the circuit is the same
# eight-section square panel_built_test declares, with the vertical and banked
# types swapped in so the straight family and the yaw types are both exercised
# by something other than "straight" and "corner".
const FARM := {"zones": [
	{"type": "barn", "width": 20, "depth": 20},
	{"type": "crop", "width": 40, "depth": 40, "crop": "wheat"},
]}

const RICH_FARM := {"zones": [
	{"type": "crop", "width": 60, "depth": 40, "crop": "wheat"},
	{"type": "crop", "width": 40, "depth": 40, "crop": "barley"},
	{"type": "pasture", "width": 50, "depth": 30},
	{"type": "orchard", "width": 30, "depth": 30},
	{"type": "pond", "width": 25, "depth": 20},
	{"type": "barn", "width": 20, "depth": 15},
	{"type": "farmhouse", "width": 12, "depth": 10},
	{"type": "silo", "width": 8, "depth": 8},
	{"type": "yard", "width": 20, "depth": 20},
]}

const CIRCUIT := {"sections": [
	{"type": "crest", "length": 200, "grade": 6},
	{"type": "corner", "radius": 60, "angle": 90},
	{"type": "dip", "length": 200, "grade": 6},
	{"type": "corner", "radius": 60, "angle": 90},
	{"type": "uphill", "length": 200, "grade": 5},
	{"type": "banked_corner", "radius": 60, "angle": 90, "bank": 12},
	{"type": "downhill", "length": 200, "grade": 5},
	{"type": "corner", "radius": 60, "angle": 90},
]}


# validate -> pre_check -> solve -> post_check, the controller's own order.
func _layout_for(module: WorldModule, parameters: Dictionary) -> Dictionary:
	var check := module.validate(parameters)
	if not bool(check.get("ok", false)):
		return {"ok": false, "why": "refused at the schema: %s" % str(check.get("errors", []))}
	var pre := module.pre_check(check["content"], {})
	if not bool(pre.get("ok", false)):
		return {"ok": false, "why": "refused at the pre-check: %s" % str(pre.get("reasons", []))}
	var solved := module.solve(pre["content"])
	if not bool(solved.get("ok", false)):
		return {"ok": false, "why": "did not solve: %s" % str(solved.get("reasons", []))}
	var post := module.post_check(solved["layout"])
	if not bool(post.get("ok", false)):
		return {"ok": false, "why": "refused at the post-check: %s" % str(post.get("reasons", []))}
	return {"ok": true, "layout": solved["layout"], "record": post.get("record", {})}


# --- FINDING: a built farm has a gate, grown or not ---

# The widest gap between consecutive fence posts standing along one line of
# constant z, and where its middle is. Read off the tree: a post is the only
# 0.8 x 0.8 thing a farm places, and nothing is asked of the module.
func _widest_gap_along(root: Node3D, z: float) -> Dictionary:
	var xs: Array = []
	for child in root.get_children():
		if not (child is MeshInstance3D):
			continue
		var mi: MeshInstance3D = child
		if not (mi.mesh is BoxMesh):
			continue
		var box: BoxMesh = mi.mesh
		# float32 in a Vector3, so compared loosely rather than for equality.
		if absf(box.size.x - 0.8) > 0.01 or absf(box.size.z - 0.8) > 0.01:
			continue
		if absf(mi.position.z - z) > 0.6:
			continue
		xs.append(mi.position.x)
	xs.sort()
	var widest := 0.0
	var middle := 0.0
	for i in range(1, xs.size()):
		var span: float = float(xs[i]) - float(xs[i - 1])
		if span > widest:
			widest = span
			middle = (float(xs[i]) + float(xs[i - 1])) * 0.5
	return {"posts": xs.size(), "widest": widest, "middle": middle}


func _gate_gap(module: WorldModule, layout: Dictionary, label: String, gate_x: float) -> void:
	var root := Node3D.new()
	get_root().add_child(root)
	module.build(root, layout)

	# The fence's south side, taken from the extent the module reports rather
	# than from the layout, so a farm the plan has grown is measured where it
	# actually stands.
	var south := module.extent(layout).y * 0.5
	var gap := _widest_gap_along(root, south)

	_check(int(gap["posts"]) > 0,
		"%s: there are fence posts along the south side (%d)" % [label, int(gap["posts"])])
	# THE ASSERTION THAT FAILS BEFORE 049 on a grown farm: no post was ever
	# skipped there, so the widest gap is one post spacing and not a gateway.
	_check(float(gap["widest"]) >= FarmModule.GATE_WIDTH,
		"%s: the gap in those posts is at least the gate's width (%.1f m, gate is %.1f m)" % [
			label, float(gap["widest"]), FarmModule.GATE_WIDTH])
	_check(absf(float(gap["middle"]) - gate_x) < FarmModule.GATE_WIDTH,
		"%s: and the gap is where the gate was cut, across the middle (%.1f vs %.1f)" % [
			label, float(gap["middle"]), gate_x])
	root.free()


func _the_gate_is_in_the_fence_that_is_built() -> void:
	var module := _module("CREATE_FARM")
	if module == null:
		_check(false, "the registry offers a farm")
		return
	var ready := _layout_for(module, FARM)
	if not bool(ready["ok"]):
		_check(false, "a farm of a barn and a field builds (%s)" % str(ready["why"]))
		return
	var layout: Dictionary = ready["layout"]
	var gate_x := float((layout["gate"] as Vector2).x)

	# As solved. This has always been right and 049 does not change it: the
	# assertion is here so that a farm nobody has grown is held to the same
	# rule, and so that a fix to the grown case cannot be bought with it.
	_gate_gap(module, layout, "as solved", gate_x)

	# And the same farm asked to hold another world. grow_to() is the module's
	# own API and it is what GameController calls when a plan puts one world
	# inside another; the size is the one a dungeon of a few rooms needs.
	var inside: Dictionary = layout.duplicate(true)
	_check(module.grow_to(inside, Vector2(260.0, 260.0)), "a farm can be grown to hold something")
	var now := module.extent(inside)
	_check(now.x >= 260.0 and now.y >= 260.0,
		"and it reports the bigger size (%.0f x %.0f)" % [now.x, now.y])
	_gate_gap(module, inside, "grown to hold a world", gate_x)

	# The zones did not move with the fence, which is the rule growth is for.
	for i in (layout["zones"] as Array).size():
		var before: Dictionary = (layout["zones"] as Array)[i]
		var after: Dictionary = (inside["zones"] as Array)[i]
		_check(is_equal_approx(float(before["x"]), float(after["x"]))
				and is_equal_approx(float(before["z"]), float(after["z"])),
			"growing the farm left zone %d where it was" % (i + 1))


# --- GUARD: the farm's panel against the slabs in the tree ---
func _the_farm_panel_against_its_slabs() -> void:
	var module := _module("CREATE_FARM")
	if module == null:
		return
	var ready := _layout_for(module, RICH_FARM)
	if not bool(ready["ok"]):
		_check(false, "a farm of every zone type builds (%s)" % str(ready["why"]))
		return
	var layout: Dictionary = ready["layout"]
	var metrics := module.measure(layout)
	var root := Node3D.new()
	get_root().add_child(root)
	var report := module.build(root, layout)

	var pieces := 0
	var worked := 0.0
	var building := 0.0
	var water := 0.0
	var largest := 0.0
	var ground := Vector2.ZERO
	var rail := 0.0
	for child in root.get_children():
		if not (child is MeshInstance3D) or not (child.mesh is BoxMesh):
			continue
		var mi: MeshInstance3D = child
		var box: BoxMesh = mi.mesh
		var label := str(mi.name)
		if label == "Ground":
			ground = Vector2(box.size.x, box.size.z)
			continue
		if mi.has_meta(WorldModule.PIECE_META):
			pieces += 1
			var type := label.substr(0, label.rfind("_"))
			var area := float(box.size.x) * float(box.size.z)
			largest = maxf(largest, area)
			if type in FarmModule.BUILDINGS:
				building += area
			elif type == "pond":
				water += area
			elif type != "yard":
				worked += area
		elif absf(box.size.y - 0.5) < 0.01:
			# A rail: one per side, 0.5 m thick, as long as the side it runs.
			rail += maxf(box.size.x, box.size.z)

	var enclosed := ground.x * ground.y
	_check(int(report["pieces_built"]) == pieces,
		"the farm reports the zone pieces it placed (%d vs %d)" % [int(report["pieces_built"]), pieces])
	_check(int(metrics["zone_count"]) == pieces,
		"the panel's ZONES is the zone slabs in the tree (%d vs %d)" % [
			int(metrics["zone_count"]), pieces])
	_check(_close(float(metrics["farm_width"]), ground.x, 0.0001)
			and _close(float(metrics["farm_depth"]), ground.y, 0.0001),
		"the panel's SIZE is the ground slab (%.1f x %.1f vs %.1f x %.1f)" % [
			float(metrics["farm_width"]), float(metrics["farm_depth"]), ground.x, ground.y])
	_check(_close(float(metrics["enclosed_area"]), enclosed, 0.0001),
		"the panel's ENCLOSED is that slab's area (%.1f vs %.1f)" % [
			float(metrics["enclosed_area"]), enclosed])
	_check(_close(float(metrics["worked_area"]), worked, 0.0001),
		"the panel's WORKED LAND is the worked slabs (%.1f vs %.1f)" % [
			float(metrics["worked_area"]), worked])
	_check(_close(float(metrics["worked_ratio"]), worked / enclosed, 0.0001),
		"and its percentage is that over the ground slab (%.4f vs %.4f)" % [
			float(metrics["worked_ratio"]), worked / enclosed])
	_check(_close(float(metrics["building_area"]), building, 0.0001),
		"the panel's BUILDINGS is the building slabs (%.1f vs %.1f)" % [
			float(metrics["building_area"]), building])
	_check(_close(float(metrics["water_area"]), water, 0.0001),
		"the panel's WATER is the pond slabs (%.1f vs %.1f)" % [
			float(metrics["water_area"]), water])
	_check(_close(float(metrics["largest_zone"]), largest, 0.0001),
		"the largest zone is the biggest slab (%.1f vs %.1f)" % [
			float(metrics["largest_zone"]), largest])
	_check(_close(float(metrics["fence_length"]), rail, 0.0001),
		"the panel's FENCE is the rails round the perimeter (%.1f vs %.1f)" % [
			float(metrics["fence_length"]), rail])

	# The crops add up to the worked land that is under crop. Measured off the
	# tree by name, because the crop a slab grows is in its colour and not in
	# its mesh.
	var crop_slabs := 0.0
	for child in root.get_children():
		if (child is MeshInstance3D) and child.has_meta(WorldModule.PIECE_META) \
				and str(child.name).begins_with("crop_"):
			var box: BoxMesh = child.mesh
			crop_slabs += float(box.size.x) * float(box.size.z)
	var stated := 0.0
	for crop in (metrics["crops"] as Dictionary):
		stated += float((metrics["crops"] as Dictionary)[crop])
	_check(_close(stated, crop_slabs, 0.0001),
		"the panel's CROPS add up to the crop slabs (%.1f vs %.1f)" % [stated, crop_slabs])

	# And each of those reached the panel. Substrings, so no wording is held.
	var shown := ""
	for line in module.metric_lines(metrics, ready["record"]):
		shown += str((line as Array)[1]) + "\n"
	_check(shown.contains("%d" % pieces), "the zone count is in the rendered panel")
	_check(shown.contains("%.0f" % ground.x), "the measured width is in the rendered panel")
	_check(shown.contains("%.0f" % building), "the building floor area is in the rendered panel")
	_check(shown.contains("%.0f" % rail), "the fence length is in the rendered panel")
	root.free()


# --- GUARD: the circuit's panel against the road in the tree ---

# The length of one road piece, taken from the mesh that was committed. Each
# quad is six vertices - l0, l1, r0, r0, l1, r1 - so the centre of its near
# edge is (l0 + r0) / 2 and of its far edge (l1 + r1) / 2.
func _piece_length(piece: MeshInstance3D) -> float:
	var arrays := piece.mesh.surface_get_arrays(0)
	var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var along := 0.0
	var k := 0
	while k + 5 < verts.size():
		var near: Vector3 = (verts[k] + verts[k + 2]) * 0.5
		var far: Vector3 = (verts[k + 1] + verts[k + 5]) * 0.5
		along += near.distance_to(far)
		k += 6
	return along


func _the_circuit_panel_against_its_road() -> void:
	var module := _module("CREATE_TRACK")
	if module == null:
		_check(false, "the registry offers a circuit")
		return
	var ready := _layout_for(module, CIRCUIT)
	if not bool(ready["ok"]):
		_check(false, "the declared circuit builds (%s)" % str(ready["why"]))
		return
	var layout: Dictionary = ready["layout"]
	var metrics := module.measure(layout)
	var root := Node3D.new()
	get_root().add_child(root)
	var report := module.build(root, layout)

	var pieces := 0
	var road := 0.0
	var straight := 0.0
	var longest := 0.0
	var shortest := INF
	var counts := {}
	for node in root.get_children():
		for child in node.get_children():
			if not (child is MeshInstance3D) or not child.has_meta(WorldModule.PIECE_META):
				continue
			var mi: MeshInstance3D = child
			pieces += 1
			var along := _piece_length(mi)
			road += along
			# "Section_3_banked_corner" -> "banked_corner". The index is
			# between the two underscores this skips past.
			var label := str(mi.name)
			var type := label.substr(label.find("_", label.find("_") + 1) + 1)
			counts[type] = int(counts.get(type, 0)) + 1
			if type in TrackGeometry.STRAIGHT_FAMILY:
				straight += along
				longest = maxf(longest, along)
				shortest = minf(shortest, along)

	_check(int(report["pieces_built"]) == pieces,
		"the circuit reports the road pieces it placed (%d vs %d)" % [
			int(report["pieces_built"]), pieces])
	_check(int(metrics["section_count"]) == pieces,
		"the panel's SECTIONS is the road pieces in the tree (%d vs %d)" % [
			int(metrics["section_count"]), pieces])
	for type in counts:
		_check(int((metrics["counts"] as Dictionary).get(type, -1)) == int(counts[type]),
			"the panel counts %d %s and the tree holds %d" % [
				int((metrics["counts"] as Dictionary).get(type, -1)), str(type), int(counts[type])])

	# LENGTH, the line HANDOVER singled out as known not to follow the world.
	# It does follow it, to within the chords the road is drawn with.
	_check(_close(float(metrics["total_length"]), road, CHORD_TOLERANCE),
		"the panel's LENGTH is the road surface placed, to within its chords (%.2f vs %.2f)" % [
			float(metrics["total_length"]), road])
	_check(_close(float(report["total_length"]), road, CHORD_TOLERANCE),
		"and so is the length in the sentence after the build (%.2f vs %.2f)" % [
			float(report["total_length"]), road])
	_check(_close(float(metrics["straight_length"]), straight, CHORD_TOLERANCE),
		"the straight length is the straight-family pieces (%.2f vs %.2f)" % [
			float(metrics["straight_length"]), straight])
	_check(_close(float(metrics["straight_ratio"]), straight / road, CHORD_TOLERANCE),
		"the panel's STRAIGHT RATIO is that over the road placed (%.4f vs %.4f)" % [
			float(metrics["straight_ratio"]), straight / road])
	_check(_close(float(metrics["longest_straight"]), longest, CHORD_TOLERANCE),
		"the panel's LONGEST STRAIGHT is the longest of them (%.2f vs %.2f)" % [
			float(metrics["longest_straight"]), longest])
	_check(_close(float(metrics["shortest_straight"]), shortest, CHORD_TOLERANCE),
		"the panel's SHORTEST STRAIGHT is the shortest of them (%.2f vs %.2f)" % [
			float(metrics["shortest_straight"]), shortest])

	var shown := ""
	for line in module.metric_lines(metrics, ready["record"]):
		shown += str((line as Array)[1]) + "\n"
	_check(shown.contains("%d" % pieces), "the section count is in the rendered panel")
	_check(shown.contains("%.0f" % road), "the measured road length is in the rendered panel")
	root.free()


# --- GUARD: the panel classifies a section the way the geometry does ---
#
# Not the lists, which were identical and never mismeasured anything: the
# CONSEQUENCE. A section of every type the validator accepts is measured on
# its own, and what the panel then says about it is checked against what
# TrackGeometry says the type is. Enumerated from SECTION_TYPES, never typed
# in here, so a type the owner ever adds is covered without this file moving.
func _a_section_of(type: String) -> Dictionary:
	var section := {"type": type}
	for field in (SectionValidator.FIELDS[type] as Array):
		match str(field):
			"length":
				section["length"] = 200.0
			"grade":
				section["grade"] = 6.0
			"angle":
				section["angle"] = 150.0 if type == "hairpin" else (
					120.0 if type == "loop_segment" else 90.0)
			"radius":
				section["radius"] = 30.0 if type == "hairpin" else 60.0
			"bank":
				section["bank"] = 12.0
			"offset":
				section["offset"] = 20.0
			"direction":
				section["direction"] = "right"
	return section


func _the_panel_classifies_a_section_as_the_geometry_does() -> void:
	for type in SectionValidator.SECTION_TYPES:
		var name := str(type)
		var section := _a_section_of(name)
		var one := TrackMetrics.measure([section])
		var along := TrackGeometry.section_length(section)

		_check(along > 0.0, "a %s has a length (%.2f)" % [name, along])
		_check(is_equal_approx(float(one["total_length"]), along),
			"a circuit of one %s is as long as that section (%.2f vs %.2f)" % [
				name, float(one["total_length"]), along])
		_check(int((one["counts"] as Dictionary).get(name, -1)) == 1,
			"and the panel counts it as one %s" % name)

		# Straight or not: whatever TrackGeometry says, the panel's straight
		# length and its longest straight say the same.
		var is_straight: bool = name in TrackGeometry.STRAIGHT_FAMILY
		var wanted := along if is_straight else 0.0
		_check(is_equal_approx(float(one["straight_length"]), wanted),
			"a %s counts %s toward the straight length (%.2f, wanted %.2f)" % [
				name, "as straight" if is_straight else "as no straight",
				float(one["straight_length"]), wanted])
		_check(is_equal_approx(float(one["longest_straight"]), wanted),
			"and the same toward the longest straight (%.2f, wanted %.2f)" % [
				float(one["longest_straight"]), wanted])

		# Turning or not: a yaw type's direction change is its angle. A
		# chicane turns twice and comes back, which is its own line in
		# TrackMetrics and not a yaw type, so it is excluded by name here and
		# only from THIS assertion.
		if name in TrackGeometry.YAW_TYPES:
			_check(is_equal_approx(float(one["direction_change_total"]), absf(float(section["angle"]))),
				"a %s changes direction by its angle (%.1f vs %.1f)" % [
					name, float(one["direction_change_total"]), absf(float(section["angle"]))])
			_check(is_equal_approx(float(one["net_turn"]), float(section["angle"])),
				"and turns that way (%.1f vs %.1f)" % [
					float(one["net_turn"]), float(section["angle"])])
		elif name != "chicane":
			_check(is_equal_approx(float(one["direction_change_total"]), 0.0),
				"a %s does not change the direction of travel (%.1f)" % [
					name, float(one["direction_change_total"])])
			_check(is_equal_approx(float(one["net_turn"]), 0.0),
				"and does not turn (%.1f)" % float(one["net_turn"]))

		# Radius or not: a curved type's tightest radius is its own.
		if name in TrackGeometry.CURVED_TYPES:
			_check(is_equal_approx(float(one["minimum_radius"]), float(section["radius"])),
				"a %s's tightest radius is its radius (%.1f vs %.1f)" % [
					name, float(one["minimum_radius"]), float(section["radius"])])
		else:
			_check(float(one["minimum_radius"]) < 0.0,
				"a %s has no radius to be tightest (%.1f)" % [
					name, float(one["minimum_radius"])])
