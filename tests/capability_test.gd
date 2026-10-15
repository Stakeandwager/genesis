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
	_a_refusal_names_a_legal_value()
	_an_enumerated_refusal_names_its_values()
	_the_fields_table_is_a_fact()
	_the_withheld_types_are_not_offered()

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


# =====================================================================
# 030 - the same claim, through the two doors nobody had opened
# =====================================================================
#
# The prompt's claim is "It REFUSES rather than clamping. A number outside its
# limits is refused with the limit named", and 028 asserted it above for every
# bound in all five validators. But a field can be refused THREE ways, not
# one:
#
#   out of range   "room 1: width is 500 m, and must be 4 to 40 m"
#   not a number   "power must be a number"                <- named nothing
#   missing        "zone 1 (barn): missing 'width'"         <- named nothing
#
# Only the first was tested, and only the first named a bound. The other two
# are the doors a MODEL is more likely to walk through than a player: null for
# a field it had nothing to say about, or a field simply left out. Measured
# before 030, with the limits sitting in scope on the very line that wrote the
# sentence:
#
#   CarTool           power must be a number
#   BootsTool         push must be a number
#   FarmModule        zone 1 (barn): missing 'width'
#                     zone 1 (barn): 'width' must be a number
#                     zone 1 has no type
#   SectionValidator  section 1 (straight): missing 'length'
#                     section 1 (straight): 'length' must be a number
#                     section 1 (straight): 'bank' is not a straight setting
#                     section 1 (corner): do not supply 'length'
#                     section 1 has no type
#                     section 1: unknown type 'loop'
#                     intent must be an object
#
# Twelve refusals, in four of the five validators. DungeonModule's two name
# their bound because 029 happened to be rewriting those lines; that was the
# instance, and this is the class (TRAPS 11).
#
# THE RULE BEING ASSERTED, AND WHY IT IS A FACT AND NOT A FORM OF WORDS
# A refusal has two jobs: stop the build, and tell the player what would be
# allowed. So for every way a field can be refused, the message must name a
# legal value - and what counts as the legal value is READ OUT OF THE CODE,
# never typed in here. The bound numbers come from the constants; the type and
# field lists from FIELDS, ZONE_TYPES, OFFERED_TYPES, SKINS, PAINTS, COLOURS
# and defaults(). A bound that moves moves the assertion with it (TRAPS 13),
# and the suite is not reading the sentence - it is reading whether the thing
# a player would have to know is in it.
#
# WHICH OF THESE MEASURED SOMETHING AND WHICH ARE ONLY GUARDS
#
# TRAPS 6: a check that cannot fail is worth keeping, worth labelling and not
# worth counting as a measurement. This section adds 364 assertions, taking
# the suite from 165 to 529, and 109 of them fail against the pre-030
# messages:
#
#    23  a bound not named when the field was LEFT OUT
#    32  a bound not named when the field was NULL
#    49  a forbidden field refused without saying what the type does have
#     3  an enumerated list not named - a farm zone with no type, and both of
#        the circuit's type refusals
#     2  a chicane's offset refused without tying it to the radius
#
# The measurement was taken against the four validators carrying their
# pre-030 MESSAGES, not against the pre-030 files verbatim: this suite reads
# SectionValidator.FIELDS and OFFERED_TYPES, which 030 introduced, so the old
# file cannot run it at all. What is measured is therefore exactly what 030
# claims to have changed - what the sentences say - and not the refactor that
# made saying it possible.
#
# The rest are guards, and two whole sections of this file are guards by
# construction and say so where they stand: _the_fields_table_is_a_fact()
# checks a table 030 introduced against the validator it describes, and
# _the_withheld_types_are_not_offered() checks a wall that was never breached.
# The old refusal named no types at all, so "it does not advertise uphill"
# passed before this commit for the wrong reason. They are here to stop the
# next edit breaking either, which is the only thing a guard is for.
#
# The dungeon's four probes are guards too, and deliberately: 029 fixed those
# two messages, and the fault being tested is "one file out of five missed a
# convention". Nothing but asking all five the same question shows that.


