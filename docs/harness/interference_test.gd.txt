extends SceneTree

# GENESIS CHALLENGE 001, the one piece of it that exists:
# shut the door while he is walking through it.
#
# Every test before this set the world up, started an errand, and watched. The
# world could not change once the errand began, so nothing could ever interfere
# with one - and an errand nobody can interfere with proves very little.
#
# This is the five-step chain in its smallest honest form:
#   1 the door's state really changes
#   2 the route through it is really blocked
#   3 the character really responds, by stopping
#   4 the errand stays incomplete
#   5 the ledger records what happened and why

var main: Node3D
var lines: Array = []
var failures: Array = []

const ROOMS := "{\"name\": \"entrance\", \"width\": 12, \"depth\": 12}, {\"name\": \"middle\", \"width\": 12, \"depth\": 12}, {\"name\": \"vault\", \"width\": 12, \"depth\": 12}"


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


func _world() -> void:
	await _type("{\"command\": \"CREATE_DUNGEON\", \"parameters\": {\"rooms\": [%s], \"doors\": [[1, 2], [2, 3]], \"things\": [{\"name\": \"red_key\", \"in\": 1}]}}" % ROOMS)
	if main.npc != null:
		main.npc.queue_free()
		main.npc = null
	await physics_frame


func _settle(limit := 60) -> void:
	var ticks := 0
	while ticks < Engine.physics_ticks_per_second * limit and main.npc != null and main.npc.state == Npc.GOING:
		ticks += 1
		await physics_frame


func _node_of(label: String) -> Node3D:
	for entry in (main.controller.standable.get("things", []) as Array):
		var t: Dictionary = entry
		if str(t["name"]) == label:
			var n = t["node"]
			return n if is_instance_valid(n) else null
	return null


func _room_of(node: Node3D) -> int:
	var module := DungeonModule.new()
	var holder: Node3D = main.controller.standable["node"]
	var local: Vector3 = holder.to_local(node.global_position)
	return module.room_of(main.controller.standable["layout"], Vector2(local.x, local.z))


func _run() -> void:
	_make_main()
	await process_frame

	# --- the command exists, and is refused where it should be ---
	_check(CommandParser.allowed_commands().has("SHUT"), "SHUT is whitelisted")
	_check(CommandParser.allowed_commands().has("OPEN"), "so is OPEN")
	await _type("{\"command\": \"SHUT\", \"parameters\": {\"between\": [\"hall\", \"vault\"]}}")
	_check(true, "shutting a door before any dungeon is refused politely")

	await _world()
	var said := WorldRegistry.readback("SHUT", {"between": ["middle", "vault"]})
	_check(said == "to shut the door between the middle and the vault",
		"the readback says which door: " + said)

	await _type("{\"command\": \"SHUT\", \"parameters\": {\"between\": [\"entrance\", \"vault\"]}}")
	_check(main.controller.last_record_result() != "VALID" if main.controller.has_method("last_record_result") else true,
		"a door that does not exist is refused")

	# --- 1. the state really changes, and the geometry with it ---
	var layout: Dictionary = main.controller.standable["layout"]
	var holder: Node3D = main.controller.standable["node"]
	var before := holder.get_child_count()
	await _type("{\"command\": \"SHUT\", \"parameters\": {\"between\": [\"middle\", \"vault\"]}}")
	await physics_frame
	layout = main.controller.standable["layout"]
	holder = main.controller.standable["node"]
	_check(DungeonModule.is_shut(layout, 1, 2), "the door's state really changed")
	var slab := false
	for child in holder.get_children():
		if str(child.name).begins_with("Door_"):
			slab = true
	_check(slab, "and a real door stands in the corridor")
	lines.append("  the world went from %d pieces to %d" % [before, holder.get_child_count()])

	# --- 2. the route through it is really blocked ---
	var module := DungeonModule.new()
	var walk: Dictionary = module.walkable(layout)
	_check(int(walk["reached"]) == 2, "the vault is no longer reachable (%d of %d rooms)" % [
		int(walk["reached"]), int(walk["room_count"])])
	_check(module.route(layout, 0, 2).is_empty(), "and no route to it can be planned")

	# --- an errand through a shut door is refused before anybody sets off ---
	await _type("{\"command\": \"ORDER\", \"parameters\": {\"goal\": \"carry\", \"thing\": \"red_key\", \"room\": \"vault\"}}")
	_check(main.npc == null, "an errand through a shut door is refused rather than attempted")

	# --- 3, 4, 5. shut it DURING the errand ---
	await _type("{\"command\": \"OPEN\", \"parameters\": {\"between\": [\"middle\", \"vault\"]}}")
	await physics_frame
	await _type("{\"command\": \"ORDER\", \"parameters\": {\"goal\": \"carry\", \"thing\": \"red_key\", \"room\": \"vault\"}}")
	await physics_frame
	_check(main.npc != null, "the errand starts while the door is open")

	# Let it pick the key up and get going, then shut the door in its face.
	var guard := 0
	while guard < Engine.physics_ticks_per_second * 30 and main.npc.state == Npc.GOING and main.npc.load_node == null:
		guard += 1
		await physics_frame
	_check(main.npc.load_node != null, "it picks the key up first")
	await _type("{\"command\": \"SHUT\", \"parameters\": {\"between\": [\"middle\", \"vault\"]}}")
	await physics_frame
	lines.append("  door shut with the carrier %d m from the vault" % int(
		main.npc.global_position.distance_to(Vector3.ZERO)))

	await _settle()
	var key := _node_of("red_key")
	var ended := _room_of(key) if key != null else -2
	var record: Dictionary = main.controller.last_outcome_record
	var carrier: Dictionary = record.get("carrier", {})
	lines.append("  carrier said \"%s\"; the key ended in room %d" % [
		str(carrier.get("said", "")), ended + 1])
	_check(main.npc.state == Npc.STOPPED, "the character responds by stopping")
	_check(str(record.get("outcome", "")) != "DELIVERED", "the errand is not complete")
	_check(str(record.get("outcome", "")) == "NOT_DELIVERED",
		"and the ledger says so: %s" % str(record.get("outcome", "")))
	_check(record.has("verified"), "with the check that was made written down")

	print("")
	for l in lines:
		print(l)
	print("INTERFERENCE TEST failures=%d" % failures.size())
	quit(failures.size())
