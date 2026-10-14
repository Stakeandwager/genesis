extends SceneTree

# 029 - what a validator does with a value that is not a number.
#
# WHY THIS SUITE EXISTS
#
# Every number in a request arrives through JSON.parse. JSON has null, objects
# and lists, and a model writes all three where a number belongs: null for a
# field it has nothing to say about, {} or [20, 20] for one whose shape it has
# misunderstood. None of that is exotic input - it is ordinary JSON that the
# parser accepts and hands on unchanged, and CommandParser passes "parameters"
# through without looking inside it.
#
# GDScript's float() has no constructor for those three. The call does not
# return a wrong number. It THROWS, and a throw inside a function abandons the
# rest of that function and leaves the caller holding a default. So the fault
# never looked like a bad measurement. Before this suite:
#
#   DungeonModule.validate, room width null/{}/[]  ->  ok=TRUE, errors=[]
#                                                      and a room 0 m across
#   DungeonModule.validate, a door pair holding {}  ->  {} - no "ok" key at
#                                                      all, and
#                                                      game_controller reads
#                                                      check["ok"] directly
#   DungeonModule / FarmModule / RacingModule
#     .readback on any of the three           ->      "" (the empty string)
#
# The first is this project's central claim failing: a validator reporting a
# spec sound when it had not read it. The third is trap 8 from the other end -
# a readback is the one place a player can catch Genesis building the wrong
# thing correctly, and it said nothing at all.
#
# THIRTY-FIVE SUITES PASSED BEFORE THE FIX AND THIRTY-FIVE PASSED AFTER.
# Every one of them hands its validators numbers, because the person writing
# a test for a width writes a width. The question nobody had asked of any
# field in Genesis was "what if this is not a number", and the answer differed
# per file: SectionValidator and FarmModule check typeof() and refuse,
# DungeonModule._side did not check at all. That is trap 18's shape one layer
# down - a convention that four files out of five picked up - and the only way
# to see it is to probe the whole class at once, which is what this does.
#
# WHAT IS ASSERTED, AND WHY IT IS A FACT AND NOT A FORM OF WORDS
#
#   1. For EVERY numeric field of EVERY validator, each of six values that are
#      not numbers is refused: the result has an "ok" key, ok is false, and
#      the errors name the field. Not one field that was found wanting
#      (trap 11) - the field lists are read out of the code below, so a field
#      added later is probed without this file being touched.
#   2. No readback is empty for any of them.
#   3. No readback states a measurement the request did not contain. This is
#      checked by pulling every digit out of the sentence and requiring it to
#      have been in the request - which catches "a 0 by 10 m barn" and "a 0 m
#      straight" without testing a single word of the wording.
#   4. The valid case is unchanged: a well-formed request still validates, and
#      still reads back WITH its measurements. A suite that only proves things
#      are refused would pass if the validators refused everything.
#
# A string is not a number here, deliberately, and that is a change: _side()
# used to accept "10" as 10 m and refuse "ten" as "width is 0 m" - a
# measurement the player never typed. FarmModule and SectionValidator already
# refused both. Now all of them do.
#
# WHICH OF THESE ASSERTIONS MEASURED SOMETHING, AND WHICH ARE ONLY GUARDS
#
# Trap 6 says a check that cannot fail is worth keeping, worth labelling and
# not worth counting as a measurement, so: this suite makes 267 assertions,
# and run against the code as it stood before the fix, 36 of them failed.
#
#   16  the dungeon's own refusals - sides (11) and doors (5)
#   12  a circuit's readback, which returned "" and, for a string or a bool,
#       stated a measurement the request did not contain
#    6  a farm's readback, the same two faults
#    3  a dungeon's readback returning ""
#
# The other 231 passed before this commit and after it. FarmModule,
# SectionValidator, CarTool and BootsTool already asked typeof() before
# converting, so every probe of those four is a GUARD AGAINST FUTURE CHANGE
# and not a finding - which is the point of probing them anyway: the fault
# was that one file out of five had missed a convention, and the only way to
# notice that is to ask all five the same question. The guards are what stops
# the sixth file doing it again.

var bad := 0

# The six. Each is a value JSON.parse can produce where a number belongs.
# "10" is included precisely because it LOOKS usable: float("10") is 10 and
# float("ten") is 0, so any reader that takes the first silently takes the
# second as a request for nothing.
const NOT_NUMBERS := [null, {}, [1, 2], true, "ten", "10"]