# --- 1. every bounded number, through the missing and not-a-number doors ---
#
# A TOOL'S FIELDS ARE NOT PROBED FOR "MISSING", DELIBERATELY. Every field of a
# car, boots or a look may be left out and keeps its ordinary value - that is
# the design, stated in the prompt, and a missing field is not a refusal there
# at all. So the missing door is asked only of the worlds, where a measurement
# left out IS a refusal. Asserting a refusal that should not happen would be
# the mirror of TRAPS 6: a check that cannot pass.
func _a_refusal_names_a_legal_value() -> void:
	var car := CarTool.new()
	for field in ["power", "braking", "steering", "grip"]:
		var limits: Vector2 = car.get(field.to_upper())
		_not_a_number_names(limits, func() -> Array:
			var r: Dictionary = car.validate({"tool": "car", "spec": {field: null}})
			return [bool(r["ok"]), r["errors"]], "a car's %s" % field, field)

	var boots := BootsTool.new()
	for field in ["push", "weight", "footing", "turning", "brake"]:
		var pair: Array = boots.get(field.to_upper())
		var limits := Vector2(float(pair[0]), float(pair[1]))
		_not_a_number_names(limits, func() -> Array:
			var r: Dictionary = boots.validate({"tool": "boots", "spec": {field: null}})
			return [bool(r["ok"]), r["errors"]], "boots' %s" % field, field)

	# A farm. Buildings and fields have different bounds, so both are asked
	# through both doors.
	var farm := FarmModule.new()
	for probe in [["barn", FarmModule.BUILDING_SIDE], ["pond", FarmModule.FIELD_SIDE]]:
		var type: String = probe[0]
		var limits: Vector2 = probe[1]
		for field in ["width", "depth"]:
			var other := "depth" if field == "width" else "width"
			_missing_names(limits, func() -> Array:
				var zone := {"type": type}
				zone[other] = _mid(limits)
				var r: Dictionary = farm.validate({"zones": [zone]})
				return [bool(r["ok"]), r["errors"]], "a farm %s's %s" % [type, field], field)
			_not_a_number_names(limits, func() -> Array:
				var zone := {"type": type, "width": _mid(limits), "depth": _mid(limits)}
				zone[field] = null
				var r: Dictionary = farm.validate({"zones": [zone]})
				return [bool(r["ok"]), r["errors"]], "a farm %s's %s" % [type, field], field)

	# A dungeon. 029 fixed these two; they are probed anyway, because the fault
	# being tested is "one file out of five missed a convention", and the only
	# way to see that is to ask all five the same question.
	var dungeon := DungeonModule.new()
	var room_side := Vector2(DungeonModule.MIN_SIDE, DungeonModule.MAX_SIDE)
	var mid := _mid(room_side)
	for field in ["width", "depth"]:
		var other := "depth" if field == "width" else "width"
		_missing_names(room_side, func() -> Array:
			var room := {"name": "vault"}
			room[other] = mid
			var r: Dictionary = dungeon.validate({
				"rooms": [room, {"name": "hall", "width": mid, "depth": mid}],
				"doors": [[1, 2]]})
			return [bool(r["ok"]), r["errors"]], "a dungeon room's %s" % field, field)
		_not_a_number_names(room_side, func() -> Array:
			var room := {"name": "vault", "width": mid, "depth": mid}
			room[field] = null
			var r: Dictionary = dungeon.validate({
				"rooms": [room, {"name": "hall", "width": mid, "depth": mid}],
				"doors": [[1, 2]]})
			return [bool(r["ok"]), r["errors"]], "a dungeon room's %s" % field, field)

	# And the circuit, every numeric field of every section type. The pairing
	# of a field to its bound is knowledge that lives in the validator's match
	# arms rather than in a constant, so it is written out here - but the
	# NUMBERS are read from the constants, and _the_fields_table_is_a_fact()
	# below fails if a type is added to FIELDS and not probed here.
	for probe in _circuit_bounds():
		var type: String = probe[0]
		var field: String = probe[1]
		var limits: Vector2 = probe[2]
		_missing_names(limits, func() -> Array:
			return _circuit_without(type, field), "a %s's %s" % [type, field], field)
		_not_a_number_names(limits, func() -> Array:
			return _circuit_with(type, field, null), "a %s's %s" % [type, field], field)

	# A chicane's offset is the one bound that is not a pair of numbers: it is
	# twice the radius that was asked for. So what a player has to be told is
	# the RADIUS, and that is what is asserted - the fact behind the sentence,
	# not the sentence.
	for outcome in [_circuit_without("chicane", "offset"),
			_circuit_with("chicane", "offset", null)]:
		_check(not bool(outcome[0]), "a chicane with no usable offset is refused")
		var said := _about("offset", outcome[1])
		_check(said.contains("radius"),
			"and the refusal says the offset is bounded by the radius: %s" % str(outcome[1]))


# One bound, asked for with the field left out entirely.
func _missing_names(limits: Vector2, run: Callable, what: String, field: String) -> void:
	_door_names(limits, run, what, field, "left out")


