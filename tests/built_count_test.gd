extends SceneTree

# --- 046: the count in the sentence after a build, read from what was built ---
#
# THE RULE ASKED, AND THE ANSWER
#
# HANDOVER named the next assistant task as TRAPS 24's rule - *a line that
# states a count reads it from what was BUILT, not from what was asked* - and
# called it "the last rule in that list with a function left to count" and
# "the one axis of the construction layer nobody has swept". It also handed
# over a starting point marked READ AND NOT MEASURED. The reading was right
# and the answer is ONLY WHERE THE FAULT WAS FOUND, for the sixth commit
# running:
#
#   stub_claims_test holds the rule for the three Prototype 001 stubs, which
#   place NOTHING. Every other line that states a count about a world that
#   was built read its number from the solved LAYOUT:
#
#     DungeonModule.summary()   Readback.plural(metrics["room_count"], "room")
#                               <- measure(layout)["room_count"]
#                               <- layout["rooms"].size()
#     RacingModule.summary()    report["section_count"]
#                               <- CircuitBuilder.build(): sections.size()
#     DungeonModule.build()     report["room_count"]: rooms.size()
#     FarmModule                states no count at all (WorldModule.summary)
#
#   HANDOVER's own spot-check said racing's count "is of pieces placed"
#   because the builder "adds a road piece for every section it loops over".
#   That is a count of LOOP ITERATIONS. It is the same number today and it is
#   not the same fact: `_add_collision` in the same function returns early on
#   an empty face list, so the builder already has one way to place less than
#   it looped over.
#
# WHY NO SUITE SAW IT, WHICH IS THE PART WORTH KEEPING (TRAPS 6)
#
# `grep` found `.summary(` in three of the 52 suites before this one, and
# **in none of them was a world ever BUILT**. All three hand the function a
# dictionary typed into the suite:
#
#   container_door_test   summary({"room_count": 2, "door_count": 1,
#                                  "loops": 1, ...}, {})
#   counted_said_test     summary(measured, {"section_count": <from metrics>})
#   capability_test        BootsTool.summary(spec) - a tool, not a world
#
# container_door_test's fixture states `loops: 1` for a dungeon of 2 rooms
# and 1 door, where measure() computes doors - rooms + 1 = 0. That is not a
# fault in that suite - it asserts a plural rule and any numbers do - and it
# is the evidence: the construction layer's sentence had never been put
# beside a construction, so nothing could have noticed where its numbers
# came from. 044's axis (what LAYER do the fixtures enter?) at the one layer
# whose answer was "none of them".
#
# WHAT THIS SUITE ASSERTS, AND WHAT IT DOES NOT (TRAPS 6, TRAPS 14)
#
# FINDING, and the assertion that fails against the pre-046 code: the count a
# world's summary states follows the TREE. A world is built, a piece is then
# taken out of the tree, the count is read again, and the sentence must state
# the smaller number. Before 046 the dungeon's sentence said "3 rooms" with
# two rooms standing, because it read the layout.
#
# GUARD: for every module in WorldRegistry.modules(), a legal world built
# from that module's OWN declared samples reports "pieces_built", and that
# number equals (a) the pieces counted independently off the tree here, (b)
# the size of the list pieces() names, and (c) the count the measurement
# layer states. A world added later that places its pieces without marking
# them reports 0 and FAILS, which is the direction that matters: a world
# whose sentence nobody tied to its geometry is louder as a failure than as
# a silent number taken from the request.
#
# GUARD, and not hypothetical: a node queued for deletion is not counted.
# GameController._clear_world_node() calls queue_free() on the old world and
# build() adds the new one in the same frame, so for part of a frame
# world_node holds both worlds. A count that included the outgoing one would
# be larger than the world it describes.
#
# NOT ASSERTED. Nothing here is about WORDING: every sentence in Genesis can
# be rewritten and this stays green, because what is compared is a number in
# the sentence against a number counted off the tree. Nothing here asserts
# that the dungeon's DOOR count or the circuit's road LENGTH comes from the
# tree - they do not, they come from the layout, and that is recorded in
# HANDOVER 046 rather than quietly fixed, because a door's construction is a
# corridor and whether "joined by 2 doors" should count corridors or doors is
# a question about what the sentence means. Nothing here asserts the farm
# says a count: it has no summary of its own and says none, which is a
# silence and not a falsehood.

var bad := 0


func _check(ok: bool, what: String) -> void:
	print(("PASS  " if ok else "FAIL  ") + what)
	if not ok:
		bad += 1


func _initialize() -> void:
	_every_world()
	_the_sentence_follows_the_tree()
	_a_node_on_its_way_out_is_not_counted()
	print("BUILT COUNT failures=%d" % bad)
	quit(bad)


