extends SceneTree

# 125 - the name a built piece carries, and whether it survives the second
# build. It does not, and this suite HOLDS THAT so it cannot change in
# silence.
#
# READ THIS BEFORE READING A ROW: EVERY DRIVEN ROW IN THIS FILE ASSERTS A
# FAULT, ON PURPOSE
# Nothing below says Genesis is right. The rows assert what Genesis DOES, and
# what it does is lose the name of every piece it rebuilds. They are written
# this way for one reason: the fix is "Human decision needed" 24 and it is the
# OWNER'S, 060 reserved it, and a suite that asserted the repaired behaviour
# would fail against today's code and tell a later session the repository is
# broken. So this is 060's own pattern - hold the behaviour, name the decision,
# and make the rows obviously deletable by whoever answers it. WHOEVER ANSWERS
# 24 DELETES SECTIONS 2, 3 AND 4. Section 1 is about Godot and survives either
# answer.
#
# WHAT IS NEW HERE, BECAUSE THE FAULT ITSELF IS NOT
# `player_door_test` section 7 found this in 060, measured the alternation and
# wrote it into HDN 24. What that reading covered was ONE node: the circuit's
# holder, `CircuitBuilder`. HDN 24 says in so many words that "the fault is
# latent: nothing reads the name today", and the cost it puts to the owner is
# the cost of one holder's name.
#
# THE COST IS NOT ONE NODE. IT IS EVERY PIECE OF EVERY REBUILT DUNGEON.
# Measured before anything was changed, on a plain dungeon of three rooms with
# two things:
#
#   build 1, fresh Main       : usable names 25, auto-named 24
#   build 2, same Main        : usable names  1, auto-named 48
#   build 3, second fresh Main: usable names 25, auto-named 24
#
# Twenty-four names, not one: `Ground`, `Corridor_1_1`, `Corridor_2_1`,
# `Room_1_entrance`, `Room_2_middle`, `Room_3_vault`, the `Wall_*` pieces, the
# `Thing_*` pieces and their `Solid` bodies. A second `CREATE_DUNGEON` does it,
# and so does any `SHUT` or `OPEN`, because those go through
# `GameController.rebuild_standing_world()`.
#
# AND IT IS NOT LATENT IN THE ONE PLACE THE PROJECT HAS BEEN BUILDING TOWARDS
# 121 asked whether a failed errand COULD name what stopped it and answered
# YES: the body's collider is a generic `Solid` and the obstacle's descriptive
# name is one `get_parent()` away. 124 then counted the naming rule that answer
# rests on - FOUR call sites and SIX name shapes - and left the class question
# for later: WHICH OF THOSE SIX NAMES CAN A STALLED ERRAND ACTUALLY READ? Asked
# of a dungeon that has been rebuilt, the answer is ONE OF THE SIX, AND ONLY
# BECAUSE IT IS NEW.
#
# `halt_cause_test` reads the name of a SHUT DOOR, after a `SHUT` - which is
# exactly the rebuild that costs the other pieces their names. It passes
# because the door slab is the one piece that DID NOT EXIST before that
# rebuild: there is no outgoing `Door_2_3` to collide with, so it keeps the
# name the module gave it. One member of the six was named, five were not, and
# the suite only ever asked about the one. Section 3 drives that, and it is the
# bound on 121's claim rather than a second copy of it.
#
# SO HDN 38 - whether a failed errand should name what stopped it - SITS ON TOP
# OF HDN 24, which nothing in this repository said before. Any answer to 38
# that names the obstacle prints "@MeshInstance3D@165" to a player the moment a
# door has been shut, and that is worse than the silence 38 is about. Neither
# question is answered here.
#
# WHAT IT ASSERTS AND WHAT IT NEVER ASSERTS (TRAPS 6, TRAPS 14)
# Not one piece name is typed into this file as an expected answer. Every row
# compares two readings of this project's own tree, so renaming every piece in
# `dungeon_module.gd` tomorrow fails nothing here, and a name LOST fails a row.
# Counts are not asserted either, for the same reason: a dungeon that gains a
# piece should not fail this file.
#
# AND THE DETECTOR HAS A CONTROL IN FRONT OF IT (TRAPS 6)
# A suite that counts generated names would read whatever it read just as
# happily if it were looking in the wrong place. Section 1 drives the mechanism
# itself on throwaway nodes this suite builds: a child named "X" added to a
# parent that already has an "X" must come back auto-named, and the same two
# calls with the incumbent detached first must keep the name. If either row
# fails, every reading below is meaningless and the suite says so.