# One bound, asked for with null where the number belongs - ordinary output
# from a model for a field it had nothing to say about.
func _not_a_number_names(limits: Vector2, run: Callable, what: String, field: String) -> void:
	_door_names(limits, run, what, field, "null")


# Refused, about this field, and naming both ends of the bound. _names_number
# is 028's, which counts a rendering only where neither neighbour is a digit,
# so "section 1" cannot pass as a bound of 1.
func _door_names(limits: Vector2, run: Callable, what: String, field: String,
		door: String) -> void:
	var outcome: Array = run.call()
	var refused: bool = not bool(outcome[0])
	_check(refused, "%s %s is refused" % [what, door])
	if not refused:
		return
	var said := _about(field, outcome[1])
	_check(said != "", "%s %s: and the refusal is about %s -> %s" % [
		what, door, field, str(outcome[1])])
	if said == "":
		return
	_check(_names_number(said, limits.x) and _names_number(said, limits.y),
		"%s %s: and it names %s to %s -> %s" % [
			what, door, _tidy(limits.x), _tidy(limits.y), said])


# The refusal about this field, without the "section 3" / "zone 1" index that
# opens it, or "" if nothing was said about it.
func _about(field: String, errors: Variant) -> String:
	for error in (errors as Array):
		if str(error).contains(field):
			return _tail(str(error))
	return ""


# Which constant bounds which field of which section type. Written out because
# the validator keeps that pairing in its match arms; the numbers themselves
# are never typed here.
func _circuit_bounds() -> Array:
	return [
		["straight", "length", SectionValidator.STRAIGHT_LENGTH],
		["uphill", "length", SectionValidator.STRAIGHT_LENGTH],
		["uphill", "grade", SectionValidator.GRADE_RANGE],
		["downhill", "length", SectionValidator.STRAIGHT_LENGTH],
		["downhill", "grade", SectionValidator.GRADE_RANGE],
		["crest", "length", SectionValidator.STRAIGHT_LENGTH],
		["crest", "grade", SectionValidator.GRADE_RANGE],
		["dip", "length", SectionValidator.STRAIGHT_LENGTH],
		["dip", "grade", SectionValidator.GRADE_RANGE],
		["corner", "radius", SectionValidator.CORNER_RADIUS],
		["corner", "angle", SectionValidator.CORNER_ANGLE],
		["hairpin", "radius", SectionValidator.HAIRPIN_RADIUS],
		["hairpin", "angle", SectionValidator.HAIRPIN_ANGLE],
		["banked_corner", "radius", SectionValidator.CORNER_RADIUS],
		["banked_corner", "angle", SectionValidator.CORNER_ANGLE],
		["banked_corner", "bank", SectionValidator.BANK_ANGLE],
		["chicane", "radius", SectionValidator.CHICANE_RADIUS],
		["loop_segment", "radius", SectionValidator.LOOP_RADIUS],
		["loop_segment", "angle", SectionValidator.LOOP_ANGLE],
	]


# A sound section of this type, built from the constants.
func _sound_section(type: String) -> Dictionary:
	var section := {"type": type}
	for field in (SectionValidator.FIELDS[type] as Array):
		match field:
			"length":
				section["length"] = _mid(SectionValidator.STRAIGHT_LENGTH)
			"grade":
				section["grade"] = _mid(SectionValidator.GRADE_RANGE)
			"direction":
				section["direction"] = "left"
			"bank":
				section["bank"] = _mid(SectionValidator.BANK_ANGLE)
			"radius":
				section["radius"] = _radius_for(type)
			"angle":
				section["angle"] = _angle_for(type)
			"offset":
				# At most twice the radius, so the radius itself is always
				# inside the bound.
				section["offset"] = _radius_for(type)
			_:
				_check(false, "a %s has a field '%s' this test cannot build" % [type, field])
	return section


func _radius_for(type: String) -> float:
	match type:
		"hairpin":
			return _mid(SectionValidator.HAIRPIN_RADIUS)
		"chicane":
			return _mid(SectionValidator.CHICANE_RADIUS)
		"loop_segment":
			return _mid(SectionValidator.LOOP_RADIUS)
	return _mid(SectionValidator.CORNER_RADIUS)


func _angle_for(type: String) -> float:
	match type:
		"hairpin":
			return _mid(SectionValidator.HAIRPIN_ANGLE)
		"loop_segment":
			return _mid(SectionValidator.LOOP_ANGLE)
	return _mid(SectionValidator.CORNER_ANGLE)


func _mid(limits: Vector2) -> float:
	return (limits.x + limits.y) * 0.5


