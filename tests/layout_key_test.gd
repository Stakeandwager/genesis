extends SceneTree

# --- 052: who reads this layout key, and what a clearance check compares to ---
#
# THE TASK, AND WHERE IT CAME FROM
#
# HANDOVER named the next assistant task as the remaining half of 051's own
# entry: *for every world, list the keys its solve() writes into the layout,
# and ask of each one WHO READS IT.* 049's fault was in the one key of the
# farm's layout that no panel line states, and it was found that way. 051
# enumerated the three layouts by grep and left one dead key behind:
# FarmModule.solve() writes "lane_width" and `grep` across every file in the
# repository finds it in that one line. HANDOVER set the class question -
# *is a layout a RECORD of what was decided or an INPUT to the builder?* -
# and named three choices: drop the key, give it a reader, or label it.
#
# THE ANSWER TO THE CLASS QUESTION IS "AN INPUT", AND IT IS MEASURED AND NOT
# ARGUED. 051 checked that nothing serialises a layout: WorldStore saves the
# command, the parameters and the metrics, never the layout. So a layout is
# produced by solve() and consumed by the module, nothing survives it, and a
# key nothing consumes is dead weight rather than documentation. That makes
# "give it a reader" the choice the repository's own shape asks for, and
# HANDOVER named the reader it would be: _check_reachable(), reading the lane
# width it is checking for rather than assuming one.
#
# IT WAS NOT ASSUMING ONE. IT WAS COMPARING AGAINST 0.5.
# `_check_reachable()` is the farm's version of "the circuit must close": the
# module's own header says a farm you cannot drive a tractor around is
# refused. It decided an edge was clear unless a neighbour stood within half
# a metre of it, and LANE_WIDTH is 6 m - so the test admitted a gap ONE
# TWELFTH of the thing its own comment calls a lane, and the number it should
# have read was sitting unread in the layout it was handed.
#
# WHAT IT COST, MEASURED HEADLESS BEFORE ANYTHING CHANGED: nothing yet, and
# the commit says so. Over 468 legal farms swept, solve() never leaves two
# zones closer than 6.0000 m, so the failure branch is not reachable from any
# request a player can send and the two thresholds agree on every farm that
# exists. What was wrong is that the guard did not guard what it names: a
# packing change that put zones 0.6 m apart would pass it, and a guard that
# cannot catch the thing it is for is the thing sweep_test exists to say out
# loud about FAILED_UNWALKABLE.
#
# THE CLASS, AND THE PROJECT HAD ALREADY BEEN RIGHT TWICE (TRAPS 11, and 040's
# question: where has this project already been RIGHT once?). Genesis has
# three clearance checks, one per world. SeparationCheck compares against
# MIN_SEPARATION, which IS ROAD_WIDTH + SAFETY_MARGIN - the road's own width
# plus a named margin. The dungeon walks its corridors with a body BODY
# metres across and reports that width in walkable(). The farm's compared
# against a bare literal with no name on it. All three facts are asserted
# below, so the rule - A CLEARANCE CHECK COMPARES AGAINST THE DIMENSION IT IS
# ABOUT - is held at every member and not at the one that was wrong.
#
# WHAT THIS SUITE ASSERTS, AND WHAT IT DOES NOT (TRAPS 6, TRAPS 14)
#
# Nothing here asserts a sentence. "The comment says a lane" would pass
# against a check comparing to 0.5 and against one comparing to 6.
#
# The reader sweep is MECHANICAL and it fails open. The worlds come from
# WorldRegistry.modules(), the keys come from the layout solve() actually
# returned, and each key is PERTURBED and the module asked again: every
# method of the module that takes a layout - found by reflection over
# get_method_list(), so a check added later is asked without this file being
# edited - plus build() into a real tree. A key whose perturbation changes
# nothing is read by nothing, and the suite says which. A world with no
# fixture here, or a layout key with no declared perturbation, FAILS rather
# than being skipped: a fourth world and a new key are both asked.
#
# What it does NOT prove: that a key is read for the right reason, or that
# the reader is correct. It proves that something downstream can tell the
# difference, which is the one property a dead key does not have.

var asserted := 0
var bad := 0


func _check(ok: bool, what: String) -> void:
	asserted += 1
	if not ok:
		bad += 1
		print("  FAIL  ", what)


