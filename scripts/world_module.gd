extends RefCounted
class_name WorldModule

# --- The world module interface ---
# A world module is one kind of place the game knows how to make: a racing
# circuit, a farm, a market. The shell around it never changes.
#
# Every module follows the same division of labour, the one that racing
# proved:
#   the AI proposes WHAT is in the place,
#   the module works out WHERE everything goes,
#   the module validates the result,
#   the module measures it,
#   and only then is anything built.
#
# A module declares its own vocabulary, so adding a kind of world costs one
# file and one registry entry. Nothing else in the game changes.
#
# --- 002F: optional steps ---
# The game controller runs every world through the same steps, in this order:
#   record_fields -> validate -> pre_check -> solve -> solve_record
#   -> (correction_feedback, only if solving failed) -> post_check
#   -> measure -> build -> summary
# Only command, display_name, prompt_section, validate, solve, measure and
# build are required. The others have defaults that do nothing, so a simple
# world like the farm can ignore them; racing uses them for its feasibility
# gate, closure feedback and separation check.

# The command that asks for this world, e.g. "CREATE_FARM".
func command() -> String:
	return ""


# A short name for people, e.g. "farm".
func display_name() -> String:
	return ""


# The rules given to the AI for this world: the vocabulary and its limits.
# An empty string adds nothing to the AI's instructions.
func prompt_section() -> String:
	return ""


# What this world adds to its log record before any checking: what was
# proposed, in the module's own field names. They follow time, request,
# raw_command, source and experiment, in the order given here.
# attempt is {"attempt": 1}, or {"attempt": 2, "revision_of": {...}}.
func record_fields(parameters: Dictionary, _attempt: Dictionary) -> Dictionary:
	var intent = parameters.get("intent", {})
	return {
		"world": display_name(),
		"intent": intent if typeof(intent) == TYPE_DICTIONARY else {},
		"command": command(),
	}


# Check what the AI proposed. Returns ok, errors, content.
func validate(_parameters: Dictionary) -> Dictionary:
	return {"ok": false, "errors": ["this module has no validator"], "content": {}}


# A check between validating and solving, for designs that can be refused
# before any work is done. It may write measurements into the record.
# Returns ok, category, reasons, and content (passed on to solve).
func pre_check(content: Dictionary, _record: Dictionary) -> Dictionary:
	return {"ok": true, "category": "", "reasons": [], "content": content}


# Work out where everything goes, and whether it can work at all.
# Returns ok, category, reasons, layout.
func solve(_content: Dictionary) -> Dictionary:
	return {"ok": false, "category": "FAILED_LAYOUT", "reasons": ["this module has no solver"], "layout": {}}


# Fields the solver's result adds to the record, whether it succeeded or not.
func solve_record(_solved: Dictionary) -> Dictionary:
	return {}


# When solving failed, what to tell the AI so it can correct its design once.
# An empty string means this failure cannot be corrected by asking again.
# The controller decides whether a correction is allowed at all (AI designs
# only, first attempts only, never inside a plan, and /revise on).
func correction_feedback(_solved: Dictionary) -> String:
	return ""


# A check on the solved layout before it is measured and built.
# Returns ok, category, reasons, and record: fields to add to the record,
# written whether the check passes or not.
func post_check(_layout: Dictionary) -> Dictionary:
	return {"ok": true, "category": "", "reasons": [], "record": {}}


# Measure the solved layout. Numbers only, no opinions.
func measure(_layout: Dictionary) -> Dictionary:
	return {}


# Build the geometry under the given node, and report its bounds.
# A world a car can drive on also reports "drivable": {"node": N,
# "road_height": metres}, where N has built, centreline, start_position and
# start_heading in its own coordinates (CircuitBuilder does). The controller
# converts them to world space for driving and racing.
func build(_root: Node3D, _layout: Dictionary) -> Dictionary:
	return {"bounds_min": Vector2.ZERO, "bounds_max": Vector2.ZERO}


