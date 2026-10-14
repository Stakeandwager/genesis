extends SceneTree

# Milestone 3, acceptance condition 5: the ledger must match the world.
#
# Every other test checks what Genesis DECIDED. This one checks what Genesis
# WROTE DOWN, by reading the records back off disk and comparing them against
# an independent reading of the world the records are about.
#
# That is a different claim. A system can judge delivery correctly and still
# write a record that says something else - a field filled from the wrong
# variable, an outcome written before the check, a log line that drifts from
# the decision it reports. Nothing until now would have caught it.
#
# So: run two errands, one that succeeds and one that cannot, then re-read
# the log and ask of each record whether the world agrees with it.

var main: Node3D
var lines: Array = []
var failures: Array = []

const ROOMS := "{\"name\": \"entrance\", \"width\": 12, \"depth\": 12}, {\"name\": \"store\", \"width\": 12, \"depth\": 12}, {\"name\": \"vault\", \"width\": 12, \"depth\": 12}"


func _check(ok: bool, what: String) -> void:
	lines.append(("PASS  " if ok else "FAIL  ") + what)
	if not ok:
		failures.append(what)


func _initialize() -> void:
	_run.call_deferred()


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
	box.size = Vector3(400, 1, 400)
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


func _settle(limit := 60) -> void:
	var ticks := 0
	while ticks < Engine.physics_ticks_per_second * limit and main.npc != null and main.npc.state == Npc.GOING:
		ticks += 1
		await physics_frame


# Everything written to the log, read back off disk.
func _written() -> Array:
	var out: Array = []
	var file := FileAccess.open(TrackLog.PATH, FileAccess.READ)
	if file == null:
		return out
	while not file.eof_reached():
		var line := file.get_line().strip_edges()
		if line == "":
			continue
		var json := JSON.new()
		if json.parse(line) == OK and typeof(json.data) == TYPE_DICTIONARY:
			out.append(json.data)
	file.close()
	return out


# Which room a named thing stands in, asked of the world and nothing else.
func _world_says(label: String) -> int:
	var module := DungeonModule.new()
	var holder: Node3D = main.controller.standable["node"]
	var layout: Dictionary = main.controller.standable["layout"]
	for entry in (main.controller.standable.get("things", []) as Array):
		var t: Dictionary = entry
		if str(t["name"]) == label:
			var node: Node3D = t["node"]
			if not is_instance_valid(node):
				return -2
			var local: Vector3 = holder.to_local(node.global_position)
			return module.room_of(layout, Vector2(local.x, local.z))
	return -2


func _run() -> void:
	_make_main()
	await process_frame
	var before := _written().size()

	await _type("{\"command\": \"CREATE_DUNGEON\", \"parameters\": {\"rooms\": [%s], \"doors\": [[1, 2], [2, 3]], \"things\": [{\"name\": \"red_key\", \"in\": 2}]}}" % ROOMS)

	# --- an errand that should succeed ---
	await _type("{\"command\": \"ORDER\", \"parameters\": {\"goal\": \"carry\", \"thing\": \"red_key\", \"room\": \"vault\"}}")
	await _settle()
	var good_room := _world_says("red_key")

	# --- an errand that cannot succeed ---
	# The character is standing on the key after the first errand, so an order
	# given here would be picked up on the very first physics frame - before
	# any interference could land. The key is put back in the store first, so
	# there is a walk to interrupt and the sabotage is deterministic.
	var module := DungeonModule.new()
	var holder: Node3D = main.controller.standable["node"]
	var rects: Array = module._rects(main.controller.standable["layout"])
	var store: Rect2 = rects[1]
	var key: Node3D = (main.controller.standable["things"] as Array)[0]["node"]
	if key.get_parent() != holder:
		key.get_parent().remove_child(key)
		holder.add_child(key)
	key.global_position = holder.to_global(Vector3(
		store.position.x + store.size.x * 0.5, DungeonModule.ROOM_HEIGHT + 0.45,
		store.position.y + store.size.y * 0.5))
	await physics_frame

	await _type("{\"command\": \"ORDER\", \"parameters\": {\"goal\": \"carry\", \"thing\": \"red_key\", \"room\": \"entrance\"}}")
	main.npc.pickup_at = -1
	await _settle()
	var bad_room := _world_says("red_key")

	await process_frame
	var records := _written().slice(before)
	var orders: Array = []
	var outcomes: Array = []
	for r in records:
		var row: Dictionary = r
		if str(row.get("command", "")) == "ORDER":
			orders.append(row)
		elif str(row.get("type", "")) == "outcome":
			outcomes.append(row)

	lines.append("  %d records written, %d orders, %d outcomes" % [records.size(), orders.size(), outcomes.size()])
	_check(orders.size() == 2 and outcomes.size() == 2,
		"both errands left an order and an outcome on disk")

	if orders.size() < 2 or outcomes.size() < 2:
		_finish()
		return

	# --- every outcome points at an order that was actually written ---
	var ids := {}
	for o in orders:
		ids[str((o as Dictionary)["id"])] = true
	var dangling := 0
	for o in outcomes:
		if not ids.has(str((o as Dictionary)["about"])):
			dangling += 1
	_check(dangling == 0, "every outcome points at an order that is on disk")

	# --- the order says where the key started, and it is where it started ---
	_check(str(orders[0].get("thing_from", "")) == "store",
		"the first order recorded the key starting in the %s" % str(orders[0].get("thing_from", "")))

	# --- and now the one that matters: does the world agree with the record? ---
	var first: Dictionary = outcomes[0]
	var second: Dictionary = outcomes[1]
	lines.append("  record 1 says %-14s world says the key is in room %d" % [
		str(first["outcome"]), good_room + 1])
	lines.append("  record 2 says %-14s world says the key is in room %d" % [
		str(second["outcome"]), bad_room + 1])

	_check(str(first["outcome"]) == "DELIVERED" and good_room == 2,
		"record 1 claims DELIVERED and the key really is in the vault")
	_check(str(second["outcome"]) == "NOT_DELIVERED" and bad_room != 0,
		"record 2 claims NOT_DELIVERED and the key really is not in the entrance")
	_check(str(second.get("thing_in", "")) == "store" and bad_room == 1,
		"and it names where the key actually is: the %s" % str(second.get("thing_in", "")))

	# --- the carrier's account is on disk, and apart from the verdict ---
	_check(first.has("carrier") and (first["carrier"] as Dictionary).has("said"),
		"the carrier's own account is written down beside the verdict")
	_check(str((first["carrier"] as Dictionary)["said"]) != str(first["outcome"]),
		"and is not the verdict: carrier \"%s\", ledger %s" % [
			str((first["carrier"] as Dictionary)["said"]), str(first["outcome"])])

	_finish()


func _finish() -> void:
	print("")
	for l in lines:
		print(l)
	print("LEDGER TEST failures=%d" % failures.size())
	quit(failures.size())
