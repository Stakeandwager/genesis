extends SceneTree

# --- 073: which numbers in the prompt were TYPED, and what reads them ---
#
# WHERE THIS CAME FROM. 068 counted the numerals in AIInterpreter's assembled
# prompt by script - 92 of them, 41 distinct - and left the class open with a
# note that has stood in HANDOVER and in prompt_bounds_test's header ever
# since: "NOT ASSERTED: that every number in the prompt is read from the thing
# that enforces it." 068 closed four by reading the prompt line by line
# against the code. 072 closed a tenth tool range the same way. Nothing asks
# the question of the class.
#
# THE QUESTION THIS FILE ASKS, AND IT IS NOT 068's. 068 asked "is this number
# the constant's number?" of the numbers it could find. That question needs a
# reader per number and a judgement about what each one means, which is the
# table HANDOVER said would go stale. This file asks the one question behind
# all 92 and answers it from the SOURCE rather than from the sentence:
#
#   was this number TYPED into the prompt, or PRODUCED by the code?
#
# A number that arrives through a %-substitution cannot drift from the thing
# that produced it; it is the same expression the prompt is built from. A
# number TYPED into the prompt template can drift from anything, and 068's
# live fault was exactly that - the composition floors were typed out beside
# the constants that enforce them, and a prompt reading "at least 7 straights
# and at least 9 corners or hairpins" passed all 69 suites.
#
# MEASURED BEFORE THIS FILE WAS WRITTEN, and it is why the file is shaped this
# way: of the 92 numerals in the assembled prompt, 18 are typed into a
# template and 74 come from a substitution. Every one of the 18 is below, and
# all of them were already true. There is NO live fault here. What changes is
# that a NINETEENTH cannot arrive unexamined - which is the only thing that
# would have caught 068 at the commit that wrote it.
#
# WHAT IS ASSERTED
#
# FINDING. The prompt contributors are enumerated from the registries, never
# listed here (TRAPS 69: an enumeration can only see what hangs off the thing
# it enumerates, so the thing enumerated is the registry the prompt is built
# from). A world or tool added later is therefore SCANNED without this file
# being edited - and it FAILS until a row is added for it below, which is the
# point and not an oversight: its numbers have to be looked at by somebody. A
# new numeric FIELD on an existing tool needs no edit at all, because it is
# stated through a substitution; measured, as control 2 below.
#
# FINDING. Every file in scripts/ that holds a prompt template is one of those
# contributors, and every contributor holds exactly one. This is the half that
# stops the scan below being narrow in a way nothing says (TRAPS 59): a prompt
# text that arrived in a file the registries do not name, or a contributor
# that stopped using a template, fails here by name rather than being skipped.
#
# FINDING. Each template is PROVED to be the text its rendered section is
# built from, by splitting it on its format specifiers and requiring every
# literal fragment to appear in the rendered section IN ORDER. A section built
# some other way - concatenation, a second literal - cannot pass this, so the
# scan cannot quietly read the wrong text.
#
# FINDING. Every numeral typed into a template must be declared below WITH ITS
# COUNT, and the count is asserted both ways: an undeclared numeral fails
# naming the file and the line, and a declared numeral that is no longer there
# fails too. A count in an assertion is the opposite of a count in a comment
# (TRAPS 24): this one cannot go stale, because it fails the day it does.
# Keying on the count and not on the numeral alone is deliberate - a bound
# typed as "at most 3 doors" into a file where 3 is already declared as prose
# would otherwise pass.
#
# FINDING. The one typed numeral that states a BOUND - "Up to 4 steps" - is
# asserted equal to GameController.MAX_PLAN_STEPS, the constant that refuses
# the fifth step. prompt_bounds_test reads the same bound through the plan's
# declared list and its "up to N <members>" pattern; this reads the typed
# character against the constant and does not depend on the sentence at all,
# so a rewording that keeps the number cannot shake it loose.
#
# FINDING. The typed ORDINALS - the seven 1s that promise "numbered from 1" -
# are measured against the validators rather than declared: a door [1, 2] is
# accepted and [0, 1] refused, a thing "in": 1 lands in the FIRST room,
# "room": 1 in an order resolves to the first room, and the reachability walk
# starts at room 1, so a dungeon whose doors avoid room 1 is refused and the
# same graph joined to room 1 is not.
#
# FINDING. The typed ARITHMETIC - the chicane's "more than 0 and at most 2 x
# R" - is measured at both ends. formula_test measures the same sentence from
# the other side; the duplication is deliberate, because tests/ has no shared
# library and a declaration that only points at another suite is a reading of
# the class rather than the class (TRAPS 66).
#
# FINDING, and it is the only wording-keyed assertion here. The worked example
# in the orders section - "A dungeon whose rooms are called large_hall,
# room_1, room_2, room_3 has a room called room_3, so 'room 3' means room_3 -
# not the third room in the list" - is a claim about what NpcGoals.validate
# does, and nothing in tests/ had ever read it: before this file, a grep for
# large_hall found two suites - log_022_test and log_023_test - and neither is
# about this. The names are READ OUT OF THE
# PROMPT and the claim measured, both halves: the name resolves to room_3, the
# NUMBER 3 resolves to the third room, and the two are different rooms, which
# is what makes the sentence worth saying. A pattern miss here FAILS rather
# than skipping (TRAPS 69), so a reworded example is noticed instead of
# quietly dropping the assertion.
#
# WHAT IS NOT ASSERTED, said plainly
#
# NOT ASSERTED: that the 74 substituted numerals come from the RIGHT constant.
# A substitution cannot drift from its own expression, but it can be wired to
# a constant that is not the enforcer. That is prompt_bounds_test's question
# for the worlds and claim_field_test's for the tools, and between them they
# account for every range the prompt states. This file does not re-ask it.
#
# NOT ASSERTED: that the PROSE numerals mean anything. EIGHT of the eighteen
# are illustrative - "go to room 2", "to room 3", and the example's own room_1,
# room_2 and its four room_3s - and no assertion stands behind them. That half
# is a judgement and is marked as one in the table. What holds it is the count:
# a ninth cannot appear without this file being edited. The eighteen are one
# BOUND, two ARITHMETIC, seven ORDINAL and eight PROSE, counted one at a time
# off the templates rather than apportioned.
#
# NOT ASSERTED: that the model obeys any of it. No model has read this prompt.
#
# NOT A PARSER. The template is found between the first two triple-quote
# marks in the file's CODE, with comments stripped by _code_of() so a comment
# that mentions one cannot move the boundary. Nothing in the prompt text
# contains a "#" or a triple quote - measured on the assembled prompt, not
# assumed - and section 2 fails if a file holds more than one template.

