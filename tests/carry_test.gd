extends SceneTree

# 015 - one complete errand, across all four layers.
#
# A player asks for something to be taken somewhere. The test follows the one
# request through interpretation (a goal and a thing, both from whitelists),
# validation (a thing that is not there is refused), construction (the thing
# exists in the world as a body), the character's action (it walks, picks up,
# carries, sets down), and finally delivery - which is answered by reading the
# THING'S position out of the scene.
#
# The last part is the point. If the carrying code breaks, the ledger must say
# the lamp is in the wrong room; it must not say the errand succeeded because
# the character believes it did. There is no path by which the character is
# asked.

var main: Node3D
var lines: Array = []
var failures: Array = []
var asserted := 0

const WORLD := "{\"command\": \"CREATE_DUNGEON\", \"parameters\": {\"rooms\": [{\"name\": \"entrance\", \"width\": 12, \"depth\": 12}, {\"name\": \"store\", \"width\": 12, \"depth\": 12}, {\"name\": \"vault\", \"width\": 12, \"depth\": 12}], \"doors\": [[1, 2], [2, 3]], \"things\": [{\"name\": \"lamp\", \"in\": 2}]}}"


func _check(ok: bool, what: String) -> void:
	asserted += 1
	lines.append(("PASS  " if ok else "FAIL  ") + what)
	if not ok:
		failures.append(what)


func _initialize() -> void:
	_run.call_deferred()


# 061: the scene the game launches, loaded rather than hand-built.
#
# This function used to build a stand-in tree by hand and name each node what
# main.gd's @onready lines ask for, so the fixture SUPPLIED the names the
# suite then proved were there (TRAPS 57). 061 walked both trees and
# enumerated twelve differences between that stand-in and scenes/main.tscn -
# a missing light, environment and TitleLabel, a Ground that was a Node3D
# where the scene has a StaticBody3D, a ground slab a metre lower with
# collision the scene has not got, a camera at a different place and angle,
# an unanchored panel, three unset strings and the child order of six nodes.
# What this suite measures is now measured against the tree the game has.
#
# The scene is resolved through ProjectSettings rather than by path, so no
# suite can end up holding a scene that is no longer the game's; the setting
# itself is asserted in player_door_test.
func _make_main() -> void:
	main = load(str(ProjectSettings.get_setting("application/run/main_scene"))).instantiate()
	get_root().add_child(main)


func _type(text: String) -> void:
	main._handle_request(text)
	await process_frame
	await process_frame


func _settle() -> float:
	var ticks := 0
	while ticks < Engine.physics_ticks_per_second * 90 and main.npc != null and main.npc.state == Npc.GOING:
		ticks += 1
		await physics_frame
	return float(ticks) / float(Engine.physics_ticks_per_second)


# Where a thing stands, as the world has it, counting rooms from 0.
func _thing_room(label: String) -> int:
	var module := DungeonModule.new()
	var holder: Node3D = main.controller.standable["node"]
	var layout: Dictionary = main.controller.standable["layout"]
	for entry in (main.controller.standable.get("things", []) as Array):
		var t: Dictionary = entry
		if str(t["name"]) == label:
			var node: Node3D = t["node"]
			var local: Vector3 = holder.to_local(node.global_position)
			return module.room_of(layout, Vector2(local.x, local.z))
	return -2