# What the player is told once the world is built.
# metrics is what measure() returned; report is what build() returned.
func summary(_metrics: Dictionary, _report: Dictionary) -> String:
	return "%s built\n(full measurements in the panel)" % display_name().capitalize()


# --- 003: how big this world is, before it is built ---
# Its size on the ground, in metres, worked out from the solved layout. A
# plan needs every world's size before it builds the first one: a world asked
# to contain another cannot know how much room to leave until the thing going
# inside it has been measured.
func extent(_layout: Dictionary) -> Vector2:
	return Vector2.ZERO


# Make this world at least this big, keeping everything the AI asked for the
# size it asked for. A world grows by putting more ground around what it
# holds, never by stretching it: the farm's fields stay the size the player
# asked for and the dungeon's rooms stay where they were put.
#
# This is the rule that lets a player say "a race track in a farm" without
# knowing that the farm comes out 430 m across. They describe the
# relationship; Genesis solves the geometry.
#
# It is written once, here, so it holds for every world there will ever be. A
# new world gets it by doing two things: returning its size from extent(),
# and running its own outer bounds through grown() when it draws them. It
# opts out by overriding can_grow().
func grow_to(layout: Dictionary, size: Vector2) -> bool:
	if not can_grow():
		return false
	var wanted: Vector2 = layout.get("min_extent", Vector2.ZERO)
	layout["min_extent"] = Vector2(maxf(wanted.x, size.x), maxf(wanted.y, size.y))
	return true


# Can more ground be put around this world without changing what it is?
# True for anything laid out inside a boundary. False where the shape itself
# is the design: a circuit's straights are the lengths the player asked for,
# so stretching it to fit round something else would quietly give them a
# different track from the one they described.
func can_grow() -> bool:
	return true


# A world's outer bounds, pushed out if a plan asked it to hold something.
# Growth is about the middle, so whatever sits inside stays centred in it.
# Every world that can grow runs its own bounds through this, which is what
# keeps one rule in one place instead of a copy per world.
func grown(low: Vector2, high: Vector2, layout: Dictionary) -> Array:
	var wanted: Vector2 = layout.get("min_extent", Vector2.ZERO)
	var size := high - low
	var out := Vector2(maxf(size.x, wanted.x), maxf(size.y, wanted.y))
	if out.is_equal_approx(size):
		return [low, high]
	var middle := (low + high) * 0.5
	return [middle - out * 0.5, middle + out * 0.5]


# --- 003: what Genesis understood ---
# This world's command, said back to the player in plain English, as a noun
# phrase that fits after "I understand: you want ...".
#
# It is built from the parameters, NOT from what the player typed, so that a
# dropped word shows up as a line that does not match what was asked. It is
# written before anything is validated, so it must cope with parameters that
# turn out to be nonsense: it describes what was proposed, not what is legal.
#
# Say the things players actually get misunderstood on - how many, how big,
# what is joined to what - and not the things nobody mishears.
func readback(_parameters: Dictionary) -> String:
	return Readback.article(display_name())


# The same world in a few words, for a plan. A plan's meaning is mostly how
# its worlds are related, and a line long enough to bury the relationship at
# the end is a line nobody reads to the end of.
func readback_short(_parameters: Dictionary) -> String:
	return Readback.article(display_name())


# --- 002I: each world writes its own metrics panel ---
# How this world's measurements are shown, as [label, value] pairs in the
# order they appear. An empty label prints the value on its own, in the
# label colour, for a note rather than a measurement.
#
# metrics is what measure() returned. record is the whole log record, so a
# world can also show what its own checks found (racing shows its closure
# error and separation, which are not measurements of the built track but of
# how it came to be built).
#
# Before this, main.gd knew which keys each world measured and guessed the
# world from them. A world that measured neither sections nor zones fell
# through and crashed the panel. Now a world that returns nothing here shows
# nothing, and a new world needs no edit outside its own file.
func metric_lines(_metrics: Dictionary, _record: Dictionary) -> Array:
	return []
