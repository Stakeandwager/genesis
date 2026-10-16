extends SceneTree

# --- 047: the panel beside the world it describes, and the doors a body can use ---
#
# THE TASK, AND WHERE IT CAME FROM
#
# HANDOVER named the next assistant task as the sixth axis applied to tests/ -
# *which suites never RUN the thing they make a claim about?* - and handed
# over a starting point marked MEASURED BY GREP AND NOT A FINDING: that
# `metric_lines(` appeared in two of the 53 suites, and that the DUNGEON'S
# PANEL, nine lines and the longest in Genesis, was fed a dictionary typed
# into container_door_test whose `loops: 1` cannot occur. It said to start at
# that panel and ask of each of its nine lines what the number is read from.
#
# Asked. The answer for all nine is `measure(layout)`, and on a dungeon that
# has just been built every one of them agrees with the geometry: measured
# headless before anything changed, 2 Room_ slabs for "ROOMS 2", 244 m2 of
# slab for "ROOM FLOOR 244 m2", 88 m2 and 18 m of Corridor_ slab for
# "CORRIDOR 18 m long, 88 m2", 29 x 12 m of placed floor for "SIZE 29 m by
# 12 m". NOTHING IN THE PANEL WAS WRONG ABOUT A DUNGEON AS BUILT and this
# suite does not claim otherwise.
#
# THE FINDING IS ONE LINE ALONG: WHICH DOORS THOSE NINE LINES WALK.
#
# Four of the nine describe GETTING ABOUT - how deep the deepest room is,
# which room that is, how many dead ends there are, how many ways round there
# are - and all four walked the dungeon's FULL door list. WALKABLE, the fifth
# line and the one directly above WAYS ROUND, walks the doors a body can USE,
# and so do route() and the body itself. Measured on a ring of four rooms:
#
#   with the ring-closing door SHUT, before 047
#     DEEPEST     crypt   2 doors from the entrance   (the cell is 3 away)
#     DEAD ENDS   0                                   (rooms 1 and 4 are)
#     WALKABLE    4 of 4 rooms reachable               <- honours the shut door
#     WAYS ROUND  1 loop                              <- there is no way round
#     summary()   "4 rooms joined by 4 doors, 1 way back round"
#   and route() 1 -> 4 went from 38 points to 191, so the BODY had already
#   been told what the panel had not.
#
# THE SECOND FAULT IS IN THE LIST ITSELF, and it is a crash rather than a
# false sentence. walkable() appended a Vector2i for a shut door and a String
# for a doorway no body fits, into one list; route() read every entry as a
# Vector2i. A blocked doorway therefore THREW inside route(), which returned
# [] - and the controller reads [] as "no way through" and says so. A crashed
# function and a plausible sentence. Demonstrated below, on a layout built by
# hand, because no legal request reaches it (see LATENT).
#
# LATENT, AND SAID PLAINLY. Neither fault has reached a player.
# `measure()` is called in exactly one place - GameController._prepare() -
# before anything is built, and `set_shut()` only ever runs on a layout that
# is already standing, so the panel a player reads was drawn when nothing was
# shut. And a doorway no body fits does not occur: 4000 random legal ring
# dungeons were solved and post-checked headless this session, 2597 of them
# built, and NONE had a blocked doorway, which is sweep_test's finding from
# the other direction. What 047 fixes is a panel that would state the design
# the moment anything re-measured a standing dungeon, and a route() that
# throws the moment a corridor can be blocked.
#
# WHAT THIS SUITE ASSERTS
#
# FINDING, and the assertions that fail against the pre-047 code: every
# reading that describes getting about follows the doors a body can use. A
# ring is built, a door is shut, and the panel's own numbers must change with
# it - the loop must go, the dead ends must appear, and the deepest room must
# be the one the BODY walks furthest to, cross-checked against route() rather
# than against a number typed here.
#
# FINDING: the unusable-doorway list is one type. Every entry is a door pair,
# there is one sentence beside it per entry, and route() answers rather than
# throwing when a doorway is impassable.
#
# GUARD, and the gap HANDOVER named: the panel is produced from a world that
# was SOLVED and BUILT, for every module in WorldRegistry.modules(), and the
# dungeon's nine lines are tied to the slabs actually in the tree - counted
# by walking it here, not by calling the function under test. A world added
# later is covered without this file being edited.
#
# GUARD: the loop count is edges - rooms + components, in one function, and
# it is asked of a graph in TWO pieces - where the hand-written "+ 1" that
# stood in pre_check and measure() states a way round that is not there.
#
# NOT ASSERTED. Nothing here is about WORDING. Where a number has to be shown
# to have reached the panel, it is looked for as a substring of the rendered
# line and never compared against a sentence, so every line in Genesis can be
# rewritten and this stays green. Nothing here asserts that the dungeon's
# DOOR count follows the usable doors - it does not, a shut door still joins
# two rooms, and that is HANDOVER's "Human decision needed". Nothing asserts
# that a farm or a circuit has a getting-about number, because neither has a
# door. And no model sent any request in this file.