# --- the fixtures, one legal request per world ---
#
# Keyed by display_name(), which is the one function that names a world
# (032's rule). A world in the registry with no entry here fails below.
#
# The farm's nine equal zones are deliberate: solve() packs them 3 by 3 with
# a lane between, so the middle zone has a neighbour on all four sides, which
# is the only shape in which the lane width can decide anything at all.
const FIXTURES := {
	"farm": {"zones": [
		{"type": "yard", "width": 20.0, "depth": 20.0},
		{"type": "yard", "width": 20.0, "depth": 20.0},
		{"type": "yard", "width": 20.0, "depth": 20.0},
		{"type": "yard", "width": 20.0, "depth": 20.0},
		{"type": "yard", "width": 20.0, "depth": 20.0},
		{"type": "yard", "width": 20.0, "depth": 20.0},
		{"type": "yard", "width": 20.0, "depth": 20.0},
		{"type": "yard", "width": 20.0, "depth": 20.0},
		{"type": "yard", "width": 20.0, "depth": 20.0},
	]},
	"circuit": {"mode": "circuit", "sections": [
		{"type": "straight", "length": 120.0},
		{"type": "corner", "radius": 40.0, "angle": 90.0},
		{"type": "straight", "length": 120.0},
		{"type": "corner", "radius": 40.0, "angle": 90.0},
		{"type": "straight", "length": 120.0},
		{"type": "corner", "radius": 40.0, "angle": 90.0},
		{"type": "straight", "length": 120.0},
		{"type": "corner", "radius": 40.0, "angle": 90.0},
	]},
	"dungeon": {
		"rooms": [{"name": "hall", "width": 12.0, "depth": 12.0},
			{"name": "vault", "width": 10.0, "depth": 10.0}],
		"doors": [[1, 2]],
		"things": [{"name": "lamp", "in": 1}],
	},
}

# The keys a perturbation is declared for. The list is checked against the
# layout rather than trusted: a key here that no layout carries is reported,
# and a layout key missing from here is a failure.
const PERTURBED := ["zones", "fence_min", "fence_max", "gate", "lane_width",
	"rooms", "doors", "pitch", "slots", "things", "sections", "target_turn",
	"min_extent"]


func _solved(module: WorldModule) -> Dictionary:
	var name := module.display_name()
	if not FIXTURES.has(name):
		return {}
	var check: Dictionary = module.validate(FIXTURES[name])
	if not bool(check.get("ok", false)):
		print("  (fixture for %s did not validate: %s)" % [name, check.get("errors", [])])
		return {}
	var pre: Dictionary = module.pre_check(check["content"], {})
	if not bool(pre.get("ok", false)):
		print("  (fixture for %s did not pass pre_check: %s)" % [name, pre.get("reasons", [])])
		return {}
	var solved: Dictionary = module.solve(pre["content"])
	if not bool(solved.get("ok", false)):
		print("  (fixture for %s did not solve: %s)" % [name, solved.get("reasons", [])])
		return {}
	return solved["layout"]


# Every method of this module that takes one layout, by name, in a fixed
# order. Reflection rather than a list, so a check added to a world later is
# part of the reader surface without this file being edited.
func _layout_readers(module: WorldModule) -> Array:
	var names := {}
	for entry in module.get_method_list():
		var args: Array = entry["args"]
		if args.size() != 1:
			continue
		var arg := str((args[0] as Dictionary)["name"])
		if arg == "layout" or arg == "_layout":
			names[str(entry["name"])] = true
	var out: Array = names.keys()
	out.sort()
	return out


# What the module makes of this layout: every layout-taking method, and the
# tree build() actually places. A key nothing here can tell the difference
# about is a key nothing reads.
func _signature(module: WorldModule, layout: Dictionary) -> String:
	var parts: Array = []
	for name in _layout_readers(module):
		parts.append("%s=%s" % [name, str(module.call(name, layout))])
	var root := Node3D.new()
	# NAMED, and the suite was wrong before it was right: an unnamed node
	# added to the tree is given a generated name with a counter in it, so
	# the signature differed between two runs over the SAME layout and every
	# assertion below passed whatever the module did with the key. Measured
	# against the pre-052 code, which it is supposed to catch and did not
	# (TRAPS 6: a check that cannot fail).
	root.name = "Probe"
	get_root().add_child(root)
	var report: Dictionary = module.build(root, layout)
	parts.append("report=%s" % str(report))
	parts.append("tree=%s" % _tree(root))
	root.free()
	return _stable("\n".join(PackedStringArray(parts)))


# A build report carries the node a car drives on or a body stands in, and a
# node prints as "<Node3D#33034339797>" - an instance id, different every
# time the same layout is built. The id is taken out and the rest kept: what
# matters is that the report names a node, not which object it was this run.
func _stable(text: String) -> String:
	var ids := RegEx.new()
	ids.compile("#\\d+")
	return ids.sub(text, "#id", true)


