extends SceneTree

# --- 069: a player-facing noun names the SET the measurement covers ---
#
# WHERE THIS CAME FROM
#
# HANDOVER's "Smallest useful assistant task next" named this as its first
# live entry, in these words: "three player-facing sentences say 'corner'
# where the code means a TURN", with line numbers - feasibility_gate.gd:100,
# racing_module.gd:176, racing_module.gd:584 - and it called the work "three
# words and a full run".
#
# IT WAS FIVE SENTENCES IN THREE FILES, AND THE LIST OF THREE WAS A READING
# AND NOT THE CLASS (TRAPS 31). Grepping the class rather than taking the
# list found two more:
#
#   racing_module.gd:566   ["SOLVER CHANGE", "corners %.1f%%, straights ..."]
#   main.gd:845            "tightest corner %.0f -> %.0f m radius"
#
# The first matters more than any of the three that were named, because it
# is a PANEL ROW: a player meets it after every circuit that was BUILT, and
# the three on the list are all reached only by a REFUSAL. The second is the
# same fault over a different set - TrackMetrics takes minimum_radius over
# TrackGeometry.CURVED_TYPES, which is corner, hairpin, banked_corner,
# chicane and loop_segment - and it is the one reading of three that drifted:
# racing_module.gd's "TIGHTEST RADIUS" row and experiment_runner.gd's
# "tightest radius" already name the same number correctly.
#
# THE GENERAL RULE, stated so it can be applied rather than admired: a
# sentence shown to a player that names a section type is making a claim
# about which sections the number beside it was taken over. The claim is
# true only if the noun names that whole set. The solver's angle adjustment
# is taken over TrackGeometry.YAW_TYPES, so its noun is "turn". The tightest
# radius is taken over TrackGeometry.CURVED_TYPES, so its noun is "radius"
# and no type at all.
#
# WHAT THIS SUITE ASSERTS, AND WHY IT IS A FACT AND NOT A WORDING (TRAPS 6)
#
# Every fixture below is built out of HAIRPINS AND STRAIGHTS AND CONTAINS NO
# CORNER AT ALL - asserted, not assumed, by _no_corner_in() on the sections
# actually handed to the code. A sentence about such a composition that uses
# the word "corner" is therefore FALSE about the thing it describes, and the
# assertion is that it does not. This is not "the sentence says turn": renaming
# a turn to anything else that is true of a hairpin passes, and the
# pre-069 wording fails naming the sentence.
#
# The assertions are paired. For each sentence the suite first measures the
# FACT the sentence reports - that the solver really did build an angle
# variable for a hairpin, that the gate's reach really is computed from a
# hairpin's angle, that minimum_radius really is a hairpin's radius - and
# then reads the sentence. A sentence that vanished would pass a
# "does not say corner" check on its own, so each one is also asserted to be
# PRESENT and to carry its number.
#
# WHAT IT DOES NOT ASSERT, AND ONE OF THESE IS A LIVE GAP
#
# THE STRAIGHT-FAMILY HALF OF THE SAME SENTENCES IS NOT ASSERTED AND IS NOT
# FIXED. The solver length-adjusts every section in
# TrackGeometry.STRAIGHT_FAMILY - straight, uphill, downhill, crest and dip -
# and all four of the sentences that name "straights" beside "turns" name
# only the first of the five. That is the identical fault one word along, and
# it is LEFT ALONE DELIBERATELY: the four slope types are the subject of
# "Human decision needed" 1 (SectionValidator accepts ten types, the prompt
# offers four and says "only these four", and GENESIS_BRIEF records that
# nothing drives the vertical axis safely yet). Choosing the word a player
# reads for a set the owner has not decided to open is his call and not this
# session's. Measured, not supposed: SectionValidator.OFFERED_TYPES is
# ["straight", "corner", "hairpin", "chicane"], so of YAW_TYPES two of three
# members are offered and of STRAIGHT_FAMILY one of five is - which is
# exactly why the turn half was live and the straight half is not.
# The assertion below pins the fact so the gap cannot be forgotten: it fails
# if a slope type ever becomes offered while those sentences still say
# "straights".
#
# NOT ASSERTED: that a hairpin's adjusted angle is the RIGHT angle. That is
# procedure_test's subject, which already holds max_angle_adjustment against
# angle_limit. This suite is about the noun.
#
# NOT ASSERTED: that any model ever sends a hairpin. No model has read
# anything here; there is no API key in the harness that runs this.

