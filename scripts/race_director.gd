extends Node
class_name RaceDirector

# --- 002D: racing against opponents ---
# Computer-controlled cars race the player round any circuit Genesis builds.
# They drive the same Car as the player, through its auto_drive inputs, so
# they obey the same physics, grip and barriers: nothing is faked.
#
# How an opponent drives:
#   steering - aims at a point further along the centreline (further the
#              faster it goes), and steers in proportion to the angle to it;
#   speed    - every point of the centreline has a safe cornering speed from
#              its curvature; the car slows in time for the slowest point it
#              can still brake for. Skill scales the grip each car trusts.
#   recovery - a car that is stuck, upside down or off the road for a few
#              seconds is put back on the centreline, facing the right way.
#
# Race order comes from distance raced along the centreline, so cutting
# across the infield gains nothing. The race is RACE_LAPS laps for the player;
# the result is announced and written to the track log.

signal announced(text: String)

const RACE_LAPS := 3
const COUNTDOWN := 3.0
const GRID_SPACING := 10.0        # metres between grid rows
const GRID_OFFSET := 3.0          # metres either side of the centreline
const BASE_GRIP := 11.0           # m/s^2 of cornering an opponent trusts at skill 1.0
const BRAKING := 7.0              # m/s^2 an opponent plans to brake at
const TOP_SPEED := 70.0           # m/s, about 250 km/h
const LOOKAHEAD_MIN := 9.0
const LOOKAHEAD_PER_MS := 0.45    # extra lookahead metres per m/s
const STEER_GAIN := 2.2
const SPEED_GAIN := 0.35
const OFF_ROAD := 16.0            # metres from the centreline counts as off
const STUCK_TIME := 3.0
const RECOVER_CLEARANCE := 10.0   # metres a recovered car is kept from any other car
const RECOVER_MAX_SHIFT := 80.0   # metres along the road it may be moved to find that
const SEARCH_WINDOW := 40         # centreline points searched either side

const SKILLS := [0.80, 0.88, 0.95, 0.84, 0.92]
const COLOURS := [Color(0.15, 0.35, 0.85), Color(0.15, 0.65, 0.25), Color(0.90, 0.75, 0.10), Color(0.55, 0.20, 0.70), Color(0.95, 0.50, 0.10)]
const NAMES := ["Blue", "Green", "Yellow", "Purple", "Orange"]
# Each opponent keeps to its own line across the road (metres right of the
# centreline), so faster cars can pass slower ones instead of queueing.
const LANES := [-3.0, 3.0, 0.0, -1.5, 1.5]

var running := false
var finished := false
var opponents: Array = []        # Car
var racers: Array = []           # Dictionary per car, the player first

var _points := PackedVector3Array()
var _along := PackedFloat64Array()   # distance along the line at each point
var _safe := PackedFloat64Array()    # safe cornering speed at each point
var _length := 0.0
var _clock := 0.0
var _start_heading := 0.0
var _player: Car


# centreline: the circuit's centreline in world coordinates, start line first.
func start(centreline: PackedVector3Array, start_heading: float, player: Car, count: int, road_height: float) -> String:
	stop()
	if centreline.size() < 20:
		return "This track is too short to race on."
	_prepare_line(centreline)
	_start_heading = start_heading
	_player = player
	_clock = 0.0
	finished = false

	count = clampi(count, 1, SKILLS.size())
	racers = [_new_racer(player, "You", 1.0)]

	# The grid: opponents in pairs behind the start line, the player at the back
	# so there is someone to chase. Grid spots follow the road backwards, so a
	# circuit that reaches the line through a corner still has its grid on it.
	for i in count:
		var car := Car.new()
		car.name = "Opponent%d" % (i + 1)
		car.body_colour = COLOURS[i]
		car.auto_drive = true
		get_parent().add_child(car)
		var row := i / 2 + 1
		var lane := -1.0 if i % 2 == 0 else 1.0
		var spot := _behind(GRID_SPACING * row)
		var heading: float = spot[1]
		car.place_at(spot[0] + TrackGeometry.right(heading) * GRID_OFFSET * lane + Vector3.UP * road_height, heading)
		opponents.append(car)
		var racer := _new_racer(car, NAMES[i], SKILLS[i])
		racer["lane"] = LANES[i]
		racers.append(racer)

	var player_row := (count + 1) / 2 + 1
	var player_spot := _behind(GRID_SPACING * player_row)
	player.place_at(player_spot[0] + Vector3.UP * road_height, player_spot[1])
	# Hold everyone on the grid during the countdown.
	player.auto_drive = true
	player.auto_throttle = 0.0
	player.auto_steer = 0.0

	for r in racers:
		_locate(r, true)
	running = true
	return "Race: %d laps against %d opponent%s. Get ready..." % [RACE_LAPS, count, "" if count == 1 else "s"]


