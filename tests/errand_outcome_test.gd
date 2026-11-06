extends SceneTree

# 123 - WHAT THE LEDGER SAYS AT EACH HALT REASON, AND THE SENTENCE A PLAYER
#       READS THERE
#
# WHERE THIS CAME FROM, AND IT IS A READ THAT WANTED CHECKING
# 121 read what the body knows at ONE halt reason. 122 widened that to all
# four. Neither asked what the ERRAND resolves to at any of them, and 122's
# entry in HANDOVER filled the gap with an inference off two lines of
# `game_controller.gd`:
#
#   var outcome := "GAVE_UP" if why == "gave up" else "BLOCKED"   (:375)
#   ... ARRIVED written over it only when the body is in the room  (:414-415)
#
# and concluded that `BLOCKED` - and therefore the sentence "Could not get to
# X: stopped making progress after N m." - is what THREE of the four halt
# reasons resolve to: the stall, "nowhere to go", and a "stopped walking"
# whose waypoints ran out somewhere other than the destination room. The
# entry said plainly that this was "a read of two lines, not a measurement,
# and nothing asserts it". This suite is the measurement, and the read was
# wrong: ONE reachable halt reason resolves to BLOCKED, not three.
#
# AND NO SUITE IN THIS PROJECT ASSERTED A `BLOCKED` THAT AN ERRAND PRODUCED,
# WHICH IS THE PART THAT MATTERS MOST
# Grepped before this file was written. `BLOCKED` occurs in tests/ exactly
# once outside this file: `log_022_test` calls
# `NpcGoals.outcome_line("BLOCKED", ...)` with the string typed in by hand,
# which pins the WORDING and reaches none of the code that decides it.
# `load_shut_test` drives an `ARRIVED`. `carry_test` does hand-call
# `finish_order(..., "stopped making progress")` - but on a CARRYING errand,
# which cannot reach `BLOCKED` at all for the reason in the next paragraph.
# The only `BLOCKED` anyone had seen come out of a running errand arrived by
# accident, as 119's injection B, and was written into HANDOVER as a surprise.
# So the one outcome a player meets when a plain errand fails was asserted
# nowhere. Section 2 drives it.
#
# WHY A SHUT DOOR AND NOT THE LEFTOVER PLAYER BODY
# The same reason halt_cause_test gives. A door shut in a walker's face is
# permanent intended behaviour - GENESIS CHALLENGE 001, already asserted by
# `interference_test` - so no answer to any of the owner's open questions can
# make this fixture unreachable. Whether a body the player stepped out of
# stays in the world is one of those questions, so a suite built on it would
# have to be deleted by whoever answers it.
#
# AND THE ERRAND HERE CARRIES NOTHING, WHICH IS THE WHOLE DIFFERENCE
# `interference_test` shuts the same door on a CARRYING errand, and a carrying
# errand never reaches `BLOCKED` at all: `finish_order` branches on
# `carrying != ""` and answers DELIVERED / NOT_DELIVERED / INCONCLUSIVE from
# where the thing ended up. `BLOCKED` is reachable only on a `go_to`, which is
# why that is what section 2 sends.
#
# WHAT EACH ROW ASSERTS, AND WHY IT IS NOT THE WORDING (TRAPS 116)
# A sentence claims something. 118's lesson is that asserting the sentence was
# said, in place of the thing it claims, is how a false sentence survives. So
# the rows here assert the CLAIM:
#
#   "Got to the vault."              -> the body is in the vault, read by the
#                                       module that owns the geometry
#   "stopped making progress"        -> the body's flat speed is 0 at the
#                                       moment it halts, it is on a wall, and
#                                       it is NOT in the destination room
#
# The sentence a player actually reads is captured off `log_message` and
# PRINTED in this suite's output, verbatim, for the owner to read. Its wording
# is asserted nowhere: what a failed errand should say is "Human decision
# needed" 38 and it is his.
#
# WHY EVERY ROW HAS A CONTROL (TRAPS 6)
# Section 2 asserts BLOCKED. On its own that would pass on a Genesis that
# answered BLOCKED to everything. Section 1 is the same dungeon, the same
# order, the same reader, with the door left open, and it must read ARRIVED.
# Neither section means anything without the other, and they share every
# helper so they cannot differ in what they looked at.
#
# AND THE THIRD HALT REASON IS CLOSED OVER THE CONSTANTS, NOT OVER ONE
# DUNGEON (TRAPS 11)
# A "stopped walking" that is not an arrival is what 122 left on its list.
# `route()`'s last mark is the destination room's own centre
# (`dungeon_module.gd:1179`), and `_steer` retires a waypoint at
# `gap < Npc.ARRIVE`, so a body that exhausts its waypoints is within
# `Npc.ARRIVE` of that centre. The centre of a legal room is at least
# `MIN_SIDE * 0.5` from its nearest edge. So the question is one comparison
# between two constants, and section 3 makes it - for EVERY legal dungeon,
# rather than for the one this file happens to build. The two it does build
# are the readings that the constants mean what they look like: that the last
# mark really is the centre, that it reads back into the destination room
# through the same transform the arrival test uses, and that the tightest
# legal dungeon is walkable at all rather than vacuously safe.
#
# WHAT IS NOT HERE, SAID PLAINLY
# The 90 s cap is not driven. `halt_cause_test` pays for that drive already -
# a 24-room chain and a 598 m route - and what it costs is minutes. The one
# line that decides GAVE_UP is read in this header and asserted nowhere here,
# so this suite says nothing about the cap at all.
# "nowhere to go" is not driven either, and does not need to be: 122's suite
# proved no ORDER can reach it, leg by leg, and that proof is there rather
# than duplicated here.

