extends SceneTree

# --- 039: the arithmetic the prompt states is arithmetic Genesis does ---
#
# HANDOVER named the next assistant task as the one kind of prompt claim with
# no door: the PROCEDURAL sentence - a flat statement about what Genesis will
# do with a value the model sends. It quoted eight of them. Asked of the
# class rather than of that list (TRAPS 11), the sharpest sub-class is the
# one that can be CHECKED BY DOING THE ARITHMETIC: a sentence stating a
# relation between numbers the model sends and a number Genesis computes.
# Six such sentences are in the assembled prompt and five of them were right.
#
# THE ONE THAT WAS NOT, and it is TRAPS 32's shape one category along:
#
#   "Top speed is push divided by weight times footing"
#
# written in 010 and never read again. BootsTool.top_speed() returns
#
#   push / (weight * footing)
#
# and the sentence, read by the arithmetic convention its own words follow -
# left to right, division and multiplication equal - says
#
#   (push / weight) * footing
#
# which differs for EVERY legal spec and, worse, puts `footing` on the wrong
# side of the division. The sentence therefore says raising footing RAISES
# top speed. Four lines above it, the footing bullet says the opposite, in
# numbers rendered from this same function: "at 1.50 an ordinary body walks
# at 2.00 m/s rather than 4.48". 038 rewrote that bullet and did not read
# this line, exactly as 013 measured `brake` and did not read the sentence
# 038 came back for.
#
# What it costs is not cosmetic, and it costs in both directions, like 035's
# farm bound. TOP_SPEED is 2 to 12 m/s and a spec outside it is refused
# whatever its fields:
#
#   push 600, weight 50, footing 0.40   sentence 4.80 (legal)   Genesis 30.00  REFUSED
#   push 600, weight 140, footing 0.40  sentence 1.71 (refused) Genesis 10.71  legal
#
# A model obeying the instruction exactly proposes specs Genesis refuses, and
# withholds specs Genesis would accept.
#
# WHAT THIS SUITE ASSERTS, AND WHAT IT DOES NOT (TRAPS 6, TRAPS 14)
#
# Not the wording. The formula sentence is READ OUT OF THE ASSEMBLED PROMPT,
# tokenised, and EVALUATED as arithmetic for a grid of specs spanning the
# declared ranges, then compared with the function. So the sentence may be
# rephrased freely and this stays green; it fails the moment the words stop
# meaning what the code does. A sentence this cannot parse FAILS rather than
# passing, because the failure mode of a sweep is silence (TRAPS 31).
#
# The other five arithmetic claims are measured rather than read, each by
# building the thing the sentence describes:
#
#   "O is more than 0 and at most 2 x R"              at both ends and outside
#   "A chicane steps the track sideways by O metres
#    and returns to its original direction"           to the millimetre
#   "a hairpin ... carries the track back only by
#    its own width, twice its radius"                 at three radii
#   "Chicanes do not count" toward the +/-360         by difference
#   "Angles are signed: positive turns right"         both signs
#
# THE DIRECTION, which is the half that was false and the half a formula can
# get wrong while still producing plausible numbers: raising push raises top
# speed, raising weight lowers it, raising footing LOWERS it. Measured from
# top_speed(), asserted independently of any sentence, so a formula that is
# reworded into the old mistake fails here too.

var failures: Array = []
var lines: Array = []


func _check(ok: bool, what: String) -> void:
	lines.append(("PASS  " if ok else "FAIL  ") + what)
	if not ok:
		failures.append(what)


func _note(what: String) -> void:
	lines.append("      " + what)


# --- the evaluator ---
#
# Strict left to right, which is what "a divided by b times c" means under
# every arithmetic convention and is the reading a model computing the
# number will use. Parentheses are the only thing that changes the order,
# which is the whole point of writing them. Returns NAN if the text is not
# arithmetic this understands - and a NAN fails, it does not pass.
func _evaluate(text: String, values: Dictionary) -> float:
	var spaced := text.replace("(", " ( ").replace(")", " ) ")
	spaced = spaced.replace("divided by", "/").replace("multiplied by", "*")
	spaced = spaced.replace(" times ", " * ").replace(" x ", " * ")
	spaced = spaced.replace("/", " / ").replace("*", " * ")
	var tokens := PackedStringArray()
	for raw in spaced.split(" ", false):
		var piece := str(raw).strip_edges()
		if piece != "":
			tokens.append(piece)
	var at := [0]
	var out := _expression(tokens, at, values)
	if at[0] != tokens.size():
		return NAN
	return out