func _tree(node: Node) -> String:
	# A node its builder did not name is given a generated one with a global
	# counter in it - "@MeshInstance3D@57" - which differs between two builds
	# of the SAME layout. The farm's fence posts are such nodes. The class
	# stands in for the name there, so the signature describes the tree and
	# not the order the suite happened to build it in.
	var line: String = node.get_class() if node.name.begins_with("@") else str(node.name)
	if node is Node3D:
		var n := node as Node3D
		line += "@%.3f,%.3f,%.3f" % [n.position.x, n.position.y, n.position.z]
		line += "*%.3f,%.3f,%.3f" % [n.scale.x, n.scale.y, n.scale.z]
	if node is MeshInstance3D:
		var m := (node as MeshInstance3D).mesh
		if m != null:
			line += "#%s" % str(m.get_aabb())
	var kids: Array = []
	for child in node.get_children():
		kids.append(_tree(child))
	return line + "{" + ",".join(PackedStringArray(kids)) + "}"


# Change this key, without changing any other. Returns the whole layout.
func _perturb(layout: Dictionary, key: String) -> Dictionary:
	var out: Dictionary = layout.duplicate(true)
	var value = out[key]
	match key:
		"lane_width", "pitch":
			out[key] = float(value) * 4.0 + 1.0
		"target_turn":
			# The SIGN, not the size. Scaling it changes nothing, which is
			# not a dead key but a key read to one bit: see
			# _only_the_sign_of_target_turn() below, which measures that
			# rather than letting this perturbation hide it.
			out[key] = -float(value)
		"fence_min":
			out[key] = (value as Vector2) - Vector2(25.0, 25.0)
		"fence_max":
			out[key] = (value as Vector2) + Vector2(25.0, 25.0)
		"gate":
			out[key] = (value as Vector2) + Vector2(40.0, 0.0)
		"min_extent":
			out[key] = (value as Vector2) + Vector2(300.0, 300.0)
		"zones":
			# One more zone, well clear of the rest, so nothing overlaps.
			var zones: Array = value
			var extra: Dictionary = (zones[zones.size() - 1] as Dictionary).duplicate(true)
			extra["x"] = float(extra["x"]) + 500.0
			zones.append(extra)
		"rooms":
			# The last room half as big again. Adding a room would leave the
			# doors and the slots referring to a room count that no longer
			# matches, which is a broken layout and not a changed one.
			var rooms: Array = value
			var last: Dictionary = rooms[rooms.size() - 1]
			last["width"] = float(last["width"]) * 1.5
		"sections":
			var sections: Array = value
			var last: Dictionary = sections[sections.size() - 1]
			for field in last.keys():
				if typeof(last[field]) == TYPE_FLOAT or typeof(last[field]) == TYPE_INT:
					last[field] = float(last[field]) * 1.5
					break
		"doors", "things":
			var list: Array = value
			if list.is_empty():
				return {}
			list.remove_at(list.size() - 1)
		"slots":
			var slots: Dictionary = value
			var ids: Array = slots.keys()
			slots[ids[ids.size() - 1]] = (slots[ids[ids.size() - 1]] as Vector2i) + Vector2i(3, 3)
		_:
			return {}
	return out


func _sweep_readers(module: WorldModule, layout: Dictionary, grown: bool) -> void:
	var world := module.display_name()
	var where := "%s%s" % [world, " (grown)" if grown else ""]
	var before := _signature(module, layout)
	# The check on the check, and it is here because this suite failed it:
	# if the same layout does not sign the same way twice, every assertion
	# below passes whatever the module does and the sweep measures nothing
	# (TRAPS 6).
	_check(_signature(module, layout) == before,
		"%s: the same layout signs the same way twice, so a difference below means something" % where)
	var keys: Array = layout.keys()
	keys.sort()
	for key in keys:
		var name := str(key)
		if not name in PERTURBED:
			_check(false, "%s.%s: no perturbation is declared for this layout key, so nothing here asks whether anything reads it" % [where, name])
			continue
		var changed: Dictionary = _perturb(layout, name)
		if changed.is_empty():
			_check(false, "%s.%s: the declared perturbation could not be applied" % [where, name])
			continue
		_check(_signature(module, changed) != before,
			"%s.%s is READ: changing it changes what the module makes of the layout" % [where, name])