var failures: Array = []
var lines: Array = []
var asserted := 0

# numeral -> [how many times it is typed, which kind it is]
#
# The kinds, and what each one costs: BOUND is asserted against its constant,
# ORDINAL against the validators, ARITHMETIC against the section validator,
# and PROSE against nothing. A file with no row here is asserted to have NO
# typed numeral at all, which is the strongest row in the table: boots, car,
# look and farm state every number they state through a substitution.
const DECLARED := {
	"ai_interpreter.gd": [["4", 1, "BOUND"], ["1", 1, "ORDINAL"], ["2", 1, "PROSE"], ["3", 1, "PROSE"]],
	"dungeon_module.gd": [["1", 4, "ORDINAL"]],
	"farm_module.gd": [],
	"racing_module.gd": [["0", 1, "ARITHMETIC"], ["2", 1, "ARITHMETIC"]],
	"boots_tool.gd": [],
	"car_tool.gd": [],
	"look_tool.gd": [],
	"npc_goals.gd": [["1", 3, "ORDINAL"], ["2", 1, "PROSE"], ["3", 4, "PROSE"]],
}

const KINDS := ["BOUND", "ORDINAL", "ARITHMETIC", "PROSE"]


func _check(ok: bool, what: String) -> void:
	asserted += 1
	lines.append(("PASS  " if ok else "FAIL  ") + what)
	if not ok:
		failures.append(what)


