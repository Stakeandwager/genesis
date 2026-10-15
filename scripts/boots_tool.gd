extends ToolModule
class_name BootsTool

# --- 010: the boots as something you can ask for ---
#
# CarTool's sibling, and the proof the tool interface was never secretly about
# cars - the same argument the dungeon settled for worlds. Nothing in
# ToolRegistry, the AI's prompt, the validator or the readback changed to
# admit this. One file and one entry.
#
# 009 made walking a force on a mass against drag, which is what made this
# possible: there was nothing to specify while movement was three speeds
# switched on and off. Now every number has a unit and a consequence.
#
# FREE AND NOT FREE
# colour and nickname change nothing you can do, so they have no limits.
# push, weight, footing and turning change what you CAN do, so each is
# bounded - and so is what they add up to, which is the new part.

const DEFAULT_PUSH := 240.0          # newtons; 009's PUSH
const DEFAULT_WEIGHT := 80.0         # kg; 009's MASS
const DEFAULT_FOOTING := 0.67        # drag per second; 009's DRAG
const DEFAULT_TURNING := 24.0        # 009's TURN_PUSH
const DEFAULT_BRAKE := 400.0         # newtons the legs can apply to stop

# --- limits are a pair of 64-bit floats, not a Vector2 ---
# CarTool writes its limits as Vector2, whose components are 32-bit. That is
# harmless while every bound is a whole number, because those survive the
# narrowing exactly. 0.40 does not: as a 32-bit float it becomes
# 0.4000000059604645, so a spec asking for exactly the documented minimum was
# refused for being below it. The first run of boots_test.gd caught it.
#
# A two-element Array keeps full precision, so a bound means the number that
# is written here.
const PUSH := [120.0, 600.0]
const WEIGHT := [50.0, 140.0]
const FOOTING := [0.40, 1.50]
const TURNING := [12.0, 40.0]
const BRAKE := [150.0, 1200.0]

# --- the bound that is not on a field ---
# Every field above can be inside its limits while the three together are
# absurd: push 600 on a 50 kg body with 0.4 footing settles at 30 m/s, which
# is a car's pace on foot. So the CONSEQUENCE is bounded too.
#
# This is new. Every validator in Genesis until now checked the numbers it was
# given; this one checks the number they produce. A spec can be refused with
# every field legal, and the refusal says what the combination would do rather
# than pointing at a field, because no single field is at fault.
const TOP_SPEED := [2.0, 12.0]               # metres a second

# Running is a fixed multiple of walking, the way a car's reverse power keeps
# its ratio to engine power: nobody should have to ask for both.
const RUN_RATIO := 430.0 / 240.0

const COLOURS := {
	"brown": Color(0.42, 0.30, 0.20),
	"black": Color(0.14, 0.13, 0.15),
	"grey": Color(0.52, 0.52, 0.55),
	"tan": Color(0.76, 0.62, 0.42),
	"red": Color(0.72, 0.22, 0.18),
	"green": Color(0.25, 0.45, 0.28),
	"blue": Color(0.24, 0.38, 0.68),
	"white": Color(0.88, 0.88, 0.86),
}


func name() -> String:
	return "boots"


func prompt_section() -> String:
	return """EQUIP boots - what the player walks a dungeon in
{"command": "EQUIP", "parameters": {"tool": "boots", "intent": {"style": STYLE}, "spec": {"push": P, "weight": W, "footing": F, "turning": T, "colour": COLOUR, "nickname": NAME}}}

push: %.0f to %.0f newtons, how hard the legs push off (ordinary is %.0f)
weight: %.0f to %.0f kg, how heavy the body is (ordinary is %.0f)
footing: %.2f to %.2f, how quickly speed bleeds away - high stops sharply, low slides on (ordinary is %.2f)
turning: %.0f to %.0f, how quickly the body turns (ordinary is %.0f)
brake: %.0f to %.0f newtons, how hard the legs can stop you (ordinary is %.0f). This does NOT change top speed: someone who wants to "stop on a sixpence" wants brake raised and nothing else.
colour: one of %s. nickname: a few words the player chose.
Top speed is push divided by weight times footing, and must come to %.0f to %.0f metres a second. A spec where every field is legal but the three together are faster or slower than that is refused.
Every field may be left out and keeps its ordinary value. Change only what the player asked about: someone who wants "boots that stop on a sixpence" wants footing raised and nothing else.
colour and nickname change nothing about how the player moves.""" % [
		PUSH[0], PUSH[1], DEFAULT_PUSH,
		WEIGHT[0], WEIGHT[1], DEFAULT_WEIGHT,
		FOOTING[0], FOOTING[1], DEFAULT_FOOTING,
		TURNING[0], TURNING[1], DEFAULT_TURNING,
		BRAKE[0], BRAKE[1], DEFAULT_BRAKE,
		", ".join(COLOURS.keys()),
		TOP_SPEED[0], TOP_SPEED[1]]


