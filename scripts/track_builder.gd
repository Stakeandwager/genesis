extends Node3D
class_name TrackBuilder

const SEGMENT_WIDTH := 12.0
const SEGMENT_THICKNESS := 0.5

var corner_nodes: Array[Node3D] = []

# --- 032: the same false line, in the other Prototype 001 builder ---
# 002B took 148 lines out of this file and left the signatures and their
# return strings. This built four corners and said so; it now builds nothing
# and said so anyway. corner_nodes is declared, cleared and read, and
# appended to NOWHERE in the repository, so has_track() below can never be
# true - which is also why SPAWN_OPPONENTS can never run.
#
# Measured, Godot 4.7.1 headless: after build({"corners": 4}) this node has 0
# children, corner_nodes is empty and has_track() is false.
#
# NOT fixed here, and recorded in HANDOVER instead: this still clear()s
# first, so a sectionless CREATE_TRACK takes the player's world away and
# then reports that it built nothing. Changing that is a change to what
# Genesis DOES rather than to what it says, on a Prototype 001 path the
# owner may be about to delete, so it is his call and not this commit's.
func build(parameters: Dictionary) -> String:
	clear()
	var corners: int = int(parameters.get("corners", 4))
	if corner_nodes.is_empty():
		# The asked-for count is deliberately NOT in this line. stub_claims_test
		# refuses any line that names a number of corners the build did not
		# produce, and the first draft of this sentence said "a ring of 4
		# corners is not built any more" - true, and still a 4 next to a
		# CREATE_TRACK in the player's log.
		return "CREATE_TRACK built nothing: a Prototype 001 ring is not built any more (describe a circuit's sections instead)"
	return "CREATE_TRACK corners=%d" % corners

# --- 032: what MODIFY_TRACK was understood to ask for ---
# The other command with no readback at all. Both fields are named, read by
# the same two keys game_controller._modify_track reads ("corner" and
# "difficulty"), so corner 1 made hard and corner 3 made easy no longer read
# back as the same sentence - which, until 032, they did: "a modify_track".
#
# Interpretation only, as with OpponentBuilder.readback: modify_corner() below
# changes nothing in the world, and that is recorded in HANDOVER rather than
# implied away here. A field that was not given is left out rather than filled
# in from the handler's default (trap 8).
static func readback(parameters: Dictionary) -> String:
	var corner := Readback.as_number(parameters.get("corner", null))
	var named := "a corner" if is_nan(corner) or corner < 1.0 else "corner %d" % int(corner)
	var difficulty := str(parameters.get("difficulty", "")).to_lower().strip_edges()
	if difficulty == "":
		return "to change %s" % named
	return "to make %s %s" % [named, difficulty]


# This one a player can actually reach. game_controller._modify_track calls
# it whenever there is no composed circuit, and it reported that it had made
# corner 2 hard without touching anything at all - 0 children before and 0
# after, measured headless.
func modify_corner(corner_index: int, difficulty: String) -> String:
	if corner_nodes.is_empty():
		return "MODIFY_TRACK changed nothing: there is no Prototype 001 ring to change (a composed circuit's sections are described in the request)"
	return "MODIFY_TRACK corner=%d difficulty=%s" % [corner_index, difficulty]

func clear() -> void:
	for child in get_children():
		child.queue_free()
	corner_nodes.clear()

func has_track() -> bool:
	return not corner_nodes.is_empty()

func get_start_position() -> Vector3:
	if corner_nodes.is_empty():
		return Vector3.ZERO
	return corner_nodes[0].position

func get_start_direction() -> Vector3:
	if corner_nodes.size() < 2:
		return Vector3.FORWARD
	return (corner_nodes[1].position - corner_nodes[0].position).normalized()