# The needle is built rather than typed so that this file's own source does
# not contain it: every sentence above that talks about a template would
# otherwise be a template as far as section 2 is concerned.
func _fence() -> String:
	return '"' + '"' + '"'


func _read(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	var text := file.get_as_text()
	file.close()
	return text


# The prompt template a file holds, and the line it starts on. Empty if the
# file holds none.
func _template(path: String) -> Dictionary:
	var code := _code_of(_read(path))
	var fence := _fence()
	var open_at := code.find(fence)
	if open_at < 0:
		return {}
	var start := open_at + fence.length()
	var close_at := code.find(fence, start)
	if close_at < 0:
		return {}
	var before := code.substr(0, start)
	return {
		"text": code.substr(start, close_at - start),
		"line": before.split("\n").size(),
		"count": code.count(fence),
	}


# The literal fragments of a template, in order, with its format specifiers
# taken out.
func _fragments(template: String) -> Array:
	var spec := RegEx.create_from_string("%%|%[-+# 0]*[0-9]*(?:\\.[0-9]+)?[a-zA-Z]")
	var out: Array = []
	var at := 0
	for m in spec.search_all(template):
		var piece := template.substr(at, m.get_start() - at)
		if piece.strip_edges() != "":
			out.append(piece)
		at = m.get_end()
	var last := template.substr(at)
	if last.strip_edges() != "":
		out.append(last)
	return out


# Every numeral typed into a template, as numeral -> count, with the format
# specifiers removed FIRST so that the 0 in "%.0f" is not read as a number the
# prompt states.
func _typed(template: String) -> Dictionary:
	var spec := RegEx.create_from_string("%%|%[-+# 0]*[0-9]*(?:\\.[0-9]+)?[a-zA-Z]")
	var bare := spec.sub(template, "\u0001", true)
	var number := RegEx.create_from_string("[0-9]+(?:\\.[0-9]+)?")
	var out := {}
	for m in number.search_all(bare):
		var found := m.get_string()
		out[found] = int(out.get(found, 0)) + 1
	return out


# Which line of a template a numeral is typed on, for the failure message.
func _where(template: String, numeral: String) -> String:
	var spec := RegEx.create_from_string("%%|%[-+# 0]*[0-9]*(?:\\.[0-9]+)?[a-zA-Z]")
	var number := RegEx.create_from_string("[0-9]+(?:\\.[0-9]+)?")
	var at := 0
	for raw in template.split("\n"):
		at += 1
		var bare := spec.sub(str(raw), "\u0001", true)
		for m in number.search_all(bare):
			if m.get_string() == numeral:
				return "line %d of the template" % at
	return "nowhere the line scan can see"


func _numerals_in(text: String) -> int:
	return RegEx.create_from_string("[0-9]+(?:\\.[0-9]+)?").search_all(text).size()


func _initialize() -> void:
	print("--- 073: the numbers typed into the prompt, and what reads them ---")

	# --- 1. the contributors, enumerated from the thing the prompt is built
	#        from, and the whole prompt accounted for ---
	var contributors: Array = []
	for m in WorldRegistry.modules():
		var module: WorldModule = m
		contributors.append([module.get_script().resource_path, module.prompt_section()])
	for t in ToolRegistry.tools():
		var tool_mod: ToolModule = t
		contributors.append([tool_mod.get_script().resource_path, tool_mod.prompt_section()])
	# The two that are not in a registry: the constant the prompt starts with
	# and the orders section. Their paths are read off the global class list
	# rather than typed, so a renamed file fails here instead of quietly
	# reading nothing.
	var by_class := {}
	for e in ProjectSettings.get_global_class_list():
		var entry: Dictionary = e
		by_class[str(entry.get("class", ""))] = str(entry.get("path", ""))
	_check(by_class.has("AIInterpreter") and by_class.has("NpcGoals"),
		"the two contributors outside the registries are on the global class list")
	contributors.append([str(by_class.get("AIInterpreter", "")), AIInterpreter.SYSTEM_PROMPT])
	contributors.append([str(by_class.get("NpcGoals", "")), NpcGoals.prompt_section()])

	_check(contributors.size() == 8,
		"%d files contribute text to the prompt" % contributors.size())

	var prompt := AIInterpreter.assembled_prompt()
	var in_sections := 0
	for c in contributors:
		var path: String = (c as Array)[0]
		var section: String = (c as Array)[1]
		var name := path.get_file()
		_check(prompt.contains(section), "%s's section is in the assembled prompt" % name)
		in_sections += _numerals_in(section)
	# Nothing escapes the accounting: a numeral anywhere in the assembled
	# prompt that is not inside one of the sections - in a registry's joining
	# text, or in one of the three headings - fails here.
	_check(_numerals_in(prompt) == in_sections,
		"all %d numerals in the assembled prompt are inside the eight sections (%d counted there)" % [
			_numerals_in(prompt), in_sections])
	# And the prompt text holds neither of the two characters the template
	# scan depends on, so stripping comments and fencing on a triple quote
	# cannot cut a prompt short.
	_check(not prompt.contains("#"), "no prompt text contains a comment mark")
	_check(not prompt.contains(_fence()), "no prompt text contains a template fence")

	# --- 2. every prompt template in scripts/ belongs to a contributor ---
	var paths := {}
	for c in contributors:
		paths[str((c as Array)[0])] = true
	var strays: Array = []
	var dir := DirAccess.open("res://scripts")
	_check(dir != null, "scripts/ can be read")
	if dir != null:
		for file_name in dir.get_files():
			var name := str(file_name)
			if not name.ends_with(".gd"):
				continue
			var path := "res://scripts/" + name
			if _code_of(_read(path)).contains(_fence()) and not paths.has(path):
				strays.append(name)
	_check(strays.is_empty(),
		"every prompt template in scripts/ is in a file the registries name (%s)" % str(strays))

	# --- 3. each template is the text its section is built from, and each
	#        file holds exactly one ---
	var templates := {}
	for c in contributors:
		var path: String = (c as Array)[0]
		var section: String = (c as Array)[1]
		var name := path.get_file()
		var found := _template(path)
		_check(not found.is_empty(), "%s holds a prompt template" % name)
		if found.is_empty():
			continue
		_check(int(found["count"]) == 2,
			"%s holds exactly one template (%d fence marks in its code)" % [name, int(found["count"])])
		var template := str(found["text"])
		templates[name] = template
		# Every literal fragment of the template, in order, in the rendered
		# section. This is what proves the template is the right text.
		var at := 0
		var lost: Array = []
		for fragment in _fragments(template):
			var seen := section.find(str(fragment), at)
			if seen < 0:
				lost.append(str(fragment).strip_edges().substr(0, 40))
			else:
				at = seen + str(fragment).length()
		_check(lost.is_empty(),
			"%s's section is built from that template, fragment for fragment in order (%s)" % [
				name, str(lost)])

	# --- 4. every typed numeral is declared, and every declaration is live ---
	var kinds_used := {}
	for name in templates:
		var template: String = templates[name]
		var typed := _typed(template)
		_check(DECLARED.has(name), "%s has a row in the table" % name)
		var declared := {}
		for row in (DECLARED.get(name, []) as Array):
			var r: Array = row
			declared[str(r[0])] = r
			kinds_used[str(r[2])] = true
		for numeral in typed:
			var how_many := int(typed[numeral])
			if not declared.has(numeral):
				_check(false, "%s: the numeral %s is typed into the prompt %d time(s) at %s and is not declared - a number the model is told that nothing here accounts for" % [
					name, numeral, how_many, _where(template, str(numeral))])
				continue
			var expected := int((declared[numeral] as Array)[1])
			_check(how_many == expected,
				"%s: the numeral %s is typed %d time(s) and %d are declared%s" % [
					name, numeral, how_many, expected,
					"" if how_many == expected
					else (" - one of them is at %s and is not accounted for" % _where(template, str(numeral))
						if how_many > expected
						else " - the row here is out of date and should be struck, not relaxed")])
		for numeral in declared:
			_check(typed.has(numeral),
				"%s: the declared numeral %s is still typed into the prompt" % [name, numeral])
	for kind in KINDS:
		_check(kinds_used.has(kind),
			"the kind %s has a live subject in the table" % kind)
	for kind in kinds_used:
		_check(KINDS.has(str(kind)), "the kind %s is one this file knows" % str(kind))

	# --- 5. BOUND: the typed 4 is the constant that refuses the fifth step ---
	var plan_template: String = str(templates.get("ai_interpreter.gd", ""))
	_check(_typed(plan_template).has(str(GameController.MAX_PLAN_STEPS)),
		"the plan bound typed into the prompt is MAX_PLAN_STEPS (%d)" % GameController.MAX_PLAN_STEPS)
	_check(int(GameController.plan_list()["high"]) == GameController.MAX_PLAN_STEPS,
		"and the plan's declared list carries the same number")

	# --- 6. ORDINAL: "numbered from 1", measured at the four doors that
	#        promise it ---
	var dungeon := DungeonModule.new()
	var two := [{"name": "a", "width": 8.0, "depth": 8.0}, {"name": "b", "width": 8.0, "depth": 8.0}]
	var joined: Dictionary = dungeon.validate({"rooms": two, "doors": [[1, 2]]})
	_check(bool(joined.get("ok", false)), "a door [1, 2] joins the first two rooms")
	var from_zero: Dictionary = dungeon.validate({"rooms": two, "doors": [[0, 1]]})
	_check(not bool(from_zero.get("ok", true)), "a door [0, 1] is refused: there is no room 0")

	var with_thing: Dictionary = dungeon.validate({
		"rooms": two, "doors": [[1, 2]],
		"things": [{"name": "red_key", "in": 1}]})
	_check(bool(with_thing.get("ok", false)), "a thing in room 1 is accepted")
	if bool(with_thing.get("ok", false)):
		var kept: Array = (with_thing["content"] as Dictionary)["things"]
		_check(int((kept[0] as Dictionary)["in"]) == 0,
			"and room 1 is the FIRST room, not the second")
	var thing_zero: Dictionary = dungeon.validate({
		"rooms": two, "doors": [[1, 2]],
		"things": [{"name": "red_key", "in": 0}]})
	_check(not bool(thing_zero.get("ok", true)), "a thing in room 0 is refused")

	var order: Dictionary = NpcGoals.validate({"goal": "go_to", "room": 1}, two)
	_check(bool(order.get("ok", false)) and int((order["goal"] as Dictionary)["room"]) == 0,
		"an order to room 1 is an order to the first room")

	# The reachability walk starts at room 1, which is what "every room must be
	# reachable from room 1" means. Four rooms, three doors - the door count
	# floor is rooms - 1 - joined into a triangle that leaves room 1 out.
	var four: Array = []
	for n in 4:
		four.append({"name": "r%d" % (n + 1), "width": 8.0, "depth": 8.0})
	var away: Dictionary = dungeon.validate({"rooms": four, "doors": [[2, 3], [3, 4], [2, 4]]})
	_check(bool(away.get("ok", false)), "a dungeon whose doors avoid room 1 is schema-valid")
	if bool(away.get("ok", false)):
		var sealed: Dictionary = dungeon.pre_check(away["content"], {})
		_check(not bool(sealed.get("ok", true)) and str(sealed.get("category", "")) == "FAILED_UNREACHABLE",
			"and it is refused, because the walk starts at room 1")
	var chained: Dictionary = dungeon.validate({"rooms": four, "doors": [[1, 2], [2, 3], [3, 4]]})
	_check(bool(chained.get("ok", false)), "the same four rooms joined to room 1 are schema-valid")
	if bool(chained.get("ok", false)):
		var walked: Dictionary = dungeon.pre_check(chained["content"], {})
		_check(bool(walked.get("ok", false)),
			"and are accepted, so the refusal above is about room 1 and not about the count")

	# --- 7. ARITHMETIC: "more than 0 and at most 2 x R" ---
	var radius := 50.0
	_check(not _offset_refused(radius, 2.0 * radius),
		"a chicane offset at twice the radius (%.0f m) is accepted" % (2.0 * radius))
	_check(_offset_refused(radius, 2.0 * radius + 1.0),
		"and one metre past twice the radius is refused")
	_check(_offset_refused(radius, 0.0),
		"an offset of 0 is refused: it must be more than 0")

	# --- 8. the worked example in the orders section, read off the prompt ---
	var orders: String = str(templates.get("npc_goals.gd", ""))
	var example := RegEx.create_from_string("called ([a-z_0-9]+(?:, [a-z_0-9]+)+) has a room called ([a-z_0-9]+)")
	var hit := example.search(orders)
	_check(hit != null,
		"the orders section states a worked example of a room named like a number")
	if hit != null:
		var named: Array = []
		for raw in hit.get_string(1).split(", "):
			named.append({"name": str(raw).strip_edges(), "width": 8.0, "depth": 8.0})
		var wanted := hit.get_string(2)
		var index := -1
		for i in named.size():
			if str((named[i] as Dictionary)["name"]) == wanted:
				index = i
		_check(index >= 0, "the example's own room '%s' is one of the rooms it lists" % wanted)
		var by_name: Dictionary = NpcGoals.validate({"goal": "go_to", "room": wanted}, named)
		_check(bool(by_name.get("ok", false)) and int((by_name["goal"] as Dictionary)["room"]) == index,
			"'%s' as a name means the room called %s (room %d of %d)" % [
				wanted, wanted, index + 1, named.size()])
		# The player's own words, with the space the prompt quotes them with.
		var spoken := wanted.replace("_", " ")
		var by_words: Dictionary = NpcGoals.validate({"goal": "go_to", "room": spoken}, named)
		_check(bool(by_words.get("ok", false)) and int((by_words["goal"] as Dictionary)["room"]) == index,
			"and so does \"%s\", the way a player says it" % spoken)
		# And the other half of the sentence: the NUMBER is the position, and
		# here that is a different room, which is what makes it worth saying.
		var digits := RegEx.create_from_string("[0-9]+").search(wanted)
		_check(digits != null, "the example's room name carries a number")
		if digits != null:
			var position := int(digits.get_string())
			var by_number: Dictionary = NpcGoals.validate({"goal": "go_to", "room": position}, named)
			_check(bool(by_number.get("ok", false)) and int((by_number["goal"] as Dictionary)["room"]) == position - 1,
				"the number %d means room %d counting from 1, which is '%s'" % [
					position, position, str((named[position - 1] as Dictionary)["name"])])
			_check(position - 1 != index,
				"and that is NOT the room called %s, which is what the example is for" % wanted)

	for line in lines:
		print(line)
	print("")
	print("PROMPT NUMERAL %d assertions, failures=%d" % [asserted, failures.size()])
	quit(1 if failures.size() > 0 else 0)


# Does the section validator complain about this chicane's offset? Built the
# way formula_test builds it: the complaint is looked for by name, so the
# other errors a two-section track collects do not answer for it.
func _offset_refused(radius: float, offset: float) -> bool:
	var check := SectionValidator.validate({"sections": [
		{"type": "straight", "length": 100.0},
		{"type": "chicane", "radius": radius, "offset": offset, "direction": "right"}]})
	for error in (check.get("errors", []) as Array):
		if str(error).contains("offset"):
			return true
	return false


# The code of a .gd source, with comments taken out. Byte-identical to the
# copy in the nine other suites that read this project's source, which
# source_scan_test holds (TRAPS 64): a scan a comment can answer is not a
# scan, and this file's own paragraphs above talk about every needle it looks
# for.
static func _code_of(source: String) -> String:
	var out := ""
	for raw in source.split("\n"):
		var line := str(raw)
		if line.strip_edges().begins_with("#"):
			out += "\n"
			continue
		var hash_at := line.find("#")
		out += (line if hash_at < 0 else line.substr(0, hash_at)) + "\n"
	return out