var failures: Array = []
var asserted := 0
var lines: Array = []


func _check(ok: bool, what: String) -> void:
	asserted += 1
	lines.append(("PASS  " if ok else "FAIL  ") + what)
	if not ok:
		failures.append(what)


# The word a sentence must not use about a composition that has none. Lower
# case so a label ("SOLVER CHANGE") and a sentence are read the same way, and
# "banked_corner" would match too - which is wanted, since no fixture here
# has one either.
func _says_corner(text: String) -> bool:
	return text.to_lower().contains("corner")


# Every fixture's own guarantee, asserted on the sections actually passed in
# rather than trusted from the builder above.
func _no_corner_in(sections: Array) -> bool:
	for s in sections:
		if str((s as Dictionary).get("type", "")).contains("corner"):
			return false
	return true


# Straights and HAIRPINS only, the straights first. The angles are handed in
# so a fixture can be aimed at one door - cancelling turns for the gate's
# reach, a near-full turn for the solver - and the radius and angle are
# inside SectionValidator's HAIRPIN_RADIUS and HAIRPIN_ANGLE so the
# composition is one a validated request could really carry.
#
# THIS ORDER DOES NOT CLOSE, and that is deliberate rather than incidental:
# putting both straights before both turns is what makes the solver work and
# fail. 069's first draft of this helper was used for a fixture it described
# as a paperclip and measured a 160 m closure miss on, which read like a
# solver fault and was not one: a paperclip ALTERNATES straight and turn, and
# ClosureSolver closes the real one exactly (proposal distance 0.0000,
# ok=true, zero adjustment - measured). The fixture was wrong, not the code.
# _paperclip() below builds the alternating one, and the claim is left here
# rather than quietly dropped (TRAPS 14).
func _hairpins(straight_lengths: Array, angles: Array) -> Array:
	var sections: Array = []
	for length in straight_lengths:
		sections.append({"type": "straight", "length": float(length)})
	for angle in angles:
		sections.append({"type": "hairpin", "radius": 50.0, "angle": float(angle)})
	return sections


# The alternating one, which closes: straight, 180-degree hairpin, the same
# straight back, the same hairpin home. Used for the panel row, because that
# row is the one member of this class a player meets on a circuit that was
# BUILT rather than refused.
func _paperclip() -> Array:
	return [
		{"type": "straight", "length": 100.0},
		{"type": "hairpin", "radius": 50.0, "angle": 180.0},
		{"type": "straight", "length": 100.0},
		{"type": "hairpin", "radius": 50.0, "angle": 180.0},
	]


func _initialize() -> void:
	_the_sets()
	_the_gates_reach()
	_the_solvers_adjustment()
	_the_tightest_radius()
	_what_changed_about_a_world_the_list_cannot_name()

	for line in lines:
		print(line)
	print("")
	print("SAID SET %d assertions, failures=%d" % [asserted, failures.size()])
	quit(1 if failures.size() > 0 else 0)


