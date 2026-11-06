extends SceneTree

# 119 - which doors were shut, across a /save and a /load.
#
# WHY THIS SUITE EXISTS
# LoadCheck.NOT_SAVED names three kinds of state a load cannot bring back:
# equipment, which doors were shut, and where things had been carried to. 117
# and 118 drove two of the three and found the list was WRONG about one of
# them - the equipment is kept - which is why each member gets driven on its
# own rather than trusted as a list (TRAPS 115).
#
# The third member was the one cell of TRAPS 115's table that was still a
# reading rather than a measurement. Driven here, through the real scene, and
# for this one the sentence is TRUE:
#
#   which doors were shut        DROPPED   - and the loss is felt, not listed
#
# WHY IT IS ITS OWN FILE AND NOT A SECTION OF load_state_test
# MEASURED, and it is the reason this file exists at all. The character Main
# builds for an ORDER is parented to MAIN, not to the world, so it survives
# every rebuild - and _clear_world_node() sets npc_at back to Vector3.INF,
# which makes _order() plan the next errand from room 0 by default
# (game_controller.gd:262-267). So after a rebuild the controller plans from
# the entrance while the body stands where it last stopped. Driven in the same
# three rooms: an errand to the vault from the entrance walks 34.9 m and
# ARRIVES; the identical errand after an identical rebuild, with the body
# already standing in the vault, walks 85.8 m to arrive at the room it was
# already in. Running these rows inside load_state_test made that suite's
# carry row go red, because the two sections were measuring each other's
# leftover body. A separate file is a separate process and a fresh Main.
# That finding is NOT asserted here - it has its own live entry in HANDOVER
# and a decision attached to it that is not this suite's to make.
#
# WHAT IT ASSERTS, AND WHY THE LAST ROW STOPS WHERE IT DOES
# The door is read two ways at each step: off DungeonModule.route(), which is
# the function the controller actually asks and which reads is_shut() through
# walkable()'s usable_doors, and off an errand driven through the scene. What
# the errand rows assert is ACCEPTED versus REFUSED, which only the route can
# decide. They do NOT assert that the errand arrives after the load: by then
# the body is standing in the destination room for the reason above, so an
# ARRIVED there would pass whether the door came back open or not. A row that
# can pass for the wrong reason is worse than no row (TRAPS 6).
#
# WHAT IT DOES NOT MEASURE
# Only the dungeon, because only a dungeon has doors to shut. Only one shut
# door on one layout. Nothing about what the player should be TOLD: the clause
# of the caveat this suite is about turns out to be true, so no wording needed
# changing and none is asserted.

var main: Node3D
var lines: Array = []
var failures: Array = []
var asserted := 0

# Its own file, removed at the end whatever happens (TRAPS 7). The name
# deliberately CONTAINS the word "shut": the row below that sweeps the saved
# world for it excludes the player-chosen name, and this is what makes that
# exclusion fail loudly if anyone ever widens the sweep back over it.
const SAVED_AS := "load-shut-test-tmp"

# Three rooms in a line, and NO THINGS IN THEM. A thing placed "in" a room
# stands where the corridor runs and a thing is solid, so an errand past it is
# BLOCKED with every door open - measured, and it is why the first probe for
# this question could not tell a shut door from a lamp (TRAPS 117).
const DUNGEON := '{"command": "CREATE_DUNGEON", "parameters": {"rooms": [{"name": "entrance", "width": 12, "depth": 12}, {"name": "store", "width": 12, "depth": 12}, {"name": "vault", "width": 12, "depth": 12}], "doors": [[1, 2], [2, 3]]}}'

# The layout numbers rooms from 0, and validate_door resolves a request's room
# NAMES through the same list, so this pair is store-vault and there is no
# off-by-one here. 116 established that reading.
const STORE := 1
const VAULT := 2


func _check(ok: bool, what: String) -> void:
	asserted += 1
	lines.append(("PASS  " if ok else "FAIL  ") + what)
	if not ok:
		failures.append(what)


func _initialize() -> void:
	_run.call_deferred()


# The scene the game launches, resolved through ProjectSettings rather than by
# path, so this suite cannot end up holding a scene that is not the game's.
func _make_main() -> void:
	main = load(str(ProjectSettings.get_setting("application/run/main_scene"))).instantiate()
	get_root().add_child(main)


