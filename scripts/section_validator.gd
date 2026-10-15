extends RefCounted
class_name SectionValidator

# --- Prototype 002B - Universal Track Geometry & Vertical Axis (user's build) ---

const SECTION_TYPES := ["straight", "uphill", "downhill", "crest", "dip", "corner", "hairpin", "banked_corner", "chicane", "loop_segment"]

# --- the four a player is offered, and why it is not the ten above ---
#
# THIS IS A WALL, NOT A STALE LIST. Read TRAPS 19 before touching it.
# SECTION_TYPES is what this validator accepts. OFFERED_TYPES is what the
# player is told a circuit is built from, and the AI's prompt in
# racing_module.gd says "only these four" for a reason that lives in a third
# file: docs/GENESIS_BRIEF.md, under "Known rough edges", records that banked
# corners act as ramps and throw cars over the barrier (about 23 opponent
# recoveries a race), that loops are built but untested with a car, that the
# separation check is flat so a loop passing over itself reads as a crash, and
# that the solver does not check a track returns to its starting height.
# Those four defects are precisely the six types left out here.
#
# The six validate, measure, close and build. What they do not do is behave,
# and "only these four" is the one thing between a player's sentence and a
# known car-launching defect. Whether to open them is the owner's - it is
# product direction and it is item 1 under "Human decision needed" in
# docs/HANDOVER.md - so nothing here decides it.
#
# What 030 changed is only that the refusals below now READ this list instead
# of naming nothing. Writing out SECTION_TYPES in the message, which is what
# "name the legal values" looks like at a glance, would have advertised the
# six withheld types to the player in the one sentence nobody was testing -
# undoing trap 19's wall through a door it had not been checked for. TRAPS 19
# asks for the reason to be written where the restriction is. It is now.
#
# tests/capability_test.gd fails if this list and the prompt's four ever
# disagree, in either direction, so the two copies cannot drift (TRAPS 11).
const OFFERED_TYPES := ["straight", "corner", "hairpin", "chicane"]

# --- what each section type is made of, in one place ---
#
# Until 030 a type's fields were written out twice: once as the list of keys
# _forbid() was handed at the call site, and once not at all - the refusal
# said "'bank' is not a straight setting" and never said what a straight's
# settings ARE. Four types also tested for 'length' in a separate line of
# their own, with a differently worded refusal, because 'length' was not in
# any _forbid list.
#
# Both now read from here: a type's own fields are what it keeps, every other
# field in the table is what it refuses, and the refusal names the fields the
# type has. This is around_of() and _wall_rects() again - the thing that acts
# and the thing that describes reading from one place.
const FIELDS := {
	"straight": ["length"],
	"uphill": ["length", "grade"],
	"downhill": ["length", "grade"],
	"crest": ["length", "grade"],
	"dip": ["length", "grade"],
	"corner": ["radius", "angle"],
	"hairpin": ["radius", "angle"],
	"banked_corner": ["radius", "angle", "bank"],
	"chicane": ["radius", "offset", "direction"],
	"loop_segment": ["radius", "angle"],
}

const MODES := ["circuit"]

const MIN_SECTIONS := 2
const MAX_SECTIONS := 40

const STRAIGHT_LENGTH := Vector2(20.0, 1000.0)
const GRADE_RANGE := Vector2(1.0, 30.0)
const CORNER_RADIUS := Vector2(15.0, 300.0)
const CORNER_ANGLE := Vector2(10.0, 120.0)
const HAIRPIN_RADIUS := Vector2(10.0, 60.0)
const HAIRPIN_ANGLE := Vector2(120.0, 200.0)
const BANK_ANGLE := Vector2(0.0, 45.0)
const CHICANE_RADIUS := Vector2(15.0, 150.0)
const LOOP_RADIUS := Vector2(10.0, 100.0)
const LOOP_ANGLE := Vector2(90.0, 360.0)


# --- 034: the list door, and why its example is read and not typed ---
#
# Every list in Genesis was refused with four words that name no legal value
# - "sections must be a list" - next to field refusals that say "and it must
# be 20 to 1000 m". TRAPS 21 one level up; see Readback.list_error().
#
# The example type is read from OFFERED_TYPES rather than written out, and
# that is not tidiness. SECTION_TYPES holds ten types and the player is
# offered four, deliberately, because the other six build and do not behave
# (TRAPS 19, "Human decision needed" 1 in HANDOVER). The refusal that names
# a legal value is exactly the sentence a withheld type would leak out of -
# which is the regression TRAPS 21's last paragraph warns about, arriving at
# the door above the one it warned about. So the example comes off the
# OFFERED list, its field comes off FIELDS, and tests/container_door_test.gd
# fails if the type shown is one the player is not offered.
static func list_entry() -> Dictionary:
	var offered := str(OFFERED_TYPES[0])
	var first_field := str((FIELDS[offered] as Array)[0])
	return {
		"key": "sections", "one": "section", "many": "sections",
		"low": MIN_SECTIONS, "high": MAX_SECTIONS, "required": true,
		"sample": [_example(offered, first_field, 200), _example(offered, first_field, 300)],
	}


