extends RefCounted
class_name SectionValidator

# --- Prototype 002B - Universal Track Geometry & Vertical Axis (user's build) ---

const SECTION_TYPES := ["straight", "uphill", "downhill", "crest", "dip", "corner", "hairpin", "banked_corner", "chicane", "loop_segment"]
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

	if parameters.has("intent") and typeof(parameters["intent"]) != TYPE_DICTIONARY:
		errors.append("intent must be an object")

	var raw = parameters.get("sections", null)
	if typeof(raw) != TYPE_ARRAY:
		errors.append("sections must be a list")
		return _result(errors, clean, counts, net_turn, direction_change)

	var sections: Array = raw
	if sections.size() < MIN_SECTIONS or sections.size() > MAX_SECTIONS:
		errors.append("a track needs %d to %d sections (got %d)" % [MIN_SECTIONS, MAX_SECTIONS, sections.size()])

	for i in sections.size():
		var n := i + 1
		var s = sections[i]
		if typeof(s) != TYPE_DICTIONARY:
			errors.append("section %d is not an object" % n)
			continue
		var section: Dictionary = s
		var t := str(section.get("type", ""))

		match t:
			"straight":
				counts["straight"] += 1
				_forbid(section, ["radius", "angle", "offset", "direction", "grade", "bank"], n, t, errors)
				var length := _number(section, "length", n, t, errors)
				if _bound(errors, n, t, "length", length, STRAIGHT_LENGTH, " m"):
					clean.append({"type": "straight", "length": length})

			"uphill", "downhill", "crest", "dip":
				counts[t] += 1
				_forbid(section, ["radius", "angle", "offset", "direction", "bank"], n, t, errors)
				var length := _number(section, "length", n, t, errors)
				var grade := _number(section, "grade", n, t, errors)
				# Both are asked, so both are answered: a spec with two bad
				# numbers is told about two, not about the first one.
				var length_ok := _bound(errors, n, t, "length", length, STRAIGHT_LENGTH, " m")
				var grade_ok := _bound(errors, n, t, "grade", grade, GRADE_RANGE, "%")
				var section_ok := length_ok and grade_ok
				if section_ok:
					clean.append({"type": t, "length": length, "grade": grade})

			"corner", "hairpin":
				counts[t] += 1
				if section.has("length"):
					errors.append("section %d (%s): do not supply 'length'" % [n, t])
				_forbid(section, ["offset", "direction", "grade", "bank"], n, t, errors)
				var radius_range := CORNER_RADIUS if t == "corner" else HAIRPIN_RADIUS
				var angle_range := CORNER_ANGLE if t == "corner" else HAIRPIN_ANGLE
				var radius := _number(section, "radius", n, t, errors)
				var angle := _number(section, "angle", n, t, errors)
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
				if section.has("length"):
					errors.append("section %d (banked_corner): do not supply 'length'" % n)
				_forbid(section, ["offset", "direction", "grade"], n, t, errors)
				var radius := _number(section, "radius", n, t, errors)
				var angle := _number(section, "angle", n, t, errors)
				var bank := _number(section, "bank", n, t, errors)
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
				if section.has("length"):
					errors.append("section %d (chicane): do not supply 'length'" % n)
				_forbid(section, ["angle", "grade", "bank"], n, t, errors)
				var radius := _number(section, "radius", n, t, errors)
				var offset := _number(section, "offset", n, t, errors)
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
				if section.has("length"):
					errors.append("section %d (loop_segment): do not supply 'length'" % n)
				_forbid(section, ["offset", "direction", "grade", "bank"], n, t, errors)
				var radius := _number(section, "radius", n, t, errors)
				var angle := _number(section, "angle", n, t, errors)
				var radius_ok := _bound(errors, n, t, "radius", radius, LOOP_RADIUS, " m")
				var angle_ok := _bound(errors, n, t, "angle", angle, LOOP_ANGLE, " degrees", true)
				var section_ok := radius_ok and angle_ok
				if section_ok:
					net_turn += angle
					direction_change += absf(angle)
					clean.append({"type": "loop_segment", "radius": radius, "angle": angle})

			"":
				errors.append("section %d has no type" % n)

			_:
				errors.append("section %d: unknown type '%s'" % [n, t])

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


static func _number(section: Dictionary, key: String, n: int, t: String, errors: Array[String]) -> float:
	if not section.has(key):
		errors.append("section %d (%s): missing '%s'" % [n, t, key])
		return NAN
	var value = section[key]
	if typeof(value) != TYPE_FLOAT and typeof(value) != TYPE_INT:
		errors.append("section %d (%s): '%s' must be a number" % [n, t, key])
		return NAN
	return float(value)


static func _forbid(section: Dictionary, keys: Array, n: int, t: String, errors: Array[String]) -> void:
	for key in keys:
		if section.has(key):
			errors.append("section %d (%s): '%s' is not a %s setting" % [n, t, key, t])


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
	var either := ", either direction" if magnitude else ""
	return "section %d (%s): %s is %s%s, and must be %s to %s%s%s" % [
		n, t, field, _tidy(value), unit, _tidy(limits.x), _tidy(limits.y), unit, either]


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
