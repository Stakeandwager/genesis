extends SceneTree

# 028 - the capability half of the AI's prompt, asserted as facts.
#
# WHY THIS SUITE EXISTS
# 027 did the limitations: all seven of WHAT GENESIS REALLY CANNOT DO are now
# asserted in tests/limits_test.gd as facts about the code rather than as
# words in the prompt, and two of them turned out to be stated wider than the
# fact behind them. The capabilities were still checked only for the EXISTENCE
# of the functions they name - log_023_test proves BootsTool.stopping_distance
# is still there, which is not the same as proving Genesis "predicts a
# stopping distance from the numbers and then measures the real one, and
# reports both". HANDOVER named that gap as the next task and it was right to:
# one of the eight claims was wider than the code, and so was the rebuttal
# RefusalCheck would have offered a player who doubted it.
#
# A capability stated too wide fails in the mirror direction of TRAPS 15. A
# limitation too wide makes Genesis refuse what it can do; a capability too
# wide makes it ACCEPT what it cannot, which the model then promises to a
# player. Both are the system lying about itself, and this half had no test.
#
# THE RULE FOR EVERY ASSERTION BELOW
# Assert the capability, never the wording. "The prompt says it measures"
# tests nothing (TRAPS 14). So each claim is read off the functions that would
# have to be true for it, and the two wording checks at the end exist only to
# stop a sentence that has been shown to be too wide coming quietly back.

var bad := 0


func _check(ok: bool, what: String) -> void:
	print(("PASS  " if ok else "FAIL  ") + what)
	if not ok:
		bad += 1


func _initialize() -> void:
	_a_refusal_names_its_limit()
	_the_four_named_measurements_exist()
	_growth_is_recorded()
	_the_stopping_distance_claim_at_its_real_width()
	_the_wide_sentences_do_not_come_back()

	print("CAPABILITY TEST failures=%d" % bad)
	quit(1 if bad > 0 else 0)


