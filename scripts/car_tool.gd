extends ToolModule
class_name CarTool

# --- 004: the car as something you can ask for ---
# Until now every player got the same car, because its specification was
# seven constants in car.gd that nobody could reach. Ask for a heavy rally
# truck or a light go-kart and you got the identical vehicle.
#
# The four numbers below are what actually change how a car behaves. The AI
# names them in the player's terms and Godot turns them into physics, the
# same division of labour as everywhere else: the player says "something
# that grips", the AI proposes a downforce, the validator decides whether
# that is a number a car may have.
#
# The defaults are exactly the old constants, so a player who asks for
# nothing gets precisely the car Genesis has always given them.
#
# FREE AND NOT FREE
# paint and nickname change nothing you can do, so they have no limits and
# are free forever. power, braking, steering and grip change what you can
# DO, so each is bounded, and those bounds are the only thing standing
# between a described car and a car that drives through walls at mach one.

const DEFAULT_POWER := 900.0
const DEFAULT_BRAKING := 18.0
const DEFAULT_STEERING := 29.0      # degrees; the old MAX_STEER of 0.5 rad
const DEFAULT_GRIP := 9.0

const POWER := Vector2(400.0, 1800.0)
const BRAKING := Vector2(8.0, 30.0)
const STEERING := Vector2(20.0, 40.0)
const GRIP := Vector2(2.0, 20.0)

const PAINTS := {
	"red": Color(0.85, 0.20, 0.16),
	"blue": Color(0.20, 0.40, 0.80),
	"green": Color(0.20, 0.60, 0.30),
	"yellow": Color(0.90, 0.75, 0.15),
	"orange": Color(0.90, 0.50, 0.15),
	"white": Color(0.90, 0.90, 0.90),
	"black": Color(0.12, 0.12, 0.14),
	"silver": Color(0.65, 0.66, 0.70),
	"purple": Color(0.45, 0.25, 0.65),
}


func name() -> String:
	return "car"


func prompt_section() -> String:
	return """EQUIP car - the car the player drives
{"command": "EQUIP", "parameters": {"tool": "car", "intent": {"style": STYLE}, "spec": {"power": P, "braking": B, "steering": S, "grip": G, "paint": PAINT, "nickname": NAME}}}

power: %.0f to %.0f, how hard it accelerates (ordinary is %.0f)
braking: %.0f to %.0f, how hard it stops (ordinary is %.0f)
steering: %.0f to %.0f degrees of lock, how sharply it turns (ordinary is %.0f)
grip: %.0f to %.0f, how hard it is pressed into the road at speed (ordinary is %.0f)
paint: one of %s. nickname: a few words the player chose.
Every field may be left out and keeps its ordinary value. Change only what the player asked about: someone who wants "a car that stops better" wants braking changed and nothing else.
paint and nickname change nothing about how the car drives.""" % [
		POWER.x, POWER.y, DEFAULT_POWER,
		BRAKING.x, BRAKING.y, DEFAULT_BRAKING,
		STEERING.x, STEERING.y, DEFAULT_STEERING,
		GRIP.x, GRIP.y, DEFAULT_GRIP,
		", ".join(PAINTS.keys())]


func defaults() -> Dictionary:
	return {
		"power": DEFAULT_POWER,
		"braking": DEFAULT_BRAKING,
		"steering": DEFAULT_STEERING,
		"grip": DEFAULT_GRIP,
		"paint": "red",
		"nickname": "",
	}


func validate(parameters: Dictionary) -> Dictionary:
	var errors: Array = []
	var spec := defaults()
	var given = parameters.get("spec", {})
	if typeof(given) != TYPE_DICTIONARY:
		return {"ok": false, "errors": ["spec must be an object"], "spec": {}}

	var asked: Dictionary = given
	for key in asked:
		if not spec.has(key):
			errors.append("a car has no '%s' (it has %s)" % [str(key), ", ".join(spec.keys())])

	spec["power"] = _bounded(asked, "power", POWER, DEFAULT_POWER, errors)
	spec["braking"] = _bounded(asked, "braking", BRAKING, DEFAULT_BRAKING, errors)
	spec["steering"] = _bounded(asked, "steering", STEERING, DEFAULT_STEERING, errors)
	spec["grip"] = _bounded(asked, "grip", GRIP, DEFAULT_GRIP, errors)

	# Detailing: free, unlimited, and it changes nothing you can do.
	if asked.has("paint"):
		var paint := str(asked["paint"]).to_lower().strip_edges()
		if not PAINTS.has(paint):
			errors.append("'%s' is not a paint this game has (%s)" % [paint, ", ".join(PAINTS.keys())])
		else:
			spec["paint"] = paint
	if asked.has("nickname"):
		spec["nickname"] = str(asked["nickname"]).strip_edges().substr(0, 40)

	if not errors.is_empty():
		return {"ok": false, "errors": errors, "spec": {}}
	return {"ok": true, "errors": [], "spec": spec}


# A number inside its limits, or an error naming the limits. Out of range is
# refused rather than clamped: a player who asked for a car twice as fast as
# this game allows should be told so, not quietly given a slower one.
func _bounded(asked: Dictionary, key: String, limits: Vector2, fallback: float, errors: Array) -> float:
	if not asked.has(key):
		return fallback
	var value = asked[key]
	if typeof(value) != TYPE_FLOAT and typeof(value) != TYPE_INT:
		errors.append("%s must be a number" % key)
		return fallback
	var number := float(value)
	if number < limits.x or number > limits.y:
		errors.append("%s is %.0f, and a car's %s must be %.0f to %.0f" % [key, number, key, limits.x, limits.y])
		return fallback
	return number


# "a red car that accelerates hard and grips well"
#
# Said in the words a player would use, not in numbers: nobody asks for 1600
# power. Only what differs from ordinary is mentioned, so a car with one
# change reads as one change.
func readback(spec: Dictionary) -> String:
	var parts := PackedStringArray()
	parts.append(_compare(float(spec.get("power", DEFAULT_POWER)), DEFAULT_POWER, POWER,
		"accelerates hard", "is slow off the line"))
	parts.append(_compare(float(spec.get("braking", DEFAULT_BRAKING)), DEFAULT_BRAKING, BRAKING,
		"stops hard", "takes a long way to stop"))
	parts.append(_compare(float(spec.get("steering", DEFAULT_STEERING)), DEFAULT_STEERING, STEERING,
		"turns sharply", "turns lazily"))
	parts.append(_compare(float(spec.get("grip", DEFAULT_GRIP)), DEFAULT_GRIP, GRIP,
		"grips well", "slides about"))

	var said := PackedStringArray()
	for p in parts:
		if p != "":
			said.append(p)

	var paint := str(spec.get("paint", "red"))
	var nickname := str(spec.get("nickname", ""))
	var thing := "%s car" % paint
	if nickname != "":
		thing = "%s called %s" % [thing, nickname]

	if said.is_empty():
		return "the ordinary %s" % thing
	return "%s that %s" % [Readback.article(thing), Readback.join_list(said)]


# How one number differs from ordinary, in words. Within a tenth of the
# range either way counts as ordinary and is not mentioned at all.
func _compare(value: float, ordinary: float, limits: Vector2, more: String, less: String) -> String:
	var span := limits.y - limits.x
	var off := value - ordinary
	if absf(off) < span * 0.1:
		return ""
	return more if off > 0.0 else less