func _filler() -> Dictionary:
	return {"type": "straight", "length": _mid(SectionValidator.STRAIGHT_LENGTH)}


func _validated(section: Dictionary) -> Array:
	var r: Dictionary = SectionValidator.validate({"sections": [section, _filler()]})
	return [bool(r["ok"]), r["errors"]]


func _circuit_without(type: String, field: String) -> Array:
	var section := _sound_section(type)
	section.erase(field)
	return _validated(section)


func _circuit_with(type: String, field: String, value: Variant) -> Array:
	var section := _sound_section(type)
	section[field] = value
	return _validated(section)


# --- 2. every refusal of a value out of a FIXED LIST names the list ---
#
# The same rule where the legal values are an enumeration rather than a range.
# Most of these named their list already; "zone 1 has no type", "section 1 has
# no type" and "section 1: unknown type 'x'" did not, which is the case where
# a player most needs it. Every expected list is read from the code.
func _an_enumerated_refusal_names_its_values() -> void:
	var car := CarTool.new()
	_lists(func() -> Array:
		var r: Dictionary = car.validate({"spec": {"paint": "taupe"}})
		return [bool(r["ok"]), r["errors"]], CarTool.PAINTS.keys(), "a car's paints")
	_lists(func() -> Array:
		var r: Dictionary = car.validate({"spec": {"spoiler": 3}})
		return [bool(r["ok"]), r["errors"]], car.defaults().keys(), "a car's own fields")

	var boots := BootsTool.new()
	_lists(func() -> Array:
		var r: Dictionary = boots.validate({"spec": {"colour": "taupe"}})
		return [bool(r["ok"]), r["errors"]], BootsTool.COLOURS.keys(), "boots' colours")
	_lists(func() -> Array:
		var r: Dictionary = boots.validate({"spec": {"laces": 3}})
		return [bool(r["ok"]), r["errors"]], boots.defaults().keys(), "boots' own fields")

	var look := LookTool.new()
	_lists(func() -> Array:
		var r: Dictionary = look.validate({"spec": {"skin": "taupe"}})
		return [bool(r["ok"]), r["errors"]], LookTool.SKINS.keys(), "a look's skins")
	_lists(func() -> Array:
		var r: Dictionary = look.validate({"spec": {"hat": 3}})
		return [bool(r["ok"]), r["errors"]], look.defaults().keys(), "a look's own fields")

	var farm := FarmModule.new()
	var fmid := _mid(FarmModule.FIELD_SIDE)
	# Both doors into the type: a zone with no type at all, and one whose type
	# is not a zone.
	_lists(func() -> Array:
		var r: Dictionary = farm.validate({"zones": [{"width": fmid, "depth": fmid}]})
		return [bool(r["ok"]), r["errors"]], FarmModule.ZONE_TYPES,
		"a farm's zone types, none given")
	_lists(func() -> Array:
		var r: Dictionary = farm.validate({"zones": [
			{"type": "quarry", "width": fmid, "depth": fmid}]})
		return [bool(r["ok"]), r["errors"]], FarmModule.ZONE_TYPES,
		"a farm's zone types, one unknown")
	_lists(func() -> Array:
		var r: Dictionary = farm.validate({"zones": [
			{"type": "crop", "crop": "tulips", "width": fmid, "depth": fmid}]})
		return [bool(r["ok"]), r["errors"]], FarmModule.CROP_COLOURS.keys(), "a farm's crops")

	# The circuit's two type refusals, which named nothing at all.
	_lists(func() -> Array:
		return _validated({}), SectionValidator.OFFERED_TYPES,
		"a circuit's types, none given")
	_lists(func() -> Array:
		return _validated({"type": "loop"}), SectionValidator.OFFERED_TYPES,
		"a circuit's types, one unknown")

	# A chicane's direction, where the legal values are the two words.
	var wrong_way := _circuit_with("chicane", "direction", "widdershins")
	_check(not bool(wrong_way[0]), "a chicane facing neither way is refused")
	var about_direction := _about("direction", wrong_way[1])
	_check(about_direction.contains("left") and about_direction.contains("right"),
		"and the refusal names left and right: %s" % str(wrong_way[1]))

	# And a field a section type does not have, refused with the fields it
	# does have. Every type, every field it lacks - not the one that was found
	# wanting (TRAPS 11).
	for type in SectionValidator.FIELDS:
		var mine: Array = SectionValidator.FIELDS[type]
		var tried := {}
		for other in SectionValidator.FIELDS:
			for field in (SectionValidator.FIELDS[other] as Array):
				if field in mine or tried.has(field):
					continue
				tried[field] = true
				var section := _sound_section(type)
				section[field] = _sound_section(other)[field]
				var outcome := _validated(section)
				_check(not bool(outcome[0]),
					"a %s given a '%s' is refused" % [type, field])
				var said := _about("'%s' is not" % field, outcome[1])
				var every := said != ""
				for has in mine:
					if not said.contains(str(has)):
						every = false
				_check(every, "a %s given a '%s' is told a %s has %s -> %s" % [
					type, field, type, str(mine),
					said if said != "" else str(outcome[1])])