# --- the claim: "It REFUSES rather than clamping. A number outside its
# limits is refused with the limit named." ---
#
# This is a claim about EVERY bounded number in Genesis, so it is tested
# against every validator that has one, not against the one that was found
# wanting. Four of the five already did it:
#
#   CarTool         power is 5000, and a car's power must be 400 to 1800
#   BootsTool       push is 5000, and boots' push must be 120 to 600
#   FarmModule      zone 1 (barn): width 500 m is outside 5-60 m
#   DungeonModule   room 1: width is 500 m, and must be 4 to 40 m
#
# SectionValidator said "length out of range" eleven times and named nothing,
# and 34 green suites did not notice, because every one of them asked whether
# a bad number was REFUSED and none asked what the player was told. The
# circuit is a third of the worlds Genesis builds.
#
# The bounds are read from the constants, never typed in here. A test that
# hardcodes 400 to 1800 starts lying the day somebody changes the limit, which
# is trap 13 - an assertion left behind by a rule that moved.
func _a_refusal_names_its_limit() -> void:
	var car := CarTool.new()
	for field in ["power", "braking", "steering", "grip"]:
		var limits: Vector2 = car.get(field.to_upper())
		_both_ways(limits, func(value: float) -> Array:
			var r: Dictionary = car.validate({"tool": "car", "spec": {field: value}})
			return [bool(r["ok"]), r["errors"]], "a car's %s" % field, field)

	var boots := BootsTool.new()
	for field in ["push", "weight", "footing", "turning", "brake"]:
		var pair: Array = boots.get(field.to_upper())
		var limits := Vector2(float(pair[0]), float(pair[1]))
		_both_ways(limits, func(value: float) -> Array:
			var r: Dictionary = boots.validate({"tool": "boots", "spec": {field: value}})
			return [bool(r["ok"]), r["errors"]], "boots' %s" % field, field)

	# A farm's buildings and its fields have different bounds, so both are
	# asked. The other zone fields ride the same _bounded() path.
	var farm := FarmModule.new()
	_both_ways(FarmModule.BUILDING_SIDE, func(value: float) -> Array:
		var r: Dictionary = farm.validate({"zones": [{"type": "barn", "width": value, "depth": 20}]})
		return [bool(r["ok"]), r["errors"]], "a farm barn's width", "width")
	_both_ways(FarmModule.FIELD_SIDE, func(value: float) -> Array:
		var r: Dictionary = farm.validate({"zones": [{"type": "pond", "width": value, "depth": 60}]})
		return [bool(r["ok"]), r["errors"]], "a farm pond's width", "width")

	var dungeon := DungeonModule.new()
	var room_side := Vector2(DungeonModule.MIN_SIDE, DungeonModule.MAX_SIDE)
	_both_ways(room_side, func(value: float) -> Array:
		var r: Dictionary = dungeon.validate({
			"rooms": [{"width": value, "depth": 10}, {"width": 10, "depth": 10}],
			"doors": [[1, 2]]})
		return [bool(r["ok"]), r["errors"]], "a dungeon room's width", "width")

	# And the circuit, which is the one that did not. Every bound in
	# SectionValidator, each in the section type that uses it.
	var filler := {"type": "straight", "length": 100.0}
	var track := func(section: Dictionary) -> Array:
		var r: Dictionary = SectionValidator.validate({"sections": [section, filler]})
		return [bool(r["ok"]), r["errors"]]

	_both_ways(SectionValidator.STRAIGHT_LENGTH, func(v: float) -> Array:
		return track.call({"type": "straight", "length": v}), "a straight's length", "length")
	_both_ways(SectionValidator.GRADE_RANGE, func(v: float) -> Array:
		return track.call({"type": "uphill", "length": 100.0, "grade": v}), "an uphill's grade", "grade")
	_both_ways(SectionValidator.CORNER_RADIUS, func(v: float) -> Array:
		return track.call({"type": "corner", "radius": v, "angle": 90.0}), "a corner's radius", "radius")
	_both_ways(SectionValidator.CORNER_ANGLE, func(v: float) -> Array:
		return track.call({"type": "corner", "radius": 50.0, "angle": v}), "a corner's angle", "angle", true)
	_both_ways(SectionValidator.HAIRPIN_RADIUS, func(v: float) -> Array:
		return track.call({"type": "hairpin", "radius": v, "angle": 180.0}), "a hairpin's radius", "radius")
	_both_ways(SectionValidator.HAIRPIN_ANGLE, func(v: float) -> Array:
		return track.call({"type": "hairpin", "radius": 30.0, "angle": v}), "a hairpin's angle", "angle", true)
	_both_ways(SectionValidator.CHICANE_RADIUS, func(v: float) -> Array:
		return track.call({"type": "chicane", "radius": v, "offset": 5.0, "direction": "left"}),
		"a chicane's radius", "radius")
	_both_ways(SectionValidator.LOOP_RADIUS, func(v: float) -> Array:
		return track.call({"type": "loop_segment", "radius": v, "angle": 180.0}), "a loop's radius", "radius")
	_both_ways(SectionValidator.LOOP_ANGLE, func(v: float) -> Array:
		return track.call({"type": "loop_segment", "radius": 30.0, "angle": v}), "a loop's angle", "angle", true)

	# Bank is the one angle that is bounded on its SIGNED value and not its
	# size, because its range starts at 0. Only the top is probed by
	# _both_ways (a value below 0 is what the low probe gives), and a negative
	# bank must stay refused - reading it as a magnitude would let one in.
	_both_ways(SectionValidator.BANK_ANGLE, func(v: float) -> Array:
		return track.call({"type": "banked_corner", "radius": 50.0, "angle": 90.0, "bank": v}),
		"a banked corner's bank", "bank")
	var negative: Dictionary = SectionValidator.validate({"sections": [
		{"type": "banked_corner", "radius": 50.0, "angle": 90.0, "bank": -10.0}, filler]})
	_check(not bool(negative["ok"]), "a negative bank is still refused, not read as 10 degrees")

	# A chicane's offset is the one bound that is not a constant: it is twice
	# the radius that was asked for. So the refusal has to name the number the
	# limit came out to, which is the only way a player can tell what to type.
	var wide: Dictionary = SectionValidator.validate({"sections": [
		{"type": "chicane", "radius": 50.0, "offset": 999.0, "direction": "left"}, filler]})
	_check(not bool(wide["ok"]), "an offset wider than twice the radius is refused")
	_check(_names_number(_tail(str(wide["errors"])), 100.0),
		"and the refusal names the 100 m that limit came to: %s" % str(wide["errors"]))

	# And a refused radius must not go on to produce a second refusal naming a
	# limit worked out FROM it. Before 028 a radius of -145 drew both "radius
	# is -145 m, and must be 15 to 150 m" and "offset is 5 m, and must be ...
	# at most twice the radius, which is -290 m here" - a refusal naming a
	# limit that is not one, on top of the refusal the player already had.
	var bad_radius: Dictionary = SectionValidator.validate({"sections": [
		{"type": "chicane", "radius": -145.0, "offset": 5.0, "direction": "left"}, filler]})
	_check(not bool(bad_radius["ok"]), "a chicane with a negative radius is refused")
	var about_offset := 0
	for error in (bad_radius["errors"] as Array):
		if str(error).contains("offset"):
			about_offset += 1
	_check(about_offset == 0,
		"and nothing is said about the offset, whose limit came from that radius: %s" % str(bad_radius["errors"]))


