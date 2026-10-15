extends RefCounted
class_name ToolModule

# --- 004: the things a world hands you to use ---
# A world is a place. A tool is what you work it with: the car you drive
# round a circuit, the tractor you work a farm with, whatever a dungeon
# eventually asks for.
#
# This is WorldModule's sibling, deliberately. A tool is described in words,
# read by the AI, checked by a validator and applied by Godot, and it goes
# through exactly the same wall: a spec the AI invents is worth no more than
# one typed by hand, and both are refused the same way. Nothing here gives
# the AI a new power. It gives the player a new thing to describe.
#
#   name              "car", "tractor"
#   prompt_section    what may be asked for, and the limits
#   validate          a spec inside those limits, or refused with reasons
#   readback          the spec said back in plain English
#   defaults          what you get for free, having asked for nothing
#
# WHAT IS FREE AND WHAT IS NOT
# Every tool has a default that costs nothing and always works: the regular
# car, the regular tractor. Detailing is free too, because a name and a
# colour change nothing about what you can do. What a tool can DO is the
# part with limits on it, and the part that could one day be bought. The
# validator already knows which is which, because capability is a number it
# bounds and a paint colour is not.
#
# There is no money here, no ownership and no trading. Those need accounts
# and a server that Genesis does not have. This is the layer underneath all
# of that: making the thing you use describable instead of hard-coded.


# What the player calls it.
func name() -> String:
	return ""


# What the AI is told it may ask for, including every limit. Empty means
# this tool cannot be asked for in words.
func prompt_section() -> String:
	return ""


# Check a proposed spec. Returns ok, errors and a clean spec with every
# missing field filled in from defaults, so what comes out is always
# complete and always inside the limits.
func validate(_parameters: Dictionary) -> Dictionary:
	return {"ok": false, "errors": ["this tool has no validator"], "spec": {}}


# What you get having asked for nothing. Always valid, always free.
func defaults() -> Dictionary:
	return {}


# --- 034: the spec door, which is the list door in its object flavour ---
#
# All three tools refused a spec that was not an object with four words -
# "spec must be an object" - naming none of the fields a spec may hold,
# three lines above a refusal for an UNKNOWN field that lists every one of
# them. One function, two refusals, one of them helpful: TRAPS 11 inside a
# single file, and the same shape as the six list doors 034 fixed.
#
# Both now read defaults(), which is the one place that knows what a tool
# has, so a field added to a tool appears in both sentences for free.
# A tool says "a car has" or "boots have" about itself; only the plural
# needs overriding.
func has_phrase() -> String:
	return "%s has" % Readback.article(name())


func fields_line() -> String:
	return "%s %s" % [has_phrase(), ", ".join(defaults().keys())]


func spec_error() -> String:
	return "'spec' must be an object (%s)" % fields_line()


# The spec in plain English, for the readback. Built from the spec, never
# from what the player typed, for the same reason a world's readback is.
func readback(_spec: Dictionary) -> String:
	return Readback.article(name())


# One line for the player once it is theirs.
func summary(_spec: Dictionary) -> String:
	return "%s ready." % name().capitalize()
