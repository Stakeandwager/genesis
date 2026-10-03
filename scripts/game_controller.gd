extends Node
class_name GameController

# --- Prototype 002B ---
# CREATE_TRACK with "sections" is validated, checked for feasibility, closed by
# the solver, checked for road separation, measured, recorded, then built.
# CREATE_TRACK without "sections" still builds the Prototype 001 ring,
# so everything that worked in 001 keeps working.
#
# --- 002C: closure feedback ---
# When an AI-designed circuit fails ONLY because it does not close, Godot
# tells the AI where its proposal actually ended and asks once for a
# correction. The correction goes through every check from the start. Both
# attempts are recorded, linked, with a comparison of the two designs.
#
# The AI proposes. Godot constructs. Godot validates. Godot measures.

signal log_message(text: String)
# Emitted for every composed-track attempt, successful or not.
signal track_measured(record: Dictionary)
# Emitted after a first attempt fails closure and may be corrected once.
signal revision_requested(feedback: String, record: Dictionary)

var track_builder: TrackBuilder
var opponent_builder: OpponentBuilder
var circuit_builder: CircuitBuilder
var world_node: Node3D
# While a plan is running, each step keeps what the earlier steps built.
var plan_running := false
var plan_bounds_min := Vector2(INF, INF)
var plan_bounds_max := Vector2(-INF, -INF)
# The footprint of each step, so a later step can be placed around an earlier one.
var plan_footprints: Array = []
var plan_pending: Dictionary = {}
var plan_problems: Array = []
# The description that made whatever is on screen now, so it can be saved.
var last_build: Dictionary = {}

# Set by main before each command, so the record says what was asked for.
# Set by main before each command, so the record says what was asked for.
var current_request := ""
var current_raw := ""
# Who produced the command, and with what settings (model, prompt version...).
var current_source: Dictionary = {}
# Which experiment run and trial this command belongs to, if any.
var current_experiment: Dictionary = {}
# Which attempt this is: {"attempt": 1}, or {"attempt": 2, "revision_of": {...}}.
var current_attempt: Dictionary = {}
# /revise off turns closure feedback off, for a like-for-like baseline.
var revision_enabled := true

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

	# Everything a world module builds lives under here.
	world_node = Node3D.new()
	world_node.name = "World"
	world_root.add_child(world_node)

	camera = world_root.get_node_or_null("Camera3D") as Camera3D
	if camera:
		original_camera_transform = camera.transform
		original_camera_far = camera.far
		original_camera_near = camera.near

	ground_box = world_root.get_node_or_null("Ground/CSGBox3D") as CSGBox3D
	if ground_box:
		original_ground_size = ground_box.size
		original_ground_position = ground_box.position

	log_message.emit("GameController successfully initialized and ready.")


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
		"PLAN":
			_execute_plan(parameters)
		"CLEAR_WORLD":
			last_build = {}
			track_builder.clear()
			opponent_builder.clear()
			circuit_builder.clear()
			_clear_world_node()
			_restore_view()
			log_message.emit("CLEAR_WORLD")
		_:
			var module := WorldRegistry.find(command)
			if module:
				_create_world(module, parameters)
			else:
				log_message.emit("No handler for: " + command)


# --- the composition pipeline ---