func _expression(tokens: PackedStringArray, at: Array, values: Dictionary) -> float:
	var left := _term(tokens, at, values)
	while at[0] < tokens.size():
		var op := tokens[at[0]]
		if op != "/" and op != "*":
			break
		at[0] += 1
		var right := _term(tokens, at, values)
		if is_nan(left) or is_nan(right):
			return NAN
		left = left / right if op == "/" else left * right
	return left


func _term(tokens: PackedStringArray, at: Array, values: Dictionary) -> float:
	if at[0] >= tokens.size():
		return NAN
	var token := tokens[at[0]]
	at[0] += 1
	if token == "(":
		var inner := _expression(tokens, at, values)
		if at[0] >= tokens.size() or tokens[at[0]] != ")":
			return NAN
		at[0] += 1
		return inner
	if values.has(token):
		return float(values[token])
	if token.is_valid_float():
		return float(token)
	return NAN


# The sentence a tool states a formula in: the clause between "<something>
# is" and the punctuation that ends it, naming two or more of that tool's
# own declared fields. Enumerated from the section rather than quoted, so a
# tool that grows a formula gets a row and a tool that loses one is counted.
func _formula_clauses(section: String, fields: Array) -> Array:
	var found: Array = []
	for raw_line in section.split("\n"):
		var line := str(raw_line)
		var at := line.find(" is ")
		if at < 0:
			continue
		var clause := line.substr(at + 4)
		for stop in [". ", ": ", ", and", ","]:
			var cut := clause.find(stop)
			if cut >= 0:
				clause = clause.substr(0, cut)
		var named := 0
		for field in fields:
			if clause.contains(str(field)):
				named += 1
		if named >= 2 and (clause.contains("divided") or clause.contains(" times ") or clause.contains(" x ")):
			found.append({"subject": line.substr(0, at).strip_edges(), "clause": clause.strip_edges()})
	return found


