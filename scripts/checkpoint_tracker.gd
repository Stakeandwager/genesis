extends Node
class_name CheckpointTracker

# --- Prototype 002B: lap timing ---
# Invisible checkpoints are spread evenly along the centreline. A lap only
# counts when they are passed in order and the start line is reached again,
# so cutting the course or reversing over the line does not score a lap.

signal lap_completed(last_time: float, best_time: float)

const CHECKPOINT_COUNT := 12
const REACH := 30.0          # how close counts as passing a checkpoint

var checkpoints: PackedVector3Array = PackedVector3Array()
var next_index := 1
var lap_count := 0
var last_lap_time := 0.0
var best_lap_time := 0.0
var lap_started := false

var _lap_start_msec := 0


func initialize(centreline: PackedVector3Array) -> void:
	checkpoints = PackedVector3Array()
	next_index = 1
	lap_count = 0
	last_lap_time = 0.0
	best_lap_time = 0.0
	lap_started = false

	if centreline.size() < CHECKPOINT_COUNT:
		return

	var step := float(centreline.size()) / float(CHECKPOINT_COUNT)
	for i in CHECKPOINT_COUNT:
		checkpoints.append(centreline[int(i * step)])


func update_progress(position: Vector3) -> void:
	if checkpoints.is_empty():
		return

	var target := checkpoints[next_index]
	if Vector2(position.x - target.x, position.z - target.z).length() > REACH:
		return

	# Passing the first checkpoint after the start line begins the timing.
	if next_index == 1 and not lap_started:
		lap_started = true
		_lap_start_msec = Time.get_ticks_msec()

	next_index += 1
	if next_index < checkpoints.size():
		return

	# Back round to the start: that is a lap.
	next_index = 1
	if not lap_started:
		return

	lap_count += 1
	last_lap_time = float(Time.get_ticks_msec() - _lap_start_msec) / 1000.0
	_lap_start_msec = Time.get_ticks_msec()
	if best_lap_time <= 0.0 or last_lap_time < best_lap_time:
		best_lap_time = last_lap_time
	lap_completed.emit(last_lap_time, best_lap_time)


func get_formatted_time(seconds: float) -> String:
	if seconds <= 0.0:
		return "--:--"
	var minutes := int(seconds) / 60
	return "%d:%05.2f" % [minutes, seconds - float(minutes * 60)]
