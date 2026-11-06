extends SceneTree

# 120 - the body the player stepped out of, and whether the keyboard is still
# driving it.
#
# WHY THIS SUITE EXISTS
# `_stop_exploring()` set `visible = false` and nothing else, and
# `Walker._physics_process` reads the keyboard every tick when `auto_walk` is
# false. `Input` reports the DEVICE, not the focused control, so an invisible
# body went on walking while the player typed their next request. Measured
# before the fix, in a dungeon, after `/view`: holding W moved the hidden body
# 2.07 m, and 2.69 m again with the text box focused and empty.
#
# The sibling path had already got this right: `_stop_driving()` sets
# `car.freeze = true`, and `Car._physics_process` reads the same keys just as
# unconditionally - measured, 0.00 m after `/view`. So this is TRAPS 11's
# shape, a rule kept at one of its two doors, and BOTH doors are asserted
# here. The last section derives the list of bodies from Main's own children
# rather than naming the two, so a third body added later is asked the
# question without anybody remembering to add it (TRAPS 114).
#
# WHY EVERY SECTION GETS ITS OWN Main, AND IT IS A MEASUREMENT RATHER THAN
# TIDINESS
# The first version of this file ran the walker rows and then the car rows on
# one Main, and the car's CONTROL row - holding W while the player is in the
# car - failed at 0.27 m where a car on a fresh Main goes 4.90 m. Narrowed:
# the walker was left standing at the dungeon's entrance, which is the origin;
# the dungeon was then cleared and a track built; and `/drive` placed the car
# on top of the player's own invisible body, where it settled at y 2.85
# instead of 1.39 and could not be driven at all. Removing the body from the
# tree and changing nothing else restored 4.90 m. **That is a fault and it is
# NOT this commit's**: the same probe against the unmodified `main.gd` of
# commit 975a70d reads the same 0.05 m. It has a live entry in HANDOVER. A
# fresh Main per section is what keeps these rows measuring the keyboard
# instead of that.
#
# WHAT EACH PAIR OF ROWS IS FOR
# Every "after /view" row has a "while in it" row in front of it. Without
# those, a suite that held a key down and saw nothing move would pass on a
# body that cannot move at all, a key nothing reads, or a headless harness
# that delivers no input - a green suite that tests nothing (TRAPS 6). The
# control rows are what make the zeros mean something, and one of them is what
# found the fault above.
#
# AND THE BODY MUST STILL BE THERE
# Taking the keyboard away is not a teleport and not a removal: the rows read
# the body's position across the held key and assert it has not moved AND is
# still in the tree. `_on_door_changed` already takes trouble to leave a
# walking body exactly where it stands, and `freeze` does the same for the
# car.
#
# WHAT IT DOES NOT ASSERT
# Nothing about whether a body the player has stepped out of SHOULD stay in
# the world as a solid obstacle. It does; it blocks a character's errand and
# it immobilises the car. Both are measured, with their numbers, in HANDOVER's
# live entries - and neither is pinned here, because a suite that asserted
# today's answer would have to be deleted by whoever answers the question
# attached to it.
# Nothing about a real keystroke typed into a focused LineEdit on real
# hardware. This harness sets the device state with
# `Input.parse_input_event`; the LineEdit took no character from it (its text
# stayed empty), so the focused case is not faithfully reproduced here and is
# not asserted. The rows below hold the key with nothing focused, which is
# enough to show a hidden body is still read by the keyboard.

var main: Node3D
var lines: Array = []
var failures: Array = []
var asserted := 0

const DUNGEON := '{"command": "CREATE_DUNGEON", "parameters": {"rooms": [{"name": "entrance", "width": 12, "depth": 12}, {"name": "store", "width": 12, "depth": 12}, {"name": "vault", "width": 12, "depth": 12}], "doors": [[1, 2], [2, 3]]}}'
const TRACK := '{"command": "CREATE_TRACK", "parameters": {"mode": "circuit", "sections": [{"type": "straight", "length": 80}, {"type": "corner", "radius": 30, "angle": 90}, {"type": "straight", "length": 80}, {"type": "corner", "radius": 30, "angle": 90}, {"type": "straight", "length": 80}, {"type": "corner", "radius": 30, "angle": 90}, {"type": "straight", "length": 80}, {"type": "corner", "radius": 30, "angle": 90}]}}'