var bad := 0


func _check(ok: bool, what: String) -> void:
	if not ok:
		bad += 1
		print("  FAIL  ", what)


func _initialize() -> void:
	_every_panel_from_a_built_world()
	_the_dungeon_panel_against_its_slabs()
	_getting_about_follows_the_usable_doors()
	_one_list_one_type()
	_the_loop_count_counts_components()
	print("PANEL BUILT failures=%d" % bad)
	quit(bad)


# --- the module, off the registry ---
func _dungeon() -> WorldModule:
	for entry in WorldRegistry.modules():
		var m: WorldModule = entry
		if m.command() == "CREATE_DUNGEON":
			return m
	return null


# A request that BUILDS. Same shape as built_count_test: the module's own
# declared samples first, read from lists() rather than typed here, and a
# declared request only for the one world whose sample is a legal list and
# not a closed circuit.
const BUILDABLE := {
	"CREATE_TRACK": {"sections": [
		{"type": "straight", "length": 200},
		{"type": "corner", "radius": 50, "angle": 90},
		{"type": "straight", "length": 200},
		{"type": "corner", "radius": 50, "angle": 90},
		{"type": "straight", "length": 200},
		{"type": "corner", "radius": 50, "angle": 90},
		{"type": "straight", "length": 200},
		{"type": "corner", "radius": 50, "angle": 90},
	]},
}


func _from_samples(module: WorldModule) -> Dictionary:
	var parameters := {}
	for entry in module.lists():
		var e: Dictionary = entry
		parameters[str(e["key"])] = e.get("sample", [])
	return parameters


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
	return {"ok": true, "layout": solved["layout"], "record": post.get("record", {}), "pre": pre}


func _buildable(module: WorldModule) -> Dictionary:
	var from_samples := _layout_for(module, _from_samples(module))
	if bool(from_samples["ok"]):
		from_samples["source"] = "its own declared samples"
		return from_samples
	if not BUILDABLE.has(module.command()):
		return {"ok": false, "why": "%s, and no request is declared for %s in this suite" % [
			str(from_samples["why"]), module.command()]}
	var declared := _layout_for(module, BUILDABLE[module.command()])
	declared["source"] = "the request this suite declares for %s" % module.command()
	if not bool(declared["ok"]):
		declared["why"] = "%s (the declared request)" % str(declared.get("why", ""))
	return declared


# --- GUARD: every world's panel, produced from a world that was BUILT ---
#
# The gap HANDOVER named. Before 047 the only suites that produced a panel fed
# it a layout or a dictionary; nothing had ever put a panel beside a
# construction. This does not check what the lines SAY - it checks that every
# module can produce its panel from a measured, built world, and that no line
# arrives empty or carrying a number that is not one.
func _every_panel_from_a_built_world() -> void:
	for entry in WorldRegistry.modules():
		var module: WorldModule = entry
		var name := module.display_name()
		var built := _buildable(module)
		if not bool(built["ok"]):
			_check(false, "%s can be built here (%s)" % [name, str(built["why"])])
			continue
		var layout: Dictionary = built["layout"]
		var metrics := module.measure(layout)
		var root := Node3D.new()
		get_root().add_child(root)
		var report := module.build(root, layout)
		_check(report.has("pieces_built"), "%s reports what it built" % name)

		var record: Dictionary = built["record"]
		record["metrics"] = metrics
		record["command"] = module.command()
		var lines: Array = module.metric_lines(metrics, record)
		_check(not lines.is_empty(), "%s's panel has lines, from a world that was built" % name)
		for line in lines:
			var pair: Array = line
			_check(pair.size() == 2, "%s: every panel line is a label and a value" % name)
			var value := str(pair[1])
			_check(value.strip_edges() != "", "%s: panel line '%s' states something" % [
				name, str(pair[0])])
			var low := value.to_lower()
			_check(not low.contains("nan") and not low.contains("inf"),
				"%s: panel line '%s' states a number, not '%s'" % [name, str(pair[0]), value])
		root.free()


