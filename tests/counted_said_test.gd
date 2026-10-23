extends SceneTree

# --- 042: a count and the word after it, at the doors 034's sweep never reached ---
#
# HANDOVER named the next assistant task as the audit 041 began, continued:
# for every fix in TRAPS, is the rule it produced applied everywhere it
# holds, or only where the fault was found? This is that question asked of
# TRAPS 27's rule - "a count and its noun are one fact, read from
# Readback.plural() or count_of() and never written out again" - and the
# answer is ONLY WHERE THE FAULT WAS FOUND, AND THE SWEEP THAT GUARDS IT CAN
# ONLY SEE HALF THE FAULT.
#
# 034 swept the validators and the dungeon's measurements. Measured headless
# before anything was changed, these were not in that sweep:
#
#   session summary, ONE request   "Session 'x': 1 minutes, 1 requests."
#                                  "First world after 1 seconds, ..."
#                                  "Understanding: 1 readbacks, ..."
#                                  "100% of the 1 that bear on it"
#   the farm's ZONES panel         "3   (2 orchard, 1 barn)"
#   the circuit's SECTIONS panel   "8  (4 straight, 4 corner, ...)"
#   /worlds with one world saved   "1 saved worlds: farm1"
#
# WHY THE SWEEP COULD NOT SEE IT. container_door_test looks for "1 <word>s"
# in the output. That is a count of ONE wearing a plural. A count of TWO
# wearing a SINGULAR is the same fault and the regex is blind to it by
# construction - and that is the half the farm's and the circuit's panels
# had. On a circuit it was unconditional: a closed circuit needs at least
# two straights and two turns, so those two counts can never be one, and
# every circuit Genesis has ever built read "4 straight, 4 corner". TRAPS 6
# at a correct assertion, the way 041 found it: not an assertion that cannot
# fail, but one that cannot fail for half of what it covers.
#
# WHAT THIS SUITE ASSERTS, AND WHAT IT DOES NOT (TRAPS 6, TRAPS 14)
#
# FINDING, and the assertion that cannot be satisfied by wording: for every
# counted panel whose counts are enumerable from the code, the count and the
# word after it are EXACTLY what Readback.plural() renders. Reword plural()
# and this still passes; write the agreement out by hand again, in either
# direction, and it fails. The types are read from FarmModule.ZONE_TYPES and
# SectionValidator.SECTION_TYPES, never typed in here.
#
# FINDING, two-directional and independent of the one above: the word after
# the count DIFFERS between a count of one and a count of two. A hand-written
# singular fails it and so does a hand-written plural, which is the property
# the regex lacks.
#
# FINDING: the circuit's SECTIONS panel itemises to its own total. The panel
# named four of the ten types SectionValidator accepts, so a circuit holding
# an uphill measured "8  (2 straights, 4 corners, 0 hairpins, 0 chicanes)" -
# a total of 8 over an itemisation of 6, with the two dropped pieces unnamed
# beside two printed zeros. Asserted as arithmetic, not as wording.
#
# FINDING: 034's own sweep, applied to the places it did not reach.
#
# NOT ASSERTED. Nothing here has been near a model: every count was typed by
# hand. The experiment runner's four counted sentences are in the class and
# were changed with it, and nothing in this suite reaches them - the
# experiment drives a live API and this harness has no key. Whether a save
# file can hold a single measurement is not known here either, so
# LoadCheck's line is the rule applied rather than a fault measured. And
# this covers the sentences that state a COUNT; it is not a sweep of every
# sentence in Genesis that contains a number (said_number_test is that, for
# the numbers a request carried).

var failures: Array = []
var asserted := 0
var lines: Array = []
var said: Array = []        # every sentence this suite caused to be produced


func _check(ok: bool, what: String) -> void:
	asserted += 1
	if ok:
		lines.append("PASS  " + what)
	else:
		failures.append(what)
		lines.append("FAIL  " + what)


# --- the suite's own first draft walked into the fault it is about ---
#
# "1 requests" CONTAINS "1 request", so String.contains() is blind to a count
# of one wearing a plural - which is exactly the half of this fault that
# 034's regex could see and the half the panels did not have. Measured: with
# contains(), four of the session-summary assertions PASSED against the
# pre-042 code that said "1 requests" and "1 readbacks". Every check below is
# a WHOLE-WORD one. See TRAPS 36.
func _says(text: String, phrase: String) -> bool:
	var re := RegEx.new()
	re.compile("(^|[^0-9A-Za-z_])%s([^0-9A-Za-z_]|$)" % phrase)
	return re.search(text) != null