# A request that BUILDS, which is not the same thing as a request that
# validates. The first choice is always the module's own declared samples -
# read from lists(), never typed here - so a world added later is covered
# without this file being edited.
#
# A circuit is the one world whose samples do not build: SectionValidator's
# declared sample is two straights, which is a legal LIST and not a closed
# circuit, so the feasibility gate refuses it ("closing a circuit needs at
# least 2 straights and 2 corners"). The sample is right for what it is for -
# the example inside a refusal at the list door - and wrong for this suite.
# So a second source is declared below, keyed on the command, and a module
# that builds from NEITHER is a FAIL and never a skip: that is the shape
# ledger_said_test and record_proposal_test both use, and the reason is that
# a world nobody can build here is a world whose sentence nobody is checking.
const BUILDABLE := {
	"CREATE_TRACK": {"sections": [
		{"type": "straight", "length": 200},
		{"type": "corner", "radius": 50, "angle": 90},
		{"type": "straight", "length": 200},
		{"type": "corner", "radius": 50, "angle": 90},
		{"type": "straight", "length": 200},
		{"type": "corner", "radius": 50, "angle": 90},
		{"type": "straight", "length": 200},
		{"type": "corner", "radius": 50, "angle": 90},
	]},
}


func _from_samples(module: WorldModule) -> Dictionary:
	var parameters := {}
	for entry in module.lists():
		var e: Dictionary = entry
		parameters[str(e["key"])] = e.get("sample", [])
	return parameters


# validate -> pre_check -> solve -> post_check, the controller's own order.
func _layout_for(module: WorldModule, parameters: Dictionary) -> Dictionary:
	var check := module.validate(parameters)
	if not bool(check.get("ok", false)):
		return {"ok": false, "why": "refused at the schema: %s" % str(check.get("errors", []))}
	var pre := module.pre_check(check["content"], {})
	if not bool(pre.get("ok", false)):
		return {"ok": false, "why": "refused at the pre-check: %s" % str(pre.get("reasons", []))}
	var solved := module.solve(pre["content"])
	if not bool(solved.get("ok", false)):
		return {"ok": false, "why": "did not solve: %s" % str(solved.get("reasons", []))}
	var post := module.post_check(solved["layout"])
	if not bool(post.get("ok", false)):
		return {"ok": false, "why": "refused at the post-check: %s" % str(post.get("reasons", []))}
	return {"ok": true, "layout": solved["layout"], "record": post.get("record", {})}


# Counted here, by walking the tree, rather than by calling the function
# under test. If placed_pieces() is ever wrong this must disagree with it.
func _count_marked(node: Node) -> int:
	var n := 0
	if node.has_meta(WorldModule.PIECE_META) and not node.is_queued_for_deletion():
		n += 1
	for child in node.get_children():
		n += _count_marked(child)
	return n


func _marked(node: Node) -> Array:
	var out: Array = []
	if node.has_meta(WorldModule.PIECE_META):
		out.append(node)
	for child in node.get_children():
		out.append_array(_marked(child))
	return out


# The layout for whichever request builds, with the samples tried first.
func _buildable(module: WorldModule) -> Dictionary:
	var from_samples := _layout_for(module, _from_samples(module))
	if bool(from_samples["ok"]):
		from_samples["source"] = "its own declared samples"
		return from_samples
	if not BUILDABLE.has(module.command()):
		return {"ok": false, "why": "%s, and no request is declared for %s in this suite" % [
			str(from_samples["why"]), module.command()]}
	var declared := _layout_for(module, BUILDABLE[module.command()])
	declared["source"] = "the request this suite declares for %s" % module.command()
	if not bool(declared["ok"]):
		declared["why"] = "%s (the declared request)" % str(declared.get("why", ""))
	return declared


# --- every world the registry offers, off the registry and not a list here ---
func _every_world() -> void:
	for entry in WorldRegistry.modules():
		var module: WorldModule = entry
		var name := module.display_name()
		var piece: Array = module.pieces()
		var built := _buildable(module)
		if not bool(built["ok"]):
			_check(false, "%s can be built here (%s)" % [name, built["why"]])
			continue
		_check(true, "%s builds from %s" % [name, str(built["source"])])

		var layout: Dictionary = built["layout"]
		var metrics := module.measure(layout)
		var root := Node3D.new()
		get_root().add_child(root)
		var report := module.build(root, layout)

		_check(report.has("pieces_built"),
			"%s reports what it built" % name)
		if not report.has("pieces_built"):
			root.free()
			continue

		var reported := int(report["pieces_built"])
		var counted := _count_marked(root)
		_check(reported == counted,
			"%s reports %d pieces and %d stand in the tree" % [name, reported, counted])

		# The list pieces() names is the world's own declaration of what it
		# is made of, so it is read from the module and never typed here.
		var declared := (layout.get(str(piece[0]), []) as Array).size()
		_check(reported == declared,
			"%s placed all %s its layout declares (placed %d)" % [
				name, Readback.plural(declared, str(piece[1])), reported])

		# And the measurement layer's count of the same list. These are two
		# different facts about one world and they must agree; if they ever
		# part, something declared was not placed and the sentence says the
		# smaller number.
		var measured := -1
		for key in ["%s_count" % str(piece[1]), "%s_count" % str(piece[0])]:
			if metrics.has(key):
				measured = int(metrics[key])
		if measured < 0:
			_check(false, "%s measures how many %s it has" % [name, str(piece[0])])
		else:
			_check(measured == reported,
				"%s measures %d %s and built %d" % [name, measured, str(piece[0]), reported])

		root.free()