# One bound, probed above and below, with the refusal read both times.
#
# The probe values are pushed outside on purpose and then CHECKED not to
# collide with either bound, so a pass can never come from the test having
# asked for the limit itself.
#
# MAGNITUDE MATTERS, and the first run of this suite proved it. A corner's
# angle is bounded on its SIZE: 10 to 120 degrees, either direction. Probing
# below the minimum with a big negative number asks for -100 degrees, which is
# a legal 100-degree left turn, and the test called the validator broken for
# accepting it. So for a bound on size, "below the minimum" means SMALL, not
# negative. The test was wrong and the code was right, which is the direction
# this harness is least able to see by itself.
func _both_ways(limits: Vector2, run: Callable, what: String, field: String,
		magnitude: bool = false) -> void:
	var low := limits.x * 0.5 if magnitude else limits.x - (absf(limits.x) + 1.0) * 10.0
	for probe in [limits.y * 10.0 + 7.0, low]:
		if is_equal_approx(probe, limits.x) or is_equal_approx(probe, limits.y):
			_check(false, "%s: the probe %f is itself a bound; the test is wrong" % [what, probe])
			continue
		var outcome: Array = run.call(probe)
		var refused: bool = not bool(outcome[0])
		_check(refused, "%s: %s is refused" % [what, _tidy(probe)])
		if not refused:
			continue
		# The refusal about THIS field, not whichever came last. A spec with
		# one bad number can draw more than one error, and reading the wrong
		# one is how the first run of this suite reported a chicane's radius
		# against an offset message.
		var said := ""
		for error in (outcome[1] as Array):
			if str(error).contains(field):
				said = _tail(str(error))
				break
		_check(said != "", "%s: and the refusal is about %s -> %s" % [what, field, str(outcome[1])])
		if said == "":
			continue
		_check(_names_number(said, limits.x) and _names_number(said, limits.y),
			"%s: and it names %s to %s -> %s" % [
				what, _tidy(limits.x), _tidy(limits.y), said])


