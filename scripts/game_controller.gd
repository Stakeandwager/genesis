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
# 014: a character has somewhere to go. Main owns the body; the controller
# owns the record and decides, afterwards, whether it got there.
signal ordered(goal: Dictionary, marks: Array, holder: Node3D, thing: Node3D, pickup: int)
# 018: a door opened or shut, so the world can be rebuilt around whatever is
# standing in it.
signal door_changed(layout: Dictionary)

var track_builder: TrackBuilder
var opponent_builder: OpponentBuilder
var world_node: Node3D
# The surface a car can drive on in the current world, if it has one:
# {"node": the built node, "road_height": metres}. See drivable_surface().
var drivable: Dictionary = {}

# --- 008: the same arrangement for a world that is walked ---
# {"node": the built node, "entrance": where a body starts in that node's own
# coordinates, "heading": radians}. See standable_surface(). A world is walked
# because its module reports one, never because the controller knows what a
# dungeon is.
var standable: Dictionary = {}

# 014: the order waiting on an answer, and where the character was last seen.
# Only one at a time: a new order replaces the old one, because a player who
# says "no, the other room" means now.
var pending_order: Dictionary = {}
# The last order accepted and the last outcome written, kept so the ledger can
# be read back without parsing the log file.
# What the carrier says it tried to do, handed over by whoever owns the body.
# Attempts, never accomplishments: it goes into the record beside the verdict,
# never into it.
var last_attempts: Array = []
var last_order_record: Dictionary = {}
var last_outcome_record: Dictionary = {}
var npc_at := Vector3.INF
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
# 023: where a refusal denied something Genesis does, if it did. Set before
# record_rejection and cleared by it, so it belongs to one refusal and cannot
# leak onto the next.
var refusal_quarrels: Array = []

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
			_build_prototype_ring(parameters)
		"MODIFY_TRACK":
			_modify_track(parameters)
		"SPAWN_OPPONENTS":
			_spawn_opponents(parameters)
		"EQUIP":
			_equip(parameters)
		"ORDER":
			_order(parameters)
		"SHUT":
			_set_door(parameters, true)
		"OPEN":
			_set_door(parameters, false)
		"PLAN":
			_execute_plan(parameters)
		"CLEAR_WORLD":
			_clear_world()
		_:
			var module := WorldRegistry.find(command)
			if module:
				_create_world(module, parameters)
			else:
				# 033: unreachable from any legal input - CommandParser admits
				# only the commands above plus WorldRegistry's, and every one
				# of those has a case. It is a guard against a command added
				# to CORE_COMMANDS without a handler, labelled as one rather
				# than counted as a measurement (TRAPS 6). It records anyway,
				# because the day it does fire is the day somebody needs to
				# know it did.
				# 054: and that is now ASSERTED rather than stated.
				# controller_reach_test walks CommandParser.allowed_commands()
				# against the case list READ OFF this match statement, so a
				# twelfth command admitted without a case fails the suite; and
				# it hands execute() a command no case matches, which is the
				# one door this branch has, and reads the category back. A
				# guard nothing can reach is also a guard nothing can prove is
				# still wired in (TRAPS 47) - this one can be.
				_finish_nothing(_new_record(command), NO_HANDLER,
					"No handler for: " + command)


# --- 033: one reading of a record's own header ---
# The nine fields every ledger record opens with were written out in full in
# SIX places - _order, _set_door, _equip, _prepare_world, _execute_plan and
# record_rejection - and 033 was about to add four more. They agreed, and
# nothing was making them: TRAPS 16's shape, waiting for the release where
# one of them grows a field and the others do not. The id is the one that
# matters, because the understanding layer writes a later record pointing at
# it, so a record that invents its own id is a record nothing can be tied to.
#
# "command" is passed rather than read, because record_rejection writes the
# empty string on purpose (the AI's answer never became a command) and
# _prepare_world lets the module name itself through record_fields().
func _new_record(command: String) -> Dictionary:
	return {
		"time": Time.get_datetime_string_from_system(),
		"request": current_request,
		"raw_command": current_raw,
		"source": current_source,
		"experiment": current_experiment,
		"readback": current_readback,
		"understanding": "UNKNOWN",
		"id": current_record_id if current_record_id != "" else TrackLog.next_id(),
		"command": command,
	}


