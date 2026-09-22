extends RefCounted
class_name SectionValidator

# --- Prototype 002A - Step A1: Section schema validation ---
# Section types are DATA, checked against a whitelist exactly like commands.
# Nothing outside this vocabulary ever reaches the geometry builder.
# Rules follow Protocol 002 plus Amendments A (signed angles),
# B (arc length is derived, never supplied) and C (chicane geometry).
#
# The AI proposes. Godot constructs. Godot validates. Godot measures.

const SECTION_TYPES := ["straight", "corner", "hairpin", "chicane"]
const DEFERRED_TYPES := ["tunnel", "jump", "bridge", "uphill", "downhill", "banked_corner"]
const MODES := ["circuit"]

const MIN_SECTIONS := 2
const MAX_SECTIONS := 40

# Allowed ranges, as (minimum, maximum). Angles are absolute degrees.
const STRAIGHT_LENGTH := Vector2(20.0, 1000.0)
const CORNER_RADIUS := Vector2(15.0, 300.0)
const CORNER_ANGLE := Vector2(10.0, 120.0)
const HAIRPIN_RADIUS := Vector2(10.0, 60.0)
const HAIRPIN_ANGLE := Vector2(120.0, 200.0)
const CHICANE_RADIUS := Vector2(15.0, 150.0)


# Returns a dictionary with:
#   ok        bool
#   errors    Array of readable problems (empty when ok)
#   sections  cleaned list of sections (only meaningful when ok)
#   summary   section_count, net_turn, direction_change, counts
static func validate(parameters: Dictionary) -> Dictionary:
	var errors: Array[String] = []
	var clean: Array = []
	var counts := {"straight": 0, "corner": 0, "hairpin": 0, "chicane": 0}
	var net_turn := 0.0
	var direction_change := 0.0

	var mode := str(parameters.get("mode", "circuit"))
	if not mode in MODES:
		errors.append("mode '%s' is not available in 002A (only: circuit)" % mode)

	if parameters.has("intent") and typeof(parameters["intent"]) != TYPE_DICTIONARY:
		errors.append("intent must be an object, for example {\"style\": \"technical\"}")

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
				_forbid(section, ["radius", "angle", "offset", "direction"], n, t, errors)
				var length := _number(section, "length", n, t, errors)
				if not is_nan(length):
					if not _in_range(length, STRAIGHT_LENGTH):
						errors.append("section %d (straight): length %.0f m is outside %.0f-%.0f m" % [n, length, STRAIGHT_LENGTH.x, STRAIGHT_LENGTH.y])
					else:
						clean.append({"type": "straight", "length": length})

			"corner", "hairpin":
				counts[t] += 1
				if section.has("length"):
					errors.append("section %d (%s): do not supply 'length'; it is calculated from radius and angle" % [n, t])
				_forbid(section, ["offset", "direction"], n, t, errors)

				var radius_range := CORNER_RADIUS if t == "corner" else HAIRPIN_RADIUS
				var angle_range := CORNER_ANGLE if t == "corner" else HAIRPIN_ANGLE

				var radius := _number(section, "radius", n, t, errors)
				var angle := _number(section, "angle", n, t, errors)
				var section_ok := not is_nan(radius) and not is_nan(angle)

				if not is_nan(radius) and not _in_range(radius, radius_range):
					errors.append("section %d (%s): radius %.0f m is outside %.0f-%.0f m" % [n, t, radius, radius_range.x, radius_range.y])
					section_ok = false

				if not is_nan(angle):
					if angle == 0.0:
						errors.append("section %d (%s): angle must not be zero (positive turns right, negative turns left)" % [n, t])
						section_ok = false
					elif not _in_range(absf(angle), angle_range):
						errors.append("section %d (%s): a %.0f degree turn is outside %.0f-%.0f degrees" % [n, t, absf(angle), angle_range.x, angle_range.y])
						section_ok = false

				if section_ok:
					net_turn += angle
					direction_change += absf(angle)
					clean.append({"type": t, "radius": radius, "angle": angle})

			"chicane":
				counts["chicane"] += 1
				if section.has("length"):
					errors.append("section %d (chicane): do not supply 'length'; it is calculated from radius and offset" % n)
				_forbid(section, ["angle"], n, t, errors)

				var radius := _number(section, "radius", n, t, errors)
				var offset := _number(section, "offset", n, t, errors)
				var direction := str(section.get("direction", ""))
				var section_ok := not is_nan(radius) and not is_nan(offset)

				if not direction in ["left", "right"]:
					errors.append("section %d (chicane): direction must be \"left\" or \"right\"" % n)
					section_ok = false

				if not is_nan(radius) and not _in_range(radius, CHICANE_RADIUS):
					errors.append("section %d (chicane): radius %.0f m is outside %.0f-%.0f m" % [n, radius, CHICANE_RADIUS.x, CHICANE_RADIUS.y])
					section_ok = false

				if not is_nan(offset) and not is_nan(radius):
					if offset <= 0.0:
						errors.append("section %d (chicane): offset must be greater than zero" % n)
						section_ok = false
					elif offset > 2.0 * radius:
						errors.append("section %d (chicane): offset %.0f m exceeds the maximum %.0f m for radius %.0f m" % [n, offset, 2.0 * radius, radius])
						section_ok = false

				if section_ok:
					# Amendment C: two equal and opposite arcs, net turn zero.
					var theta := acos(1.0 - offset / (2.0 * radius))
					direction_change += 2.0 * rad_to_deg(theta)
					clean.append({"type": "chicane", "radius": radius, "offset": offset, "direction": direction})

			"":
				errors.append("section %d has no type" % n)

			_:
				if t in DEFERRED_TYPES:
					errors.append("section %d: '%s' is planned for Prototype 002B and is not available yet" % [n, t])
				else:
					errors.append("section %d: unknown type '%s' (allowed: straight, corner, hairpin, chicane)" % [n, t])

	return _result(errors, clean, counts, net_turn, direction_change)


# --- helpers ---

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