var main: Node3D
var lines: Array = []
var failures: Array = []
var asserted := 0
var said: Array = []
var at_halt := {}

const ROOMS := '{"name": "entrance", "width": 12, "depth": 12}, {"name": "middle", "width": 12, "depth": 12}, {"name": "vault", "width": 12, "depth": 12}'
const DUNGEON := '{"command": "CREATE_DUNGEON", "parameters": {"rooms": [%s], "doors": [[1, 2], [2, 3]]}}'
# The tightest dungeon the schema allows: two rooms at MIN_SIDE, one door.
const TIGHT := '{"command": "CREATE_DUNGEON", "parameters": {"rooms": [{"name": "entrance", "width": 4, "depth": 4}, {"name": "vault", "width": 4, "depth": 4}], "doors": [[1, 2]]}}'
const ORDER := '{"command": "ORDER", "parameters": {"goal": "go_to", "room": "vault"}}'
const SHUT := '{"command": "SHUT", "parameters": {"between": ["middle", "vault"]}}'

const VAULT := 2        # the destination, 0-based, in the three-room fixture
const TIGHT_VAULT := 1  # and in the two-room one


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
	said = []
	at_halt = {}
	main.controller.log_message.connect(func(t): said.append(str(t)))


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


# What the body knows at the moment it stops. Read INSIDE the handler, because
# `halt()` sets `state` and clears nothing a frame later: a reading taken after
# `_settle()` would be of a body that has been standing still either way, and
# could not tell a stall from an arrival.
func _on_stopped(why: String, _at: Vector3, _seconds: float, _travelled: float) -> void:
	at_halt = {
		"why": why,
		"speed": Vector2(main.npc.velocity.x, main.npc.velocity.z).length(),
		"on_wall": main.npc.is_on_wall(),
		"collisions": main.npc.get_slide_collision_count(),
		"mark": main.npc.mark,
		"marks": main.npc.marks.size(),
		# At THIS moment, for the reason on `_room_of_body` below.
		"room": _room_of_body(),
	}


func _settle() -> void:
	var guard := 0
	while guard < Engine.physics_ticks_per_second * 95 and main.npc != null \
			and main.npc.state == Npc.GOING:
		guard += 1
		await physics_frame
	for i in 20:
		await physics_frame


# Which room the body is standing in, asked of the module that owns the
# geometry and through the same transform `finish_order` uses.
#
# AND IT IS ONLY THE SAME ANSWER AT THE SAME MOMENT, WHICH IS NOT A DETAIL.
# The first draft of this file called it after `_settle()` and said in a
# comment that it "cannot answer differently from the thing that decided the
# outcome". That was false, and this commit's own injection B proved it: with
# `Npc.ARRIVE` widened the body halted in the corridor - `finish_order` read
# no room and resolved BLOCKED - and then slid forward into the room over the
# frames that followed, so a read after `_settle()` said room 1 about an
# errand the ledger had already called BLOCKED. Both readings were true of the
# body at the moment each was taken. The outcome is decided from the position
# at the halt, so that is when this is called: from inside `_on_stopped`,
# which is the frame `finish_order` is reached on.
func _room_of_body() -> int:
	var module := DungeonModule.new()
	var holder: Node3D = main.controller.standable["node"]
	var layout: Dictionary = main.controller.standable["layout"]
	var local: Vector3 = holder.to_local(main.npc.global_position)
	return module.room_of(layout, Vector2(local.x, local.z))


# The outcome record, with the guard 119's injection D exists for: a record
# left over from an earlier errand reads as a pass. It is only this errand's
# answer if its `about` is this errand's id.
func _outcome_of_this_errand() -> String:
	var order: Dictionary = main.controller.last_order_record
	var out: Dictionary = main.controller.last_outcome_record
	if order.is_empty() or out.is_empty():
		return "NONE"
	if str(out.get("about", "")) != str(order.get("id", "")):
		return "STALE(%s)" % str(out.get("outcome", ""))
	return str(out.get("outcome", ""))