# --- the sets themselves, so the rest of the suite is measuring the door it
# --- thinks it is measuring
func _the_sets() -> void:
	_check("hairpin" in TrackGeometry.YAW_TYPES,
		"a hairpin is one of the sections the solver adjusts the angle of (YAW_TYPES: %s)" % str(TrackGeometry.YAW_TYPES))
	_check(TrackGeometry.YAW_TYPES.size() > 1,
		"and it is not the only one, so no single type's name covers the set (%d members)" % TrackGeometry.YAW_TYPES.size())
	_check("hairpin" in TrackGeometry.CURVED_TYPES and "chicane" in TrackGeometry.CURVED_TYPES,
		"the tightest radius is taken over a set wider than the turns (CURVED_TYPES: %s)" % str(TrackGeometry.CURVED_TYPES))

	# A hairpin is OFFERED, which is what makes the turn half of this class
	# live rather than latent: a player can compose one today.
	_check("hairpin" in SectionValidator.OFFERED_TYPES,
		"a hairpin is a type the prompt offers the player (%s)" % str(SectionValidator.OFFERED_TYPES))

	# And the straight half is latent for exactly one reason, pinned here so
	# it cannot quietly stop being true. See this file's header: the
	# "straights" in those sentences is the same fault, left for the owner.
	var offered_slopes: Array = []
	for t in TrackGeometry.SLOPE_TYPES:
		if t in SectionValidator.OFFERED_TYPES:
			offered_slopes.append(t)
	_check(offered_slopes.is_empty(),
		"no slope type is offered yet, which is why \"straights\" is not this session's to reword (offered slopes: %s)" % str(offered_slopes))


# --- feasibility_gate.gd:100 — "with up to N% adjustment per <noun>" ---
func _the_gates_reach() -> void:
	# Two hairpins that cancel: the floor is cleared, so the gate reaches its
	# reach sentence rather than its composition sentence, and +-FULL_TURN is
	# far outside what 20% of these angles can reach.
	var sections := _hairpins([100.0, 100.0], [150.0, -150.0])
	_check(_no_corner_in(sections), "the gate fixture is straights and hairpins, with no corner in it")

	var gate: Dictionary = FeasibilityGate.check(sections)
	_check(str(gate.get("category", "")) == "FAILED_INFEASIBLE",
		"a composition of hairpins whose turns cancel is refused as infeasible (%s)" % str(gate.get("category", "")))

	# THE FACT the sentence reports: the reach was computed from the HAIRPINS.
	# Both of them, and nothing else in the composition turns, so a reach of
	# exactly +-20% of their total is the measurement that they were counted.
	_check(int(gate.get("turns", -1)) == 2,
		"the gate counted both hairpins as turns (%s)" % str(gate.get("turns", -1)))
	var expected := FeasibilityGate.MAX_ANGLE_ADJUSTMENT * 300.0
	_check(absf(float(gate.get("reachable_max", 0.0)) - expected) < 0.01,
		"and its reach is %.0f%% of the hairpins' own angles (%+.1f deg, expected %+.1f)" % [
			FeasibilityGate.MAX_ANGLE_ADJUSTMENT * 100.0, float(gate.get("reachable_max", 0.0)), expected])

	# THE SENTENCE. Present, carrying its number, and not naming a section
	# type the composition does not contain.
	var reach_line := ""
	for r in (gate.get("reasons", []) as Array):
		if str(r).contains("%.0f%% adjustment per" % (FeasibilityGate.MAX_ANGLE_ADJUSTMENT * 100.0)):
			reach_line = str(r)
	_check(reach_line != "",
		"the refusal tells the player the adjustment it allows (said: %s)" % str(gate.get("reasons", [])))
	_check(not _says_corner(reach_line),
		"and it does not call these hairpins corners (said: %s)" % reach_line)


