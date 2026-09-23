extends Node
class_name GameController

# --- Prototype 002A - Step A7 ---
# CREATE_TRACK with "sections" is validated, checked for feasibility, closed by
# the solver, checked for road separation, measured, recorded, then built.
# CREATE_TRACK without "sections" still builds the Prototype 001 ring,
# so everything that worked in 001 keeps working.
#
# The AI proposes. Godot constructs. Godot validates. Godot measures.

signal log_message(text: String)
# Emitted for every composed-track attempt, successful or not.
signal track_measured(record: Dictionary)

var track_builder: TrackBuilder
var opponent_builder: OpponentBuilder
var circuit_builder: CircuitBuilder

# Set by main before each command, so the record says what was asked for.
var current_request := ""
var current_raw := ""
# Who produced the command, and with what settings (model, prompt version...).
var current_source: Dictionary = {}

# Composed tracks can be much bigger than the original ground and camera view,
# so they are resized to fit, and restored for the Prototype 001 ring.
var camera: Camera3D
var ground_box: CSGBox3D
var original_camera_transform: Transform3D
var original_camera_far := 4000.0
var original_camera_near := 0.05
var original_ground_size := Vector3(200.0, 1.0, 200.0)
var original_ground_position := Vector3(0.0, -0.5, 0.0)


func setup(world_root: Node3D) -> void:
	track_builder = TrackBuilder.new()
	track_builder.name = "TrackBuilder"
	world_root.add_child(track_builder)

	opponent_builder = OpponentBuilder.new()
	opponent_builder.name = "OpponentBuilder"
	world_root.add_child(opponent_builder)

	circuit_builder = CircuitBuilder.new()
	circuit_builder.name = "CircuitBuilder"
	world_root.add_child(circuit_builder)

	camera = world_root.get_node_or_null("Camera3D") as Camera3D
	if camera:
		original_camera_transform = camera.transform
		original_camera_far = camera.far
		original_camera_near = camera.near

	ground_box = world_root.get_node_or_null("Ground/CSGBox3D") as CSGBox3D
	if ground_box:
		original_ground_size = ground_box.size
		original_ground_position = ground_box.position


func execute(command: String, parameters: Dictionary) -> void:
	match command:
		"CREATE_TRACK":
			if parameters.has("sections"):
				_create_composed_track(parameters)
			else:
				circuit_builder.clear()
				_restore_view()
				opponent_builder.clear()
				log_message.emit(track_builder.build(parameters))
		"MODIFY_TRACK":
			if circuit_builder.built:
				log_message.emit("MODIFY_TRACK failed: composed tracks are changed with MODIFY_SECTION, which comes in a later step")
				return
			_modify_track(parameters)
		"SPAWN_OPPONENTS":
			if circuit_builder.built:
				log_message.emit("SPAWN_OPPONENTS failed: opponents on composed tracks come in a later step")
				return
			_spawn_opponents(parameters)
		"CLEAR_WORLD":
			track_builder.clear()
			opponent_builder.clear()
			circuit_builder.clear()
			_restore_view()
			log_message.emit("CLEAR_WORLD")
		_:
			log_message.emit("No handler for: " + command)


# --- the composition pipeline ---

