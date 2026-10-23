extends SceneTree

# --- 035: does the prompt state the bounds the code enforces? ---
#
# HANDOVER named the next assistant task as one instance: the AI's prompt
# said "Use 2 to 24 zones" while FarmModule.MIN_ZONES was 1, and had been
# since 003 lowered it so that "build a farm with a barn" - about the most
# natural thing a first-time player can type - would stop being refused. The
# prompt then told the model not to send one. A bound stated narrower than
# the truth costs a player the request the bound was widened for.
#
# Asked of the CLASS rather than of that one sentence (TRAPS 11), every
# numeric bound in AIInterpreter.assembled_prompt() was measured against the
# constant that enforces it. Nine were right, one was wrong, and one was
# missing: the circuit's section count, 2 to 40, appeared nowhere in the
# prompt at all - so a model asked for a long technical circuit could compose
# 41 sections and be refused by a limit it was never told. That is the shape
# of the `doors` refusal 034 fixed, one door along.
#
# WHAT THIS ASSERTS, AND WHAT IT DOES NOT (TRAPS 6)
#
# FINDING, and it is the one that catches the fault rather than its wording:
# every count the prompt states about a declared list must EQUAL that list's
# declared bounds. The prompt is read with a regular expression - "N to M
# <members>", "at most N <members>", "up to N <members>" - so it does not
# matter which sentence says it or how, and a number typed in by hand is
# caught exactly as a generated one would be. Against the pre-035 prompt,
# "Use 2 to 24 zones" fails here on the 2.
#
# FINDING. Every declared list's size must be stated SOMEWHERE in the
# prompt. This is what the circuit's missing sentence failed, and it is the
# assertion a prompt cannot pass by saying nothing.
#
# FINDING. The declared bounds must be the bounds the VALIDATOR enforces,
# measured by handing it lists of low, low-1, high and high+1 members and
# reading which ones it refuses for their count. This is what stops the
# chain being fixed at the wrong end: a declaration moved to 2 to match the
# old sentence would satisfy every assertion above and fail here, because
# a one-zone farm validates.
#
# FINDING. Every stated FIELD bound - a room's sides, a farm's zone sides,
# every section type's radius, angle and length, the solver's adjustment and
# the road's separation - must appear in the prompt as the constant spells
# it. Those are nine numbers that were typed out by hand next to the
# constants that enforce them.
#
# FINDING. AIInterpreter.PROMPT_FINGERPRINT is the sha256 of the assembled
# prompt. A changed prompt fails here and the failure says to move
# PROMPT_VERSION with it. This is not an assertion about wording: it says
# only that the prompt the model receives is the one the version names. It
# had to be built because PROMPT_VERSION sat at "025-what-genesis-does-1"
# through 027 and 028, each of which changed what the model is told, so
# three prompts were recorded as one and the ledger compared them as one
# population.
#
# GUARD. The lists are enumerated from WorldRegistry.modules() and each
# module's own lists(), never written out here, so a world added later is
# covered without editing this file.
#
# FINDING, 068. The two composition floors and the full turn are stated to
# the model and enforced by FeasibilityGate, and are not a declared list's
# size, so the reader above cannot see them at all. Until 068 no file in
# tests/ named FULL_TURN, MIN_STRAIGHTS or MIN_TURNS: the prompt stated all
# three BY HAND and the gate's own FAILED_INFEASIBLE sentence stated the full
# turn by hand a fourth time. Measured: a prompt reading "at least 7
# straights and at least 9 corners or hairpins", with PROMPT_FINGERPRINT
# moved with it the way a real prompt edit moves it, passed all 69 suites.
# The four numbers are now read from the constants and compared here, and the
# gate is handed compositions at the floor and one below it.
#
# FINDING, 068, AND THE ONLY ONE OF THEM THAT WAS LIVE. The floor refusal told
# the player "at least N straights and N corners", and the count beside it
# said "corner" too - but MIN_TURNS is compared against a count of
# TrackGeometry.YAW_TYPES, so a HAIRPIN answers that door as well, which the
# prompt has always said and those two sentences did not. Measured: the floor
# fixture below is MIN_TURNS hairpins and no corner at all whenever the full
# turn splits above 120 deg, and it clears the door.
#
# AND THE CLAIM 068 FIRST WROTE HERE WAS WRONG, which is left in the record
# rather than quietly fixed (TRAPS 14). It said nothing in tests/ had ever
# read those two sentences, on the strength of a grep for "composition has"
# that found nothing. counted_said_test reads them - its needle is built from
# Readback.plural(), so the string a grep would look for is not in the file -
# and it went RED on the fix. What it asserts is the agreement between the
# count and whatever noun follows it, with the noun typed in; it could not
# see the noun being the wrong one. A grep for a sentence finds the suites
# that quote it, not the suites that construct it.
#
# NOT ASSERTED, deliberately: that any particular sentence exists. Nothing
# here requires the prompt to say "Use" or "at most", and every sentence in
# it can be rewritten freely as long as the numbers in it stay true. THE 068
# ASSERTIONS ARE THE EXCEPTION AND SAY SO: the two prompt bounds below, and
# the three sentences read off the gate's own verdicts, match the wording
# around their numbers, because a number with no list noun beside it cannot
# be found any other way. They are a narrower guard than the rest of this
# file and will fail on a rewording that keeps the numbers true. No count of
# them is given here on purpose - a count in a comment is TRAPS 24's shape,
# and the figure in the suite's result line is the one that cannot go stale.
#
# NOT ASSERTED HERE, AND NO LONGER UNASKED. 068 counted 92 numerals in the
# assembled prompt, 41 of them distinct, and left this file accounting for the
# bounds it names and no others, with the rest - enforced bounds, worked
# examples and ordinary prose - described as the next task. 073 took it, and
# split it the other way: a numeral that arrives through a %-substitution is
# the same expression the prompt is built from and cannot drift from what
# produced it, while a numeral TYPED into the template can drift from
# anything. Measured: 74 of the 92 are substituted and 18 are typed.
# tests/prompt_numeral_test.gd holds the 18 - every one of them declared with
# its count, and the facts behind them measured rather than declared - and it
# does NOT re-ask whether a substituted numeral comes from the right
# constant, which is this file's question for the worlds and
# claim_field_test's for the tools. The two halves together are what accounts
# for the 92.
#
# The sentence this paragraph replaces said "separating them is the next task"
# and stood for five commits. It is struck rather than deleted because the
# lesson is 066's: an entry is satisfied by the capability arriving, not by
# the file named in it being touched, so grep for the capability before
# trusting the entry (TRAPS 14, TRAPS 66).
#
# NOT ASSERTED: that the model obeys any of it. No model has read this
# prompt. Whether telling the model the section count changes what it sends
# is the owner's editor session and is in HANDOVER under Next action.

