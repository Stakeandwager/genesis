extends Node
class_name GameController

# --- 002F: every world takes one path ---
# CREATE_TRACK with "sections" and CREATE_FARM are both world modules
# (racing_module.gd, farm_module.gd), found in the WorldRegistry and run
# through _create_world(). Racing's checks, solver, closure feedback and
# record fields all live in its module now; nothing here is racing-specific.
# CREATE_TRACK without "sections" still builds the Prototype 001 ring,
# so everything that worked in 001 keeps working.
#
# --- 002C: closure feedback ---
# When a module says a failed design can be corrected (racing: it does not
# close), the AI is told what Godot measured and asked once for a
# correction, through revision_requested. AI designs only, first attempts
# only, never inside a plan.
#
# The AI proposes. Godot constructs. Godot validates. Godot measures.

signal log_message(text: String)
# Emitted for every composed-track attempt, successful or not.
signal track_measured(record: Dictionary)
# Emitted after a first attempt fails closure and may be corrected once.
signal revision_requested(feedback: String, record: Dictionary)
# 004: a tool spec was accepted. The car picks this up so a change applies
# to the car already on the track, not only to the next one built.
signal equipped(tool_name: String, spec: Dictionary)

var track_builder: TrackBuilder
var opponent_builder: OpponentBuilder
var world_node: Node3D
# The surface a car can drive on in the current world, if it has one:
# {"node": the built node, "road_height": metres}. See drivable_surface().
var drivable: Dictionary = {}
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
var current_request := ""
var current_raw := ""
# Who produced the command, and with what settings (model, prompt version...).
var current_source: Dictionary = {}
# Which experiment run and trial this command belongs to, if any.
var current_experiment: Dictionary = {}
# Which attempt this is: {"attempt": 1}, or {"attempt": 2, "revision_of": {...}}.
var current_attempt: Dictionary = {}
# 003: the line Genesis showed the player before building this, generated
# from the structured command. Kept beside the request, never instead of it:
# what the player SAID, what Genesis UNDERSTOOD and what Genesis BUILT are
# three different things and must never become one field.
var current_readback := ""
# 003 Stage 2: the id this request's record will carry, made before the
# record exists so that the readback shown to the player can be pointed at
# by evidence that only arrives later - a "yes", a correction, a drive.
var current_record_id := ""

# --- 004: what the player is equipped with ---
# Every tool starts at its free default, so a player who never asks for
# anything drives exactly the car Genesis has always given them. EQUIP
# replaces an entry; nothing else can.
var kit: Dictionary = ToolRegistry.free_kit()
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
		"CREATE_TRACK" when not parameters.has("sections"):
			# The Prototype 001 ring. Composed circuits are a world module.
			_clear_world_node()
			_restore_view()
			opponent_builder.clear()
			log_message.emit(track_builder.build(parameters))
		"MODIFY_TRACK":
			if has_drivable():
				log_message.emit("MODIFY_TRACK failed: composed tracks are changed with MODIFY_SECTION, which comes in a later step")
				return
			_modify_track(parameters)
		"SPAWN_OPPONENTS":
			if has_drivable():
				log_message.emit("SPAWN_OPPONENTS failed: opponents on composed tracks come in a later step")
				return
			_spawn_opponents(parameters)
		"EQUIP":
			_equip(parameters)
		"PLAN":
			_execute_plan(parameters)
		"CLEAR_WORLD":
			last_build = {}
			track_builder.clear()
			opponent_builder.clear()
			_clear_world_node()
			_restore_view()
			log_message.emit("CLEAR_WORLD")
		_:
			var module := WorldRegistry.find(command)
			if module:
				_create_world(module, parameters)
			else:
				log_message.emit("No handler for: " + command)


