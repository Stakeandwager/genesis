extends SceneTree

# --- 040: the procedural claims that are settled by BUILDING the thing ---
#
# 039 split the prompt's procedural sentences - flat statements about what
# Genesis will do with what the model sends - into the ones that can be
# settled by DOING THE ARITHMETIC and the ones that cannot. formula_test is
# the door for the first six. This is the door for the rest: five claims 039
# measured BY HAND, recorded in HANDOVER as true and unguarded, and left for
# its own commit.
#
#   "Room 1 is the entrance, where the player comes in."
#   "R is a room's name or its number counting from 1."
#   "A door joins two different rooms, and the same pair may only be joined
#    once."
#   "The game can adjust each angle and each straight length by up to 20%."
#   "a new world replaces whatever was there before, whichever kind it was."
#
# Asked of the CLASS rather than of those five sentences (TRAPS 11), because
# a list written by reading is a sweep whose unit nobody checked (TRAPS 31) -
# which is the mistake 039 found in HANDOVER's own list of eight. Two of the
# five turned out to be members of larger classes, and both classes had a
# fault in them:
#
# THE REFERENCE DOORS. "R is a room's name or its number counting from 1" is
# one of FIVE places the prompt tells the model to name a piece of a world by
# its position in a list: a dungeon's door pairs, a thing's "in", an ORDER's
# "room", a SHUT or OPEN's "between", and a plan step's "around". Asked at
# the door rather than at the sentence (TRAPS 31's unit), every one bound-
# checks - so no caller can reach GDScript's array[-1], which is the LAST
# element and would have been a silent wrong answer. But a number that is
# not a WHOLE number was taken by int() to the room below it at FOUR of the
# five, in silence. "around" alone refused it and named the range, because
# 036 was the one session that asked. A drop is worse than a refusal because
# a refusal is visible (TRAPS 31), and Genesis's own prompt says of Genesis
# that "it REFUSES rather than clamping". Fixed in 040 at all five, through
# one reading in Readback.ordinal_index().
#
# THE REPLACEMENT. "a new world replaces whatever was there before" is one
# member of a rule Genesis follows everywhere else: a REFUSAL leaves what was
# there alone. A single world's refusal never reaches _build_world, and a
# plan refused for its SCHEMA returns before any clearing. But a PLAN cleared
# the world BEFORE working its steps out, so a plan holding one unbuildable
# world took the player's standing world away and then said it had built
# nothing - measured, a farm of 62 children down to 0. Fixed in 040 by
# clearing when a build is certain to start rather than before it is known
# whether one can.
#
# WHAT THIS SUITE ASSERTS, AND WHAT IT DOES NOT (TRAPS 6, TRAPS 14)
#
# Nothing here matches a sentence. Every claim is settled by building the
# thing the sentence describes and reading what came out, which is the only
# way these five can be settled at all: "the prompt says room 1 is the
# entrance" tests nothing.
#
# The units are enumerated, never quoted:
#   - the reference doors, against a sweep of the assembled prompt for the
#     phrases that DEFINE an ordinal, so a prompt that grows a sixth door
#     makes the count disagree and this suite FAILS rather than quietly not
#     covering it;
#   - the room permutations, all of them, rather than one reordering;
#   - the room pairs, every ordered pair, rather than one duplicate;
#   - the adjustable sections, from TrackGeometry's own type families;
#   - the worlds, every ORDERED PAIR from WorldRegistry.modules(), so a
#     world added later has rows here without this file being edited.
#
# NOT ASSERTED, deliberately, and both are the owner's with the measurements
# in HANDOVER:
#
#   - that a built section stays inside its type's own range. It does not: a
#     120 degree corner is built at 136.2. The 20% licence is what the prompt
#     states and that is what is asserted here; whether the stated range
#     should also bound what Genesis BUILDS is "Human decision needed" 9 and
#     an assertion either way would settle it on the owner's behalf.
#   - that a plan refused for OVERLAPPING leaves the world standing. It does
#     not, and 040 did not fix it: the overlap is found in pass 3 by
#     _place(), after the clear and after earlier steps are built, so making
#     it safe means knowing every footprint before building any of them.
#     That is a change to how a plan is built - "Human decision needed" 10.
#     It is left unasserted rather than asserted as correct, because a suite
#     that guards a fault is TRAPS 14 in its most literal form.

