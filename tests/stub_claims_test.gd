extends SceneTree

# 032 - what a builder reports must match what it built.
#
# THE FAULT THIS SUITE WAS WRITTEN FOR
#
# Found while asking whether every command the whitelist allows reads back
# (plan_said_test). Two of them had no readback at all, and the reason turned
# out to be worse than the readback: they do nothing, and they said they had.
#
# 002B removed Prototype 001's track and opponents - 89 lines out of
# opponent_builder.gd, 148 out of track_builder.gd - and left the function
# SIGNATURES and their RETURN STRINGS in place. So, measured headless on the
# code before 032:
#
#   OpponentBuilder.spawn(8, ...)        "SPAWN_OPPONENTS count=8"
#                                        0 children, opponents.size() == 0
#   TrackBuilder.build({"corners": 4})   "CREATE_TRACK corners=4"
#                                        0 children, has_track() false
#   TrackBuilder.modify_corner(2, "hard") "MODIFY_TRACK corner=2 difficulty=hard"
#                                        0 children before, 0 after
#
# Those strings go straight to log_message.emit(), so they are what a player
# is shown. Each is a construction-layer claim with no measurement behind it,
# in a project whose first rule is that missing evidence must not become
# success and whose standing example is that a carrier's claim is evidence of
# an attempt and never of delivery. Nothing was looking, because nothing
# described these commands at all.
#
# WHAT IS ASSERTED, AND WHY IT IS A FACT AND NOT A WORDING (TRAPS 14)
#
# Not "the line contains the words built nothing" - that is a wording, and a
# test for it passes on a line that is false in different words. What is
# asserted is the TIE between the sentence and the measurement:
#
#   if nothing was placed, the reported line must not state the number that
#   was asked for.
#
# So the line may be rephrased freely and this suite stays green; it fails
# the moment a function reports a count of things it did not place. And if
# Prototype 001's ring is ever rebuilt, these functions start placing nodes,
# the measurement changes, and the suite requires the line to change with it -
# in either direction.
#
# WHAT WAS A FINDING AND WHAT IS A GUARD (TRAPS 6)
#
# All three of the first group FAILED against the code before 032. The
# dead-reckoning checks below (that corner_nodes is never filled, so
# has_track() cannot be true) are GUARDS: they have always passed, and they
# are here because they are the reason SPAWN_OPPONENTS can never run, which
# is a fact the owner's decision in HANDOVER turns on.

var bad := 0
var asserted := 0


func _check(ok: bool, what: String) -> void:
	asserted += 1
	print(("PASS  " if ok else "FAIL  ") + what)
	if not ok:
		bad += 1


func _initialize() -> void:
	_opponents()
	_ring()
	_corner()
	print("STUB CLAIMS %d assertions, failures=%d" % [asserted, bad])
	quit(bad)


# --- SPAWN_OPPONENTS reports no count it did not place ---
func _opponents() -> void:
	var builder := OpponentBuilder.new()
	get_root().add_child(builder)

	var asked := 8
	var said := builder.spawn(asked, Vector3.ZERO, Vector3.FORWARD)
	var placed := builder.opponents.size()

	_check(said != "", "spawn says something")
	_check(placed == builder.get_child_count(),
		"what spawn placed is what is in the scene (%d)" % placed)
	if placed == 0:
		_check(not said.contains(str(asked)),
			"spawn placed nothing, so its line does not state %d: \"%s\"" % [asked, said])
	else:
		_check(said.contains(str(placed)),
			"spawn placed %d, so its line states it" % placed)

	builder.queue_free()


# --- CREATE_TRACK's Prototype 001 ring reports no corners it did not build ---
func _ring() -> void:
	var builder := TrackBuilder.new()
	get_root().add_child(builder)

	var asked := 4
	var said := builder.build({"corners": asked})
	var built := builder.corner_nodes.size()

	_check(said != "", "build says something")
	if built == 0:
		_check(not said.contains(str(asked)),
			"build built nothing, so its line does not state %d corners: \"%s\"" % [asked, said])
		_check(not builder.has_track(),
			"and has_track() is false, so SPAWN_OPPONENTS cannot be reached at all")
	else:
		_check(said.contains(str(built)),
			"build built %d corners, so its line states it" % built)
		_check(builder.has_track(), "and has_track() agrees")

	# The guard the owner's decision turns on: nothing in the repository ever
	# fills corner_nodes, which is why both commands above are unreachable or
	# inert. Asserted as a measurement rather than as a grep.
	_check(builder.corner_nodes.is_empty(),
		"nothing fills corner_nodes, before or after a build")

	builder.queue_free()


# --- MODIFY_TRACK reports no change it did not make ---
func _corner() -> void:
	var builder := TrackBuilder.new()
	get_root().add_child(builder)

	var before := builder.get_child_count()
	var said := builder.modify_corner(2, "hard")
	var after := builder.get_child_count()

	_check(said != "", "modify_corner says something")
	_check(before == after, "modify_corner changed nothing in the scene")
	if before == after and builder.corner_nodes.is_empty():
		# It changed nothing, so it must not name the corner it did not
		# change. "2" is the corner asked for.
		_check(not said.contains("corner=2"),
			"so its line does not report corner 2 as changed: \"%s\"" % said)

	builder.queue_free()