# The only tool whose name is plural, so the only one that overrides this.
func has_phrase() -> String:
	return "boots have"


func defaults() -> Dictionary:
	return {
		"push": DEFAULT_PUSH,
		"weight": DEFAULT_WEIGHT,
		"footing": DEFAULT_FOOTING,
		"turning": DEFAULT_TURNING,
		"brake": DEFAULT_BRAKE,
		"colour": "brown",
		"nickname": "",
	}


# What a spec comes to, in metres a second. The one piece of arithmetic that
# matters, kept in a function so the validator, the prompt and the readback
# cannot disagree about it - the rule around_of() and _wall_rects() exist for.
static func top_speed(spec: Dictionary) -> float:
	var push := float(spec.get("push", DEFAULT_PUSH))
	var weight := float(spec.get("weight", DEFAULT_WEIGHT))
	var footing := float(spec.get("footing", DEFAULT_FOOTING))
	if weight <= 0.0 or footing <= 0.0:
		return 0.0
	return push / (weight * footing)


# --- 013: what this spec SHOULD do, worked out before anything moves ---
#
# The model is named, because a prediction without one is arithmetic about
# nothing. A body slowing with no input is losing speed two ways at once:
#
#     dv/dt = -(b + k*v)        b = brake / weight,  k = footing
#
# a constant braking force the legs apply, and drag that grows with speed.
# Solving it gives the distance exactly:
#
#     d = v/k - (b / k^2) * ln(1 + k*v / b)
#
# As drag goes to nothing this becomes d = v^2 / (2*b), the schoolbook
# constant-deceleration formula - which is the special case, not the model.
#
# This lives here rather than in a test for the reason around_of() and
# _wall_rects() exist: the thing that predicts and the thing that acts must
# read from one place, or the test measures a promise nobody made.
static func stopping_distance(spec: Dictionary, from_speed: float) -> float:
	var b := braking(spec)
	var k := float(spec.get("footing", DEFAULT_FOOTING))
	if from_speed <= 0.0 or b <= 0.0:
		return 0.0
	if k <= 0.0:
		return from_speed * from_speed / (2.0 * b)
	return from_speed / k - (b / (k * k)) * log(1.0 + k * from_speed / b)


# How hard this spec slows down, in metres a second per second. Mass is here
# and not in the drag term, which is the whole point: the legs apply a force,
# so a heavier body takes longer to stop.
static func braking(spec: Dictionary) -> float:
	var weight := float(spec.get("weight", DEFAULT_WEIGHT))
	if weight <= 0.0:
		return 0.0
	return float(spec.get("brake", DEFAULT_BRAKE)) / weight


func validate(parameters: Dictionary) -> Dictionary:
	var errors: Array = []
	var spec := defaults()
	var given = parameters.get("spec", {})
	if typeof(given) != TYPE_DICTIONARY:
		return {"ok": false, "errors": [spec_error()], "spec": {}}

	var asked: Dictionary = given
	for key in asked:
		if not spec.has(key):
			errors.append("boots have no '%s' (they have %s)" % [str(key), ", ".join(spec.keys())])

	spec["push"] = _bounded(asked, "push", PUSH, DEFAULT_PUSH, errors)
	spec["weight"] = _bounded(asked, "weight", WEIGHT, DEFAULT_WEIGHT, errors)
	spec["footing"] = _bounded(asked, "footing", FOOTING, DEFAULT_FOOTING, errors)
	spec["turning"] = _bounded(asked, "turning", TURNING, DEFAULT_TURNING, errors)
	spec["brake"] = _bounded(asked, "brake", BRAKE, DEFAULT_BRAKE, errors)

	if asked.has("colour"):
		var colour := str(asked["colour"]).to_lower().strip_edges()
		if not COLOURS.has(colour):
			errors.append("'%s' is not a colour this game has (%s)" % [colour, ", ".join(COLOURS.keys())])
		else:
			spec["colour"] = colour
	if asked.has("nickname"):
		spec["nickname"] = str(asked["nickname"]).strip_edges().substr(0, 40)

	# The consequence, checked only once the fields themselves are sound: a
	# body that is already being refused for a bad number does not also need
	# telling what that bad number would have done.
	if errors.is_empty():
		var reached := top_speed(spec)
		if reached < float(TOP_SPEED[0]) or reached > float(TOP_SPEED[1]):
			errors.append("those boots would carry you at %.1f m/s, and a body's top speed must be %.0f to %.0f (push %.0f, weight %.0f, footing %.2f)" % [
				reached, TOP_SPEED[0], TOP_SPEED[1],
				float(spec["push"]), float(spec["weight"]), float(spec["footing"])])

	if not errors.is_empty():
		return {"ok": false, "errors": errors, "spec": {}}
	return {"ok": true, "errors": [], "spec": spec}