# --- racing_module.gd:176, :566 and :584 — the solver's own three sentences ---
func _the_solvers_adjustment() -> void:
	var module := RacingModule.new()

	# Two hairpins at 175 degrees turn 350, which the gate's 20% reach covers,
	# so the solver is handed a target of +360 it must change ANGLES to meet.
	# Chosen over the other fixtures measured for this: it is the one where
	# the solver moves a hairpin's angle by a visible amount rather than by a
	# rounding error, which is what makes the assertion below a fact.
	var sections := _hairpins([300.0, 300.0], [175.0, 175.0])
	_check(_no_corner_in(sections), "the solver fixture is straights and hairpins, with no corner in it")

	var record := {}
	var pre: Dictionary = module.pre_check({"sections": sections}, record)
	_check(bool(pre.get("ok", false)),
		"the gate passes it, so the solver is reached (%s)" % str(pre.get("reasons", [])))
	if not bool(pre.get("ok", false)):
		return

	var out: Dictionary = module.solve(pre["content"])
	_check(not bool(out.get("ok", true)),
		"and the solver cannot close it, so it says what adjustment it used")
	if bool(out.get("ok", true)):
		return

	# THE FACT the three sentences report. Nothing in this composition turns
	# except the two hairpins, so an angle adjustment of this size is a
	# HAIRPIN'S angle having been changed - measured, not supposed. Asserted
	# well above zero on purpose: 069's first draft asserted "> 0.0" against a
	# fixture that reported 0.00001335, which PASSED and proved nothing, and
	# is TRAPS 6's shape - an assertion satisfied for a reason other than the
	# one it names.
	var solved: Dictionary = out["solver"]
	var moved := float(solved.get("max_angle_adjustment", 0.0))
	_check(moved > 0.01,
		"the solver changed a hairpin's angle by %.1f%% of itself, so the adjustment it reports is a hairpin's" % (moved * 100.0))

	# SENTENCE ONE - racing_module.gd:176, a refusal reason.
	var used_line := ""
	for r in (out.get("reasons", []) as Array):
		if str(r).begins_with("adjustment used:"):
			used_line = str(r)
	_check(used_line != "",
		"the refusal reports the adjustment it used (said: %s)" % str(out.get("reasons", [])))
	_check(used_line.contains("%.1f%%" % (moved * 100.0)),
		"and the number it reports is that one (said: %s)" % used_line)
	_check(not _says_corner(used_line),
		"and it does not call these hairpins corners (said: %s)" % used_line)

	# SENTENCE TWO - racing_module.gd:584, the closure feedback prose.
	var feedback := str(module.correction_feedback(out))
	var adjusted_line := ""
	for line in feedback.split("\n"):
		if str(line).contains("adjusted every"):
			adjusted_line = str(line)
	_check(adjusted_line != "",
		"the feedback tells the player what was adjusted (said: %s)" % feedback.substr(0, 200))
	_check(not _says_corner(adjusted_line),
		"and it does not call these hairpins corners (said: %s)" % adjusted_line)

	# The sentence below it in the same function already used the right word
	# for the same set, which is where 069's wording came from rather than
	# from invention.
	_check(feedback.contains("keeping your turns as they are"),
		"and the sentence below it says \"turns\" for the same set, as it already did")

	# SENTENCE THREE - racing_module.gd:566, the SOLVER CHANGE panel row. The
	# member HANDOVER's list of three did not name, and the only one of the
	# five a player meets on a circuit that was BUILT - so it is asserted on a
	# circuit that CLOSED, which is the context it is really shown in.
	var closed := _paperclip()
	_check(_no_corner_in(closed), "the panel fixture is straights and hairpins, with no corner in it")
	var closed_record := {}
	var closed_pre: Dictionary = module.pre_check({"sections": closed}, closed_record)
	_check(bool(closed_pre.get("ok", false)),
		"a paperclip of two hairpins passes the gate (%s)" % str(closed_pre.get("reasons", [])))
	var closed_out: Dictionary = module.solve(closed_pre["content"])
	_check(bool(closed_out.get("ok", false)),
		"and it CLOSES, so the panel row below is the one a built circuit shows (%s)" % str(closed_out.get("category", "")))

	var fields: Dictionary = module.solve_record(closed_out)
	_check(fields.has("drift"),
		"the record carries the solver's drift, which is what the panel row reads")
	var metrics: Dictionary = TrackMetrics.measure(closed)
	var drift_row := ""
	for row in module.metric_lines(metrics, fields):
		var pair: Array = row as Array
		if str(pair[0]) == "SOLVER CHANGE":
			drift_row = "%s %s" % [str(pair[0]), str(pair[1])]
	_check(drift_row != "",
		"the panel has a row for it")
	_check(not _says_corner(drift_row),
		"and that row does not call this circuit's turns corners (said: %s)" % drift_row)