func _check(ok: bool, what: String) -> void:
	print(("PASS  " if ok else "FAIL  ") + what)
	if not ok:
		bad += 1


func _label(value: Variant) -> String:
	if value == null:
		return "null"
	match typeof(value):
		TYPE_DICTIONARY:
			return "an object"
		TYPE_ARRAY:
			return "a list"
		TYPE_BOOL:
			return "true"
	return "the string \"%s\"" % str(value)


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	_dungeon_sides()
	_dungeon_doors()
	_farm_sides()
	_circuit_fields()
	_tool_fields()
	_readbacks_are_never_empty()
	_readbacks_invent_no_measurement()
	_the_valid_case_still_works()

	print("REQUEST TYPES failures=%d" % bad)
	quit(bad)


# --- the shape every validator must have ---
#
# A result that has no "ok" in it is the empty dictionary a thrown float()
# left behind, and it is worse than a refusal: game_controller indexes
# check["ok"] directly, so there is no verdict to read and no error to show.
func _refused(result: Variant, field: String, where: String, value: Variant) -> void:
	var what := "%s refuses %s for '%s'" % [where, _label(value), field]
	if typeof(result) != TYPE_DICTIONARY:
		_check(false, what + " - validate returned no dictionary at all")
		return
	var r: Dictionary = result
	if not r.has("ok") or not r.has("errors"):
		_check(false, what + " - the result has no 'ok'/'errors' (a thrown conversion)")
		return
	if bool(r["ok"]):
		_check(false, what + " - ACCEPTED, errors=%s" % str(r["errors"]))
		return
	var named := false
	for e in (r["errors"] as Array):
		if str(e).contains(field):
			named = true
			break
	_check(named, what + " and says which field: %s" % str(r["errors"]))


# --- 1. a dungeon's room sides ---
#
# The fields come from a room the module itself accepts, so a side added to a
# room is probed here without this file being edited.
func _dungeon_sides() -> void:
	var d := DungeonModule.new()
	var mid := (DungeonModule.MIN_SIDE + DungeonModule.MAX_SIDE) * 0.5
	for field in ["width", "depth"]:
		for value in NOT_NUMBERS:
			var room := {"name": "vault", "width": mid, "depth": mid}
			room[field] = value
			var p := {
				"rooms": [room, {"name": "hall", "width": mid, "depth": mid}],
				"doors": [[1, 2]],
			}
			_refused(d.validate(p), field, "a dungeon", value)


# --- 2. a dungeon's doors ---
#
# A door is a pair of room numbers read out of a list rather than from behind
# a key, so it needs the same guard in its own form. An object in a door pair
# is what returned the empty dictionary.
func _dungeon_doors() -> void:
	var d := DungeonModule.new()
	var mid := (DungeonModule.MIN_SIDE + DungeonModule.MAX_SIDE) * 0.5
	for slot in [0, 1]:
		for value in NOT_NUMBERS:
			var pair: Array = [1, 2]
			pair[slot] = value
			var p := {
				"rooms": [
					{"name": "vault", "width": mid, "depth": mid},
					{"name": "hall", "width": mid, "depth": mid},
				],
				"doors": [pair],
			}
			_refused(d.validate(p), "door", "a dungeon", value)


# --- 3. a farm's zone sides ---
func _farm_sides() -> void:
	var f := FarmModule.new()
	var mid := (FarmModule.BUILDING_SIDE.x + FarmModule.BUILDING_SIDE.y) * 0.5
	for field in ["width", "depth"]:
		for value in NOT_NUMBERS:
			var zone := {"type": "barn", "width": mid, "depth": mid}
			zone[field] = value
			var p := {"zones": [zone, {"type": "barn", "width": mid, "depth": mid}]}
			_refused(f.validate(p), field, "a farm", value)


# --- 4. every numeric field of every section type ---
#
# A sound section is built per type from the CONSTANTS, never from numbers
# typed into this file, so a bound that moves cannot leave a stale probe
# behind (trap 13). Then each of its numeric fields in turn is replaced by
# each of the six.
func _circuit_fields() -> void:
	for section in _sound_sections():
		var type := str(section["type"])
		for field in section.keys():
			if field == "type" or field == "direction":
				continue
			for value in NOT_NUMBERS:
				var broken: Dictionary = section.duplicate(true)
				broken[field] = value
				var p := {"sections": [broken, _straight()]}
				_refused(SectionValidator.validate(p), field,
					"a circuit's %s" % type, value)


func _mid(limits: Vector2) -> float:
	return (limits.x + limits.y) * 0.5


func _straight() -> Dictionary:
	return {"type": "straight", "length": _mid(SectionValidator.STRAIGHT_LENGTH)}


# One of each type the validator accepts - all ten, not the four the prompt
# offers, because the validator is what is being tested and it takes ten.
func _sound_sections() -> Array:
	var slope := {
		"length": _mid(SectionValidator.STRAIGHT_LENGTH),
		"grade": _mid(SectionValidator.GRADE_RANGE),
	}
	var out: Array = [_straight()]
	for t in ["uphill", "downhill", "crest", "dip"]:
		var s := slope.duplicate()
		s["type"] = t
		out.append(s)
	out.append({"type": "corner",
		"radius": _mid(SectionValidator.CORNER_RADIUS),
		"angle": _mid(SectionValidator.CORNER_ANGLE)})
	out.append({"type": "hairpin",
		"radius": _mid(SectionValidator.HAIRPIN_RADIUS),
		"angle": _mid(SectionValidator.HAIRPIN_ANGLE)})
	out.append({"type": "banked_corner",
		"radius": _mid(SectionValidator.CORNER_RADIUS),
		"angle": _mid(SectionValidator.CORNER_ANGLE),
		"bank": _mid(SectionValidator.BANK_ANGLE)})
	var chicane_radius := _mid(SectionValidator.CHICANE_RADIUS)
	out.append({"type": "chicane",
		"radius": chicane_radius,
		"offset": chicane_radius,
		"direction": "left"})
	out.append({"type": "loop_segment",
		"radius": _mid(SectionValidator.LOOP_RADIUS),
		"angle": _mid(SectionValidator.LOOP_ANGLE)})
	return out


# --- 5. the tools ---
#
# Which fields are numeric is read out of defaults(): a tool's free fields
# (paint, nickname, colour) are strings there and are not probed as numbers.
# So a bounded field added to a tool is probed here the day it is added.
func _tool_fields() -> void:
	for tool in [CarTool.new(), BootsTool.new()]:
		var defaults: Dictionary = tool.defaults()
		for field in defaults:
			var d = defaults[field]
			if typeof(d) != TYPE_FLOAT and typeof(d) != TYPE_INT:
				continue
			for value in NOT_NUMBERS:
				var spec := {}
				spec[field] = value
				_refused(tool.validate({"spec": spec}), str(field),
					"%s" % tool.name(), value)


# --- 6. a readback is never empty ---
#
# The layer whose only job is to describe the request returned "" for a null
# width, in all three worlds. A player who mistyped one section of a circuit
# was told nothing about any of it.
func _readbacks_are_never_empty() -> void:
	for probe in _readback_probes():
		var said := str(probe["said"])
		_check(said.strip_edges() != "",
			"%s still describes the request when %s is %s" % [
				probe["where"], probe["field"], _label(probe["value"])])


# --- 7. and it states no measurement the request did not contain ---
#
# The real assertion of this suite, and the one that is about a fact rather
# than a form of words. "a 0 by 10 m barn" for a barn whose width was the word
# "ten" is perfectly fluent and completely false, which is trap 8 exactly. So
# every run of digits in the sentence must be a number that was in the
# request. Counts up to six are spelled as words by Readback.count_of, so in
# these small specs every digit is a measurement.
func _readbacks_invent_no_measurement() -> void:
	var digits := RegEx.new()
	digits.compile("[0-9]+")
	for probe in _readback_probes():
		var said := str(probe["said"])
		var given: Array = probe["given"]
		var invented := PackedStringArray()
		for m in digits.search_all(said):
			var n := m.get_string()
			if not given.has(n):
				invented.append(n)
		_check(invented.is_empty(),
			"%s invents no measurement when %s is %s%s" % [
				probe["where"], probe["field"], _label(probe["value"]),
				"" if invented.is_empty() else " - said %s, request held %s: \"%s\"" % [
					str(invented), str(given), said]])