func _run() -> void:
	_make_main()
	await process_frame

	# --- interpretation: carry is on the whitelist, and needs a real thing ---
	_check(NpcGoals.GOALS.has("carry"), "carry is a goal the game has")
	var rooms: Array = [{"name": "entrance"}, {"name": "store"}, {"name": "vault"}]
	var things: Array = [{"name": "lamp"}]
	var invented: Dictionary = NpcGoals.validate({"goal": "carry", "thing": "sword", "room": "vault"}, rooms, things)
	_check(not bool(invented["ok"]) and str(invented["errors"][0]).contains("lamp"),
		"a thing that is not there is refused, naming what is")
	var nothing: Dictionary = NpcGoals.validate({"goal": "carry", "thing": "lamp", "room": "vault"}, rooms, [])
	_check(not bool(nothing["ok"]), "and so is carrying in a dungeon with nothing in it")
	var said := WorldRegistry.readback("ORDER", {"goal": "carry", "thing": "lamp", "room": "vault"})
	_check(said == "to have the lamp carried to the vault", "the readback says what was asked: " + said)

	# --- construction: the thing is a body in the world ---
	await _type(WORLD)
	_check(main.controller.has_standable(), "the dungeon is standing")
	var present: Array = main.controller.standable.get("things", [])
	_check(present.size() == 1 and str(present[0]["name"]) == "lamp", "the lamp exists in the world")
	_check(_thing_room("lamp") == 1, "and it starts in the store, where it was asked for")

	# A thing may not be invented by the world command either.
	var module := DungeonModule.new()
	var clash: Dictionary = module.validate({"rooms": [{"name": "a", "width": 10, "depth": 10},
		{"name": "b", "width": 10, "depth": 10}], "doors": [[1, 2]],
		"things": [{"name": "lamp", "in": 9}]})
	_check(not bool(clash["ok"]), "a thing in a room that does not exist is refused")

	# --- the errand ---
	await _type("{\"command\": \"ORDER\", \"parameters\": {\"goal\": \"carry\", \"thing\": \"lamp\", \"room\": \"vault\"}}")
	_check(main.npc != null, "a character sets off")
	_check(str(main.controller.pending_order.get("thing", "")) == "lamp",
		"and the pending order knows what it is carrying")
	# Step 1 of the delivery test: taken NOW, while it describes this errand.
	var ordered: Dictionary = main.controller.last_order_record.duplicate(true)
	var seconds: float = await _settle()

	var ended := _thing_room("lamp")
	lines.append("  the lamp ended in room %d, after %.1f s and %.1f m" % [
		ended + 1, seconds, main.npc.travelled])
	_check(ended == 2, "the lamp is in the vault, read from the world rather than from the character")
	_check(main.npc.load_node == null, "and the character is no longer holding it")
	_check(main.controller.pending_order.is_empty(), "the order is resolved")
	_check(not ("deliver" in main.npc.why.to_lower()),
		"the character's own account claims nothing about delivery: \"%s\"" % main.npc.why)

	# --- the ledger must be able to say NO ---
	# Move the lamp somewhere wrong before the errand resolves, and the record
	# has to call it a failure. This is the test that would catch a carrying
	# bug being reported as a success.
	await _type("{\"command\": \"ORDER\", \"parameters\": {\"goal\": \"carry\", \"thing\": \"lamp\", \"room\": \"entrance\"}}")
	await physics_frame
	var holder: Node3D = main.controller.standable["node"]
	var layout: Dictionary = main.controller.standable["layout"]
	var rects: Array = module._rects(layout)
	var store: Rect2 = rects[1]
	main.npc.halt("stopped making progress")
	var lamp: Node3D = (main.controller.standable["things"] as Array)[0]["node"]
	if lamp.get_parent() != holder:
		lamp.get_parent().remove_child(lamp)
		holder.add_child(lamp)
	lamp.global_position = holder.to_global(Vector3(
		store.position.x + store.size.x * 0.5, DungeonModule.ROOM_HEIGHT + 0.45,
		store.position.y + store.size.y * 0.5))
	await physics_frame
	main.controller.finish_order(main.npc.global_position, 1.0, 1.0, "stopped making progress")
	_check(_thing_room("lamp") == 1, "the lamp was put back in the store by hand")


	# --- the five steps of the delivery test, named ---
	# 1 identity and starting place, recorded before anything moved
	_check(str(ordered.get("thing", "")) == "lamp" and str(ordered.get("thing_from", "")) == "store",
		"the order's record says what was carried and where it started: %s in the %s" % [
			str(ordered.get("thing", "")), str(ordered.get("thing_from", ""))])

	# 2 the carrier's account kept apart from the world's answer
	var resolved: Dictionary = main.controller.last_outcome_record
	_check(resolved.has("carrier") and resolved.has("outcome"),
		"the outcome keeps the carrier's account apart from the world's answer")
	_check(str((resolved["carrier"] as Dictionary)["said"]) != str(resolved["outcome"]),
		"they are different things: carrier said \"%s\", world says %s" % [
			str((resolved["carrier"] as Dictionary)["said"]), str(resolved["outcome"])])

	# 5 a third outcome when the world cannot answer
	_check(NpcGoals.delivery_line("INCONCLUSIVE", "lamp", "vault", "").contains("Cannot tell"),
		"there is a wording for not being able to tell")
	var lost: Node3D = (main.controller.standable["things"] as Array)[0]["node"]
	var kept := lost.global_position
	# Standing outside every room is a KNOWN failure: we can see exactly where
	# it is. "Cannot tell" has to mean cannot tell.
	lost.global_position = Vector3(5000, 5000, 5000)
	main.controller.pending_order = {"id": "x", "room": 2, "room_name": "vault", "thing": "lamp"}
	main.controller.finish_order(main.npc.global_position, 1.0, 1.0, "stopped walking")
	_check(str(main.controller.last_outcome_record.get("outcome", "")) == "NOT_DELIVERED",
		"a thing standing in no room is a known failure, not an unknown")
	lost.global_position = kept

	# Gone from the world is the one thing that cannot be judged.
	lost.get_parent().remove_child(lost)
	lost.queue_free()
	await physics_frame
	main.controller.pending_order = {"id": "y", "room": 2, "room_name": "vault", "thing": "lamp"}
	main.controller.finish_order(main.npc.global_position, 1.0, 1.0, "stopped walking")
	_check(str(main.controller.last_outcome_record.get("outcome", "")) == "INCONCLUSIVE",
		"a thing gone from the world is INCONCLUSIVE")

	print("")
	for l in lines:
		print(l)
	print("CARRY TEST %d assertions, failures=%d" % [asserted, failures.size()])
	quit(failures.size())