static func _example(type_name: String, field: String, value: int) -> Dictionary:
	var member := {"type": type_name}
	member[field] = value
	return member


static func validate(parameters: Dictionary) -> Dictionary:
	var errors: Array[String] = []
	var clean: Array = []
	var counts := {
		"straight": 0, "uphill": 0, "downhill": 0, "crest": 0, "dip": 0,
		"corner": 0, "hairpin": 0, "banked_corner": 0, "chicane": 0, "loop_segment": 0
	}
	var net_turn := 0.0
	var direction_change := 0.0

	var mode := str(parameters.get("mode", "circuit"))
	if not mode in MODES:
		errors.append("mode '%s' is not available (only: circuit)" % mode)

	# FarmModule and DungeonModule have shown the shape here since they were
	# written; this one named the type and left the player to guess what goes
	# in it. 037: all six doors now ask Readback.intent_problem().
	var intent_wrong := Readback.intent_problem(parameters, "a street circuit")
	if intent_wrong != "":
		errors.append(intent_wrong)

	var raw = parameters.get("sections", null)
	if typeof(raw) != TYPE_ARRAY:
		errors.append(Readback.list_error(list_entry()))
		return _result(errors, clean, counts, net_turn, direction_change)

	var sections: Array = raw
	if sections.size() < MIN_SECTIONS or sections.size() > MAX_SECTIONS:
		errors.append("a track needs %d to %s (got %d)" % [MIN_SECTIONS, Readback.plural(MAX_SECTIONS, "section"), sections.size()])

	for i in sections.size():
		var n := i + 1
		var s = sections[i]
		if typeof(s) != TYPE_DICTIONARY:
			errors.append(Readback.member_error(list_entry(), n))
			continue
		var section: Dictionary = s
		var t := str(section.get("type", ""))

		match t:
			"straight":
				counts["straight"] += 1
				_forbid(section, n, t, errors)
				var length := _number(section, "length", n, t, errors, _span(STRAIGHT_LENGTH, " m"))
				if _bound(errors, n, t, "length", length, STRAIGHT_LENGTH, " m"):
					clean.append({"type": "straight", "length": length})

			"uphill", "downhill", "crest", "dip":
				counts[t] += 1
				_forbid(section, n, t, errors)
				var length := _number(section, "length", n, t, errors, _span(STRAIGHT_LENGTH, " m"))
				var grade := _number(section, "grade", n, t, errors, _span(GRADE_RANGE, "%"))
				# Both are asked, so both are answered: a spec with two bad
				# numbers is told about two, not about the first one.
				var length_ok := _bound(errors, n, t, "length", length, STRAIGHT_LENGTH, " m")
				var grade_ok := _bound(errors, n, t, "grade", grade, GRADE_RANGE, "%")
				var section_ok := length_ok and grade_ok
				if section_ok:
					clean.append({"type": t, "length": length, "grade": grade})

			"corner", "hairpin":
				counts[t] += 1
				_forbid(section, n, t, errors)
				var radius_range := CORNER_RADIUS if t == "corner" else HAIRPIN_RADIUS
				var angle_range := CORNER_ANGLE if t == "corner" else HAIRPIN_ANGLE
				var radius := _number(section, "radius", n, t, errors, _span(radius_range, " m"))
				var angle := _number(section, "angle", n, t, errors, _span(angle_range, " degrees", true))
				var radius_ok := _bound(errors, n, t, "radius", radius, radius_range, " m")
				# An angle of exactly 0 was refused by a test of its own here.
				# It still is, by the bound: every angle_range in this file
				# starts above 0, so a straight-ahead "corner" is out of range
				# on its size and is told so with the size named.
				var angle_ok := _bound(errors, n, t, "angle", angle, angle_range, " degrees", true)
				var section_ok := radius_ok and angle_ok
				if section_ok:
					net_turn += angle
					direction_change += absf(angle)
					clean.append({"type": t, "radius": radius, "angle": angle})

			"banked_corner":
				counts["banked_corner"] += 1
				_forbid(section, n, t, errors)
				var radius := _number(section, "radius", n, t, errors, _span(CORNER_RADIUS, " m"))
				var angle := _number(section, "angle", n, t, errors, _span(CORNER_ANGLE, " degrees", true))
				var bank := _number(section, "bank", n, t, errors, _span(BANK_ANGLE, " degrees"))
				var radius_ok := _bound(errors, n, t, "radius", radius, CORNER_RADIUS, " m")
				var angle_ok := _bound(errors, n, t, "angle", angle, CORNER_ANGLE, " degrees", true)
				# Bank is the one angle in this file that is NOT bounded on its
				# size. Its range starts at 0, so a negative bank is out of
				# range and has to stay out; reading it as a magnitude would
				# quietly let one in.
				var bank_ok := _bound(errors, n, t, "bank", bank, BANK_ANGLE, " degrees")
				var section_ok := radius_ok and angle_ok and bank_ok
				if section_ok:
					net_turn += angle
					direction_change += absf(angle)
					clean.append({"type": "banked_corner", "radius": radius, "angle": angle, "bank": bank})

			"chicane":
				counts["chicane"] += 1
				_forbid(section, n, t, errors)
				var radius := _number(section, "radius", n, t, errors, _span(CHICANE_RADIUS, " m"))
				# The one bound in this file that is not a constant, so the
				# phrase names the RULE rather than a pair of numbers. A
				# player whose model left the offset out can act on "more
				# than 0 and at most twice the radius"; they could not act on
				# "missing 'offset'".
				var offset := _number(section, "offset", n, t, errors,
					"more than 0 and at most twice the radius")
				var direction := str(section.get("direction", ""))
				var section_ok := not is_nan(radius) and not is_nan(offset)
				if not direction in ["left", "right"]:
					errors.append("section %d (chicane): direction must be left or right" % n)
					section_ok = false
				var radius_ok := _bound(errors, n, t, "radius", radius, CHICANE_RADIUS, " m")
				if not radius_ok:
					section_ok = false
				# Only once the radius is SOUND. The bound on offset is twice
				# the radius, so a radius that has already been refused would
				# make this name a limit that is not one: a radius of -145
				# produced "at most twice the radius, which is -290 m here".
				# A refusal has to name a real limit or it is noise on top of
				# the refusal the player already has. BootsTool states the same
				# rule for the same reason - a body already being refused for a
				# bad number does not also need telling what that number would
				# have done.
				if not is_nan(offset) and radius_ok:
					# The one bound in this file that is not a constant: it is
					# twice the radius that was asked for. So the refusal names
					# the number the limit came out to, not just the rule, or a
					# player cannot tell what to type instead.
					if offset <= 0.0 or offset > 2.0 * radius:
						errors.append("section %d (chicane): offset is %s m, and must be more than 0 and at most twice the radius, which is %s m here" % [
							n, _tidy(offset), _tidy(2.0 * radius)])
						section_ok = false
				if section_ok:
					var theta := acos(1.0 - offset / (2.0 * radius))
					direction_change += 2.0 * rad_to_deg(theta)
					clean.append({"type": "chicane", "radius": radius, "offset": offset, "direction": direction})

			"loop_segment":
				counts["loop_segment"] += 1
				_forbid(section, n, t, errors)
				var radius := _number(section, "radius", n, t, errors, _span(LOOP_RADIUS, " m"))
				var angle := _number(section, "angle", n, t, errors, _span(LOOP_ANGLE, " degrees", true))
				var radius_ok := _bound(errors, n, t, "radius", radius, LOOP_RADIUS, " m")
				var angle_ok := _bound(errors, n, t, "angle", angle, LOOP_ANGLE, " degrees", true)
				var section_ok := radius_ok and angle_ok
				if section_ok:
					net_turn += angle
					direction_change += absf(angle)
					clean.append({"type": "loop_segment", "radius": radius, "angle": angle})

			# Both of these named nothing a player could act on until 030.
			# They name OFFERED_TYPES and not SECTION_TYPES, deliberately:
			# see the note on OFFERED_TYPES and TRAPS 19.
			"":
				errors.append("section %d has no type (a circuit is built from %s)" % [
					n, ", ".join(OFFERED_TYPES)])

			_:
				errors.append("section %d: unknown type '%s' (a circuit is built from %s)" % [
					n, t, ", ".join(OFFERED_TYPES)])

	return _result(errors, clean, counts, net_turn, direction_change)