var failures: Array = []
var asserted := 0
var lines: Array = []
var c: GameController


func _initialize() -> void:
	_run.call_deferred()


func _check(ok: bool, what: String) -> void:
	asserted += 1
	lines.append(("PASS  " if ok else "FAIL  ") + what)
	if not ok:
		failures.append(what)


func _note(what: String) -> void:
	lines.append("      " + what)


# Each room's size belongs to its NAME, not to where it sits in the list, so
# a permutation carries the sizes with the names. That is what makes the
# entrance claim falsifiable: if size decided the entrance instead of
# position, the biggest room would lead every time, and it does not.
const ROOM_SIZES := {
	"hall": [12, 10], "vault": [20, 16], "crypt": [32, 28], "store": [8, 24],
}


func _rooms(names: Array) -> Array:
	var out: Array = []
	for n in names:
		var size: Array = ROOM_SIZES[str(n)]
		out.append({"name": str(n), "width": int(size[0]), "depth": int(size[1])})
	return out


# A line of doors joining every room of a dungeon this size, by position.
func _spanning(count: int) -> Array:
	var out: Array = []
	for i in range(1, count):
		out.append([i, i + 1])
	return out


# --------------------------------------------------------------------------
# 1. Every door the prompt offers a position at, asked at the DOOR
# --------------------------------------------------------------------------
#
# Each entry resolves a reference the way its own door does and reports the
# index counting from 0, or -1 for a refusal, plus the sentences the refusal
# carried. The door is the unit, not the field: 037 found that the same field
# name behaves differently at each command it is offered at.
func _resolve(door: String, given: Variant, rooms: Array) -> Dictionary:
	var dm := DungeonModule.new()
	var count := rooms.size()
	match door:
		"thing in":
			var p := {"rooms": rooms, "doors": _spanning(count),
				"things": [{"name": "key", "in": given}]}
			var r: Dictionary = dm.validate(p)
			if not r["ok"]:
				return {"at": -1, "errors": r["errors"]}
			return {"at": int((r["content"]["things"] as Array)[0]["in"]), "errors": []}
		"door pair":
			# The door under test is an EXTRA door on top of a spanning line,
			# paired with a room the line does not already join it to - "more
			# doors than rooms is allowed and makes loops", but the same pair
			# twice is refused, and a duplicate would be measuring the
			# uniqueness rule instead of the reference.
			var partner := _partner(given, rooms)
			var doors := _spanning(count)
			doors.append([given, partner])
			var r: Dictionary = dm.validate({"rooms": rooms, "doors": doors})
			if not r["ok"]:
				return {"at": -1, "errors": r["errors"]}
			var built: Vector2i = (r["content"]["doors"] as Array)[doors.size() - 1]
			# Which end of the built pair is the reference, told apart by the
			# end that is NOT the partner.
			var at := built.x if built.x != partner - 1 else built.y
			return {"at": at, "errors": []}
		"order room":
			var r := NpcGoals.validate({"goal": "go_to", "room": given}, rooms, [])
			if not r["ok"]:
				return {"at": -1, "errors": r["errors"]}
			return {"at": int(r["goal"]["room"]), "errors": []}
		"shut between":
			# A standing dungeon joined in a line, and a door that EXISTS in
			# it, so a refusal here is about the reference and never about the
			# layout - a door nothing joins has a sentence of its own.
			var layout_doors: Array = []
			for pair in _spanning(count):
				layout_doors.append(Vector2i(int(pair[0]) - 1, int(pair[1]) - 1))
			var neighbour := _neighbour(given, rooms)
			var r := NpcGoals.validate_door(
				{"between": [given, neighbour]}, rooms, {"doors": layout_doors})
			if not r["ok"]:
				return {"at": -1, "errors": r["errors"]}
			var a := int(r["door"]["a"])
			var b := int(r["door"]["b"])
			return {"at": a if a != neighbour - 1 else b, "errors": []}
		"plan around":
			# "around" names a STEP, so the list it counts into is the steps
			# BEFORE it: a plan of count + 1 steps with this one last puts the
			# same range in front of it as a dungeon of count rooms puts in
			# front of a room reference.
			var problem := WorldRegistry.around_problem(
				{"command": "CREATE_FARM", "around": given}, count + 1, count + 1)
			if problem != "":
				return {"at": -1, "errors": [problem]}
			return {"at": int(Readback.as_number(given)) - 1, "errors": []}
	return {"at": -1, "errors": ["this suite has no measurement for the door '%s'" % door]}