func stop() -> void:
	running = false
	for car in opponents:
		if is_instance_valid(car):
			car.queue_free()
	opponents.clear()
	racers.clear()
	if _player and is_instance_valid(_player):
		_player.auto_drive = false


func countdown_left() -> float:
	return maxf(0.0, COUNTDOWN - _clock)


func player_position() -> int:
	return _position_of(racers[0]) if not racers.is_empty() else 0


func player_lap() -> int:
	if racers.is_empty():
		return 0
	return clampi(int(racers[0]["lap"]) + 1, 1, RACE_LAPS)


func _physics_process(delta: float) -> void:
	if not running:
		return
	_clock += delta
	var racing := _clock >= COUNTDOWN
	if racing and _player.auto_drive and racers[0]["car"] == _player and not finished:
		_player.auto_drive = false
		announced.emit("GO!")

	for r in racers:
		_locate(r, false)
		if r["car"] != _player:
			_drive(r, racing, delta)

	if not finished and float(racers[0]["raced"]) >= RACE_LAPS * _length:
		_finish()


# --- the centreline, prepared once per race ---

func _prepare_line(centreline: PackedVector3Array) -> void:
	_points = PackedVector3Array()
	# Drop repeated points where one section ends and the next begins.
	for p in centreline:
		if _points.is_empty() or _points[_points.size() - 1].distance_to(p) > 0.5:
			_points.append(p)
	if _points.size() > 2 and _points[0].distance_to(_points[_points.size() - 1]) < 0.5:
		_points.remove_at(_points.size() - 1)

	var n := _points.size()
	_along = PackedFloat64Array()
	_along.resize(n)
	var total := 0.0
	for i in n:
		_along[i] = total
		total += _points[i].distance_to(_points[(i + 1) % n])
	_length = total

	# Safe speed from how sharply the line turns around each point.
	_safe = PackedFloat64Array()
	_safe.resize(n)
	for i in n:
		var a := _points[(i - 3 + n) % n]
		var b := _points[i]
		var c := _points[(i + 3) % n]
		var d1 := Vector2(b.x - a.x, b.z - a.z)
		var d2 := Vector2(c.x - b.x, c.z - b.z)
		var span := d1.length() + d2.length()
		var turn := absf(d1.angle_to(d2))
		var curvature := turn / maxf(span * 0.5, 0.01)
		_safe[i] = minf(TOP_SPEED, sqrt(BASE_GRIP / maxf(curvature, 0.0001)))


# A point on the centreline this far behind the start line, and the heading
# of the road there.
func _behind(distance: float) -> Array:
	var n := _points.size()
	var s := fposmod(_length - distance, _length)
	var i := n - 1
	while i > 0 and _along[i] > s:
		i -= 1
	var here := _points[i]
	var ahead := _points[(i + 1) % n]
	var heading := atan2(ahead.x - here.x, -(ahead.z - here.z))
	return [here, heading]


# --- where each car is ---

func _new_racer(car: Car, label: String, skill: float) -> Dictionary:
	return {"car": car, "name": label, "skill": skill, "index": 0, "lap": 0, "raced": 0.0,
		"last_s": 0.0, "stuck": 0.0, "finish_time": -1.0, "recoveries": 0}


func _locate(r: Dictionary, full_search: bool) -> void:
	var car: Car = r["car"]
	var pos := car.global_position
	var n := _points.size()
	var best := int(r["index"])
	var best_d := INF
	var lo := 0 if full_search else -SEARCH_WINDOW
	var hi := n if full_search else SEARCH_WINDOW
	for k in range(lo, hi):
		var i := k if full_search else (int(r["index"]) + k + n) % n
		var p := _points[i]
		var d := (p.x - pos.x) * (p.x - pos.x) + (p.z - pos.z) * (p.z - pos.z)
		if d < best_d:
			best_d = d
			best = i
	r["index"] = best
	# Off the road sideways, or fallen well below it.
	r["off"] = maxf(sqrt(best_d), (_points[best].y - pos.y) * 2.0)

	var s := _along[best]
	if full_search:
		# On the grid, behind the line: the first crossing starts lap one.
		r["lap"] = -1 if s > _length * 0.5 else 0
	else:
		var last: float = r["last_s"]
		if last > _length * 0.75 and s < _length * 0.25:
			r["lap"] = int(r["lap"]) + 1
		elif last < _length * 0.25 and s > _length * 0.75:
			r["lap"] = int(r["lap"]) - 1
	r["last_s"] = s
	r["raced"] = int(r["lap"]) * _length + s


func _position_of(r: Dictionary) -> int:
	var place := 1
	for other in racers:
		if other != r and _ahead_of(other, r):
			place += 1
	return place


func _ahead_of(a: Dictionary, b: Dictionary) -> bool:
	var fa := float(a["finish_time"])
	var fb := float(b["finish_time"])
	if fa >= 0.0 and fb >= 0.0:
		return fa < fb
	if fa >= 0.0:
		return true
	if fb >= 0.0:
		return false
	return float(a["raced"]) > float(b["raced"])


