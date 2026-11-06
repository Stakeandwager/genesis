extends SceneTree

# 118 - what a /load keeps, and what it drops without a word.
#
# WHY THIS SUITE EXISTS
# LoadCheck.NOT_SAVED names three kinds of state a load cannot bring back:
# equipment, which doors were shut, and where things had been carried to. The
# caveat built from it is said on EVERY outcome, RESTORED included, on the
# reasoning written at load_check.gd:25-31.
#
# 117 asked whether that list is a measurement of /load and found that for one
# of its three items it is not. Driven again here, through the real scene:
#
#   a carried thing's position   DROPPED   - back to the room it was built in
#   the equipment                KEPT      - in the kit, and on the body
#
# So the player is told "none of equipment ... came back" while the boots they
# equipped are still on their feet. That is the same shape as TRAPS 14, where
# Genesis told players it could not save worlds it had been saving for
# releases, and it is why this suite exists at all: the sentence was held in
# place by a test that asserted the sentence CONTAINS the word "equipment",
# which is green because the sentence is said and not because anything it
# claims is true.
#
# WHY THE EQUIPMENT SURVIVES, AND IT IS STRUCTURAL RATHER THAN LUCKY
# ToolRegistry.free_kit() is assigned to `kit` exactly once, where the
# GameController is constructed (game_controller.gd:100), and _equip() is the
# only other write to it in all of scripts/. A /load does not construct a
# controller - it calls controller.execute() on the saved description, the
# same door an edit comes through - so no load can reset the kit.
#
# WHAT THIS ASSERTS, AND WHAT IT DELIBERATELY DOES NOT
# It asserts the two capabilities above, each read off the world or off the
# body and never off a record or off a sentence. It asserts NO WORDING. Which
# way the player-facing caveat should be reworded is the owner's call and is
# open in HANDOVER under "Human decision needed": a test that pinned today's
# sentence would have to be deleted by whoever answers that question, which is
# a tripwire and not a guard.
#
# WHAT IT DOES NOT MEASURE
# The third member, which doors were shut, is not driven here. 116 drove it
# across the EDIT path and found it lost, and 119 drove it across /load and
# found it lost there too - in tests/load_shut_test.gd, which is its own file
# and not a section of this one on purpose: a character parented to Main
# survives every rebuild, so two questions sharing one Main measure each
# other's leftover body. See that suite's header and TRAPS 117.

var main: Node3D
var lines: Array = []
var failures: Array = []
var asserted := 0

# Its own file, removed at the end whatever happens (TRAPS 7).
const SAVED_AS := "load-state-test-tmp"

const DUNGEON := '{"command": "CREATE_DUNGEON", "parameters": {"rooms": [{"name": "entrance", "width": 12, "depth": 12}, {"name": "store", "width": 12, "depth": 12}, {"name": "vault", "width": 12, "depth": 12}], "doors": [[1, 2], [2, 3]], "things": [{"name": "lamp", "in": 2}]}}'

# Inside every BootsTool bound, and far enough from the free kit's 240 N that
# a kept spec cannot be confused with a reset one.
const BOOTS := {"push": 400.0, "weight": 70.0, "footing": 0.9, "turning": 30.0, "brake": 600.0}


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


func _settle() -> void:
	var ticks := 0
	while ticks < Engine.physics_ticks_per_second * 90 and main.npc != null and main.npc.state == Npc.GOING:
		ticks += 1
		await physics_frame


# Where a thing stands, as THE WORLD has it, counting rooms from 0. Never the
# carrier's account and never the order's record: the same rule carry_test
# answers delivery by.
func _thing_room(label: String) -> int:
	var module := DungeonModule.new()
	var holder: Node3D = main.controller.standable["node"]
	var layout: Dictionary = main.controller.standable["layout"]
	for entry in (main.controller.standable.get("things", []) as Array):
		var t: Dictionary = entry
		if str(t["name"]) == label:
			var node = t.get("node", null)
			if not is_instance_valid(node):
				return -3
			var local: Vector3 = holder.to_local((node as Node3D).global_position)
			return module.room_of(layout, Vector2(local.x, local.z))
	return -2


func _finish() -> void:
	WorldStore.remove_world(SAVED_AS)
	_check(not WorldStore.list_worlds().has(SAVED_AS),
		"the suite's own save file is cleaned up after it")
	print("")
	for l in lines:
		print(l)
	print("LOAD STATE %d assertions, failures=%d" % [asserted, failures.size()])
	quit(failures.size())