# --- 004: asking for a tool ---
# The same shape as building a world: validate, record, apply, say what
# happened. A spec outside the limits is refused with its reasons, exactly
# as an unclosable circuit is, and the player keeps the tool they had.
# --- 014: sending a character somewhere ---
# The same shape as equipping: validate against a whitelist, record, hand the
# work to something that can do it, say what was asked for. The difference is
# the last line of the record, which cannot be written yet.
#
# Every command before this one finished inside the frame that accepted it. A
# world was built or refused; a tool was equipped or refused. An order is the
# first thing Genesis accepts without knowing how it ends, so its record is
# written PENDING and a second record resolves it later - the same arrangement
# the understanding layer uses, where a later record judges an earlier one and
# never edits it.
func _order(parameters: Dictionary) -> void:
	var record := _new_record("ORDER")
	record["proposed_goal"] = parameters

	var rooms: Array = standable.get("rooms", []) if has_standable() else []
	var things: Array = standable.get("things", []) if has_standable() else []
	var checked := NpcGoals.validate(parameters, rooms, things)
	if not bool(checked["ok"]):
		_finish_failed(record, "FAILED_SCHEMA", checked["errors"])
		return

	var goal: Dictionary = checked["goal"]
	var module := WorldRegistry.find(str(standable.get("command", "")))
	if module == null:
		# 054: A GUARD, no legal request reaches it, and nothing said so
		# before. Two facts put it out of reach, both asserted in
		# controller_reach_test. The first: DungeonModule is the only module
		# that reports a standable at all - grepped across scripts/, where
		# WorldModule only documents the key - and it puts its own command()
		# in it, which the registry knows, so find() never comes back null
		# for a world that is standing. (_rebuild_standable sets the same
		# value again on the SHUT/OPEN path; the suite asserts every
		# registered module's command() is one the registry knows, so a
		# second standable-reporting world is asked the question too.) The
		# second: an ORDER sent when nothing is standing is refused one step
		# EARLIER, by NpcGoals, which answers "there is nobody to order
		# about: build a dungeon first" as FAILED_SCHEMA - measured, not
		# reasoned about. It fires when handed a standable whose command no
		# module answers to.
		_finish_failed(record, "FAILED_SCENE", ["there is nobody to order about here"])
		return

	var layout: Dictionary = standable.get("layout", {})
	var from_room := 0
	if is_instance_valid(standable["node"]) and npc_at != Vector3.INF:
		var local: Vector3 = (standable["node"] as Node3D).to_local(npc_at)
		var found := module.room_of(layout, Vector2(local.x, local.z))
		if found >= 0:
			from_room = found

	# 015: a carry is two legs - fetch it, then take it - and the thing is
	# picked up at the end of the first leg, which is why the pickup mark is
	# computed here rather than guessed by the body.
	var marks: Array = []
	var pickup := -1
	var carried: Node3D = null
	if str(goal.get("thing", "")) != "":
		var found := _thing_node(str(goal["thing"]))
		if found == null:
			# 054: A GUARD. It needs a thing LISTED in standable.things whose
			# node is dead, and no request leaves one: a thing is listed by
			# the module that placed it, _rebuild_standable replaces the whole
			# list when a door is shut, and _clear_world_node empties
			# standable altogether. Asserted in controller_reach_test as the
			# invariant it guards - over a build, a SHUT, an OPEN, an errand
			# in progress and a SHUT during one, every thing in the list has a
			# valid node - and fired by freeing a node and leaving it listed.
			_finish_failed(record, "FAILED_SCENE", [
				NpcGoals.missing_thing_line(str(goal["thing"]), "gone")])
			return
		carried = found
		var local_thing: Vector3 = (standable["node"] as Node3D).to_local(found.global_position)
		var thing_room := module.room_of(layout, Vector2(local_thing.x, local_thing.z))
		if thing_room < 0:
			# 054: REACHABLE, and it took physics to find, which is why it is
			# written down here. A thing is placed in a room and a room is
			# where it ends, so this reads like the guard its neighbour above
			# is - but a thing being CARRIED spends part of the errand in a
			# corridor, where room_of() is -1. Measured over one errand: the
			# lamp was sampled in room 1, in room 2 and in no room at all. So
			# a SECOND order sent at that moment reaches this line, and
			# controller_reach_test produces exactly that - it waits for a
			# roomless frame and sends one.
			_finish_failed(record, "FAILED_SCENE", [
				NpcGoals.missing_thing_line(str(goal["thing"]), "roomless")])
			return
		var to_thing := module.route(layout, from_room, thing_room)
		var onward := module.route(layout, thing_room, int(goal["room"]))
		if (to_thing.is_empty() and from_room != thing_room) or (onward.is_empty() and thing_room != int(goal["room"])):
			_finish_failed(record, "FAILED_UNWALKABLE", [
				NpcGoals.outcome_line("NO_ROUTE", str(goal["room_name"]), 0.0, 0.0)])
			return
		# The first leg ENDS at the thing. A route is sampled every half metre
		# along the corridor and on to the room's middle, so it carries points
		# BEYOND where the thing stands - and a thing is solid, so walking to
		# them means walking through it. The first version stalled with the
		# body pressed against the lamp, two thirds of a metre from picking it
		# up, and the ledger correctly called the errand a failure.
		#
		# So the leg is cut at the point nearest the thing and the thing's own
		# position is put on the end.
		var here := Vector2(local_thing.x, local_thing.z)
		var nearest := 0
		var best := 1e9
		for i in to_thing.size():
			var step: Vector2 = to_thing[i]
			var away := step.distance_to(here)
			if away < best:
				best = away
				nearest = i
		to_thing = to_thing.slice(0, nearest)
		to_thing.append(here)
		marks = to_thing + onward
		pickup = to_thing.size() - 1
		# Step 1 of the delivery test: what the thing is and where it was
		# BEFORE the errand, written into the order's own record. Without it
		# the ledger cannot tell a delivery from a thing that was already
		# there.
		record["thing"] = str(goal["thing"])
		record["thing_from"] = str((layout["rooms"] as Array)[thing_room]["name"])
		record["thing_at"] = [snappedf(local_thing.x, 0.1), snappedf(local_thing.z, 0.1)]
	else:
		marks = module.route(layout, from_room, int(goal["room"]))
		if marks.is_empty() and from_room != int(goal["room"]):
			# A refusal, not a failure to try: 005 already measured which
			# doorways a body can pass, and there is no way through to this one.
			_finish_failed(record, "FAILED_UNWALKABLE", [
				NpcGoals.outcome_line("NO_ROUTE", str(goal["room_name"]), 0.0, 0.0)])
			return

	record["goal"] = goal
	record["result"] = "VALID"
	record["construction"] = "BUILT"
	record["category"] = ""
	record["reasons"] = []
	record["metrics"] = {}
	record["outcome"] = "PENDING"
	pending_order = {"id": str(record["id"]), "room": int(goal["room"]),
		"room_name": str(goal["room_name"]), "thing": str(goal.get("thing", ""))}
	last_order_record = record
	TrackLog.append(record)
	track_measured.emit(record)
	ordered.emit(goal, marks, standable["node"], carried, pickup)
	log_message.emit(NpcGoals.sent_line(parameters))