# --- 004: asking for a tool ---
# The same shape as building a world: validate, record, apply, say what
# happened. A spec outside the limits is refused with its reasons, exactly
# as an unclosable circuit is, and the player keeps the tool they had.
func _equip(parameters: Dictionary) -> void:
	var record := {
		"time": Time.get_datetime_string_from_system(),
		"request": current_request,
		"raw_command": current_raw,
		"source": current_source,
		"experiment": current_experiment,
		"readback": current_readback,
		"understanding": "UNKNOWN",
		"id": current_record_id if current_record_id != "" else TrackLog.next_id(),
		"command": "EQUIP",
		"tool": str(parameters.get("tool", "")),
		"proposed_spec": parameters.get("spec", {}),
	}

	var tool := ToolRegistry.find(str(parameters.get("tool", "")))
	if tool == null:
		_finish_failed(record, "FAILED_SCHEMA", [
			"this game has no tool called '%s' (it has %s)" % [
				str(parameters.get("tool", "")), ", ".join(ToolRegistry.names())]])
		return

	var checked := tool.validate(parameters)
	if not bool(checked["ok"]):
		_finish_failed(record, "FAILED_SCHEMA", checked["errors"])
		return

	var spec: Dictionary = checked["spec"]
	kit[tool.name()] = spec
	record["spec"] = spec
	record["result"] = "VALID"
	record["construction"] = "BUILT"
	record["category"] = ""
	record["reasons"] = []
	record["metrics"] = {}
	TrackLog.append(record)
	track_measured.emit(record)
	equipped.emit(tool.name(), spec)
	log_message.emit(tool.summary(spec))


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
		"readback": current_readback,
		"understanding": "UNKNOWN",
		"id": current_record_id if current_record_id != "" else TrackLog.next_id(),
		"command": "",
		"attempt": int(current_attempt.get("attempt", 1)),
		"result": "FAILED",
		"construction": "UNSUPPORTED" if category == "UNSUPPORTED" else "FAILED",
		"category": category,
		"reasons": [reason],
	}
	if current_attempt.has("revision_of"):
		record["revision_of"] = current_attempt["revision_of"]
	TrackLog.append(record)
	track_measured.emit(record)


# --- corrections ---