func _initialize() -> void:
	var prompt := AIInterpreter.assembled_prompt()

	# --------------------------------------------------------------------
	# 1. Every formula a tool states is the arithmetic that tool performs.
	# --------------------------------------------------------------------
	var formulas := 0
	for entry in ToolRegistry.tools():
		var tool: ToolModule = entry
		var fields: Array = tool.defaults().keys()
		var section := tool.prompt_section()
		_check(prompt.contains(section), "the %s section is in the assembled prompt" % tool.name())
		for found in _formula_clauses(section, fields):
			formulas += 1
			var clause := str(found["clause"])
			_note("%s: \"%s is %s\"" % [tool.name(), str(found["subject"]), clause])
			if tool.name() != "boots":
				_check(false, "a formula this suite has no measurement for: %s" % clause)
				continue

			# Evaluated for a grid spanning the declared ranges, so the
			# sentence is held against the function everywhere it is legal
			# to ask, not at the one spec somebody had in mind.
			var worst := 0.0
			var compared := 0
			var unreadable := false
			for push in [BootsTool.PUSH[0], BootsTool.DEFAULT_PUSH, BootsTool.PUSH[1]]:
				for weight in [BootsTool.WEIGHT[0], BootsTool.DEFAULT_WEIGHT, BootsTool.WEIGHT[1]]:
					for footing in [BootsTool.FOOTING[0], BootsTool.DEFAULT_FOOTING, BootsTool.FOOTING[1]]:
						var spec := {"push": push, "weight": weight, "footing": footing}
						var said := _evaluate(clause, spec)
						if is_nan(said):
							unreadable = true
							continue
						compared += 1
						worst = maxf(worst, absf(said - BootsTool.top_speed(spec)))
			_check(not unreadable,
				"the %s formula is arithmetic this suite can read: \"%s\"" % [tool.name(), clause])
			_check(compared == 27 and worst < 0.0005,
				"\"%s\" gives top_speed() for all %d specs across the declared ranges (worst gap %.4f m/s)" % [
					clause, compared, worst])

	_check(formulas == 1, "the tools state %d formula, and each one is measured above" % formulas)

	# --------------------------------------------------------------------
	# 2. The direction, measured from the function and from no sentence.
	#    This is the half the old wording got wrong: it put `footing` in the
	#    numerator, so it told the model that raising footing goes faster.
	# --------------------------------------------------------------------
	var ordinary := {"push": BootsTool.DEFAULT_PUSH, "weight": BootsTool.DEFAULT_WEIGHT, "footing": BootsTool.DEFAULT_FOOTING}
	var base := BootsTool.top_speed(ordinary)
	for move in [
		["push", BootsTool.PUSH[1], true, "more push is faster"],
		["push", BootsTool.PUSH[0], false, "less push is slower"],
		["weight", BootsTool.WEIGHT[1], false, "more weight is slower"],
		["footing", BootsTool.FOOTING[1], false, "more footing is slower"],
		["footing", BootsTool.FOOTING[0], true, "less footing is faster"],
	]:
		var spec := ordinary.duplicate()
		spec[str(move[0])] = float(move[1])
		var now := BootsTool.top_speed(spec)
		_check((now > base) == bool(move[2]),
			"%s: %s at %s gives %.2f m/s against the ordinary %.2f" % [
				str(move[3]), str(move[0]), str(move[1]), now, base])

	# The worked example the prompt states is the number the function
	# returns, rendered rather than typed (TRAPS 28).
	_check(BootsTool.new().prompt_section().contains("come to %.2f m/s" % base),
		"the boots section states the ordinary top speed as %.2f m/s" % base)

	# --------------------------------------------------------------------
	# 3. "O is more than 0 and at most 2 x R" - a relation between two
	#    fields of the same section, checked at both ends and outside.
	# --------------------------------------------------------------------
	for radius in [SectionValidator.CHICANE_RADIUS[0], 50.0, SectionValidator.CHICANE_RADIUS[1]]:
		for pair in [[0.0, false], [-1.0, false], [0.01, true], [2.0 * radius, true], [2.0 * radius + 0.5, false]]:
			var offset := float(pair[0])
			var want_ok := bool(pair[1])
			var refused := _offset_refused(radius, offset)
			_check(refused != want_ok,
				"chicane R=%.0f offset %.2f (2 x R = %.0f) is %s" % [
					radius, offset, 2.0 * radius, "accepted" if want_ok else "refused"])

	# --------------------------------------------------------------------
	# 4. "A chicane steps the track sideways by O metres and returns to its
	#    original direction." Measured, both halves, including a left one.
	# --------------------------------------------------------------------
	for radius in [15.0, 50.0, 150.0]:
		for offset in [1.0, radius, 2.0 * radius]:
			for direction in ["right", "left"]:
				var section := {"type": "chicane", "radius": radius, "offset": offset, "direction": direction}
				var pose: Array = TrackGeometry.advance(Vector3.ZERO, 0.0, section)
				var sideways: float = (pose[0] as Vector3).dot(TrackGeometry.right(0.0))
				var wanted: float = offset if direction == "right" else -offset
				_check(absf(sideways - wanted) < 0.001,
					"chicane R=%.0f O=%.0f %s steps sideways %.3f m" % [radius, offset, direction, sideways])
				_check(absf(float(pose[1])) < 1e-9,
					"chicane R=%.0f O=%.0f %s ends on its original heading" % [radius, offset, direction])

	# --------------------------------------------------------------------
	# 5. "a hairpin ... carries the track back only by its own width, twice
	#    its radius."
	# --------------------------------------------------------------------
	for radius in [SectionValidator.HAIRPIN_RADIUS[0], 40.0, SectionValidator.HAIRPIN_RADIUS[1]]:
		var pose: Array = TrackGeometry.advance(Vector3.ZERO, 0.0,
			{"type": "hairpin", "radius": radius, "angle": 180.0})
		var across: float = (pose[0] as Vector3).dot(TrackGeometry.right(0.0))
		var back: float = (pose[0] as Vector3).dot(TrackGeometry.forward(0.0))
		_check(absf(across - 2.0 * radius) < 0.001 and absf(back) < 0.001,
			"a hairpin of radius %.0f carries the track %.3f m across, twice its radius, and %.3f m on" % [
				radius, across, back])

	# --------------------------------------------------------------------
	# 6. "Corner and hairpin angles must add up to exactly +360 ... Chicanes
	#    do not count." Measured by DIFFERENCE: adding a chicane to a
	#    composition the gate accepts must not move its net turn.
	# --------------------------------------------------------------------
	var square: Array = []
	for i in 4:
		square.append({"type": "straight", "length": 200.0})
		square.append({"type": "corner", "radius": 60.0, "angle": 90.0})
	var plain: Dictionary = FeasibilityGate.check(square)
	_check(bool(plain["ok"]) and absf(float(plain["net_turn"]) - 360.0) < 1e-9,
		"four 90 degree corners add up to %+.1f and the gate accepts them" % float(plain["net_turn"]))
	for direction in ["right", "left"]:
		var with_chicane: Array = square.duplicate(true)
		with_chicane.append({"type": "chicane", "radius": 50.0, "offset": 40.0, "direction": direction})
		var after: Dictionary = FeasibilityGate.check(with_chicane)
		_check(absf(float(after["net_turn"]) - float(plain["net_turn"])) < 1e-9,
			"a %s chicane does not count: net turn stays %+.1f" % [direction, float(after["net_turn"])])

	# --------------------------------------------------------------------
	# 7. "Angles are signed: positive turns right, negative turns left."
	#    Right is +X at heading 0, which is what TrackGeometry.right() says.
	# --------------------------------------------------------------------
	for angle in [10.0, 90.0, 120.0]:
		for sign in [1.0, -1.0]:
			var pose: Array = TrackGeometry.advance(Vector3.ZERO, 0.0,
				{"type": "corner", "radius": 50.0, "angle": angle * sign})
			var sideways: float = (pose[0] as Vector3).dot(TrackGeometry.right(0.0))
			var turned_right := sideways > 0.0 and float(pose[1]) > 0.0
			_check(turned_right == (sign > 0.0),
				"a %+.0f degree corner turns %s: %+.3f m sideways, facing %+.1f" % [
					angle * sign, "right" if sign > 0.0 else "left", sideways, rad_to_deg(float(pose[1]))])

	# --------------------------------------------------------------------
	# 8. "Never give a corner, hairpin or chicane a length; it is
	#    calculated." Both halves, and for all three types rather than the
	#    one that happened to be tried (TRAPS 11).
	# --------------------------------------------------------------------
	for given in [["corner", {"radius": 50.0, "angle": 90.0}], ["hairpin", {"radius": 40.0, "angle": 180.0}],
			["chicane", {"radius": 50.0, "offset": 40.0, "direction": "right"}]]:
		var section: Dictionary = (given[1] as Dictionary).duplicate()
		section["type"] = str(given[0])
		var clean := section.duplicate()
		section["length"] = 123.0
		var checked := SectionValidator.validate({"mode": "circuit", "sections": [section]})
		var named := false
		for error in (checked["errors"] as Array):
			if str(error).contains("'length' is not a %s setting" % str(given[0])):
				named = true
		_check(named, "a %s given a length is refused, naming the field" % str(given[0]))
		_check(TrackGeometry.section_length(clean) > 0.0,
			"a %s's length is calculated: %.3f m" % [str(given[0]), TrackGeometry.section_length(clean)])

	for line in lines:
		print(line)
	print("")
	print("FORMULA failures=%d" % failures.size())
	quit(1 if failures.size() > 0 else 0)


func _offset_refused(radius: float, offset: float) -> bool:
	var checked := SectionValidator.validate({"mode": "circuit", "sections": [
		{"type": "chicane", "radius": radius, "offset": offset, "direction": "right"}]})
	for error in (checked["errors"] as Array):
		if str(error).contains("offset"):
			return true
	return false