func _initialize() -> void:
	print("LAYOUT KEYS")

	# --- 1. every key of every world's layout is read by something ---
	var worlds := 0
	for module in WorldRegistry.modules():
		var name: String = module.display_name()
		var layout: Dictionary = _solved(module)
		_check(not layout.is_empty(),
			"%s has a fixture here and it solves" % name)
		if layout.is_empty():
			continue
		worlds += 1
		_check(not layout.keys().is_empty(), "%s's layout has keys to ask about" % name)
		_sweep_readers(module, layout, false)

		# min_extent only exists on a layout a plan has grown, so it is asked
		# on one. A world that refuses to grow is asked nothing further.
		var bigger: Dictionary = layout.duplicate(true)
		if module.grow_to(bigger, module.extent(layout) + Vector2(200.0, 200.0)):
			_check(bigger.has("min_extent"),
				"%s that grew carries min_extent" % name)
			_sweep_readers(module, bigger, true)

	_check(worlds == WorldRegistry.modules().size(),
		"every world in the registry was asked (%d of %d)" % [worlds, WorldRegistry.modules().size()])

	_only_the_sign_of_target_turn()
	_lane_width_is_the_threshold()
	_the_other_two_clearances()
	_no_legal_farm_is_refused()

	print("LAYOUT KEYS %d assertions, failures=%d" % [asserted, bad])
	quit()


# --- 1b: how far "read" goes, for the one key where it is one bit ---
#
# The sweep above asks whether anything can tell a key apart. This asks HOW
# MUCH of one is read, and the answer for the circuit's target_turn is: its
# sign and nothing else. Inside solve() the number is the closure target the
# solver aims at; in the LAYOUT it survives only to decide whether build()
# calls the circuit clockwise. Quadruple it and the built track is identical
# to the millimetre; negate it and the direction flips.
#
# That is not a dead key and it is not a fault. It is written down because
# 049 predicted "at least one more dead or wrongly-read field" and this is
# what that prediction actually turned up on the circuit: a key read to one
# bit, which a sweep that only asks "did anything change?" would have
# reported as fully read.
func _only_the_sign_of_target_turn() -> void:
	var module := RacingModule.new()
	var layout: Dictionary = _solved(module)
	_check(not layout.is_empty(), "the circuit fixture solves for the target_turn reading")
	if layout.is_empty():
		return
	_check(layout.has("target_turn"), "a solved circuit's layout carries target_turn")
	if not layout.has("target_turn"):
		return
	var before := _signature(module, layout)

	var bigger: Dictionary = layout.duplicate(true)
	bigger["target_turn"] = float(bigger["target_turn"]) * 4.0
	_check(_signature(module, bigger) == before,
		"four times the turn target builds the same circuit: its SIZE is read by nothing in the layout")

	var other_way: Dictionary = layout.duplicate(true)
	other_way["target_turn"] = -float(other_way["target_turn"])
	_check(_signature(module, other_way) != before,
		"and the other way round builds a different one: its SIGN is read")


# --- 2. the farm's clearance is the lane width in the layout it is given ---
#
# A grid of nine zones with a known gap between them, checked at several lane
# widths. The verdict has to MOVE with the width: that is what "it reads the
# layout" means, and it is a fact rather than a wording. Against the pre-052
# code every one of the refusals below is an "ok".
func _grid(gap: float) -> Array:
	var zones: Array = []
	for i in 9:
		zones.append({"type": "yard", "width": 20.0, "depth": 20.0,
			"x": float(i % 3) * (20.0 + gap), "z": float(i / 3) * (20.0 + gap)})
	return zones


