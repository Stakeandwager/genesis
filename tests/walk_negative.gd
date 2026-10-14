extends SceneTree
func _initialize() -> void:
	var m := DungeonModule.new()
	var bad := 0

	var rooms: Array = []
	for n in ["a", "b", "c"]:
		rooms.append({"name": n, "width": 10.0, "depth": 10.0})
	var doors: Array = [[1, 2], [2, 3]]
	var v: Dictionary = m.validate({"rooms": rooms, "doors": doors})
	var pre: Dictionary = m.pre_check(v["content"], {})
	var s: Dictionary = m.solve(pre["content"])
	var layout: Dictionary = s["layout"]
	var rects: Array = m._rects(layout)

	# A room with no doorway cut: all four walls solid.
	var sealed: Array = m._wall_rects(rects[0], [])
	var floors: Array = [rects[0], rects[1]]

	# Walking out of a sealed room must be reported as blocked.
	var out_path: Array = []
	var a: Rect2 = rects[0]
	for k in 40:
		out_path.append(a.get_center() + Vector2(0, -float(k) * 0.5))
	var stuck: Dictionary = m._first_blockage(out_path, floors, sealed)
	if stuck.is_empty():
		bad += 1; print("FAIL  walked out through a solid wall")
	else:
		print("PASS  sealed room blocks the way out: %s" % str(stuck["why"]))

	# The same walk with the doorway cut must succeed where the wall was.
	var legs: Array = m._corridor(layout, 0, 1)
	var open_walls: Array = m._wall_rects(rects[0], [legs[0]])
	var all_floors: Array = [rects[0], rects[1]]
	for leg in legs:
		all_floors.append(leg)
	var path: Array = m._corridor_path(layout, 0, 1)
	var through: Dictionary = m._first_blockage(path, all_floors, open_walls + m._wall_rects(rects[1], [legs[legs.size()-1]]))
	if through.is_empty():
		print("PASS  with the doorway cut, the same walk gets through")
	else:
		bad += 1; print("FAIL  blocked through an open doorway: %s" % str(through["why"]))

	print("NEGATIVE TEST failures=%d" % bad)
	quit(bad)