# What actually happened, measured rather than reported. The character says
# where it stopped; the module that owns the geometry says whether that is the
# room it was sent to. There is no path by which a character reports its own
# success.
func finish_order(at: Vector3, seconds: float, travelled: float, why: String) -> void:
	if pending_order.is_empty() or not has_standable():
		return
	var module := WorldRegistry.find(str(standable.get("command", "")))
	var layout: Dictionary = standable.get("layout", {})
	var carrying := str(pending_order.get("thing", ""))
	var outcome := "GAVE_UP" if why == "gave up" else "BLOCKED"
	var actually := ""

	if carrying != "":
		# A delivery is proven by where the THING is, read out of the scene at
		# rest, after the character has stopped and set it down. The character
		# is not asked and could not be believed: a bug in the carrying code
		# must show up as a thing in the wrong room, not as a success.
		#
		# The tolerance is stated rather than numeric: the thing counts as
		# delivered when it stands INSIDE the destination room's rectangle.
		# One reading, once, at rest - not a coordinate that crossed a
		# boundary on the way past.
		#
		# Three outcomes, because "I cannot tell" is not "it failed":
		#   DELIVERED      the thing is in the room it was sent to
		#   NOT_DELIVERED  the thing is somewhere else - a named room, or no
		#                  room at all (a corridor, or still in somebody's
		#                  hands). Where it is is KNOWN; it is simply not
		#                  where it was sent.
		#   INCONCLUSIVE   the world cannot answer at all: the thing is gone
		#                  from the scene, or there is no geometry to ask.
		#
		# The first run of the false delivery test called a key stalled in a
		# corridor INCONCLUSIVE. That overstated our ignorance: we knew exactly
		# where the key was. "Cannot tell" has to mean cannot tell.
		var node := _thing_node(carrying)
		if node == null or module == null or not is_instance_valid(standable["node"]):
			outcome = "INCONCLUSIVE"
		else:
			var spot: Vector3 = (standable["node"] as Node3D).to_local(node.global_position)
			var in_room := module.room_of(layout, Vector2(spot.x, spot.z))
			if in_room == int(pending_order["room"]):
				outcome = "DELIVERED"
			else:
				outcome = "NOT_DELIVERED"
				actually = str((layout["rooms"] as Array)[in_room]["name"]) if in_room >= 0 else ""
	elif module != null and is_instance_valid(standable["node"]):
		var local: Vector3 = (standable["node"] as Node3D).to_local(at)
		if module.room_of(layout, Vector2(local.x, local.z)) == int(pending_order["room"]):
			outcome = "ARRIVED"

	var resolved := {
		"type": "outcome",
		"time": Time.get_datetime_string_from_system(),
		"about": str(pending_order["id"]),
		# The world's answer. What the carrier said for itself is kept apart,
		# under "carrier", so nothing can read one as the other.
		"outcome": outcome,
		"thing": carrying,
		"thing_in": actually,
		"carrier": {"said": why, "stopped_at": [snappedf(at.x, 0.1), snappedf(at.z, 0.1)],
			"seconds": snappedf(seconds, 0.1), "travelled": snappedf(travelled, 0.1),
			# Actions ATTEMPTED and what came of each. "picked up the key" is
			# something that was tried; it is not proof the key moved.
			"attempted": last_attempts.duplicate(true)},
		# The check that was made, written down so the verdict can be
		# re-examined without rerunning anything: what was asked for, what was
		# looked at, and what was found.
		"verified": {
			"check": "the thing's position, read from the world at rest, against the destination room",
			"destination": str(pending_order.get("room_name", "")),
			"found_in": actually if actually != "" else ("(no room)" if outcome != "INCONCLUSIVE" else "(not in the world)"),
		},
		"why": why,
		"room": int(pending_order["room"]),
		"room_name": str(pending_order["room_name"]),
		"at": [snappedf(at.x, 0.1), snappedf(at.z, 0.1)],
		"seconds": snappedf(seconds, 0.1),
		"travelled": snappedf(travelled, 0.1),
	}
	last_outcome_record = resolved
	TrackLog.append(resolved)
	if carrying != "":
		log_message.emit(NpcGoals.delivery_line(
			outcome, carrying, str(pending_order["room_name"]), actually))
	else:
		log_message.emit(NpcGoals.outcome_line(
			outcome, str(pending_order["room_name"]), travelled, seconds))
	pending_order = {}