var failures: Array = []
var asserted := 0
var lines: Array = []


func _check(ok: bool, what: String) -> void:
	asserted += 1
	lines.append(("PASS  " if ok else "FAIL  ") + what)
	if not ok:
		failures.append(what)


# Every statement in the prompt about how many of something is allowed, for
# one list's member words. Returns [low, high] pairs, with low -1 where the
# sentence names only a maximum.
func _counts_stated(prompt: String, entry: Dictionary) -> Array:
	var one := str(entry.get("one", ""))
	var many := str(entry.get("many", ""))
	var words: Array = []
	for w in [many, one]:
		if w != "" and not w in words:
			words.append(w)
	var nouns := "|".join(PackedStringArray(words))
	var found: Array = []

	# Case-insensitive, because a sentence that starts with the bound says
	# "At most 8 things" and one that carries it mid-clause says "at most".
	# A test that read only the lower-cased form would have reported the
	# dungeon's things bound as stated nowhere, which is a finding about a
	# regular expression and not about Genesis.
	var span := RegEx.new()
	span.compile("(?i)([0-9]+) to ([0-9]+) (%s)\\b" % nouns)
	for m in span.search_all(prompt):
		found.append([int(m.get_string(1)), int(m.get_string(2))])

	var capped := RegEx.new()
	capped.compile("(?i)(?:at most|up to|no more than) ([0-9]+) (%s)\\b" % nouns)
	for m in capped.search_all(prompt):
		found.append([-1, int(m.get_string(1))])

	# 068: and a MINIMUM stated on its own, which neither pattern above can
	# see. This is the regex-breadth axis of 042's question asked of this
	# file: the two patterns above are correct and between them they can only
	# match a bound that states a maximum. A sentence that states the ceiling
	# in a shape they CAN see and the floor in one they cannot leaves
	# `stated` non-empty, so the "states how many are allowed" assertion
	# passes and the floor is never compared with anything.
	#
	# Readback.list_rule() writes "N to M members" or "up to N members" and
	# never this shape, so TODAY no declared list's statement matches here
	# and this pattern reads nothing. That is said plainly because a reader
	# with no live subject is a check that cannot fail (TRAPS 6): its value
	# is held by a negative control instead - 068 reworded the farm's
	# sentence to "Use at most 24 zones, and at least 9 zones." in a
	# throwaway copy and read the FAIL line naming 9 against the declared 1.
	var floored := RegEx.new()
	floored.compile("(?i)(?:at least|no fewer than|a minimum of) ([0-9]+) (%s)\\b" % nouns)
	for m in floored.search_all(prompt):
		found.append([int(m.get_string(1)), -1])

	return found


