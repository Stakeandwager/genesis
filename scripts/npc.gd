extends Walker
class_name Npc

# --- 014: a character that can be sent somewhere ---
#
# It EXTENDS Walker rather than reimplementing it, and that is the whole
# design. The body a character has is the body the player has: same capsule,
# same force, mass and drag, same collision. A doorway that stops you stops
# it. If it were its own kind of body, the two could disagree about what the
# world is, and every verification after that would be measuring a different
# world from the one you walk in.
#
# WHAT THIS DOES NOT DO
# It never decides whether it arrived. It walks, it stops, and it says where
# it stopped and why it stopped trying. Whether that place is the room it was
# sent to is answered by the module that owns the geometry, afterwards.
#
# That is deliberate and it is structural, not a rule anybody follows: there
# is no code path by which a character can report its own success. An NPC that
# can say "delivered" is an NPC that will say it when nothing arrived.

enum { WAITING, GOING, STOPPED }

const ARRIVE := 1.4                # metres; close enough to a waypoint
const FACING := 0.8                # radians; wide enough to walk while turning
const CREEP := 0.35                # forward effort while turning hard
const REACH := 2.2                 # metres; close enough to pick something up
const HOLD := 0.4                  # how high a carried thing rides
const THING_REST := 0.45           # half a thing's height, so it sits on the floor

signal stopped_walking(why: String, at: Vector3, seconds: float, travelled: float)

var state := WAITING
var marks: Array = []              # Vector3 waypoints, in world space
var mark := 0
var elapsed := 0.0
var travelled := 0.0
var why := ""

# What was ATTEMPTED, in order, with what came of each attempt. This is not
# evidence that anything was accomplished - it is the carrier's account of its
# own actions, and it is kept apart for exactly that reason: "picked up the
# key" is a thing that was tried, not proof the key changed hands.
var attempts: Array = []

# 015: what is being carried, if anything. The character moves it; it never
# says anything about where it got to.
var load_node: Node3D = null
var pickup_at := -1               # which waypoint to pick the thing up at

var _closest := 1e9
var _stale := 0.0
var _was := Vector3.ZERO
var _carry_target: Node3D = null
var _carry_home: Node3D = null
var _floor_y := 0.0


func _build_body() -> void:
	super._build_body()
	var figure := get_node_or_null("Figure") as MeshInstance3D
	if figure:
		var material := StandardMaterial3D.new()
		material.albedo_color = Color(0.30, 0.52, 0.64)
		material.roughness = 0.9
		figure.material_override = material


# Carry something: walk to it, pick it up at the waypoint given, carry on.
# The thing is reparented to the body so the world moves it, rather than its
# position being written by hand - a carried thing is in the scene where it
# looks like it is.
func fetch(route: Array, thing: Node3D, at_mark: int) -> void:
	follow(route)
	pickup_at = at_mark
	_carry_target = thing
	_carry_home = thing.get_parent()
	_floor_y = thing.global_position.y - THING_REST


# Take a route and start walking it. A new order replaces the old one
# outright, rather than queueing: a player who says "no, the other room" means
# now. Anything being carried is set down where the body stands.
func follow(route: Array) -> void:
	if load_node != null:
		_put_down()
	marks.clear()
	for p in route:
		var point: Vector2 = p
		marks.append(Vector3(point.x, 0.0, point.y))
	mark = 0
	pickup_at = -1
	_carry_target = null
	elapsed = 0.0
	travelled = 0.0
	why = ""
	attempts.clear()
	_closest = 1e9
	_stale = 0.0
	_was = global_position
	auto_walk = true
	auto_forward = 0.0
	auto_turn = 0.0
	state = GOING if not marks.is_empty() else STOPPED
	if state == STOPPED:
		why = "nowhere to go"
		stopped_walking.emit(why, global_position, 0.0, 0.0)


# Set it down where the body stands. Nothing about this says it is the right
# place: that is read off the thing's position afterwards, by the module that
# owns the geometry.
func _put_down() -> void:
	if load_node == null or not is_instance_valid(load_node):
		load_node = null
		return
	var here := load_node.global_position
	remove_child(load_node)
	var world := get_tree().current_scene if get_tree() else null
	var holder := _carry_home if is_instance_valid(_carry_home) else world
	if holder == null:
		add_child(load_node)
		return
	holder.add_child(load_node)
	load_node.global_position = Vector3(here.x, _floor_y + THING_REST, here.z)
	_collide(load_node, true)
	attempts.append({"action": "set_down", "result": "set_down",
		"at": [snappedf(here.x, 0.1), snappedf(here.z, 0.1)],
		"seconds": snappedf(elapsed, 0.1)})
	load_node = null