# --- 018: shutting a door, at any moment ---
#
# A player may do this while a character is halfway along the corridor it
# stands in. Nothing warns the character and nothing re-plans for it: the door
# becomes real, and the body walks into it. That is the point - a world that
# can only be changed between errands cannot be interfered with, and an errand
# nobody can interfere with proves very little.
#
# The world is rebuilt from the layout so the door is actually there, with
# collision, rather than being true only in a list.
func _set_door(parameters: Dictionary, closed: bool) -> void:
	var record := _new_record("SHUT" if closed else "OPEN")
	record["proposed_door"] = parameters

	if not has_standable():
		_finish_failed(record, "FAILED_SCENE", ["there are no doors here: build a dungeon first"])
		return

	var rooms: Array = standable.get("rooms", [])
	var checked := NpcGoals.validate_door(parameters, rooms, standable.get("layout", {}))
	if not bool(checked["ok"]):
		_finish_failed(record, "FAILED_SCHEMA", checked["errors"])
		return

	var door: Dictionary = checked["door"]
	var layout: Dictionary = standable["layout"]
	var changed := DungeonModule.set_shut(layout, int(door["a"]), int(door["b"]), closed)

	record["door"] = door
	record["result"] = "VALID"
	record["construction"] = "BUILT"
	record["category"] = ""
	record["reasons"] = []
	record["metrics"] = {}
	record["changed"] = changed
	TrackLog.append(record)
	track_measured.emit(record)

	if changed:
		door_changed.emit(layout)
	log_message.emit(NpcGoals.door_line(door, closed, changed))


# Rebuild the dungeon that is standing, from its own layout, keeping the
# things where they actually are rather than where they started. Used when a
# door opens or shuts: the geometry has to change for real.
func rebuild_standing_world() -> void:
	if not has_standable():
		return
	var module := WorldRegistry.find(str(standable.get("command", "")))
	if module == null:
		return
	var holder: Node3D = standable["node"]
	var layout: Dictionary = standable["layout"]

	# Where everything stands now, so nothing is put back where it began.
	var carried := {}
	for entry in (standable.get("things", []) as Array):
		var t: Dictionary = entry
		var node = t.get("node", null)
		if is_instance_valid(node):
			carried[str(t["name"])] = (node as Node3D).global_position

	for child in holder.get_children():
		child.queue_free()
	var report := module.build(holder, layout)
	standable = report["standable"]
	standable["command"] = str(module.command())

	for entry in (standable.get("things", []) as Array):
		var t: Dictionary = entry
		if carried.has(str(t["name"])):
			(t["node"] as Node3D).global_position = carried[str(t["name"])]


# The thing in the world with this name, or null. Looked up fresh every time,
# because a carried thing has moved in the scene tree and only the world knows
# where it is now.
func _thing_node(label: String) -> Node3D:
	for entry in (standable.get("things", []) as Array):
		var t: Dictionary = entry
		if str(t.get("name", "")) == label:
			var node = t.get("node", null)
			return node if is_instance_valid(node) else null
	return null


# --- 037: the sixth door to "intent", which read the field nowhere at all ---
#
# The example in the refusal. One for the EQUIP door rather than one per tool,
# because what the sentence has to show is the SHAPE of the field, and a
# player who sent a string for it needs that whether they were asking for a
# car or for boots. Written as the prompt tells the model to write a style -
# "a short lowercase label with underscores" - which two of the five older
# examples are not, and which is recorded in HANDOVER rather than swept here.
const EQUIP_INTENT_EXAMPLE := "lightweight"


func _equip(parameters: Dictionary) -> void:
	var record := _new_record("EQUIP")
	record["tool"] = str(parameters.get("tool", ""))
	# 037: MEASURED, not inferred. All three EQUIP skeletons in the assembled
	# prompt carry "intent": {"style": STYLE}, and nothing in Genesis read it:
	# not this function, not ToolRegistry, not one of the three tools. So a
	# style the model sent exactly as instructed was dropped in silence - the
	# ledger carried no "intent" key for any EQUIP ever made, and
	# main._on_track_measured reads record["intent"]["style"] for the one line
	# the player sees, so the panel said "REQUESTED: not stated" for every
	# tool while a farm with the identical field said "smallholding".
	#
	# Written here and not in the tools for the same reason the worlds write
	# it before validating: the record must carry what was PROPOSED whether or
	# not the proposal stands, so a refused EQUIP says what it was refused
	# about. A non-object becomes {}, as it does for every world.
	record["intent"] = Readback.intent_of(parameters)
	record["proposed_spec"] = parameters.get("spec", {})

	# Both faults are asked, so both are answered. A spec whose intent is a
	# string and whose power is 5000 is told about two things, which is what
	# SectionValidator has done for a section's length and grade since it was
	# written; this function used to return on the first.
	var problems: Array = []
	var intent_wrong := Readback.intent_problem(parameters, EQUIP_INTENT_EXAMPLE)
	if intent_wrong != "":
		problems.append(intent_wrong)

	var asked_tool := str(parameters.get("tool", "")).strip_edges()
	var tool := ToolRegistry.find(asked_tool)
	if tool == null:
		# 022: a missing field and a wrong name are two different faults and
		# used to read as one. Asked for boots that stop inside a metre, the
		# AI sent a spec with no "tool" at all, and the refusal said the game
		# has no tool called '' - which is true, and tells nobody what to fix.
		# A refusal is only worth having if it names the thing that was wrong.
		var kinds := ", ".join(ToolRegistry.names())
		var why := ""
		if asked_tool == "":
			why = "an EQUIP has to say which tool it is for (this game has %s)" % kinds
		else:
			why = "this game has no tool called '%s' (it has %s)" % [asked_tool, kinds]
		problems.append(why)
		_finish_failed(record, "FAILED_SCHEMA", problems)
		return

	var checked := tool.validate(parameters)
	if not bool(checked["ok"]):
		problems.append_array(checked["errors"])
	# Both conditions, not just the list: a validator that answered ok=false
	# with no reasons would otherwise fall through to the build below holding
	# an empty spec. None of the three does; the guard is here so that a tool
	# written later cannot make this the quiet path.
	if not bool(checked["ok"]) or not problems.is_empty():
		_finish_failed(record, "FAILED_SCHEMA", problems)
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
	var record := _new_record("")
	record["attempt"] = int(current_attempt.get("attempt", 1))
	record["result"] = "FAILED"
	record["construction"] = "UNSUPPORTED" if category == "UNSUPPORTED" else "FAILED"
	record["category"] = category
	record["reasons"] = [reason]
	# 023: when a refusal denies something Genesis does, the disagreement goes
	# in the record beside the refusal. It is kept as evidence, not as a score:
	# nothing counts it, and the refusal still stands in the ledger exactly as
	# the AI gave it.
	if not refusal_quarrels.is_empty():
		record["refusal_understates"] = refusal_quarrels.duplicate(true)
		refusal_quarrels = []
	if current_attempt.has("revision_of"):
		record["revision_of"] = current_attempt["revision_of"]
	TrackLog.append(record)
	track_measured.emit(record)


