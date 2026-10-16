extends SceneTree

# --- 034: does a refusal at a CONTAINER door name a legal value? ---
#
# 030 made every FIELD refusal name its limits through all three of its
# doors - out of range, not a number, missing (TRAPS 21). The CONTAINERS
# those fields live in were never asked, and all six lists plus all three
# tool specs answered with four words:
#
#   "rooms must be a list"      "doors must be a list"
#   "zones must be a list"      "sections must be a list"
#   "things must be a list"     "a plan needs a list of steps"
#   "spec must be an object"  (x3, three lines above a refusal for an
#                              unknown field that lists every legal one)
#
# No count, no shape, no example, next to field refusals that say "and it
# must be 5 to 60 m". `doors` is the sharp one: required, with no default,
# so a dungeon described with no doors at all was refused with four words
# naming nothing a player could act on.
#
# WHAT THIS ASSERTS, AND WHAT IT DOES NOT (TRAPS 6)
#
# FINDING. Every container door refuses with a sentence that names its
# bounds and carries an EXAMPLE THAT PARSES. All of it fails against the
# pre-034 messages.
#
# FINDING. The example is not merely present but legal: a request assembled
# out of every declared sample is handed back to the validator that declared
# it and must be ACCEPTED. That is the assertion that cannot be satisfied by
# wording. An example drifting out of its bounds, a bound moved in one place
# and not the other, or a world that grows a required list and forgets to
# declare it all fail here, because the assembled request stops validating.
#
# FINDING. An example may not advertise something the player is not offered.
# 034's own first attempt offered MODIFY_TRACK - a stub that builds nothing
# and appears nowhere in the prompt - as what a plan step looks like, which
# is TRAPS 21's closing warning arriving one door up. Every command named in
# an example must appear in AIInterpreter.assembled_prompt(), and a circuit's
# example type must come from OFFERED_TYPES and never from SECTION_TYPES
# (TRAPS 19's wall).
#
# GUARD. The lists are enumerated from WorldRegistry.modules() and each
# module's own lists(), never written out here, so a world added later is
# covered without editing this file - and a world that declares nothing is a
# FAILURE and never a skip.
#
# NOT ASSERTED, deliberately: the wording. Nothing here matches a sentence.
# What is checked is that the numbers the validator enforces appear, that
# the example parses to the value the module declared, and that the value is
# accepted. Every sentence in Genesis can be rewritten without touching this
# file - which is the mistake plan_said_test made, asserting the literal
# "<key> must be a list" and going vacuous the moment it changed.
#
# NOT ASSERTED: that the examples are the BEST ones to show a player. That
# is a judgement and it is in HANDOVER under the owner's next session.

var failures: Array = []
var lines: Array = []
# Every sentence this suite caused to be produced, for the plural sweep.
var said: Array = []


func _check(ok: bool, what: String) -> void:
	lines.append(("PASS  " if ok else "FAIL  ") + what)
	if not ok:
		failures.append(what)


func _remember(errors) -> Array:
	var out: Array = []
	for e in (errors as Array):
		out.append(str(e))
		said.append(str(e))
	return out


# The example a refusal carries, parsed back out of it. A sentence with no
# parseable example returns null, which is a failure everywhere it is used.
func _example_in(sentence: String) -> Variant:
	var mark := ", for example "
	var at := sentence.find(mark)
	if at < 0:
		return null
	return JSON.parse_string(sentence.substr(at + mark.length()))


# The refusal out of a set that is about this key: the one carrying an
# example equal to the declared sample. Found by VALUE and not by wording,
# so renaming the sentence cannot make this suite pass by accident.
func _door_sentence(errors: Array, entry: Dictionary) -> String:
	var sample: Array = entry.get("sample", [])
	if sample.is_empty():
		return ""
	for sentence in errors:
		var shown = _example_in(str(sentence))
		if shown != null and typeof(shown) == TYPE_ARRAY and (shown as Array).size() == 1:
			# Compared through Readback.as_json on both sides, because the
			# sample holds 12 and JSON.parse_string hands back 12.0 for the
			# same number. What is being asserted is that the example IS the
			# declared member, not how a parser spells it.
			if Readback.as_json((shown as Array)[0]) == Readback.as_json(sample[0]):
				return str(sentence)
	return ""


# A complete request for this world, out of every list it declares.
func _full_request(module: WorldModule) -> Dictionary:
	var parameters := {}
	for entry in module.lists():
		parameters[str((entry as Dictionary)["key"])] = (entry as Dictionary).get("sample", [])
	return parameters