func _type(text: String) -> void:
	main._handle_request(text)
	await process_frame
	await process_frame


# Is there a way through, as the function the CONTROLLER asks has it?
# route() reads its doors from walkable()["usable_doors"], which is where
# is_shut() is consulted - so this is the same reading _order() makes and not
# a second opinion about the layout.
func _way_through() -> bool:
	var module := DungeonModule.new()
	var layout: Dictionary = main.controller.standable["layout"]
	return not module.route(layout, 0, VAULT).is_empty()


# The errand's two records, each read so that it cannot be about a different
# errand.
#
# NOT main.controller.last_order_record: that field is assigned only on the
# VALID path (game_controller.gd:358), so after a REFUSED order it still holds
# the previous order's record and reads back VALID. The first probe for this
# suite read it and got a stale VALID for an order that had just been refused
# FAILED_UNWALKABLE, so it could not tell the two apart at all. The ORDER's
# own record is taken off track_measured, which _finish_failed and the valid
# path both emit.
#
# THE OUTCOME IS A SECOND RECORD AND IS NOT ON THAT SIGNAL. finish_order()
# assigns last_outcome_record and appends it to the ledger and emits nothing
# (game_controller.gd:446-447) - read, not assumed. So it is taken off the
# field and guarded by its own "about": a refused order never reaches
# finish_order, so without that guard an absent outcome would read as the
# PREVIOUS errand's ARRIVED. 033 is the entry about an id that points at the
# wrong record.
#
# AND THE WAIT IS ON pending_order, NOT ON npc.state. pending_order is set
# synchronously when an order is accepted - carry_test:117 asserts exactly
# that - and cleared by finish_order, so this returns at once for an order
# that was refused and waits out the walk for one that was not. An errand
# here took 1699 physics ticks.
func _order_to_vault() -> Dictionary:
	var orders: Array = []
	var listener := func(record: Dictionary) -> void:
		if str(record.get("command", "")) == "ORDER":
			orders.append(record.duplicate(true))
	main.controller.track_measured.connect(listener)
	await _type('{"command": "ORDER", "parameters": {"goal": "go_to", "room": "vault"}}')
	var ticks := 0
	while ticks < Engine.physics_ticks_per_second * 180 and not main.controller.pending_order.is_empty():
		ticks += 1
		await physics_frame
	main.controller.track_measured.disconnect(listener)

	var out := {"result": "", "category": "", "outcome": "", "records": orders.size()}
	if orders.size() == 1:
		var rec: Dictionary = orders[0]
		out["result"] = str(rec.get("result", ""))
		out["category"] = str(rec.get("category", ""))
		var resolved: Dictionary = main.controller.last_outcome_record
		if str(resolved.get("about", "")) == str(rec.get("id", "")):
			out["outcome"] = str(resolved.get("outcome", ""))
	return out


# Every key of the saved world EXCEPT the one the player names it, swept for
# the word. Not a hand-written list of the keys save_world() writes: a seventh
# key added later is swept by this without anybody remembering to add it
# (TRAPS 114). "name" is excluded because the player chooses it and it can
# contain any word at all - including this suite's own.
func _keys_mentioning_shut(world: Dictionary, skip: Array) -> Array:
	var out: Array = []
	for key in world.keys():
		if skip.has(str(key)):
			continue
		if JSON.stringify(world[key]).to_lower().contains("shut"):
			out.append(str(key))
	return out


func _finish() -> void:
	WorldStore.remove_world(SAVED_AS)
	_check(not WorldStore.list_worlds().has(SAVED_AS),
		"the suite's own save file is cleaned up after it")
	print("")
	for l in lines:
		print(l)
	print("LOAD SHUT %d assertions, failures=%d" % [asserted, failures.size()])
	quit(failures.size())