# --- main.gd:845 — "tightest <noun>" for a number taken over CURVED_TYPES ---
func _the_tightest_radius() -> void:
	# THE FACT: minimum_radius is a hairpin's radius when a hairpin is the
	# tightest thing on the circuit. Measured through TrackMetrics, which is
	# the function main.gd's line reads.
	var sections := _hairpins([400.0], [180.0])
	_check(_no_corner_in(sections), "the radius fixture is a straight and a hairpin, with no corner in it")
	var metrics: Dictionary = TrackMetrics.measure(sections)
	_check(absf(float(metrics.get("minimum_radius", -1.0)) - 50.0) < 0.01,
		"the tightest radius on a circuit of hairpins is a hairpin's radius (%.1f m)" % float(metrics.get("minimum_radius", -1.0)))

	# THE SENTENCE, read off main.gd's own function rather than its source.
	var main = load(str(ProjectSettings.get_setting("application/run/main_scene"))).instantiate()
	get_root().add_child(main)
	var before := {"command": "CREATE_CIRCUIT", "parameters": {"a": 1}, "metrics": {"minimum_radius": 50.0}}
	var after := {"command": "CREATE_CIRCUIT", "parameters": {"a": 2}, "metrics": {"minimum_radius": 20.0}}
	var said := str(main._describe_changes(before, after))
	_check(said.contains("50") and said.contains("20"),
		"main.gd reports a changed tightest radius (said: %s)" % said)
	_check(not _says_corner(said),
		"and it does not call it a corner, which it is only one of five types of (said: %s)" % said)
	main.queue_free()