func _create_composed_track(parameters: Dictionary) -> void:
	var intent = parameters.get("intent", {})
	var record := {
		"time": Time.get_datetime_string_from_system(),
		"request": current_request,
		"raw_command": current_raw,
		"source": current_source,
		"experiment": current_experiment,
		"intent": intent if typeof(intent) == TYPE_DICTIONARY else {},
		"command": "CREATE_TRACK",
		"proposed_sections": parameters.get("sections", []),
		"attempt": int(current_attempt.get("attempt", 1)),
	}
	if current_attempt.has("revision_of"):
		record["revision_of"] = current_attempt["revision_of"]

	# Step A1: every piece must be a legal piece.
	var check := SectionValidator.validate(parameters)
	if not check["ok"]:
		_finish_failed(record, "FAILED_SCHEMA", check["errors"])
		return

	record["proposed_metrics"] = TrackMetrics.measure(check["sections"])
	if record.has("revision_of"):
		record["revision_comparison"] = _compare_designs(record["revision_of"].get("proposed_metrics", {}), record["proposed_metrics"])

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
		"remaining_ahead": solved["remaining_ahead"],
		"remaining_right": solved["remaining_right"],
		"proposal": solved["proposal"],
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
		var may_revise := _may_revise(record)
		if may_revise:
			# Recorded, but not the final word: a correction is on its way.
			record["revision_pending"] = true
		_finish_failed(record, solved["category"], [
			"best attempt ends %.1f m from the start, heading off by %.1f deg" % [solved["closure_distance"], solved["closure_heading_error"]],
			"closed means within %.1f m and %.0f deg" % [solved["distance_tolerance"], solved["heading_tolerance"]],
			"adjustment used: corners up to %.1f%%, straights up to %.1f%% (limit %.0f%%)" % [solved["max_angle_adjustment"] * 100.0, solved["max_length_adjustment"] * 100.0, solved["angle_limit"] * 100.0],
		])
		if may_revise:
			revision_requested.emit(_closure_feedback(solved), record)
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
	if not plan_running:
		last_build = {"command": "CREATE_TRACK", "parameters": parameters, "metrics": record["metrics"], "request": current_request}
	record["category"] = ""
	record["reasons"] = []

	track_builder.clear()
	opponent_builder.clear()
	var report := circuit_builder.build(solved["sections"], false)
	if plan_running:
		_place(circuit_builder, report["bounds_min"], report["bounds_max"])
	else:
		circuit_builder.position = Vector3.ZERO
		_frame_view(report["bounds_min"], report["bounds_max"])

	TrackLog.append(record)
	track_measured.emit(record)

	var direction := "clockwise" if gate["target_turn"] > 0.0 else "anticlockwise"
	log_message.emit(
		"CREATE_TRACK built a closed %s circuit: %d sections, %.0f m of road\n(full measurements in the metrics panel)"
		% [direction, report["section_count"], report["total_length"]]
	)


# --- answers that never became a command ---

# The AI's answer was refused before it reached any world: not valid JSON,
# not a whitelisted command, or the AI saying it can't do this. That is a
# result too, so it is logged and announced like any other attempt. Without
# this, an experiment would wait forever for a result that never came.
func record_rejection(category: String, reason: String) -> void:
	var record := {
		"time": Time.get_datetime_string_from_system(),
		"request": current_request,
		"raw_command": current_raw,
		"source": current_source,
		"experiment": current_experiment,
		"command": "",
		"attempt": int(current_attempt.get("attempt", 1)),
		"result": "FAILED",
		"category": category,
		"reasons": [reason],
	}
	if current_attempt.has("revision_of"):
		record["revision_of"] = current_attempt["revision_of"]
	TrackLog.append(record)
	track_measured.emit(record)


# --- closure feedback ---

# One correction, only for AI designs, only for a first attempt, and only
# outside plans (a plan would need the whole plan re-proposed).
func _may_revise(record: Dictionary) -> bool:
	return revision_enabled \
		and not plan_running \
		and int(record.get("attempt", 1)) == 1 \
		and str(current_source.get("source", "")) == "ai"