var main: Node3D
var lines: Array = []
var failures: Array = []
var asserted := 0

const ROOMS := '{"name": "entrance", "width": 12, "depth": 12}, {"name": "middle", "width": 12, "depth": 12}, {"name": "vault", "width": 12, "depth": 12}'
const THINGS := '{"name": "lamp", "in": "entrance"}, {"name": "key", "in": "middle"}'
const DUNGEON := '{"command": "CREATE_DUNGEON", "parameters": {"rooms": [%s], "doors": [[1, 2], [2, 3]], "things": [%s]}}'
const SHUT := '{"command": "SHUT", "parameters": {"between": ["middle", "vault"]}}'
const SECTIONS := "{\"type\": \"straight\", \"length\": 200}, {\"type\": \"corner\", \"radius\": 60, \"angle\": 90}, {\"type\": \"straight\", \"length\": 200}, {\"type\": \"corner\", \"radius\": 60, \"angle\": 90}, {\"type\": \"straight\", \"length\": 200}, {\"type\": \"corner\", \"radius\": 60, \"angle\": 90}, {\"type\": \"straight\", \"length\": 200}, {\"type\": \"corner\", \"radius\": 60, \"angle\": 90}"
const TRACK := '{"command": "CREATE_TRACK", "parameters": {"sections": [%s]}}'


func _check(ok: bool, what: String) -> void:
	asserted += 1
	if not ok:
		failures.append(what)
	lines.append(("PASS  " if ok else "FAIL  ") + what)


func _initialize() -> void:
	_run()


# The scene the game launches, resolved through ProjectSettings rather than by
# path, so this suite cannot end up holding a scene that is not the game's.
func _make_main() -> void:
	var path := str(ProjectSettings.get_setting("application/run/main_scene"))
	main = (load(path) as PackedScene).instantiate()
	root.add_child(main)


func _drop_main() -> void:
	await process_frame
	main.get_parent().remove_child(main)
	main.free()
	main = null
	await process_frame


func _type(text: String) -> void:
	main._handle_request(text)
	await process_frame
	await process_frame


# Godot's own marker for a name it generated because the one it was given was
# taken: "@<Class>@<instance id>". Section 1 drives this rather than trusting
# the shape of the string.
func _is_auto(name_of: String) -> bool:
	return name_of.begins_with("@")


# Every node standing under `holder`, whatever depth, split into the names a
# reader could use and the classes carrying a generated one. Nodes queued for
# deletion are skipped: this suite is about what the tree holds, and a node on
# its way out is not part of the world being described. The same function reads
# every build, so two readings cannot differ in what they looked at.
#
# THE SPLIT IS NOT TIDYING, AND THE FIRST DRAFT OF THIS SUITE GOT IT WRONG
# (TRAPS 89). That draft compared ALL names and asserted a first build
# auto-names nothing. It FAILED on a correct tree, by 24, and the control row
# is what said so: `_solid()` builds a `CollisionShape3D` and never names it,
# so a first build legitimately stands 24 auto-named nodes up. A node never
# given a name and a node that LOST the name it was given are the same string
# afterwards and cannot be told apart by reading it. So the two are separated
# by what can be said about each: which readable names are gone, and which
# CLASSES have started carrying a generated name.
#
# AND THE SECOND HALF IS A CLASS SET RATHER THAN A COUNT, WHICH THAT DRAFT ALSO
# GOT WRONG. It compared the auto-named COUNT, and a `SHUT` genuinely adds a
# piece - so the count moved 24 -> 25 on a tree where nothing had been lost and
# the row called a real addition a lost name. The set of classes does not move
# when a piece is added or removed, and does move the instant a MeshInstance3D
# turns up auto-named.
func _reading(holder: Node) -> Dictionary:
	var readable := {}
	var auto_classes := {}
	var autos := 0
	var total := 0
	var stack: Array = [holder]
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		for child in node.get_children():
			stack.append(child)
			if child.is_queued_for_deletion():
				continue
			total += 1
			if _is_auto(str(child.name)):
				autos += 1
				auto_classes[child.get_class()] = true
			else:
				readable[str(child.name)] = child.get_class()
	return {"readable": readable, "auto_classes": auto_classes,
		"autos": autos, "total": total}


# The classes carrying a generated name, sorted, so a row prints what it read
# rather than what it hoped for.
func _auto_class_list(r: Dictionary) -> Array:
	var out: Array = (r["auto_classes"] as Dictionary).keys()
	out.sort()
	return out