# --- 116: "no measured difference in size or pieces", about a world whose
# --- measurements had moved on seven keys ---
#
# THE SAME SHAPE AS EVERYTHING ABOVE, one layer down. The sentences above are
# player-facing sentences that name the SET a number was taken over. This one
# is a player-facing sentence that names a MEASUREMENT - "no measured
# difference" - and the claim is about every metric the world has, not about a
# noun. main._describe_changes() reads seven keys by name: three circuit keys,
# the "counts" sub-dictionary, and four farm keys. A dungeon's metrics block
# has SIXTEEN keys and not one of them is any of those, so a dungeon edited
# from 12x12 rooms to 16x16 was told there was no measured difference while
# Genesis's own block moved on seven of them. Driven in 116 through the real
# scene before any of this was written: floor_area 432 -> 768, corridor_area
# 176 -> 208, corridor_length 36 -> 44, largest_room_area 144 -> 256, pitch
# 18 -> 22, width 48 -> 60, depth 12 -> 16.
#
# WHAT IS ASSERTED, AND IT IS THE CLASS AND NOT THE DUNGEON (TRAPS 11)
#
# FINDING. For a world whose metrics moved, the line names the key and both
# numbers for EVERY numeric metric that moved, and does not say there was no
# measured difference. Against the pre-116 function the dungeon rows fail.
#
# GUARD, and this is the row that keeps the fix general. The moved keys are
# checked against main.NAMED_ABOVE - the list the hand-written branches
# cover - and a dungeon's are asserted to be OUTSIDE it. That is the fact
# that made the sentence false: a world type the list cannot reach. If
# somebody closes this by adding four dungeon keys to the branches above
# instead, this row says so.
#
# GUARD. No metric is said TWICE. A key named by a branch above and left in
# the general pass would be, and the two are kept in step by a constant that
# nothing else reads - so this row is the only thing holding them together.
#
# NON-VACUITY, BOTH WAYS. The metrics are measured through the modules' own
# measure(), not written out here, and the suite first asserts that at least
# one key really moved - without that row every comparison below passes on a
# world that did not change. And a world where NOTHING moved is asserted to
# still get the old sentence, because there it is TRUE: the fix is that the
# sentence is said when it is true, not that it is never said.
#
# NOT ASSERTED, deliberately: the order of the parts, the separator, the
# wording of the three circuit branches (held by _the_tightest_radius above),
# and anything about what the AI sends. No model answered anything here.
func _what_changed_about_a_world_the_list_cannot_name() -> void:
	var main = load(str(ProjectSettings.get_setting("application/run/main_scene"))).instantiate()
	get_root().add_child(main)

	# --- a dungeon, measured through DungeonModule rather than written out ---
	var small := {"rooms": [
		{"name": "hall", "width": 12, "depth": 12},
		{"name": "middle", "width": 12, "depth": 12},
		{"name": "vault", "width": 12, "depth": 12}], "doors": [[1, 2], [2, 3]]}
	var big := {"rooms": [
		{"name": "hall", "width": 16, "depth": 16},
		{"name": "middle", "width": 16, "depth": 16},
		{"name": "vault", "width": 16, "depth": 16}], "doors": [[1, 2], [2, 3]]}
	var m0 := _measured(DungeonModule.new(), small)
	var m1 := _measured(DungeonModule.new(), big)
	_check(m0.size() >= 10 and m1.size() >= 10,
		"a dungeon's metrics block is measured by its own module (%d keys)" % m0.size())

	var moved := _moved_between(m0, m1)
	_check(moved.size() >= 1,
		"making every room bigger moves at least one measurement, so the rows below are not vacuous (%s)" % str(moved))

	# THE FACT THE SENTENCE WAS FALSE ABOUT: not one of those keys is a key the
	# hand-written branches can name.
	var reachable: Array = []
	for key in moved:
		if main.NAMED_ABOVE.has(str(key)):
			reachable.append(str(key))
	_check(reachable.is_empty(),
		"and none of them is a key the named branches cover, which is why a dungeon got the sentence at all (overlap: %s)" % str(reachable))

	var said := str(main._describe_changes(
		{"command": "CREATE_DUNGEON", "parameters": small, "metrics": m0},
		{"command": "CREATE_DUNGEON", "parameters": big, "metrics": m1}))
	_check(not said.contains("no measured difference"),
		"a dungeon whose measurements moved is NOT told there was no measured difference (said: %s)" % said)
	for key in moved:
		if not _is_num(m0[key]) or not _is_num(m1[key]):
			continue
		var label := str(key).replace("_", " ")
		_check(said.contains(label),
			"the line names '%s', which moved (said: %s)" % [label, said])
		_check(said.contains("%.0f" % float(m0[key])) and said.contains("%.0f" % float(m1[key])),
			"and carries both of its numbers, %.0f and %.0f" % [float(m0[key]), float(m1[key])])
		_check(said.count(label) == 1,
			"and says '%s' exactly once, so no branch and the general pass both name it" % label)

	# --- the same world, unchanged: the sentence is TRUE and is still said ---
	var same := str(main._describe_changes(
		{"command": "CREATE_DUNGEON", "parameters": small, "metrics": m0},
		{"command": "CREATE_DUNGEON", "parameters": big.duplicate(true), "metrics": m0.duplicate(true)}))
	_check(same.contains("no measured difference"),
		"a world whose measurements did NOT move still gets that sentence, because there it is true (said: %s)" % same)

	# --- a farm: the keys the branches DO cover are still named, once ---
	var farm_small := {"zones": [{"type": "barn", "width": 20, "depth": 20}]}
	var farm_big := {"zones": [{"type": "barn", "width": 30, "depth": 30}]}
	var f0 := _measured(FarmModule.new(), farm_small)
	var f1 := _measured(FarmModule.new(), farm_big)
	var farm_moved := _moved_between(f0, f1)
	_check(farm_moved.size() >= 1,
		"a bigger barn moves at least one of a farm's measurements (%s)" % str(farm_moved))
	var farm_said := str(main._describe_changes(
		{"command": "CREATE_FARM", "parameters": farm_small, "metrics": f0},
		{"command": "CREATE_FARM", "parameters": farm_big, "metrics": f1}))
	# Every moved key exactly once, whichever half of the function names it -
	# NOT gated on NAMED_ABOVE, because a row that only looks at the keys the
	# constant lists cannot see the constant losing one. Emptying NAMED_ABOVE
	# makes a branch and the general pass BOTH name farm width, and these are
	# the rows that say so.
	var covered := false
	for key in farm_moved:
		_check(farm_said.count(str(key).replace("_", " ")) == 1,
			"a farm measurement that moved is said exactly once: '%s' (said: %s)" % [str(key), farm_said])
		if main.NAMED_ABOVE.has(str(key)):
			covered = true
	_check(covered,
		"and at least one of the farm keys that moved is one the branches cover, so this world reaches both halves (%s)" % str(farm_moved))

	# --- the change no NUMBER shows: a measurement that is a room's NAME ---
	#
	# Two rooms, 20x20 and 12x12, and then the same two sizes the other way
	# round. Measured: every one of the sixteen numbers is identical and
	# largest_room moves hall -> vault. So this world measurably changed and
	# no numeric comparison in the function - old or new - can see it, which
	# is why the general pass compares a non-numeric metric as itself. The
	# row asserts the metrics block first, so it fails loudly if the module
	# ever starts moving a number here too and the fixture stops being the
	# one-metric case it was chosen for.
	var hall_big := {"rooms": [
		{"name": "hall", "width": 20, "depth": 20},
		{"name": "vault", "width": 12, "depth": 12}], "doors": [[1, 2]]}
	var vault_big := {"rooms": [
		{"name": "hall", "width": 12, "depth": 12},
		{"name": "vault", "width": 20, "depth": 20}], "doors": [[1, 2]]}
	var n0 := _measured(DungeonModule.new(), hall_big)
	var n1 := _measured(DungeonModule.new(), vault_big)
	var name_moved := _moved_between(n0, n1)
	_check(name_moved.size() == 1 and str(name_moved[0]) == "largest_room",
		"swapping which room is biggest moves exactly one measurement, and it is a NAME (%s)" % str(name_moved))
	var swapped := str(main._describe_changes(
		{"command": "CREATE_DUNGEON", "parameters": hall_big, "metrics": n0},
		{"command": "CREATE_DUNGEON", "parameters": vault_big, "metrics": n1}))
	_check(not swapped.contains("no measured difference"),
		"and the player is not told there was no measured difference (said: %s)" % swapped)
	_check(swapped.contains(str(n0["largest_room"])) and swapped.contains(str(n1["largest_room"])),
		"the line carries both room names, '%s' and '%s' (said: %s)" % [str(n0["largest_room"]), str(n1["largest_room"]), swapped])

	# --- the unit comes from the metric's own name ---
	#
	# A fact about the rule rather than about the sentence: a metric wearing
	# the wrong unit is a false claim about the world, so where the name does
	# not say, the rule says nothing.
	_check(str(main._unit_of("floor_area")) == " m2",
		"an area is said in m2 (got '%s')" % str(main._unit_of("floor_area")))
	_check(str(main._unit_of("corridor_length")) == " m",
		"a length is said in m (got '%s')" % str(main._unit_of("corridor_length")))
	_check(str(main._unit_of("room_count")) == "",
		"and a count carries no unit rather than a guessed one (got '%s')" % str(main._unit_of("room_count")))

	main.queue_free()