# A second and a half of a held key at 120 ticks. The control rows print what
# that actually comes to rather than asserting a distance, and only ask that
# it is more than MOVED: the point of a control is that the probe COULD have
# moved, not that it moves exactly so far.
const HELD_TICKS := 180
const MOVED := 1.0
# What counts as not having moved. NOT zero, and the reason is the point: both
# bodies are still SIMULATED after `/view`, so a body coasting to a halt under
# drag covers a little ground on the way. 0.05 m is a fiftieth of what a held
# key moves either body, so a key that still reached one could not hide under
# it.
const STILL := 0.05


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


# The device state, which is what both bodies read. Set with keycode AND
# physical_keycode because Walker asks `is_key_pressed` and Car asks
# `is_physical_key_pressed` - the two bodies read the keyboard through
# different calls, and a probe that set only one would be measuring one of
# them.
func _key(code: Key, down: bool) -> void:
	var ev := InputEventKey.new()
	ev.keycode = code
	ev.physical_keycode = code
	ev.pressed = down
	Input.parse_input_event(ev)


# Hold a key, let the body settle, and answer how far it went. Released in all
# cases, so a row that fails cannot leave the key down for the next one.
func _held_move(body: Node3D, code: Key) -> float:
	var before: Vector3 = body.global_position
	_key(code, true)
	for i in HELD_TICKS:
		await physics_frame
	_key(code, false)
	for i in 15:
		await physics_frame
	return body.global_position.distance_to(before)


# Every body Main holds that the player can step INTO, taken off Main's own
# children rather than from a list in this file. The character is excluded by
# type: an Npc is a Walker, the player never steers it, and it must go on
# being driven while it is walking an errand.
func _player_bodies() -> Array:
	var out: Array = []
	for child in main.get_children():
		if child is Npc:
			continue
		if child is Walker or child is Car:
			out.append(child)
	return out


# Is this body still being steered by the keyboard? Asked of each kind by the
# thing that actually decides it: `freeze` for a RigidBody3D car, and for a
# CharacterBody3D walker whether anything other than the keyboard is driving
# it with nothing to drive.
func _still_steered(body: Node3D) -> bool:
	if body is Car:
		return not bool(body.freeze)
	return not bool(body.auto_walk) \
		or absf(float(body.auto_forward)) > 0.001 \
		or absf(float(body.auto_turn)) > 0.001


func _finish() -> void:
	print("")
	for l in lines:
		print(l)
	print("LEFT BODY %d assertions, failures=%d" % [asserted, failures.size()])
	quit(failures.size())


# --- the walker, on a Main of its own ---
func _walker_section() -> void:
	_make_main()
	await process_frame
	await _type(DUNGEON)
	await _type("/explore")
	_check(main.exploring and main.walker != null,
		"a dungeon is standing and /explore put the player in a body")
	for i in 60:
		await physics_frame

	var walked: float = await _held_move(main.walker, KEY_W)
	_check(walked > MOVED,
		"THE CONTROL: while the player is IN it, holding W walks the body %.2f m" % walked)

	await _type("/view")
	_check(not main.exploring and not main.walker.visible,
		"/view stops exploring and the body goes invisible")
	_check(main.walker.is_inside_tree() and is_instance_valid(main.walker),
		"and the body is STILL IN THE WORLD: /view hides it, it does not remove it")

	# Let the body finish coasting before the reading is taken, so what the
	# next row measures is the held key and not the last one.
	for i in 60:
		await physics_frame
	var left_at: Vector3 = main.walker.global_position
	var hidden_walked: float = await _held_move(main.walker, KEY_W)
	_check(hidden_walked < STILL,
		"AND THE KEYBOARD NO LONGER DRIVES IT: holding W after /view moves the hidden body %.3f m" % hidden_walked)
	_check(main.walker.global_position.distance_to(left_at) < STILL,
		"and it is still where the player left it, neither teleported nor dropped: %.3f m" %
			main.walker.global_position.distance_to(left_at))

	# R is read in the same branch as W, and it TELEPORTS the body back to the
	# entrance. A hidden body jumping across the world while the player types
	# is the same fault with a larger step, so it gets its own row.
	var before_r: Vector3 = main.walker.global_position
	var hidden_reset: float = await _held_move(main.walker, KEY_R)
	_check(hidden_reset < STILL,
		"and R no longer teleports the hidden body to the entrance either: %.3f m" % hidden_reset)

	# The fix must not be a one-way door: a player who goes back in must get
	# their body back. Without this row, taking the keyboard away and never
	# giving it back would pass every row above.
	await _type("/explore")
	for i in 60:
		await physics_frame
	var again: float = await _held_move(main.walker, KEY_W)
	_check(again > MOVED,
		"and /explore gives the body back: holding W walks it %.2f m again" % again)
	_check(before_r.distance_to(main.walker.global_position) > 0.0,
		"and that second walk is a real one, from a body the suite has not teleported")

	await _drop_main()


