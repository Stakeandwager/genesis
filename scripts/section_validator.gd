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
				if not is_nan(length):
					if not _in_range(length, STRAIGHT_LENGTH):
						errors.append("section %d (straight): length out of range" % n)
					else:
						clean.append({"type": "straight", "length": length})

			"uphill", "downhill", "crest", "dip":
				counts[t] += 1
				_forbid(section, ["radius", "angle", "offset", "direction", "bank"], n, t, errors)
				var length := _number(section, "length", n, t, errors)
				var grade := _number(section, "grade", n, t, errors)
				var section_ok := not is_nan(length) and not is_nan(grade)
				if not is_nan(length) and not _in_range(length, STRAIGHT_LENGTH):
					errors.append("section %d (%s): length out of range" % [n, t])
					section_ok = false
				if not is_nan(grade) and not _in_range(grade, GRADE_RANGE):
					errors.append("section %d (%s): grade out of range" % [n, t])
					section_ok = false
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
				var section_ok := not is_nan(radius) and not is_nan(angle)
				if not is_nan(radius) and not _in_range(radius, radius_range):
					errors.append("section %d (%s): radius out of range" % [n, t])
					section_ok = false
				if not is_nan(angle):
					if angle == 0.0 or not _in_range(absf(angle), angle_range):
						errors.append("section %d (%s): angle out of range" % [n, t])
						section_ok = false
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
				var section_ok := not is_nan(radius) and not is_nan(angle) and not is_nan(bank)
				if not is_nan(radius) and not _in_range(radius, CORNER_RADIUS):
					errors.append("section %d (banked_corner): radius out of range" % n)
					section_ok = false
				if not is_nan(angle) and not _in_range(absf(angle), CORNER_ANGLE):
					errors.append("section %d (banked_corner): angle out of range" % n)
					section_ok = false
				if not is_nan(bank) and not _in_range(bank, BANK_ANGLE):
					errors.append("section %d (banked_corner): bank out of range" % n)
					section_ok = false
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
				if not is_nan(radius) and not _in_range(radius, CHICANE_RADIUS):
					errors.append("section %d (chicane): radius out of range" % n)
					section_ok = false
				if not is_nan(offset) and not is_nan(radius):
					if offset <= 0.0 or offset > 2.0 * radius:
						errors.append("section %d (chicane): invalid offset" % n)
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
				var section_ok := not is_nan(radius) and not is_nan(angle)
				if not is_nan(radius) and not _in_range(radius, LOOP_RADIUS):
					errors.append("section %d (loop_segment): radius out of range" % n)
					section_ok = false
				if not is_nan(angle) and not _in_range(absf(angle), LOOP_ANGLE):
					errors.append("section %d (loop_segment): angle out of range" % n)
					section_ok = false
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


static func _in_range(value: float, limits: Vector2) -> bool:
	return value >= limits.x and value <= limits.y
