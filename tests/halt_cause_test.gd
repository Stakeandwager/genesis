extends SceneTree

# 121 - what the body knows at the moment it stops, and whether a failed
# errand COULD name what stopped it.
#
# WHY THIS SUITE EXISTS
# 120's second live entry measured an errand that fails with a sentence a
# player can do nothing with: "Could not get to the vault: stopped making
# progress after 5 m." True, and useless - what stopped it was the player's
# own invisible body, and nothing in the record said so. `carrier.attempted`
# was empty and the `verified` block reports the destination and the room
# found, not the obstacle. That entry named one thing as NOT MEASURED:
#
#   "whether the record COULD name the obstacle. halt() is called with
#    'stopped making progress' by npc.gd:227 on a no-progress timer, and what
#    the body knows at that moment has not been read - a move_and_slide()
#    collider is available in principle and that is an inference, not a
#    reading."
#
# This is the reading. It is YES, and it is better than "a collider": the
# collider's owning piece carries a descriptive name, so the obstacle can be
# named rather than merely detected.
#
# WHAT IT DOES NOT ASSERT, AND THE REASON IS THE POINT
# Nothing about what a player SHOULD be told, and nothing about what the
# outcome record SHOULD hold. Whether a failed errand should name what
# stopped it is the owner's, and it is open in HANDOVER. A suite that
# asserted either of today's answers would have to be deleted by whoever
# answers it, which is a tripwire and not a guard. What is asserted here is
# only that the INFORMATION IS IN HAND at the moment halt() fires - which is
# true whichever way that question goes, and is what any answer to it would
# have to stand on.
#
# WHY THE SHUT DOOR AND NOT THE LEFTOVER BODY
# The leftover player body is the obstacle in 120's live entry, and it is
# measured there with its numbers. It is deliberately NOT the fixture here:
# whether a body the player stepped out of stays in the world at all is one
# of the owner's open questions, so a suite built on that body stalling an
# errand would stop being reachable the moment he answers one way. A door
# shut in a carrier's face is permanent, intended behaviour - it is GENESIS
# CHALLENGE 001 and `interference_test` already asserts that it stops the
# carrier - so it cannot be invalidated by any of the three pending answers.
# The reading is the body's own and does not know what kind of thing it is
# pressed against, which is why one fixture settles it; the second obstacle
# class is in HANDOVER as a measurement rather than here as a row.
#
# WHY EVERY ROW HAS A CONTROL IN FRONT OF IT (TRAPS 6)
# A suite that read "1 collision, on_wall true" at a stall and asserted it
# would pass on a body that is pressed against something for the whole walk,
# and a suite that read it only at the stall could not tell that from a body
# that always reports one. So the same two calls are read THREE times in the
# same errand: in the open mid-walk, at a stall, and at an arrival. The first
# and the third must read nothing, or the second reads nothing either.
#
# AND THE SOURCE SCAN IS COMMENT-STRIPPED, BECAUSE THE HARNESS SAID SO
# The last section reads `scripts/npc.gd` and `scripts/walker.gd` to assert
# the call ordering that makes the rows above mean what they say. The first
# draft read them raw, and `source_scan_test` failed it on this project's own
# standing rule: a file in tests/ that scans source defines `_code_of()` and
# searches the comment-stripped text, so a comment can never answer a
# question about what the code does (TRAPS 63). It was right - npc.gd's own
# comments discuss `_steer`. The helper below is that rule, and the scan rows
# have a can-it-fail row saying the read was not empty.
#
# AND THE READING IS ONE FRAME OLD, WHICH IS WRITTEN DOWN RATHER THAN HIDDEN
# `Npc._physics_process` calls `_steer(delta)` and THEN
# `super._physics_process(delta)`, which is where `move_and_slide()` is. So
# inside the `stopped_walking` handler the slide collisions are the PREVIOUS
# frame's. For this halt reason that is harmless - the body has been pressed
# against the thing for STALL_SECONDS by then, and the rows below read
# velocity exactly zero - but it is the reason this suite reads at the signal
# rather than at any later moment, and the reason the ordering is asserted.

var main: Node3D
var lines: Array = []
var failures: Array = []
var asserted := 0

const ROOMS := '{"name": "entrance", "width": 12, "depth": 12}, {"name": "middle", "width": 12, "depth": 12}, {"name": "vault", "width": 12, "depth": 12}'
const DUNGEON := '{"command": "CREATE_DUNGEON", "parameters": {"rooms": [%s], "doors": [[1, 2], [2, 3]]}}'
const ORDER := '{"command": "ORDER", "parameters": {"goal": "go_to", "room": "vault"}}'
const SHUT := '{"command": "SHUT", "parameters": {"between": ["middle", "vault"]}}'

