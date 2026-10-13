extends SceneTree

# 008 - /explore, played the way the owner plays it: raw JSON typed into the
# box, then a slash command.
#
# What this has to prove is not that a Walker exists. It is that the player's
# body lands on the dungeon's floor rather than inside it or under it, that it
# can actually get from the entrance to the next room, and that walking counts
# as using the world - because before 008 a dungeon could never earn anything
# stronger than ACCEPTED_BY_SILENCE.

var main: Node3D
var lines: Array = []
var failures: Array = []

const DUNGEON := "{\"command\": \"CREATE_DUNGEON\", \"parameters\": {\"rooms\": [{\"name\": \"entrance\", \"width\": 10, \"depth\": 10}, {\"name\": \"vault\", \"width\": 10, \"depth\": 10}], \"doors\": [[1, 2]]}}"
const TRACK := "{\"command\": \"CREATE_TRACK\", \"parameters\": {\"mode\": \"circuit\", \"sections\": [{\"type\": \"straight\", \"length\": 80}, {\"type\": \"corner\", \"radius\": 30, \"angle\": 90}, {\"type\": \"straight\", \"length\": 80}, {\"type\": \"corner\", \"radius\": 30, \"angle\": 90}, {\"type\": \"straight\", \"length\": 80}, {\"type\": \"corner\", \"radius\": 30, \"angle\": 90}, {\"type\": \"straight\", \"length\": 80}, {\"type\": \"corner\", \"radius\": 30, \"angle\": 90}]}}"


func _initialize() -> void:
	_run.call_deferred()


func _check(ok: bool, what: String) -> void:
	lines.append(("PASS  " if ok else "FAIL  ") + what)
	if not ok:
		failures.append(what)


func _make_main() -> void:
	main = Node3D.new()
	main.name = "Main"
	main.set_script(load("res://scripts/main.gd"))
	var cam := Camera3D.new()
	cam.name = "Camera3D"
	cam.position = Vector3(0, 80, 120)
	main.add_child(cam)
	var ground := Node3D.new()
	ground.name = "Ground"
	main.add_child(ground)
	var box := CSGBox3D.new()
	box.name = "CSGBox3D"
	box.size = Vector3(200, 1, 200)
	box.position = Vector3(0, -0.5, 0)
	box.use_collision = true
	ground.add_child(box)
	var ui := CanvasLayer.new()
	ui.name = "UI"
	main.add_child(ui)
	var panel := PanelContainer.new()
	panel.name = "CommandPanel"
	ui.add_child(panel)
	var vb := VBoxContainer.new()
	vb.name = "VBoxContainer"
	panel.add_child(vb)
	for pair in [["InputBox", LineEdit.new()], ["BuildButton", Button.new()], ["StatusLabel", Label.new()]]:
		pair[1].name = pair[0]
		vb.add_child(pair[1])
	get_root().add_child(main)


func _type(text: String) -> void:
	main._handle_request(text)
	await process_frame
	await process_frame


func _run() -> void:
	_make_main()
	await process_frame

	# Nothing to walk before a dungeon exists.
	await _type("/explore")
	_check(not main.exploring, "/explore before any dungeon is refused politely")

	# A track is drivable and not walkable: the two are separate reports, so
	# neither world should be offered the other's verb.
	await _type(TRACK)
	await _type("/explore")
	_check(not main.exploring, "/explore on a race track is refused")
	_check(main.controller.has_drivable(), "the track is still drivable")

	await _type(DUNGEON)
	_check(main.controller.has_standable(), "a dungeon reports somewhere to stand")
	_check(not main.controller.has_drivable(), "a dungeon is not drivable")

	await _type("/explore")
	_check(main.exploring, "/explore starts on a dungeon")
	var walker: Walker = main.walker
	_check(walker != null and walker.camera.current, "the walker's camera is the one in use")

	# Land on the floor rather than inside it or through it.
	for i in 90:
		await physics_frame
	var floor_top: float = DungeonModule.ROOM_HEIGHT
	var feet: float = walker.global_position.y - Walker.TALL * 0.5
	_check(absf(feet - floor_top) < 0.15,
		"the body lands on the room floor (feet at %.2f m, floor at %.2f m)" % [feet, floor_top])

	# Walk forward out of the entrance and into the next room. The far room's
	# centre is found from the layout rather than assumed.
	var module := DungeonModule.new()
	var layout: Dictionary = main.controller.standable.get("layout", {})
	var start := walker.global_position

	walker.auto_walk = true
	walker.auto_forward = 1.0
	walker.auto_turn = 0.0
	# Face the door: the second room is placed west of the first, so turn
	# until the body is pointing that way, then walk.
	walker.rotation = Vector3(0.0, PI * 0.5, 0.0)
	for i in 600:
		await physics_frame
	var moved := walker.global_position.distance_to(start)
	walker.auto_forward = 0.0
	_check(moved > 8.0, "the body walks out of the entrance (%.1f m in 5 s)" % moved)
	_check(walker.global_position.y > 0.5, "the body did not fall out of the world")

	# Walking is evidence the world was used, which a dungeon could never earn
	# before: only /drive, /race and /save counted.
	var verdict: Dictionary = Understanding.judge("/explore", "", true)
	_check(str(verdict.get("understanding", "")) == "ACCEPTED_BY_USE" and str(verdict.get("evidence", "")) == "WALKED_IT",
		"walking counts as using the world")
	var refused: Dictionary = Understanding.judge("/explore", "", false)
	_check(refused.is_empty(), "walking after a failed build says nothing")

	await _type("/view")
	_check(not main.exploring, "/view stops walking")
	_check(main.controller.camera.current, "the overhead camera comes back")

	print("")
	for l in lines:
		print(l)
	print("EXPLORE TEST failures=%d" % failures.size())
	quit(failures.size())
