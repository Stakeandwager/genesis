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


# --- 4. the vocabulary: every outcome an errand can resolve to, and whether
#        the sentence a player reads has an arm for it ---
#
# WHERE THIS CAME FROM. 123 wrote the three sections above and then wrote down
# what they could not catch: "nothing here reads `game_controller.gd` to assert
# that :375 is still the only place an outcome is initialised; a second
# assignment added tomorrow is caught by no row in this file." That is this
# section, and asking it of the CLASS rather than of that one line (TRAPS 11)
# turns out to be a different and better question than the one 123 named.
#
# THE SHAPE OF THE FAULT IT GUARDS. `finish_order` decides one of six names.
# It then hands that name to ONE OF TWO functions - `delivery_line` when the
# errand was carrying something, `outcome_line` when it was not - and each of
# those is a `match` with a FALL-THROUGH: an unmatched name returns
# "Nothing happened." So an outcome that reaches the wrong one of the two, or a
# seventh outcome added with no arm, does not crash and does not log: a player
# whose delivery failed reads "Nothing happened." about an errand that did
# something, and the ledger still holds the real outcome. Missing evidence
# becoming a sentence that says nothing is the shape PROTOCOL section 2 names.
#
# NOTHING ASSERTED THIS. Grepped before this section was written, and stated at
# the width the grep supports: "Nothing happened." occurs nowhere in `tests/`,
# no suite reads `npc_goals.gd` for these arms, and the three suites that touch
# these names at all type them in by hand at one call apiece - `log_022_test`
# and `said_article_test` pin WORDING, `carry_test` drives three deliveries.
# None of them would notice a seventh name or a name on the wrong side.
#
# WHAT IS ASSERTED IS THE AGREEMENT AND NOT THE WORDING (TRAPS 6, TRAPS 14).
# Not one sentence is typed into this file as an expected answer, and no row
# says what a player SHOULD be told - that is "Human decision needed" 38 and
# it is the owner's. Every row is a comparison between two sets read out of
# this repository's own source, so a sentence reworded in a way that keeps its
# arm does not fail here, and an outcome that loses its sentence does.
#
# AND THE SETS ARE READ OFF THE CODE, COMMENT-STRIPPED, because a question
# about what the code DOES is answered from the code (TRAPS 63). The reader is
# `_code_of()`, byte-identical to every other copy in `tests/`;
# `source_scan_test` holds that class and this file is now a member of it,
# which is the cost 123 declined to pay and the reason it could not ask this.


const CONTROLLER := "res://scripts/game_controller.gd"
const GOALS := "res://scripts/npc_goals.gd"
# The one branch in finish_order that decides WHICH of the two sentence
# functions is handed the outcome. Named once, and found below by its own text
# and indentation rather than by a line number, so the block can move.
const CARRY_BRANCH := "if carrying != \"\":"


static func _code_of(source: String) -> String:
	var out := ""
	for raw in source.split("\n"):
		var line := str(raw)
		if line.strip_edges().begins_with("#"):
			out += "\n"
			continue
		var hash_at := line.find("#")
		out += (line if hash_at < 0 else line.substr(0, hash_at)) + "\n"
	return out


func _source(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	return _code_of(file.get_as_text())


static func _sorted(set: Dictionary) -> Array:
	var out: Array = []
	for k in set.keys():
		out.append(str(k))
	out.sort()
	return out


static func _both_of(a: Array, b: Array) -> Array:
	var out: Array = []
	for n in a:
		if b.has(n):
			out.append(str(n))
	out.sort()
	return out


static func _without(names: Array, taken: Array) -> Array:
	var out: Array = []
	for n in names:
		if not taken.has(n):
			out.append(str(n))
	out.sort()
	return out


# The code of one function: from its header line to the next one that starts a
# function at column 0. The header itself is dropped, so every line returned is
# indented and the base indentation of the body is one tab.
static func _body_of(code: String, header: String) -> String:
	var out := ""
	var inside := false
	for raw in code.split("\n"):
		var line := str(raw)
		if line.begins_with(header):
			inside = true
			continue
		if inside:
			if line.begins_with("func ") or line.begins_with("static func "):
				break
			out += line + "\n"
	return out


# Every ALL-CAPS string literal this code assigns to a variable named
# `outcome`. Taken from the whole right-hand side and not from the first match,
# because the initialiser is a ternary that assigns two names on one line - so
# a reader that stopped at the first would see GAVE_UP and miss BLOCKED.
static func _assigned(code: String) -> Array:
	var found: Dictionary = {}
	var assign := RegEx.create_from_string("\\boutcome[ \t]*:?=[ \t]*(.+)$")
	var literal := RegEx.create_from_string("\"([A-Z][A-Z_0-9]*)\"")
	for raw in code.split("\n"):
		var m := assign.search(str(raw))
		if m == null:
			continue
		for lit in literal.search_all(m.get_string(1)):
			found[lit.get_string(1)] = true
	return _sorted(found)


# The same, restricted to one indented block: the lines below `opener` that are
# indented deeper than it is.
static func _assigned_in_block(body: String, opener: String) -> Array:
	var lines := body.split("\n")
	var start := -1
	var indent := 0
	for i in lines.size():
		var line := str(lines[i])
		if line.strip_edges() == opener:
			start = i
			indent = line.length() - line.lstrip("\t").length()
			break
	if start < 0:
		return []
	var inner := ""
	for i in range(start + 1, lines.size()):
		var line := str(lines[i])
		if line.strip_edges() == "":
			continue
		if line.length() - line.lstrip("\t").length() <= indent:
			break
		inner += line + "\n"
	return _assigned(inner)


# Every arm of a `match`: a line that is nothing but an ALL-CAPS string
# literal and a colon.
static func _arms(body: String) -> Array:
	var found: Dictionary = {}
	var arm := RegEx.create_from_string("^[ \t]*\"([A-Z][A-Z_0-9]*)\"[ \t]*:[ \t]*$")
	for raw in body.split("\n"):
		var m := arm.search(str(raw))
		if m != null:
			found[m.get_string(1)] = true
	return _sorted(found)


# Every ALL-CAPS literal handed to a named function at a call site.
static func _hand_called(code: String, fn: String) -> Array:
	var found: Dictionary = {}
	var call := RegEx.create_from_string(fn + "\\([ \t]*\"([A-Z][A-Z_0-9]*)\"")
	for m in call.search_all(code):
		found[m.get_string(1)] = true
	return _sorted(found)


# The returns at the function's OWN indentation - below the match, not inside
# an arm. "The last return" would be an assumption about the layout; this is a
# reading of it, and the row below asserts there is exactly one.
#
# AND WHAT IT DELIBERATELY DOES NOT SEE, found by an injection that did not
# land and written down rather than tidied away (TRAPS 89). A return nested
# inside a branch - `if outcome == "": return ""` at two tabs - is NOT counted,
# and an injection that added one read failures=0. That is correct and is the
# point: a guarded early return is not the arm an unmatched name takes. The
# cost is that this reader cannot answer anything about a fall-through that is
# itself conditional, and if one is ever written the row below will say there
# are none rather than noticing the shape changed.
static func _base_returns(body: String) -> Array:
	var out: Array = []
	var ret := RegEx.create_from_string("^\t?return[ \t]+(.+)$")
	for raw in body.split("\n"):
		var m := ret.search(str(raw))
		if m != null:
			out.append(m.get_string(1).strip_edges())
	return out


func _vocabulary_section() -> void:
	var controller := _source(CONTROLLER)
	var goals := _source(GOALS)
	var finish := _body_of(controller, "func finish_order(")
	var delivery := _body_of(goals, "static func delivery_line(")
	var errand := _body_of(goals, "static func outcome_line(")

	# Can this section fail at all? A scan that quietly read nothing would
	# satisfy every emptiness test below it (TRAPS 6).
	_check(finish != "" and delivery != "" and errand != "",
		"finish_order, delivery_line and outcome_line were all read (%d/%d/%d lines)" % [
			finish.split("\n").size(), delivery.split("\n").size(),
			errand.split("\n").size()])

	var produced := _assigned(finish)
	var carried := _assigned_in_block(finish, CARRY_BRANCH)
	var plain := _without(produced, carried)
	var delivery_arms := _arms(delivery)
	var errand_arms := _arms(errand)
	var hand := _hand_called(controller, "outcome_line")
	var arms_everywhere: Array = []
	for n in delivery_arms:
		arms_everywhere.append(str(n))
	for n in errand_arms:
		arms_everywhere.append(str(n))

	lines.append("  finish_order decides:      %s" % str(produced))
	lines.append("    carrying:                %s" % str(carried))
	lines.append("    not carrying:            %s" % str(plain))
	lines.append("  delivery_line arms:        %s" % str(delivery_arms))
	lines.append("  outcome_line arms:         %s" % str(errand_arms))
	lines.append("  hand-called, never decided: %s" % str(hand))

	_check(produced.size() >= 2 and not delivery_arms.is_empty() \
			and not errand_arms.is_empty(),
		"the three sets were read and none is empty - %d outcomes, %d + %d arms" % [
			produced.size(), delivery_arms.size(), errand_arms.size()])

	# A. the seventh outcome, added tomorrow with no sentence.
	_check(_without(produced, arms_everywhere).is_empty(),
		"every outcome finish_order can decide has an arm in one of the two sentence functions (no arm for %s)" % str(
			_without(produced, arms_everywhere)))

	# B and C. the wrong side of the branch. These are the rows that make A
	# more than a spelling check: an outcome CAN have an arm somewhere and
	# still reach the function that does not have it.
	_check(carried == delivery_arms,
		"the outcomes decided inside `%s` are EXACTLY delivery_line's arms (%s against %s)" % [
			CARRY_BRANCH, str(carried), str(delivery_arms)])
	_check(plain == _without(errand_arms, hand),
		"the outcomes decided on the other path are EXACTLY outcome_line's arms, less the ones only ever hand-called (%s against %s)" % [
			str(plain), str(_without(errand_arms, hand))])

	# D. no dead arm - the other direction, and controller_reach_test's rule
	# applied to outcomes rather than to refusals.
	_check(_without(arms_everywhere, produced + hand).is_empty(),
		"every arm is produced somewhere: decided by finish_order, or handed in by name at a call site (orphan %s)" % str(
			_without(arms_everywhere, produced + hand)))

	# E. and no name can be ambiguous about which sentence it gets.
	var both := _both_of(delivery_arms, errand_arms)
	_check(both.is_empty(),
		"the two arm sets are disjoint, so which function is handed a name decides its sentence (in both: %s)" % str(both))

	# F. WHY ALL OF THE ABOVE MATTERS, read rather than argued: an unmatched
	# name is answered, not refused. If these two returns ever became a crash
	# or a refusal the rows above would still be worth having, but they would
	# be guarding something loud instead of something silent.
	var d_base := _base_returns(delivery)
	var e_base := _base_returns(errand)
	_check(d_base.size() == 1 and e_base.size() == 1,
		"each sentence function has exactly one return below its match - the arm an unmatched outcome takes (%d, %d)" % [
			d_base.size(), e_base.size()])
	_check(d_base.size() == 1 and e_base.size() == 1 and d_base[0] == e_base[0],
		"and both fall through to the same sentence, so neither tells a player nor this suite that a name was missed: %s" % str(d_base))

	_vocabulary_controls()


# CAN EACH ROW ABOVE FAIL? Every reader is fed text it must answer differently
# about, so a row that passes because its reader sees nothing is caught here
# rather than in the commit that breaks it.
func _vocabulary_controls() -> void:
	var seventh := "\tvar outcome := \"GAVE_UP\" if why == \"gave up\" else \"BLOCKED\"\n\toutcome = \"ABANDONED\"\n"
	_check(_assigned(seventh) == ["ABANDONED", "BLOCKED", "GAVE_UP"],
		"a seventh outcome added to finish_order is seen by the reader row A uses (%s)" % str(_assigned(seventh)))

	var ternary := "\tvar outcome := \"GAVE_UP\" if why == \"gave up\" else \"BLOCKED\"\n"
	_check(_assigned(ternary) == ["BLOCKED", "GAVE_UP"],
		"and the initialiser's SECOND name is seen, which a reader that stopped at the first would miss (%s)" % str(
			_assigned(ternary)))

	var moved := "\tif carrying != \"\":\n\t\tif node == null:\n\t\t\toutcome = \"BLOCKED\"\n\telif module != null:\n\t\t\toutcome = \"ARRIVED\"\n"
	_check(_assigned_in_block(moved, CARRY_BRANCH) == ["BLOCKED"],
		"an outcome moved into the carrying branch is seen there and the one in the elif is not, which is what row B compares (%s)" % str(
			_assigned_in_block(moved, CARRY_BRANCH)))

	var two_arms := "\tmatch outcome:\n\t\t\"DELIVERED\":\n\t\t\treturn \"a\"\n\t\t\"INCONCLUSIVE\":\n\t\t\treturn \"b\"\n\treturn \"Nothing happened.\"\n"
	_check(_arms(two_arms) == ["DELIVERED", "INCONCLUSIVE"],
		"the arm reader finds the arms a match has (%s)" % str(_arms(two_arms)))
	_check(_arms(two_arms.replace("\t\t\"INCONCLUSIVE\":\n\t\t\treturn \"b\"\n", "")) == ["DELIVERED"],
		"and an arm removed from it stops being found, which is how row A fails")

	# Prose in, nothing out. An arm that exists only in a comment must not
	# answer a question about the code (TRAPS 63).
	_check(_arms(_code_of("\t\t# \"ABANDONED\":\n")).is_empty(),
		"an arm written in a COMMENT is not seen, so a comment cannot satisfy row A")
	_check(_assigned(_code_of("\t# outcome = \"ABANDONED\"\n")).is_empty(),
		"and neither is an assignment in a comment")
	_check(not _assigned(_code_of("\toutcome = \"ABANDONED\"\n")).is_empty(),
		"while the same two lines as CODE are both seen, so the two rows above are not passing on an empty read")

	# The slice, and the one thing that would silently widen it.
	var pair := "func finish_order(a: int) -> void:\n\toutcome = \"ARRIVED\"\n\n\nfunc _set_door(b: int) -> void:\n\toutcome = \"ABANDONED\"\n"
	_check(_assigned(_body_of(pair, "func finish_order(")) == ["ARRIVED"],
		"the slice stops at the next function, so a neighbour's assignment is not read as finish_order's (%s)" % str(
			_assigned(_body_of(pair, "func finish_order("))))
	_check(_base_returns(two_arms) == ["\"Nothing happened.\""],
		"and the fall-through reader ignores the returns inside the arms (%s)" % str(_base_returns(two_arms)))

	# A DIGIT IN THE NAME (138). All three readers took an ALL-CAPS identifier
	# to be letters and underscores only, so a name carrying a digit came back
	# TRUNCATED rather than missing - and a truncation that lands on a name
	# that already exists is SILENT, because the new name merges into the old
	# one's entry and no "has a row" assertion has anything to complain about.
	# These three fail against the character class this file carried until 138
	# and pass against the widened one. The reason they are readings and not a
	# table: `scripts/` holds ZERO ALL-CAPS literals with a digit today
	# (counted), so nothing here is a claim about the current tree.
	var digit_assign := "\toutcome = \"GAVE_UP2\"\n"
	_check(_assigned(digit_assign) == ["GAVE_UP2"],
		"an outcome name carrying a DIGIT is read whole, not truncated to the existing name it starts with (%s)" % str(
			_assigned(digit_assign)))

	var digit_arm := "\tmatch outcome:\n\t\t\"DELIVERED2\":\n\t\t\treturn \"a\"\n"
	_check(_arms(digit_arm) == ["DELIVERED2"],
		"and so is a match ARM's name (%s)" % str(_arms(digit_arm)))

	var digit_hand := "\toutcome_line(\"ARRIVED2\", room, 0.0, 0.0)\n"
	_check(_hand_called(digit_hand, "outcome_line") == ["ARRIVED2"],
		"and so is one HANDED to a named function, which is the reader row D uses (%s)" % str(
			_hand_called(digit_hand, "outcome_line")))


func _run() -> void:
	print("--- 123/124: what the errand resolves to, and whether it has a sentence ---")
	await _arrival_section()
	await _blocked_section()
	await _unreachable_section()
	_vocabulary_section()

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
