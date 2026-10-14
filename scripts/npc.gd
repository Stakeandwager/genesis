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

signal stopped_walking(why: String, at: Vector3, seconds: float, travelled: float)

var state := WAITING
var marks: Array = []              # Vector3 waypoints, in world space
var mark := 0
var elapsed := 0.0
var travelled := 0.0
var why := ""

var _closest := 1e9
var _stale := 0.0
var _was := Vector3.ZERO


func _build_body() -> void:
	super._build_body()
	var figure := get_node_or_null("Figure") as MeshInstance3D
	if figure:
		var material := StandardMaterial3D.new()
		material.albedo_color = Color(0.30, 0.52, 0.64)
		material.roughness = 0.9
		figure.material_override = material


# Take a route and start walking it. A new order replaces the old one
# outright, rather than queueing: a player who says "no, the other room" means
# now.
func follow(route: Array) -> void:
	marks.clear()
	for p in route:
		var point: Vector2 = p
		marks.append(Vector3(point.x, 0.0, point.y))
	mark = 0
	elapsed = 0.0
	travelled = 0.0
	why = ""
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


func halt(reason: String) -> void:
	if state != GOING:
		return
	state = STOPPED
	why = reason
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
		mark += 1
		_closest = 1e9
		_stale = 0.0
		if mark >= marks.size():
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