# --- GUARD: the dungeon's nine lines against the slabs in the tree ---
#
# Every number is counted here by walking the tree, never by calling the
# function under test, and then looked for in the rendered line - as a
# substring, so the sentence around it can be rewritten freely.
func _the_dungeon_panel_against_its_slabs() -> void:
	var module := _dungeon()
	if module == null:
		_check(false, "the registry offers a dungeon")
		return
	var built := _buildable(module)
	if not bool(built["ok"]):
		_check(false, "a dungeon can be built here (%s)" % str(built["why"]))
		return
	var layout: Dictionary = built["layout"]
	var metrics := module.measure(layout)
	var root := Node3D.new()
	get_root().add_child(root)
	module.build(root, layout)

	var rooms := 0
	var room_area := 0.0
	var corridor_area := 0.0
	var corridor_length := 0.0
	var largest := 0.0
	var largest_name := ""
	var low := Vector2(INF, INF)
	var high := Vector2(-INF, -INF)
	for child in root.get_children():
		if not (child is MeshInstance3D):
			continue
		var slab: MeshInstance3D = child
		var box: BoxMesh = slab.mesh
		var here := Vector2(slab.position.x, slab.position.z)
		var half := Vector2(box.size.x, box.size.z) * 0.5
		var label := str(slab.name)
		if label.begins_with("Room_"):
			rooms += 1
			var area := box.size.x * box.size.z
			room_area += area
			if area > largest:
				largest = area
				largest_name = label.substr(label.find("_", 5) + 1)
			low = low.min(here - half)
			high = high.max(here + half)
		elif label.begins_with("Corridor_"):
			corridor_area += box.size.x * box.size.z
			# The run between the two room walls: the slab spans the gap and
			# overlaps half a corridor width at each end, which is the
			# subtraction measure() makes.
			corridor_length += maxf(box.size.x, box.size.z) - DungeonModule.CORRIDOR
			low = low.min(here - half)
			high = high.max(here + half)

	var across := high - low
	_check(int(metrics["room_count"]) == rooms,
		"the panel's room count is the Room_ slabs in the tree (%d vs %d)" % [
			int(metrics["room_count"]), rooms])
	_check(is_equal_approx(float(metrics["floor_area"]), room_area),
		"the panel's room floor is the area of those slabs (%.1f vs %.1f)" % [
			float(metrics["floor_area"]), room_area])
	_check(is_equal_approx(float(metrics["corridor_area"]), corridor_area),
		"the panel's corridor area is the Corridor_ slabs (%.1f vs %.1f)" % [
			float(metrics["corridor_area"]), corridor_area])
	_check(is_equal_approx(float(metrics["corridor_length"]), corridor_length),
		"the panel's corridor length is those slabs' runs (%.1f vs %.1f)" % [
			float(metrics["corridor_length"]), corridor_length])
	_check(str(metrics["largest_room"]) == largest_name,
		"the panel's largest room is the biggest slab (%s vs %s)" % [
			str(metrics["largest_room"]), largest_name])
	_check(is_equal_approx(float(metrics["largest_room_area"]), largest),
		"the panel's largest area is that slab's (%.1f vs %.1f)" % [
			float(metrics["largest_room_area"]), largest])
	_check(is_equal_approx(float(metrics["width"]), across.x)
			and is_equal_approx(float(metrics["depth"]), across.y),
		"the panel's size is the extent of the placed floors (%.1f x %.1f vs %.1f x %.1f)" % [
			float(metrics["width"]), float(metrics["depth"]), across.x, across.y])

	# And each of those numbers reached the panel. Looked for as a substring
	# of the rendered value, so no wording is asserted.
	var record: Dictionary = built["record"]
	var shown := ""
	for line in module.metric_lines(metrics, record):
		shown += str((line as Array)[1]) + "\n"
	_check(shown.contains("%d" % rooms), "the room count is in the rendered panel")
	_check(shown.contains("%.0f" % room_area), "the room floor area is in the rendered panel")
	_check(shown.contains(largest_name), "the largest room's name is in the rendered panel")
	_check(shown.contains("%.0f" % across.x), "the measured width is in the rendered panel")
	root.free()


# --- a ring of four rooms, for the doors ---
func _ring() -> Dictionary:
	return {
		"rooms": [
			{"name": "hall", "width": 12, "depth": 12},
			{"name": "vault", "width": 10, "depth": 10},
			{"name": "crypt", "width": 10, "depth": 10},
			{"name": "cell", "width": 8, "depth": 8},
		],
		"doors": [[1, 2], [2, 3], [3, 4], [4, 1]],
		"things": [],
	}


