extends SceneTree
# Does a described car actually drive differently? Full throttle in a
# straight line on flat ground, same seconds, measure the distance.
var results: Array = []

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
	print("PHYSICS TEST failures=%d" % bad)
	quit(bad)