func _initialize() -> void:
	var prompt := AIInterpreter.assembled_prompt()
	var modules := WorldRegistry.modules()
	_check(not modules.is_empty(), "WorldRegistry has worlds to ask")

	for m in modules:
		var module: WorldModule = m
		var where := module.command()
		var declared: Array = module.lists()

		# A world that declares nothing fails. It cannot be skipped: a world
		# with an undeclared list is the fault, not an exemption from it.
		_check(not declared.is_empty(), "%s declares the lists a request may carry" % where)

		# The assembled request must be ACCEPTED. This is the assertion that
		# catches a stale example, a moved bound and an undeclared list.
		var full := _full_request(module)
		var whole: Dictionary = module.validate(full)
		var whole_errors := _remember(whole.get("errors", []))
		_check(bool(whole.get("ok", false)),
			"%s accepts a request built from its own declared samples%s" % [
				where, "" if whole_errors.is_empty() else " (said: %s)" % ", ".join(whole_errors)])

		for e in declared:
			var entry: Dictionary = e
			var key := str(entry["key"])
			var low := int(entry.get("low", 0))
			var high := int(entry.get("high", 0))
			var sample: Array = entry.get("sample", [])
			var label := "%s '%s'" % [where, key]

			_check(not sample.is_empty(), "%s declares a sample member" % label)

			# --- the door: a value that is not a list at all ---
			var wrong := _full_request(module)
			wrong[key] = 7
			var refused: Dictionary = module.validate(wrong)
			var errors := _remember(refused.get("errors", []))
			_check(not bool(refused.get("ok", false)), "%s set to a number is refused" % label)

			var sentence := _door_sentence(errors, entry)
			_check(sentence != "", "%s: the refusal shows the example the module declares" % label)
			if sentence != "":
				_check(sentence.contains(str(high)),
					"%s: the refusal names its upper limit (%d)" % [label, high])
				if low > 0:
					_check(sentence.contains(str(low)),
						"%s: the refusal names its lower limit (%d)" % [label, low])

			# --- the door: the key left out entirely ---
			var without := _full_request(module)
			without.erase(key)
			var missing: Dictionary = module.validate(without)
			var missing_errors := _remember(missing.get("errors", []))
			if bool(entry.get("required", false)):
				_check(not bool(missing.get("ok", false)), "%s left out is refused" % label)
				_check(_door_sentence(missing_errors, entry) != "",
					"%s left out: the refusal shows an example" % label)
			else:
				# An optional list left out must not be complained about at
				# all. `things` is the only one, and saying so here is what
				# makes `doors` being required a measured fact rather than
				# an assumption about it.
				_check(bool(missing.get("ok", false)),
					"%s is optional, so leaving it out builds%s" % [
						label, "" if missing_errors.is_empty() else " (said: %s)" % ", ".join(missing_errors)])

			# --- a member of the list, refused on its own ---
			var bad_member := _full_request(module)
			var members: Array = []
			for item in sample:
				members.append(item)
			if not members.is_empty():
				members[0] = "not a member at all"
				bad_member[key] = members
				var member_refused: Dictionary = module.validate(bad_member)
				var member_errors := _remember(member_refused.get("errors", []))
				_check(not bool(member_refused.get("ok", false)),
					"%s: a member that is a string is refused" % label)
				var shown := false
				for s in member_errors:
					var got = _example_in(str(s))
					if got != null and Readback.as_json(got) == Readback.as_json(sample[0]):
						shown = true
				_check(shown, "%s: a refused member is shown what a member looks like" % label)

			# --- an example may not advertise what the player is not offered ---
			for member in sample:
				if typeof(member) == TYPE_DICTIONARY:
					var named := str((member as Dictionary).get("command", ""))
					if named != "":
						_check(prompt.contains(named),
							"%s: the example names '%s', which the prompt tells the model about" % [label, named])

	# --- TRAPS 19's wall, at the door 034 opened ---
	# SectionValidator accepts ten types and the player is offered four. The
	# refusal that names a legal value is the sentence a withheld type would
	# leak out of, so the example's type is read from OFFERED_TYPES. This
	# fails the moment it is read from SECTION_TYPES instead.
	var circuit := SectionValidator.list_entry()
	for member in (circuit.get("sample", []) as Array):
		var type_name := str((member as Dictionary).get("type", ""))
		_check(SectionValidator.OFFERED_TYPES.has(type_name),
			"the circuit's example is a '%s', a type the player is offered" % type_name)

	# --- the sixth list door, which is not in a world module ---
	var plan := GameController.plan_list()
	var plan_sentence := Readback.list_error(plan)
	said.append(plan_sentence)
	_check(plan_sentence.contains(str(int(plan["high"]))),
		"the plan's list door names how many steps a plan may have")
	var plan_example = _example_in(plan_sentence)
	_check(plan_example != null, "the plan's list door carries an example that parses")

	var step: Dictionary = GameController.plan_example_step()
	var step_command := str(step.get("command", ""))
	_check(step_command != "PLAN", "the example step is not another plan")
	_check(CommandParser.allowed_commands().has(step_command),
		"the example step's command is one the whitelist admits")
	_check(prompt.contains(step_command),
		"the example step's command is one the prompt tells the model about")
	var step_world := WorldRegistry.find(step_command)
	_check(step_world != null, "the example step builds a world")
	if step_world != null:
		var step_check: Dictionary = step_world.validate(step.get("parameters", {}))
		var step_errors := _remember(step_check.get("errors", []))
		_check(bool(step_check.get("ok", false)),
			"the example step is a request that validates%s" % (
				"" if step_errors.is_empty() else " (said: %s)" % ", ".join(step_errors)))

	# --- the tools: the same door in its object flavour ---
	for t in ToolRegistry.tools():
		var tool_module: ToolModule = t
		var spec_refused: Dictionary = tool_module.validate({"spec": 5})
		var spec_errors := _remember(spec_refused.get("errors", []))
		_check(not bool(spec_refused.get("ok", false)),
			"%s: a spec that is not an object is refused" % tool_module.name())
		var joined := " ".join(PackedStringArray(spec_errors))
		# Every field the tool actually has must be named. Read from
		# defaults(), which is the one place that knows, so a field added to
		# a tool is covered here without editing this suite.
		for field in tool_module.defaults().keys():
			_check(joined.contains(str(field)),
				"%s: the spec door names '%s', a field a spec may hold" % [
					tool_module.name(), str(field)])

	_plurals()

	for line in lines:
		print(line)
	print("")
	print("CONTAINER DOOR failures=%d" % failures.size())
	quit(1 if failures.size() > 0 else 0)