# --- 025: what a load was checked against ---
#
# Its own record, pointing at the world by name, in the same shape the
# understanding and delivery layers use: evidence is added to the ledger, never
# written back over the thing it judges. The build's own record stands exactly
# as it was, and this says whether the world that came out of it is the one
# that went in.
func record_load_check(world_name: String, verdict: Dictionary) -> void:
	var record := {
		"type": "load_check",
		"time": Time.get_datetime_string_from_system(),
		"id": TrackLog.next_id(),
		"about": str(last_build.get("command", "")),
		"world": world_name,
		"outcome": str(verdict.get("outcome", "")),
		"differences": verdict.get("differences", []),
		"not_measured": verdict.get("not_measured", []),
		"said": str(verdict.get("said", "")),
	}
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

# --- 033: two categories for the two ways a command can do nothing ---
# NOTHING_BUILT is not FAILED_SCHEMA and not FAILED_SCENE. The request was
# well formed and the world was the right kind; there is simply no
# implementation behind the name. The three Prototype 001 paths are the only
# ones that answer to it, and the day the last of them is rebuilt or taken out
# of the whitelist, nothing answers to it at all.
#
# 054: AND ONLY TWO OF THOSE THREE CAN BE REACHED, which this comment did not
# say and a reader counting live answers off it would have got wrong.
# MODIFY_TRACK's and the sectionless CREATE_TRACK's are reachable and
# controller_reach_test sends one of each. SPAWN_OPPONENTS' is a GUARD: it
# stands after the has_track() refusal, and TrackBuilder.corner_nodes is
# appended to nowhere in scripts/, so has_track() is always false and the
# refusal above returns first. The comment at _spawn_opponents' SCHEMA check
# has said exactly that since 036 - about the line four above this one's
# sibling - and the same label was never put on the NOTHING_BUILT line
# itself, which is TRAPS 11 at the scale of two adjacent branches.
const NOTHING_BUILT := "FAILED_NOTHING_BUILT"
# A whitelisted command with no case in execute(). See the _ branch there.
const NO_HANDLER := "FAILED_NO_HANDLER"


# --- 034: the plan's own list door ---
#
# The sixth of the six, and the one outside the world modules: a plan is a
# list of steps exactly as a dungeon is a list of rooms, and it was refused
# the same way - "a plan needs a list of steps", naming no count and showing
# no step. The bound is MAX_PLAN_STEPS, which was in scope four lines below
# the sentence that did not name it.
#
# Declared as data rather than written into the message so that
# container_door_test can read it without standing up a scene, and so the
# example step's command is read from the whitelist that admits it instead
# of being typed out beside it - a plan whose example named a command the
# parser rejects would be the fault this commit is about, inverted.
static func plan_list() -> Dictionary:
	return {
		"key": "steps", "one": "step", "many": "steps",
		"low": 1, "high": MAX_PLAN_STEPS, "required": true,
		"sample": [plan_example_step()],
	}


# --- a step a plan may legally carry, and why it is not the first one ---
#
# MEASURED, and it is the reason this function exists. The obvious reading -
# the first whitelisted command that is not PLAN - returns MODIFY_TRACK,
# which is a Prototype 001 stub that builds nothing, appears nowhere in the
# prompt the model is sent, and is item 2 under "Human decision needed". A
# refusal offering it as the example of a plan step would have advertised a
# command the prompt deliberately withholds, in the sentence nobody tests -
# which is precisely the regression TRAPS 21's last paragraph warns about,
# arriving one door up. Measured, not reasoned about: the string was
# generated and read before it was committed.
#
# So the example is a WORLD, built from that world's own lists() samples,
# which makes it a step that would actually build something and ties it to
# the declarations the rest of 034 reads. container_door_test asserts both:
# that the command appears in AIInterpreter.assembled_prompt(), and that the
# step validates.
static func plan_example_step() -> Dictionary:
	var modules := WorldRegistry.modules()
	if modules.is_empty():
		return {"command": "", "parameters": {}}
	var module: WorldModule = modules[0]
	var parameters := {}
	for entry in module.lists():
		var list: Dictionary = entry
		if bool(list.get("required", false)):
			parameters[str(list["key"])] = list.get("sample", [])
	return {"command": module.command(), "parameters": parameters}