# Does this text name this number, as a number and not as digits inside a
# longer one?
#
# The throwaway probe that found this whole fault had exactly this bug: it
# looked for "1" and matched "section 1", and so reported a nameless refusal
# as a named one. A check that passes for the wrong reason is TRAPS 6's
# neighbour, and it is worse than one that cannot fail, because it reads as
# evidence. So a rendering counts only where neither neighbouring character is
# a digit or a decimal point.
func _names_number(text: String, value: float) -> bool:
	var renderings := PackedStringArray()
	if is_equal_approx(value, roundf(value)):
		renderings.append("%.0f" % value)
	else:
		renderings.append("%.2f" % value)
		renderings.append("%.1f" % value)
	for rendering in renderings:
		var from := 0
		while from <= text.length():
			var at := text.find(rendering, from)
			if at < 0:
				break
			var before := text[at - 1] if at > 0 else " "
			var after_index := at + rendering.length()
			var after := text[after_index] if after_index < text.length() else " "
			if not _digitish(before) and not _digitish(after):
				return true
			from = at + 1
	return false


func _digitish(character: String) -> bool:
	return character.is_valid_int() or character == "."


# The refusal without the "section 3" / "zone 1" / "room 2" that opens it.
# That number is an index, not a bound, and leaving it in is how the probe
# above fooled itself.
func _tail(message: String) -> String:
	var at := message.rfind(": ")
	return message.substr(at + 2) if at >= 0 else message


func _tidy(value: float) -> String:
	return "%.0f" % value if is_equal_approx(value, roundf(value)) else "%.2f" % value


# --- the claim: "It MEASURES everything it builds ... corridor length, how
# many doors deep the furthest room is, lap length, closest approach of a
# track to itself." ---
#
# Four measurements are named in the prompt by name. Each is asserted here by
# building something and reading the number out, because a claim that a thing
# is measured is a claim that a number comes back - not that a key exists.
func _the_four_named_measurements_exist() -> void:
	var dungeon := DungeonModule.new()
	var checked: Dictionary = dungeon.validate({
		"rooms": [{"name": "hall", "width": 10, "depth": 10},
			{"name": "room_2", "width": 8, "depth": 8},
			{"name": "room_3", "width": 8, "depth": 8}],
		"doors": [[1, 2], [2, 3]]})
	_check(bool(checked["ok"]), "a three-room dungeon validates: %s" % str(checked["errors"]))
	if bool(checked["ok"]):
		var solved: Dictionary = dungeon.solve(checked["content"])
		_check(bool(solved["ok"]), "and lays out")
		if bool(solved["ok"]):
			var metrics: Dictionary = dungeon.measure(solved["layout"])
			var corridor := float(metrics.get("corridor_length", -1.0))
			_check(corridor > 0.0, "corridor length is measured: %.1f m" % corridor)
			# Three rooms in a line: the furthest is two doors in. A number
			# that is merely present would pass a test for a key; this asks
			# whether it counted the right thing.
			_check(int(metrics.get("deepest", -1)) == 2,
				"how many doors deep the furthest room is: %s" % str(metrics.get("deepest", "missing")))

	# A circuit: lap length, and closest approach of the road to itself.
	var sections := [
		{"type": "straight", "length": 200.0},
		{"type": "corner", "radius": 50.0, "angle": 90.0},
		{"type": "straight", "length": 200.0},
		{"type": "corner", "radius": 50.0, "angle": 90.0},
		{"type": "straight", "length": 200.0},
		{"type": "corner", "radius": 50.0, "angle": 90.0},
		{"type": "straight", "length": 200.0},
		{"type": "corner", "radius": 50.0, "angle": 90.0},
	]
	var track: Dictionary = SectionValidator.validate({"sections": sections})
	_check(bool(track["ok"]), "a rectangle circuit validates: %s" % str(track["errors"]))
	var measured: Dictionary = TrackMetrics.measure(track["sections"])
	var lap := float(measured.get("total_length", -1.0))
	_check(lap > 0.0, "lap length is measured: %.1f m" % lap)
	# The straights are 200 m each and the corners add their arcs, so the lap
	# has to be longer than the straights alone. Reading the number is not the
	# same as checking it means anything.
	_check(lap > 800.0, "and it is the length of the whole lap, not of the straights (%.1f m)" % lap)

	# Closest approach needs a track that actually approaches itself. On the
	# generous rectangle above the answer is INF - no two SEPARATE stretches of
	# road come near each other - which is honest and makes a "> 0" assertion
	# vacuous: INF passes it without measuring anything. TRAPS 6 is exactly
	# this, so the claim is asked of a long thin circuit whose two straights
	# run 50 m apart, where a real number has to come back.
	var thin := [
		{"type": "straight", "length": 400.0},
		{"type": "corner", "radius": 15.0, "angle": 90.0},
		{"type": "straight", "length": 20.0},
		{"type": "corner", "radius": 15.0, "angle": 90.0},
		{"type": "straight", "length": 400.0},
		{"type": "corner", "radius": 15.0, "angle": 90.0},
		{"type": "straight", "length": 20.0},
		{"type": "corner", "radius": 15.0, "angle": 90.0},
	]
	var thin_checked: Dictionary = SectionValidator.validate({"sections": thin})
	_check(bool(thin_checked["ok"]), "a long thin circuit validates: %s" % str(thin_checked["errors"]))
	var separation: Dictionary = SeparationCheck.check(thin_checked["sections"])
	var closest := float(separation.get("minimum_separation", -1.0))
	_check(is_finite(closest) and closest > 0.0,
		"closest approach of the track to itself is measured: %.1f m" % closest)
	# And it is the gap between the two long straights, which is the short
	# side plus a corner radius at each end: 20 + 15 + 15.
	_check(absf(closest - 50.0) < 6.0,
		"and it is the real gap between the straights, about 50 m, not any number at all (%.1f m)" % closest)
	_check(float(separation.get("required_separation", -1.0)) > 0.0,
		"and it is reported against the separation the game requires: %.0f m" % float(separation.get("required_separation", -1.0)))