# A world's metrics, through the module's own chain: validate, pre_check,
# solve, measure. The same four calls game_controller._prepare_world makes, so
# what this suite compares is what a player's world is measured as.
func _measured(module, parameters: Dictionary) -> Dictionary:
	var record := {}
	var check: Dictionary = module.validate(parameters)
	if not bool(check.get("ok", false)):
		_check(false, "the fixture validates (%s)" % str(check.get("errors", [])))
		return {}
	var pre: Dictionary = module.pre_check(check["content"], record)
	if not bool(pre.get("ok", false)):
		_check(false, "the fixture passes the gate (%s)" % str(pre.get("reasons", [])))
		return {}
	var solved: Dictionary = module.solve(pre["content"])
	if not bool(solved.get("ok", false)):
		_check(false, "the fixture solves (%s)" % str(solved.get("reasons", [])))
		return {}
	return module.measure(solved["layout"])


# The keys present in both blocks whose value is not the same, by the same
# threshold the function uses for a number.
func _moved_between(m0: Dictionary, m1: Dictionary) -> Array:
	var out: Array = []
	for key in m0:
		if not m1.has(key):
			continue
		if _is_num(m0[key]) and _is_num(m1[key]):
			if absf(float(m1[key]) - float(m0[key])) >= 1.0:
				out.append(key)
		elif str(m0[key]) != str(m1[key]):
			out.append(key)
	return out


func _is_num(value: Variant) -> bool:
	return typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT
