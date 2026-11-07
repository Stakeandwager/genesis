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
# 122 - AND THE SAME QUESTION ASKED OF THE OTHER HALT REASONS, BECAUSE ONE
# MEMBER OF A CLASS IS NOT THE CLASS (TRAPS 11)
# 121 read the body at ONE halt reason and left three. `halt()` is called with
# "stopped walking" (npc.gd:216, the arrival), "gave up" (npc.gd:183, the
# 90 s cap) and "stopped making progress" (npc.gd:227, the stall), and
# `stopped_walking` is emitted a FOURTH time with "nowhere to go"
# (npc.gd:107) without going through `halt()` at all. 121 read the stall and
# used the arrival as its control. The two it did not read are the two below,
# and the answer at the cap is the OPPOSITE of the answer at the stall:
#
#   at the stall  count 1, on_wall true,  speed 0.0000  -> an obstacle, named
#   at the cap    count 0, on_wall false, speed 4.4776  -> nothing to name
#
# THE BODY IS TOUCHING NOTHING AT THE CAP BECAUSE THERE IS NOTHING TO TOUCH.
# A body that stops making progress is halted by the stall timer after
# STALL_SECONDS, so the only errand that can still be going at MAX_SECONDS is
# one that was still closing on its waypoint - and the one that reaches the cap
# is walking at full speed, 394 m into a 598 m route. So a fix that named the
# collider would leave this halt reason exactly as silent as it is now, and
# this halt reason is REACHABLE: the fixture below is a legal CREATE_DUNGEON.
# What the body does know at the cap is how far along how long a route it got,
# which is a different fact in a different place, and the rows below assert
# that those numbers are in hand. WHAT A PLAYER SHOULD BE TOLD IS STILL NOT
# ASSERTED ANYWHERE - that is "Human decision needed" 38 and it is the
# owner's; this suite only widens what any answer to it would stand on.
#
# AND "nowhere to go" IS A GUARD NO ORDER CAN REACH, WHICH IS LABELLED AS ONE
# TRAPS 6: a check no legal input can fail is worth keeping and worth
# labelling, and is not a measurement. The guard works when driven directly -
# the rows below drive it - but no ORDER reaches it, and the last section
# asserts each leg of that rather than asserting it in prose, so the day one of
# the legs moves this suite says so.
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
var at_cap := {}
var at_nowhere := {}

# 133: the clock section's scale, its band and where it takes its mid-walk
# reading. The reasoning for every one of them is in that section's header;
# none of them is an expected number of seconds.
const CLOCK_SCALE := 0.5
const CLOCK_FLOOR := 0.5
const CLOCK_CEILING := 1.5
const CLOCK_MID_FRAMES := 240

var said: Array = []


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


func _on_stopped(why: String, _at: Vector3, seconds: float, travelled: float) -> void:
	var r := _reading(main.npc)
	r["why"] = why
	r["seconds"] = seconds
	r["travelled"] = travelled
	r["mark"] = main.npc.mark
	r["marks"] = main.npc.marks.size()
	r["attempts"] = main.npc.attempts.size()
	if why == "stopped making progress":
		at_stall = r
	elif why == "stopped walking":
		at_arrival = r
	elif why == "gave up":
		at_cap = r
	elif why == "nowhere to go":
		at_nowhere = r


# 133: what the player was told. Connected only for the clock section, and
# only the last line is read there.
func _on_said(text: String) -> void:
	said.append(text)


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