# --- the claim: "Genesis grows the outer world until the inner one fits with
# room to spare, and records the growth rather than quietly shrinking what was
# asked for." ---
#
# The growable half is the farm; a circuit's shape IS the design, so it is
# never grown. What is asserted is that a farm asked to hold something bigger
# than itself comes back BIGGER, which is the half of the claim a player would
# notice, and that the readback still says one world is inside the other.
func _growth_is_recorded() -> void:
	var farm := FarmModule.new()
	var small := {"zones": [{"type": "barn", "width": 20, "depth": 20}]}
	var checked: Dictionary = farm.validate(small)
	_check(bool(checked["ok"]), "a one-zone farm validates")
	if not bool(checked["ok"]):
		return
	var solved: Dictionary = farm.solve(checked["content"])
	_check(bool(solved["ok"]), "and lays out")
	if not bool(solved["ok"]):
		return
	var before: Vector2 = farm.extent(solved["layout"])
	var target := Vector2(before.x * 4.0 + 200.0, before.y * 4.0 + 200.0)
	var grown: bool = farm.grow_to(solved["layout"], target)
	_check(grown, "a farm can be grown to hold something bigger than itself")
	if grown:
		var after: Vector2 = farm.extent(solved["layout"])
		_check(after.x > before.x and after.y > before.y,
			"and it really is bigger: %.0f x %.0f m -> %.0f x %.0f m" % [
				before.x, before.y, after.x, after.y])
		_check(after.x >= target.x - 0.5 and after.y >= target.y - 0.5,
			"and it reaches what it was asked for rather than shrinking it")

	var nested := {"steps": [
		{"command": "CREATE_FARM", "parameters": {"zones": [{"type": "barn", "width": 20, "depth": 20}]}},
		{"command": "CREATE_TRACK", "parameters": {"around": 1, "sections": [
			{"type": "straight", "length": 120}, {"type": "corner", "radius": 40, "angle": 90},
			{"type": "straight", "length": 120}, {"type": "corner", "radius": 40, "angle": 90},
			{"type": "straight", "length": 120}, {"type": "corner", "radius": 40, "angle": 90},
			{"type": "straight", "length": 120}, {"type": "corner", "radius": 40, "angle": 90}]}},
	]}
	_check(WorldRegistry.readback("PLAN", nested).contains("one inside the other"),
		"and a plan still says one world goes inside the other")