func _remember(texts) -> void:
	for t in texts:
		said.append(str(t))


func _initialize() -> void:
	_the_farms_panel()
	_the_circuits_panel()
	_the_session_summary()
	_the_remaining_doors()
	_the_one_reading()
	_sweep()

	for line in lines:
		print(line)
	print("")
	print("COUNTED SAID %d assertions, failures=%d" % [asserted, failures.size()])
	quit(1 if failures.size() > 0 else 0)


# --- the farm's ZONES panel, at one, two and three of a kind ---
#
# The type names are FarmModule.ZONE_TYPES, which are SINGULAR words, so
# "%d %s" was right at a count of one and wrong at every other count.
func _the_farms_panel() -> void:
	var farm := FarmModule.new()
	for type in FarmModule.ZONE_TYPES:
		var side: Vector2 = FarmModule.BUILDING_SIDE if type in FarmModule.BUILDINGS else FarmModule.FIELD_SIDE
		var words := {}
		for n in [1, 2]:
			var zones: Array = []
			for i in n:
				var zone := {"type": type, "width": side.x, "depth": side.x}
				if type == "crop":
					zone["crop"] = "corn"
				zones.append(zone)
			var panel := _farm_zones(farm, zones)
			if panel == "":
				_check(false, "a farm of %s could not be built, so its panel cannot be read" % Readback.plural(n, str(type)))
				continue
			_remember([panel])
			var expected := Readback.plural(n, str(type))
			_check(_says(panel, expected),
				"the farm's ZONES panel says \"%s\" for %d of them (said: %s)" % [expected, n, panel])
			words[n] = expected.split(" ")[1]
		if words.has(1) and words.has(2):
			_check(str(words[1]) != str(words[2]),
				"one %s and two of them take DIFFERENT words in the panel (one: \"%s\", two: \"%s\")" % [
					str(type), str(words.get(1, "")), str(words.get(2, ""))])


func _farm_zones(farm: FarmModule, zones: Array) -> String:
	var v := farm.validate({"zones": zones}) as Dictionary
	if not bool(v.get("ok", false)):
		return ""
	var solved := farm.solve(v["content"]) as Dictionary
	if not bool(solved.get("ok", false)):
		return ""
	for row in farm.metric_lines(farm.measure(solved["layout"]) as Dictionary, {}):
		if str((row as Array)[0]) == "ZONES":
			return str((row as Array)[1])
	return ""