# Hops from room 1 to every room, over a door list given here. The suite's own
# breadth-first walk, so it can disagree with the module's.
func _hops(count: int, doors: Array) -> Dictionary:
	var near := {}
	for i in count:
		near[i] = []
	for door in doors:
		var d: Vector2i = door
		near[int(d.x)].append(int(d.y))
		near[int(d.y)].append(int(d.x))
	var depth := {0: 0}
	var queue: Array = [0]
	while not queue.is_empty():
		var at: int = queue.pop_front()
		for nxt in near[at]:
			if not depth.has(nxt):
				depth[nxt] = int(depth[at]) + 1
				queue.append(nxt)
	return {"depth": depth, "near": near}


# --- FINDING: getting about follows the doors a body can use ---
func _getting_about_follows_the_usable_doors() -> void:
	var module := _dungeon()
	var ready := _layout_for(module, _ring())
	if not bool(ready["ok"]):
		_check(false, "a ring of four rooms builds (%s)" % str(ready["why"]))
		return
	var layout: Dictionary = ready["layout"]
	var root := Node3D.new()
	get_root().add_child(root)
	module.build(root, layout)

	# Open, as a baseline: one loop, no dead ends, and the ring says so.
	var open_metrics := module.measure(layout)
	_check(int(open_metrics["loops"]) == 1, "a ring of four has one way round (%d)" % int(open_metrics["loops"]))
	_check(int(open_metrics["dead_ends"]) == 0, "a ring of four has no dead ends (%d)" % int(open_metrics["dead_ends"]))

	# Shut the door that closes the ring. Nothing else changes.
	_check(DungeonModule.set_shut(layout, 3, 0, true), "the ring-closing door shuts")
	var metrics := module.measure(layout)
	var walk: Dictionary = module.walkable(layout)
	var usable: Array = walk["usable_doors"]

	_check(usable.size() == 3, "three of the four doors are usable (%d)" % usable.size())
	_check(int(metrics["door_count"]) == 4,
		"the dungeon still has four doors: a shut door still joins two rooms (%d)" % int(metrics["door_count"]))

	# THE ASSERTION THAT FAILS BEFORE 047. The panel said "1 loop".
	_check(int(metrics["loops"]) == 0,
		"with the ring broken there is no way round, and the panel says so (%d)" % int(metrics["loops"]))

	# Two rooms are left with one usable door each. Counted here.
	var mine := _hops(4, usable)
	var near: Dictionary = mine["near"]
	var ends := 0
	for i in 4:
		if (near[i] as Array).size() == 1:
			ends += 1
	_check(ends == 2, "this suite counts two dead ends over the usable doors (%d)" % ends)
	_check(int(metrics["dead_ends"]) == ends,
		"the panel's dead ends are the rooms with one usable door (%d vs %d)" % [
			int(metrics["dead_ends"]), ends])

	# The deepest room is the one the BODY walks furthest to, cross-checked
	# against route() rather than against a number typed here.
	var depth: Dictionary = mine["depth"]
	var furthest := 0
	var furthest_room := -1
	for i in depth:
		if int(depth[i]) > furthest:
			furthest = int(depth[i])
			furthest_room = int(i)
	_check(int(metrics["deepest"]) == furthest,
		"the panel's deepest is the hops over usable doors (%d vs %d)" % [
			int(metrics["deepest"]), furthest])
	_check(str(metrics["deepest_room"]) == str((layout["rooms"] as Array)[furthest_room]["name"]),
		"the panel names that room (%s vs %s)" % [
			str(metrics["deepest_room"]), str((layout["rooms"] as Array)[furthest_room]["name"])])
	_check(not module.route(layout, 0, furthest_room).is_empty(),
		"and the body can actually walk to the room the panel calls deepest")

	# Shut a second door: the cell is sealed off entirely. WALKABLE already
	# said so before 047; now the lines beside it agree with it.
	_check(DungeonModule.set_shut(layout, 2, 3, true), "a second door shuts")
	var sealed := module.measure(layout)
	var sealed_walk: Dictionary = module.walkable(layout)
	_check(int(sealed["walk_reached"]) == 3,
		"three of the four rooms are reachable (%d)" % int(sealed["walk_reached"]))
	_check(int(sealed["loops"]) == 0,
		"a line of three rooms and one sealed room has no way round (%d)" % int(sealed["loops"]))
	var sealed_hops: Dictionary = _hops(4, sealed_walk["usable_doors"])
	var sealed_depth: Dictionary = sealed_hops["depth"]
	_check(sealed_depth.has(int(_room_index(layout, str(sealed["deepest_room"])))),
		"the room the panel calls deepest is one a body can get to (%s)" % str(sealed["deepest_room"]))
	root.free()


