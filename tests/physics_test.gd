extends SceneTree
# Does a described car actually drive differently? Full throttle in a
# straight line on flat ground, same seconds, measure the distance.
#
# --- 038: and does `braking` do what the prompt says it does? ---
#
# The prompt tells the model: someone who wants "a car that stops better"
# wants braking changed AND NOTHING ELSE. That is a claim about Genesis of
# the kind tests/claim_field_test.gd sweeps for, and it is the one of the
# three it cannot measure: BootsTool predicts a stop in closed form, so a
# boots claim is arithmetic, but a car's stop happens in the physics and the
# only way to read it is to drive one. 038 found the boots claim of the same
# shape was FALSE and had been since 013, so the car's was worth measuring
# rather than reading off the field's name - which is all "braking" is, a
# name (TRAPS 11: the fix is to the class, and so is the measurement).
#
# Both halves, because "and nothing else" is half the claim: raising braking
# must shorten the stop, and must leave the run to speed exactly as it was.
var results: Array = []
var stops: Array = []

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	var ground := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(4000, 2, 4000)
	shape.shape = box
	shape.position = Vector3(0, -1, 0)
	ground.add_child(shape)
	root.add_child(ground)

	for trial in [["ordinary", {}], ["powerful", {"power": 1800.0}], ["feeble", {"power": 400.0}]]:
		var car := Car.new()
		root.add_child(car)
		car.equip(CarTool.new().validate({"tool": "car", "spec": trial[1]})["spec"])
		car.place_at(Vector3(0, 1.0, 0), 0.0)
		car.freeze = false
		car.auto_drive = true
		car.auto_throttle = 1.0
		car.auto_steer = 0.0
		for i in 600:                      # 5 seconds at 120 ticks
			await physics_frame
		results.append([trial[0], car.global_position.length(), car.speed_kmh()])
		car.queue_free()
		await physics_frame

	# --- braking: five seconds of throttle, then everything the brake has ---
	#
	# The run to speed is measured in the same trial as the stop, so the two
	# readings cannot come from different cars. The bounds are read from
	# CarTool rather than typed, for the reason 035 gave about the prompt.
	for trial in [
		["ordinary", {}],
		["hard brakes", {"braking": CarTool.BRAKING.y}],
		["soft brakes", {"braking": CarTool.BRAKING.x}],
	]:
		var car := Car.new()
		root.add_child(car)
		car.equip(CarTool.new().validate({"tool": "car", "spec": trial[1]})["spec"])
		car.place_at(Vector3(0, 1.0, 0), 0.0)
		car.freeze = false
		car.auto_drive = true
		car.auto_steer = 0.0
		car.auto_throttle = 1.0
		for i in 600:                      # the same 5 seconds as above
			await physics_frame
		var ran: float = car.global_position.length()
		var reached := car.speed_kmh() / 3.6
		var from := car.global_position
		car.auto_throttle = -1.0
		var ticks := 0
		while car.speed_kmh() / 3.6 > 0.5 and ticks < 2400:
			await physics_frame
			ticks += 1
		stops.append([trial[0], ran, reached, car.global_position.distance_to(from), ticks])
		car.queue_free()
		await physics_frame

	var bad := 0
	for r in results:
		print("  %-10s travelled %6.1f m, reached %5.1f km/h" % [r[0], r[1], r[2]])
	var ordinary: float = results[0][1]
	var powerful: float = results[1][1]
	var feeble: float = results[2][1]
	if powerful <= ordinary * 1.05:
		print("FAIL  more power did not travel further"); bad += 1
	if feeble >= ordinary * 0.95:
		print("FAIL  less power did not travel less"); bad += 1
	if bad == 0:
		print("PASS  the spec reaches the physics: %.0f m < %.0f m < %.0f m" % [feeble, ordinary, powerful])

	print("")
	for r in stops:
		print("  %-12s ran %6.1f m to %5.2f m/s, then stopped in %6.2f m (%d ticks)" % [
			r[0], r[1], r[2], r[3], r[4]])
	var plain_run: float = stops[0][1]
	var plain_stop: float = stops[0][3]
	var hard_stop: float = stops[1][3]
	var soft_stop: float = stops[2][3]
	if not (hard_stop < plain_stop and plain_stop < soft_stop):
		print("FAIL  braking did not order the stops: %.2f m, %.2f m, %.2f m" % [hard_stop, plain_stop, soft_stop])
		bad += 1
	else:
		print("PASS  more braking really does stop shorter: %.2f m < %.2f m < %.2f m" % [
			hard_stop, plain_stop, soft_stop])
	# AND NOTHING ELSE. A tenth of a percent of the run, which is the same
	# five seconds of the same throttle in all three: if braking touched the
	# way a car gets to speed, this is where it would show.
	var worst := 0.0
	for r in stops:
		worst = maxf(worst, absf(float(r[1]) - plain_run))
	if worst > plain_run * 0.001:
		print("FAIL  braking changed the run to speed by %.3f m, so \"and nothing else\" is false" % worst)
		bad += 1
	else:
		print("PASS  and changes nothing else: every run to speed within %.3f m of %.1f m" % [worst, plain_run])

	print("PHYSICS TEST failures=%d" % bad)
	quit(bad)