# The readable names in `a` that are gone from `b`, sorted.
func _lost(a: Dictionary, b: Dictionary) -> Array:
	var out: Array = []
	for n in (a["readable"] as Dictionary).keys():
		if not (b["readable"] as Dictionary).has(n):
			out.append(str(n))
	out.sort()
	return out


# The two readings a rebuild produces, asserted the same way wherever the
# rebuild happened, so the dungeon's two paths are measured by one reader
# rather than by two that could drift.
#
# HOLDS A FAULT. Both rows assert that names ARE lost. See the header: the fix
# is HDN 24 and whoever answers it deletes these.
func _hold_the_loss(before: Dictionary, after: Dictionary, what: String) -> void:
	var lost := _lost(before, after)
	_check(not lost.is_empty(),
		"HELD FAULT (HDN 24): %s LOSES readable names - %d gone, first four %s" % [
			what, lost.size(), str(lost.slice(0, 4))])

	# The classes that have started carrying a generated name. A piece that
	# lost its name puts its own class in this list, which is how this row
	# tells "a name was lost" from "a node was removed".
	var grew: Array = []
	for c in _auto_class_list(after):
		if not (before["auto_classes"] as Dictionary).has(c):
			grew.append(str(c))
	_check(not grew.is_empty(),
		"HELD FAULT (HDN 24): and the PIECES are what went nameless - classes carrying a generated name now but not before: %s. %s afterwards against %s before, %d generated of %d nodes" % [
			str(grew), str(_auto_class_list(after)), str(_auto_class_list(before)),
			int(after["autos"]), int(after["total"])])


# --- 1: the detector itself, driven on nodes this suite builds (TRAPS 6) ---
# About Godot and not about Genesis, so it survives either answer to HDN 24.
# It pins the MECHANISM the rest of the file is about: that the REPLACEMENT,
# not the incumbent, is the node that loses its name; that add_child()'s
# default gives it "@Class@id" rather than a readable variant; and that
# detaching the incumbent first is enough to keep the name - which is the fix
# HDN 24 describes as "freeing the outgoing world before adding the new one",
# measured here rather than argued.
func _detector_section() -> void:
	var parent := Node.new()
	parent.name = "Parent"
	root.add_child(parent)

	var first := Node3D.new()
	first.name = "X"
	parent.add_child(first)
	_check(str(first.name) == "X", "a child added to an empty parent keeps the name it was given")

	var second := Node3D.new()
	second.name = "X"
	parent.add_child(second)
	_check(str(first.name) == "X",
		"and when a SECOND child wants that name the INCUMBENT is untouched - it is still \"X\"")
	_check(str(second.name) != "X",
		"THE MECHANISM: the REPLACEMENT is the one renamed - it asked for \"X\" and got \"%s\"" % str(second.name))
	_check(_is_auto(str(second.name)),
		"AND THE DETECTOR WORKS: that name is generated and _is_auto() says so - \"%s\". Every reading below is only worth having because this row passed" % str(second.name))

	var third := Node3D.new()
	third.name = "Y"
	parent.add_child(third)
	parent.remove_child(third)
	var fourth := Node3D.new()
	fourth.name = "Y"
	parent.add_child(fourth)
	_check(str(fourth.name) == "Y",
		"AND THE FIX HDN 24 NAMES DOES WORK, measured here rather than argued: with the incumbent REMOVED from the tree first, the replacement keeps \"Y\". remove_child() is not deferred; queue_free() is")
	third.free()

	parent.get_parent().remove_child(parent)
	parent.free()


# --- 2: the second dungeon in one session ---
# The plainest reachable form: two legal CREATE_DUNGEONs, which is a player
# asking for a different dungeon. HOLDS A FAULT.
func _second_build_section() -> void:
	_make_main()
	await process_frame
	await _type(DUNGEON % [ROOMS, THINGS])
	var before := _reading(main.controller.standable["node"])
	_check((before["readable"] as Dictionary).size() > 0,
		"a dungeon is built - %d nodes under it, %d with a name a reader could use" % [
			int(before["total"]), (before["readable"] as Dictionary).size()])
	_check(int(before["autos"]) > 0 and _auto_class_list(before).size() == 1,
		"THE CONTROL: on the FIRST build the only class carrying a generated name is %s - the shape _solid() builds and never names. Read off the tree, not typed in. This is why the rows below compare readable names and classes rather than counts" % str(_auto_class_list(before)))

	await _type(DUNGEON % [ROOMS, THINGS])
	var after := _reading(main.controller.standable["node"])
	_hold_the_loss(before, after, "A SECOND CREATE_DUNGEON IN THE SAME SESSION")
	await _drop_main()


