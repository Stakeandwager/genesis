extends Node
class_name CheckpointTracker

# --- Prototype 002B: lap timing ---
# Invisible checkpoints are spread evenly along the centreline. A lap only
# counts when they are passed in order and the start line is reached again,
# so cutting the course or reversing over the line does not score a lap.
#
# 130: THAT PARAGRAPH WAS HALF FALSE FROM 002B TO 129 AND IS KEPT AS IT WAS
# WRITTEN, because it is the claim this commit made true rather than a
# sentence to delete (TRAPS 14). The ordering half was always true. The
# start-line half was not: next_index started at 1 and was only ever
# incremented or reset to 1, so checkpoints[0] - the start line - was never a
# target. Timing began at checkpoints[1] and a lap was counted at
# checkpoints[11], so lap 1 spanned ten of twelve segments and every lap was
# "completed" about a twelfth of a circuit BEFORE the line.
#
# WHAT THAT COST A PLAYER, MEASURED (129, and the numbers are in HANDOVER's
# 129 and 130 entries). On a 2377 m circuit driven at a constant 19.7 m a
# frame, lap 1 read 0.7000 s where laps 2 and 3 read 0.8250 and 0.8333 - and
# because best_lap_time is a min, that short first lap became the "best lap"
# on main.gd:869-873's status line and in the history for the rest of the
# session. The player was shown, as his best, a time he had not driven and
# could not beat unless a real lap was 17% faster than his others.
#
# WHAT IS DIFFERENT NOW: THE LINE IS A MARKER LIKE THE OTHER ELEVEN.
# next_index cycles 0 -> 1 -> ... -> 11 -> 0, so reaching checkpoints[0] in
# order is what closes a lap and what starts the next one. Lap 1 is a whole
# lap, every lap is counted at the line, and the ordering requirement is
# stronger than before rather than weaker: the line itself now has to be
# passed in its turn.
#
# AND THE STANDING START IS WHY THERE IS A _left_line FLAG, WHICH IS NOT
# TIDINESS. A checkpoint is "reached" by proximity, and the player's car is
# placed ON the start line by /drive (main.gd:728) and 20 m behind it on a
# two-row grid by /race (race_director.gd:96-97) - inside REACH either way,
# from the first frame. The first version of this fix started the lap clock
# there, and section 8 of player_door_test caught it immediately on the first
# run after it: lap 1 read 3.0992 s against 0.0833 s for laps 2 and
# 3, because the clock had run through the whole 3 s countdown the player sits
# out before he moves. Arriving at the line cannot be told from waiting on it,
# so the line only counts as reached once the car has been CLEAR of it, and a
# car that began inside it has its lap timed from the moment it drove off.
#
# WHAT THAT LEAVES, STATED RATHER THAN HIDDEN: lap 1 is short by the distance
# from the line to wherever the car was first seen clear of its REACH - 53.2 m
# of a 2377 m circuit as section 9 MEASURES it, 2.2%, against the 16.7% this
# commit removed. It is a fixed offset and not a growing one, a real lap beats
# it (lap 1 read 0.8083 s against 0.8333 s for laps 2 and 3, 0.970), and the
# alternative - firing every line event at the point of CLOSEST APPROACH
# instead of on arrival, which would make lap 1 exact and move every "Lap N
# completed" from 30 m before the line to 30 m after it - is written up in
# HANDOVER's 130 entry as a proposal and is not applied here.
#
# THE CLASS, ASKED RATHER THAN ASSUMED (TRAPS 11). Every other ordered
# progress index in scripts/ was read: Npc.mark is set to 0 in follow()
# (npc.gd:91), so the first waypoint is a target; RaceDirector tracks progress
# by arc length with a wrap at the line (race_director.gd:231-239), not by a
# skipped index; and the two range(1, ...) loops in dungeon_module.gd (1175,
# 1577) are consecutive-pair loops whose element 0 is handled on its own line.
# This file held the only instance.

signal lap_completed(last_time: float, best_time: float)

