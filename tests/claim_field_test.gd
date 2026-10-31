extends SceneTree

# --- 038: the field the prompt names is the field that does it ---
#
# HANDOVER named the next assistant task as one contradiction: the boots
# section told the model that someone who wants to "stop on a sixpence" wants
# `brake` raised, and three lines below that someone who wants "boots that
# stop on a sixpence" wants `footing` raised. The same quoted player phrase,
# two different fields.
#
# Asked of the CLASS rather than of those two sentences (TRAPS 11), the prompt
# makes exactly three claims of this shape - one per tool that has fields
# worth choosing between - and each is a claim about Genesis of a kind nothing
# had ever checked: not a bound (035 holds those), not a refusal (030), not a
# capability (028) and not a limitation (027), but an instruction that a
# NAMED FIELD is the one that does a NAMED THING, at no cost the player did
# not ask for. The sentence is the earliest claim Genesis makes, like a bound,
# and it is the only one that tells the model what to DO rather than what is
# allowed.
#
# WHY IT SURVIVED, which is the part worth keeping. The footing sentence was
# written in 010 and was true then: footing was the only field that shortened
# a stop. 013 added `brake` and MEASURED that brake does the same job for
# nothing - behaviour_test's claim 5 has asserted precisely that, green, ever
# since. So for 33 commits this repository held a measurement and a prompt
# sentence that contradicted each other, and nothing caught it, because a
# capability was asserted in the suite and a claim was made in the prompt and
# THERE WAS NO DOOR BETWEEN THEM. This suite is that door: it reads the claim
# out of the prompt and measures it, rather than measuring the capability on
# its own and hoping the sentence agrees.
#
# WHAT THIS ASSERTS, AND WHAT IT DOES NOT (TRAPS 6)
#
# FINDING. Every field a tool declares in defaults() appears in the JSON
# skeleton of that tool's own prompt section, and every key in that skeleton
# is a declared field. `brake` was described in the boots bullets and absent
# from the skeleton the model copies, so a model doing what the skeleton told
# it could not send the field the bullet told it to raise. Measured across
# ToolRegistry.tools(), it was the only such field in Genesis.
#
# FINDING. No two claims may own the same player phrase and name different
# fields - asserted by substring, because the two that did were "stop on a
# sixpence" and "boots that stop on a sixpence" and no equality test would
# have put them together.
#
# FINDING, and it is the one that measures rather than compares: a claim that
# says "and nothing else" must name a field that changes at most ONE of the
# quantities its tool can measure. Taken to the end of the range the prompt
# itself states, `brake` changes the stopping distance and not the walking
# pace; `turning` changes neither; `footing` changes BOTH, which is what made
# the old sentence false and what fails here.
#
# FINDING. The numbers the prompt states about those consequences are the
# numbers the functions produce. TRAPS 28's rule - a bound stated to the model
# is read from the code, never remembered - applied to a consequence, since a
# sentence about what a field costs is as much a claim as a sentence about
# what it is allowed to be.
#
# FINDING. Every "LOW to HIGH" bound the prompt states for a TOOL's field is a
# bound that tool's validator accepts at both ends. 035 measured this chain
# for the worlds and left the tools, on the reasoning that the tools render
# their bounds from their constants - which they do, and which says nothing
# about whether the constants are legal.
#
# FINDING (072), and it is about this file rather than about Genesis. The
# check above was written as a LOOKUP PER FIELD - find this field's bound in
# the prompt, and `continue` if the pattern does not match. A lookup that
# misses is indistinguishable from a field that has no bound, so a bound
# reworded out of the pattern's shape left its field unchecked, silently, in
# the suite that exists to hold bounds. TRAPS 65's shape. The answer is not a
# wider pattern: it is a reader that sweeps the section for EVERY range it
# states and reports the ones it cannot place. Measured before it was
# written: the three tools state ten ranges, nine are field bounds, and the
# tenth was read by nothing in tests/.
#
# FINDING (072). That tenth is BootsTool.TOP_SPEED - "It must come to 2 to 12
# metres a second" - a bound stated to the model, enforced in validate(), and
# unreachable by any loop over defaults().keys() because top speed is not a
# field. It is now checked the way the fields are, with one addition that is
# not a restatement: both ends must be REACHABLE with legal field values. A
# narrowed push or weight range can leave an end of a derived bound
# unreachable while both constants sit exactly where they were, and the
# player is then told about a bound they cannot have. Nothing was wrong -
# both ends are reachable and accepted, measured - and what changed is that
# it can now fail.
#
# FINDING (072). A numeric field that states NO bound is now a failure. Every
# numeric field in every tool states one today, so this is a pin and not a
# fix.
#
# GUARD. The claims are enumerated from AIInterpreter.assembled_prompt() and
# the tools from ToolRegistry.tools(), never written out here, so a tool added
# later, or a fourth sentence of this shape, is covered without editing this
# file - and a sentence whose field is not a field of its own tool fails
# rather than passing unexamined.
#
# GUARD (072). Which fields are numeric is read off defaults() rather than
# listed, so a field added later is covered without editing this file. The
# one hand-written list left is the table of DERIVED bounds, and its weakness
# is stated at the table: a derived bound added to a tool is not in it. That
# is held by the unaccounted-range check, which fails on any range the table
# does not claim - so a new one cannot pass unexamined, it has to be added.
# Making tools declare their derived bounds would remove the list, and is a
# change to scripts/ for one suite's benefit; it is in HANDOVER, not done.
#
# NOT ASSERTED (072): anything about the worlds' bounds, which are 035's and
# prompt_bounds_test's. This sweep runs over the three tool sections only.
# NOT ASSERTED (072): that a range written on a TEXT field's line is wrong.
# It is deliberately left unattributed so that it lands in the unaccounted
# list and has to be ruled on, because nothing in any tool enforces a bound
# on a text field. There is no such range today.
#
# NOT ASSERTED, deliberately: that any particular sentence exists, or what any
# of them say. The regex requires only the shape that carries the claim. Every
# phrase in the prompt may be rewritten, and a field that genuinely does two
# things may be described honestly - it simply must not be described as doing
# one.
#
# NOT ASSERTED: the car's claim, which is the third of the three. CarTool has
# no closed-form prediction to read - a car's stop happens in the physics - so
# "a car that stops better wants braking changed and nothing else" is measured
# in tests/physics_test.gd, by driving one. This suite checks the car sentence
# names a real field that is in the skeleton, and says so below rather than
# passing over it in silence.
#
# NOT ASSERTED: that any model obeys any of it. No model has read this prompt.
# What a model actually sends for "boots that stop on a sixpence" is the
# owner's editor session and is in HANDOVER under Next action.