# A composition of `straights` straights and `turns` turns, handed to the gate
# directly. Nothing here is a request: FeasibilityGate.check() runs after
# SectionValidator, so the fields only have to be the ones the gate reads -
# the type, and an angle on every turn. The turn angle is FULL_TURN split
# between them so that a composition which clears the floor is not then
# refused as infeasible for an unrelated reason.
func _composition(straights: int, turns: int) -> Array:
	var sections: Array = []
	for i in maxi(straights, 0):
		sections.append({"type": "straight", "length": 100.0})
	var share := FeasibilityGate.FULL_TURN / float(maxi(turns, 1))
	for i in maxi(turns, 0):
		sections.append({
			"type": "hairpin" if share > 120.0 else "corner",
			"radius": 50.0,
			"angle": share,
		})
	return sections


# Does the gate refuse this composition FOR ITS COMPOSITION? Read off the
# category and not the sentence, so a reworded reason does not move the
# answer, and so that a composition refused one door along - FAILED_INFEASIBLE
# - is not counted as this door answering.
func _floor_refused(straights: int, turns: int) -> bool:
	var verdict: Dictionary = FeasibilityGate.check(_composition(straights, turns))
	return str(verdict.get("category", "")) == "FAILED_DEGREES_OF_FREEDOM"


# A member of this list, made distinct from the others. Doors are pairs of
# room numbers and must not repeat; anything with a name needs a new one.
func _member(entry: Dictionary, i: int, rooms: int) -> Variant:
	var sample: Array = entry.get("sample", [])
	if sample.is_empty():
		return {}
	var first = sample[0]
	if typeof(first) == TYPE_ARRAY:
		# Distinct pairs, in the order (1,2), (1,3) ... so that the count is
		# what is being refused and never a repeated pair.
		var a := 1
		var b := 2
		var n := 0
		while n < i:
			b += 1
			if b > rooms:
				a += 1
				b = a + 1
			n += 1
		return [a, b]
	if typeof(first) == TYPE_DICTIONARY:
		var copy: Dictionary = (first as Dictionary).duplicate(true)
		if copy.has("name"):
			copy["name"] = "%s_%d" % [str(copy["name"]), i + 1]
		return copy
	return first


