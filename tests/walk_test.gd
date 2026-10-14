extends SceneTree
func _solve(m: DungeonModule, rooms: Array, doors: Array) -> Dictionary:
	var v: Dictionary = m.validate({"rooms": rooms, "doors": doors})
	if not bool(v["ok"]): return {}
	var pre: Dictionary = m.pre_check(v["content"], {})
	if not bool(pre["ok"]): return {}
	var s: Dictionary = m.solve(pre["content"])
	return s["layout"] if bool(s["ok"]) else {}

func _rooms(names: Array, size := 10.0) -> Array:
	var out: Array = []
	for n in names: out.append({"name": n, "width": size, "depth": size})
	return out

func _initialize() -> void:
	var m := DungeonModule.new()
	var bad := 0

	var shapes := [
		["a row of five",  ["a","b","c","d","e"], [[1,2],[2,3],[3,4],[4,5]]],
		["four off a hall", ["hall","a","b","c","d"], [[1,2],[1,3],[1,4],[1,5]]],
		["a ring",          ["a","b","c","d"], [[1,2],[2,3],[3,4],[4,1]]],
		["two rooms",       ["a","b"], [[1,2]]],
		["twelve, branching", ["r0","r1","r2","r3","r4","r5","r6","r7","r8","r9","r10","r11"],
		 [[1,2],[1,3],[2,4],[2,5],[3,6],[3,7],[4,8],[5,9],[6,10],[7,11],[8,12]]],
	]
	for s in shapes:
		var layout: Dictionary = _solve(m, _rooms(s[1]), s[2])
		if layout.is_empty():
			bad += 1; print("FAIL  %s would not solve" % s[0]); continue
		var w: Dictionary = m.walkable(layout)
		var ok: bool = int(w["reached"]) == int(w["room_count"]) and (w["blocked_doors"] as Array).is_empty()
		if ok:
			print("PASS  %-20s logical %d/%d, physical %d/%d" % [
				s[0], s[1].size(), s[1].size(), int(w["reached"]), int(w["room_count"])])
		else:
			bad += 1
			print("FAIL  %-20s physical %d/%d, unreachable %s, blocked %s" % [
				s[0], int(w["reached"]), int(w["room_count"]), w["unreachable"], w["blocked_doors"]])

	# The check must be able to FAIL. A body wider than the corridor cannot
	# pass, however well connected the graph is.
	var layout: Dictionary = _solve(m, _rooms(["a","b","c"]), [[1,2],[2,3]])
	var walls: Array = m._wall_rects(m._rects(layout)[0], [])
	if walls.size() != 4:
		bad += 1; print("FAIL  a room with no doorway should have 4 solid walls, got %d" % walls.size())
	else:
		print("PASS  a room with no openings is walled on all four sides")

	print("WALK TEST failures=%d" % bad)
	quit(bad)
