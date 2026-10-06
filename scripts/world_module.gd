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