func _lane_width_is_the_threshold() -> void:
	var module := FarmModule.new()

	# Zones six metres apart. A six metre lane fits; anything wider does not.
	var six: Array = _grid(6.0)
	for lane in [1.0, 3.0, 6.0]:
		var res: Dictionary = module._check_reachable({"zones": six, "lane_width": lane})
		_check(bool(res["ok"]),
			"zones 6 m apart are reachable when a lane is %.1f m wide" % lane)
	for lane in [8.0, 12.0, 24.0]:
		var res: Dictionary = module._check_reachable({"zones": six, "lane_width": lane})
		_check(not bool(res["ok"]),
			"zones 6 m apart are NOT reachable when a lane is %.1f m wide" % lane)
		# The one walled in is the middle of the nine: the four round the
		# edge each still have open ground outside the grid.
		_check((res["reasons"] as Array).size() == 1,
			"and it is the one zone with a neighbour on all four sides (%d reported)" % (res["reasons"] as Array).size())

	# The fault itself: a gap that is not a lane. Half a metre was the old
	# threshold, so every one of these passed before 052.
	for gap in [0.6, 1.0, 3.0, 5.0]:
		var res: Dictionary = module._check_reachable(
			{"zones": _grid(gap), "lane_width": module.LANE_WIDTH})
		_check(not bool(res["ok"]),
			"a %.1f m gap is not a %.0f m lane and the middle zone is walled in" % [gap, module.LANE_WIDTH])

	# And an overlap is blocked too, which the four flush tests could only
	# see when it was within half a metre of exact.
	var over: Array = _grid(6.0)
	(over[4] as Dictionary)["width"] = 200.0
	(over[4] as Dictionary)["depth"] = 200.0
	(over[4] as Dictionary)["x"] = -90.0
	(over[4] as Dictionary)["z"] = -90.0
	var swallowed: Dictionary = module._check_reachable({"zones": over, "lane_width": module.LANE_WIDTH})
	_check(not bool(swallowed["ok"]),
		"a zone buried inside another one is not reachable (%d reported)" % (swallowed["reasons"] as Array).size())

	# The key the check reads is written by the solver, every time, so the
	# reading needs no default (TRAPS 45).
	var written := 0
	var farms := 0
	for n in [1, 2, 5, 9, 24]:
		var zones: Array = []
		for i in n:
			zones.append({"type": "yard", "width": 20.0, "depth": 20.0})
		var check: Dictionary = module.validate({"zones": zones})
		if not bool(check["ok"]):
			continue
		var solved: Dictionary = module.solve(check["content"])
		if not bool(solved["ok"]):
			continue
		farms += 1
		if (solved["layout"] as Dictionary).has("lane_width"):
			written += 1
	_check(farms > 0 and written == farms,
		"every layout solve() returns carries lane_width (%d of %d)" % [written, farms])


# --- 3. the same rule at the other two worlds (TRAPS 11) ---
#
# A clearance check compares against the dimension it is about. Two of the
# three members were already right and this says so in facts: the circuit's
# threshold is its road's own width plus a named margin, and the dungeon
# reports the body width it walked its corridors with.
func _the_other_two_clearances() -> void:
	_check(is_equal_approx(SeparationCheck.MIN_SEPARATION,
			SeparationCheck.ROAD_WIDTH + SeparationCheck.SAFETY_MARGIN),
		"the circuit keeps roads a road's width plus a margin apart (%.1f = %.1f + %.1f)" % [
			SeparationCheck.MIN_SEPARATION, SeparationCheck.ROAD_WIDTH, SeparationCheck.SAFETY_MARGIN])
	_check(SeparationCheck.ROAD_WIDTH > 0.0 and SeparationCheck.SAFETY_MARGIN > 0.0,
		"and neither half of it is zero")

	var dungeon := DungeonModule.new()
	var layout: Dictionary = _solved(dungeon)
	_check(not layout.is_empty(), "the dungeon fixture solves for the walk check")
	if layout.is_empty():
		return
	var walk: Dictionary = dungeon.walkable(layout)
	_check(walk.has("body"), "the dungeon's walk check reports the width it cleared")
	_check(walk.has("body") and is_equal_approx(float(walk["body"]), dungeon.BODY),
		"and it is the body's own width (%.2f)" % float(walk.get("body", -1.0)))


# --- 4. and no farm a player can ask for is refused by the new threshold ---
#
# The guard is stricter than it was by a factor of twelve, so the thing to
# measure is whether it now refuses anything legal. It does not, and it
# cannot: the solver leaves exactly a lane between zones, which limits_test
# asserts from the other side.
func _no_legal_farm_is_refused() -> void:
	var module := FarmModule.new()
	var rng := RandomNumberGenerator.new()
	rng.seed = 20261016
	var types: Array = module.ZONE_TYPES
	var tried := 0
	var refused := 0
	var reasons: Array = []
	for n in [1, 2, 3, 5, 8, 12, 24]:
		for trial in 30:
			var zones: Array = []
			for i in n:
				var type := str(types[rng.randi_range(0, types.size() - 1)])
				var limits: Vector2 = module.BUILDING_SIDE if type in module.BUILDINGS else module.FIELD_SIDE
				var zone := {"type": type,
					"width": snappedf(rng.randf_range(limits.x, limits.y), 0.1),
					"depth": snappedf(rng.randf_range(limits.x, limits.y), 0.1)}
				if type == "crop":
					zone["crop"] = "wheat"
				zones.append(zone)
			var check: Dictionary = module.validate({"zones": zones})
			if not bool(check["ok"]):
				continue
			tried += 1
			var solved: Dictionary = module.solve(check["content"])
			if not bool(solved["ok"]):
				refused += 1
				if reasons.size() < 3:
					reasons.append(solved["reasons"])
	_check(tried > 150, "swept %d legal farms through the solver" % tried)
	_check(refused == 0,
		"and the lane check refused none of them (%d: %s)" % [refused, str(reasons)])
