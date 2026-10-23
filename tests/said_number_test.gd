extends SceneTree

# --- 041: the number a refusal says back, at every door that says one ---
#
# HANDOVER named the next assistant task as 040's question turned round. 040
# found a CORRECT RULE - a reference by position must be a whole number -
# written out in WorldRegistry.around_problem() by 036 and never carried to
# the four other doors of its class. So the question for every fix in TRAPS 1
# to 34 is not "did it reappear" but: IS THE RULE IT PRODUCED APPLIED
# EVERYWHERE IT HOLDS, OR ONLY WHERE THE FAULT WAS FOUND?
#
# Asked of TRAPS 34's own fifth rule, the answer is "only where the fault was
# found", and it costs a refusal a player cannot act on.
#
# THE RULE (TRAPS 34, written one commit ago): "A number said back is said as
# the player wrote it. Every number is a float by the time a refusal prints
# it, so Readback.number_said() prints 0 as '0' and not '0.0'."
#
# 040 applied it at the five reference doors it was looking at. EIGHT OTHER
# DOORS SAY A REQUEST'S NUMBER BACK AND EVERY ONE OF THEM RENDERED IT BY
# HAND, in three different styles - and all three ROUND. Measured headless
# against the pre-041 code, every one of the five validators could be made to
# name a value INSIDE the range the same sentence says it is outside:
#
#   width 40.4    room 1: width is 40 m, and must be 4 to 40 m
#   width 3.6     room 1: width is 4 m, and must be 4 to 40 m
#   barn 60.4     zone 1 (barn): width 60 m is outside 5-60 m
#   length 1000.04  section 1 (straight): length is 1000.0 m, and must be 20 to 1000 m
#   angle 9.996   section 1 (corner): angle is 10.00 degrees, and must be 10 to 120
#   grip 20.4     grip is 20, and a car's grip must be 2 to 20
#   footing 1.504 footing is 1.504 -> "1.50", and boots' footing must be 0.40 to 1.50
#
# A refusal that names a legal value is TRAPS 18's fault with the limit
# present: the player is told the number they sent is out of range and the
# number they are shown is in it. There is nothing they can act on.
#
# AND THE ONE READING ITSELF HAD THE FAULT AT ITS EDGE. number_said() ended
# String.num(number, 2), which rounds: 1.504 came back "1.50" against a bound
# printed "1.50". So this was not only a fix that failed to reach its class -
# the fix was not sufficient at the door it was written for. 041 makes the
# precision faithful (String.num(number, -1)) and routes all eight doors
# through it. A BOUND is deliberately not said this way: a bound is a
# constant at its own natural precision (TRAPS 28), which is why boots keep
# "0.40 to 1.50" while the value between them is said exactly.
#
# WHY NO SUITE SAW IT, which is the part worth keeping. capability_test has
# asserted "a number outside its limits is refused with the limit named" for
# every bound in all five validators since 028 - TRAPS 11 done properly, the
# whole class enumerated from the constants. It probes limits.y * 10.0 + 7.0
# and a value far below the minimum. BOTH PROBES ARE EFFECTIVELY WHOLE
# NUMBERS, so every rounding style renders them faithfully and the check
# could not fail. TRAPS 6 at the choice of probe rather than at the
# assertion: the class was right, the doors were right, and the VALUES were
# the one axis nobody varied. This suite is that suite's enumeration with the
# probes moved to the edge of each bound.
#
# WHAT THIS SUITE ASSERTS: that a refusal about a bounded field names the
# number that was sent, and that the number it names is still outside the
# bound the same sentence states. Both are facts and neither is a wording:
# every sentence here may be rewritten and these assertions stay green.
#
# WHAT IT DOES NOT ASSERT, deliberately, because it is the owner's and not a
# defect this suite should freeze either way (TRAPS 14: a suite that guards a
# fault is the most literal form of it). A READBACK rounds a measurement to
# whole metres, and that is a sentence about what will be BUILT rather than a
# misquote of a request, so it is left out of the assertions and written down
# here with its measurement instead. Measured headless this session:
#
#   rooms 12.4 and 20.5 m   "entered through a 12 m hall, along with a 20 m vault"
#   barn 30.4 by 20.6 m     "a farm with a 30 by 21 m barn"
#   straights 200.4 m       "two 200 m straights and two 50 m corners, 90 deg right"
#
# The world really is built at 12.4 m, so the sentence rounds a true fact
# rather than inventing one; whether a readback should say "a 12.4 m hall" is
# a judgement about prose and it is HANDOVER's "Human decision needed" 11.

var bad := 0
var asserted := 0