# Which rooms the door that gets shut joins, 0-based, and the room the errand
# is sent to. Named once so the derived node name below has one source.
const SHUT_A := 1
const SHUT_B := 2
const VAULT := 2

var at_stall := {}
var at_arrival := {}
var mid_walk := {}


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


func _drop_main() -> void:
	main.get_parent().remove_child(main)
	main.queue_free()
	main = null
	for i in 10:
		await process_frame


func _type(text: String) -> void:
	main._handle_request(text)
	await process_frame
	await process_frame


# Everything the body can say about what it is touching, read off the body
# itself. One function, used at all three moments, so the three readings
# cannot differ in what they looked at.
func _reading(npc: Node3D) -> Dictionary:
	var rows: Array = []
	var n: int = npc.get_slide_collision_count()
	for i in n:
		var c = npc.get_slide_collision(i)
		var col = c.get_collider()
		var owner_name := ""
		var owner_class := ""
		if col != null and col.get_parent() != null:
			owner_name = str(col.get_parent().name)
			owner_class = col.get_parent().get_class()
		rows.append({
			"collider": ("" if col == null else str(col.name)),
			"class": ("" if col == null else col.get_class()),
			"path": ("" if col == null else str(col.get_path())),
			"owner": owner_name,
			"owner_class": owner_class,
			"normal": c.get_normal(),
		})
	return {
		"count": n, "rows": rows,
		"on_wall": npc.is_on_wall(),
		"speed": Vector2(npc.velocity.x, npc.velocity.z).length(),
	}


# The name the dungeon gives the slab it builds for a shut door, derived from
# the module's own rule (`_door_slab` is called with "%d_%d" on the door's
# 0-based pair, plus one) rather than written out here, so a change to that
# rule fails this suite instead of silently passing it.
func _door_node_name(a: int, b: int) -> String:
	return "Door_%d_%d" % [a + 1, b + 1]


# A file's source with its comments removed, so a question about what the code
# DOES is answered from the code and never from prose (TRAPS 63). Required of
# every file in tests/ that scans this project's source: source_scan_test
# enumerates them and failed this suite's first draft, which read npc.gd raw.
static func _code_of(source: String) -> String:
	var out := ""
	for raw in source.split("\n"):
		var line := str(raw)
		if line.strip_edges().begins_with("#"):
			out += "\n"
			continue
		var hash_at := line.find("#")
		out += (line if hash_at < 0 else line.substr(0, hash_at)) + "\n"
	return out


