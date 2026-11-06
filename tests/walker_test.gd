extends SceneTree

# 007 - the first physical measurement that uses a body.
#
# sweep_test.gd showed that geometric reachability can never disagree with the
# door graph: the tightest legal room leaves a body 0.8 m of slack. It also
# showed why the two SHOULD eventually disagree - a flat-rectangle checker
# cannot see height at all, and the surfaces a body walks on are at different
# heights.
#
# 126: and the two sentences that used to stand here were FALSE, and had been
# for most of this project's life. They said "room floors sit at ROOM_HEIGHT
# 1.6 and corridors at CORRIDOR_HEIGHT 1.3, so every doorway is a 0.3 m step
# up". CORRIDOR_HEIGHT is 1.58, not 1.3 - it was raised for exactly this
# reason, and dungeon_module.gd's own comment above that constant records what
# the 0.3 m version cost: "a walker reached 1 room in 5 while the geometric
# check still reported 5 of 5". A doorway is a 0.02 m step today and is not
# the hazard. The hazard moved and nothing moved with it: the step from the
# GROUND PAD up onto a corridor is PAD_HEIGHT 1.0 to CORRIDOR_HEIGHT 1.58,
# which is 0.58 m, and a body that leaves the floored line cannot get back up
# it. Measured, not reasoned: 126 drove a stalled carrier at that step on
# eight headings for 12 s each and it never rose above the pad.
#
# This walks a real CharacterBody3D along every corridor and reports which
# rooms a moving body actually reaches. Where it disagrees with walkable(),
# the disagreement is the finding.
#
# 126: AND THE SHAPES BELOW DO NOT COVER THE CLASS, WHICH IS WHERE THE
# DISAGREEMENT ACTUALLY IS. "every corridor" above is a claim about this
# file's own fixture list, and nothing checks it. All three shapes - a row of
# five, four off a hall, two rooms - place every room in a slot ORTHOGONALLY
# ADJACENT to its neighbour, so every corridor they build has ONE leg.
# _corridor() also builds FOUR-leg corridors, for any door between rooms the
# lattice could not seat side by side, and a body cannot walk one: see
# "Human decision needed" 40 in docs/HANDOVER.md for the table, which fails
# at every room size from 11 m to the legal maximum of 40 m and arrives at
# every size below. The shape that shows it is a fifth room off a hall - the
# fifth neighbour is the one that has to take a ring-1 CORNER slot.
#
# IT IS NOT ADDED HERE, DELIBERATELY. Adding it would make this suite red
# against today's code, and the fix is a placement rule, a geometry change or
# a navigation change - all three of them the owner's. A suite asserting the
# fault would have to be deleted by whoever fixes it, which is a tripwire and
# not a guard (halt_cause_test's header makes the same argument). The
# measurement is in HANDOVER; this note is here so the next session reading
# "every corridor" knows what that does and does not mean.

const SPEED := 6.0
const GRAVITY := 20.0
const MAX_TICKS := 1500            # per door, at 120 ticks a second
const STUCK_TICKS := 150           # no progress for this long is stuck
const ARRIVE := 1.2                # metres; close enough to count as there

var module: DungeonModule
var lines: Array = []
var failures: Array = []
var asserted := 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	module = DungeonModule.new()

	var shapes := [
		["a row of five", ["a", "b", "c", "d", "e"], [[1, 2], [2, 3], [3, 4], [4, 5]]],
		["four off a hall", ["hall", "a", "b", "c", "d"], [[1, 2], [1, 3], [1, 4], [1, 5]]],
		["two rooms", ["a", "b"], [[1, 2]]],
	]

	for s in shapes:
		await _try_shape(str(s[0]), s[1] as Array, s[2] as Array)

	print("")
	for l in lines:
		print(l)
	print("WALKER TEST %d assertions, failures=%d" % [asserted, failures.size()])
	quit(failures.size())