func _check(ok: bool, what: String) -> void:
	asserted += 1
	print(("PASS  " if ok else "FAIL  ") + what)
	if not ok:
		bad += 1


func _initialize() -> void:
	_the_one_reading_is_faithful()
	_the_check_can_tell_a_number_is_there()
	_a_refusal_names_the_number_that_was_sent()
	_the_reference_doors_say_it_the_same_way()

	print("SAID NUMBER %d assertions, failures=%d" % [asserted, bad])
	quit(1 if bad > 0 else 0)


# --- the one reading, before any door is asked ---
#
# number_said() is the function all thirteen doors now share, so its own
# behaviour is asserted first and as a round trip rather than as a string
# where a string would be a wording. The one literal case kept is the one
# TRAPS 34 states in words - 0 is "0" and not "0.0" - because that sentence
# is the reason the function exists.
func _the_one_reading_is_faithful() -> void:
	_check(Readback.number_said(0.0) == "0",
		"number_said(0.0) is \"0\" and not \"0.0\" (TRAPS 34's own sentence)")
	_check(Readback.number_said(500.0) == "500",
		"a whole number takes no decimal point: %s" % Readback.number_said(500.0))
	_check(Readback.number_said(null) == "nothing",
		"and a value that is not a number at all is \"nothing\"")

	# The half that was wrong: a fraction must survive being said. This is a
	# round trip and not a quoted string, so the rendering may change as long
	# as it still means the number that went in.
	for value in [40.4, 1.504, 1.5004, 2.5, -0.4, 60.4, 9.996, 1000.04, 0.396, 700.5]:
		var said := Readback.number_said(value)
		_check(is_equal_approx(said.to_float(), float(value)),
			"number_said(%s) comes back as the same number: %s" % [
				String.num(value, 4), said])


# A positive control for the check this suite leans on (TRAPS 26: a "the
# sentence does not say X" assertion passes for free the day the sentence
# changes, so make it say X first from a value that should produce it).
func _the_check_can_tell_a_number_is_there() -> void:
	_check(_names(" width is 40.4 m, and must be 4 to 40 m", "40.4"),
		"the control finds a number that IS named")
	_check(not _names(" width is 40 m, and must be 4 to 40 m", "40.4"),
		"and does not find one that is not")
	# And the reason this is not a plain `contains`: the digits of a number
	# are inside longer numbers and inside "section 1". A rendering counts
	# only where neither neighbour is a digit or a point.
	_check(not _names("section 1 (straight): length is 1000.4 m", "1000"),
		"and does not find \"1000\" inside \"1000.4\"")
	_check(not _names("room 1: width is 2.5 m", "5"),
		"and does not find \"5\" inside \"2.5\"")
	_check(_names("room 1: width is 2.5 m", "1"),
		"and DOES find \"1\" where it stands alone, which \"room 1\" is")