# --- 122: the 90 s cap, on the longest errand the module allows ---
# The fixture is derived from `DungeonModule.MAX_ROOMS` rather than written
# out, so the day somebody changes that constant this suite says whether the
# cap is still reachable instead of quietly timing out. It is a legal
# CREATE_DUNGEON: a chain of the largest allowed number of rooms, each 20 m,
# joined one to the next, with the errand sent to the far end.
func _cap_section() -> void:
	at_cap = {}
	_make_main()
	await process_frame
	var rooms: Array = []
	var doors: Array = []
	for i in DungeonModule.MAX_ROOMS:
		rooms.append('{"name": "r%d", "width": 20, "depth": 20}' % i)
		if i > 0:
			doors.append("[%d, %d]" % [i, i + 1])
	await _type('{"command": "CREATE_DUNGEON", "parameters": {"rooms": [%s], "doors": [%s]}}' % [
		", ".join(rooms), ", ".join(doors)])
	var far := DungeonModule.MAX_ROOMS - 1
	await _type('{"command": "ORDER", "parameters": {"goal": "go_to", "room": "r%d"}}' % far)
	_check(main.npc != null, "an errand to the far end of the longest legal chain starts")
	if main.npc == null:
		await _drop_main()
		return
	main.npc.stopped_walking.connect(_on_stopped)

	# The route, measured off the module rather than assumed, so the rows below
	# can say the errand ran out of TIME and not out of route.
	var module := DungeonModule.new()
	var layout: Dictionary = main.controller.standable["layout"]
	var path: Array = module.route(layout, 0, far)
	var route_length := 0.0
	for i in range(1, path.size()):
		route_length += (path[i] as Vector2).distance_to(path[i - 1] as Vector2)
	_check(path.size() > 100 and route_length > 100.0,
		"and the route really is the long one - %d marks, %.0f m (the fixture is derived from MAX_ROOMS=%d, not written out)" % [
			path.size(), route_length, DungeonModule.MAX_ROOMS])

	await _settle()
	_check(not at_cap.is_empty(),
		"THE CAP IS REACHABLE BY A LEGAL REQUEST: the errand ends on \"gave up\", not on arrival and not on the stall timer")
	if at_cap.is_empty():
		await _drop_main()
		return

	# The reading, at the moment halt() emits - the same function that read 1
	# at the stall, in the same suite run.
	_check(int(at_cap["count"]) == 0 and not bool(at_cap["on_wall"]),
		"AND THE BODY IS TOUCHING NOTHING AT THE CAP: get_slide_collision_count()=%d on_wall=%s - the OPPOSITE of the stall, so a collider does not name THIS failure. Says nothing about every body that could ever reach the cap: one that slid along a wall while still closing on its waypoint is not driven anywhere and is in HANDOVER as NOT VERIFIED" % [
			int(at_cap["count"]), at_cap["on_wall"]])
	# THE ROW THAT MAKES THE 0 MEAN SOMETHING (TRAPS 6). The same `_reading()`
	# read 1 at the stall earlier in this same run, so an empty reading here
	# cannot be a reader that never reads anything.
	_check(not at_stall.is_empty() and int(at_stall["count"]) >= 1 and int(at_cap["count"]) == 0,
		"AND THE SAME READER READ %d AT THE STALL EARLIER IN THIS RUN - so the 0 at the cap is the world and not a broken reading" % (
			int(at_stall["count"]) if not at_stall.is_empty() else -1))
	_check(float(at_cap["speed"]) > 1.0,
		"AND IT IS STILL WALKING AT THE TIME - %.4f m/s, which is what makes the 0 above \"no obstacle\" and not \"stopped and resting against nothing\"" % float(at_cap["speed"]))
	_check(int(at_cap["mark"]) < int(at_cap["marks"]),
		"and it is a FAILURE and not an arrival - it stopped at waypoint %d of %d" % [
			int(at_cap["mark"]), int(at_cap["marks"])])
	_check(float(at_cap["seconds"]) >= NpcGoals.MAX_SECONDS,
		"and what halted it is the cap itself - %.1f s against NpcGoals.MAX_SECONDS=%.1f, read from the constant that enforces it" % [
			float(at_cap["seconds"]), NpcGoals.MAX_SECONDS])
	_check(float(at_cap["travelled"]) > 0.0 and float(at_cap["travelled"]) < route_length,
		"AND THE NUMBERS THAT DO NAME IT ARE IN HAND: %.0f m travelled of a %.0f m route - it ran out of time, not out of route" % [
			float(at_cap["travelled"]), route_length])
	_check(int(at_cap["attempts"]) == 0,
		"and a plain go_to has nothing in `attempts` at the cap either - %d entries" % int(at_cap["attempts"]))
	await _drop_main()