# What the AI is told. Plain facts Godot measured; no advice about style.
func _closure_feedback(solved: Dictionary) -> String:
	var p: Dictionary = solved["proposal"]
	var lines := PackedStringArray()
	lines.append("Godot measured your circuit and it does not close.")
	lines.append("")
	lines.append("Measured from the start line, your sections as proposed end %s and %s%s." % [
		_along(float(p["ahead"])), _across(float(p["right"])), _above(float(p["height"]))])
	lines.append("They end %.0f m from the start line. A closed circuit must end exactly on it." % float(p["distance"]))
	lines.append("Your sections turn a total of %+.0f degrees. A closed circuit must turn exactly %+.0f degrees." % [float(p["net_turn"]), float(p["target_turn"])])
	lines.append("Even after the game adjusted every corner and straight by up to %.0f%%, the track still ended %.0f m from the start line, and it must be within %.0f m." % [
		float(solved["angle_limit"]) * 100.0, float(solved["closure_distance"]), float(solved["distance_tolerance"])])
	lines.append("")
	lines.append("Where each of your sections ends, in metres from the start line (ahead is along the start direction, negative means behind; right is to the right of it, negative means left), and which way the track faces there (0 is the start direction, positive is clockwise):")
	for e in p["section_ends"]:
		lines.append("  %d %s: ahead %.0f, right %.0f, facing %.0f" % [int(e["section"]), str(e["type"]), float(e["ahead"]), float(e["right"]), float(e["facing"])])
	lines.append("")
	lines.append("Revise the sections so the circuit closes by itself: it must end on the start line, facing the start direction. Keep everything else about your design that you can. Return ONLY the complete JSON command, in the same format as before.")
	return "\n".join(lines)


func _along(ahead: float) -> String:
	if absf(ahead) < 0.5:
		return "level with the start line"
	return "%.0f m past the start line" % ahead if ahead > 0.0 else "%.0f m short of the start line" % -ahead


func _across(right: float) -> String:
	if absf(right) < 0.5:
		return "directly in line with it"
	return "%.0f m to its right" % right if right > 0.0 else "%.0f m to its left" % -right


func _above(height: float) -> String:
	if absf(height) < 1.0:
		return ""
	return ", %.0f m %s it" % [absf(height), "above" if height > 0.0 else "below"]


# Did the correction keep the design, or replace it with something simpler?
# Compares the two proposals, not the built tracks, so a refused correction
# can be compared too.
func _compare_designs(before: Dictionary, after: Dictionary) -> Dictionary:
	if before.is_empty() or after.is_empty():
		return {}
	var before_counts: Dictionary = before.get("counts", {})
	var after_counts: Dictionary = after.get("counts", {})
	var type_changes := {}
	for key in before_counts:
		var change := int(after_counts.get(key, 0)) - int(before_counts[key])
		if change != 0:
			type_changes[key] = change
	var before_length := float(before.get("total_length", 0.0))
	var before_turning := float(before.get("direction_change_total", 0.0))
	return {
		"sections_before": int(before.get("section_count", 0)),
		"sections_after": int(after.get("section_count", 0)),
		"length_before": before_length,
		"length_after": float(after.get("total_length", 0.0)),
		"length_ratio": float(after.get("total_length", 0.0)) / before_length if before_length > 0.0 else 0.0,
		"turning_before": before_turning,
		"turning_after": float(after.get("direction_change_total", 0.0)),
		"type_changes": type_changes,
		"same_piece_counts": type_changes.is_empty(),
	}


# --- plans: several approved commands from one request ---
# A plan is not a new power. Every step is an ordinary command that goes
# through the same whitelist, the same validator and the same checks. The only
# new thing is that the worlds are placed beside each other instead of
# replacing one another.

const MAX_PLAN_STEPS := 4


