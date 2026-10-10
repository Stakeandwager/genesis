extends SceneTree

# Can FAILED_UNWALKABLE ever happen?
#
# 005 added a physical reachability check. The negative test proves the check
# DETECTS a wall, by handing it a layout with a doorway removed. It does not
# prove any command a player could send can produce one. If every schema-valid
# dungeon is physically walkable, the check is a guard against future builder
# changes, not a live measurement - and the honest thing is to know which.
#
# So: sweep the whole legal space. Sizes at and near MIN_SIDE, random trees,
# rings, hubs, and long chains. Report every case where logical and physical
# disagree, and the narrowest clearance seen anywhere.

var failures: Array = []
var narrowest := 1e9
var narrowest_where := ""


func _solve(m: DungeonModule, rooms: Array, doors: Array) -> Dictionary:
	var v: Dictionary = m.validate({"rooms": rooms, "doors": doors})
	if not bool(v["ok"]):
		return {}
	var pre: Dictionary = m.pre_check(v["content"], {})
	if not bool(pre["ok"]):
		return {}
	var s: Dictionary = m.solve(pre["content"])
	return s["layout"] if bool(s["ok"]) else {}


func _initialize() -> void:
	var m := DungeonModule.new()
	var rng := RandomNumberGenerator.new()
	rng.seed = 20261010

	var tried := 0
	var solved := 0
	var divergent := 0

	# Every room at the smallest legal side, which is where a body is most
	# likely to be pinched.
	var sizes: Array = [m.MIN_SIDE, m.MIN_SIDE + 0.5, 5.0, 6.0, 10.0, 40.0]

	for size in sizes:
		for n in [2, 3, 5, 8, 12, 24]:
			for shape in ["chain", "hub", "ring", "random"]:
				tried += 1
				var rooms: Array = []
				for i in n:
					rooms.append({"name": "r%d" % i, "width": size, "depth": size})
				var doors: Array = _doors(shape, n, rng)
				var layout: Dictionary = _solve(m, rooms, doors)
				if layout.is_empty():
					continue
				solved += 1
				var w: Dictionary = m.walkable(layout)
				var reached := int(w["reached"])
				var count := int(w["room_count"])
				if reached != count or not (w["blocked_doors"] as Array).is_empty():
					divergent += 1
					failures.append("%s n=%d size=%.1f  logical %d/%d, physical %d/%d  blocked %s" % [
						shape, n, size, n, n, reached, count, w["blocked_doors"]])

	# A mixed-size dungeon: one tiny room on the end of a chain of large ones,
	# which is the shape most likely to pinch a doorway.
	for size in [m.MIN_SIDE, 5.0, 6.0]:
		tried += 1
		var rooms: Array = [
			{"name": "hall", "width": 40.0, "depth": 40.0},
			{"name": "mid", "width": 20.0, "depth": 6.0},
			{"name": "closet", "width": size, "depth": size},
		]
		var layout: Dictionary = _solve(m, rooms, [[1, 2], [2, 3]])
		if layout.is_empty():
			continue
		solved += 1
		var w: Dictionary = m.walkable(layout)
		if int(w["reached"]) != int(w["room_count"]):
			divergent += 1
			failures.append("mixed closet %.1f m  physical %d/%d  blocked %s" % [
				size, int(w["reached"]), int(w["room_count"]), w["blocked_doors"]])

	# How much room to spare does a body actually have in the tightest legal
	# room? Interior width minus the wall on each side, against the body.
	var clear: float = m.MIN_SIDE - 2.0 * m.WALL_THICK
	narrowest = clear
	narrowest_where = "a %.1f m room with %.1f m walls" % [m.MIN_SIDE, m.WALL_THICK]

	print("SWEEP  tried %d, solved %d, logical and physical disagreed %d times" % [
		tried, solved, divergent])
	for f in failures:
		print("  DIVERGED  " + f)
	print("TIGHTEST  %s leaves %.1f m of floor; a body is %.1f m, so %.1f m to spare" % [
		narrowest_where, clear, m.BODY, clear - m.BODY])
	if divergent == 0:
		print("VERDICT   no legal command reaches FAILED_UNWALKABLE.")
		print("          physical reachability is a dormant guard, not a live measurement.")
	else:
		print("VERDICT   FAILED_UNWALKABLE is reachable from a legal command.")
	quit(0)


func _doors(shape: String, n: int, rng: RandomNumberGenerator) -> Array:
	var out: Array = []
	match shape:
		"chain":
			for i in range(1, n):
				out.append([i, i + 1])
		"hub":
			for i in range(2, n + 1):
				out.append([1, i])
		"ring":
			for i in range(1, n):
				out.append([i, i + 1])
			if n > 2:
				out.append([n, 1])
		"random":
			for i in range(2, n + 1):
				out.append([rng.randi_range(1, i - 1), i])
	return out
