extends SceneTree

# 117 - what an EDIT keeps, and what it drops without a word.
#
# WHY THIS SUITE EXISTS
# LoadCheck.NOT_SAVED names three kinds of state a /load cannot bring back:
# equipment, which doors were shut, and where things had been carried to. It
# says all three, every load, RESTORED included, on the reasoning written at
# load_check.gd:25-31 - a silence there becomes the next half-truth.
#
# 116 drove the EDIT path (a complete world command handed back for a world
# that is already standing) and found the shut state is dropped there too, in
# silence. It then reasoned - and recorded that it was reasoning and not
# measuring - that the same was true of the other two, and wrote down that the
# claim must not be stated anywhere until both were driven.
#
# 117 drove them, and the three-way claim IS NOT TRUE OF THE EDIT PATH:
#
#   a carried thing's position   DROPPED   - back to the room it was built in
#   the equipment                KEPT      - in the kit and on the body
#
# So an edit loses TWO of the three, not three. Had the sentence been written
# from the reading, Genesis would have told players it had lost equipment it
# still had - the same shape as TRAPS 14, where Genesis told players it could
# not save worlds it had been saving for releases.
#
# WHAT THIS ASSERTS, AND WHAT IT DELIBERATELY DOES NOT
# It asserts the two CAPABILITIES above, each read off the world or off the
# body and never off a record. It asserts nothing about any wording: there is
# no sentence at the edit path naming either kind of state today, and whether
# there should be is the owner's call (HANDOVER, "Human decision needed").
# A test that asserted the absence of a sentence would have to be deleted by
# whoever adds it, which is not a guard, it is a tripwire.

var main: Node3D
var lines: Array = []
var failures: Array = []
var asserted := 0

const SMALL := '{"command": "CREATE_DUNGEON", "parameters": {"rooms": [{"name": "entrance", "width": 12, "depth": 12}, {"name": "store", "width": 12, "depth": 12}, {"name": "vault", "width": 12, "depth": 12}], "doors": [[1, 2], [2, 3]], "things": [{"name": "lamp", "in": 2}]}}'

# The same three rooms, larger. The model is told to return the complete
# command for the whole changed world, so this is the shape an edit arrives in.
const BIGGER := '{"command": "CREATE_DUNGEON", "parameters": {"rooms": [{"name": "entrance", "width": 16, "depth": 16}, {"name": "store", "width": 16, "depth": 16}, {"name": "vault", "width": 16, "depth": 16}], "doors": [[1, 2], [2, 3]], "things": [{"name": "lamp", "in": 2}]}}'

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


# An edit, driven the way the live API path drives one: editing_from set from
# the standing world, then _execute_json. _handle_request CLEARS editing_from
# at main.gd:183 before its raw-JSON branch, so a typed command cannot be an
# edit - which player_door_test section 2 asserts, and which is why this goes
# through _execute_json rather than through _type.
func _edit(json_text: String) -> void:
	main.editing_from = main.controller.last_build.duplicate(true)
	main.pending_source = {"source": "ai"}
	main._execute_json(json_text)
	await process_frame
	await process_frame
	await physics_frame


func _run() -> void:
	_make_main()
	await process_frame

	# --- the world, and the thing where it was built ---
	await _type(SMALL)
	_check(main.controller.has_standable(), "the dungeon is standing")
	_check(_thing_room("lamp") == 1, "the lamp starts in the store, where the command put it")
	var built_metrics: Dictionary = (main.controller.last_build.get("metrics", {}) as Dictionary).duplicate(true)

	# --- carry it somewhere else, so there is a position an edit could lose ---
	# Asserted before the edit, so a broken carry fails HERE rather than
	# making the assertion after the edit vacuously true (TRAPS 6).
	await _type('{"command": "ORDER", "parameters": {"goal": "carry", "thing": "lamp", "room": "vault"}}')
	await _settle()
	_check(_thing_room("lamp") == 2,
		"the lamp is in the vault, read off the world: the state an edit could drop now exists")

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

	# --- the edit ---
	await _edit(BIGGER)

	# The edit really happened. Without this, everything below could be read
	# against a world that never changed.
	var after_metrics: Dictionary = main.controller.last_build.get("metrics", {})
	_check(not after_metrics.is_empty() and float(after_metrics.get("floor_area", 0.0)) > float(built_metrics.get("floor_area", 0.0)),
		"the edit rebuilt the world: floor area %.0f -> %.0f m2" % [
			float(built_metrics.get("floor_area", 0.0)), float(after_metrics.get("floor_area", 0.0))])

	# (1) THE CARRIED POSITION IS DROPPED. The lamp is back in the room the
	# command puts it in, not the room it was carried to.
	var where := _thing_room("lamp")
	_check(where == 1,
		"AN EDIT DOES NOT KEEP WHERE A THING WAS CARRIED TO: the lamp is in room %d, built in 1, carried to 2" % where)

	# (2) THE EQUIPMENT IS KEPT. This is the half 116 reasoned was lost and
	# that is measured here to be kept. The kit is the authoritative copy:
	# ToolRegistry.free_kit() is assigned to it exactly once, where the
	# controller is constructed, and _equip is the only other write.
	_check(is_equal_approx(float(main.controller.kit.get("boots", {}).get("push", 0.0)), float(BOOTS["push"])),
		"AN EDIT KEEPS THE EQUIPMENT: the kit still carries the equipped spec")

	# The standing body is NOT re-equipped by a build, so this says only that
	# the edit does not strip the body it left standing. On its own it is a
	# weak guard and says so: with the kit wiped it still passes, because the
	# body holds the spec it was last handed. Measured, by wiping the kit in a
	# throwaway copy - see HANDOVER's 117 entry, injection 2.
	_check(main.walker != null and is_equal_approx(main.walker.push, float(BOOTS["push"])),
		"and the edit does not strip the standing body: push is %s N" % [
			(str(main.walker.push) if main.walker != null else "no walker")])

	# THE ONE THAT IS THE PLAYER'S QUESTION. _start_exploring re-equips from
	# the kit every time (main.gd:761-762), so leaving and stepping back in
	# after an edit is what a wiped kit would be felt through. This is the
	# assertion that fails if anything ever resets the kit on a build.
	await _type("/view")
	await _type("/explore")
	_check(main.exploring and main.walker != null and is_equal_approx(main.walker.push, float(BOOTS["push"])),
		"and stepping back in on foot after the edit still gives the equipped boots: push is %s N, not the free kit's %.0f" % [
			(str(main.walker.push) if main.walker != null else "no walker"), BootsTool.DEFAULT_PUSH])

	print("")
	for l in lines:
		print(l)
	print("EDIT STATE %d assertions, failures=%d" % [asserted, failures.size()])
	quit(failures.size())