var failures: Array = []
var asserted := 0
var lines: Array = []


func _check(ok: bool, what: String) -> void:
	asserted += 1
	lines.append(("PASS  " if ok else "FAIL  ") + what)
	if not ok:
		failures.append(what)


func _note(what: String) -> void:
	lines.append("      " + what)


# The keys of the JSON object that starts at `open`, nested braces and all.
func _keys_of_object_at(text: String, open: int) -> Array:
	if open < 0:
		return []
	var depth := 0
	var close := open
	while close < text.length():
		if text[close] == "{":
			depth += 1
		elif text[close] == "}":
			depth -= 1
			if depth == 0:
				break
		close += 1
	var inner := text.substr(open, close - open + 1)
	var keys: Array = []
	var re := RegEx.new()
	re.compile("\"([a-z_]+)\"\\s*:")
	for m in re.search_all(inner):
		if not m.get_string(1) in keys:
			keys.append(m.get_string(1))
	return keys


# The field names the "spec" object of a tool's skeleton offers the model.
func _spec_keys(section: String) -> Array:
	var at := section.find("\"spec\"")
	if at < 0:
		return []
	return _keys_of_object_at(section, section.find("{", at))


# The field names a world's "parameters" object offers. "style" comes out of
# the nested intent object with it, which is why `intent` is checked by
# membership below rather than by comparing the two sets.
func _param_keys(section: String) -> Array:
	var at := section.find("\"parameters\"")
	if at < 0:
		return []
	return _keys_of_object_at(section, section.find("{", at))


# "brake: 150 to 1200 newtons, ..." -> [150.0, 1200.0]. The bound AS THE
# PROMPT STATES IT, not as the constant holds it, because what is being
# measured here is the claim the model was given.
func _stated_bound(section: String, field: String) -> Array:
	var re := RegEx.new()
	re.compile("(?m)^%s: ([0-9]+(?:\\.[0-9]+)?) to ([0-9]+(?:\\.[0-9]+)?)\\b" % field)
	var m := re.search(section)
	if m == null:
		return []
	return [m.get_string(1).to_float(), m.get_string(2).to_float()]