func _source(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	return _code_of(file.get_as_text())


func _on_stopped(why: String, _at: Vector3, _seconds: float, _travelled: float) -> void:
	var r := _reading(main.npc)
	r["why"] = why
	if why == "stopped making progress":
		at_stall = r
	elif why == "stopped walking":
		at_arrival = r


func _settle() -> void:
	var guard := 0
	while guard < Engine.physics_ticks_per_second * 95 and main.npc != null \
			and main.npc.state == Npc.GOING:
		guard += 1
		await physics_frame
	for i in 20:
		await physics_frame


func _flat(holder: Node3D, where: Vector3) -> Vector2:
	var local := holder.to_local(where)
	return Vector2(local.x, local.z)


# --- the errand that arrives: the control for both readings below ---
func _arrival_section() -> void:
	_make_main()
	await process_frame
	await _type(DUNGEON % ROOMS)
	await _type(ORDER)
	_check(main.npc != null, "an errand to the vault starts")
	main.npc.stopped_walking.connect(_on_stopped)

	# In the open, halfway through the walk. This is the row that stops a
	# stall's "1" from being a body that is always touching something.
	var guard := 0
	while guard < Engine.physics_ticks_per_second * 6 and main.npc.state == Npc.GOING:
		guard += 1
		await physics_frame
	if main.npc.state == Npc.GOING:
		mid_walk = _reading(main.npc)
		_check(int(mid_walk["count"]) == 0 and not bool(mid_walk["on_wall"]),
			"THE CONTROL: mid-walk in the open the body touches nothing - count=%d on_wall=%s" % [
				int(mid_walk["count"]), mid_walk["on_wall"]])
		_check(float(mid_walk["speed"]) > 0.1,
			"and it is actually walking at the time - %.2f m/s" % float(mid_walk["speed"]))
	else:
		_check(false, "the errand was still walking 6 s in (it was not; nothing read mid-walk)")

	await _settle()
	_check(not at_arrival.is_empty(), "the errand ends with \"stopped walking\"")
	if not at_arrival.is_empty():
		_check(int(at_arrival["count"]) == 0 and not bool(at_arrival["on_wall"]),
			"THE SECOND CONTROL: at an ARRIVAL the body touches nothing - count=%d on_wall=%s" % [
				int(at_arrival["count"]), at_arrival["on_wall"]])
	await _drop_main()


# --- the errand that stalls, on a Main of its own ---
func _stall_section() -> void:
	at_stall = {}
	_make_main()
	await process_frame
	await _type(DUNGEON % ROOMS)
	var module := DungeonModule.new()
	var layout: Dictionary = main.controller.standable["layout"]
	var holder: Node3D = main.controller.standable["node"]
	await _type(ORDER)
	_check(main.npc != null, "the errand starts while the door is open")
	main.npc.stopped_walking.connect(_on_stopped)

	# Let it get out of the entrance, then shut the door ahead of it - the
	# same interference interference_test drives.
	var guard := 0
	while guard < Engine.physics_ticks_per_second * 20 and main.npc.state == Npc.GOING \
			and module.room_of(layout, _flat(holder, main.npc.global_position)) != SHUT_A:
		guard += 1
		await physics_frame
	_check(module.room_of(layout, _flat(holder, main.npc.global_position)) == SHUT_A,
		"the carrier is in the middle room when the door is shut")
	await _type(SHUT)
	_check(DungeonModule.is_shut(main.controller.standable["layout"], SHUT_A, SHUT_B),
		"the door's state really changed")
	await _settle()

	_check(not at_stall.is_empty(),
		"the errand ends on the no-progress timer, not on arrival or the 90 s cap")
	if at_stall.is_empty():
		await _drop_main()
		return

	_check(int(at_stall["count"]) >= 1,
		"AND THE BODY KNOWS IT IS PRESSED AGAINST SOMETHING: get_slide_collision_count()=%d" % int(at_stall["count"]))
	_check(bool(at_stall["on_wall"]), "is_on_wall() is true at the halt")
	_check(float(at_stall["speed"]) < 0.01,
		"and it had stopped dead first - %.4f m/s, so the one-frame-old reading is of the thing it is still against" % float(at_stall["speed"]))

	var rows: Array = at_stall["rows"]
	var wanted := _door_node_name(SHUT_A, SHUT_B)
	var named := false
	for r in rows:
		lines.append("  touching %s (%s) under %s (%s)" % [
			r["collider"], r["class"], r["owner"], r["owner_class"]])
		if str(r["owner"]) == wanted:
			named = true
	_check(named,
		"AND IT CAN BE NAMED: the collider's owning piece is \"%s\" - the door that was shut, derived from the module's own naming rule" % wanted)

	# The collider itself is the generic solid; the name is one get_parent()
	# away. Asserted because a fix that read get_collider().name alone would
	# report "Solid" to a player and that is no better than silence.
	var generic := true
	for r in rows:
		if str(r["collider"]) != "Solid":
			generic = false
	_check(generic,
		"and the collider itself is the generic \"Solid\" every dungeon piece carries, so the name is the PARENT's and not the collider's")
	await _drop_main()


# --- why the reading is one frame old, read off the source ---
# Not a style check. If a later change moves `_steer` after the parent call,
# the handler would read THIS frame's collisions, which at a stall is the
# frame in which the body is already being stopped - and the rows above would
# go on passing while meaning something different. So the ordering that makes
# them mean what the header says is asserted.
func _ordering_section() -> void:
	var src := _source("res://scripts/npc.gd")
	_check(src != "", "scripts/npc.gd was read")
	var steer := src.find("_steer(delta)")
	var parent := src.find("super._physics_process(delta)")
	_check(steer >= 0 and parent >= 0,
		"Npc._physics_process calls both _steer and the parent")
	_check(steer >= 0 and parent >= 0 and steer < parent,
		"and _steer comes FIRST, which is why the halt-time reading is the previous frame's move_and_slide()")
	var walker := _source("res://scripts/walker.gd")
	_check(walker.contains("move_and_slide()"),
		"and the move that produces those collisions is Walker's own move_and_slide()")
	_check(walker.strip_edges().begins_with("extends CharacterBody3D"),
		"which it has because the body is a CharacterBody3D - the reading is the body's, not the dungeon's")
	# The can-it-fail row for the two searches above. Both are `find` on a
	# comment-stripped file, so a row that passed on a file the scan never
	# reached would be the fault TRAPS 6 is about: an empty string contains
	# neither of them and would pass the ordering comparison trivially.
	_check(src.length() > 1000 and walker.length() > 1000,
		"and the scan reached real code rather than an empty read - npc.gd %d chars, walker.gd %d chars after comments are stripped" % [
			src.length(), walker.length()])


func _run() -> void:
	await _arrival_section()
	await _stall_section()
	_ordering_section()
	print("")
	for l in lines:
		print(l)
	print("HALT CAUSE %d assertions, failures=%d" % [asserted, failures.size()])
	quit(failures.size())