# A request for this world with every list filled from its sample, except
# the one under test, which is given exactly `count` members.
func _request(module: WorldModule, key: String, count: int) -> Dictionary:
	var parameters := {}
	for e in module.lists():
		var entry: Dictionary = e
		parameters[str(entry["key"])] = entry.get("sample", [])
	var under: Dictionary = module.list_of(key)
	# Doors are numbered against the rooms the same request carries, so the
	# room list is widened first and the pairs are built against it.
	var rooms := 60
	if key != "rooms" and module.list_of("rooms") != {}:
		var room_entry: Dictionary = module.list_of("rooms")
		var wide: Array = []
		for i in int(room_entry.get("high", 1)):
			wide.append(_member(room_entry, i, 0))
		parameters["rooms"] = wide
		rooms = wide.size()
	var members: Array = []
	for i in count:
		members.append(_member(under, i, rooms))
	parameters[key] = members

	# Every room joined in a chain, unless the doors are what is being
	# counted. Without this, a request of 24 rooms and one sample door is
	# refused for REACHABILITY in a sentence that happens to begin "24 rooms
	# need at least 23 doors", which the probe below read as the room count
	# being refused. The request is made otherwise legal so that the one
	# door under test is the only one that can answer.
	if key != "doors" and module.list_of("doors") != {}:
		var chain: Array = []
		for i in range(1, (parameters["rooms"] as Array).size()):
			chain.append([i, i + 1])
		parameters["doors"] = chain
	return parameters


# Does the validator refuse this request FOR THE COUNT of that list? Read
# from two things every count refusal in Genesis is built from and no other
# refusal carries together: the bound, as Readback.plural writes it, and the
# size it was handed, as "(got N)". Neither alone is enough - the dungeon's
# reachability refusal names a room count too - and together they name this
# door and nothing else. Any other error in the same request is ignored on
# purpose: what is being measured is one door.
func _count_refused(module: WorldModule, entry: Dictionary, count: int) -> bool:
	var key := str(entry["key"])
	var marker := Readback.plural(int(entry.get("high", 0)), str(entry.get("one", key)), str(entry.get("many", "")))
	var got := "(got %d)" % count
	var result: Dictionary = module.validate(_request(module, key, count))
	for e in (result.get("errors", []) as Array):
		if str(e).contains(marker) and str(e).contains(got):
			return true
	return false