# --- the circuit's SECTIONS panel, on a real closed circuit ---
#
# Two assertions, neither about wording: every count the panel states is
# Readback.plural()'s rendering of the measurement's own count, and the
# counts the panel itemises SUM TO the total it states. The second is what
# catches a panel that names four of the ten types the validator accepts.
func _the_circuits_panel() -> void:
	for probe in [
			["four straights and four corners", [
				{"type": "straight", "length": 400}, {"type": "corner", "angle": 90, "radius": 50},
				{"type": "straight", "length": 400}, {"type": "corner", "angle": 90, "radius": 50},
				{"type": "straight", "length": 400}, {"type": "corner", "angle": 90, "radius": 50},
				{"type": "straight", "length": 400}, {"type": "corner", "angle": 90, "radius": 50}]],
			# A type the prompt withholds and the validator accepts. This is
			# the circuit whose panel accounted for 6 of its 8 pieces.
			["a circuit holding one uphill and one downhill", [
				{"type": "straight", "length": 400}, {"type": "corner", "angle": 90, "radius": 50},
				{"type": "uphill", "length": 200, "grade": 4}, {"type": "corner", "angle": 90, "radius": 50},
				{"type": "straight", "length": 400}, {"type": "corner", "angle": 90, "radius": 50},
				{"type": "downhill", "length": 200, "grade": 4}, {"type": "corner", "angle": 90, "radius": 50}]]]:
		var what := str((probe as Array)[0])
		var sections: Array = (probe as Array)[1]
		var r := RacingModule.new()
		var v := r.validate({"sections": sections}) as Dictionary
		if not bool(v.get("ok", false)):
			_check(false, "%s was refused, so its panel cannot be read: %s" % [what, str(v.get("errors", []))])
			continue
		var gate := r.pre_check(v["content"], {}) as Dictionary
		if not bool(gate.get("ok", false)):
			_check(false, "%s did not pass the gate: %s" % [what, str(gate.get("reasons", []))])
			continue
		var solved := r.solve(gate["content"]) as Dictionary
		if not bool(solved.get("ok", false)):
			_check(false, "%s did not close: %s" % [what, str(solved.get("reasons", []))])
			continue
		var metrics := r.measure(solved["layout"]) as Dictionary
		var counts: Dictionary = metrics.get("counts", {})
		var panel := ""
		for row in r.metric_lines(metrics, {}):
			if str((row as Array)[0]) == "SECTIONS":
				panel = str((row as Array)[1])
		if panel == "":
			_check(false, "%s: the panel has no SECTIONS line" % what)
			continue
		_remember([panel])
		# 046: the sentence states the section count from the BUILD REPORT,
		# counted off the built tree, so the fixture carries that count too.
		# It is the measured one here because this suite is about the plural
		# rule; tests/built_count_test.gd is where the two are made to
		# disagree on purpose.
		_remember([r.summary(metrics, {"direction": "clockwise",
			"pieces_built": metrics["section_count"],
			"section_count": metrics["section_count"], "total_length": metrics["total_length"]})])

		# Every count present is said the way the one reading says it.
		for type in SectionValidator.SECTION_TYPES:
			var n := int(counts.get(type, 0))
			if n <= 0:
				continue
			var expected := Readback.plural(n, str(type))
			_check(_says(panel, expected),
				"%s: the SECTIONS panel says \"%s\" (said: %s)" % [what, expected, panel])

		# And the itemisation adds up to the total the same line states.
		var itemised := 0
		var digits := RegEx.new()
		digits.compile("(\\d+) [a-z_]+")
		var inside := panel.substr(panel.find("(") + 1)
		for hit in digits.search_all(inside):
			itemised += int(hit.get_string(1))
		_check(itemised == int(metrics["section_count"]),
			"%s: the SECTIONS panel itemises %d of its own total of %d (said: %s)" % [
				what, itemised, int(metrics["section_count"]), panel])


# --- the session summary, over the commonest session a tester has ---
func _the_session_summary() -> void:
	var words := {}
	for n in [1, 2]:
		var records: Array = [{"type": "session_event", "time": "2026-10-08T09:00:00", "event": "session_start"}]
		for i in n:
			records.append({"time": "2026-10-08T09:00:0%d" % (i + 1), "id": "r%d" % i,
				"request": "a farm with a barn", "readback": "a farm with a 20 m barn",
				"result": "VALID", "command": "CREATE_FARM", "source": {"source": "ai"}, "metrics": {}})
			records.append({"type": "understanding", "about": "r%d" % i,
				"understanding": "CONFIRMED", "evidence": "SAID_SO", "strength": "strong"})
		records.append({"type": "session_event", "time": "2026-10-08T09:01:00", "event": "session_end"})
		var summary := SessionReport.describe("tester", SessionReport.summarise(records))
		_remember([summary])
		for noun in ["request", "readback"]:
			var expected := Readback.plural(n, noun)
			_check(_says(summary, expected),
				"a session of %d says \"%s\" (said: %s)" % [n, expected, summary.replace("\n", " | ")])
		words[n] = summary

	# The two counts that are one in a one-request session and are not nouns:
	# the duration below a minute, and the verb after "the N that bear on it".
	_check(_says(str(words[1]), Readback.plural(1, "second")),
		"a world built one second in says \"%s\" (said: %s)" % [
			Readback.plural(1, "second"), str(words[1]).replace("\n", " | ")])
	_check(_says(str(words[1]), "1 readback that bears on it"),
		"one readback bearing on a session BEARS on it (said: %s)" % str(words[1]).replace("\n", " | "))
	_check(_says(str(words[2]), "2 readbacks that bear on it"),
		"two readbacks BEAR on it (said: %s)" % str(words[2]).replace("\n", " | "))


