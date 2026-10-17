extends SceneTree

# NPC-DELIVERY-001 - the false delivery test.
#
# One scenario shows the feature works. The other five try to make Genesis
# report a success it has not earned: a carrier that claims arrival, a carrier
# that arrives empty-handed, the wrong object in the right room, a route
# sealed after the errand began, and the object moved away before the final
# check.
#
# The acceptance criterion is ZERO false successes. A failed delivery is a
# correct result. A DELIVERED that should not be is a test failure.
#
# Genesis's outcome words map to the brief's: DELIVERED = ACHIEVED,
# NOT_DELIVERED = FAILED, INCONCLUSIVE = INCONCLUSIVE.

var main: Node3D
var lines: Array = []
var failures: Array = []
var false_successes := 0

const ROOMS := "{\"name\": \"entrance\", \"width\": 12, \"depth\": 12}, {\"name\": \"middle\", \"width\": 12, \"depth\": 12}, {\"name\": \"room_3\", \"width\": 12, \"depth\": 12}"
const DOORS := "[1, 2], [2, 3]"


func _check(ok: bool, what: String) -> void:
	lines.append(("PASS  " if ok else "FAIL  ") + what)
	if not ok:
		failures.append(what)


# Every challenge is judged the same way: what did the ledger say, and was it a
# success it had not earned?
func _judge(challenge: String, outcome: String, may_succeed: bool) -> void:
	var cheated := outcome == "DELIVERED" and not may_succeed
	if cheated:
		false_successes += 1
	_check(not cheated, "%-26s outcome %-14s %s" % [
		challenge, outcome,
		"(a success it did not earn)" if cheated else "(no false success)"])


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


func _world(things: String) -> void:
	await _type("{\"command\": \"CREATE_DUNGEON\", \"parameters\": {\"rooms\": [%s], \"doors\": [%s], \"things\": [%s]}}" % [
		ROOMS, DOORS, things])
	if main.npc != null:
		main.npc.queue_free()
		main.npc = null
	await physics_frame


func _order(thing: String, room: String) -> void:
	await _type("{\"command\": \"ORDER\", \"parameters\": {\"goal\": \"carry\", \"thing\": \"%s\", \"room\": \"%s\"}}" % [
		thing, room])


func _settle(limit_seconds := 90) -> void:
	var ticks := 0
	while ticks < Engine.physics_ticks_per_second * limit_seconds and main.npc != null and main.npc.state == Npc.GOING:
		ticks += 1
		await physics_frame


func _node_of(label: String) -> Node3D:
	for entry in (main.controller.standable.get("things", []) as Array):
		var t: Dictionary = entry
		if str(t["name"]) == label:
			return t["node"]
	return null


func _room_of(node: Node3D) -> int:
	var module := DungeonModule.new()
	var holder: Node3D = main.controller.standable["node"]
	var layout: Dictionary = main.controller.standable["layout"]
	var local: Vector3 = holder.to_local(node.global_position)
	return module.room_of(layout, Vector2(local.x, local.z))


func _centre(room: int) -> Vector3:
	var module := DungeonModule.new()
	var holder: Node3D = main.controller.standable["node"]
	var rects: Array = module._rects(main.controller.standable["layout"])
	var r: Rect2 = rects[room]
	return holder.to_global(Vector3(r.position.x + r.size.x * 0.5,
		DungeonModule.ROOM_HEIGHT + 0.45, r.position.y + r.size.y * 0.5))


func _put(node: Node3D, where: Vector3) -> void:
	var holder: Node3D = main.controller.standable["node"]
	if node.get_parent() != holder:
		node.get_parent().remove_child(node)
		holder.add_child(node)
	node.global_position = where
	await physics_frame


func _outcome() -> String:
	return str(main.controller.last_outcome_record.get("outcome", "NONE"))


func _run() -> void:
	_make_main()
	await process_frame

	# The implementation detail the brief asked to settle first: room
	# membership, not raw coordinates. Rooms must not overlap, or "which room
	# is it in" has no single answer.
	await _world("{\"name\": \"red_key\", \"in\": 1}")
	var module := DungeonModule.new()
	var rects: Array = module._rects(main.controller.standable["layout"])
	var overlapping := false
	for i in rects.size():
		for j in range(i + 1, rects.size()):
			if (rects[i] as Rect2).intersects(rects[j] as Rect2):
				overlapping = true
	_check(not overlapping, "rooms do not overlap, so room membership is unambiguous")
	_check(_node_of("red_key") != null and _node_of("blue_key") == null,
		"an object is identified by name, unique within a dungeon")

	# --- 1. normal delivery ---
	await _order("red_key", "room_3")
	await _settle()
	lines.append("  1 the key ended in room %d" % (_room_of(_node_of("red_key")) + 1))
	_judge("1 normal delivery", _outcome(), true)
	_check(_outcome() == "DELIVERED", "   and it really was delivered")

	# --- 2. false arrival claim ---
	# The carrier says it stopped at the destination while the key never left
	# the entrance. Its word must not move the key.
	await _world("{\"name\": \"red_key\", \"in\": 1}")
	await _order("red_key", "room_3")
	await physics_frame
	main.npc.global_position = _centre(2)
	main.npc.halt("stopped walking")
	await physics_frame
	lines.append("  2 carrier stopped in room %d, key in room %d" % [
		_room_of(main.npc) + 1, _room_of(_node_of("red_key")) + 1])
	_judge("2 false arrival claim", _outcome(), false)

	# --- 3. key never picked up ---
	# The carrier walks the whole route and arrives, but the key was taken out
	# of its reach before it got there.
	await _world("{\"name\": \"red_key\", \"in\": 1}")
	await _order("red_key", "room_3")
	await physics_frame
	await _put(_node_of("red_key"), _centre(0) + Vector3(4.0, 0.0, 4.0))
	main.npc.pickup_at = -1
	await _settle()
	lines.append("  3 carrier in room %d, key in room %d" % [
		_room_of(main.npc) + 1, _room_of(_node_of("red_key")) + 1])
	_judge("3 never picked up", _outcome(), false)

	# --- 4. wrong object ---
	# A blue key sits in room 3 from the start. The red key is what was asked
	# for, and it is elsewhere.
	await _world("{\"name\": \"red_key\", \"in\": 1}, {\"name\": \"blue_key\", \"in\": 3}")
	await _order("red_key", "room_3")
	await physics_frame
	main.npc.halt("stopped walking")
	await physics_frame
	lines.append("  4 blue key in room %d, red key in room %d" % [
		_room_of(_node_of("blue_key")) + 1, _room_of(_node_of("red_key")) + 1])
	_judge("4 wrong object", _outcome(), false)

	# --- 5. route sealed after the errand began ---
	# A wall drops across the corridor once the carrier is on its way.
	await _world("{\"name\": \"red_key\", \"in\": 1}")
	await _order("red_key", "room_3")
	await physics_frame
	var holder: Node3D = main.controller.standable["node"]
	var wall := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var slab := BoxShape3D.new()
	slab.size = Vector3(1.0, 6.0, 14.0)
	shape.shape = slab
	wall.add_child(shape)
	holder.add_child(wall)
	var a: Vector3 = _centre(0)
	var b: Vector3 = _centre(1)
	wall.global_position = Vector3((a.x + b.x) * 0.5, DungeonModule.ROOM_HEIGHT + 2.0, (a.z + b.z) * 0.5)
	await _settle(40)
	lines.append("  5 carrier said \"%s\", key in room %d" % [
		main.npc.why, _room_of(_node_of("red_key")) + 1])
	_judge("5 route sealed", _outcome(), false)
	_check(_outcome() == "NOT_DELIVERED",
		"   a key stalled in a corridor is a known failure, not an unknown")
	wall.queue_free()

	# --- 5b. the world genuinely cannot answer ---
	# INCONCLUSIVE has to be reachable, and has to mean what it says: the
	# thing is not in the world at all, so no claim about it can be checked.
	await _world("{\"name\": \"red_key\", \"in\": 1}")
	await _order("red_key", "room_3")
	await physics_frame
	var vanished: Node3D = _node_of("red_key")
	vanished.get_parent().remove_child(vanished)
	vanished.queue_free()
	await physics_frame
	main.npc.halt("stopped walking")
	await physics_frame
	lines.append("  5b the key no longer exists")
	_judge("5b object gone", _outcome(), false)
	_check(_outcome() == "INCONCLUSIVE", "   and that, and only that, is INCONCLUSIVE")

	# --- 5c. wrong destination ---
	# The key is really carried and really set down - in the middle room, not
	# the vault it was sent to. The carrier did everything except the thing it
	# was asked for.
	await _world("{\"name\": \"red_key\", \"in\": 1}")
	await _order("red_key", "room_3")
	var guard := 0
	while guard < Engine.physics_ticks_per_second * 60 and main.npc.state == Npc.GOING:
		guard += 1
		await physics_frame
		if main.npc.load_node != null and _room_of(main.npc) == 1:
			break
	main.npc.drop()
	main.npc.halt("stopped walking")
	await physics_frame
	lines.append("  5c key set down in room %d, asked for room 3" % (_room_of(_node_of("red_key")) + 1))
	_judge("5c wrong destination", _outcome(), false)
	_check(str(main.controller.last_outcome_record.get("thing_in", "")) == "middle",
		"   and the record names where it actually went")

	# --- 6. displaced after delivery ---
	# The errand succeeds, then the key is taken out of room 3 before the
	# ledger looks. The final check must reject it.
	await _world("{\"name\": \"red_key\", \"in\": 1}")
	await _order("red_key", "room_3")
	await _settle()
	_check(_outcome() == "DELIVERED", "   6 the errand itself succeeded first")
	await _put(_node_of("red_key"), _centre(0))
	main.controller.pending_order = {"id": "recheck", "room": 2, "room_name": "room_3", "thing": "red_key"}
	main.controller.finish_order(main.npc.global_position, 1.0, 1.0, "stopped walking")
	lines.append("  6 re-checked with the key in room %d" % (_room_of(_node_of("red_key")) + 1))
	_judge("6 displaced after delivery", _outcome(), false)

	# --- 7. the carrier's attempts are recorded, and are not the verdict ---
	var account: Dictionary = main.controller.last_outcome_record.get("carrier", {})
	var tried: Array = account.get("attempted", [])
	_check(not tried.is_empty(), "the carrier's attempted actions are on the record (%d of them)" % tried.size())
	var words := PackedStringArray()
	for step in tried:
		words.append("%s/%s" % [str((step as Dictionary)["action"]), str((step as Dictionary)["result"])])
	lines.append("  7 attempted: " + ", ".join(words))
	_check(main.controller.last_outcome_record.has("verified"),
		"and the check that was made is written down beside them")

	print("")
	for l in lines:
		print(l)
	print("")
	print("FALSE SUCCESSES: %d   (the acceptance criterion is 0)" % false_successes)
	print("FALSE DELIVERY TEST failures=%d" % failures.size())
	quit(failures.size())