static func _result(errors: Array[String], clean: Array, counts: Dictionary, net_turn: float, direction_change: float) -> Dictionary:
	return {
		"ok": errors.is_empty(),
		"errors": errors,
		"sections": clean,
		"summary": {
			"section_count": clean.size(),
			"net_turn": net_turn,
			"direction_change": direction_change,
			"counts": counts,
		},
	}


# A number out of a section, or a refusal naming what one would have to be.
#
# `allowed` is the same phrase the range refusal uses, built by _span() from
# the same constant, so the three refusals a field can draw - missing, not a
# number, out of range - cannot disagree about its bound. Before 030 only the
# third of them named one; the first two said "missing 'length'" and
# "'length' must be a number" and left the player with nothing to type
# (TRAPS 21). The caller passes the phrase rather than the limits because one
# bound in this file is not a constant: a chicane's offset is twice the radius
# that was asked for, and its phrase is a rule rather than a pair of numbers.
#
# The type question is Readback.as_number()'s, the single place in Genesis
# that decides whether a value out of a request is a number (029, TRAPS 20).
static func _number(section: Dictionary, key: String, n: int, t: String,
		errors: Array[String], allowed: String) -> float:
	if not section.has(key):
		errors.append("section %d (%s): missing '%s', and it must be %s" % [n, t, key, allowed])
		return NAN
	var value := Readback.as_number(section[key])
	if is_nan(value):
		errors.append("section %d (%s): '%s' must be a number, %s" % [n, t, key, allowed])
		return NAN
	return value