# --- the claim that was too wide, at the width it is actually true ---
#
# The prompt said: "Genesis predicts a stopping distance from the numbers and
# then measures the real one, and reports both." Two things in that are wider
# than the code, and HANDOVER had already marked the sentence as suspect:
#
#   1. Nothing in the GAME measures a real stop. tests/behaviour_test.gd does,
#      against this very prediction, and a player cannot reach a test. The
#      only stopping distance a player is ever shown is the predicted one, in
#      BootsTool.summary().
#   2. A CAR has no predicted stopping distance at all. It has bounded
#      braking, and nothing that turns it into a distance. The owner's own 023
#      session asked for exactly this - "measure their stopping distances and
#      compare the measured results with predictions" - for two CARS.
#
# So the facts behind the narrowed sentence are asserted, including the two
# absences. An absence is a capability claim like any other and is the kind
# nobody checks.
func _the_stopping_distance_claim_at_its_real_width() -> void:
	var boots := BootsTool.new()
	var kit: Dictionary = boots.defaults()

	var predicted := BootsTool.stopping_distance(kit, 5.0)
	_check(predicted > 0.0, "boots predict a stopping distance: %.2f m from 5 m/s" % predicted)

	# Predicted from the NUMBERS, which means changing a number has to change
	# it, in the direction the number means. Legs that pull harder stop sooner.
	var strong := kit.duplicate()
	strong["brake"] = float(BootsTool.BRAKE[1])
	var weak := kit.duplicate()
	weak["brake"] = float(BootsTool.BRAKE[0])
	var hard := BootsTool.stopping_distance(strong, 5.0)
	var soft := BootsTool.stopping_distance(weak, 5.0)
	_check(hard < soft,
		"and it comes out of the spec: brake %.0f stops in %.2f m, brake %.0f in %.2f m" % [
			float(BootsTool.BRAKE[1]), hard, float(BootsTool.BRAKE[0]), soft])

	# And the player is told it before anything moves, which is the half of
	# the claim that is true of the game rather than of the suite.
	_check(boots.summary(kit).contains("stopping in"),
		"and the player is told it when the boots go on: %s" % boots.summary(kit))

	# The two absences. If either of these ever stops being true, the prompt
	# is understating Genesis and this test says so by failing.
	var car := CarTool.new()
	_check(not car.has_method("stopping_distance"),
		"a car still has no predicted stopping distance, so the prompt must not promise one")
	_check(car.defaults().has("braking"),
		"though a car does have bounded braking, which is what the prompt may say")
	_check(not boots.has_method("measured_stopping_distance")
		and not car.has_method("measured_stopping_distance"),
		"and nothing in the game measures a real stop to report beside the prediction")


# --- the two sentences, kept from quietly coming back ---
#
# This is the only part of this suite that reads the prompt's words, and it is
# here for the reason 025 and 027 put the same kind of check in: a sentence
# that has been shown to be wider than the code should not be able to return
# without a test going red. It is not evidence that the capability works; the
# functions above are that.
func _the_wide_sentences_do_not_come_back() -> void:
	var prompt: String = AIInterpreter.SYSTEM_PROMPT
	_check(not prompt.contains("measures the real one"),
		"the prompt no longer says Genesis measures the real stopping distance")
	_check(prompt.contains("For BOOTS"),
		"it says which tool the prediction is for instead")

	var physics := ""
	for entry in RefusalCheck.CAPABILITIES:
		var capability: Dictionary = entry
		if str(capability["name"]) == "measurement and physics":
			physics = str(capability["but"])
	_check(physics != "", "RefusalCheck still has something to say about physics")
	# 028: the same over-wide sentence was in here too, which is the thing
	# worth catching. A checker built to catch Genesis understating itself was
	# overstating it, and would have contradicted a player's correct refusal.
	_check(not physics.contains("measures the real one"),
		"and no longer claims it measures the real stop: %s" % physics)
	_check(physics.contains("predicted stopping distance"),
		"while still saying what it does predict")