const CHECKPOINT_COUNT := 12
const REACH := 30.0          # how close counts as passing a checkpoint

var checkpoints: PackedVector3Array = PackedVector3Array()
# 130: 0, not 1. The start line is the first marker a lap is measured from.
var next_index := 0
var lap_count := 0
var last_lap_time := 0.0
var best_lap_time := 0.0
var lap_started := false
# 130: has the car been clear of the start line's REACH since initialize, and
# was it inside it when the tracker first saw it. See the standing-start
# paragraph in the header: without these the lap clock starts on the grid.
var _left_line := false
var _began_at_line := false
var _seen := false

# 128: THE LAP CLOCK IS THE SIMULATION'S CLOCK AND NOT THE WALL'S.
# It was a wall clock from 002B to 127, and that is the odd one out of the
# three durations Genesis reports about its own world. The other two
# accumulate the engine's frame delta in _physics_process: RaceDirector._clock
# (race_director.gd:138), which is where a race's finish time comes from, and
# Npc.elapsed (npc.gd:178), which is the "seconds" an errand reports and the
# cap it gives up at. This one now does the same thing, so a lap time and the
# finish time of the race it was driven in are the same clock.
#
# MEASURED, not argued, and the measurement is in HANDOVER's 128 entry: at
# 2.5 frames a second the old clock read 8.41 s for a lap the engine had
# simulated in 1.40 s, because Godot clamps the delta it hands out and does
# not clamp the wall. The same lap read 0.000 s under --fixed-fps, which is
# what 127 found and could not explain from the suite alone.
var _clock := 0.0
var _lap_start := 0.0


func _physics_process(delta: float) -> void:
	_clock += delta


func initialize(centreline: PackedVector3Array) -> void:
	checkpoints = PackedVector3Array()
	next_index = 0
	lap_count = 0
	last_lap_time = 0.0
	best_lap_time = 0.0
	lap_started = false
	_left_line = false
	_began_at_line = false
	_seen = false
	_clock = 0.0
	_lap_start = 0.0

	if centreline.size() < CHECKPOINT_COUNT:
		return

	var step := float(centreline.size()) / float(CHECKPOINT_COUNT)
	for i in CHECKPOINT_COUNT:
		checkpoints.append(centreline[int(i * step)])


func update_progress(position: Vector3) -> void:
	if checkpoints.is_empty():
		return

	var at_line := Vector2(position.x - checkpoints[0].x, position.z - checkpoints[0].z).length() <= REACH
	if not _seen:
		_seen = true
		_began_at_line = at_line

	if not at_line and not _left_line:
		_left_line = true
		# A standing start: the car was on the grid inside the line's REACH
		# and has driven off it. That is where lap 1 is timed from.
		if _began_at_line and next_index == 0 and not lap_started:
			lap_started = true
			_lap_start = _clock
			next_index = 1

	if next_index == 0:
		# The start line is the target, and it only counts once the car has
		# been clear of it.
		if not at_line or not _left_line:
			return
		next_index = 1
		if not lap_started:
			# Reached the line from elsewhere with no lap running: a grid
			# further back than REACH, or a player who drove here first.
			lap_started = true
			_lap_start = _clock
			return
		lap_count += 1
		last_lap_time = _clock - _lap_start
		_lap_start = _clock
		if best_lap_time <= 0.0 or last_lap_time < best_lap_time:
			best_lap_time = last_lap_time
		lap_completed.emit(last_lap_time, best_lap_time)
		return

	# One of the eleven between the lines: advance, and after the last of them
	# the next target is the line itself.
	var target := checkpoints[next_index]
	if Vector2(position.x - target.x, position.z - target.z).length() > REACH:
		return
	next_index += 1
	if next_index >= checkpoints.size():
		next_index = 0


func get_formatted_time(seconds: float) -> String:
	if seconds <= 0.0:
		return "--:--"
	var minutes := int(seconds) / 60
	return "%d:%05.2f" % [minutes, seconds - float(minutes * 60)]