func _run() -> void:
	WorldStore.remove_world(SAVED_AS)
	_make_main()
	await process_frame

	# --- the world, and the thing where it was built ---
	await _type(DUNGEON)
	_check(main.controller.has_standable(), "the dungeon is standing")
	_check(_thing_room("lamp") == 1, "the lamp starts in the store, where the command put it")

	# --- carry it somewhere else, so there is a position a load could lose ---
	# Asserted BEFORE the save, so a broken carry fails here rather than
	# making the assertion after the load vacuously true (TRAPS 6).
	await _type('{"command": "ORDER", "parameters": {"goal": "carry", "thing": "lamp", "room": "vault"}}')
	await _settle()
	_check(_thing_room("lamp") == 2,
		"the lamp is in the vault, read off the world: the state a load could drop now exists")

	# --- on foot, so the equipment is read at the body and not only in the kit ---
	await _type("/explore")
	_check(main.exploring, "/explore puts the player in the world on foot")
	_check(main.walker != null and is_equal_approx(main.walker.push, BootsTool.DEFAULT_PUSH),
		"and the free kit's boots are on the body, so a change is a change (push %s)" %
			(str(main.walker.push) if main.walker != null else "no walker"))

	await _type('{"command": "EQUIP", "parameters": {"tool": "boots", "spec": %s}}' % JSON.stringify(BOOTS))
	_check(is_equal_approx(float(main.controller.kit.get("boots", {}).get("push", 0.0)), float(BOOTS["push"])),
		"the EQUIP is in the kit")
	_check(is_equal_approx(main.walker.push, float(BOOTS["push"])),
		"and it reached the body: push is %.0f N" % main.walker.push)

	# --- save, then load, through the commands a player types ---
	await _type("/save " + SAVED_AS)
	var on_disk: Dictionary = WorldStore.load_world(SAVED_AS)
	_check(bool(on_disk.get("ok", false)), "the world saved to its own file")
	if not bool(on_disk.get("ok", false)):
		_finish()
		return

	# What the file actually holds, read off disk. This is the claim that is
	# TRUE - the save format carries no equipment - and it is the reason the
	# player-facing sentence is worth rewording rather than simply deleting.
	var world: Dictionary = on_disk.get("world", {})
	_check(not (world.keys() as Array).has("equipment") and not (world.keys() as Array).has("kit"),
		"and the FILE carries no equipment of its own, which is the true half of the claim")

	var built_metrics: Dictionary = (main.controller.last_build.get("metrics", {}) as Dictionary).duplicate(true)
	await _type("/load " + SAVED_AS)

	# The load really happened. Without this, everything below could be read
	# against the world that was already standing.
	var after: Dictionary = main.controller.last_build
	_check(str(after.get("command", "")).to_upper() == "CREATE_DUNGEON" and not (after.get("metrics", {}) as Dictionary).is_empty(),
		"the /load rebuilt a dungeon and measured it")
	_check(main.controller.has_standable(), "and the loaded world is standing")

	# (1) THE CARRIED POSITION IS DROPPED. The lamp is back in the room the
	# saved description puts it in, not the room it was carried to.
	var where := _thing_room("lamp")
	_check(where == 1,
		"A /load DOES NOT KEEP WHERE A THING WAS CARRIED TO: the lamp is in room %d, built in 1, carried to 2" % where)

	# (2) THE EQUIPMENT IS KEPT, AND THIS IS THE ASSERTION THE FALSE SENTENCE
	# WAS STANDING ON. The kit is the authoritative copy: free_kit() is
	# assigned to it exactly once, where the controller is constructed, and
	# _equip is the only other write in all of scripts/.
	_check(is_equal_approx(float(main.controller.kit.get("boots", {}).get("push", 0.0)), float(BOOTS["push"])),
		"A /load KEEPS THE EQUIPMENT: the kit still carries the equipped spec, %.0f N against the free kit's %.0f" % [
			float(main.controller.kit.get("boots", {}).get("push", 0.0)), BootsTool.DEFAULT_PUSH])

	# The standing body is NOT re-equipped by a build, so this says only that
	# the load does not strip the body it left standing. On its own it is a
	# weak guard and says so: with the kit wiped it still passes, because the
	# body holds the spec it was last handed. The row below is the one that
	# catches a wiped kit.
	_check(main.walker != null and is_equal_approx(main.walker.push, float(BOOTS["push"])),
		"and the load does not strip the standing body: push is %s N (weak - see the comment)" % [
			(str(main.walker.push) if main.walker != null else "no walker")])

	# THE ONE THAT IS THE PLAYER'S QUESTION. _start_exploring re-equips from
	# the kit every time (main.gd:761-762), so leaving and stepping back in
	# after the load is what a wiped kit would be felt through. This is the
	# assertion that fails if anything ever resets the kit on a load.
	await _type("/view")
	await _type("/explore")
	_check(main.exploring and main.walker != null and is_equal_approx(main.walker.push, float(BOOTS["push"])),
		"and stepping back in on foot after the /load still gives the equipped boots: push is %s N, not the free kit's %.0f" % [
			(str(main.walker.push) if main.walker != null else "no walker"), BootsTool.DEFAULT_PUSH])

	_finish()
