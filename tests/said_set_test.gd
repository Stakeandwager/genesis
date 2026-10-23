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
var lines: Array = []


func _check(ok: bool, what: String) -> void:
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

	for line in lines:
		print(line)
	print("")
	print("SAID SET failures=%d" % failures.size())
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