# Which room a reference is MEANT to name, worked out here rather than by
# calling the function under test: a harness that asks the code it is
# measuring where to point ends up agreeing with it. Numbers count from 1 and
# must be whole; a name is matched against this suite's own room list. -1
# when the reference is not meant to name anything.
func _intended(given: Variant, rooms: Array) -> int:
	if typeof(given) == TYPE_INT or typeof(given) == TYPE_FLOAT:
		var number := float(given)
		if number != floor(number) or number < 1.0 or number > float(rooms.size()):
			return -1
		return int(number)
	var wanted := str(given)
	for i in rooms.size():
		if str((rooms[i] as Dictionary)["name"]) == wanted:
			return i + 1
	return -1


# A room for the door under test to be joined to that the spanning line has
# not already joined it to. With a line 1-2-3-...-n the adjacent pairs are
# taken, so a room two along is always free. A reference that is not meant to
# name a room gets room 1, and the door is then refused for the reference.
func _partner(given: Variant, rooms: Array) -> int:
	var number := _intended(given, rooms)
	if number < 0:
		return 1
	return number + 2 if number + 2 <= rooms.size() else number - 2


# A room the spanning line really does join this one to, for SHUT and OPEN.
func _neighbour(given: Variant, rooms: Array) -> int:
	var number := _intended(given, rooms)
	if number < 0:
		return 1
	return number + 1 if number < rooms.size() else number - 1


# Does the prompt offer a NAME at this door as well as a number?
func _names_allowed(door: String) -> bool:
	return door in ["thing in", "order room", "shut between"]


func _doors_in_prompt(prompt: String) -> int:
	# The phrases the prompt defines an ordinal WITH. Counted rather than
	# listed, so a sixth reference added to the prompt changes this number
	# and the assertion below fails - the sweep says something when it is
	# wrong instead of saying nothing (TRAPS 31).
	var found := 0
	for phrase in ["counting from 1", "1 for the first"]:
		var at := prompt.find(phrase)
		while at >= 0:
			found += 1
			at = prompt.find(phrase, at + 1)
	return found