# --- the car, the sibling path, on a Main of its own ---
func _car_section() -> void:
	_make_main()
	await process_frame
	await _type(TRACK)
	await _type("/drive")
	_check(main.driving and main.car != null,
		"a track is standing and /drive put the player in a car")
	for i in 240:
		await physics_frame

	var drove: float = await _held_move(main.car, KEY_W)
	_check(drove > MOVED,
		"THE CONTROL: while the player is IN it, holding W drives the car %.2f m" % drove)

	await _type("/view")
	_check(not main.driving and main.car.freeze,
		"/view stops driving and the car is frozen")
	var parked_at: Vector3 = main.car.global_position
	var frozen_drove: float = await _held_move(main.car, KEY_W)
	_check(frozen_drove < STILL,
		"and the keyboard does not drive it either: holding W after /view moves the frozen car %.3f m" % frozen_drove)
	_check(main.car.is_inside_tree() and main.car.global_position.distance_to(parked_at) < STILL,
		"and the car is still in the world, where it was parked: %.3f m" %
			main.car.global_position.distance_to(parked_at))

	await _drop_main()


# --- the class, derived rather than listed ---
# One Main that has been in BOTH bodies, so the row is asked of every body
# Main holds. It reads flags and no distances, which is why it can share a
# Main with a car parked on a walker.
func _class_section() -> void:
	_make_main()
	await process_frame
	await _type(DUNGEON)
	await _type("/explore")
	await _type("/view")
	await _type(TRACK)
	await _type("/drive")
	await _type("/view")
	for i in 30:
		await physics_frame

	var bodies := _player_bodies()
	var still_driven: Array = []
	for body in bodies:
		if _still_steered(body):
			still_driven.append(str(body.name))
	_check(bodies.size() == 2 and still_driven.is_empty(),
		"EVERY body Main lets the player step into is left unsteered by /view: %d found, still driven: %s" % [
			bodies.size(), str(still_driven)])

	# And the row above could fail: the same question asked while the player
	# is IN a body must find it steered, or the check is a guard against
	# nothing (TRAPS 6).
	#
	# THE DUNGEON IS BUILT AGAIN FIRST. Without it `/explore` is refused -
	# the track replaced the dungeon, so there is nowhere to stand - and the
	# row read an empty list and looked like the fix leaking rather than like
	# a probe that never started (TRAPS 6, again, in the row written to catch
	# exactly that).
	await _type(DUNGEON)
	await _type("/explore")
	for i in 10:
		await physics_frame
	var steered: Array = []
	for body in _player_bodies():
		if _still_steered(body):
			steered.append(str(body.name))
	_check(steered == ["Walker"],
		"and the check can fail: back in the body, exactly the Walker is steered again: %s" % str(steered))

	await _drop_main()


func _run() -> void:
	await _walker_section()
	await _car_section()
	await _class_section()
	_finish()