# --- the assertion that fails against the pre-046 code ---
#
# Build a world, take one piece out of the tree, read the count again, and
# ask the module's own summary() what it says. The sentence must state the
# number of pieces that are there. Nothing about the wording is asserted:
# what is compared is the count rendered through Readback.plural() - the one
# reading of a count and its noun (TRAPS 27) - against the tree.
func _the_sentence_follows_the_tree() -> void:
	for entry in WorldRegistry.modules():
		var module: WorldModule = entry
		var name := module.display_name()
		var piece: Array = module.pieces()
		var built := _buildable(module)
		if not bool(built["ok"]):
			continue

		var layout: Dictionary = built["layout"]
		var metrics := module.measure(layout)
		var root := Node3D.new()
		get_root().add_child(root)
		var report := module.build(root, layout)
		var whole := int(report.get("pieces_built", -1))
		var said_whole := module.summary(metrics, report)

		# A world that states no count cannot state a wrong one. The farm is
		# this case today and it is named rather than skipped silently.
		var says_whole := said_whole.contains(Readback.plural(whole, str(piece[1])))
		if not says_whole:
			_check(not said_whole.contains(str(whole)),
				"%s states no %s count, and no bare %d either: %s" % [
					name, str(piece[1]), whole, said_whole.replace("\n", " / ")])
			root.free()
			continue

		# One piece out of the tree, by name, so the removal is visible in
		# the failure message if this ever breaks.
		var pieces := _marked(root)
		_check(pieces.size() == whole,
			"%s: %d marked nodes to take one from" % [name, pieces.size()])
		var gone: Node = pieces[pieces.size() - 1]
		var gone_name := str(gone.name)
		gone.get_parent().remove_child(gone)
		gone.free()

		var fewer := WorldModule.placed_pieces(root)
		_check(fewer == whole - 1,
			"%s: %s removed leaves %d of %d" % [name, gone_name, fewer, whole])

		var short_report := report.duplicate()
		short_report["pieces_built"] = fewer
		var said_fewer := module.summary(metrics, short_report)
		_check(said_fewer.contains(Readback.plural(fewer, str(piece[1]))),
			"%s says %s with %s gone: %s" % [
				name, Readback.plural(fewer, str(piece[1])), gone_name,
				said_fewer.replace("\n", " / ")])
		# And it no longer says the number the LAYOUT declares, which is the
		# number the pre-046 sentence said.
		_check(not said_fewer.contains(Readback.plural(whole, str(piece[1]))),
			"%s no longer says %s: %s" % [
				name, Readback.plural(whole, str(piece[1])),
				said_fewer.replace("\n", " / ")])
		root.free()


# --- a node on its way out is not a node that stands there ---
func _a_node_on_its_way_out_is_not_counted() -> void:
	var root := Node3D.new()
	get_root().add_child(root)
	var a := Node3D.new()
	a.name = "StandingPiece"
	root.add_child(a)
	WorldModule.mark_piece(a)
	var b := Node3D.new()
	b.name = "OutgoingPiece"
	root.add_child(b)
	WorldModule.mark_piece(b)

	_check(WorldModule.placed_pieces(root) == 2, "two marked pieces count as two")
	b.queue_free()
	_check(WorldModule.placed_pieces(root) == 1,
		"a piece queued for deletion is not counted (got %d)" % WorldModule.placed_pieces(root))
	_check(_count_marked(root) == 1, "and counting the tree here agrees")
	root.queue_free()

	# And the same thing in the shape the controller actually makes it:
	# GameController._clear_world_node() calls queue_free() on every child of
	# world_node and _build_world() calls module.build(world_node, layout) on
	# the next line, so a second world is added before the first is gone.
	# Measured here rather than read off the controller.
	var shared := Node3D.new()
	get_root().add_child(shared)
	var dungeon := DungeonModule.new()
	var first := _buildable(dungeon)
	if not bool(first["ok"]):
		_check(false, "a dungeon to build twice into one node (%s)" % str(first["why"]))
		shared.free()
		return
	var one := dungeon.build(shared, first["layout"])
	var rooms_each := int(one["pieces_built"])
	_check(rooms_each > 0, "the first world into the shared node placed %d" % rooms_each)
	for child in shared.get_children():
		child.queue_free()
	var two := dungeon.build(shared, first["layout"])
	_check(int(two["pieces_built"]) == rooms_each,
		"a world built over an outgoing one counts %d, not %d (both are in the tree: %d marked)" % [
			rooms_each, int(two["pieces_built"]), _marked(shared).size()])
	_check(_marked(shared).size() == rooms_each * 2,
		"and both worlds really are in the tree at that moment (%d marked nodes)" % _marked(shared).size())
	shared.free()