func _run() -> void:
	var prompt := AIInterpreter.assembled_prompt()
	# Four rooms, joined in a line, because the door-pair door needs a room
	# the line has not already joined this one to and a line of three leaves
	# the middle room without one.
	var rooms := _rooms(["hall", "vault", "crypt", "store"])
	var count := rooms.size()

	var reference_doors := ["thing in", "door pair", "order room", "shut between", "plan around"]

	# --------------------------------------------------------------------
	# The prompt's ordinal definitions and the doors this suite measures.
	# --------------------------------------------------------------------
	# Four of the five doors carry one of the defining phrases. The fifth,
	# SHUT and OPEN's "between", carries none: its skeleton uses the token
	# ROOM, which the ORDERS section defines once, at the other end of the
	# prompt. So the expected count is four, and it is written down WITH its
	# reason, because an unexplained magic number in a sweep is how the next
	# session learns nothing from it.
	var defined := _doors_in_prompt(prompt)
	_note("the prompt defines an ordinal %d times; this suite measures %d doors" % [
		defined, reference_doors.size()])
	_check(defined == reference_doors.size() - 1,
		"every ordinal the prompt defines has a door in this suite (SHUT's 'between' takes the token ROOM, defined under ORDERS)")

	for door in reference_doors:
		# A whole number counts from 1.
		for at in range(1, count + 1):
			var got: Dictionary = _resolve(door, at, rooms)
			_check(int(got["at"]) == at - 1,
				"%s: the number %d is position %d counting from 0" % [door, at, at - 1])

		# A whole number that arrived as a float - which is EVERY number a
		# model sends, because JSON.parse makes them all floats - counts the
		# same. A whole-number check that rejected 2.0 would refuse every
		# ordinary request.
		var as_float: Dictionary = _resolve(door, float(count), rooms)
		_check(int(as_float["at"]) == count - 1,
			"%s: %d sent as a JSON float is still position %d" % [door, count, count])

		# Nothing outside the list resolves, and nothing resolves to a
		# NEGATIVE index: in GDScript array[-1] is the last element, so an
		# unchecked reference would answer with the wrong piece rather than
		# refusing. Measured at both ends and past both.
		for bad in [0, -1, -count, count + 1, count + 99]:
			var got: Dictionary = _resolve(door, bad, rooms)
			_check(int(got["at"]) < 0, "%s: %d is refused, not resolved" % [door, bad])
			_check(not (got["errors"] as Array).is_empty(),
				"%s: %d is refused with something said" % [door, bad])

		# --- the fault 040 fixed, at every door rather than at one ---
		# A number that is not whole is not a position. It used to be taken
		# to the position below it in silence at four of these five.
		for fraction in [1.5, 2.9, float(count) + 0.5, 0.5]:
			var got: Dictionary = _resolve(door, fraction, rooms)
			_check(int(got["at"]) < 0,
				"%s: %s is refused rather than truncated" % [door, String.num(fraction, 2)])
			var said := ""
			for e in (got["errors"] as Array):
				said += str(e) + " "
			# And the refusal names what a legal one would be, which is the
			# rule every field refusal in Genesis has followed since 030 and
			# every container refusal since 034.
			_check(said.contains("whole"),
				"%s: refusing %s says a position is a whole number" % [door, String.num(fraction, 2)])
			_check(said.contains(str(count)),
				"%s: refusing %s names the range it must be inside" % [door, String.num(fraction, 2)])

		# A name, where the prompt offers one.
		if _names_allowed(door):
			for i in count:
				var name := str((rooms[i] as Dictionary)["name"])
				var got: Dictionary = _resolve(door, name, rooms)
				_check(int(got["at"]) == i,
					"%s: the name '%s' is the same room as the number %d" % [door, name, i + 1])
			var missing: Dictionary = _resolve(door, "nowhere_at_all", rooms)
			_check(int(missing["at"]) < 0, "%s: a name no room has is refused" % door)
		else:
			# And where it does not, a name is refused rather than guessed at.
			var got: Dictionary = _resolve(door, str((rooms[0] as Dictionary)["name"]), rooms)
			_check(int(got["at"]) < 0,
				"%s: a name is refused at a door the prompt offers only numbers at" % door)

	# --------------------------------------------------------------------
	# 2. "Room 1 is the entrance, where the player comes in."
	# --------------------------------------------------------------------
	# The claim is that POSITION decides the entrance - not the name, not the
	# size, not the door graph. So it is asked by permuting the list and
	# watching where the entrance goes, over every permutation rather than
	# one reordering. Three rooms of three different sizes and names, joined
	# in a line, so each permutation is the same dungeon described in a
	# different order.
	var dm := DungeonModule.new()
	var permutations := [
		["hall", "vault", "crypt"], ["hall", "crypt", "vault"],
		["vault", "hall", "crypt"], ["vault", "crypt", "hall"],
		["crypt", "hall", "vault"], ["crypt", "vault", "hall"]]
	var entrances: Array = []
	for order in permutations:
		var these := _rooms(order)
		var r: Dictionary = dm.validate({"rooms": these, "doors": _spanning(these.size())})
		if not r["ok"]:
			_check(false, "the %s dungeon validates" % str(order))
			continue
		var solved: Dictionary = dm.solve(r["content"])
		if not bool(solved["ok"]):
			_check(false, "the %s dungeon solves" % str(order))
			continue
		var layout: Dictionary = solved["layout"]
		var slots: Dictionary = layout["slots"]
		# The entrance is where the body comes in, and build() takes rects[0]
		# - the room in slot 0, which solve() seeds with the FIRST room and
		# nothing reorders. Asserted as "the first room in the list I sent",
		# never as "the room called hall".
		_check(Vector2i(slots[0]) == Vector2i.ZERO,
			"rooms %s: the first room in the list holds the entrance slot" % str(order))
		var entrance: Dictionary = layout["rooms"][0]
		_check(str(entrance["name"]) == str(order[0]),
			"rooms %s: nothing between validate() and build() reordered the list" % str(order))
		# And it is the room that was written first, carrying its OWN size -
		# so the claim is about position and not about which room the sizes
		# make special.
		var own: Array = ROOM_SIZES[str(order[0])]
		_check(int(entrance["width"]) == int(own[0]) and int(entrance["depth"]) == int(own[1]),
			"rooms %s: the entrance is %s at its own %d by %d m" % [
				str(order), str(order[0]), int(own[0]), int(own[1])])
		entrances.append(str(entrance["name"]))

	# The falsifying half (TRAPS 6): if SIZE decided the entrance rather than
	# position, the same room would lead every permutation. Three different
	# rooms lead, and the biggest is not one of them more often than the
	# smallest.
	_check(entrances.size() == permutations.size(),
		"every permutation produced an entrance")
	var distinct := {}
	for e in entrances:
		distinct[str(e)] = true
	_check(distinct.size() == 3,
		"three different rooms are the entrance across the six permutations, so position decides and not size")
	_note("entrances, in permutation order: %s" % ", ".join(entrances))

	# And the consequence a player meets, which is what makes the claim worth
	# holding: the deepest room is measured FROM the entrance. The same three
	# rooms with the same door SHAPE - a star from the first room, against a
	# line through all three - are a different dungeon, and the only thing
	# that says which room the star is centred on is its position.
	var star: Dictionary = dm.solve((dm.validate(
		{"rooms": _rooms(["hall", "vault", "crypt"]), "doors": [[1, 2], [1, 3]]}) as Dictionary)["content"])
	var in_a_line: Dictionary = dm.solve((dm.validate(
		{"rooms": _rooms(["hall", "vault", "crypt"]), "doors": [[1, 2], [2, 3]]}) as Dictionary)["content"])
	# "deepest" is the measurement the player is shown - "crypt, two doors
	# from the entrance" - and it is counted FROM ROOM 1, so it is the
	# cheapest proof that the entrance is where the claim says it is.
	var star_deep := int((dm.measure(star["layout"]) as Dictionary)["deepest"])
	var line_deep := int((dm.measure(in_a_line["layout"]) as Dictionary)["deepest"])
	_note("from the entrance: a star is %d door(s) deep, a line is %d" % [star_deep, line_deep])
	_check(star_deep == 1 and line_deep == 2,
		"depth is counted from room 1: the same three rooms are 1 door deep around it and 2 in a line from it")

	# --------------------------------------------------------------------
	# 3. "A door joins two different rooms, and the same pair may only be
	#     joined once."
	# --------------------------------------------------------------------
	# Two halves, and the second has a case a normalisation can get wrong:
	# [1, 2] and then [2, 1] are the same pair written backwards. Asked over
	# every ordered pair rather than at one example.
	for a in range(1, count + 1):
		# Half one: a room cannot have a door to itself.
		var self_door: Dictionary = dm.validate({"rooms": rooms, "doors": [[a, a]]})
		_check(not self_door["ok"], "a door from room %d to itself is refused" % a)
		var said := ""
		for e in (self_door["errors"] as Array):
			said += str(e) + " "
		_check(said.contains(str(1)) or said.contains("itself") or said.contains("different"),
			"refusing the door from room %d to itself says why" % a)

		for b in range(1, count + 1):
			if a == b:
				continue
			# Half two: the same pair twice, written forwards and backwards.
			# A line of doors that would otherwise be legal, with the
			# duplicate added, so the refusal is about the duplicate.
			for second in [[a, b], [b, a]]:
				var dup: Dictionary = dm.validate({"rooms": rooms, "doors": [[a, b], second]})
				_check(not dup["ok"],
					"[%d, %d] then %s is refused as the same pair twice" % [a, b, str(second)])

			# And the pair ONCE is accepted, so the rule above is not simply
			# refusing everything (TRAPS 6: a check that cannot pass is as
			# useless as one that cannot fail).
			var once: Dictionary = dm.validate({"rooms": rooms, "doors": _line_through(a, b, count)})
			_check(once["ok"], "rooms %d and %d joined once is accepted" % [a, b])

	# --------------------------------------------------------------------
	# 4. "The game can adjust each angle and each straight length by up to
	#     20% to close the loop."
	# --------------------------------------------------------------------
	# EACH, which is the half nothing held: prompt_bounds_test has asserted
	# the 20% against ClosureSolver's constants since 035, and that a number
	# matches a constant says nothing about how many sections it applies to.
	# So the adjustable set is counted against the sections that HAVE an
	# angle or a length, from TrackGeometry's own families - the same lists
	# the solver, the gate and the geometry all read.
	for circuit in _circuits():
		var sections: Array = circuit["sections"]
		var what := str(circuit["what"])
		var eligible := 0
		for s in sections:
			var t := str((s as Dictionary)["type"])
			if t in TrackGeometry.STRAIGHT_FAMILY or t in TrackGeometry.YAW_TYPES:
				eligible += 1
		var gate := FeasibilityGate.check(sections)
		if not bool(gate["ok"]):
			_check(false, "%s: the feasibility gate accepts it" % what)
			continue
		# The target the gate itself worked out, never 360 written out here:
		# a circuit the gate decided turns anticlockwise is solved against
		# -360, and handing it +360 would measure a different circuit.
		var solved := ClosureSolver.solve(sections, float(gate["target_turn"]))

		# "each": every section that turns or stretches is one the solver may
		# move. A chicane has neither an angle nor a length and is not in
		# either family, which is why the prompt's own sentence names angles
		# and straight lengths and not sections.
		var movable := 0
		for s in (solved["sections"] as Array):
			var t := str((s as Dictionary)["type"])
			if t in TrackGeometry.STRAIGHT_FAMILY or t in TrackGeometry.YAW_TYPES:
				movable += 1
		_check(movable == eligible,
			"%s: all %d sections with an angle or a length are the solver's to move" % [what, eligible])

		# "by up to 20%": the limit the sentence states, read off the solver
		# rather than written out here, and compared with what it actually
		# did. 035 holds the constant against the prompt; this holds the
		# WORK against the constant.
		var angle_used := float(solved["max_angle_adjustment"])
		var length_used := float(solved["max_length_adjustment"])
		_check(angle_used <= float(solved["angle_limit"]) + 1.0e-9,
			"%s: the largest angle adjustment %.2f%% is inside the stated %.0f%%" % [
				what, angle_used * 100.0, float(solved["angle_limit"]) * 100.0])
		_check(length_used <= float(solved["length_limit"]) + 1.0e-9,
			"%s: the largest length adjustment %.2f%% is inside the stated %.0f%%" % [
				what, length_used * 100.0, float(solved["length_limit"]) * 100.0])
		_note("%s: closed=%s, angle moved %.2f%%, length moved %.2f%%" % [
			what, str(solved["ok"]), angle_used * 100.0, length_used * 100.0])

	# --------------------------------------------------------------------
	# 5. "a new world replaces whatever was there before, whichever kind it
	#     was."
	# --------------------------------------------------------------------
	var root := Node3D.new()
	get_root().add_child(root)
	c = GameController.new()
	root.add_child(c)
	c.setup(root)
	await process_frame

	# Every ORDERED pair, from the registry rather than from a list written
	# here, so the day a fourth world exists it has rows without this file
	# being touched - and a world whose module gives no buildable request
	# FAILS rather than being skipped.
	var kinds: Array = []
	for command in WorldRegistry.commands():
		var parameters := _request(str(command))
		_check(not parameters.is_empty(),
			"this suite has a buildable request for %s" % str(command))
		if parameters.is_empty():
			continue
		kinds.append({"command": str(command), "parameters": parameters})

	for first in kinds:
		for second in kinds:
			var one: Dictionary = first
			var two: Dictionary = second
			c.execute(str(one["command"]), one["parameters"])
			await process_frame
			var after_one := c.world_node.get_child_count()
			_check(after_one > 0, "%s builds something" % str(one["command"]))
			c.execute(str(two["command"]), two["parameters"])
			await process_frame
			var after_two := c.world_node.get_child_count()

			# The second world's own count, measured from a clean start, is
			# what "replaces" means: not fewer children than before, not
			# some - exactly the second world and nothing else.
			c.execute("CLEAR_WORLD", {})
			await process_frame
			c.execute(str(two["command"]), two["parameters"])
			await process_frame
			var alone := c.world_node.get_child_count()
			_check(after_two == alone,
				"%s after %s leaves exactly one %s and nothing of the %s" % [
					str(two["command"]), str(one["command"]), str(two["command"]), str(one["command"])])

	# And the half of the rule that is about a refusal: a world that is
	# REFUSED does not replace anything, because the clear lives where the
	# building does. The refused request is one the world's OWN validator
	# refuses - named per command for the same reason the buildable one is,
	# so a world added later has a row rather than a gap.
	#
	# NOT asked with a sectionless CREATE_TRACK, and the reason matters: that
	# is not a refused circuit, it is Prototype 001's ring, which clears the
	# world and then reports that it built nothing. This suite found that by
	# itself when the refused request was `{}`. It is the third member of
	# this class, it has been measured since 032, and it is left alone here
	# because it is "Human decision needed" 2 - the owner's call on whether
	# the three stubs are rebuilt or taken out of the whitelist. Asserting
	# either behaviour would settle that for him.
	for kind in kinds:
		var k: Dictionary = kind
		var refused := _refused_request(str(k["command"]))
		_check(not refused.is_empty(),
			"this suite has a refused request for %s" % str(k["command"]))
		if refused.is_empty():
			continue
		c.execute(str(k["command"]), k["parameters"])
		await process_frame
		var standing := c.world_node.get_child_count()
		_check(standing > 0, "the %s this refusal is sent against is standing" % str(k["command"]))
		c.execute(str(k["command"]), refused)
		await process_frame
		_check(c.world_node.get_child_count() == standing,
			"a refused %s leaves the standing world standing" % str(k["command"]))

	# A PLAN is the case that was broken, and it was broken at one of its two
	# refusal layers rather than both - which is why it is asked at both.
	var farm := _request("CREATE_FARM")
	var unbuildable := {"rooms": [{"name": "only_one", "width": 8, "depth": 8}], "doors": []}
	var plans := [
		{"what": "a plan refused for its SCHEMA", "steps": [
			{"command": "CREATE_FARM", "parameters": farm},
			{"command": "CREATE_DUNGEON", "around": 9, "parameters": _request("CREATE_DUNGEON")}]},
		{"what": "a plan with a step that cannot be worked out", "steps": [
			{"command": "CREATE_FARM", "parameters": farm},
			{"command": "CREATE_DUNGEON", "parameters": unbuildable}]},
		{"what": "a plan whose only step cannot be worked out", "steps": [
			{"command": "CREATE_DUNGEON", "parameters": unbuildable}]},
	]
	for entry in plans:
		var plan: Dictionary = entry
		c.execute("CREATE_FARM", farm)
		await process_frame
		var standing := c.world_node.get_child_count()
		_check(standing > 0, "the farm the plan is sent against is standing")
		c.execute("PLAN", {"steps": plan["steps"]})
		await process_frame
		await process_frame
		_check(c.world_node.get_child_count() == standing,
			"%s leaves the standing world standing" % str(plan["what"]))

	# A plan that WORKS still replaces, so the fix above did not buy safety
	# by never clearing at all.
	c.execute("CREATE_FARM", farm)
	await process_frame
	var before_plan := c.world_node.get_child_count()
	c.execute("PLAN", {"steps": [
		{"command": "CREATE_FARM", "parameters": farm},
		{"command": "CREATE_DUNGEON", "around": 1, "parameters": _request("CREATE_DUNGEON")}]})
	await process_frame
	await process_frame
	var after_plan := c.world_node.get_child_count()
	_check(after_plan > 0 and after_plan != before_plan,
		"a plan that builds still replaces what was there (%d -> %d)" % [before_plan, after_plan])

	for out in lines:
		print(out)
	print("")
	print("PROCEDURE %d assertions, failures=%d" % [asserted, failures.size()])
	for f in failures:
		print("  - %s" % str(f))
	quit(0)