func _try_shape(title: String, names: Array, doors: Array) -> void:
	var rooms: Array = []
	for n in names:
		rooms.append({"name": n, "width": 10.0, "depth": 10.0})

	var v: Dictionary = module.validate({"rooms": rooms, "doors": doors})
	var pre: Dictionary = module.pre_check(v["content"], {})
	var solved: Dictionary = module.solve(pre["content"])
	var layout: Dictionary = solved["layout"]

	var world := Node3D.new()
	root.add_child(world)
	module.build(world, layout)
	await physics_frame

	var geometric: Dictionary = module.walkable(layout)
	var rects: Array = module._rects(layout)

	var walker := CharacterBody3D.new()
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = module.BODY * 0.5
	capsule.height = 1.8
	shape.shape = capsule
	walker.add_child(shape)
	root.add_child(walker)

	# Each door walked on its own, so one blockage cannot hide another.
	var passed: Array = []
	var blocked: Array = []
	for door in layout["doors"]:
		var d: Vector2i = door
		var path: Array = module._corridor_path(layout, d.x, d.y)
		var result: Dictionary = await _walk(walker, rects, d.x, d.y, path)
		if bool(result["ok"]):
			passed.append(d)
		else:
			blocked.append({"door": d, "why": result})

	var reached := _spread(layout["rooms"].size(), passed)
	var count: int = layout["rooms"].size()
	var geo := int(geometric["reached"])

	asserted += 1
	var ok := reached.size() == count
	lines.append("%-18s geometry %d/%d, body %d/%d%s" % [
		title, geo, count, reached.size(), count,
		"" if ok else "   <-- DISAGREES"])
	for b in blocked:
		var w: Dictionary = b["why"]
		lines.append("    door %s stopped at (%.1f, %.1f, %.1f) after %d ticks, %s" % [
			str(b["door"]), w["at"].x, w["at"].y, w["at"].z, int(w["ticks"]), str(w["reason"])])
	if not ok:
		failures.append(title)

	walker.queue_free()
	world.queue_free()
	await physics_frame


# Walk the corridor path, then into the far room's centre. Reports where it
# stopped if it never arrives, because WHERE a body stops is the whole value
# of using one.
func _walk(walker: CharacterBody3D, rects: Array, a: int, b: int, path: Array) -> Dictionary:
	var start: Rect2 = rects[a]
	var finish: Rect2 = rects[b]
	var from := Vector3(start.position.x + start.size.x * 0.5, module.ROOM_HEIGHT + 1.2,
		start.position.y + start.size.y * 0.5)
	walker.global_position = from
	walker.velocity = Vector3.ZERO
	for i in 40:
		walker.velocity.y -= GRAVITY * (1.0 / 120.0)
		walker.move_and_slide()
		await physics_frame

	var marks: Array = []
	for p in path:
		var point: Vector2 = p
		marks.append(Vector3(point.x, 0.0, point.y))
	marks.append(Vector3(finish.position.x + finish.size.x * 0.5, 0.0,
		finish.position.y + finish.size.y * 0.5))

	var ticks := 0
	for mark in marks:
		var target: Vector3 = mark
		var best := 1e9
		var stale := 0
		while true:
			ticks += 1
			if ticks > MAX_TICKS:
				return {"ok": false, "at": walker.global_position, "ticks": ticks,
					"reason": "ran out of time"}
			var here := walker.global_position
			var flat := Vector3(target.x - here.x, 0.0, target.z - here.z)
			var gap := flat.length()
			if gap < ARRIVE:
				break
			if gap < best - 0.01:
				best = gap
				stale = 0
			else:
				stale += 1
				if stale > STUCK_TICKS:
					return {"ok": false, "at": here, "ticks": ticks,
						"reason": "stuck %.1f m short of (%.1f, %.1f)" % [gap, target.x, target.z]}
			var step := flat.normalized() * SPEED
			walker.velocity.x = step.x
			walker.velocity.z = step.z
			if walker.is_on_floor():
				walker.velocity.y = 0.0
			else:
				walker.velocity.y -= GRAVITY * (1.0 / 120.0)
			walker.move_and_slide()
			await physics_frame
			if walker.global_position.y < -20.0:
				return {"ok": false, "at": walker.global_position, "ticks": ticks,
					"reason": "fell out of the world"}
	return {"ok": true, "at": walker.global_position, "ticks": ticks, "reason": ""}


# Which rooms the entrance reaches using only doors a body actually got through.
func _spread(count: int, passed: Array) -> Array:
	var near := {}
	for i in count:
		near[i] = []
	for d in passed:
		var e: Vector2i = d
		near[e.x].append(e.y)
		near[e.y].append(e.x)
	var seen := {0: true}
	var queue := [0]
	while not queue.is_empty():
		var at: int = queue.pop_front()
		for n in near[at]:
			if not seen.has(n):
				seen[n] = true
				queue.append(n)
	return seen.keys()