# --- the three remaining doors in the class ---
func _the_remaining_doors() -> void:
	# /worlds, with one world saved, read from the function that writes it.
	# The suite's first draft ASSEMBLED this string itself and asserted on
	# its own output, which tests nothing: the sentence lived inline in
	# Main._list_worlds(), a Node3D no suite can instantiate. It is
	# WorldStore.saved_line() now, and this reads it.
	for n in [1, 2]:
		var names: Array = []
		for i in n:
			names.append("farm%d" % (i + 1))
		var line := WorldStore.saved_line(names)
		_remember([line])
		_check(_says(line, Readback.plural(n, "saved world")),
			"the /worlds line names %s (said: %s)" % [Readback.plural(n, "saved world"), line])

	# The feasibility gate's refusal, at a composition of one of each. The
	# minimum is two, so this is the sentence a player meets when they have
	# fewer - reachable, and it said "1 straight(s) and 1 corner(s)".
	#
	# 068: the second noun was "corner" and is now "turn", because the count
	# it labels is a count of TrackGeometry.YAW_TYPES - corners, hairpins and
	# banked corners - so a composition of one hairpin was reported as "1
	# corner". THIS ASSERTION DID NOT CATCH THAT: it types the noun in, so it
	# holds the agreement between the count and whatever noun follows it and
	# not the CHOICE of noun. It is the reason 068's first draft of that fix
	# turned this suite red, and the reason 068's HANDOVER entry had to be
	# corrected: this file HAD read the sentence, by a needle built from
	# Readback.plural() rather than by any string a grep for "composition
	# has" would find. The choice of noun is held in prompt_bounds_test,
	# where a composition of MIN_TURNS hairpins and no corner at all is
	# measured through the same door.
	var gate := FeasibilityGate.check([
		{"type": "straight", "length": 400}, {"type": "corner", "angle": 90, "radius": 50}]) as Dictionary
	_check(not bool(gate.get("ok", true)),
		"one straight and one corner cannot close a circuit")
	_remember(gate.get("reasons", []))
	var reasons := " | ".join(PackedStringArray(gate.get("reasons", [])))
	for expected in [Readback.plural(1, "straight"), Readback.plural(1, "turn")]:
		_check(_says(reasons, expected),
			"the gate's refusal says \"%s\" (said: %s)" % [expected, reasons])
	_check(not reasons.contains("(s)"),
		"the gate's refusal does not dodge the plural with \"(s)\" (said: %s)" % reasons)

	# LoadCheck's line. One measurement recorded and matching is not known to
	# be reachable, so this asserts the rule and not a fault: the noun and
	# the verb both follow the count.
	var one := LoadCheck.compare({"zone_count": 1.0}, {"zone_count": 1.0}) as Dictionary
	_remember([str(one.get("said", ""))])
	_check(_says(str(one.get("said", "")), "1 measurement matches"),
		"one measurement MATCHES (said: %s)" % str(one.get("said", "")))
	var two := LoadCheck.compare({"zone_count": 1.0, "fence_length": 10.0},
		{"zone_count": 1.0, "fence_length": 10.0}) as Dictionary
	_remember([str(two.get("said", ""))])
	_check(_says(str(two.get("said", "")), "2 measurements match"),
		"two measurements MATCH (said: %s)" % str(two.get("said", "")))


# --- the one reading itself: "is this count one", asked once ---
#
# Asserted as a round trip against agrees(), not as quoted strings. plural()
# must be a READER of that decision and not a second copy of it.
func _the_one_reading() -> void:
	for n in [0, 1, 2, 3, 11]:
		var expected := "%d %s" % [n, Readback.agrees(n, "room", "rooms")]
		_check(Readback.plural(n, "room") == expected,
			"plural(%d) reads agrees(%d): %s" % [n, n, Readback.plural(n, "room")])
		var irregular := "%d %s" % [n, Readback.agrees(n, "person", "people")]
		_check(Readback.plural(n, "person", "people") == irregular,
			"plural(%d) carries an irregular plural through agrees(): %s" % [
				n, Readback.plural(n, "person", "people")])
	_check(Readback.agrees(1, "one", "many") == "one", "agrees() says the singular at one")
	_check(Readback.agrees(0, "one", "many") == "many", "agrees() says the plural at none")
	_check(Readback.agrees(2, "one", "many") == "many", "agrees() says the plural at two")


# --- 034's sweep, applied to the places 034 did not reach ---
#
# Every sentence this suite caused to be produced, swept for a count of one
# wearing a plural. A sentence added later is covered without editing this,
# and a sentence reworded does not break it.
func _sweep() -> void:
	var one := RegEx.new()
	one.compile("\\b1 [a-z_]+s\\b")
	var caught: Array = []
	for sentence in said:
		for line in str(sentence).split("\n"):
			var hit := one.search(str(line))
			if hit != null:
				caught.append("\"%s\" in: %s" % [hit.get_string(), str(line)])
	_check(caught.is_empty(), "no sentence counts one of anything in the plural%s" % (
		"" if caught.is_empty() else " - %s" % "; ".join(PackedStringArray(caught))))