# One correction, only for AI designs, only for a first attempt, and only
# outside plans (a plan would need the whole plan re-proposed).
func _may_revise(record: Dictionary) -> bool:
	return revision_enabled \
		and not plan_running \
		and int(record.get("attempt", 1)) == 1 \
		and str(current_source.get("source", "")) == "ai"


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
		"readback": current_readback,
		"understanding": "UNKNOWN",
		"id": current_record_id if current_record_id != "" else TrackLog.next_id(),
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
	_clear_world_node()
	plan_running = true
	plan_bounds_min = Vector2(INF, INF)
	plan_bounds_max = Vector2(-INF, -INF)
	plan_footprints = []
	plan_problems = []

	# --- 003: work every world out, fit them together, THEN build ---
	# Until now a plan built each world as it went, so a world asked to
	# contain another only found out how big that other world was after both
	# existed, and a plan could fail by six metres of grass. Now nothing is
	# built until every size is known and the containers have been grown.
	var done := PackedStringArray()

	# Pass 1: work out each world. Nothing is built.
	var prepared: Array = []
	for i in steps.size():
		var step: Dictionary = steps[i]
		var step_command := str(step["command"]).to_upper()
		var step_parameters: Dictionary = step.get("parameters", {})
		var module := WorldRegistry.find(step_command)
		if module == null:
			# Not a world (CLEAR_WORLD, the Prototype 001 ring): nothing to
			# work out in advance, so it is run in order during pass 3.
			prepared.append({})
			continue
		var out := _prepare_world(module, step_parameters)
		if not bool(out["ok"]):
			plan_problems.append("step %d could not be worked out" % (i + 1))
			prepared.append({})
			continue
		out["module"] = module
		out["parameters"] = step_parameters
		prepared.append(out)

	# Pass 2: make the containers big enough.
	var fitted: Array = []
	if plan_problems.is_empty():
		fitted = _fit_plan(steps, prepared)
		if not fitted.is_empty():
			record["fitted"] = fitted

	# Pass 3: build, in the order the AI gave.
	if plan_problems.is_empty():
		for i in steps.size():
			var step: Dictionary = steps[i]
			var step_command := str(step["command"]).to_upper()
			var step_parameters: Dictionary = step.get("parameters", {})
			plan_pending = step
			var out: Dictionary = prepared[i]
			if out.is_empty():
				execute(step_command, step_parameters)
			else:
				_build_world(out["module"], out["parameters"], out["layout"], out["record"])
			plan_pending = {}
			done.append(step_command)

	plan_running = false

	# A plan that never got built still leaves its worlds in the record, with
	# a valid proposal and no construction. History is added to, not rewritten.
	if not plan_problems.is_empty():
		for out in prepared:
			var o: Dictionary = out
			if o.is_empty() or not o.has("record"):
				continue
			var step_record: Dictionary = o["record"]
			step_record["construction"] = "FAILED"
			step_record["category"] = "FAILED_SCENE"
			step_record["reasons"] = plan_problems
			TrackLog.append(step_record)
			track_measured.emit(step_record)

	if not plan_problems.is_empty():
		track_builder.clear()
		opponent_builder.clear()
		_clear_world_node()
		_finish_failed(record, "FAILED_SCENE", plan_problems)
		return

	if plan_bounds_min.x < INF:
		_frame_view(plan_bounds_min, plan_bounds_max)

	record["result"] = "VALID"
	record["construction"] = "BUILT"
	record["category"] = ""
	record["reasons"] = []
	record["steps"] = done
	last_build = {"command": "PLAN", "parameters": parameters, "metrics": {}, "request": current_request}
	TrackLog.append(record)

	var lines := PackedStringArray()
	lines.append("Plan built in %d steps: %s" % [done.size(), ", ".join(done)])
	for note in fitted:
		var n: Dictionary = note
		lines.append("%s grown to %.0f by %.0f m so the %s fits inside it" % [
			str(n["world"]).capitalize(), float(n["to_width"]), float(n["to_depth"]), str(n["inner"])])
	log_message.emit("\n".join(lines))


# Where a world sits within a plan. The AI says what it wants - beside, or
# around an earlier world - and this works out the actual position, then
# checks the result holds together. The AI never supplies coordinates.
const SCENE_CLEARANCE := 15.0
# No world may be grown past this. A container grows to fit what it holds,
# and a huge circuit inside a small farm would otherwise ask for kilometres
# of fence that this machine cannot draw.
const PLAN_MAX_EXTENT := 2000.0