# EVERY "N to M" the section states, with the numeric field whose bound it is
# or "" where it is not one. Read off the SECTION rather than looked up per
# field, and that is the whole difference: a lookup that misses returns
# nothing and says nothing, where a sweep standing on the statement cannot
# fail to see it. 072 found the lookup above being skipped in silence by
# `if bound.is_empty(): continue` - the shape TRAPS 65 names - and the answer
# is not a wider pattern but a reader that reports what it could not place.
#
# Attribution is to NUMERIC fields only. A range written on a text field's
# line - "nickname: 3 to 8 words" - is deliberately left unattributed so that
# it lands in the unaccounted list below and has to be ruled on, because
# nothing in any tool enforces a bound on a text field.
func _ranges_in(section: String, numeric_fields: Array) -> Array:
	var out: Array = []
	var re := RegEx.new()
	re.compile("([0-9]+(?:\\.[0-9]+)?) to ([0-9]+(?:\\.[0-9]+)?)\\b")
	for m in re.search_all(section):
		var ls := section.rfind("\n", m.get_start())
		var le := section.find("\n", m.get_start())
		if le < 0:
			le = section.length()
		var line := section.substr(ls + 1, le - ls - 1)
		var owner := ""
		for f in numeric_fields:
			if line.begins_with(str(f) + ":"):
				owner = str(f)
				break
		out.append({
			"low": m.get_string(1).to_float(),
			"high": m.get_string(2).to_float(),
			"field": owner,
			"line": line,
		})
	return out


# The declared fields whose ordinary value is a number, so the fields a stated
# bound is meaningful for. Taken from defaults() rather than listed, so a
# field added later is covered without editing this file.
func _numeric_fields(tool_mod: ToolModule) -> Array:
	var out: Array = []
	for k in tool_mod.defaults().keys():
		if typeof(tool_mod.defaults()[k]) in [TYPE_INT, TYPE_FLOAT]:
			out.append(str(k))
	return out


# A legal boots spec whose top speed is `target`, DERIVED from the constants
# rather than typed in: top speed is push / (weight x footing), so push is
# solved for at the corners of the weight and footing ranges until the push it
# needs is itself legal. Returns {} when no corner reaches it - which fails
# the check below rather than skipping it, and that failure is the point. A
# bound the prompt states that no legal combination of fields can reach is a
# bound a player is told about and cannot have.
func _boots_spec_reaching(target: float) -> Dictionary:
	for w in [BootsTool.WEIGHT[0], BootsTool.WEIGHT[1]]:
		for f in [BootsTool.FOOTING[0], BootsTool.FOOTING[1]]:
			var push: float = target * float(w) * float(f)
			if push < float(BootsTool.PUSH[0]) or push > float(BootsTool.PUSH[1]):
				continue
			var spec := {"push": push, "weight": float(w), "footing": float(f)}
			if is_equal_approx(BootsTool.top_speed(spec), target):
				return spec
	return {}


# What BootsTool can measure about a spec. Each entry is a name and a reading,
# and a field's claim is checked against every one of them except the one the
# player asked about - which is why there must be more than one for the check
# to mean anything.
func _boots_readings(spec: Dictionary, from_speed: float) -> Dictionary:
	return {
		"walking pace": BootsTool.top_speed(spec),
		"stopping distance": BootsTool.stopping_distance(spec, from_speed),
	}