# --- 1. the errand that arrives: the control for section 2 ---
func _arrival_section() -> void:
	_make_main()
	await process_frame
	await _type(DUNGEON % ROOMS)
	await _type(ORDER)
	_check(main.npc != null, "a plain go_to errand to the vault sets somebody walking")
	if main.npc == null:
		return
	main.npc.stopped_walking.connect(_on_stopped)
	await _settle()

	_check(str(at_halt.get("why", "")) == "stopped walking",
		"with every door open it halts for the reason an arrival halts for - \"%s\"" % str(at_halt.get("why", "")))
	_check(int(at_halt.get("mark", -1)) >= int(at_halt.get("marks", 0)),
		"and it halts because the waypoints ran out - mark %d of %d" % [
			int(at_halt.get("mark", -1)), int(at_halt.get("marks", 0))])
	_check(_outcome_of_this_errand() == "ARRIVED",
		"and THAT halt reason resolves to ARRIVED - the ledger says \"%s\"" % _outcome_of_this_errand())
	# The claim the sentence makes, not the sentence (TRAPS 116).
	_check(int(at_halt.get("room", -9)) == VAULT,
		"and the claim behind \"Got to the vault\" holds: at the halt the geometry puts the body in room %d of the %d it was sent to" % [
			int(at_halt.get("room", -9)), VAULT])
	lines.append("  the player reads: " + (str(said[-1]) if not said.is_empty() else "(nothing)"))
	await _drop_main()


# --- 2. the errand that is stopped: the BLOCKED no suite had asserted ---
func _blocked_section() -> void:
	_make_main()
	await process_frame
	await _type(DUNGEON % ROOMS)
	await _type(ORDER)
	_check(main.npc != null, "the same errand, sent again with the door still open")
	if main.npc == null:
		return
	main.npc.stopped_walking.connect(_on_stopped)

	# Let it get clear of the entrance, then shut the door in front of it. The
	# route was planned when the order was given and is not re-planned, which
	# is the point of GENESIS CHALLENGE 001.
	var guard := 0
	while guard < Engine.physics_ticks_per_second * 6 and main.npc.state == Npc.GOING:
		guard += 1
		await physics_frame
	var before: int = main.npc.mark
	_check(main.npc.state == Npc.GOING and before > 0,
		"it is under way when the door is shut - mark %d of %d" % [before, main.npc.marks.size()])
	await _type(SHUT)
	await physics_frame
	_check(main.npc != null and main.npc.state == Npc.GOING,
		"and shutting the door does not stop it or replace it: the same body walks on")
	await _settle()

	_check(str(at_halt.get("why", "")) == "stopped making progress",
		"it halts on the stall timer - \"%s\"" % str(at_halt.get("why", "")))
	_check(int(at_halt.get("mark", 0)) < int(at_halt.get("marks", 0)),
		"with waypoints still unspent, which is what makes it a different halt from section 1 - mark %d of %d" % [
			int(at_halt.get("mark", 0)), int(at_halt.get("marks", 0))])
	_check(_outcome_of_this_errand() == "BLOCKED",
		"and THAT halt reason resolves to BLOCKED - the ledger says \"%s\"" % _outcome_of_this_errand())
	# The two claims the sentence makes, neither of them its wording.
	_check(float(at_halt.get("speed", -1.0)) == 0.0,
		"and the claim behind \"stopped making progress\" holds: flat speed %.4f m/s at the moment it halts" % float(at_halt.get("speed", -1.0)))
	_check(bool(at_halt.get("on_wall", false)) and int(at_halt.get("collisions", 0)) >= 1,
		"it is pressed against something - on_wall %s, %d slide collisions" % [
			str(at_halt.get("on_wall", false)), int(at_halt.get("collisions", 0))])
	_check(int(at_halt.get("room", -9)) != VAULT,
		"and the claim behind \"could not get to the vault\" holds: at the halt the geometry puts the body in room %d, not %d" % [
			int(at_halt.get("room", -9)), VAULT])
	lines.append("  the player reads: " + (str(said[-1]) if not said.is_empty() else "(nothing)"))
	await _drop_main()