# --- 122: the fourth reason, and it never goes through halt() ---
# `follow([])` emits `stopped_walking` directly at npc.gd:107. Driven here
# because a guard that is never reached is still a guard, and the next section
# is what says no ORDER reaches it.
func _nowhere_section() -> void:
	at_nowhere = {}
	_make_main()
	await process_frame
	await _type(DUNGEON % ROOMS)
	await _type(ORDER)
	_check(main.npc != null, "a character exists to be given an empty route")
	if main.npc == null:
		await _drop_main()
		return
	main.npc.halt("stopped walking")
	for i in 20:
		await physics_frame
	main.npc.stopped_walking.connect(_on_stopped)
	main.npc.follow([])
	for i in 10:
		await physics_frame
	_check(not at_nowhere.is_empty(),
		"an empty route stops with \"nowhere to go\" - the fourth reason, and the only one that does not go through halt()")
	if at_nowhere.is_empty():
		await _drop_main()
		return
	_check(main.npc.state == Npc.STOPPED, "and the body is left STOPPED rather than walking")
	_check(int(at_nowhere["count"]) == 0 and not bool(at_nowhere["on_wall"]),
		"and there is nothing to name here either - count=%d on_wall=%s" % [
			int(at_nowhere["count"]), at_nowhere["on_wall"]])
	_check(float(at_nowhere["speed"]) < 0.01 and float(at_nowhere["travelled"]) == 0.0,
		"and correctly so: nothing was attempted - %.4f m/s, %.1f m travelled, %d waypoints" % [
			float(at_nowhere["speed"]), float(at_nowhere["travelled"]), int(at_nowhere["marks"])])
	await _drop_main()


# --- 122: and no ORDER reaches it, asserted by its legs ---
# LABELLED AS A GUARD AND NOT A MEASUREMENT (TRAPS 6). Every row here passes
# today and no legal input can fail it; what it is for is the day one of the
# legs moves. The legs: NpcGoals.validate refuses any room that does not
# resolve into range, so `goal["room"]` is always a real index; `from_room`
# starts at 0 and only moves to a `room_of` result that is >= 0, so it is in
# range too; DungeonModule.route with both indices in range and EQUAL returns
# the room's own centre rather than nothing; with them unequal and the route
# empty the controller refuses FAILED_UNWALKABLE before `ordered.emit`; and
# the list validate counts is the same array route indexes.
func _unreachable_section() -> void:
	_make_main()
	await process_frame
	await _type(DUNGEON % ROOMS)
	var module := DungeonModule.new()
	var layout: Dictionary = main.controller.standable["layout"]
	var layout_rooms: Array = layout["rooms"]
	var standable_rooms: Array = main.controller.standable["rooms"]
	_check(standable_rooms.size() == layout_rooms.size() and standable_rooms.size() > 0,
		"GUARD: the room list NpcGoals.validate counts is the one route() indexes - %d and %d" % [
			standable_rooms.size(), layout_rooms.size()])

	# Every room, not the one that happens to be first (TRAPS 11).
	var same_room_empty := 0
	for i in layout_rooms.size():
		if (module.route(layout, i, i) as Array).is_empty():
			same_room_empty += 1
	_check(same_room_empty == 0,
		"GUARD: route(i, i) returns the room's own centre for all %d rooms, so a same-room errand is never an empty route - %d empty" % [
			layout_rooms.size(), same_room_empty])

	var bad: Dictionary = NpcGoals.validate({"goal": "go_to", "room": "no_such_room"}, standable_rooms)
	_check(not bool(bad["ok"]),
		"GUARD: validate refuses a room that does not exist, so goal[\"room\"] is never out of range")
	var good: Dictionary = NpcGoals.validate({"goal": "go_to", "room": "vault"}, standable_rooms)
	_check(bool(good["ok"]) and int((good["goal"] as Dictionary)["room"]) >= 0 \
			and int((good["goal"] as Dictionary)["room"]) < layout_rooms.size(),
		"GUARD: and it resolves a real name into range - room %d of %d" % [
			int((good["goal"] as Dictionary)["room"]) if bool(good["ok"]) else -1, layout_rooms.size()])

	# And the one that is a reading rather than a guard: a same-room ORDER is
	# the nearest thing a player can type to an empty route, and it arrives.
	await _type('{"command": "ORDER", "parameters": {"goal": "go_to", "room": "entrance"}}')
	_check(main.npc != null and main.npc.marks.size() == 1,
		"a same-room ORDER - the nearest a player gets to an empty route - is given ONE waypoint, the room's centre")
	# READ OFF `npc.why` AND NOT OFF THE SIGNAL, AND THAT IS THE POINT. The
	# first draft of this row connected `stopped_walking` after sending the
	# order and asserted the handler had not fired. `follow()` emits "nowhere
	# to go" synchronously, INSIDE the order, before any handler written here
	# could be attached - so the row passed because nothing could ever have
	# set it, which is TRAPS 6 in a row written to guard against TRAPS 6.
	# Caught by injection D: route(i, i) made empty, which really does send
	# this errand down the empty-route path, and the row went on passing.
	# `why` is set by `follow()` and survives, so it can be read afterwards.
	if main.npc != null:
		_check(str(main.npc.why) != "nowhere to go",
			"and it does NOT go down the empty-route path - npc.why is \"%s\" immediately after the order" % str(main.npc.why))
		await _settle()
		_check(str(main.npc.why) == "stopped walking",
			"and it walks to that waypoint and arrives - npc.why is \"%s\" at the end" % str(main.npc.why))

	# Read off the source, comment-stripped (TRAPS 63): the emit that is not
	# halt()'s lives in follow(), which is why halt()'s bookkeeping is skipped
	# on that path.
	var src := _source("res://scripts/npc.gd")
	var in_follow := src.find("func follow(")
	var in_put_down := src.find("func _put_down(")
	var emit_at := src.find("stopped_walking.emit")
	_check(in_follow >= 0 and in_put_down > in_follow and emit_at > in_follow and emit_at < in_put_down,
		"GUARD: and the first stopped_walking.emit in npc.gd is inside follow() and not inside halt(), which is why halt()'s own bookkeeping is skipped on that path")
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