func _initialize() -> void:
	var prompt := AIInterpreter.assembled_prompt()
	var tools := ToolRegistry.tools()
	_check(not tools.is_empty(), "ToolRegistry has tools to ask")

	# --- every declared field is a field the model can actually send ---

	for t in tools:
		var tool_mod: ToolModule = t
		var section := tool_mod.prompt_section()
		var skeleton := _spec_keys(section)
		var declared: Array = tool_mod.defaults().keys()
		_check(not skeleton.is_empty(), "EQUIP %s: its section carries a spec skeleton" % tool_mod.name())
		for k in declared:
			_check(str(k) in skeleton,
				"EQUIP %s: '%s' is a field and the skeleton offers it" % [tool_mod.name(), str(k)])
		for k in skeleton:
			_check(tool_mod.defaults().has(k),
				"EQUIP %s: the skeleton's '%s' is a declared field" % [tool_mod.name(), str(k)])

	# The same question of the worlds, where the answer was already yes. A
	# list the validator requires and the skeleton omits would be the dungeon
	# `doors` refusal (034) with nothing to read at all.
	for m in WorldRegistry.modules():
		var module: WorldModule = m
		var params := _param_keys(module.prompt_section())
		for e in module.lists():
			var key := str((e as Dictionary)["key"])
			_check(key in params,
				"%s: the declared list '%s' is in the skeleton" % [module.command(), key])

	# --- 104: every registered member is a member the AI has heard of ---
	#
	# 103 found this by enumeration and left it as a live entry with the
	# honest note that it was NOT MEASURED whether anything already failed on
	# it. It is measured now, and the entry's premise - "nothing would say
	# so" - was WRONG in both halves. What was true is sharper and is the
	# reason these four assertions exist rather than a fix.
	#
	# WHAT ALREADY HELD IT, DRIVEN RATHER THAN READ. Blanking LookTool's
	# prompt_section() in a throwaway copy turns six suites red; blanking
	# FarmModule's turns five. But of all those rows, exactly ONE is asked
	# off the registries about every member without naming the member:
	# prompt_numeral_test's `prompt.contains(section)`, which belongs to 073's
	# NUMERAL accounting and is not a statement about visibility at all. The
	# rest are hand-typed per member - formula_test names "the look section",
	# look_test names the look tool, prompt_bounds_test names the farm's zone
	# types one at a time - so a FOURTH member, which no such row mentions,
	# would be held by that one incidental assertion alone.
	#
	# AND THAT ASSERTION HOLDS IT BY AN ENGINE DETAIL, WHICH IS WHY IT IS NOT
	# ENOUGH. `String.contains("")` is FALSE in Godot 4.7.1 - measured with a
	# four-line probe, not assumed, because the opposite is true in several
	# languages a reader may be coming from (Python's `"" in s` is True). So
	# `prompt.contains("")` fails today, and the rule survives on a behaviour
	# nothing in this repository writes down. An engine that answered the
	# other way would turn that row green and leave the rule held by nothing,
	# in silence. TRAPS 6: a check that passes for a reason other than the one
	# it is named for.
	#
	# SO THE EMPTINESS IS ASSERTED FIRST, AND SEPARATELY. The two assertions
	# below are independent: the section must SAY SOMETHING, and its text must
	# be IN the prompt. The first does not depend on contains() at all, and it
	# is `strip_edges() != ""` rather than `!= ""` for the reason 103 found at
	# the leaf - three spaces is not a section, and `!= ""` would accept it.
	#
	# WHAT THIS ASSERTS: that every member of both registries contributes
	# text the model receives. It is read off ToolRegistry.tools() and
	# WorldRegistry.modules(), so a fourth tool or a fourth world is asked the
	# same question without this file being edited - TRAPS 11's "the class
	# includes the world that does not exist yet".
	#
	# WHAT IT DOES NOT ASSERT, said rather than discovered later: that the
	# section is CORRECT, or complete, or that it describes the fields the
	# validator actually reads. The skeleton checks above hold that for tools;
	# for a world it is held only where the world declares lists(), so a world
	# with no lists and a one-word section passes everything here. And it says
	# nothing about NpcGoals, which contributes a third section to the prompt
	# and is in neither registry.
	var contributing: Array = []
	for t in tools:
		var tool_mod: ToolModule = t
		contributing.append(["EQUIP %s" % tool_mod.name(), tool_mod.prompt_section()])
	for m in WorldRegistry.modules():
		var module: WorldModule = m
		contributing.append([module.command(), module.prompt_section()])
	# --- 109: THE BREADTH LINE UNDER THIS SECTION, POINTED AT SOMETHING THAT
	#          CAN FAIL (HANDOVER's first live entry as of 108) ---
	#
	# WHAT WAS HERE AND WHAT IT WAS WORTH. One assertion:
	# `contributing.size() == ToolRegistry.tools().size() +
	# WorldRegistry.modules().size()`, under the message "every registry member
	# is asked". Both loops above append EXACTLY ONCE PER ITERATION - no
	# `continue`, no condition, nothing between - and `tools` is
	# `ToolRegistry.tools()` taken at the top of this function and never
	# touched, so the two sides were two counts of the same two collections and
	# NO INPUT COULD SEPARATE THEM. The message was TRUE and measured nothing,
	# which is TRAPS 6's case and not TRAPS 14's.
	#
	# WHERE IT CAME FROM. 108 counted the `_check` conditions in tests/ with a
	# container read on both sides of an `==`, read two of them, and left the
	# rest as a live entry saying READ THEM. 109 read the class - every site of
	# it, by file and line, listed in docs/HANDOVER.md - and THIS IS THE ONE
	# that no input and no duplicate can make fail.
	#
	# WHAT THE OLD LINE COULD AND COULD NOT SEE, DRIVEN BEFORE IT WAS TOUCHED,
	# each injection alone in its own throwaway copy with its own config/name:
	#   - a `continue` skipping one tool: it FIRED - 132 assertions,
	#     failures=1, "every registry member is asked (5 of them)". THAT is why
	#     the count is kept below rather than deleted (TRAPS 6).
	#   - the "EQUIP " prefix dropped from the label three lines up: 134
	#     assertions, FAILURES=0. The label reaches the two messages below and
	#     nothing in tests/ reads it, so a member could be asked under a name
	#     the prompt never uses with every assertion in this file green.
	#
	# WHAT IS ASSERTED INSTEAD: the membership, BY NAME, both ways, read off
	# `ToolRegistry.names()` and `WorldRegistry.commands()` rather than off the
	# two loops above - the idiom this project already uses wherever a coverage
	# claim has to be falsifiable (controller_reach_test's _reachable_coverage,
	# refusal_reach_test's _driven_coverage, formula_test's "here" rows). A
	# skipped member now fails BY NAME, and so does a member asked under a name
	# neither registry gives it.
	# WHAT IT STILL DOES NOT ASSERT: that the TEXT beside each label is that
	# member's own prompt_section(). The pair is built in one expression per
	# loop, so a label paired with another member's text would need both loops
	# rewritten; it is not checked here and is not claimed to be.
	# AND THE COUNT IS KEPT BESIDE IT AND SAYS WHAT IT IS: membership both ways
	# does NOT imply equal size, because `contributing` is an Array and can
	# carry one label twice, so the count is the duplicate detector and that is
	# the whole of what it is now for.
	var asked: Array = []
	for c in contributing:
		asked.append(str((c as Array)[0]))
	var registered: Array = []
	for tool_name in ToolRegistry.names():
		registered.append("EQUIP %s" % str(tool_name))
	for command in WorldRegistry.commands():
		registered.append(str(command))
	for member in registered:
		_check(asked.has(str(member)),
			"%s is a registry member, so this section asks it for its prompt_section()" % str(member))
	for who_asked in asked:
		_check(registered.has(str(who_asked)),
			"'%s' is asked here under a name one of the two registries gives it" % str(who_asked))
	_check(asked.size() == registered.size(),
		"and no member is asked twice - the duplicate detector, not a breadth measurement: %d entries for %d members" % [
			asked.size(), registered.size()])
	for c in contributing:
		var who: String = (c as Array)[0]
		var text: String = (c as Array)[1]
		_check(text.strip_edges() != "",
			"%s: its prompt_section() says something" % who)
		# Guarded by the assertion above, so this cannot be satisfied by an
		# empty needle whichever way the engine answers contains("").
		if text.strip_edges() != "":
			_check(prompt.contains(text),
				"%s: the text of its section is in the prompt the model receives" % who)

	# --- every bound the prompt states for a tool, at both ends ---
	#
	# 072: this used to loop over the fields and ask the prompt for each
	# one's bound, skipping in silence when the pattern did not match - so a
	# bound reworded out of the shape the pattern reads left the field
	# unchecked and the suite green, with nothing printed. TRAPS 65's shape,
	# inside a suite that exists to hold bounds. Two things are wrong with a
	# per-field lookup and only one of them is the pattern:
	#
	#   1. a miss is indistinguishable from a field that has no bound, and
	#   2. a bound the prompt states about something that is NOT a field
	#      cannot be reached by a loop over fields at all.
	#
	# Both are answered by sweeping the section for every range it states and
	# requiring each one to be ACCOUNTED FOR, rather than asking per field and
	# accepting silence. Measured before it was written: the three tools state
	# ten ranges between them, nine are field bounds and the tenth is boots'
	# top speed, which no file in tests/ read.

	# The bounds a tool states that are not a field's. Each names the constant
	# that holds it and a way to build a spec that reaches a given value of
	# it, so the check below is the same check the fields get: the numbers are
	# read from the constant, and both ends are tried against the validator.
	#
	# WHAT THIS TABLE IS WEAK AT, said rather than discovered later: it is
	# written out by hand, so a derived bound added to a tool is not covered
	# by it. That is held by the unaccounted-range check below, which fails on
	# a range this table does not claim - so a new one cannot pass unexamined,
	# it simply has to be added here. Making tools declare their derived
	# bounds would remove the hand-written list and is a change to scripts/
	# for one suite's benefit; it is in HANDOVER rather than done here.
	var derived: Array = [{
		"tool": "boots",
		"what": "top speed",
		"bound": [float(BootsTool.TOP_SPEED[0]), float(BootsTool.TOP_SPEED[1])],
		"reach": func(target: float) -> Dictionary: return _boots_spec_reaching(target),
	}]

	for t in tools:
		var tool_mod: ToolModule = t
		var section_t := tool_mod.prompt_section()
		var numeric := _numeric_fields(tool_mod)
		var ranges := _ranges_in(section_t, numeric)

		# A numeric field with no bound stated is now a FAILURE and not a
		# skip. The model is told what every other number may be; a field
		# left out of that is a field it has to guess at.
		var attributed: Array = []
		for field in numeric:
			var bound := _stated_bound(section_t, field)
			_check(not bound.is_empty(),
				"EQUIP %s: '%s' is a number, so the prompt states its bound" % [tool_mod.name(), field])
			if bound.is_empty():
				continue
			attributed.append(field)
			# The two readers must agree, so neither can drift away from the
			# other and leave one of them reading a bound nobody states.
			var swept: Array = []
			for r in ranges:
				if str((r as Dictionary)["field"]) == field:
					swept.append(r)
			_check(swept.size() == 1,
				"EQUIP %s: '%s' states exactly one bound (%d found)" % [tool_mod.name(), field, swept.size()])
			if swept.size() == 1:
				var one: Dictionary = swept[0]
				_check(is_equal_approx(float(one["low"]), bound[0]) and is_equal_approx(float(one["high"]), bound[1]),
					"EQUIP %s: '%s' reads the same bound both ways (%s-%s and %s-%s)" % [
						tool_mod.name(), field, str(one["low"]), str(one["high"]), str(bound[0]), str(bound[1])])
			for end in bound:
				var result: Dictionary = tool_mod.validate({"tool": tool_mod.name(), "spec": {field: end}})
				_check(bool(result.get("ok", false)),
					"EQUIP %s: the stated bound %s for '%s' is accepted%s" % [
						tool_mod.name(), str(end), field,
						"" if bool(result.get("ok", false)) else " - refused: %s" % str(result.get("errors", []))])

		# Every range the section states is either a numeric field's bound or
		# one this suite has declared and checks below. An unaccounted range
		# fails: it is a number the model was given that nothing here reads.
		var mine: Array = []
		for d in derived:
			if str((d as Dictionary)["tool"]) == tool_mod.name():
				mine.append(d)
		var unaccounted: Array = []
		for r in ranges:
			if str((r as Dictionary)["field"]) != "":
				continue
			var claimed := false
			for d in mine:
				var b: Array = (d as Dictionary)["bound"]
				if is_equal_approx(float((r as Dictionary)["low"]), b[0]) and is_equal_approx(float((r as Dictionary)["high"]), b[1]):
					claimed = true
					break
			if not claimed:
				unaccounted.append("%s to %s in \"%s\"" % [
					str((r as Dictionary)["low"]), str((r as Dictionary)["high"]),
					str((r as Dictionary)["line"]).substr(0, 60)])
		_check(unaccounted.is_empty(),
			"EQUIP %s: every bound it states is read by this suite%s" % [
				tool_mod.name(),
				"" if unaccounted.is_empty() else " - not read: %s" % str(unaccounted)])
		_note("EQUIP %s: %d ranges stated, %d are field bounds, %d derived" % [
			tool_mod.name(), ranges.size(), attributed.size(), mine.size()])
		_check(ranges.size() == attributed.size() + mine.size(),
			"EQUIP %s: the %d ranges stated are the %d field bounds and the %d derived ones" % [
				tool_mod.name(), ranges.size(), attributed.size(), mine.size()])

	# The derived bounds, given the same two checks a field's bound gets: the
	# numbers are the constant's, and both ends are reachable with legal
	# fields AND accepted. The second is not a restatement of the first - a
	# narrowed field range can leave an end of a derived bound unreachable
	# while both constants stay exactly where they were.
	for d in derived:
		var entry: Dictionary = d
		var tool_mod: ToolModule = ToolRegistry.find(str(entry["tool"]))
		_check(tool_mod != null, "the derived bound '%s' names a tool that exists" % str(entry["what"]))
		if tool_mod == null:
			continue
		var b: Array = entry["bound"]
		var stated := _ranges_in(tool_mod.prompt_section(), _numeric_fields(tool_mod))
		var said := false
		for r in stated:
			if str((r as Dictionary)["field"]) != "":
				continue
			if is_equal_approx(float((r as Dictionary)["low"]), b[0]) and is_equal_approx(float((r as Dictionary)["high"]), b[1]):
				said = true
				break
		_check(said, "EQUIP %s: the prompt states the %s bound %s to %s the constant holds" % [
			str(entry["tool"]), str(entry["what"]), str(b[0]), str(b[1])])
		var reach: Callable = entry["reach"]
		for end in b:
			var spec: Dictionary = reach.call(float(end))
			_check(not spec.is_empty(),
				"EQUIP %s: %s %s is reachable with legal fields" % [
					str(entry["tool"]), str(entry["what"]), str(end)])
			if spec.is_empty():
				continue
			var result: Dictionary = tool_mod.validate({"tool": str(entry["tool"]), "spec": spec})
			_note("EQUIP %s: %s %s reached by %s" % [str(entry["tool"]), str(entry["what"]), str(end), str(spec)])
			_check(bool(result.get("ok", false)),
				"EQUIP %s: the stated %s bound %s is accepted%s" % [
					str(entry["tool"]), str(entry["what"]), str(end),
					"" if bool(result.get("ok", false)) else " - refused: %s" % str(result.get("errors", []))])

	# --- every claim that a named field is the one that does a named thing ---
	#
	# "and nothing else" is required by the pattern, because that is the part
	# being measured. A sentence that does not promise it is not making this
	# claim and is not swept up here.

	var claims: Array = []
	var re := RegEx.new()
	# Case-insensitive, and that is not a detail. Written case-SENSITIVE this
	# sweep found two of the three claims and reported all clear, because one
	# of them begins a sentence and so begins "Someone". That is TRAPS 31 - a
	# sweep is a claim about the unit it counted - arriving inside the suite
	# written to hold TRAPS 31, and prompt_bounds_test carries a comment
	# saying the same thing about "At most 8 things". A pattern that can miss
	# a member silently is worse than no sweep: it reports a clear answer to a
	# question it did not ask.
	re.compile("(?i)someone who wants (?:to )?\"([^\"]+)\" wants ([a-z_]+) (raised|lowered|changed) and nothing else")
	for m in re.search_all(prompt):
		claims.append({"phrase": m.get_string(1), "field": m.get_string(2), "verb": m.get_string(3)})
	_check(not claims.is_empty(), "the prompt makes at least one 'wants FIELD and nothing else' claim")
	_note("%d such claims in the assembled prompt" % claims.size())
	for c in claims:
		_note("\"%s\" -> '%s' %s" % [str(c["phrase"]), str(c["field"]), str(c["verb"])])

	# No two claims may own the same player phrase and answer it differently.
	# By substring, because the pair that did were three lines apart and no
	# equality test would have found them: "stop on a sixpence" and "boots
	# that stop on a sixpence".
	for a in claims:
		for b in claims:
			if a == b:
				continue
			var one := str(a["phrase"])
			var two := str(b["phrase"])
			if one.contains(two) or two.contains(one):
				_check(str(a["field"]) == str(b["field"]),
					"\"%s\" and \"%s\" are the same request and name the same field ('%s' and '%s')" % [
						one, two, str(a["field"]), str(b["field"])])

	# Each claim's field must belong to the tool whose section the claim is in,
	# and must be in that tool's skeleton. A sentence naming a field the model
	# cannot send is the fault 038 found, one door along from the skeleton
	# sweep above: that sweep asks whether every field is offered, this asks
	# whether every field the prompt INSTRUCTS the model to change is.
	for c in claims:
		var phrase := str(c["phrase"])
		var field := str(c["field"])
		var owner_name := ""
		for t in tools:
			var tool_mod: ToolModule = t
			if tool_mod.prompt_section().contains(phrase):
				owner_name = tool_mod.name()
				break
		_check(owner_name != "", "the claim \"%s\" lives in a tool's own section" % phrase)
		if owner_name == "":
			continue
		var owner: ToolModule = ToolRegistry.find(owner_name)
		_check(owner.defaults().has(field),
			"\"%s\": '%s' is a field of %s" % [phrase, field, owner_name])
		_check(field in _spec_keys(owner.prompt_section()),
			"\"%s\": '%s' is in the %s skeleton, so the model can send it" % [phrase, field, owner_name])

	# --- and nothing else, measured ---
	#
	# Only BootsTool can answer this here: it is the one tool that predicts
	# what a spec will do before anything moves. The car's claim is measured
	# by driving one, in tests/physics_test.gd.
	var boots: BootsTool = ToolRegistry.find("boots")
	var ordinary: Dictionary = boots.validate({"tool": "boots", "spec": {}})["spec"]
	var walk := BootsTool.top_speed(ordinary)
	_check(walk > 0.0, "an ordinary pair of boots walks at a measurable pace (%.2f m/s)" % walk)
	var plain := _boots_readings(ordinary, walk)

	var measured_any := false
	# 072: counted, not just "at least one". `measured_any` alone is satisfied
	# by ANY claim being measured, so a boots claim whose bound stopped being
	# readable dropped out here in silence while the other one kept the
	# assertion green - the same hole as the bound lookup above, one loop
	# along. The claims this suite is able to measure are counted first and
	# the count is asserted at the end.
	var boots_claims: Array = []
	for c in claims:
		if boots.defaults().has(str(c["field"])) and boots.prompt_section().contains(str(c["phrase"])):
			boots_claims.append(c)
	var measured: Array = []
	for c in boots_claims:
		var field := str(c["field"])
		var bound := _stated_bound(boots.prompt_section(), field)
		# A numeric field is asserted above to state a bound, so an empty one
		# here is a failure and no longer a note.
		_check(not bound.is_empty(),
			"\"%s\": '%s' states a bound, so there is an end to take it to" % [str(c["phrase"]), field])
		if bound.is_empty():
			continue
		var ends: Array = []
		match str(c["verb"]):
			"raised": ends = [bound[1]]
			"lowered": ends = [bound[0]]
			_: ends = [bound[0], bound[1]]
		for end in ends:
			var result: Dictionary = boots.validate({"tool": "boots", "spec": {field: end}})
			_check(bool(result.get("ok", false)),
				"boots '%s' at %s validates, so the claim can be measured" % [field, str(end)])
			if not bool(result.get("ok", false)):
				continue
			measured_any = true
			if not field in measured:
				measured.append(field)
			var moved := _boots_readings(result["spec"], walk)
			var changed: Array = []
			for what in moved:
				# A tenth of a percent: the arithmetic is the same arithmetic
				# either side, so anything that moves at all moved on purpose.
				if absf(float(moved[what]) - float(plain[what])) > absf(float(plain[what])) * 0.001:
					changed.append(str(what))
			_note("'%s' at %s changes: %s" % [field, str(end), "nothing" if changed.is_empty() else ", ".join(PackedStringArray(changed))])
			_check(changed.size() <= 1,
				"\"%s\" promises nothing else, and '%s' at %s changes %d of the %d things boots measure%s" % [
					str(c["phrase"]), field, str(end), changed.size(), plain.size(),
					"" if changed.size() <= 1 else " (%s)" % ", ".join(PackedStringArray(changed))])
	_check(measured_any, "at least one claim was measured rather than only read")
	_check(measured.size() == boots_claims.size(),
		"every boots claim was measured and not only read: %d of %d (%s)" % [
			measured.size(), boots_claims.size(), str(measured)])
	_note("boots claims measured: %s" % str(measured))

	# The stopping claim is a comparison, so the comparison is measured: from
	# ONE speed, which is the part the 037 reading got wrong. A stop from a
	# body's own top speed is not comparable with a stop from another's, and
	# footing lowers the speed it is measured from, which flatters it.
	var sharp: Dictionary = boots.validate({"tool": "boots", "spec": {"brake": BootsTool.BRAKE[1]}})["spec"]
	var grippy: Dictionary = boots.validate({"tool": "boots", "spec": {"footing": BootsTool.FOOTING[1]}})["spec"]
	var sharp_stop := BootsTool.stopping_distance(sharp, walk)
	var grippy_stop := BootsTool.stopping_distance(grippy, walk)
	_note("from %.2f m/s: brake at %.0f stops in %.2f m, footing at %.2f stops in %.2f m, ordinary %.2f m" % [
		walk, BootsTool.BRAKE[1], sharp_stop, BootsTool.FOOTING[1], grippy_stop, float(plain["stopping distance"])])
	_check(sharp_stop < grippy_stop,
		"from one speed the free field also stops shorter: %.2f m against %.2f m" % [sharp_stop, grippy_stop])
	_check(BootsTool.top_speed(grippy) < walk,
		"and the other one costs the walking pace: %.2f m/s against %.2f" % [BootsTool.top_speed(grippy), walk])

	# --- the consequence the prompt states is the consequence the code gives ---
	#
	# Not a wording assertion: these are the numbers, however the sentence
	# around them is phrased. A number typed by hand here is caught the way
	# 035 catches a bound typed by hand.
	var section := boots.prompt_section()
	for said in [
		"%.2f m/s rather than %.2f" % [BootsTool.top_speed(grippy), walk],
		"from %.2f m/s" % walk,
		"stops in %.2f m" % sharp_stop,
		"stops in %.2f m" % grippy_stop,
	]:
		_check(section.contains(said), "the boots section states \"%s\"" % said)

	for line in lines:
		print(line)
	print("")
	print("CLAIM FIELD %d assertions, failures=%d" % [asserted, failures.size()])
	quit(1 if failures.size() > 0 else 0)