func _execute_plan(parameters: Dictionary) -> void:
	var record := {
		"time": Time.get_datetime_string_from_system(),
		"request": current_request,
		"raw_command": current_raw,
		"source": current_source,
		"experiment": current_experiment,
		"command": "PLAN",
		"world": "plan",
		"intent": parameters.get("intent", {}),
	}

	var raw = parameters.get("steps", null)
	if typeof(raw) != TYPE_ARRAY:
		_finish_failed(record, "FAILED_SCHEMA", ["a plan needs a list of steps"])
		return

	var steps: Array = raw
	if steps.is_empty() or steps.size() > MAX_PLAN_STEPS:
		_finish_failed(record, "FAILED_SCHEMA", ["a plan needs 1 to %d steps (got %d)" % [MAX_PLAN_STEPS, steps.size()]])
		return

	# Check every step before doing any of them.
	var problems: Array = []
	for i in steps.size():
		var n := i + 1
		if typeof(steps[i]) != TYPE_DICTIONARY:
			problems.append("step %d is not an object" % n)
			continue
		var step: Dictionary = steps[i]
		var step_command := str(step.get("command", "")).to_upper()
		if step_command == "PLAN":
			problems.append("step %d: a plan may not contain another plan" % n)
		elif not step_command in CommandParser.allowed_commands():
			problems.append("step %d: '%s' is not a command this game has" % [n, step_command])
		if step.has("parameters") and typeof(step["parameters"]) != TYPE_DICTIONARY:
			problems.append("step %d: parameters must be an object" % n)

	if not problems.is_empty():
		_finish_failed(record, "FAILED_SCHEMA", problems)
		return

	# Clear once, then let each step add to the same scene.
	track_builder.clear()
	opponent_builder.clear()
	circuit_builder.clear()
	_clear_world_node()
	plan_running = true
	plan_bounds_min = Vector2(INF, INF)
	plan_bounds_max = Vector2(-INF, -INF)
	plan_footprints = []
	plan_problems = []

	var done := PackedStringArray()
	for i in steps.size():
		var step: Dictionary = steps[i]
		var step_command := str(step["command"]).to_upper()
		var step_parameters: Dictionary = step.get("parameters", {})
		plan_pending = step
		execute(step_command, step_parameters)
		plan_pending = {}
		done.append(step_command)

	plan_running = false

	if not plan_problems.is_empty():
		track_builder.clear()
		opponent_builder.clear()
		circuit_builder.clear()
		_clear_world_node()
		_finish_failed(record, "FAILED_SCENE", plan_problems)
		return

	if plan_bounds_min.x < INF:
		_frame_view(plan_bounds_min, plan_bounds_max)

	record["result"] = "VALID"
	record["category"] = ""
	record["reasons"] = []
	record["steps"] = done
	last_build = {"command": "PLAN", "parameters": parameters, "metrics": {}, "request": current_request}
	TrackLog.append(record)
	log_message.emit("Plan built in %d steps: %s" % [done.size(), ", ".join(done)])


# Where a world sits within a plan. The AI says what it wants - beside, or
# around an earlier world - and this works out the actual position, then
# checks the result holds together. The AI never supplies coordinates.
const SCENE_CLEARANCE := 15.0


