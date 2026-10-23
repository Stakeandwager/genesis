extends SceneTree

# 014 - the first command Genesis accepts without knowing how it ends.
#
# Everything before this finished inside the frame that accepted it: a world
# was built or refused, a tool equipped or refused. An order is answered
# later, by a body that has to walk there, so the record is written PENDING
# and a second record resolves it - the same arrangement the understanding
# layer uses, where a later record judges an earlier one and never edits it.
#
# What matters most here is the thing that is NOT tested, because it cannot
# happen: there is no path by which the character reports its own arrival. It
# says where it stopped; the module that owns the geometry says whether that
# is the room it was sent to. These tests check that the decision is made from
# the position, including the case where the character stops in the wrong room
# and the record says so.

var main: Node3D
var lines: Array = []
var failures: Array = []
var asserted := 0

const CHAIN := "{\"command\": \"CREATE_DUNGEON\", \"parameters\": {\"rooms\": [{\"name\": \"entrance\", \"width\": 10, \"depth\": 10}, {\"name\": \"middle\", \"width\": 10, \"depth\": 10}, {\"name\": \"vault\", \"width\": 10, \"depth\": 10}], \"doors\": [[1, 2], [2, 3]]}}"
const FARM := "{\"command\": \"CREATE_FARM\", \"parameters\": {\"zones\": [{\"type\": \"barn\", \"width\": 20, \"depth\": 20}]}}"


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


func _order(room) -> void:
	var value := "\"%s\"" % str(room) if typeof(room) == TYPE_STRING else str(room)
	await _type("{\"command\": \"ORDER\", \"parameters\": {\"goal\": \"go_to\", \"room\": %s}}" % value)


func _run() -> void:
	_make_main()
	await process_frame

	# --- the whitelist ---
	_check(CommandParser.allowed_commands().has("ORDER"), "ORDER is whitelisted")
	_check(NpcGoals.prompt_section().contains("ORDER go_to"),
		"there is a prompt section describing orders")

	# --- a goal nobody can be given ---
	var rooms: Array = [{"name": "entrance"}, {"name": "vault"}]
	var invented: Dictionary = NpcGoals.validate({"goal": "attack", "room": "vault"}, rooms)
	_check(not bool(invented["ok"]), "an invented goal is refused")
	var nowhere: Dictionary = NpcGoals.validate({"goal": "go_to", "room": "kitchen"}, rooms)
	_check(not bool(nowhere["ok"]) and str(nowhere["errors"][0]).contains("entrance"),
		"a room this dungeon has not got is refused, naming the ones it has")
	var by_number: Dictionary = NpcGoals.validate({"goal": "go_to", "room": 2}, rooms)
	_check(bool(by_number["ok"]) and int(by_number["goal"]["room"]) == 1,
		"a room may be named or numbered")

	# --- nobody to order about ---
	await _order("vault")
	_check(main.npc == null, "an order before any dungeon is refused")
	await _type(FARM)
	await _order("vault")
	_check(main.npc == null, "and so is an order in a farm")

	# --- a real order ---
	await _type(CHAIN)
	_check(main.controller.has_standable(), "the dungeon reports somewhere to stand")
	var readback := WorldRegistry.readback("ORDER", {"goal": "go_to", "room": "vault"})
	_check(readback == "to send someone to the vault", "the readback says what was asked: " + readback)

	await _order("vault")
	_check(main.npc != null, "a character appears")
	_check(not main.controller.pending_order.is_empty(), "and the order is recorded as pending")

	# Let it walk. The chain is three 10 m rooms, so this is two corridors.
	var ticks := 0
	while ticks < Engine.physics_ticks_per_second * 60 and main.npc.state == Npc.GOING:
		ticks += 1
		await physics_frame
	var seconds := float(ticks) / float(Engine.physics_ticks_per_second)

	_check(main.npc.state == Npc.STOPPED, "the character stops walking (%.1f s, %.1f m)" % [
		seconds, main.npc.travelled])
	_check(main.controller.pending_order.is_empty(), "and the order is resolved rather than left pending")

	# --- arrival is decided from the geometry, not from the character ---
	var module := DungeonModule.new()
	var holder: Node3D = main.controller.standable["node"]
	var layout: Dictionary = main.controller.standable["layout"]
	var local: Vector3 = holder.to_local(main.npc.global_position)
	var where := module.room_of(layout, Vector2(local.x, local.z))
	lines.append("  stopped in room %d of %d, %.1f m travelled in %.1f s" % [
		where + 1, (layout["rooms"] as Array).size(), main.npc.travelled, seconds])
	_check(where == 2, "it is standing in the vault, measured from where it is")

	# The character itself never says it arrived.
	_check(not ("arrived" in main.npc.why.to_lower()),
		"the character's own account does not claim arrival: \"%s\"" % main.npc.why)

	# --- a second order replaces the first ---
	await _order(1)
	_check(main.npc.state == Npc.GOING, "a new order starts at once")
	_check(int(main.controller.pending_order["room"]) == 0, "and replaces the one before it")
	ticks = 0
	while ticks < Engine.physics_ticks_per_second * 60 and main.npc.state == Npc.GOING:
		ticks += 1
		await physics_frame
	local = holder.to_local(main.npc.global_position)
	_check(module.room_of(layout, Vector2(local.x, local.z)) == 0, "and it walks back to the entrance")

	print("")
	for l in lines:
		print(l)
	print("ORDER TEST %d assertions, failures=%d" % [asserted, failures.size()])
	quit(failures.size())