# Refused, and the refusal names every member of the list it should offer.
func _lists(run: Callable, expected: Array, what: String) -> void:
	var outcome: Array = run.call()
	_check(not bool(outcome[0]), "%s: the unknown value is refused" % what)
	if bool(outcome[0]):
		return
	var said := ""
	for error in (outcome[1] as Array):
		said += str(error) + " "
	var missing := PackedStringArray()
	for value in expected:
		if not said.contains(str(value)):
			missing.append(str(value))
	_check(missing.is_empty(), "%s: and the refusal names all %d of them%s" % [
		what, expected.size(),
		"" if missing.is_empty() else " - left out %s: %s" % [
			str(missing), said.strip_edges()]])


# --- 3. FIELDS is a fact about the validator, not a list beside it ---
#
# SectionValidator.FIELDS is new in 030 and now decides two things: which
# fields a type refuses, and what its refusal says a type is made of. A table
# that drifts from the code it describes is TRAPS 16's shape - a rule written
# down and not enforced - so it is checked against the validator itself.
func _the_fields_table_is_a_fact() -> void:
	for type in SectionValidator.FIELDS:
		_check(type in SectionValidator.SECTION_TYPES,
			"FIELDS names '%s', which the validator accepts" % type)
		var outcome := _validated(_sound_section(type))
		_check(bool(outcome[0]),
			"a %s built from exactly the fields FIELDS gives it validates: %s" % [
				type, str(outcome[1])])

	for type in SectionValidator.SECTION_TYPES:
		_check(SectionValidator.FIELDS.has(type),
			"the validator accepts '%s', and FIELDS says what it is made of" % type)

	# Every type in the table has its bounds probed by section 1 above. A type
	# added later and not probed fails here rather than passing silently,
	# which is the guard TRAPS 13 asks for.
	var probed := {}
	for probe in _circuit_bounds():
		probed[probe[0]] = true
	for type in SectionValidator.FIELDS:
		var numeric := false
		for field in (SectionValidator.FIELDS[type] as Array):
			if field != "direction":
				numeric = true
		if numeric:
			_check(probed.has(type),
				"'%s' has bounded numbers and its refusals are probed above" % type)


# --- 4. the wall between the ten types and the four, from both sides ---
#
# TRAPS 19: SectionValidator accepts ten section types and the prompt offers
# four, and that gap is deliberate - docs/GENESIS_BRIEF.md records that the
# other six throw cars over barriers, are untested with a car, read as a crash
# when a loop passes over itself, and are not checked for returning to their
# starting height.
#
# 030 made the circuit's type refusals name the types a player may ask for,
# which is a SECOND place that restriction now lives. The obvious way to write
# that message - list SECTION_TYPES, because that is what the validator takes -
# would have advertised all six withheld types to the player, undoing the wall
# through the one sentence nobody was testing. So the two copies are bound
# together here, in both directions, and a refusal may never name a type the
# validator would then reject.
func _the_withheld_types_are_not_offered() -> void:
	var prompt := RacingModule.new().prompt_section()
	var withheld := PackedStringArray()
	for type in SectionValidator.SECTION_TYPES:
		if not type in SectionValidator.OFFERED_TYPES:
			withheld.append(type)

	for type in SectionValidator.OFFERED_TYPES:
		_check(prompt.contains("%s: {\"type\": \"%s\"" % [type, type]),
			"the prompt offers '%s', which a refusal now names" % type)
		_check(type in SectionValidator.SECTION_TYPES,
			"and the validator accepts '%s', so the refusal names nothing it would reject" % type)

	for type in withheld:
		_check(not prompt.contains("%s: {\"type\": \"%s\"" % [type, type]),
			"the prompt still withholds '%s' (TRAPS 19)" % type)

	# And the refusal withholds them too, which is the half that is new.
	var said := str(_validated({"type": "loop"})[1])
	for type in withheld:
		_check(not said.contains(type),
			"and a refusal does not advertise '%s' either: %s" % [type, said])
	_check(withheld.size() == 6,
		"six types are withheld, as TRAPS 19 records: %s" % str(withheld))