# --- 133: the seconds an errand reports are the SIMULATION's seconds ---
#
# WHY THIS SECTION EXISTS, AND WHY IT IS IN THIS SUITE. `Npc.elapsed` is the
# last of the three durations Genesis reports about its own world, and the
# only row that had ever read it is the cap row in `_cap_section` above -
# which holds that the number reaches `NpcGoals.MAX_SECONDS` and NOT that it
# is the simulation's clock. 128 found the lap clock was the WALL's from 002B
# to 127 and changed it, and `checkpoint_tracker.gd:82`-`89` names the other
# two - `RaceDirector._clock` and this one - as the ones that were already
# right. "Already right" was a READ of `npc.gd:178` and nothing held it, which
# is the same shape as the claim 128 found false.
#
# WHAT IS ASSERTED IS THE NUMBER A PLAYER MEETS, NOT THE FIELD (TRAPS 14).
# `elapsed` goes out through `stopped_walking` (`npc.gd:168`),
# `GameController.finish_order` snaps it to a tenth and writes it into the
# ledger record as `"seconds"` (`game_controller.gd:443`), and
# `NpcGoals.outcome_line` puts it in the sentence - *"Got to the vault. 34 m
# in 6 seconds."* (`npc_goals.gd:380`). So the verdict below is taken from the
# ledger record and from the sentence the player reads. One row reads the
# field itself, mid-walk, and it is labelled as that.
#
# HOW THE TWO CLOCKS ARE SEPARATED WITHOUT SLEEPING, AND IN EITHER
# CONFIGURATION (TRAPS 4). `Engine.time_scale` scales the delta the engine
# hands out and does not touch the wall. At CLOCK_SCALE the SIMULATED span of
# the errand is what it always was, while the WALL span is 1 / CLOCK_SCALE
# times it with no `--fixed-fps` and a fraction of it WITH `--fixed-fps`,
# where frames run as fast as the machine computes them rather than in real
# time. Both are outside the band, in opposite directions, which is why one
# scale covers both ways the runner is used. The scale is set BEFORE the ORDER
# that starts the errand, so every frame it is timed over is a scaled frame.
#
# NOTHING HERE IS TYPED IN AS AN EXPECTED NUMBER OF SECONDS. The band is a
# ratio against the span THIS SUITE stepped - frames this suite counted itself
# multiplied by `Engine.physics_ticks_per_second` and the scale it set - so
# the two sides of every comparison have different sources. Change the
# fixture, the rooms or the tick rate and the rows still hold; put a wall
# clock back in `npc.gd` and they fail.
#
# FRAMES ARE COUNTED ONLY WHILE THE BODY IS `GOING`, and that is not
# bookkeeping. `elapsed += delta` is in `_steer` (`npc.gd:178`), and
# `_physics_process` calls `_steer` only in that state (`npc.gd:171`-`173`),
# so a frame spent WAITING or STOPPED adds nothing and must not be counted
# against it.
func _clock_section() -> void:
	# `_on_stopped` files by halt reason, so an arrival here lands in the same
	# dict `_arrival_section` used. Its rows have already run; this clears it
	# so nothing below can read that errand's answer as this one's.
	at_arrival = {}
	said = []
	_make_main()
	await process_frame
	await _type(DUNGEON % ROOMS)

	var tick := 1.0 / float(Engine.physics_ticks_per_second)
	Engine.time_scale = CLOCK_SCALE
	await _type(ORDER)
	_check(main.npc != null,
		"an errand to the vault starts with the engine's time scale at %.2f" % CLOCK_SCALE)
	if main.npc == null:
		Engine.time_scale = 1.0
		await _drop_main()
		return
	main.npc.stopped_walking.connect(_on_stopped)
	main.controller.log_message.connect(_on_said)

	var frames := 0
	var mid_elapsed := -1.0
	var wall_at_start := Time.get_ticks_msec()
	# Derived from the cap the errand would halt at, not chosen: an errand
	# that gives up does so at MAX_SECONDS of SIMULATED time, which is that
	# many frames at this scale.
	var guard := int(ceil(NpcGoals.MAX_SECONDS / (tick * CLOCK_SCALE))) + 1200
	while frames < guard and main.npc != null and main.npc.state == Npc.GOING:
		await physics_frame
		frames += 1
		if frames == CLOCK_MID_FRAMES:
			mid_elapsed = main.npc.elapsed
	var wall_span := float(Time.get_ticks_msec() - wall_at_start) / 1000.0
	var mid_span := float(CLOCK_MID_FRAMES) * tick * CLOCK_SCALE
	var sim_span := float(frames) * tick * CLOCK_SCALE
	for i in 20:
		await physics_frame
	Engine.time_scale = 1.0

	_check(str(at_arrival.get("why", "")) == "stopped walking",
		"and it ends the way an arrival ends, so the duration below is a whole errand's and not a cap's - \"%s\"" % str(at_arrival.get("why", "")))
	_check(frames > CLOCK_MID_FRAMES and mid_elapsed >= 0.0,
		"and it walked for longer than the %d frames the mid-walk reading is taken at - %d frames of GOING in all" % [
			CLOCK_MID_FRAMES, frames])

	# THE FIELD, read while the clock is still running, against a span this
	# suite chose rather than one the errand chose.
	_check(mid_elapsed > mid_span * CLOCK_FLOOR and mid_elapsed < mid_span * CLOCK_CEILING,
		"THE FIELD: %d frames into the walk Npc.elapsed reads the SIMULATED span and not the wall's - %.4f s against %.4f s simulated, band %.4f to %.4f" % [
			CLOCK_MID_FRAMES, mid_elapsed, mid_span, mid_span * CLOCK_FLOOR, mid_span * CLOCK_CEILING])

	# THE NUMBER A PLAYER MEETS. The ledger's own record, and only this
	# errand's: a record left over from an earlier one reads as a pass, which
	# is the guard `errand_outcome_test` wrote for the same reason.
	var rec: Dictionary = main.controller.last_outcome_record
	var order: Dictionary = main.controller.last_order_record
	var mine := not rec.is_empty() and not order.is_empty() \
		and str(rec.get("about", "")) == str(order.get("id", ""))
	_check(mine,
		"and THIS errand wrote the outcome record the row below reads - about \"%s\" against order id \"%s\"" % [
			str(rec.get("about", "")), str(order.get("id", ""))])
	if not mine:
		main.controller.log_message.disconnect(_on_said)
		await _drop_main()
		return

	var reported := float(rec.get("seconds", -1.0))
	_check(reported > sim_span * CLOCK_FLOOR and reported < sim_span * CLOCK_CEILING,
		"THE NUMBER A PLAYER MEETS: the ledger's \"seconds\" is the SIMULATED duration of the errand and not the wall's - %.4f s against %.4f s simulated over %d frames, wall %.4f s, band %.4f to %.4f" % [
			reported, sim_span, frames, wall_span, sim_span * CLOCK_FLOOR, sim_span * CLOCK_CEILING])
	_check(float(rec.get("travelled", 0.0)) > 1.0,
		"and the errand it is the duration OF really walked - %.1f m in the same record" % float(rec.get("travelled", 0.0)))

	# AND IT REACHES THE SENTENCE, WHOSE OWN NUMBER IS READ OUT AND PUT
	# THROUGH THE SAME BAND.
	#
	# WHY IT IS NOT COMPARED AGAINST THE RECORD'S NUMBER, WHICH IS A FAULT
	# THIS ROW HAD AND WAS CAUGHT BY RUNNING IT RED. The first draft asserted
	# that the sentence contained `"in %.0f seconds" % reported`. The record
	# holds `snappedf(elapsed, 0.1)` (`game_controller.gd:443`) and the
	# sentence rounds the RAW `elapsed` to the second (`npc_goals.gd:380`), so
	# the two roundings can land either side of a half: against a wall-clock
	# `npc.gd` with no `--fixed-fps` the record read 19.5000 s, the row wanted
	# "in 20 seconds" and the sentence said "in 19 seconds", and the row
	# failed for a reason that was nothing to do with which clock it was. It
	# would have flaked on any errand that happened to land on a half-second.
	# Reading the sentence's own number and banding it needs no agreement
	# between two roundings, and it is the stronger claim of the two: it is
	# the duration the PLAYER sees, held against the span this suite stepped.
	var sentence := str(said[-1]) if not said.is_empty() else ""
	var dug := RegEx.create_from_string("in ([0-9]+) seconds").search(sentence)
	_check(dug != null,
		"and the sentence the player reads carries a duration at all - \"%s\"" % sentence)
	if dug != null:
		var told := float(dug.get_string(1))
		_check(told > sim_span * CLOCK_FLOOR and told < sim_span * CLOCK_CEILING,
			"AND THAT IS THE DURATION THE PLAYER IS TOLD: the sentence's own number is the SIMULATED duration too - %d s in \"%s\", against %.4f s simulated, band %.4f to %.4f" % [
				int(told), sentence, sim_span, sim_span * CLOCK_FLOOR, sim_span * CLOCK_CEILING])

	_check(is_equal_approx(Engine.time_scale, 1.0),
		"and the engine's time scale is back to 1.0 for anything after this (%.2f)" % Engine.time_scale)
	lines.append("  ERRAND CLOCK: at time_scale %.2f, %d frames of GOING = %.4f s simulated and %.4f s of wall; Npc.elapsed read %.4f s at frame %d of a %.4f s span; the ledger reported %.4f s and the player read \"%s\"" % [
		CLOCK_SCALE, frames, sim_span, wall_span, mid_elapsed, CLOCK_MID_FRAMES, mid_span, reported, sentence])

	main.controller.log_message.disconnect(_on_said)
	await _drop_main()


func _run() -> void:
	await _arrival_section()
	await _stall_section()
	await _cap_section()
	await _nowhere_section()
	await _unreachable_section()
	_ordering_section()
	await _clock_section()
	print("")
	for l in lines:
		print(l)
	print("HALT CAUSE %d assertions, failures=%d" % [asserted, failures.size()])
	quit(failures.size())