# A line of doors joining every room, with a and b joined exactly once. Built
# rather than written out, so the "accepted" half of the uniqueness rule is
# exercised at every pair the refusal half is.
func _line_through(a: int, b: int, count: int) -> Array:
	var out: Array = [[a, b]]
	for i in range(1, count + 1):
		if i == a or i == b:
			continue
		out.append([a, i])
	return out


# The smallest buildable request for each world, named from the command so a
# world added to the registry without one is a FAILURE above rather than a
# silent gap. The numbers are inside every bound the prompt states.
func _request(command: String) -> Dictionary:
	match command:
		"CREATE_FARM":
			return {"zones": [
				{"type": "crop", "crop": "wheat", "width": 80, "depth": 60},
				{"type": "barn", "width": 20, "depth": 15}]}
		"CREATE_TRACK":
			var sections: Array = []
			for i in 4:
				sections.append({"type": "straight", "length": 300})
				sections.append({"type": "corner", "radius": 60, "angle": 90})
			return {"mode": "circuit", "sections": sections}
		"CREATE_DUNGEON":
			return {"rooms": [
				{"name": "hall", "width": 12, "depth": 10},
				{"name": "vault", "width": 20, "depth": 16}], "doors": [[1, 2]]}
	return {}


# A request each world's own validator refuses, named from the command so a
# world added to the registry without one is a FAILURE rather than a silent
# gap. Each is refused for a COUNT, which every world validator checks, so
# none of them reaches a builder.
func _refused_request(command: String) -> Dictionary:
	match command:
		"CREATE_FARM":
			return {"zones": []}
		"CREATE_TRACK":
			# "mode" and "sections" present, so this is a composed circuit
			# being refused and not Prototype 001's sectionless ring.
			return {"mode": "circuit", "sections": []}
		"CREATE_DUNGEON":
			return {"rooms": [{"name": "only_one", "width": 8, "depth": 8}], "doors": []}
	return {}


# Circuits for the adjustment claim: one that closes by itself, one that needs
# the licence, and one with a chicane in it - the type that has neither an
# angle nor a length and so is NOT the solver's to move. Only types from
# SectionValidator.OFFERED_TYPES, never SECTION_TYPES (TRAPS 19's wall).
func _circuits() -> Array:
	var square: Array = []
	for i in 4:
		square.append({"type": "straight", "length": 300})
		square.append({"type": "corner", "radius": 60, "angle": 90})

	var needs_closing: Array = []
	for i in 4:
		needs_closing.append({"type": "straight", "length": 300 if i % 2 == 0 else 280})
		needs_closing.append({"type": "corner", "radius": 60, "angle": 88})

	var with_chicane: Array = []
	for i in 4:
		with_chicane.append({"type": "straight", "length": 300})
		with_chicane.append({"type": "corner", "radius": 60, "angle": 90})
	with_chicane.insert(1, {"type": "chicane", "radius": 40, "offset": 20, "direction": "left"})

	return [
		{"what": "a square circuit", "sections": square},
		{"what": "a circuit that needs the licence", "sections": needs_closing},
		{"what": "a circuit with a chicane", "sections": with_chicane},
	]