# --- the claim, at every bound in all five validators ---
#
# The enumeration is capability_test's, because that is the list that is
# already right: every bound Genesis has, read from its own constant and
# never typed in here (TRAPS 13 - an assertion that hardcodes a limit starts
# lying the day the limit moves). What is different is the PROBE. A value
# whose rounded form lands on the bound is the only input that can show this
# fault, and three deltas are used because three rounding styles existed:
# 0.4 defeats "%.0f", 0.04 defeats "%.1f", 0.004 defeats "%.2f".
func _a_refusal_names_the_number_that_was_sent() -> void:
	var car := CarTool.new()
	for field in ["power", "braking", "steering", "grip"]:
		var limits: Vector2 = car.get(field.to_upper())
		_at_the_edges(limits, func(value: float) -> Array:
			var r: Dictionary = car.validate({"tool": "car", "spec": {field: value}})
			return [bool(r["ok"]), r["errors"]], "a car's %s" % field, field)

	var boots := BootsTool.new()
	for field in ["push", "weight", "footing", "turning", "brake"]:
		var pair: Array = boots.get(field.to_upper())
		var limits := Vector2(float(pair[0]), float(pair[1]))
		_at_the_edges(limits, func(value: float) -> Array:
			var r: Dictionary = boots.validate({"tool": "boots", "spec": {field: value}})
			return [bool(r["ok"]), r["errors"]], "boots' %s" % field, field)

	var farm := FarmModule.new()
	_at_the_edges(FarmModule.BUILDING_SIDE, func(value: float) -> Array:
		var r: Dictionary = farm.validate({"zones": [{"type": "barn", "width": value, "depth": 20}]})
		return [bool(r["ok"]), r["errors"]], "a farm barn's width", "width")
	_at_the_edges(FarmModule.FIELD_SIDE, func(value: float) -> Array:
		var r: Dictionary = farm.validate({"zones": [{"type": "pond", "width": value, "depth": 60}]})
		return [bool(r["ok"]), r["errors"]], "a farm pond's width", "width")

	var dungeon := DungeonModule.new()
	var room_side := Vector2(DungeonModule.MIN_SIDE, DungeonModule.MAX_SIDE)
	_at_the_edges(room_side, func(value: float) -> Array:
		var r: Dictionary = dungeon.validate({
			"rooms": [{"width": value, "depth": 10}, {"width": 10, "depth": 10}],
			"doors": [[1, 2]]})
		return [bool(r["ok"]), r["errors"]], "a dungeon room's width", "width")

	var filler := {"type": "straight", "length": 100.0}
	var track := func(section: Dictionary) -> Array:
		var r: Dictionary = SectionValidator.validate({"sections": [section, filler]})
		return [bool(r["ok"]), r["errors"]]

	_at_the_edges(SectionValidator.STRAIGHT_LENGTH, func(v: float) -> Array:
		return track.call({"type": "straight", "length": v}), "a straight's length", "length")
	_at_the_edges(SectionValidator.GRADE_RANGE, func(v: float) -> Array:
		return track.call({"type": "uphill", "length": 100.0, "grade": v}), "an uphill's grade", "grade")
	_at_the_edges(SectionValidator.CORNER_RADIUS, func(v: float) -> Array:
		return track.call({"type": "corner", "radius": v, "angle": 90.0}), "a corner's radius", "radius")
	_at_the_edges(SectionValidator.CORNER_ANGLE, func(v: float) -> Array:
		return track.call({"type": "corner", "radius": 50.0, "angle": v}), "a corner's angle", "angle", true)
	_at_the_edges(SectionValidator.HAIRPIN_RADIUS, func(v: float) -> Array:
		return track.call({"type": "hairpin", "radius": v, "angle": 180.0}), "a hairpin's radius", "radius")
	_at_the_edges(SectionValidator.HAIRPIN_ANGLE, func(v: float) -> Array:
		return track.call({"type": "hairpin", "radius": 30.0, "angle": v}), "a hairpin's angle", "angle", true)
	_at_the_edges(SectionValidator.CHICANE_RADIUS, func(v: float) -> Array:
		return track.call({"type": "chicane", "radius": v, "offset": 5.0, "direction": "left"}),
		"a chicane's radius", "radius")
	_at_the_edges(SectionValidator.LOOP_RADIUS, func(v: float) -> Array:
		return track.call({"type": "loop_segment", "radius": v, "angle": 180.0}), "a loop's radius", "radius")
	_at_the_edges(SectionValidator.LOOP_ANGLE, func(v: float) -> Array:
		return track.call({"type": "loop_segment", "radius": 30.0, "angle": v}), "a loop's angle", "angle", true)
	_at_the_edges(SectionValidator.BANK_ANGLE, func(v: float) -> Array:
		return track.call({"type": "banked_corner", "radius": 50.0, "angle": 90.0, "bank": v}),
		"a banked corner's bank", "bank")

	# The chicane's offset is the one bound that is not a constant - it is
	# twice the radius asked for - so it gets its own probe. The offset is the
	# player's number and is said exactly; the limit it broke is a bound and
	# keeps its own rendering.
	var over: Dictionary = SectionValidator.validate({"sections": [
		{"type": "chicane", "radius": 50.0, "offset": 100.4, "direction": "left"}, filler]})
	_check(not bool(over["ok"]), "an offset of 100.4 against a limit of 100 is refused")
	var offset_said := str(over.get("errors", []))
	_check(_names(offset_said, "100.4"),
		"and the refusal says 100.4 and not 100: %s" % offset_said)