# --- the count of one, which nothing had ever asked for ---
#
# "2 rooms need at least 1 doors to all be reachable", "this dungeon has 1
# rooms", "deepest room 1 doors in". A person writing a test for a count
# writes two, so the plural was written by hand and nothing read it back.
#
# Asserted as a fact about the OUTPUT rather than about any one sentence:
# every string this suite caused to be produced is swept for a count of one
# followed by a plural. A sentence added later is covered for free, and a
# sentence reworded is not broken by it - which is the opposite of quoting
# the wording.
func _plurals() -> void:
	var dungeon := DungeonModule.new()

	# The two refusals that were wrong, and a third to be sure the sweep has
	# something to look at.
	_remember((dungeon.validate({
		"rooms": [{"name": "a", "width": 12, "depth": 12}, {"name": "b", "width": 12, "depth": 12}],
		"doors": []}) as Dictionary).get("errors", []))
	_remember((NpcGoals.validate({"goal": "go_to", "room": 9},
		[{"name": "hall", "width": 12.0, "depth": 12.0}]) as Dictionary).get("errors", []))

	# The lines a player reads after a dungeon is built, at every count of
	# one there is. These are measurements rather than refusals, and the
	# plural rule is a fact about the word either way.
	#
	# The counts here are the smallest a REAL dungeon can have, not the
	# smallest the format allows: MIN_ROOMS is 2, so a one-room dungeon is
	# not a sentence Genesis can produce and asserting about one would be
	# guarding an assumption rather than checking a fact (TRAPS 6). Two
	# rooms joined by one door is reachable, and it is where every count
	# that CAN be one is one.
	var metrics := {
		"room_count": 2, "door_count": 1, "loops": 1, "deepest": 1,
		"width": 20.0, "depth": 20.0, "pitch": 18.0, "floor_area": 144.0,
		"corridor_length": 12.0, "corridor_area": 72.0,
		"largest_room": "hall", "largest_room_area": 144.0,
		"deepest_room": "vault", "dead_ends": 1, "walk_reached": 1,
	}
	# 046: the summary states the room count from the BUILD REPORT, read off
	# the tree, and never from the measurement beside it - so the fixture has
	# to say how many rooms were built. Two, the same as the layout here
	# measures: this suite is about the plural rule and not about a count
	# that disagrees, and tests/built_count_test.gd is where the two are
	# made to disagree on purpose.
	said.append(dungeon.summary(metrics, {"pieces_built": 2}))
	for row in dungeon.metric_lines(metrics, {"placement": {
			"placed": 1, "room_count": 2, "furthest_ring": 1}}):
		said.append(str((row as Array)[1]))

	var one := RegEx.new()
	one.compile("\\b1 [a-z]+s\\b")
	var caught: Array = []
	for sentence in said:
		var hit := one.search(str(sentence))
		if hit != null:
			caught.append("\"%s\" in: %s" % [hit.get_string(), str(sentence)])
	_check(caught.is_empty(), "no sentence counts one of anything in the plural%s" % (
		"" if caught.is_empty() else " - %s" % "; ".join(PackedStringArray(caught))))