# Each world described with one measurement replaced by something that is not
# a number, alongside the digits the request actually contained.
func _readback_probes() -> Array:
	var out: Array = []
	var d := DungeonModule.new()
	var f := FarmModule.new()
	var r := RacingModule.new()
	for value in NOT_NUMBERS:
		# A dungeon. 12 and 30 are the only numbers in the request.
		var p1 := {
			"rooms": [{"name": "vault", "width": value, "depth": 12},
				{"name": "hall", "width": 30, "depth": 30}],
			"doors": [[1, 2]],
		}
		out.append({"where": "a dungeon's readback", "field": "a room's width",
			"value": value, "said": d.readback(p1), "given": ["12", "30"]})

		# A farm.
		var p2 := {"zones": [{"type": "barn", "width": value, "depth": 12},
			{"type": "pond", "width": 30, "depth": 30}]}
		out.append({"where": "a farm's readback", "field": "a zone's width",
			"value": value, "said": f.readback(p2), "given": ["12", "30"]})

		# A circuit, with the bad value on a section that is not the only one,
		# so a readback that drops the piece entirely is still visibly wrong.
		var p3 := {"sections": [{"type": "straight", "length": value},
			{"type": "straight", "length": 250}]}
		out.append({"where": "a circuit's readback", "field": "a straight's length",
			"value": value, "said": r.readback(p3), "given": ["250"]})

		# And a graded section, whose readback reads TWO numbers.
		var p4 := {"sections": [{"type": "uphill", "length": 200, "grade": value},
			{"type": "straight", "length": 250}]}
		out.append({"where": "a circuit's readback", "field": "an uphill's grade",
			"value": value, "said": r.readback(p4), "given": ["200", "250"]})
	return out


# --- 8. and the sound case is untouched ---
#
# Everything above would also pass if the validators had been changed to
# refuse every request and the readbacks to say nothing but the type. This is
# the half that says they were not.
func _the_valid_case_still_works() -> void:
	var d := DungeonModule.new()
	var dungeon := {
		"rooms": [{"name": "vault", "width": 12, "depth": 12},
			{"name": "hall", "width": 30, "depth": 30}],
		"doors": [[1, 2]],
	}
	var dr = d.validate(dungeon)
	_check(bool(dr["ok"]), "a sound dungeon still validates: %s" % str(dr["errors"]))
	var dsaid := d.readback(dungeon)
	_check(dsaid.contains("12"), "and still reads its entrance back WITH a size: %s" % dsaid)

	# An integer and a float are both numbers, and a float must survive the
	# new reader: a model writes 12.5 as readily as 12.
	var half := {
		"rooms": [{"name": "vault", "width": 12.5, "depth": 12.5},
			{"name": "hall", "width": 30, "depth": 30}],
		"doors": [[1, 2]],
	}
	_check(bool(d.validate(half)["ok"]), "a fractional side is still a number")

	var f := FarmModule.new()
	var farm := {"zones": [{"type": "barn", "width": 12, "depth": 12},
		{"type": "pond", "width": 30, "depth": 30}]}
	var fr = f.validate(farm)
	_check(bool(fr["ok"]), "a sound farm still validates: %s" % str(fr["errors"]))
	_check(f.readback(farm).contains("12"), "and still reads its sizes back")

	var r := RacingModule.new()
	var circuit := {"sections": [{"type": "straight", "length": 250},
		{"type": "uphill", "length": 200, "grade": 5}]}
	var said := r.readback(circuit)
	_check(said.contains("250") and said.contains("200") and said.contains("5"),
		"a circuit still reads back every measurement it was given: %s" % said)

	# inf IS a float, so every typeof() check in Genesis passes it through,
	# and JSON.parse('{"w": 1e400}') really does produce one - this is not a
	# value that needs a hand-built Variant to reach a validator. It is
	# refused anyway, by the bound, because inf is above every upper limit.
	# Asserted here because HANDOVER now says so, and a claim in a document
	# with no test behind it is trap 14.
	var parsed := JSON.new()
	_check(parsed.parse('{"w": 1e400}') == OK and is_inf(float((parsed.data as Dictionary)["w"])),
		"1e400 in JSON really does parse to inf")
	var huge := {
		"rooms": [{"name": "vault", "width": INF, "depth": 12},
			{"name": "hall", "width": 30, "depth": 30}],
		"doors": [[1, 2]],
	}
	_check(not bool(d.validate(huge)["ok"]), "and an infinite side is refused by the bound")

	# And a bound still refuses a number that IS one, with the limit named -
	# the thing 028 built, which a type check must not have quietly replaced.
	var too_long := {"sections": [
		{"type": "straight", "length": SectionValidator.STRAIGHT_LENGTH.y + 1000.0},
		_straight()]}
	var tr := SectionValidator.validate(too_long)
	var names_limit := false
	for e in (tr["errors"] as Array):
		if str(e).contains("%.0f" % SectionValidator.STRAIGHT_LENGTH.y):
			names_limit = true
	_check(not bool(tr["ok"]) and names_limit,
		"an out-of-range number is still refused with its limit named: %s" % str(tr["errors"]))