# --- how an opponent drives ---

func _drive(r: Dictionary, racing: bool, delta: float) -> void:
	var car: Car = r["car"]
	if not racing:
		car.auto_throttle = 0.0
		car.auto_steer = 0.0
		return

	var n := _points.size()
	var index := int(r["index"])
	var speed := car.linear_velocity.length()

	# Steering: aim at a point further along the line.
	var reach := LOOKAHEAD_MIN + speed * LOOKAHEAD_PER_MS
	var target := index
	var travelled := 0.0
	while travelled < reach:
		var next := (target + 1) % n
		travelled += _points[target].distance_to(_points[next])
		target = next
	var aim := _points[target]
	var along_road := _points[(target + 1) % n] - aim
	var road_heading := atan2(along_road.x, -along_road.z)
	aim += TrackGeometry.right(road_heading) * float(r.get("lane", 0.0))
	var local := car.global_transform.affine_inverse() * aim
	var angle := atan2(local.x, -local.z)   # positive: target is to the right
	car.auto_steer = clampf(angle * STEER_GAIN, -1.0, 1.0)

	# Speed: the slowest corner ahead it can still brake for.
	var grip := float(r["skill"])
	var wanted := TOP_SPEED
	var scan := index
	var distance := 0.0
	var horizon := speed * speed / (2.0 * BRAKING) + 40.0
	while distance < horizon:
		var next := (scan + 1) % n
		distance += _points[scan].distance_to(_points[next])
		scan = next
		var corner_speed := _safe[scan] * sqrt(grip)
		wanted = minf(wanted, sqrt(corner_speed * corner_speed + 2.0 * BRAKING * distance))
	wanted = minf(wanted, _safe[index] * sqrt(grip))
	# Skill also limits power, so opponents spread out rather than run nose to tail.
	car.auto_throttle = clampf((wanted - speed) * SPEED_GAIN, -1.0, grip)

	# Recovery: stuck, upside down or off the road for too long.
	var upside_down := car.global_transform.basis.y.y < 0.3
	if speed < 2.0 or upside_down or float(r["off"]) > OFF_ROAD:
		r["stuck"] = float(r["stuck"]) + delta
	else:
		r["stuck"] = 0.0
	if float(r["stuck"]) > STUCK_TIME:
		_recover(r)


func _recover(r: Dictionary) -> void:
	var car: Car = r["car"]
	var n := _points.size()
	var i := int(r["index"])
	# Never put a car back on top of another one. A car stopped on the road
	# (the player, say) used to catch an opponent behind it for ever: it ran
	# into the stopped car, was put back on the same spot, and ran into it
	# again. So the spot moves on along the road until it is clear.
	var moved := 0.0
	while _occupied(_points[i], car) and moved < RECOVER_MAX_SHIFT:
		moved += _points[i].distance_to(_points[(i + 1) % n])
		i = (i + 1) % n
	r["index"] = i
	var here := _points[i]
	var ahead := _points[(i + 2) % n]
	var heading := atan2(ahead.x - here.x, -(ahead.z - here.z))
	car.place_at(here + Vector3.UP * CircuitBuilder.ROAD_HEIGHT, heading)
	car.auto_throttle = 0.0
	r["stuck"] = 0.0
	r["recoveries"] = int(r["recoveries"]) + 1


# Whether any other car in the race is too close to this point to put a car
# there.
func _occupied(point: Vector3, except: Car) -> bool:
	for other in racers:
		var car: Car = other["car"]
		if car == except or not is_instance_valid(car):
			continue
		var p := car.global_position
		if Vector2(p.x - point.x, p.z - point.z).length() < RECOVER_CLEARANCE:
			return true
	return false


# --- the end ---

func _finish() -> void:
	finished = true
	var player_time := _clock - COUNTDOWN
	racers[0]["finish_time"] = player_time
	# Opponents are placed by how far they had raced when the player finished.
	var place := _position_of(racers[0])
	var total := racers.size()
	var text := "Finished P%d of %d in %s." % [place, total, _format(player_time)]
	if place == 1:
		text += " You won!"
	announced.emit(text)

	var order: Array = []
	var recoveries := {}
	var sorted := racers.duplicate()
	sorted.sort_custom(func(a, b): return _ahead_of(a, b))
	for r in sorted:
		order.append(r["name"])
		if r["car"] != _player:
			recoveries[r["name"]] = r["recoveries"]
	TrackLog.append({
		"type": "race_result",
		"time": Time.get_datetime_string_from_system(),
		"laps": RACE_LAPS,
		"opponents": total - 1,
		"track_length": _length,
		"player_place": place,
		"player_time": player_time,
		"order": order,
		"opponent_recoveries": recoveries,
	})


func _format(seconds: float) -> String:
	var minutes := int(seconds) / 60
	return "%d:%04.1f" % [minutes, seconds - minutes * 60]