# A crate riding on your shoulder should not shove you about: its collision
# sleeps while it is carried and wakes when it is set down.
func _collide(thing: Node3D, on: bool) -> void:
	var body := thing.get_node_or_null("Solid") as StaticBody3D
	if body == null:
		return
	for child in body.get_children():
		if child is CollisionShape3D:
			(child as CollisionShape3D).disabled = not on


# Put down whatever is being carried, here, now. Nothing about doing it says
# it is the right place - that is read off the thing afterwards.
func drop() -> void:
	_put_down()


func halt(reason: String) -> void:
	if state != GOING:
		return
	state = STOPPED
	why = reason
	# A carrier asked to fetch something that never got near it still has to
	# say so: silence about an attempt is not the same as not attempting.
	if pickup_at >= 0:
		var tried := false
		for a in attempts:
			if str((a as Dictionary)["action"]) == "pick_up":
				tried = true
		if not tried:
			attempts.append({"action": "pick_up", "result": "never_reached_it",
				"at": [snappedf(global_position.x, 0.1), snappedf(global_position.z, 0.1)],
				"seconds": snappedf(elapsed, 0.1)})
	auto_forward = 0.0
	auto_turn = 0.0
	stopped_walking.emit(reason, global_position, elapsed, travelled)


func _physics_process(delta: float) -> void:
	if state == GOING:
		_steer(delta)
	super._physics_process(delta)


func _steer(delta: float) -> void:
	elapsed += delta
	travelled += Vector2(global_position.x - _was.x, global_position.z - _was.z).length()
	_was = global_position

	if elapsed > NpcGoals.MAX_SECONDS:
		halt("gave up")
		return

	var target: Vector3 = marks[mark]
	var to := Vector3(target.x - global_position.x, 0.0, target.z - global_position.z)
	var gap := to.length()

	if gap < ARRIVE:
		# 015: the thing is picked up at the waypoint it stands at, and only
		# if the body is actually beside it. Reaching the room is not picking
		# it up.
		if mark == pickup_at and load_node == null and is_instance_valid(_carry_target):
				var away := global_position.distance_to(_carry_target.global_position)
				if away < REACH:
					load_node = _carry_target
					var world := load_node.get_parent()
					world.remove_child(load_node)
					add_child(load_node)
					load_node.position = Vector3(0.0, HOLD, -BODY * 0.6)
					_collide(load_node, false)
					attempts.append({"action": "pick_up", "result": "picked_up",
						"at": [snappedf(global_position.x, 0.1), snappedf(global_position.z, 0.1)],
						"seconds": snappedf(elapsed, 0.1)})
				else:
					attempts.append({"action": "pick_up", "result": "out_of_reach",
						"short_by": snappedf(away - REACH, 0.1),
						"at": [snappedf(global_position.x, 0.1), snappedf(global_position.z, 0.1)],
						"seconds": snappedf(elapsed, 0.1)})
		mark += 1
		_closest = 1e9
		_stale = 0.0
		if mark >= marks.size():
			_put_down()
			halt("stopped walking")
		return

	# No progress for long enough is being stuck, which is a real answer and
	# a more useful one than walking into a wall for ninety seconds.
	if gap < _closest - 0.05:
		_closest = gap
		_stale = 0.0
	else:
		_stale += delta
		if _stale > NpcGoals.STALL_SECONDS:
			halt("stopped making progress")
			return

	# Turn towards the waypoint, and walk while doing it unless the turn is
	# sharp, so a corner is taken rather than orbited.
	var facing := -transform.basis.z
	var want := atan2(-to.x, -to.z)
	var have := atan2(-facing.x, -facing.z)
	var off := wrapf(want - have, -PI, PI)
	auto_turn = clampf(off * 2.0, -1.0, 1.0)
	auto_forward = 1.0 if absf(off) < FACING else CREEP