# --- the five doors 040 built the rule for, asked the same question ---
#
# Not a repeat of procedure_test, which asserts that a fractional position is
# REFUSED. This asserts what the refusal SAYS, which is the half 040's own
# control door was still doing by hand: around_problem() ended
# String.num(number, 2), so a step of 1.5004 came back "not 1.5".
func _the_reference_doors_say_it_the_same_way() -> void:
	var dungeon := DungeonModule.new()
	var rooms := [{"name": "hall", "width": 10, "depth": 10},
		{"name": "vault", "width": 10, "depth": 10}]

	var door: Dictionary = dungeon.validate({"rooms": rooms, "doors": [[1, 2.504]]})
	_check(not bool(door["ok"]), "a door to room 2.504 is refused")
	_check(_names(str(door.get("errors", [])), "2.504"),
		"and the refusal says 2.504: %s" % str(door.get("errors", [])))

	var thing: Dictionary = dungeon.validate({"rooms": rooms, "doors": [[1, 2]],
		"things": [{"name": "key", "in": 1.504}]})
	_check(not bool(thing["ok"]), "a thing in room 1.504 is refused")
	_check(_names(str(thing.get("errors", [])), "1.504"),
		"and the refusal says 1.504: %s" % str(thing.get("errors", [])))

	# The plan step, which is the control member of 040's class and the one
	# door of the five that was right before 040 - and was still rounding.
	var step := {"command": "CREATE_DUNGEON", "around": 1.5004}
	var problem := WorldRegistry.around_problem(step, 2, 2)
	_check(problem != "", "a plan step around 1.5004 is refused")
	_check(_names(problem, "1.5004"),
		"and the refusal says 1.5004 and not 1.5: %s" % problem)


# --- the probe, and the two facts asserted of every bound ---
#
# magnitude: a corner's angle is bounded on its SIZE, so "below the minimum"
# means SMALL and not negative - capability_test's first run called the
# validator broken for accepting -100 degrees, which is a legal left turn.
func _at_the_edges(limits: Vector2, run: Callable, what: String, field: String,
		magnitude: bool = false) -> void:
	# Whether a probe is out of range is decided the way the VALIDATOR decides
	# it - a strict comparison - and not with is_equal_approx, whose tolerance
	# is relative: 1800.004 is 0.004 past a bound of 1800 and the validator
	# refuses it, while is_equal_approx calls the two numbers equal. The first
	# draft of this suite used that guard and reported four of its own probes
	# as test bugs. A delta too small to put a value outside its bound is
	# skipped rather than failed, because that is a fact about floats and not
	# about Genesis - and `used` then fails if a bound ends up with no probe
	# at all, so nothing is skipped quietly.
	var used := 0
	for delta in [0.4, 0.04, 0.004]:
		for probe: float in [limits.y + delta, limits.x - delta]:
			var measured_probe: float = absf(probe) if magnitude else probe
			if measured_probe >= limits.x and measured_probe <= limits.y:
				continue
			used += 1
			var outcome: Array = run.call(probe)
			if bool(outcome[0]):
				_check(false, "%s: %s is outside %s to %s and must be refused" % [
					what, String.num(probe, 4), String.num(limits.x, 2), String.num(limits.y, 2)])
				continue

			# The refusal about THIS field, not whichever came last: one bad
			# number can draw more than one error.
			var said := ""
			for error in (outcome[1] as Array):
				if str(error).contains(field):
					said = str(error)
					break
			if said == "":
				_check(false, "%s: the refusal is about %s -> %s" % [
					what, field, str(outcome[1])])
				continue

			# FACT ONE: the sentence names the number that was sent.
			var rendering := Readback.number_said(probe)
			_check(_names(said, rendering),
				"%s: %s is said back as %s -> %s" % [what, String.num(probe, 4), rendering, said])

			# FACT TWO: and the number it names is still outside the bound the
			# same sentence states. This is the half that makes the refusal
			# actionable, and it is asserted of the rendering rather than of
			# the raw value, because the rendering is all the player gets.
			var read_back := rendering.to_float()
			var measured := absf(read_back) if magnitude else read_back
			_check(measured < limits.x or measured > limits.y,
				"%s: and %s read back out of the sentence is still outside %s to %s" % [
					what, rendering, String.num(limits.x, 2), String.num(limits.y, 2)])

	_check(used > 0, "%s: at least one edge probe lands outside the bound" % what)


# Does this text name this rendering, as a number and not as digits inside a
# longer one? capability_test's _names_number is the same idea read from a
# float; this one is handed the rendering, because that is what is being
# asserted. A rendering counts only where neither neighbour is a digit or a
# decimal point - otherwise "1" matches "room 1:" and "1000" matches "1000.4",
# and a check that passes for the wrong reason reads as evidence.
func _names(text: String, rendering: String) -> bool:
	var from := 0
	while from <= text.length():
		var at := text.find(rendering, from)
		if at < 0:
			return false
		var before := text.substr(at - 1, 1) if at > 0 else ""
		var after_at := at + rendering.length()
		var after := text.substr(after_at, 1) if after_at < text.length() else ""
		var bounded := not _digit_or_point(before) and not _digit_or_point(after)
		if bounded:
			return true
		from = at + 1
	return false


func _digit_or_point(ch: String) -> bool:
	return ch != "" and (ch == "." or ch.is_valid_int())
