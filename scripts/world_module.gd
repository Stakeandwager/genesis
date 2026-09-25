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

# The command that asks for this world, e.g. "CREATE_FARM".
func command() -> String:
	return ""


# A short name for people, e.g. "farm".
func display_name() -> String:
	return ""


# The rules given to the AI for this world: the vocabulary and its limits.
func prompt_section() -> String:
	return ""


# Check what the AI proposed. Returns ok, errors, content.
func validate(_parameters: Dictionary) -> Dictionary:
	return {"ok": false, "errors": ["this module has no validator"], "content": {}}


# Work out where everything goes, and whether it can work at all.
# Returns ok, category, reasons, layout.
func solve(_content: Dictionary) -> Dictionary:
	return {"ok": false, "category": "FAILED_LAYOUT", "reasons": ["this module has no solver"], "layout": {}}


# Measure the solved layout. Numbers only, no opinions.
func measure(_layout: Dictionary) -> Dictionary:
	return {}


# Build the geometry under the given node, and report its bounds.
func build(_root: Node3D, _layout: Dictionary) -> Dictionary:
	return {"bounds_min": Vector2.ZERO, "bounds_max": Vector2.ZERO}