func _run() -> void:
	WorldStore.remove_world(SAVED_AS)
	_make_main()
	await process_frame

	# --- the world, and a way through it ---
	await _type(DUNGEON)
	_check(main.controller.has_standable(), "a dungeon with no things in it is standing")
	_check(not main.controller.standable["layout"].has("shut"),
		"nothing is shut in a freshly built dungeon: the layout has no 'shut' key")
	_check(_way_through(), "and there is a way through to the vault, as route() has it")

	# THE BASELINE ERRAND. Without it the refusal below could be the corridor,
	# the route, the wait or the body, and nothing here could tell (TRAPS 6).
	# This is the FIRST errand, so the character is placed at the entrance when
	# it is created and the walk is a real one.
	var open_doors := await _order_to_vault()
	_check(int(open_doors["records"]) == 1 and str(open_doors["result"]) == "VALID"
			and str(open_doors["outcome"]) == "ARRIVED",
		"with every door open the character walks to the vault: %d record, %s/%s" % [
			int(open_doors["records"]), str(open_doors["result"]), str(open_doors["outcome"])])

	# --- shut it, and the loss of the way through is felt ---
	# Built again first, so the measurement is of the door and not of a world
	# somebody has been walking around in.
	await _type(DUNGEON)
	await _type('{"command": "SHUT", "parameters": {"between": ["store", "vault"]}}')
	var shut_layout: Dictionary = main.controller.standable["layout"]
	_check(DungeonModule.is_shut(shut_layout, STORE, VAULT),
		"the SHUT is in the standing layout: shut=%s" % str(shut_layout.get("shut", [])))
	_check(not _way_through(),
		"and route() has no way through to the vault any more")

	var door_shut := await _order_to_vault()
	_check(int(door_shut["records"]) == 1 and str(door_shut["result"]) == "FAILED"
			and str(door_shut["category"]) == "FAILED_UNWALKABLE",
		"and the shut door is FELT: the same errand is refused %s/%s" % [
			str(door_shut["result"]), str(door_shut["category"])])

	# Nothing walked, so there is no outcome record about it. This row is also
	# what shows the "about" guard in _order_to_vault() is doing work: without
	# it an absent outcome would read as the previous errand's ARRIVED.
	_check(str(door_shut["outcome"]) == "",
		"and nothing walked: the refused errand has no outcome record of its own (got '%s')" %
			str(door_shut["outcome"]))

	# --- what the FILE holds, which is the true half of the claim ---
	# /save stores last_build's parameters and metrics, and a SHUT never writes
	# last_build - _set_door() appends its own record and emits door_changed,
	# and rebuild_standing_world() does not touch last_build either (read, not
	# assumed). So there is nowhere in the file for the shut state to go.
	await _type("/save " + SAVED_AS)
	var on_disk: Dictionary = WorldStore.load_world(SAVED_AS)
	_check(bool(on_disk.get("ok", false)), "the shut world saved to its own file")
	if not bool(on_disk.get("ok", false)):
		_finish()
		return
	var world: Dictionary = on_disk.get("world", {})
	_check(_keys_mentioning_shut(world, ["name"]).is_empty(),
		"and NO field of the saved world carries the shut state: %s" % [
			str(_keys_mentioning_shut(world, ["name"]))])
	# And the exclusion is not decorative: the one key left out is the one that
	# does contain the word, because this suite named its own file that way.
	_check(str(world.get("name", "")).to_lower().contains("shut"),
		"and the excluded key is the player-chosen name, which here does contain the word")

	# --- across the load ---
	await _type("/load " + SAVED_AS)
	_check(str(main.controller.last_build.get("command", "")).to_upper() == "CREATE_DUNGEON"
			and main.controller.has_standable(),
		"the /load rebuilt the dungeon and it is standing")

	var loaded: Dictionary = main.controller.standable["layout"]
	_check(not DungeonModule.is_shut(loaded, STORE, VAULT),
		"A /load DOES NOT KEEP WHICH DOORS WERE SHUT: is_shut is false on the loaded layout")
	_check(_way_through(),
		"and the way through to the vault is back, as route() has it")

	# AND IT IS FELT: the errand that was refused a moment ago is accepted.
	# ACCEPTED is the whole assertion here. Whether it then ARRIVES is not
	# asserted and must not be: the body is standing in the vault already, for
	# the reason in this file's header, so an arrival would pass whether the
	# door came back open or not.
	var after_load := await _order_to_vault()
	_check(int(after_load["records"]) == 1 and str(after_load["result"]) == "VALID"
			and str(after_load["category"]) == "",
		"and the loss is FELT: the errand refused before the /save is accepted after the /load: %s/%s" % [
			str(after_load["result"]), str(after_load["category"])])

	_finish()