# --- 003: fitting a plan together before anything is built ---
# The player says what they want related to what. They do not know, and
# should not have to know, that their farm comes out 430 m across and their
# circuit 412 m - six metres a side short of holding it. So Genesis measures
# both and grows whichever one is the container.
#
# "around": N centres two worlds on each other. One must then contain the
# other with SCENE_CLEARANCE to spare. If neither does, the bigger one is
# asked to grow; if it cannot (a circuit's shape IS the design, so it never
# can), the smaller one is asked to contain the bigger instead, which is the
# same relationship seen from the other side.
#
# Every growth is recorded. Godot changing what the AI proposed is drift, and
# drift is measured here as it is everywhere else.
func _fit_plan(steps: Array, prepared: Array) -> Array:
	var notes: Array = []
	for i in steps.size():
		var out: Dictionary = prepared[i]
		if out.is_empty():
			continue
		var around := WorldRegistry.around_of(steps[i])
		if around < 1 or around > prepared.size() or around - 1 == i:
			continue
		var other: Dictionary = prepared[around - 1]
		if other.is_empty():
			continue

		var a: WorldModule = out["module"]
		var b: WorldModule = other["module"]
		var size_a: Vector2 = a.extent(out["layout"])
		var size_b: Vector2 = b.extent(other["layout"])
		if _holds(size_a, size_b) or _holds(size_b, size_a):
			continue

		# Try the bigger one as the container, then the smaller one.
		var order: Array = [[a, out, size_a, b, other, size_b], [b, other, size_b, a, out, size_a]]
		if size_b.x * size_b.y > size_a.x * size_a.y:
			order.reverse()

		var grew := false
		for attempt in order:
			var outer: WorldModule = attempt[0]
			var outer_out: Dictionary = attempt[1]
			var outer_size: Vector2 = attempt[2]
			var inner: WorldModule = attempt[3]
			var inner_size: Vector2 = attempt[5]
			var needed := inner_size + Vector2(SCENE_CLEARANCE, SCENE_CLEARANCE) * 2.0
			var target := Vector2(maxf(outer_size.x, needed.x), maxf(outer_size.y, needed.y))
			if target.x > PLAN_MAX_EXTENT or target.y > PLAN_MAX_EXTENT:
				continue
			if not outer.grow_to(outer_out["layout"], target):
				continue
			var now: Vector2 = outer.extent(outer_out["layout"])
			notes.append({
				"world": outer.display_name(),
				"inner": inner.display_name(),
				"from_width": outer_size.x, "from_depth": outer_size.y,
				"to_width": now.x, "to_depth": now.y,
			})
			grew = true
			break

		if not grew:
			plan_problems.append(
				"%s is %.0f by %.0f m and %s is %.0f by %.0f m: neither can be made to hold the other" % [
					a.display_name(), size_a.x, size_a.y, b.display_name(), size_b.x, size_b.y])
	return notes


# Does a world this size hold one that size, with room to spare, when the two
# are centred on each other?
func _holds(outer: Vector2, inner: Vector2) -> bool:
	return outer.x >= inner.x + SCENE_CLEARANCE * 2.0 and outer.y >= inner.y + SCENE_CLEARANCE * 2.0


func _place(node: Node3D, bounds_min: Vector2, bounds_max: Vector2) -> void:
	var step := plan_pending
	var centre := (bounds_min + bounds_max) * 0.5
	var offset := Vector2.ZERO

	# 003: one reading, shared with the readback, so the line the player was
	# shown and the placement they get can never disagree.
	var around := WorldRegistry.around_of(step)
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


# Every world: racing circuits, farms, and whatever comes next. The module
# owns the rules, the layout, the measurements and the geometry, so adding a
# kind of world changes nothing here. The optional steps (pre_check, solve_record,
# correction_feedback, post_check, summary) do nothing unless a module
# provides them.
func _create_world(module: WorldModule, parameters: Dictionary) -> void:
	var prepared := _prepare_world(module, parameters)
	if not bool(prepared["ok"]):
		return
	_build_world(module, parameters, prepared["layout"], prepared["record"])


# --- 003: working a world out, without building it ---
# Everything up to but not including geometry: validate, check, solve, check
# again, measure. A plan runs this for EVERY step before it builds any of
# them, because a world asked to contain another cannot know how much room to
# leave until the thing going inside it has been measured.
#
# Returns {"ok", "record", "layout"}. A failure writes its own record and
# announces itself exactly as it always did.
func _prepare_world(module: WorldModule, parameters: Dictionary) -> Dictionary:
	var record := {
		"time": Time.get_datetime_string_from_system(),
		"request": current_request,
		"raw_command": current_raw,
		"source": current_source,
		"experiment": current_experiment,
		"readback": current_readback,
		"understanding": "UNKNOWN",
		"id": current_record_id if current_record_id != "" else TrackLog.next_id(),
	}
	record.merge(module.record_fields(parameters, current_attempt))

	var check := module.validate(parameters)
	if not check["ok"]:
		_finish_failed(record, "FAILED_SCHEMA", check["errors"])
		return {"ok": false}

	var pre := module.pre_check(check["content"], record)
	if not pre["ok"]:
		_finish_failed(record, pre["category"], pre["reasons"])
		return {"ok": false}

	var solved := module.solve(pre["content"])
	record.merge(module.solve_record(solved))
	if not solved["ok"]:
		var feedback := module.correction_feedback(solved)
		var may_revise := feedback != "" and _may_revise(record)
		if may_revise:
			# Recorded, but not the final word: a correction is on its way.
			record["revision_pending"] = true
		_finish_failed(record, solved["category"], solved["reasons"])
		if may_revise:
			revision_requested.emit(feedback, record)
		return {"ok": false}

	var post := module.post_check(solved["layout"])
	record.merge(post["record"])
	if not post["ok"]:
		_finish_failed(record, post["category"], post["reasons"])
		return {"ok": false}

	record["metrics"] = module.measure(solved["layout"])
	# The PROPOSAL is valid. Whether anything gets built is a separate
	# question, answered later and recorded in its own field.
	record["result"] = "VALID"
	record["category"] = ""
	record["reasons"] = []
	return {"ok": true, "record": record, "layout": solved["layout"]}


