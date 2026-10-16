extends SceneTree

# 048 - the world on its way out was counted as part of the world coming in.
#
# FROM THE OWNER'S MACHINE, 2026-10-16. A dungeon of four rooms, live key,
# real hardware:
#
#   READBACK: a dungeon of four rooms joined by four doors ...
#   Controller: CREATE_DUNGEON built 14 rooms joined by 4 doors, 1 way back
#   96 m of corridor, deepest room 2 doors in
#
# Everything in that sentence was right except the first number. The ten extra
# were the starter circuit Main puts in the world so there is something to
# drive before anything has been asked for, queue_free()d in the same frame
# the dungeon was added.
#
# WHY THE SUITE COULD NOT SEE IT, which is the whole reason this file exists.
# Every other test builds into a FRESH holder. There is never an outgoing
# world, because the starter circuit only exists in the running game. So the
# fixture was the bug: a count of "what is under this node" was only ever
# asked on a node with nothing else under it, and six commits earlier 046
# moved the player-facing sentence onto that count on the strength of "the two
# agree on every dungeon measured so far".
#
# They did agree. In a harness that could not disagree.
#
# So this suite does the one thing the others do not: it puts a world there
# FIRST, clears it the way the controller clears it, and only then builds.

var bad := 0


func _check(ok: bool, what: String) -> void:
	print(("PASS  " if ok else "FAIL  ") + what)
	if not ok:
		bad += 1


# A holder of marked pieces, as every builder leaves one.
func _a_world(parent: Node, holder_name: String, pieces: int) -> Node3D:
	var holder := Node3D.new()
	holder.name = holder_name
	parent.add_child(holder)
	for i in pieces:
		var piece := Node3D.new()
		piece.name = "%s_piece_%d" % [holder_name, i]
		WorldModule.mark_piece(piece)
		holder.add_child(piece)
	return holder


func _initialize() -> void:
	_the_owners_fourteen()
	_the_flag_is_only_on_the_node_it_was_called_on()
	_nested_deeper_than_one_level()
	_a_world_that_is_not_going_anywhere_still_counts()
	_the_sentence_a_player_reads()

	print("OUTGOING WORLD failures=%d" % bad)
	quit(1 if bad > 0 else 0)


# --- the owner's case, to the number ---
func _the_owners_fourteen() -> void:
	var world := Node3D.new()
	get_root().add_child(world)

	# The starter circuit: ten road pieces in a holder.
	_a_world(world, "StarterCircuit", 10)
	_check(WorldModule.placed_pieces(world) == 10, "the starter circuit is there, and counts")

	# _clear_world_node(): queue_free on the direct children.
	for child in world.get_children():
		child.queue_free()

	# build(): the new world, same frame.
	_a_world(world, "Dungeon", 4)

	var counted := WorldModule.placed_pieces(world)
	_check(counted == 4, "four rooms are counted as four, not %d" % counted)
	_check(counted != 14, "and specifically not the owner's 14")
	world.queue_free()


# --- the mistake underneath it ---
#
# Worth asserting on its own, because the comment that got this wrong was not
# careless: it named the right hazard and assumed queue_free() marked the
# subtree. It does not, and that is a fact about Godot rather than about
# Genesis, so it is pinned here where the next person will see it.
func _the_flag_is_only_on_the_node_it_was_called_on() -> void:
	var world := Node3D.new()
	get_root().add_child(world)
	var holder := _a_world(world, "Outgoing", 3)
	holder.queue_free()

	_check(holder.is_queued_for_deletion(), "the holder knows it is going")
	_check(not holder.get_child(0).is_queued_for_deletion(),
		"its children do NOT: queue_free marks one node, never the subtree")
	_check(WorldModule.placed_pieces(world) == 0,
		"so the count has to stop at the holder, and does")
	world.queue_free()


# --- a holder inside a holder, which a PLAN makes ---
func _nested_deeper_than_one_level() -> void:
	var world := Node3D.new()
	get_root().add_child(world)
	var outer := Node3D.new()
	outer.name = "Plan"
	world.add_child(outer)
	_a_world(outer, "Farm", 6)
	_a_world(outer, "Circuit", 8)
	_check(WorldModule.placed_pieces(world) == 14, "a plan of two worlds counts both: 14")

	outer.queue_free()
	_check(WorldModule.placed_pieces(world) == 0,
		"and freeing the plan removes all 14, two levels down")
	world.queue_free()


# --- the direction that must not break ---
#
# A count that returns 0 for everything would pass every assertion above. The
# point of reading the tree instead of the request (046) is that a builder
# which places fewer pieces than the layout declares says the smaller number.
func _a_world_that_is_not_going_anywhere_still_counts() -> void:
	var world := Node3D.new()
	get_root().add_child(world)
	var holder := _a_world(world, "Dungeon", 4)
	_check(WorldModule.placed_pieces(world) == 4, "a standing world counts its pieces")

	# One piece lost: the sentence must say three, not four.
	holder.get_child(0).queue_free()
	_check(WorldModule.placed_pieces(world) == 3,
		"and a piece that failed to stand is missing from the count, which is why this is read from the tree at all")
	world.queue_free()


# --- and the sentence itself, on a real dungeon ---
func _the_sentence_a_player_reads() -> void:
	var module := DungeonModule.new()
	var checked: Dictionary = module.validate({
		"rooms": [
			{"name": "entrance", "width": 10, "depth": 10},
			{"name": "store", "width": 10, "depth": 10},
			{"name": "vault", "width": 10, "depth": 10},
			{"name": "exit", "width": 10, "depth": 10}],
		"doors": [[1, 2], [2, 3], [3, 4], [4, 1]],
		"things": []})
	if not bool(checked["ok"]):
		_check(false, "the owner's ring is valid")
		return
	var layout: Dictionary = module.solve(checked["content"])["layout"]
	var metrics: Dictionary = module.measure(layout)

	var world := Node3D.new()
	get_root().add_child(world)
	# The starter circuit first, exactly as the running game has it.
	_a_world(world, "StarterCircuit", 10)
	for child in world.get_children():
		child.queue_free()

	var holder := Node3D.new()
	world.add_child(holder)
	var report: Dictionary = module.build(holder, layout)
	var said := module.summary(metrics, report)
	print("      %s" % said.split("\n")[0])
	_check(said.begins_with("CREATE_DUNGEON built 4 rooms"),
		"the owner's dungeon now says four rooms with a circuit going out underneath it")
	_check(not said.contains("14 rooms"), "and never fourteen")
	world.queue_free()