func _room_index(layout: Dictionary, room_name: String) -> int:
	for i in (layout["rooms"] as Array).size():
		if str((layout["rooms"] as Array)[i]["name"]) == room_name:
			return i
	return -1


# --- FINDING: one list of unusable doorways, one type, and route() answers ---
func _one_list_one_type() -> void:
	var module := _dungeon()
	var ready := _layout_for(module, _ring())
	if not bool(ready["ok"]):
		_check(false, "a ring of four rooms builds (%s)" % str(ready["why"]))
		return
	var layout: Dictionary = ready["layout"]
	DungeonModule.set_shut(layout, 3, 0, true)
	var walk: Dictionary = module.walkable(layout)
	var blocked: Array = walk["blocked_doors"]
	var why: Array = walk["blocked_why"]
	_check(blocked.size() == 1, "one doorway cannot be used (%d)" % blocked.size())
	_check(why.size() == blocked.size(),
		"one sentence per unusable doorway (%d vs %d)" % [why.size(), blocked.size()])
	for b in blocked:
		_check(typeof(b) == TYPE_VECTOR2I,
			"every entry is a door pair, not a %d" % typeof(b))
	for w in why:
		_check(typeof(w) == TYPE_STRING and str(w).strip_edges() != "",
			"every sentence beside it says something")

	# A doorway no body fits, on a layout built BY HAND. No legal request
	# reaches this - 2597 legal ring dungeons were built headless this
	# session and none had one - so the only way to put the contract under
	# test is to construct the layout, and it is labelled rather than passed
	# off as a request. Before 047 route() threw here, on the String this
	# list carried for a blockage, and returned [].
	var by_hand := {
		"rooms": [
			{"name": "hall", "width": 10, "depth": 10},
			{"name": "vault", "width": 10, "depth": 10},
			{"name": "blockhouse", "width": 16, "depth": 16},
		],
		"doors": [Vector2i(0, 1), Vector2i(0, 2)],
		"slots": {0: Vector2i(0, 0), 1: Vector2i(2, 0), 2: Vector2i(1, 0)},
		"pitch": 16.0,
		"things": [],
	}
	var hand_walk: Dictionary = module.walkable(by_hand)
	var hand_blocked: Array = hand_walk["blocked_doors"]
	_check(not hand_blocked.is_empty(),
		"a room parked in the lane blocks the doorway through it")
	for b in hand_blocked:
		_check(typeof(b) == TYPE_VECTOR2I,
			"a blocked doorway is a door pair too, not a %d" % typeof(b))
	_check((hand_walk["blocked_why"] as Array).size() == hand_blocked.size(),
		"and it has its sentence beside it")
	_check(typeof(module.route(by_hand, 0, 1)) == TYPE_ARRAY,
		"route() answers over a blocked doorway rather than throwing")
	_check(module.route(by_hand, 0, 2).size() > 0,
		"and still routes through the doorway that is clear")


# --- GUARD: the loop count counts components, in one function ---
func _the_loop_count_counts_components() -> void:
	var module := _dungeon()

	# The formula itself, on a graph in two pieces: four rooms, two doors,
	# two components. Edges - rooms + components = 0, where the "+ 1" that
	# stood in two places by hand gives -1 and a "+ 1" over a connected
	# reading gives 1. Neither is the number of ways round, which is none.
	_check(DungeonModule.loop_count(2, 4, 2) == 0,
		"two doors over four rooms in two pieces is no way round (%d)" % DungeonModule.loop_count(2, 4, 2))
	_check(DungeonModule.loop_count(4, 4, 1) == 1,
		"a ring of four is one way round (%d)" % DungeonModule.loop_count(4, 4, 1))
	_check(DungeonModule.loop_count(3, 4, 1) == 0,
		"a line of four is no way round (%d)" % DungeonModule.loop_count(3, 4, 1))

	# And the design's own count, in the record pre_check writes, is the same
	# function - so the two readings cannot drift apart.
	# pre_check writes it into the record it was handed, not into content.
	var record := {}
	module.pre_check(module.validate(_ring())["content"], record)
	_check(record.has("reachability"), "pre_check records the design's reachability")
	if record.has("reachability"):
		var r: Dictionary = record["reachability"]
		_check(int(r["loops"]) == 1,
			"and the design's loop count is the same function's answer (%d)" % int(r["loops"]))