# --- 3. the halt reason 122 left on its list, closed over the constants ---
#
# GUARD, AND LABELLED AS ONE (TRAPS 6). Nothing here drives a non-arrival
# "stopped walking", because the comparison below is why there is none to
# drive. What can fail, and this was taken rather than reasoned about: with
# `Npc.ARRIVE` widened to 2.5 in a throwaway copy, this section goes to
# failures=3 and the LAST row of it - the tightest legal dungeon, walked -
# reports a body that ran out of waypoints reading room -1 at the halt and
# resolving to BLOCKED. That is the fault 122 inferred, and it is one
# constant away. Dropping `DungeonModule.MIN_SIDE` below 2.8 does the same
# from the other side. That is the change this section exists to catch.
func _unreachable_section() -> void:
	var tightest := DungeonModule.MIN_SIDE * 0.5
	_check(Npc.ARRIVE < tightest,
		"a waypoint is retired within %.2f m of it and the centre of the smallest legal room is %.2f m from its nearest edge, so a body that runs out of waypoints is inside the room it was sent to - %.2f m of margin, for EVERY legal dungeon" % [
			Npc.ARRIVE, tightest, tightest - Npc.ARRIVE])

	# And the readings that say the two constants above are about the same
	# thing: that route()'s last mark IS the room's centre, and that it reads
	# back into the destination room through the transform finish_order uses.
	for which in [DUNGEON % ROOMS, TIGHT]:
		_make_main()
		await process_frame
		await _type(which)
		var room_count: int = (main.controller.standable.get("rooms", []) as Array).size() \
			if main.controller.has_standable() else 0
		_check(main.controller.has_standable(),
			"a legal fixture builds, %d rooms%s" % [room_count,
				(" - the TIGHTEST the schema allows" if which == TIGHT else "")])
		if not main.controller.has_standable():
			await _drop_main()
			continue
		var module := DungeonModule.new()
		var holder: Node3D = main.controller.standable["node"]
		var layout: Dictionary = main.controller.standable["layout"]
		var rects: Array = module._rects(layout)
		var off_centre := 0
		var not_in_room := 0
		var tight_margin := 1e9
		for r in rects.size():
			var marks: Array = module.route(layout, 0, r)
			if marks.is_empty():
				not_in_room += 1
				continue
			var last: Vector2 = marks[marks.size() - 1]
			var rect: Rect2 = rects[r]
			if last.distance_to(rect.position + rect.size * 0.5) > 0.0001:
				off_centre += 1
			var local: Vector3 = holder.to_local(Vector3(last.x, 0.0, last.y))
			if module.room_of(layout, Vector2(local.x, local.z)) != r:
				not_in_room += 1
			tight_margin = minf(tight_margin, minf(
				minf(last.x - rect.position.x, rect.position.x + rect.size.x - last.x),
				minf(last.y - rect.position.y, rect.position.y + rect.size.y - last.y)))
		_check(off_centre == 0 and rects.size() > 0,
			"the last mark of the route to each of its %d rooms is that room's own centre - %d elsewhere" % [
				rects.size(), off_centre])
		_check(not_in_room == 0,
			"and reads back into that room through the transform finish_order asks through - %d did not" % not_in_room)
		_check(tight_margin > Npc.ARRIVE,
			"its tightest centre-to-edge is %.4f m against an ARRIVE of %.2f m" % [tight_margin, Npc.ARRIVE])
		await _drop_main()

	# The tightest legal dungeon, actually walked. Without this the row above
	# could be true of a layout no body can cross, which would make the whole
	# section safe for the wrong reason.
	_make_main()
	await process_frame
	await _type(TIGHT)
	await _type(ORDER)
	_check(main.npc != null, "and the tightest legal dungeon is walkable rather than vacuously safe: the errand sets off")
	if main.npc != null:
		main.npc.stopped_walking.connect(_on_stopped)
		await _settle()
		_check(str(at_halt.get("why", "")) == "stopped walking" \
				and _outcome_of_this_errand() == "ARRIVED" \
				and int(at_halt.get("room", -9)) == TIGHT_VAULT,
			"and it arrives there too - \"%s\", %s, room %d at the halt" % [
				str(at_halt.get("why", "")), _outcome_of_this_errand(),
				int(at_halt.get("room", -9))])
	await _drop_main()


func _run() -> void:
	print("--- 123: what the errand resolves to at each halt reason ---")
	await _arrival_section()
	await _blocked_section()
	await _unreachable_section()

	print("")
	for l in lines:
		print(l)
	print("")
	print("  halt reason                   outcome   driven here")
	print("  \"stopped walking\" (arrival)    ARRIVED   yes, sections 1 and 3")
	print("  \"stopped making progress\"      BLOCKED   yes, section 2")
	print("  \"stopped walking\", not arrived  -        unreachable, section 3")
	print("  \"nowhere to go\"                 -        unreachable by any ORDER (122)")
	print("  \"gave up\"                      GAVE_UP   NOT driven, and not asserted anywhere here")
	print("ERRAND OUTCOME %d assertions, failures=%d" % [asserted, failures.size()])
	quit(failures.size())