func _initialize() -> void:
	var prompt := AIInterpreter.assembled_prompt()
	var modules := WorldRegistry.modules()
	_check(not modules.is_empty(), "WorldRegistry has worlds to ask")

	# --- every list's count: stated, correct, and enforced ---

	var every: Array = []
	for m in modules:
		var module: WorldModule = m
		for e in module.lists():
			every.append([module, e as Dictionary])

	for pair in every:
		var module: WorldModule = (pair as Array)[0]
		var entry: Dictionary = (pair as Array)[1]
		var key := str(entry["key"])
		var where := "%s '%s'" % [module.command(), key]
		var low := int(entry.get("low", 0))
		var high := int(entry.get("high", 0))

		var stated := _counts_stated(prompt, entry)
		_check(not stated.is_empty(), "%s: the prompt states how many are allowed" % where)
		for s in stated:
			var said_low: int = (s as Array)[0]
			var said_high: int = (s as Array)[1]
			# 068: each half is compared only when the sentence stated it. It
			# used to compare the maximum unconditionally, which is why a
			# minimum-only shape could not simply be added to the reader.
			if said_high >= 0:
				_check(said_high == high, "%s: the prompt's maximum of %d is the declared %d" % [where, said_high, high])
			if said_low >= 0:
				_check(said_low == low, "%s: the prompt's minimum of %d is the declared %d" % [where, said_low, low])

		# And the declaration is the validator's, measured rather than
		# trusted. A declaration edited to match a wrong sentence fails here.
		if low >= 1:
			_check(_count_refused(module, entry, low - 1),
				"%s: %d members is refused for its count" % [where, low - 1])
		_check(not _count_refused(module, entry, low),
			"%s: the declared minimum of %d is accepted" % [where, low])
		_check(not _count_refused(module, entry, high),
			"%s: the declared maximum of %d is accepted" % [where, high])
		_check(_count_refused(module, entry, high + 1),
			"%s: %d members is refused for its count" % [where, high + 1])

	# The plan's steps are declared the same way but validated inside a
	# scene, which this suite does not stand up, so only the stated bound is
	# read here. tests/container_door_test.gd holds the example.
	var steps := GameController.plan_list()
	var plan_stated := _counts_stated(prompt, steps)
	_check(not plan_stated.is_empty(), "PLAN 'steps': the prompt states how many are allowed")
	for s in plan_stated:
		_check((s as Array)[1] == int(steps["high"]),
			"PLAN 'steps': the prompt's maximum of %d is the declared %d" % [(s as Array)[1], int(steps["high"])])

	# --- every stated FIELD bound, against the constant that enforces it ---

	var ranges := [
		["a room's sides", "%.0f to %.0f metres" % [DungeonModule.MIN_SIDE, DungeonModule.MAX_SIDE]],
		["a field's sides", "%.0f to %.0f metres" % [FarmModule.FIELD_SIDE.x, FarmModule.FIELD_SIDE.y]],
		["a building's sides", "%.0f to %.0f metres" % [FarmModule.BUILDING_SIDE.x, FarmModule.BUILDING_SIDE.y]],
		["a straight's length", "%.0f to %.0f metres" % [SectionValidator.STRAIGHT_LENGTH.x, SectionValidator.STRAIGHT_LENGTH.y]],
		["a corner's radius", "%.0f to %.0f metres" % [SectionValidator.CORNER_RADIUS.x, SectionValidator.CORNER_RADIUS.y]],
		["a corner's angle", "%.0f to %.0f degrees" % [SectionValidator.CORNER_ANGLE.x, SectionValidator.CORNER_ANGLE.y]],
		["a hairpin's radius", "%.0f to %.0f metres" % [SectionValidator.HAIRPIN_RADIUS.x, SectionValidator.HAIRPIN_RADIUS.y]],
		["a hairpin's angle", "%.0f to %.0f degrees" % [SectionValidator.HAIRPIN_ANGLE.x, SectionValidator.HAIRPIN_ANGLE.y]],
		["a chicane's radius", "%.0f to %.0f metres" % [SectionValidator.CHICANE_RADIUS.x, SectionValidator.CHICANE_RADIUS.y]],
		["the road's separation", "at least %.0f metres apart" % SeparationCheck.MIN_SEPARATION],
	]
	for r in ranges:
		var what: String = (r as Array)[0]
		var said: String = (r as Array)[1]
		_check(prompt.contains(said), "the prompt states %s as \"%s\"" % [what, said])

	# One number stands for two constants in the closure sentence: the solver
	# may move an angle and a straight's length by the same fraction. If they
	# ever differ, that sentence describes one of them as both, so it has to
	# be split - and this is where that is found out.
	_check(is_equal_approx(ClosureSolver.MAX_ANGLE_ADJUSTMENT, ClosureSolver.MAX_LENGTH_ADJUSTMENT),
		"the solver adjusts an angle and a length by the same fraction, which the prompt says once")

	# 068: and a THIRD constant holds the same fraction. FeasibilityGate
	# carries its own MAX_ANGLE_ADJUSTMENT and decides off it which net turns
	# are reachable, and it states its own copy to the player in
	# FAILED_INFEASIBLE's third reason. The prompt states ClosureSolver's.
	# Nothing asserted the two were the same number, so moving the solver's
	# limit alone would leave the gate refusing compositions the solver can
	# close, in a sentence naming the wrong percentage, with every suite
	# green. grep for MAX_ANGLE_ADJUSTMENT: these two files are the whole
	# class, and MAX_LENGTH_ADJUSTMENT exists in one place only.
	_check(is_equal_approx(FeasibilityGate.MAX_ANGLE_ADJUSTMENT, ClosureSolver.MAX_ANGLE_ADJUSTMENT),
		"the gate decides reachability with the solver's own adjustment limit")

	# --- 068: the two composition floors and the full turn ---
	#
	# These are bounds the model is told and FeasibilityGate enforces, and
	# they are not a declared list's size, so _counts_stated() cannot see
	# them: "at least 2 straights" is neither "N to M members" nor "at most N
	# members", and the straights are a subset of the sections list rather
	# than a list of their own.
	#
	# MEASURED BEFORE THIS WAS WRITTEN, not supposed. No file in tests/ named
	# FULL_TURN, MIN_STRAIGHTS or MIN_TURNS at all. With the prompt reading
	# "at least 7 straights and at least 9 corners or hairpins" - a floor
	# stated four times narrower than the truth, which is TRAPS 28's own
	# fault - and PROMPT_FINGERPRINT moved with it the way any real prompt
	# edit moves it, all 69 suites passed: 0 with something to look at. The
	# fingerprint says the prompt CHANGED. It cannot say the prompt is wrong.
	_check(prompt.contains("at least %d straights and at least %d corners or hairpins" % [
			FeasibilityGate.MIN_STRAIGHTS, FeasibilityGate.MIN_TURNS]),
		"the prompt states the composition floors as %d straights and %d turns" % [
			FeasibilityGate.MIN_STRAIGHTS, FeasibilityGate.MIN_TURNS])
	_check(prompt.contains("%+.0f (clockwise) or %+.0f (anticlockwise)" % [
			FeasibilityGate.FULL_TURN, -FeasibilityGate.FULL_TURN]),
		"the prompt states the full turn as %+.0f and %+.0f degrees" % [
			FeasibilityGate.FULL_TURN, -FeasibilityGate.FULL_TURN])

	# And the floors are the GATE'S, handed compositions rather than trusted.
	# This is the third link of TRAPS 28's chain - prompt, declaration,
	# enforcer - for a bound that has no declaration to sit between them, so
	# the prompt is compared with the constant above and the constant with
	# the running check here. A constant edited to match a wrong sentence
	# fails on these three.
	_check(_floor_refused(FeasibilityGate.MIN_STRAIGHTS - 1, FeasibilityGate.MIN_TURNS),
		"%d straights is refused for the composition" % (FeasibilityGate.MIN_STRAIGHTS - 1))
	_check(_floor_refused(FeasibilityGate.MIN_STRAIGHTS, FeasibilityGate.MIN_TURNS - 1),
		"%d turns is refused for the composition" % (FeasibilityGate.MIN_TURNS - 1))
	_check(not _floor_refused(FeasibilityGate.MIN_STRAIGHTS, FeasibilityGate.MIN_TURNS),
		"the declared floor of %d straights and %d turns clears that door" % [
			FeasibilityGate.MIN_STRAIGHTS, FeasibilityGate.MIN_TURNS])

	# THE FOURTH DOOR THAT STATES THE FULL TURN, held here beside the prompt's
	# rather than in a file of its own, so that the next session fixing one of
	# them sees the other (TRAPS 11). FAILED_INFEASIBLE's second reason is a
	# claim about Genesis made to the PLAYER, and it typed +360 and -360 out
	# by hand next to the constant it was describing. A composition whose
	# turns cancel reaches a net turn of 0 and no adjustment can take it to
	# either full turn, which is the shortest way to that door.
	# Built from the floors rather than from two and two, so that this pair
	# measures the SECOND door for any value of the floors THE GATE KEEPS.
	# Stated at that width on purpose (TRAPS 15): if the gate ever enforces a
	# floor its own constant does not name, a fixture built from the constant
	# lands at the first door instead and these two fail as well - measured,
	# that is what 068's fault 2 did, and the assertion above it names the
	# cause. What the construction removes is the version of that confusion
	# that a mere change of MIN_STRAIGHTS would have caused.
	var cancelled: Array = []
	for i in maxi(FeasibilityGate.MIN_STRAIGHTS, 1):
		cancelled.append({"type": "straight", "length": 100.0})
	var pairs: int = maxi(FeasibilityGate.MIN_TURNS, 2)
	if pairs % 2 == 1:
		pairs += 1
	for i in pairs:
		cancelled.append({
			"type": "corner", "radius": 50.0,
			"angle": 60.0 if i % 2 == 0 else -60.0,
		})
	var infeasible: Dictionary = FeasibilityGate.check(cancelled)
	_check(str(infeasible.get("category", "")) == "FAILED_INFEASIBLE",
		"a composition whose turns cancel is refused as infeasible (%s)" % str(infeasible.get("category", "")))
	var said_turn := "exactly %+.0f or %+.0f deg" % [FeasibilityGate.FULL_TURN, -FeasibilityGate.FULL_TURN]
	var names_turn := false
	for r in (infeasible.get("reasons", []) as Array):
		if str(r).contains(said_turn):
			names_turn = true
	_check(names_turn, "and it tells the player the full turn as \"%s\"" % said_turn)

	# A hairpin is a turn, which is what the prompt's "corners or hairpins"
	# claims and what TrackGeometry.YAW_TYPES decides. Asserted because the
	# floor fixture above is built out of whichever of the two the share of
	# the full turn fits, so a hairpin dropping out of YAW_TYPES would
	# silently change which door those three assertions are measuring.
	_check("hairpin" in TrackGeometry.YAW_TYPES and "corner" in TrackGeometry.YAW_TYPES,
		"the gate counts both a corner and a hairpin as a turn")

	# And the sentence the PLAYER reads at that door has to say so. It said
	# "at least 2 straights and 2 corners" until 068, which is narrower than
	# what clears it: the floor fixture above is MIN_TURNS hairpins and no
	# corner at all when the full turn splits above 120 deg, and the
	# "clears that door" assertion is the measurement that it passes. A
	# refusal naming a narrower set than the check accepts costs the player
	# the design the check would have taken.
	var short_floor: Dictionary = FeasibilityGate.check(
		_composition(maxi(FeasibilityGate.MIN_STRAIGHTS - 1, 0), FeasibilityGate.MIN_TURNS))
	var names_turns := false
	for r in (short_floor.get("reasons", []) as Array):
		if str(r).contains("%d straights and %d corners or hairpins" % [
				FeasibilityGate.MIN_STRAIGHTS, FeasibilityGate.MIN_TURNS]):
			names_turns = true
	_check(names_turns,
		"the floor refusal names both a corner and a hairpin, as the gate counts them")

	# And the COUNT line one above it, which said "corner" for the same count
	# of YAW_TYPES and reported a composition of one hairpin as "1 corner".
	# Held here rather than left to the sentence above, because the two words
	# are one line apart and fixing one of them is TRAPS 11's exact shape.
	#
	# The WORD is typed in here, as it is in counted_said_test. What is
	# measured rather than spelled is the FACT behind it: the YAW_TYPES
	# assertion below, and the "clears that door" assertion above, which is
	# built from MIN_TURNS hairpins and no corner at all.
	var names_count := false
	for r in (short_floor.get("reasons", []) as Array):
		if str(r).contains("composition has ") and str(r).contains(Readback.plural(
				int(short_floor.get("turns", 0)), "turn")):
			names_count = true
	_check(names_count,
		"and the count beside it says turns, not corners")
	_check(prompt.contains("by up to %.0f%%" % (ClosureSolver.MAX_ANGLE_ADJUSTMENT * 100.0)),
		"the prompt states the solver's adjustment as %.0f%%" % (ClosureSolver.MAX_ANGLE_ADJUSTMENT * 100.0))

	# --- every legal value the prompt offers, from the list that admits it ---
	#
	# The circuit's four offered types are already held by capability_test
	# (TRAPS 19's wall), so they are not repeated here. A farm's zone types
	# and crops were held by nothing.

	for type in FarmModule.ZONE_TYPES:
		_check(prompt.contains(str(type)), "the prompt offers the zone type '%s'" % str(type))
	for crop in FarmModule.CROP_COLOURS.keys():
		_check(prompt.contains(str(crop)), "the prompt offers the crop '%s'" % str(crop))

	# --- the version cannot be left behind ---

	var fingerprint := prompt.sha256_text()
	_check(fingerprint == AIInterpreter.PROMPT_FINGERPRINT,
		"the assembled prompt is the one PROMPT_VERSION names (%s, %d characters)%s" % [
			AIInterpreter.PROMPT_VERSION, prompt.length(),
			"" if fingerprint == AIInterpreter.PROMPT_FINGERPRINT
			else " - THE PROMPT CHANGED. Move PROMPT_VERSION and set PROMPT_FINGERPRINT to %s" % fingerprint])

	for line in lines:
		print(line)
	print("")
	print("PROMPT BOUNDS %d assertions, failures=%d" % [asserted, failures.size()])
	quit(1 if failures.size() > 0 else 0)