# --- 3: the rebuild a player actually causes, and the bound on 121 ---
# SHUT goes through GameController.rebuild_standing_world(). This is the rebuild
# halt_cause_test reads a name across, so this section is the bound on that
# suite's claim rather than a second copy of it: it asks about the five shapes
# that suite does not ask about, and it shows why the sixth could answer.
# HOLDS A FAULT.
func _shut_rebuild_section() -> void:
	_make_main()
	await process_frame
	await _type(DUNGEON % [ROOMS, THINGS])
	var before := _reading(main.controller.standable["node"])
	_check((before["readable"] as Dictionary).size() > 0,
		"a dungeon with a shuttable door is built - %d readable names" % (before["readable"] as Dictionary).size())

	await _type(SHUT)
	_check(DungeonModule.is_shut(main.controller.standable["layout"], 1, 2),
		"and the door's state really changed, so a rebuild really happened")
	var after := _reading(main.controller.standable["node"])

	_hold_the_loss(before, after, "A SHUT - the rebuild halt_cause_test reads a name across")

	# The door slab is NEW, so it is the one piece that cannot show the fault.
	# Asserted explicitly, because this is the whole reason 121's green is real
	# and narrow at the same time.
	var door := ""
	for n in (after["readable"] as Dictionary).keys():
		if str(n).begins_with("Door_"):
			door = str(n)
	_check(door != "",
		"AND THE ONE PIECE THAT KEEPS ITS NAME IS THE ONE THE REBUILD ADDED - \"%s\"" % door)
	_check(not (before["readable"] as Dictionary).has(door),
		"and it really is new: \"%s\" was not standing before the SHUT, so it collided with nothing. THAT is why halt_cause_test can read ITS name, and the five shapes it does not ask about are above" % door)
	await _drop_main()


# --- 4: the circuit, where this was first found, and where it is ONE node ---
# `player_door_test` section 7 holds the alternation across four builds. This is
# not a second copy of it: it is here so the dungeon reading above and the
# circuit reading sit in one file, and so a later session can see at a glance
# that HDN 24 is one rule with two very different costs.
#
# AND THE PIECES UNDER A CIRCUIT ARE NOT AFFECTED, WHICH THIS SESSION EXPECTED
# THEM TO BE AND MEASURED INSTEAD (TRAPS 89). `CircuitBuilder.clear()` does
# empty itself and `build()` does refill it in the same frame - but
# `RacingModule.build()` hands every CREATE_TRACK a BRAND NEW CircuitBuilder,
# so the Section_/Barrier_ pieces never meet an incumbent and `clear()` is
# reached on a node nobody rebuilds. The circuit's whole exposure is its
# HOLDER. Written down rather than tidied away, because "the same fault in the
# other world kind" was the wrong guess and the reason it is wrong is the
# useful part.
func _circuit_section() -> void:
	_make_main()
	await process_frame
	await _type(TRACK % SECTIONS)
	var holder_first := str((main.controller.drivable["node"] as Node).name)
	var pieces_first := _reading(main.controller.drivable["node"])

	await _type(TRACK % SECTIONS)
	var holder_second := str((main.controller.drivable["node"] as Node).name)
	var pieces_second := _reading(main.controller.drivable["node"])

	_check(_is_auto(holder_first) or _is_auto(holder_second),
		"HELD FAULT (HDN 24): a circuit's HOLDER carries a generated name on one of two consecutive builds - \"%s\" then \"%s\"" % [
			holder_first, holder_second])
	_check(_lost(pieces_first, pieces_second).is_empty(),
		"AND THE PIECES UNDER IT ARE UNAFFECTED - %d readable names, %d lost across the second build. RacingModule.build() makes a NEW CircuitBuilder each time, so they never meet an incumbent" % [
			(pieces_first["readable"] as Dictionary).size(),
			_lost(pieces_first, pieces_second).size()])
	await _drop_main()


func _run() -> void:
	_detector_section()
	await _second_build_section()
	await _shut_rebuild_section()
	await _circuit_section()

	print("")
	for l in lines:
		print(l)
	print("")
	print("PIECE NAME %d assertions, failures=%d" % [asserted, failures.size()])
	for f in failures:
		print("  FAILED: " + f)
	quit(0 if failures.is_empty() else 1)