# --- 003: building a world that has already been worked out ---
func _build_world(module: WorldModule, parameters: Dictionary, layout: Dictionary, record: Dictionary) -> void:
	record["construction"] = "BUILT"
	if not plan_running:
		last_build = {"command": module.command(), "parameters": parameters, "metrics": record["metrics"], "request": current_request}

	var holder := world_node
	if plan_running:
		# Keep whatever earlier steps built: this world gets its own node.
		holder = Node3D.new()
		holder.name = module.display_name().capitalize()
		world_node.add_child(holder)
	else:
		# A new world replaces whatever was there, whichever kind it was.
		track_builder.clear()
		opponent_builder.clear()
		_clear_world_node()

	var report := module.build(holder, layout)
	if plan_running:
		_place(holder, report["bounds_min"], report["bounds_max"])
	else:
		_frame_view(report["bounds_min"], report["bounds_max"])
	# In a plan, the last world that can be driven is the one driven.
	if report.has("drivable"):
		drivable = report["drivable"]

	TrackLog.append(record)
	track_measured.emit(record)

	log_message.emit(module.summary(record["metrics"], report))


func _clear_world_node() -> void:
	drivable = {}
	if world_node == null:
		return
	for child in world_node.get_children():
		child.queue_free()


# A world built without a request: nothing recorded, nothing to save, and the
# AI is not shown it as the player's world. Main uses this for the small
# circuit that is there to drive before anything has been asked for.
func show_unrecorded(module: WorldModule, layout: Dictionary) -> void:
	track_builder.clear()
	opponent_builder.clear()
	_clear_world_node()
	var report := module.build(world_node, layout)
	_frame_view(report["bounds_min"], report["bounds_max"])
	if report.has("drivable"):
		drivable = report["drivable"]


# --- driving ---
# Driving and racing reach the world only through here, so any world whose
# module reports a drivable surface can be driven.

func has_drivable() -> bool:
	return not drivable.is_empty() and is_instance_valid(drivable["node"]) and bool(drivable["node"].built)


# Where the car goes, in world space: a plan may have moved the world (a
# track around a farm), so the node's own numbers are converted.
# Returns {} when there is nothing to drive, otherwise start_position,
# start_heading (radians, 0 is the start direction), centreline and
# road_height.
func drivable_surface() -> Dictionary:
	if not has_drivable():
		return {}
	var node: Node3D = drivable["node"]
	var line := PackedVector3Array()
	for p in node.centreline:
		line.append(node.to_global(p))
	return {
		"start_position": node.to_global(node.start_position),
		"start_heading": float(node.start_heading),
		"centreline": line,
		"road_height": float(drivable["road_height"]),
	}


func _finish_failed(record: Dictionary, category: String, reasons: Array) -> void:
	record["result"] = "FAILED"
	# 003: what actually happened in the game, kept apart from whether the
	# proposal was valid and from whether the player was understood. A plan
	# that fails is rolled back whole, so there is no PARTIAL to record: the
	# value stays unused until the engine can keep what worked.
	record["construction"] = "FAILED"
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