func _execute_plan(parameters: Dictionary) -> void:
	var record := _new_record("PLAN")
	record["world"] = "plan"
	# --- 045: the steps a plan was ASKED for ---
	# PLAN was the second of the two commands whose record said nothing about
	# what was proposed. It wrote record["steps"] on the way out, and that is
	# the steps it DID - a construction-layer field - so a plan refused at
	# step 2 of 3 left a ledger entry naming the problem and never the plan.
	# Written here, above every refusal below, so a plan refused for its
	# intent, its list shape, its length or a bad step records its steps like
	# any other command. Read through plan_list(), which is the one place that
	# names this key (Readback.list_error() and the refusals below read the
	# same entry), and said AS SENT: this is what arrived, not what survived.
	record["proposed_%s" % str(plan_list()["key"])] = parameters.get(str(plan_list()["key"]), [])
	# 036: all three world validators and SectionValidator refuse an "intent"
	# that is not an object, and name it. PLAN read the same field, checked
	# nothing, and wrote whatever arrived into the ledger - so a record could
	# carry a string or a list where every other record carries an object,
	# and an auditor reading the file by field would meet three shapes.
	# WorldModule.record_fields() has substituted {} for a non-object intent
	# since 003; this is the fifth door to the same field.
	# 037: the sentence moved into Readback.intent_problem(), which is the one
	# place that answers it for all six doors the prompt offers this field at.
	var intent_wrong := Readback.intent_problem(parameters, "a farm with a circuit round it")
	if intent_wrong != "":
		_finish_failed(record, "FAILED_SCHEMA", [intent_wrong])
		return
	record["intent"] = Readback.intent_of(parameters)

	var raw = parameters.get("steps", null)
	if typeof(raw) != TYPE_ARRAY:
		_finish_failed(record, "FAILED_SCHEMA", [Readback.list_error(plan_list())])
		return

	var steps: Array = raw
	if steps.is_empty() or steps.size() > MAX_PLAN_STEPS:
		_finish_failed(record, "FAILED_SCHEMA", ["a plan needs 1 to %s (got %d)" % [
			Readback.plural(MAX_PLAN_STEPS, "step"), steps.size()]])
		return

	# Check every step before doing any of them.
	var problems: Array = []
	for i in steps.size():
		var n := i + 1
		if typeof(steps[i]) != TYPE_DICTIONARY:
			problems.append(Readback.member_error(plan_list(), n))
			continue
		var step: Dictionary = steps[i]
		var step_command := str(step.get("command", "")).to_upper()
		if step_command == "PLAN":
			problems.append("step %d: a plan may not contain another plan" % n)
		elif not step_command in CommandParser.allowed_commands():
			problems.append("step %d: '%s' is not a command this game has" % [n, step_command])
		if step.has("parameters") and typeof(step["parameters"]) != TYPE_DICTIONARY:
			problems.append("step %d: parameters must be an object" % n)
		# 036: "around" is the one field the PROMPT tells the model to write
		# that nothing checked. Read through WorldRegistry, which is the one
		# place that knows where it may be written, so a check here and the
		# placement in _place() cannot look in different places.
		var around_wrong := WorldRegistry.around_problem(step, n, steps.size())
		if around_wrong != "":
			problems.append(around_wrong)

	if not problems.is_empty():
		_finish_failed(record, "FAILED_SCHEMA", problems)
		return

	# --- 040: the clear waits until a build is certain to start ---
	#
	# This used to happen HERE, before pass 1, and pass 1 can refuse: a step
	# that will not validate makes the whole plan FAILED_SCENE. So a plan
	# containing one unbuildable world TOOK THE PLAYER'S STANDING WORLD AWAY
	# and then reported that it had built nothing - measured, a farm of 62
	# children down to 0 with no geometry built. Every other refusal in
	# Genesis leaves the world alone: a single world's refusal never reaches
	# _build_world, and a plan refused for its SCHEMA returns above this line.
	# This path was the exception, and the rule it broke is Genesis's own.
	#
	# Pass 1 builds nothing (_prepare_world is "everything up to but not
	# including geometry") and pass 2 only grows layouts, so the clear is
	# simply late rather than conditional. It is still before any geometry.
	#
	# WHAT THIS DOES NOT FIX, because the fix is not a move: a plan whose
	# worlds OVERLAP is refused in pass 3, by _place(), after the clear and
	# after earlier steps have been built. Two worlds with no "around" - the
	# shape of the prompt's own PLAN skeleton - take that path. Making it
	# safe means knowing every world's footprint before building any of them,
	# which is a change to how a plan is built: HANDOVER, "Human decision
	# needed" 10.
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

	# Pass 3: build, in the order the AI gave. Clear once first, then let
	# each step add to the same scene - 040 moved this down from above pass 1
	# so that a plan refused before here leaves the standing world standing.
	var cleared_for_building := false
	if plan_problems.is_empty():
		track_builder.clear()
		opponent_builder.clear()
		_clear_world_node()
		cleared_for_building = true
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
		# 040: tidy up only what THIS plan put in the scene. Clearing
		# unconditionally here was the second half of the same fault: the
		# clear above now waits for pass 3, so a plan refused in pass 1 has
		# built nothing, and running this would take the standing world away
		# at the end instead of at the beginning. Measured: a farm of 62
		# children survives a plan whose second step will not validate.
		if cleared_for_building:
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
	lines.append("Plan built in %s: %s" % [Readback.plural(done.size(), "step"), ", ".join(done)])
	for note in fitted:
		var n: Dictionary = note
		# 043: "the" through the one function that decides it, like every
		# other name in Genesis. A world's display_name() is never numbered,
		# so this line is byte-identical today - which is the point: it can
		# no longer be the one that is wrong when something else is.
		lines.append("%s grown to %.0f by %.0f m so %s fits inside it" % [
			str(n["world"]).capitalize(), float(n["to_width"]), float(n["to_depth"]),
			Readback.the(str(n["inner"]))])
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
		# 036: `float(given.get("x", 0.0))` threw on null and {}, abandoning
		# _place() - so the world was built and never positioned, silently.
		# A coordinate Genesis cannot read is now treated as no coordinate,
		# which is what an absent one already does.
		#
		# NOT refused, and the reason is a question rather than an answer.
		# Measured: an offset of 150 really does move a world to x = 150, and
		# the prompt says "never give coordinates" and never names this
		# field - the one line in it containing the word "offset" is a
		# CHICANE's sideways step, a different field behind SectionValidator.
		# So no prompted request reaches this branch, and a refusal written
		# here would be a sentence no player can meet. But a working
		# placement-by-coordinate that the prompt denies is TRAPS 17's shape
		# reversed, and whether the prompt should offer it or the validator
		# should refuse it is the owner's: HANDOVER, "Human decision
		# needed" 8.
		var given: Dictionary = step["offset"]
		var ox := Readback.measure(given, "x")
		var oz := Readback.measure(given, "z")
		offset = Vector2(0.0 if is_nan(ox) else ox, 0.0 if is_nan(oz) else oz)

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
	# The module names itself. Dictionary.merge does NOT overwrite a key that
	# is already there, so the command is passed IN rather than left to the
	# merge below: opening the header with "" and expecting record_fields()
	# to fill it left every world record with an empty command, which
	# session_test caught by counting three worlds as one. record_fields()
	# names the same command, so the merge is a no-op on that key and still
	# adds "world" and the intent.
	var record := _new_record(module.command())
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
	if report.has("standable"):
		standable = report["standable"]

	TrackLog.append(record)
	track_measured.emit(record)

	log_message.emit(module.summary(record["metrics"], report))