# A field this type does not have, refused with the fields it DOES have.
#
# The forbidden set is every field in FIELDS that this type does not keep, so
# the list and the sentence come from one place and a type that grows a field
# stops forbidding it in the same edit. It also absorbs the four hand-written
# 'length' checks that sat beside the old call sites, which refused the same
# thing in different words.
static func _forbid(section: Dictionary, n: int, t: String, errors: Array[String]) -> void:
	var mine: Array = FIELDS.get(t, [])
	var asked := {}
	for type in FIELDS:
		for key in (FIELDS[type] as Array):
			if key in mine or asked.has(key):
				continue
			asked[key] = true
			if section.has(key):
				# Readback.join_list for the same reason every other list in
				# Genesis uses it: "radius and angle", not "radius, angle".
				errors.append("section %d (%s): '%s' is not a %s setting (a %s has %s)" % [
					n, t, key, t, t,
					Readback.join_list(PackedStringArray(mine))])


# --- one reading, applied to the words of a refusal ---
#
# The AI's prompt states this as a fact about Genesis, not an ambition: "It
# REFUSES rather than clamping. A number outside its limits is refused with
# the limit named." Every other validator in the project does exactly that:
#
#   CarTool         power is 5000, and a car's power must be 400 to 1800
#   BootsTool       push is 5000, and boots' push must be 120 to 600
#   FarmModule      zone 1 (barn): width 500 m is outside 5-60 m
#   DungeonModule   room 1: width is 500 m, and must be 4 to 40 m
#
# This file said "length out of range" and named nothing, eleven times over.
# The limits lived in the one range test and the sentence was written by hand at
# every call site, so the one function that knew the bound was the one
# function that never said it - the thing that acts and the thing that
# describes reading from different places, which is the fault around_of() was
# written to settle.
#
# It matters to a player and not only to a document. A refusal that names no
# limit is half a refusal: it says no without saying what yes would be, so a
# player who asked for a 2 km straight is told to try again with no idea what
# to try. The circuit was the only world in Genesis that refused that way.
#
# So the function that decides whether a number is in range is the function
# that names the range. around_of(), _wall_rects(), is_shut(), top_speed() and
# sentences_of() are the same rule in five other places.
#
# unit is written as it should read after the number, so " m" and " degrees"
# carry their space and "%" does not.
static func _range_error(n: int, t: String, field: String, value: float,
		limits: Vector2, unit: String, magnitude: bool) -> String:
	# A signed angle is bounded on its SIZE: positive turns right, negative
	# left, and both are legal at the same magnitudes. Bank is not, and passes
	# magnitude = false for that reason.
	var measured := absf(value) if magnitude else value
	if measured >= limits.x and measured <= limits.y:
		return ""
	return "section %d (%s): %s is %s%s, and must be %s" % [
		n, t, field, _tidy(value), unit, _span(limits, unit, magnitude)]


# What a legal value for this bound would be, in the words a refusal uses.
#
# One function, because a field can be refused three ways - missing, not a
# number, out of range - and all three have to describe the same bound. 028
# gave the range refusal its limits and 029 recorded that the other two still
# had none; this is where they get them.
static func _span(limits: Vector2, unit: String, magnitude: bool = false) -> String:
	var either := ", either direction" if magnitude else ""
	return "%s to %s%s%s" % [_tidy(limits.x), _tidy(limits.y), unit, either]


# Records the refusal if there is one, and says whether the number was sound.
# A number that was missing or was not a number has already been refused by
# _number() and is not sound either, so a call site reads as one line per
# bound and nothing is accepted on the strength of a NAN.
static func _bound(errors: Array[String], n: int, t: String, field: String,
		value: float, limits: Vector2, unit: String, magnitude: bool = false) -> bool:
	if is_nan(value):
		return false
	var problem := _range_error(n, t, field, value, limits, unit, magnitude)
	if problem == "":
		return true
	errors.append(problem)
	return false


# A number as a player would read it: whole numbers with no decimal point,
# fractions with enough places to be exact about what was asked for.
static func _tidy(value: float) -> String:
	if is_equal_approx(value, roundf(value)):
		return "%.0f" % value
	return "%.2f" % value if absf(value) < 10.0 else "%.1f" % value