func _place(node: Node3D, bounds_min: Vector2, bounds_max: Vector2) -> void:
	var step := plan_pending
	var centre := (bounds_min + bounds_max) * 0.5
	var offset := Vector2.ZERO

	var around := int(step.get("around", 0))
	if around >= 1 and around <= plan_footprints.size():
		# Centre this world on the one it is meant to surround.
		var target: Dictionary = plan_footprints[around - 1]
		var target_centre: Vector2 = (target["min"] + target["max"]) * 0.5
		offset = target_centre - centre
	elif typeof(step.get("offset", null)) == TYPE_DICTIONARY:
		var given: Dictionary = step["offset"]
		offset = Vector2(float(given.get("x", 0.0)), float(given.get("z", 0.0)))

	node.position = Vector3(offset.x, 0.0, offset.y)
	var placed_min := bounds_min + offset
	var placed_max := bounds_max + offset

	# Worlds must either stand clear of each other, or contain one another.
	var index := plan_footprints.size() + 1
	for i in plan_footprints.size():
		var other: Dictionary = plan_footprints[i]
		var other_min: Vector2 = other["min"]
		var other_max: Vector2 = other["max"]
		var overlaps: bool = placed_min.x < other_max.x and placed_max.x > other_min.x and placed_min.y < other_max.y and placed_max.y > other_min.y
		if not overlaps:
			continue
		var contains_other: bool = placed_min.x <= other_min.x - SCENE_CLEARANCE and placed_max.x >= other_max.x + SCENE_CLEARANCE and placed_min.y <= other_min.y - SCENE_CLEARANCE and placed_max.y >= other_max.y + SCENE_CLEARANCE
		var inside_other: bool = other_min.x <= placed_min.x - SCENE_CLEARANCE and other_max.x >= placed_max.x + SCENE_CLEARANCE and other_min.y <= placed_min.y - SCENE_CLEARANCE and other_max.y >= placed_max.y + SCENE_CLEARANCE
		if not contains_other and not inside_other:
			plan_problems.append("step %d overlaps step %d: they must stand apart, or one must be big enough to contain the other with %.0f m to spare" % [index, i + 1, SCENE_CLEARANCE])

	plan_footprints.append({"min": placed_min, "max": placed_max})
	plan_bounds_min = Vector2(minf(plan_bounds_min.x, placed_min.x), minf(plan_bounds_min.y, placed_min.y))
	plan_bounds_max = Vector2(maxf(plan_bounds_max.x, placed_max.x), maxf(plan_bounds_max.y, placed_max.y))


# Any world that is not a racing circuit. The module owns the rules, the
# layout, the measurements and the geometry, so adding a kind of world
# changes nothing here.
func _create_world(module: WorldModule, parameters: Dictionary) -> void:
	var intent = parameters.get("intent", {})
	var record := {
		"time": Time.get_datetime_string_from_system(),
		"request": current_request,
		"raw_command": current_raw,
		"source": current_source,
		"experiment": current_experiment,
		"world": module.display_name(),
		"intent": intent if typeof(intent) == TYPE_DICTIONARY else {},
		"command": module.command(),
		"proposed": parameters.get("zones", []),
	}

	var check := module.validate(parameters)
	if not check["ok"]:
		_finish_failed(record, "FAILED_SCHEMA", check["errors"])
		return

	var solved := module.solve(check["content"])
	if not solved["ok"]:
		_finish_failed(record, solved["category"], solved["reasons"])
		return

	record["metrics"] = module.measure(solved["layout"])
	record["result"] = "VALID"
	if not plan_running:
		last_build = {"command": module.command(), "parameters": parameters, "metrics": record["metrics"], "request": current_request}
	record["category"] = ""
	record["reasons"] = []

	var holder := world_node
	if plan_running:
		# Keep whatever earlier steps built: this world gets its own node.
		holder = Node3D.new()
		holder.name = module.display_name().capitalize()
		world_node.add_child(holder)
	else:
		track_builder.clear()
		opponent_builder.clear()
		circuit_builder.clear()
		_clear_world_node()

	var report := module.build(holder, solved["layout"])
	if plan_running:
		_place(holder, report["bounds_min"], report["bounds_max"])
	else:
		_frame_view(report["bounds_min"], report["bounds_max"])

	TrackLog.append(record)
	track_measured.emit(record)

	var metrics: Dictionary = record["metrics"]
	log_message.emit("%s built: %d zones across %.0f m by %.0f m\n(full measurements in the panel)" % [
		module.display_name().capitalize(), metrics["zone_count"], metrics["farm_width"], metrics["farm_depth"]])


func _clear_world_node() -> void:
	if world_node == null:
		return
	for child in world_node.get_children():
		child.queue_free()


func _finish_failed(record: Dictionary, category: String, reasons: Array) -> void:
	record["result"] = "FAILED"
	record["category"] = category
	record["reasons"] = reasons
	TrackLog.append(record)
	track_measured.emit(record)

	var lines := PackedStringArray()
	lines.append("%s failed: %s" % [str(record.get("command", "CREATE_TRACK")), category])
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