func _clear_world_node() -> void:
	drivable = {}
	standable = {}
	pending_order = {}
	npc_at = Vector3.INF
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
	if report.has("standable"):
		standable = report["standable"]


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


# --- 008: walking ---

func has_standable() -> bool:
	return not standable.is_empty() and is_instance_valid(standable["node"])


# Where a body starts, in world space. A plan may have moved the world, so the
# node's own numbers are converted, exactly as drivable_surface() does.
# Returns {} when there is nothing to walk.
func standable_surface() -> Dictionary:
	if not has_standable():
		return {}
	var node: Node3D = standable["node"]
	return {
		"start_position": node.to_global(standable["entrance"]),
		"start_heading": float(standable.get("heading", 0.0)),
	}


# --- 033: a command that did nothing, recorded as having done nothing ---
# Four paths through execute() wrote to the player's log and nothing else, so
# a request that was accepted and then did nothing left no trace in the one
# place the project calls its evidence. The understanding layer still wrote a
# record pointing back at the id those requests were given, so the ledger
# carried a reference to a record that had never been written.
#
# The line the player reads and the reason in the record are the SAME string,
# passed in once by the function that produced it, so the two cannot drift
# apart - the rule WorldRegistry.around_of() exists for. Nothing here is
# worded in this function.
#
# Kept apart from _finish_failed, which writes its own multi-line "X failed:
# CATEGORY / - reason / no geometry built" announcement. The three Prototype
# 001 builders already say exactly what happened in sentences 032 measured
# and wrote, and this must not replace them.
func _finish_nothing(record: Dictionary, category: String, line: String) -> void:
	record["result"] = "FAILED"
	record["construction"] = "FAILED"
	record["category"] = category
	record["reasons"] = [line]
	record["metrics"] = {}
	TrackLog.append(record)
	track_measured.emit(record)
	log_message.emit(line)


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
#
# --- 033: the three commands that left no record ---
# 032 found that these three said they had built things they had not, and
# fixed what they say. Asked the next question off the same list - does every
# command the whitelist admits WRITE A RECORD? - all three, and CLEAR_WORLD
# with them, turned out to write none at all. Measured headless: an accepted
# MODIFY_TRACK left exactly one new record in the ledger, the understanding
# record about it, pointing at an id no record carried.
#
# Each of them now ends in exactly one place, so there is one record per
# request and no path out without one. The guards that used to sit in
# execute() moved in here for that reason: a refusal is a result, and it was
# the half of these commands a player was most likely to meet.

