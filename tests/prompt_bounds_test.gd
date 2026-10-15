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
# NOT ASSERTED, deliberately: that any particular sentence exists. Nothing
# here requires the prompt to say "Use" or "at most", and every sentence in
# it can be rewritten freely as long as the numbers in it stay true.
#
# NOT ASSERTED: that the model obeys any of it. No model has read this
# prompt. Whether telling the model the section count changes what it sends
# is the owner's editor session and is in HANDOVER under Next action.

var failures: Array = []
var lines: Array = []


func _check(ok: bool, what: String) -> void:
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

	return found


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
	print("PROMPT BOUNDS failures=%d" % failures.size())
	quit(1 if failures.size() > 0 else 0)
