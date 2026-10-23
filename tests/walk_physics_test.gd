extends SceneTree

# 009 - walking is a force on a mass, so its numbers can be measured rather
# than asserted. The sibling of physics_test.gd, which does the same for the
# car: full effort in a straight line on flat ground, same seconds, measure.
#
# What is checked here is that the arithmetic in walker.gd is TRUE of the body
# that moves, not just of the comment: top speed should land where
# push / (mass * drag) says it will, a half-pressed stick should settle at
# half of it, and letting go should coast rather than stop dead.

var lines: Array = []
var failures: Array = []
var asserted := 0


func _initialize() -> void:
	_run.call_deferred()


func _check(ok: bool, what: String) -> void:
	asserted += 1
	lines.append(("PASS  " if ok else "FAIL  ") + what)
	if not ok:
		failures.append(what)


func _ground() -> void:
	var ground := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(4000, 2, 4000)
	shape.shape = box
	shape.position = Vector3(0, -1, 0)
	ground.add_child(shape)
	root.add_child(ground)


func _make() -> Walker:
	var w := Walker.new()
	root.add_child(w)
	w.auto_walk = true
	w.auto_turn = 0.0
	w.place_at(Vector3(0, 1.0, 0), 0.0)
	return w


func _run() -> void:
	_ground()
	await physics_frame

	# --- top speed is a result, not a setting ---
	var w := _make()
	var predicted_walk: float = w.push / (w.mass * w.drag)
	w.auto_forward = 1.0
	for i in Engine.physics_ticks_per_second * 10:
		await physics_frame
	var settled := w.speed_mps()
	lines.append("  predicted %.2f m/s, measured %.2f m/s" % [predicted_walk, settled])
	_check(absf(settled - predicted_walk) < 0.25,
		"full effort settles where push / (mass * drag) says")

	# --- an analogue input scales the force, so it settles proportionally ---
	w.auto_forward = 0.5
	for i in Engine.physics_ticks_per_second * 10:
		await physics_frame
	var half := w.speed_mps()
	lines.append("  half effort  %.2f m/s, half of full is %.2f m/s" % [half, settled * 0.5])
	_check(absf(half - settled * 0.5) < 0.25,
		"a half-pressed stick settles at half the speed")

	# --- letting go coasts ---
	w.auto_forward = 1.0
	for i in Engine.physics_ticks_per_second * 10:
		await physics_frame
	var before := w.speed_mps()
	w.auto_forward = 0.0
	var moved := w.global_position
	for i in Engine.physics_ticks_per_second:        # one second of nothing
		await physics_frame
	var coasted := moved.distance_to(w.global_position)
	lines.append("  let go at %.2f m/s, coasted %.2f m in a second" % [before, coasted])
	_check(coasted > 0.8, "a body carries its momentum instead of stopping dead")
	_check(w.speed_mps() < before, "and slows while it does")

	# --- reaching speed takes time ---
	w.queue_free()
	await physics_frame
	var w2 := _make()
	w2.auto_forward = 1.0
	var ticks := 0
	while ticks < Engine.physics_ticks_per_second * 10 and w2.speed_mps() < predicted_walk * 0.63:
		ticks += 1
		await physics_frame
	# Read the real tick rate rather than assuming the --fixed-fps figure:
	# that flag sets the iteration rate, while physics_ticks_per_second is
	# what a physics frame actually is, and Main sets it to 120 while this
	# project leaves it at the default. Dividing by the wrong one halved the
	# measured time and made the physics look twice as quick as it is.
	var seconds := float(ticks) / float(Engine.physics_ticks_per_second)
	lines.append("  63%% of top speed after %.2f s at %d Hz (drag says %.2f s)" % [
		seconds, Engine.physics_ticks_per_second, 1.0 / w2.drag])
	_check(absf(seconds - 1.0 / w2.drag) < 0.25,
		"speed is built up over the time drag says, not switched on")

	# --- running is faster than walking, by the same arithmetic ---
	var predicted_run: float = w2.run_push / (w2.mass * w2.drag)
	_check(predicted_run > predicted_walk * 1.5,
		"running is meaningfully faster (%.1f m/s against %.1f m/s)" % [predicted_run, predicted_walk])

	print("")
	for l in lines:
		print(l)
	print("WALK PHYSICS %d assertions, failures=%d" % [asserted, failures.size()])
	quit(failures.size())