func _modify_track(parameters: Dictionary) -> void:
	var record := _new_record("MODIFY_TRACK")
	record["proposed_change"] = parameters
	# 054: MEASURED, and worth knowing before reading the branches below.
	# main.gd stands an UNRECORDED starter circuit in the world at launch
	# (show_unrecorded, main.gd:135) so there is something to drive before
	# anything has been asked for, and that sets `drivable`. So has_drivable()
	# is TRUE on a fresh session and this is the answer a player's FIRST
	# MODIFY_TRACK gets - about a track he never asked for. The two branches
	# below are reached only after the world has been cleared. Nothing is
	# changed here: what that refusal should SAY is in HANDOVER under "Human
	# decision needed" 2, with the rest of the three stubs' future.
	if has_drivable():
		_finish_nothing(record, "FAILED_SCENE",
			"MODIFY_TRACK failed: composed tracks are changed with MODIFY_SECTION, which comes in a later step")
		return
	# --- 036: the type question, asked where no validator stands ---
	# This was `int(parameters.get("corner", 1))`, and int() has no
	# constructor for null, {} or []: it threw, abandoning this function
	# AFTER _new_record() and BEFORE _finish_nothing(), so the request left
	# NO RECORD AT ALL while the understanding layer still wrote one pointing
	# at its id. That is 033's dangling reference back again, through a value
	# that is not a number. TrackBuilder.readback() has read the same field
	# through Readback.as_number() since 032, one file along.
	var asked_corner := Readback.measure(parameters, "corner")
	if parameters.has("corner") and is_nan(asked_corner):
		_finish_failed(record, "FAILED_SCHEMA",
			["'corner' must be a number, the corner to change"])
		return
	var corner: int = 1 if is_nan(asked_corner) else int(asked_corner)
	var difficulty: String = str(parameters.get("difficulty", "medium"))
	# The builder's own sentence, which 032 tied to what it actually did, is
	# both the player's line and the record's reason.
	_finish_nothing(record, NOTHING_BUILT, track_builder.modify_corner(corner, difficulty))


func _spawn_opponents(parameters: Dictionary) -> void:
	var record := _new_record("SPAWN_OPPONENTS")
	record["proposed_grid"] = parameters
	if has_drivable():
		_finish_nothing(record, "FAILED_SCENE",
			"SPAWN_OPPONENTS failed: opponents on composed tracks come in a later step")
		return
	if not track_builder.has_track():
		# Always true: TrackBuilder.corner_nodes is appended to nowhere in the
		# repository, so has_track() can never return true and this is the one
		# answer SPAWN_OPPONENTS can give. Recorded as the measurement it is.
		_finish_nothing(record, "FAILED_SCENE", "SPAWN_OPPONENTS failed: build a track first")
		return

	# 036: the same reading as _modify_track's, and the same rule.
	# UNREACHABLE TODAY and labelled as such (TRAPS 6): has_track() is always
	# false, so the guard above returns first and no legal input gets here.
	# It is fixed anyway because the fault is the CLASS and not the instance
	# (TRAPS 11) - and because if the owner ever takes option (c) under
	# "Human decision needed" 2, this line is reached on the first request.
	# OpponentBuilder.readback() has read "count" safely since 032.
	var asked_count := Readback.measure(parameters, "count")
	if parameters.has("count") and is_nan(asked_count):
		_finish_failed(record, "FAILED_SCHEMA",
			["'count' must be a number, how many opponents to put on the grid"])
		return
	var count: int = 1 if is_nan(asked_count) else int(asked_count)
	# 054: UNREACHABLE TODAY for the same reason as the check above it, and
	# labelled now rather than only in the sentence next door (TRAPS 11, TRAPS
	# 6). has_track() is always false, so the guard above returns first and no
	# request gets here. stub_claims_test has asserted the reachability half
	# since 032 - corner_nodes empty before and after a build, has_track()
	# false, and its header says that is "the reason SPAWN_OPPONENTS can never
	# run" - so this line was already known to be out of reach from the
	# BUILDER's side. What 054 adds is the other two halves: that nothing
	# anywhere in scripts/ appends to corner_nodes (grepped by the suite, not
	# asserted on one instance after one build), and that handed a track this
	# branch FIRES - controller_reach_test puts two corner nodes into
	# TrackBuilder.corner_nodes and reads FAILED_NOTHING_BUILT back. A guard,
	# then, and not dead code.
	_finish_nothing(record, NOTHING_BUILT, opponent_builder.spawn(
		count,
		track_builder.get_start_position(),
		track_builder.get_start_direction()
	))


# A sectionless CREATE_TRACK. Still clears the world before discovering it
# has nothing to build, which is HANDOVER's "Human decision needed" 2 and
# deliberately not changed here: 033 is about what the ledger says, and
# taking the clear() out is a change to what Genesis DOES on a path the owner
# may delete. What is new is that the ledger now says the world went.
func _build_prototype_ring(parameters: Dictionary) -> void:
	var record := _new_record("CREATE_TRACK")
	record["proposed_ring"] = parameters
	_clear_world_node()
	_restore_view()
	opponent_builder.clear()
	_finish_nothing(record, NOTHING_BUILT, track_builder.build(parameters))


# CLEAR_WORLD is the one command here that does exactly what it says.
func _clear_world() -> void:
	var record := _new_record("CLEAR_WORLD")
	last_build = {}
	track_builder.clear()
	opponent_builder.clear()
	_clear_world_node()
	_restore_view()
	record["result"] = "VALID"
	# Not BUILT. Nothing was built: a world was taken away, which is the
	# whole job of this command, so the construction layer says what it did
	# rather than borrowing the word that means the opposite. Nothing counts
	# CLEARED as a world - see SessionReport, which until 033 counted every
	# valid record as one.
	record["construction"] = "CLEARED"
	record["category"] = ""
	record["reasons"] = []
	record["metrics"] = {}
	TrackLog.append(record)
	track_measured.emit(record)
	log_message.emit("CLEAR_WORLD")