# Both refusals name the bound. See the note on CarTool._bounded and TRAPS 21:
# until 030 the not-a-number branch said bare "push must be a number" while
# the range branch two lines down named 120 to 600, from the same `limits`.
# The type question belongs to Readback.as_number(), so all five validators
# answer it in one place rather than in five.
func _bounded(asked: Dictionary, key: String, limits: Array, fallback: float, errors: Array) -> float:
	if not asked.has(key):
		return fallback
	var number := Readback.as_number(asked[key])
	if is_nan(number):
		errors.append("%s must be a number, %s to %s" % [
			key, _tidy(float(limits[0])), _tidy(float(limits[1]))])
		return fallback
	if number < float(limits[0]) or number > float(limits[1]):
		errors.append("%s is %s, and boots' %s must be %s to %s" % [
			key, _tidy(number), key, _tidy(float(limits[0])), _tidy(float(limits[1]))])
		return fallback
	return number


func _tidy(value: float) -> String:
	return "%.2f" % value if absf(value) < 10.0 else "%.0f" % value


# "brown boots that stop sharply, though they only walk at 2.5 m/s"
#
# In the words a player would use. Nobody asks for 0.67 footing. Only what
# differs from ordinary is mentioned.
#
# --- 011: the readback says what it costs ---
# "give me boots that stop on a sixpence" became footing 1.2, which is right,
# and the readback said "stop sharply", which was true and incomplete: raising
# footing also drops the walk from 4.5 m/s to 2.5, because top speed is
# push / (weight * footing) and footing does both jobs. The player asked for
# one thing and got two, and was told about one.
#
# A readback that describes half of what Genesis is about to do is worse than
# none: it teaches a player to trust a line that is not the whole truth. So
# when a spec moves the walking pace noticeably, the pace is said in the same
# sentence - not in a separate line afterwards, in numbers, which is the part
# a player skims.
#
# Said as a cost ("though") when it is slower and plainly when it is faster,
# because the one that needs catching is the one nobody asked for.
func readback(spec: Dictionary) -> String:
	var parts := PackedStringArray()
	parts.append(_compare(float(spec.get("push", DEFAULT_PUSH)), DEFAULT_PUSH, PUSH,
		"get you moving quickly", "are heavy going"))
	parts.append(_compare(float(spec.get("weight", DEFAULT_WEIGHT)), DEFAULT_WEIGHT, WEIGHT,
		"weigh you down", "leave you light on your feet"))
	parts.append(_compare(float(spec.get("footing", DEFAULT_FOOTING)), DEFAULT_FOOTING, FOOTING,
		"stop sharply", "slide on after you stop pushing"))
	parts.append(_compare(float(spec.get("turning", DEFAULT_TURNING)), DEFAULT_TURNING, TURNING,
		"turn on the spot", "come round slowly"))
	parts.append(_compare(float(spec.get("brake", DEFAULT_BRAKE)), DEFAULT_BRAKE, BRAKE,
		"pull you up short", "take a while to pull up"))

	var said := PackedStringArray()
	for p in parts:
		if p != "":
			said.append(p)

	var colour := str(spec.get("colour", "brown"))
	var nickname := str(spec.get("nickname", ""))
	var thing := "%s boots" % colour
	if nickname != "":
		thing = "%s called %s" % [thing, nickname]

	var pace := _pace(spec)
	if said.is_empty():
		return "the ordinary %s" % thing if pace == "" else "%s, %s" % [thing, pace]
	return "%s that %s%s" % [thing, Readback.join_list(said), pace]


# What this spec does to the walking pace, in the same sentence or not at all.
# Within a tenth of ordinary either way is not worth a player's attention.
func _pace(spec: Dictionary) -> String:
	var ordinary := top_speed(defaults())
	var reached := top_speed(spec)
	if ordinary <= 0.0 or absf(reached - ordinary) < ordinary * 0.1:
		return ""
	if reached < ordinary:
		return ", though they only walk at %.1f m/s" % reached
	return ", and walk at %.1f m/s" % reached


func _compare(value: float, ordinary: float, limits: Array, more: String, less: String) -> String:
	var span := float(limits[1]) - float(limits[0])
	var off := value - ordinary
	if absf(off) < span * 0.1:
		return ""
	return more if off > 0.0 else less


func summary(spec: Dictionary) -> String:
	var walk := top_speed(spec)
	return "Boots on. %.1f m/s at a walk, stopping in %.2f m from there." % [
		walk, stopping_distance(spec, walk)]
