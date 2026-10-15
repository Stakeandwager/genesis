extends Node3D
class_name OpponentBuilder

var opponents: Array[Node3D] = []


# --- 032: what SPAWN_OPPONENTS was understood to ask for ---
# This command had NO readback at all, at either layer: WorldRegistry.readback
# returned the empty string for it, and inside a plan it printed the raw JSON
# token, "a spawn_opponents". Eight opponents and two read back identically.
# Measured headless, not inferred; see HANDOVER 032.
#
# It lives here, beside the handler's field, so the sentence and the code that
# reads "count" cannot drift apart - the rule around_of() exists for.
#
# This is the INTERPRETATION layer and says only what was asked. It promises
# nothing about construction: SPAWN_OPPONENTS cannot currently put a single
# car on a track (TrackBuilder.corner_nodes is never filled, so has_track() is
# always false), and that is recorded under "Human decision needed" rather
# than papered over here. A readback that described the request as a result
# would be the four layers merged, which is the one thing they are kept apart
# for.
#
# A count that was not given is NOT filled in from the handler's default of 1:
# a readback describing the defaults instead of the request is trap 8.
static func readback(parameters: Dictionary) -> String:
	var asked := Readback.as_number(parameters.get("count", null))
	if is_nan(asked) or asked < 1.0:
		return "to put opponents on the track"
	return "to put %s on the track" % Readback.count_of(int(asked), "opponent")


# --- 032: a line that reported eight cars it had not placed ---
# 002B took 89 lines out of this file - MAX_OPPONENTS, the colours, the
# staggered grid, _build_vehicle - and left the SIGNATURE and the RETURN
# STRING behind. So this placed nothing and said "SPAWN_OPPONENTS count=8",
# which is a construction-layer claim with no measurement behind it, in a
# project whose first rule is that missing evidence must not become success.
#
# Measured, Godot 4.7.1 headless: after spawn(8, ...) this node has 0
# children and opponents.size() is 0. Nothing is removed and nothing is
# built here - the line now says what happened, which is nothing. Whether
# Prototype 001's grid should come back or SPAWN_OPPONENTS should leave the
# whitelist is the owner's, and is written into HANDOVER.
#
# In practice game_controller never reaches this: _spawn_opponents guards on
# TrackBuilder.has_track(), which cannot be true (see track_builder.gd). It is
# corrected anyway, because a guard somewhere else is not a reason for a
# function to lie about itself, and the guard could be lifted by the commit
# that rebuilds the ring.
func spawn(count: int, _start_position: Vector3, _direction: Vector3) -> String:
	clear()
	if opponents.is_empty():
		return "SPAWN_OPPONENTS built nothing: no opponent is placed on a Prototype 001 ring (a composed circuit brings its own grid)"
	return "SPAWN_OPPONENTS count=%d" % count

func clear() -> void:
	for child in get_children():
		child.queue_free()
	opponents.clear()