func _create_composed_track(parameters: Dictionary) -> void:
	var intent = parameters.get("intent", {})
	var record := {
		"time": Time.get_datetime_string_from_system(),
		"request": current_request,
		"raw_command": current_raw,
		"source": current_source,
		"intent": intent if typeof(intent) == TYPE_DICTIONARY else {},
		"proposed_sections": parameters.get("sections", []),
	}

	# Step A1: every piece must be a legal piece.
	var check := SectionValidator.validate(parameters)
	if not check["ok"]:
		_finish_failed(record, "FAILED_SCHEMA", check["errors"])
		return

	record["proposed_metrics"] = TrackMetrics.measure(check["sections"])

	# Step A3: refuse compositions that could never close, before building anything.
	var gate := FeasibilityGate.check(check["sections"])
	record["feasibility"] = {
		"net_turn": gate["net_turn"],
		"reachable_min": gate["reachable_min"],
		"reachable_max": gate["reachable_max"],
		"target_turn": gate["target_turn"],
	}
	if not gate["ok"]:
		_finish_failed(record, gate["category"], gate["reasons"])
		return

	# Step A4: close the circuit, within the permitted adjustment.
	var solved := ClosureSolver.solve(check["sections"], gate["target_turn"])
	record["closure"] = {
		"closure_distance": solved["closure_distance"],
		"closure_heading_error": solved["closure_heading_error"],
		"distance_tolerance": solved["distance_tolerance"],
		"heading_tolerance": solved["heading_tolerance"],
		"iterations": solved["iterations"],
	}
	record["drift"] = {
		"max_angle_adjustment": solved["max_angle_adjustment"],
		"max_length_adjustment": solved["max_length_adjustment"],
		"angle_limit": solved["angle_limit"],
		"length_limit": solved["length_limit"],
		"proposed_net_turn": solved["proposed_net_turn"],
		"final_net_turn": solved["final_net_turn"],
	}
	if not solved["ok"]:
		_finish_failed(record, solved["category"], [
			"best attempt ends %.1f m from the start, heading off by %.1f deg" % [solved["closure_distance"], solved["closure_heading_error"]],
			"closed means within %.1f m and %.0f deg" % [solved["distance_tolerance"], solved["heading_tolerance"]],
			"adjustment used: corners up to %.1f%%, straights up to %.1f%% (limit %.0f%%)" % [solved["max_angle_adjustment"] * 100.0, solved["max_length_adjustment"] * 100.0, solved["angle_limit"] * 100.0],
		])
		return

	record["final_sections"] = solved["sections"]

	# Step A5: a closed track must not cross itself or run into itself.
	var separation := SeparationCheck.check(solved["sections"])
	record["separation"] = {
		"minimum_separation": _finite(separation["minimum_separation"]),
		"required_separation": separation["required_separation"],
		"self_intersections": separation["self_intersections"],
	}
	if not separation["ok"]:
		_finish_failed(record, separation["category"], separation["reasons"])
		return

	# Valid: measure the final geometry, build it, and record it.
	record["metrics"] = TrackMetrics.measure(solved["sections"])
	record["result"] = "VALID"
	record["category"] = ""
	record["reasons"] = []

	track_builder.clear()
	opponent_builder.clear()
	var report := circuit_builder.build(solved["sections"], false)
	_frame_view(report["bounds_min"], report["bounds_max"])

	TrackLog.append(record)
	track_measured.emit(record)

	var direction := "clockwise" if gate["target_turn"] > 0.0 else "anticlockwise"
	log_message.emit(
		"CREATE_TRACK built a closed %s circuit: %d sections, %.0f m of road\n(full measurements in the metrics panel)"
		% [direction, report["section_count"], report["total_length"]]
	)


func _finish_failed(record: Dictionary, category: String, reasons: Array) -> void:
	record["result"] = "FAILED"
	record["category"] = category
	record["reasons"] = reasons
	TrackLog.append(record)
	track_measured.emit(record)

	var lines := PackedStringArray()
	lines.append("CREATE_TRACK failed: %s" % category)
	for reason in reasons:
		lines.append("- " + str(reason))
	lines.append("no geometry built")
	log_message.emit("\n".join(lines))


# JSON can't hold infinity, so "nothing measured" is stored as -1.
func _finite(value: float) -> float:
	return value if is_finite(value) else -1.0


# --- view ---

# The command panel covers the bottom of the screen and the history and metrics
# panels cover the right, so the track is framed into the space that's left:
# the camera aims slightly right of and nearer than the track's centre, which
# shifts the track left and up on screen.
func _frame_view(bounds_min: Vector2, bounds_max: Vector2) -> void:
	var centre := Vector3((bounds_min.x + bounds_max.x) * 0.5, 0.0, (bounds_min.y + bounds_max.y) * 0.5)
	var span := maxf(bounds_max.x - bounds_min.x, bounds_max.y - bounds_min.y) + 40.0

	if ground_box:
		var size := maxf(original_ground_size.x, span * 2.2)
		ground_box.size = Vector3(size, original_ground_size.y, size)
		ground_box.position = Vector3(centre.x, original_ground_position.y, centre.z)

	if camera:
		camera.far = maxf(original_camera_far, span * 4.0)
		# Pushing the near plane out as the camera pulls back keeps depth
		# precision high, so the road never sinks into the ground on older GPUs.
		camera.near = clampf(span * 0.02, original_camera_near, 20.0)
		var aim := centre + Vector3(span * FRAME_SHIFT_RIGHT, 0.0, span * FRAME_SHIFT_NEAR)
		camera.look_at_from_position(aim + Vector3(0.0, span * FRAME_HEIGHT, span * FRAME_DISTANCE), aim, Vector3.UP)


const FRAME_HEIGHT := 0.80
const FRAME_DISTANCE := 0.62
const FRAME_SHIFT_RIGHT := 0.22
const FRAME_SHIFT_NEAR := 0.12


func _restore_view() -> void:
	if camera:
		camera.transform = original_camera_transform
		camera.far = original_camera_far
		camera.near = original_camera_near
	if ground_box:
		ground_box.size = original_ground_size
		ground_box.position = original_ground_position


# --- Prototype 001 paths ---

func _modify_track(parameters: Dictionary) -> void:
	var corner: int = int(parameters.get("corner", 1))
	var difficulty: String = str(parameters.get("difficulty", "medium"))
	log_message.emit(track_builder.modify_corner(corner, difficulty))


func _spawn_opponents(parameters: Dictionary) -> void:
	if not track_builder.has_track():
		log_message.emit("SPAWN_OPPONENTS failed: build a track first")
		return

	var count: int = int(parameters.get("count", 1))
	log_message.emit(opponent_builder.spawn(
		count,
		track_builder.get_start_position(),
		track_builder.get_start_direction()
	))
