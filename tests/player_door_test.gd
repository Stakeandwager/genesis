extends SceneTree

# --- 061 FIRST: WHAT IN THIS HEADER HAS STOPPED BEING TRUE ---
#
# Everything below was written in 060 and is kept as it was written, because
# deleting a sentence that has been overtaken loses the reason it was there
# (TRAPS 14). Two of its claims are now HISTORY and not fact, and they are
# named here rather than quietly edited out of the paragraphs that make them:
#
#   1. "Every suite that needs main.gd - sixteen of them - builds its own
#      stand-in tree." NOT ANY MORE. 061 converted all sixteen _make_main()
#      fixtures to load this same scene, through
#      ProjectSettings.get_setting("application/run/main_scene") rather than
#      by path. This file is still the FIRST in the project's history to load
#      it, which is what the sentence was really about, and it is no longer
#      the only one.
#
#   2. "Sixteen files in tests/ set box.use_collision = true." NOT ANY MORE
#      either, and for the same reason: none of them builds a ground slab at
#      all now. Section 6 used to assert that at least two other suites gave
#      the slab collision the game has not got; that count is 0 and the
#      assertion FAILED when 061 ran it, which is how a check is supposed to
#      behave when the fact under it moves. It is turned round in place.
#
# What 061 established in their stead, and what section 0 now asserts, is the
# invariant rather than the gap: no suite stands main.gd up by hand, and
# every suite that stands it up reaches the scene through the setting. 061
# also walked both trees and enumerated TWELVE differences between the old
# stand-in and this scene; they are listed in HANDOVER's 061 section.
#
# --- 060: the four connects held by nothing, and the scene no test had ever
#          loaded ---
#
# THE TASK, AND WHERE IT CAME FROM
#
# HANDOVER named this as the next assistant task, in these words: "four are
# held by nothing and all four are reachable with no key - lap_completed,
# race announced, pressed and text_submitted. The last two are the doors a
# player actually uses: nothing in the project emits either signal, grepped,
# so every suite enters at _handle_request() and the suite says nothing about
# whether typing a sentence and pressing Build reaches the game at all."
#
# That is 057's sweep of main.gd's sixteen connect() calls, finished in 059.
# All four are held here, and all four are walked through a REAL EMIT: the
# real button's signal, the real LineEdit's signal, the real CheckpointTracker
# counting a lap off the car's own position, and the real RaceDirector's
# countdown running out under real physics. Nothing is hand-emitted into a
# handler.
#
# AND ASKING THE TASK'S OWN QUESTION ONE LEVEL OUT FOUND SOMETHING LARGER,
# which is why this file loads a scene instead of building one.
#
#   NOTHING IN THIS REPOSITORY HAD EVER LOADED scenes/main.tscn.
#
# Grepped across tests/ and scripts/: no file mentions a .tscn at all. The
# scene is reached only by project.godot's run/main_scene, by uid, which is
# to say only by the game. Every suite that needs main.gd - sixteen of them -
# builds its own stand-in tree by hand in a _make_main() of its own, naming
# the nodes main.gd's @onready lines ask for. So the fixture SUPPLIES the
# names it then proves are there, which is TRAPS 14's shape in a fixture
# rather than in a document: the check guards the assumption instead of
# checking the fact.
#
# (061: THE PARAGRAPH ABOVE IS NOW HISTORY. All sixteen were converted to
# load this scene; see the note at the top of this header.)
#
# WHAT THAT COST, STATED AS THE CLASS AND NOT THE INSTANCE (TRAPS 11). The
# scripts resolve SIX node paths against that scene, enumerated by reading
# the source below rather than listed from memory:
#
#   main.gd:20   $UI/CommandPanel/VBoxContainer/InputBox      LineEdit
#   main.gd:21   $UI/CommandPanel/VBoxContainer/BuildButton    Button
#   main.gd:22   $UI/CommandPanel/VBoxContainer/StatusLabel    Label
#   main.gd:23   $UI                                           CanvasLayer
#   game_controller.gd:129  world_root.get_node_or_null("Camera3D")
#   game_controller.gd:135  world_root.get_node_or_null("Ground/CSGBox3D")
#
# Rename, move or delete any one of them in scenes/main.tscn and the game
# fails at launch - the first three with a null on a typed @onready, the last
# two silently, with no camera and no ground pad - and before this file every
# one of the 64 suites still passed, because every one of them built the tree
# it wanted. That is not a hypothetical: it is the only way those six paths
# have ever been checked.
#
# AND THE FIXTURE IS NOT THE SCENE IN A WAY THAT IS MEASURABLE. Sixteen files
# in tests/ set `box.use_collision = true` on the ground slab they build.
# (061: NONE DOES NOW - none of them builds a slab. Section 6 is turned
# round and the note at the top of this header says why.)
# Nothing in scripts/ sets use_collision anywhere, and the real scene's
# Ground is a StaticBody3D with no CollisionShape3D under it and a CSGBox3D
# with use_collision left at its default false. MEASURED, in a throwaway copy
# of the project outside the repository (TRAPS 50), by dropping a 1 m box
# from y = 6 over cleared ground and stepping 400 physics frames:
#
#   the real scene   fell to y = -42.77 and was still falling
#   the fixture      rested at y =  0.49, on top of the slab
#
# AND WHAT THAT DIFFERENCE COSTS TODAY IS NOTHING, MEASURED RATHER THAN
# ARGUED EITHER WAY. All sixteen fixtures were patched to use_collision =
# false - the scene's own value - in that throwaway copy and every suite was
# run again, --all, user:// cleared first: 64 suites, 0 with something to
# look at, and the list DIFFED against the baseline is IDENTICAL, line for
# line. So no suite's answer rests on that floor, and this file does not
# claim one does.
#
# The two suites that really do stand a body on a floor - physics_test and
# behaviour_test - build their own 4000 m StaticBody3D with a real
# CollisionShape3D under it and were not touched by that patch, which is the
# part a sentence about "every suite that stands a body on the ground" would
# have got wrong. An earlier draft of this header said exactly that; it is
# recorded here rather than quietly deleted (TRAPS 14).
#
# What is left is a fixture that differs from the game in a way nobody had
# measured, and section 6 holds the scene's half of it as a fact: the day
# somebody turns collision on in the scene this suite says so, because
# sixteen fixtures are already written as though it is on.
# (061: THE SECOND HALF OF THAT SENTENCE IS NO LONGER TRUE. The sixteen
# fixtures are gone and section 6 now asserts that NO suite gives the slab a
# floor the game has not got, which is the same fact from the side that still
# holds. 061 also measured what the stand-in's floor had been doing, and it
# was not nothing: on drive_test's banked square an opponent car that came
# off the road landed on that floor and was recovered 21 times, where against
# the game's own scene it falls through the world and is recovered 25. Four
# runs, two a side, each identical to its repeat. No verdict moved.)
#
# WHAT THIS FILE DOES NOT PROVE, said here rather than left to be found:
#
#   - That a MOUSE CLICK on the button emits `pressed`, or that a RETURN key
#     in the box emits `text_submitted`. Those are Godot's, not Genesis's.
#     What is held is everything from the signal inwards, in the real scene.
#   - That a player DRIVING reaches the checkpoints. Section 3 moves the
#     car's own position and lets main.gd's _process call the tracker; the
#     driving loop that would move it is drive_test's business.
#   - The OTHER emit of race.announced, the result line in
#     RaceDirector._finish(). It needs three full laps driven by somebody,
#     and nobody drives in a headless run. Only the countdown's "GO!" is
#     walked.
#   - Anything about a rendered pixel. This is headless; the scene loads, its
#     nodes exist, and no window opens.
#
# AND TWO OF THIS FILE'S OWN ASSERTIONS WERE FALSE ABOUT GENESIS, which is
# recorded rather than quietly corrected (TRAPS 6, TRAPS 14). Both passed
# review by reading and both failed when run:
#
#   - "the circuit is the one thing standing in the world" read the standing
#     node's NAME and expected "CircuitBuilder", as drive_test:174 does.
#     It is "@Node3D@49" on the first build and the name ALTERNATES after
#     that. Section 7 has the mechanism and the measurement.
#   - "the play loop reported the difference" expected a "Changed: length"
#     line after the second world was built over the first. A raw-JSON
#     request is NEVER an edit: main.gd:190 calls _execute_json and returns,
#     eight lines before editing_from is set. Section 2 asserts the fact
#     instead, and the player who debugs with raw JSON is never told what
#     changed.
#
# RUN AGAINST BROKEN CODE BEFORE IT WAS BELIEVED (TRAPS 51). The deliberate
# faults, one at a time, each in a throwaway copy outside the repository with
# its own config/name so it could not share user:// with anything, and the
# FAIL lines READ rather than counted, are listed in HANDOVER's 060 section.

const SCENE_PATH := "res://scenes/main.tscn"

# Four straights and four 90 deg corners, as a raw JSON command. Raw JSON is
# the one door that works with no key - main.gd:188 - so the whole of this
# file runs in a container with no api_key.txt, which is what this container
# is. The three differ only in the length of the straights, so which of them
# built the standing world is a number and not a judgement.
const A_LENGTH := 300
const B_LENGTH := 400
const C_LENGTH := 500

var main: Node3D
var asserted := 0
var bad := 0
var notes: Array = []
# The name of the node each world was built into, in build order. Collected
# as the suite goes and read in section 7, because what it shows is a
# sequence and no single build shows it.
var world_names: Array = []


func _check(ok: bool, what: String) -> void:
	asserted += 1
	if ok:
		print("PASS  ", what)
	else:
		bad += 1
		print("  FAIL  ", what)


func _initialize() -> void:
	_run.call_deferred()


# --- the harness: the scene the game runs, loaded rather than rebuilt ---

func _track(length: int) -> String:
	var sections: Array = []
	for i in 4:
		sections.append('{"type": "straight", "length": %d}' % length)
		sections.append('{"type": "corner", "radius": 60, "angle": 90}')
	return '{"command": "CREATE_TRACK", "parameters": {"mode": "circuit", "sections": [%s]}}' % ", ".join(sections)


func _history() -> String:
	return main.history_log.get_parsed_text()


func _written() -> Array:
	var out: Array = []
	var file := FileAccess.open(TrackLog.PATH, FileAccess.READ)
	if file == null:
		return out
	while not file.eof_reached():
		var line := file.get_line().strip_edges()
		if line == "":
			continue
		var json := JSON.new()
		if json.parse(line) == OK and typeof(json.data) == TYPE_DICTIONARY:
			out.append(json.data)
	file.close()
	return out


func _records_since(before: int) -> Array:
	var all := _written()
	var mine: Array = []
	for i in range(before, all.size()):
		mine.append(all[i])
	return mine


# The name of the node the standing world was built into. Taken off
# drivable["node"], which the controller holds by reference, so this reads the
# name of a node this suite has already identified rather than searching for
# a node by name.
func _record_world_name(label: String) -> void:
	var node = main.controller.drivable.get("node", null)
	world_names.append([label, "none" if node == null else str(node.name)])


func _first_section_length() -> int:
	var params: Dictionary = main.controller.last_build.get("parameters", {})
	var sections: Array = params.get("sections", [])
	if sections.is_empty():
		return -1
	return int((sections[0] as Dictionary).get("length", -1))


# --- 0. the scene the game runs, and the six paths into it ---
#
# The scene is asserted to be THE ONE THE GAME LAUNCHES before anything else
# is asserted about it. project.godot names it by uid, so a suite that loaded
# scenes/main.tscn by path and said nothing about this would be holding a
# file that might not be the game's any more.
func _the_scene() -> void:
	var setting := str(ProjectSettings.get_setting("application/run/main_scene", ""))
	_check(setting != "", "project.godot names a main scene: " + setting)
	var launched: PackedScene = load(setting)
	_check(launched != null and launched.resource_path == SCENE_PATH,
		"and it is %s, the scene this file loads (got %s)" % [
			SCENE_PATH, "null" if launched == null else launched.resource_path])

	# 061: AND THE SENTENCE THAT USED TO BE ASSERTED HERE HAS STOPPED BEING
	# TRUE, which is said here rather than left for an assertion to keep
	# passing over a changed fact - TRAPS 14 in the check instead of in a
	# document. What stood here was "this is the only file in tests/ or
	# scripts/ that names a .tscn", written in 060 so that the header's claim
	# that NOTHING had ever loaded scenes/main.tscn could not go stale
	# unnoticed. In 061 all sixteen _make_main() fixtures were converted to
	# load it, so that claim is false and the header above says so. The old
	# assertion would still PASS, because those sixteen reach the scene
	# through ProjectSettings and name no .tscn at all - which is exactly why
	# it had to be replaced rather than kept: a check that cannot see the
	# change it was written to catch is worth nothing.
	#
	# What is asserted instead is the invariant 061 actually establishes, and
	# it is a stronger one than the sentence it replaces: NO suite stands
	# main.gd up by hand any more, and every suite that stands it up at all
	# reaches the scene through application/run/main_scene rather than by
	# path. Enumerated off the files rather than listed, so a seventeenth
	# suite is covered the day it is written.
	#
	# IT KEYS ON `var main: Node3D`, AND THAT IS A LIMITATION WORTH NAMING
	# RATHER THAN LEAVING TO BE FOUND. session_test declares no such variable:
	# it `extends "res://tests/drive_test.gd"` and inherits that file's
	# fixture, so it stands main.gd up without appearing in either list here.
	# It is covered in substance - whatever drive_test loads, it loads - but a
	# future suite that inherits a fixture from somewhere else would be
	# invisible to this enumeration. It is also why the count below is a floor
	# and not an equality. This is the reason 061's documents say SEVENTEEN
	# suites stand main.gd up where 060's said sixteen: sixteen files with a
	# _make_main() of their own, plus session_test inheriting one.
	var hand_built: Array = []
	var by_setting: Array = []
	var by_path: Array = []
	for name in DirAccess.get_files_at("res://tests"):
		# This file is skipped throughout section 0's enumerations: the
		# strings being looked for are written out in its own source, so an
		# enumeration that read itself would be counting its own assertions.
		# The first draft of the line below did exactly that and FAILED
		# naming player_door_test.gd, which is the only reason this comment
		# is here rather than the mistake being in the committed suite.
		if not name.ends_with(".gd") or name == "player_door_test.gd":
			continue
		# READ OFF THE CODE AND NOT THE WHOLE FILE (067). Every needle below
		# is a question about what a suite DOES, and until 067 all four were
		# asked of the raw file. MEASURED: add a suite to tests/ that loads
		# the main scene from a path it assembles itself - which is exactly
		# what this section exists to forbid - and the by_path assertion
		# FAILS by name, until one comment line in it says "Not read from
		# application/run/main_scene, deliberately", at which point the suite
		# is filed as reaching the setting and PASSES. 67 assertions,
		# failures=0, on the guard 061 wrote the section for. See TRAPS 64.
		var body := _code_of(FileAccess.get_file_as_string("res://tests/%s" % name))
		if body.contains('set_script(load("res://scripts/main.gd"))'):
			hand_built.append(name)
		if not body.contains("var main: Node3D"):
			continue
		if body.contains("application/run/main_scene"):
			by_setting.append(name)
		else:
			by_path.append(name)
	_check(hand_built.is_empty(),
		"no suite builds a stand-in for the main scene by putting main.gd on a node it made itself (%s)" % str(hand_built))
	_check(by_path.is_empty(),
		"and every suite that stands main.gd up reaches the scene through application/run/main_scene, not by a path of its own (%s)" % str(by_path))
	# A number, because an enumeration that matched nothing would assert
	# nothing and pass (TRAPS 6). A floor rather than an exact count, so a
	# seventeenth suite does not have to edit this line.
	_check(by_setting.size() >= 16,
		"and there are %d of them besides this file" % by_setting.size())
	# The reader those four needles go through, with its own negative control,
	# because the enumeration above is only as good as the text it reads. The
	# needle here is the one the measurement used.
	var prose := "# Not read from application/run/main_scene, deliberately.\n\tvar p := 1  # application/run/main_scene\n"
	_check(not _code_of(prose).contains("application/run/main_scene"),
		"and the reader it uses does not see that setting in a comment, on its own line or after code")
	_check(_code_of('\tvar p := ProjectSettings.get_setting("application/run/main_scene")\n').contains("application/run/main_scene"),
		"while it does see it in a line of code, so the filing above is not done by seeing nothing")
	# A scene RESOURCE PATH lives in exactly one place - this file, which is
	# the one that compares it with the setting. Read as "res://scenes" and
	# not as ".tscn": the sixteen converted suites name scenes/main.tscn in a
	# COMMENT explaining what they load, and the first draft of this line
	# searched for ".tscn" and failed on all sixteen of those comments. A
	# check that fires on a comment is checking the wording and not the fact.
	var literals: Array = []
	var literals_min := -1
	for dir in ["res://tests", "res://scripts"]:
		var here := 0
		for name in DirAccess.get_files_at(dir):
			if not name.ends_with(".gd") or name == "player_door_test.gd":
				continue
			here += 1
			# Code, not prose (067). This needle was CHOSEN to dodge the
			# sixteen comments that name the scene - the paragraph above says
			# so - and reading the code instead is the general form of that
			# dodge, so a seventeenth comment cannot fail this for a wording
			# reason. It narrows the check in exactly one way, correctly: a
			# commented-out resource path is not a resource path anything
			# loads. Found while measuring 067, by this file's own fixture
			# failing on a comment in the throwaway suite written to test it.
			if _code_of(FileAccess.get_file_as_string("%s/%s" % [dir, name])).contains("res://scenes"):
				literals.append(name)
		if literals_min < 0 or here < literals_min:
			literals_min = here
	# THE FLOOR, MISSING UNTIL 083 AND MEASURED RATHER THAN REASONED ABOUT.
	# The assertion below is an ABSENCE, so it is at its greenest when this
	# read has looked at nothing (TRAPS 75). 083 pointed this one read at a
	# directory that exists and is empty and the suite came back 69
	# assertions, failures=0 - a clean pass over a scan of nothing.
	# THE FEWER OF THE TWO, not the total: this read runs twice, over
	# tests/ and over scripts/, and a total would stay positive with one of
	# the two directories empty. The condition is what decides, so it is the
	# smaller count that has to clear zero.
	_check(literals_min > 0,
		"both directories were read and hold .gd files; the fewer of the two holds %d" % literals_min)
	_check(literals.is_empty(),
		"and a scene resource path is written out in this file and nowhere else in tests/ or scripts/ (others: %s)" % str(literals))

	# The @onready paths, ENUMERATED OUT OF main.gd rather than copied here,
	# so a fifth one is covered the day it is written. The count is asserted
	# too, because an enumeration that matched nothing would assert nothing
	# and pass (TRAPS 6).
	var onready := RegEx.create_from_string('@onready var \\w+: (\\w+) = \\$(\\S+)')
	# ASKED AT THE READ AND NOT AFTER THE STRIPPER (085, TRAPS 81). A path that
	# is not there reads as the empty string, and `_code_of("")` is NOT empty -
	# so a guard on `source` could not fail. Until 085 this read was held only
	# by `found == 4` below, which is an enumeration count written for another
	# purpose: it catches an empty read today and stops doing so the day
	# somebody loosens it to `found >= 1`. The property this relies on is
	# asserted centrally in source_scan_test's section 4, over a copy of
	# `_code_of()` that section 3 there has proved byte-identical to this one.
	var main_raw := FileAccess.get_file_as_string("res://scripts/main.gd")
	_check(main_raw != "", "main.gd was read (%d bytes)" % main_raw.length())
	var source := _code_of(main_raw)
	var found := 0
	for m in onready.search_all(source):
		found += 1
		var type_name := m.get_string(1)
		var path := m.get_string(2)
		var node := main.get_node_or_null(NodePath(path))
		_check(node != null, "scenes/main.tscn has %s, which main.gd declares" % path)
		if node != null:
			_check(node.is_class(type_name),
				"and it is a %s, as main.gd's type says (it is a %s)" % [type_name, node.get_class()])
	_check(found == 4,
		"main.gd declares four @onready scene paths and all four were enumerated (found %d)" % found)

	# The controller's two, read out of its own source the same way. These
	# resolve against world_root, which is main.
	var getter := RegEx.create_from_string('world_root\\.get_node_or_null\\("([^"]+)"\\) as (\\w+)')
	# The same guard for the same reason (085, TRAPS 81). This read was held
	# only by `paths.size() == 2` below.
	var controller_raw := FileAccess.get_file_as_string("res://scripts/game_controller.gd")
	_check(controller_raw != "", "game_controller.gd was read (%d bytes)" % controller_raw.length())
	var controller_source := _code_of(controller_raw)
	var paths: Array = []
	for m in getter.search_all(controller_source):
		paths.append(m.get_string(1))
		var node := main.get_node_or_null(NodePath(m.get_string(1)))
		_check(node != null and node.is_class(m.get_string(2)),
			"scenes/main.tscn has %s as a %s, which game_controller.gd reads off main" % [
				m.get_string(1), m.get_string(2)])
	_check(paths.size() == 2,
		"game_controller.gd resolves two paths against the main scene and both were enumerated (found %s)" % str(paths))

	# And the consequence rather than the path: the controller found both.
	_check(main.controller.camera != null,
		"the controller holds the scene's camera, so /view has something to return to")
	_check(main.controller.ground_box != null,
		"and the scene's ground box, so a world can be fitted to it")
	notes.append("the scene the game launches was loaded and all six script-declared node paths resolve in it")


# --- 1. the Build button (main.gd:100) ---
#
# The player's door. The text goes in the box and the button's own signal is
# emitted; everything after that is the game.
func _build_button() -> void:
	var request := _track(A_LENGTH)
	_check(main.controller.last_build.is_empty(),
		"before the button is pressed the player has built nothing (the startup circuit is unrecorded)")
	_check(not _history().contains("%d m straights" % A_LENGTH),
		"and nothing in the history says otherwise")

	var before := _written().size()
	main.input_box.text = request
	main.build_button.pressed.emit()
	await process_frame
	await process_frame

	_check(main.pending_request == request,
		"pressing BUILD carried the box's text into the request pipeline")
	_check(main.input_box.text == "",
		"and emptied the box, so the next sentence starts clean")
	_check(str(main.controller.last_build.get("command", "")) == "CREATE_TRACK",
		"and A WORLD WAS BUILT: the player's last build is a CREATE_TRACK (%s)" % str(main.controller.last_build.get("command", "NONE")))
	_check(_first_section_length() == A_LENGTH,
		"built from THIS request's numbers: first straight %d m, asked %d" % [_first_section_length(), A_LENGTH])
	_check(main.controller.has_drivable(),
		"and the world reports a drivable surface")
	_check(main.controller.drivable_surface().get("centreline", PackedVector3Array()).size() >= CheckpointTracker.CHECKPOINT_COUNT,
		"with a centreline long enough to carry checkpoints")

	var standing: Array = []
	for child in main.controller.world_node.get_children():
		if not child.is_queued_for_deletion():
			standing.append(child)
	_check(standing.size() == 1,
		"and one world stands in the scene, the startup circuit having been replaced (%d standing)" % standing.size())
	# IDENTITY AND NOT NAME. The first draft of this assertion read the node's
	# NAME, expecting "CircuitBuilder" as drive_test:174 does, and it failed.
	# What came back was "@Node3D@49". See section 7: the name is not the
	# world's to keep.
	if standing.size() == 1:
		_check(standing[0] == main.controller.drivable.get("node", null),
			"and it IS the node the controller will drive, by identity rather than by name")
	_record_world_name("button")

	# The ground pad is fitted to the world that was built, which is the
	# Ground/CSGBox3D path answering by consequence rather than by reflection.
	# Guarded rather than dereferenced: with the scene's Ground renamed,
	# get_node_or_null leaves this null and main.gd carries on silently - so a
	# suite that read .size off it would throw and abort instead of reporting.
	# Measured: that is exactly what the first draft did under fault 9.
	_check(main.controller.ground_box != null and main.controller.ground_box.size.x > 200.0,
		"the scene's 200 m ground pad was refitted to the built world (%s m)" % (
			"no ground box" if main.controller.ground_box == null else "%.0f" % main.controller.ground_box.size.x))

	_check(_history().contains(request),
		"the history panel gained the request the player typed")
	_check(_history().contains("%d m straights" % A_LENGTH),
		"and a readback naming what was understood")

	var records := _records_since(before)
	var built := false
	for r in records:
		var d: Dictionary = r
		if str(d.get("command", "")) == "CREATE_TRACK" and str(d.get("construction", "")) != "FAILED":
			built = true
	_check(built, "and the ledger gained a CREATE_TRACK record that did not fail (%d records)" % records.size())
	notes.append("BUILD: box -> button signal -> handler -> a 4x%d m circuit standing, recorded" % A_LENGTH)


# --- 2. the Enter key (main.gd:101) ---
#
# THE SAME HANDLER, A SECOND WIRE. Holding one does not hold the other: they
# are two connects to two functions that both call _handle_request, and
# either can be removed without the other noticing. So this walks its own
# door and builds its own world, told apart from section 1's by a number.
func _enter_key() -> void:
	var request := _track(B_LENGTH)
	var before := _written().size()
	main.input_box.text = request
	main.input_box.text_submitted.emit(request)
	await process_frame
	await process_frame

	_check(main.pending_request == request,
		"pressing RETURN in the box carried its text into the request pipeline")
	_check(main.input_box.text == "", "and emptied the box")
	_check(_first_section_length() == B_LENGTH,
		"and built THIS request's world over section 1's: first straight %d m, asked %d" % [_first_section_length(), B_LENGTH])
	# PROOF IT CAME THROUGH THE FRONT DOOR: pending_source is set to
	# {"source": "typed"} at main.gd:189, inside _handle_request's raw-JSON
	# branch, and nowhere else. _execute_json called directly - which is how
	# every other suite enters - leaves whatever was there.
	_check(main.pending_source == {"source": "typed"},
		"and _handle_request's own raw-JSON branch marked the source `typed`: %s" % str(main.pending_source))

	# AND THE PLAY LOOP SAYS NOTHING, WHICH THIS FILE'S FIRST DRAFT ASSERTED
	# THE OPPOSITE OF (TRAPS 6, TRAPS 14). It asserted "Changed: length" in
	# the history, on the reasoning that _handle_request sets editing_from and
	# the play loop reports the difference. It does not: main.gd:190 calls
	# _execute_json and RETURNS, eight lines before main.gd:199-201 sets
	# editing_from from the standing world. So a request typed as raw JSON is
	# never an edit, and the player who types one is never told what changed -
	# only the AI door gets that sentence. drive_test sets main.editing_from
	# by hand before _type() for exactly this reason, which is the repository
	# already knowing this without anywhere saying so.
	_check(main.editing_from.is_empty(),
		"a raw-JSON request is not an edit: editing_from is empty (%s)" % str(main.editing_from))
	_check(not _history().contains("Changed:"),
		"so the play loop reported no difference, although a second world was built over the first")
	_record_world_name("return")

	var records := _records_since(before)
	var built := false
	for r in records:
		if str((r as Dictionary).get("command", "")) == "CREATE_TRACK":
			built = true
	_check(built, "and the ledger gained its own CREATE_TRACK record (%d records)" % records.size())
	notes.append("RETURN: box -> text_submitted -> handler -> a 4x%d m circuit over the first" % B_LENGTH)


# --- 3. lap_completed (main.gd:93), through its production caller ---
#
# The tracker is not touched by this suite. The CAR is moved, and
# main.gd:809 - the only production caller of update_progress(), grepped - is
# what feeds the tracker, from _process, while driving. So what is held is
# the whole of it: that line, the tracker's counting, the signal, the connect
# and the handler's sentence.
#
# What is not held is a player driving there. Positions are set on the car;
# nothing steers it.
func _lap() -> void:
	_check(not _history().contains("Lap 1 completed"),
		"before a lap is driven the history says nothing about one")

	main._handle_request("/drive")
	await process_frame
	_check(main.driving and main.car != null, "/drive put a car on the circuit the player built")
	if main.car == null:
		return
	# Parked rather than driven: the physics that would move it has nobody at
	# the wheel, and a car left loose drifts off the checkpoint it was put on.
	main.car.freeze = true

	var checkpoints: PackedVector3Array = main.checkpoint_tracker.checkpoints
	_check(checkpoints.size() == CheckpointTracker.CHECKPOINT_COUNT,
		"and spread %d checkpoints along it (got %d)" % [CheckpointTracker.CHECKPOINT_COUNT, checkpoints.size()])
	_check(main.checkpoint_tracker.lap_count == 0, "with no lap counted yet")

	for i in range(1, checkpoints.size()):
		main.car.global_position = checkpoints[i]
		await process_frame
		await process_frame

	_check(main.checkpoint_tracker.lap_count == 1,
		"passing every checkpoint in order and reaching the line again counts one lap (got %d)" % main.checkpoint_tracker.lap_count)
	_check(main.checkpoint_tracker.last_lap_time > 0.0,
		"and timed it (%.3f s)" % main.checkpoint_tracker.last_lap_time)

	# Built from the tracker's own numbers through the tracker's own
	# formatter, so this asserts the handler reported WHAT HAPPENED rather
	# than that some line containing the word "Lap" was written.
	var expected := "Lap %d completed in %s (best %s)" % [
		main.checkpoint_tracker.lap_count,
		main.checkpoint_tracker.get_formatted_time(main.checkpoint_tracker.last_lap_time),
		main.checkpoint_tracker.get_formatted_time(main.checkpoint_tracker.best_lap_time),
	]
	_check(_history().contains(expected),
		"and the player was shown it, with the tracker's own times: " + expected)
	notes.append("LAP: car position -> main.gd:809 -> tracker -> lap_completed -> " + expected)


# --- 4. race.announced (main.gd:98) ---
#
# A real /race through the player's door, then real physics until the
# RaceDirector's countdown runs out and it says so. COUNTDOWN is 3 s at 120
# ticks, so this is about 360 physics frames; the loop waits for the sentence
# rather than counting to a number, because without --fixed-fps the delta a
# physics frame carries is not this suite's to predict.
func _race_announcement() -> void:
	_check(not _history().contains("GO!"), "before a race starts nothing has said GO!")

	main._handle_request("/race 1")
	await process_frame
	_check(main.race.running, "/race 1 started a race on the player's circuit")
	if not main.race.running:
		return
	_check(main.race.countdown_left() > 0.0,
		"with a countdown still to run (%.1f s)" % main.race.countdown_left())

	var frames := 0
	var limit := 120 * 30
	while frames < limit and not _history().contains("GO!"):
		await physics_frame
		frames += 1

	_check(_history().contains("GO!"),
		"when the countdown ran out the director announced the start and the player was shown it (%d physics frames)" % frames)
	_check(_history().contains("> race"),
		"and it is recorded against `race`, which is what _on_race_announced writes")
	_check(main.race.countdown_left() == 0.0, "and the countdown is spent")

	main.race.stop()
	main._handle_request("/view")
	await process_frame
	_check(not main.driving, "/view put the camera back and stopped driving")
	notes.append("RACE: /race -> real countdown -> announced -> \"GO!\" in the history after %d physics frames" % frames)


# --- 5. a guard, labelled as one (TRAPS 6) ---
#
# _on_text_submitted ignores the String the signal carries and reads
# input_box.text instead. A LineEdit always emits its own text, so NO INPUT A
# PLAYER CAN SEND can make the two differ and this assertion cannot fail
# today. It is here as a guard against a future handler that trusts the
# argument, and it is not counted as a measurement of anything.
func _reads_the_box_not_the_argument() -> void:
	main.input_box.text = _track(C_LENGTH)
	main.input_box.text_submitted.emit(_track(A_LENGTH))
	await process_frame
	await process_frame
	_check(_first_section_length() == C_LENGTH,
		"GUARD (unreachable today): the handler built the box's %d m circuit, not the signal argument's %d m" % [C_LENGTH, A_LENGTH])
	_record_world_name("guard")


# --- 6. the floor the fixtures have and the scene does not ---
#
# Asserted as a FACT about the real scene rather than as a fault, because
# nothing a player drives or walks on comes from here: a track builds its own
# slab and a dungeon builds its own Ground pad (dungeon_module.gd:1168). What
# makes it worth an assertion is the other side of it - sixteen fixtures in
# tests/ build this slab WITH collision, so they are written as though the
# scene's were solid. The day it becomes solid, those sixteen stop differing
# from the game and this says so.
func _the_scene_has_no_floor() -> void:
	var ground := main.get_node_or_null("Ground")
	_check(ground != null and ground.is_class("StaticBody3D"),
		"the scene's Ground is a StaticBody3D (%s)" % ("missing" if ground == null else ground.get_class()))
	if ground == null:
		return
	var shapes := 0
	for child in ground.get_children():
		if child is CollisionShape3D:
			shapes += 1
	_check(shapes == 0, "with no CollisionShape3D under it (found %d)" % shapes)
	var box := main.get_node_or_null("Ground/CSGBox3D") as CSGBox3D
	_check(box != null and not box.use_collision,
		"and a CSGBox3D with use_collision off, so the scene's ground is scenery and not a floor")

	# 061 TURNED THIS ASSERTION ROUND, AND THE OLD ONE FAILING IS HOW. In 060
	# it read "and N other suites in tests/ build that slab WITH collision,
	# which the game's scene does not", with N asserted to be at least 2:
	# sixteen fixtures set use_collision = true on a ground slab the game
	# leaves as scenery. 061 converted all sixteen to load the scene, so not
	# one of them builds a slab at all, the count went to 0 and the assertion
	# failed when the suite was run. The asymmetry it was written to report is
	# closed, so what is asserted now is the closure rather than the gap:
	#
	#   NO suite gives the ground a floor the game has not got.
	#
	# That is the same fact from the other side and it is the better guard:
	# the day a new fixture builds a slab with collision on it, this fires.
	# This file is skipped by the enumeration because its own header and
	# assertions quote the string, and an enumeration that counted itself
	# would be counting a comment.
	#
	# IT DOES NOT SAY NO SUITE HAS A FLOOR, which would be false:
	# physics_test and behaviour_test each build their own 4000 m
	# StaticBody3D with a real CollisionShape3D under it, deliberately,
	# because what they measure is a body coming to rest. They do it through
	# a shape and not through use_collision, and they stand up no main.gd, so
	# neither this line nor 061 touched them.
	#
	# BOTH READS BELOW CARRY A FLOOR SINCE 083, AND NEITHER DID BEFORE.
	# Both assertions are ABSENCES, and 083 measured each read on its own
	# against a directory that exists and is empty: 69 assertions,
	# failures=0 apiece. The third read in this function - the one feeding
	# own_floor below - was the only one of the three that fired, which is
	# why pointing all of tests/ at an empty directory at once looked like
	# coverage and was not (TRAPS 75, TRAPS 78).
	var with_collision: Array = []
	var tests_scanned := 0
	for name in DirAccess.get_files_at("res://tests"):
		if not name.ends_with(".gd") or name == "player_door_test.gd":
			continue
		tests_scanned += 1
		if _code_of(FileAccess.get_file_as_string("res://tests/%s" % name)).contains("use_collision"):
			with_collision.append(name)
	_check(tests_scanned > 0,
		"tests/ was read for that slab: %d suite(s) besides this file" % tests_scanned)
	_check(with_collision.is_empty(),
		"and no suite in tests/ gives that slab the collision the game's scene has not got (%s)" % str(with_collision))
	var in_scripts: Array = []
	var scripts_scanned := 0
	for name in DirAccess.get_files_at("res://scripts"):
		if not name.ends_with(".gd"):
			continue
		scripts_scanned += 1
		if _code_of(FileAccess.get_file_as_string("res://scripts/%s" % name)).contains("use_collision"):
			in_scripts.append(name)
	_check(scripts_scanned > 0,
		"and scripts/ was read for it: %d script(s)" % scripts_scanned)
	_check(in_scripts.is_empty(),
		"while nothing in scripts/ sets use_collision at all (%s)" % str(in_scripts))
	# And the floors that ARE deliberate, named so that the assertion above
	# cannot be read as "nothing in tests/ has a floor".
	var own_floor: Array = []
	for name in DirAccess.get_files_at("res://tests"):
		if not name.ends_with(".gd") or name == "player_door_test.gd":
			continue
		var body := _code_of(FileAccess.get_file_as_string("res://tests/%s" % name))
		if body.contains("StaticBody3D.new()") and body.contains("CollisionShape3D.new()"):
			own_floor.append(name)
	_check(own_floor.size() >= 2,
		"and the suites that really do stand a body on a floor build their own with a real shape (%s)" % str(own_floor))
	notes.append("the scene's ground is scenery and since 061 no fixture pretends otherwise; the %d suites that need a floor build their own" % own_floor.size())


# --- 7. the name a world is built into is not the world's to keep ---
#
# FOUND BY THIS FILE'S FIRST DRAFT FAILING. Section 1 asserted that the node
# standing in the world after a build is named "CircuitBuilder", as
# drive_test:174 asserts after a farm. It is not. It was "@Node3D@49".
#
# THE MECHANISM, measured across four builds in one session rather than read
# off the code. RacingModule.build() sets circuit.name = "CircuitBuilder" and
# THEN calls root.add_child(circuit). Godot's add_child, with
# force_readable_name left at its default false, replaces the name of a node
# that shares one with a SIBLING by a dummy "@Type@id". And the world being
# replaced is still a sibling in that frame: _clear_world_node() calls
# queue_free() on it, which does not remove it until the frame ends - the
# same fact 048 found underneath a count that said fourteen rooms.
#
# SO THE NAME ALTERNATES, and that is more than "the first build is wrong",
# which is what this session predicted before measuring:
#
#   startup circuit   CircuitBuilder   (nothing was there to collide with)
#   build 1           @Node3D@N        (the startup circuit still held it)
#   build 2           CircuitBuilder   (the outgoing one was called @Node3D@N)
#   build 3           @Node3D@N        (the outgoing one held it again)
#
# EVERY OTHER CIRCUIT A PLAYER BUILDS GETS A DUMMY NAME, decided by what the
# previous world was called and by nothing about this one.
#
# NOTHING A PLAYER CAN REACH IS WRONG, and that is asserted rather than
# assumed: no file in scripts/ contains the string "CircuitBuilder" except
# the module that assigns it, so no production code identifies a world by
# name - the controller holds drivable["node"] by reference. What reads the
# name is drive_test, twice, and its positive assertion at line 174 passes on
# the parity of its own build order: the world before it is a FARM, whose
# pieces go straight into world_node with no CircuitBuilder among them, so
# nothing collides. One circuit built before it and that line would fail.
# Named in HANDOVER as a candidate rather than changed here; a fix is to
# name the node after add_child, or to free the outgoing world first, and it
# touches a builder every world in the project goes through.
func _the_name_is_not_the_worlds() -> void:
	_check(world_names.size() == 3,
		"three worlds were built through the player's doors (%s)" % str(world_names))
	if world_names.size() != 3:
		return
	var first := str(world_names[0][1])
	var second := str(world_names[1][1])
	var third := str(world_names[2][1])
	_check(first.begins_with("@"),
		"the FIRST world a player builds is named by Godot, not by its builder: %s" % first)
	_check(second == "CircuitBuilder",
		"the SECOND takes the builder's name, the outgoing one no longer holding it: %s" % second)
	_check(third.begins_with("@"),
		"and the THIRD is named by Godot again: %s - the name alternates with what was there before" % third)

	# Why it costs nothing today, asserted off the source so that the day a
	# script starts reading the name this file says the cost has changed.
	#
	# AND IT CARRIES A FLOOR SINCE 083. The assertion is an absence that
	# underwrites a claim in the paragraph above - "no production code
	# identifies a world by name", which is the whole reason the alternating
	# name is said to cost nothing today. 083 pointed this read at a
	# directory that exists and is empty: 69 assertions, failures=0, the
	# claim at its greenest having read no script at all (TRAPS 75).
	var readers: Array = []
	var readers_scanned := 0
	for name in DirAccess.get_files_at("res://scripts"):
		if not name.ends_with(".gd") or name == "racing_module.gd":
			continue
		readers_scanned += 1
		if _code_of(FileAccess.get_file_as_string("res://scripts/%s" % name)).contains('"CircuitBuilder"'):
			readers.append(name)
	_check(readers_scanned > 0,
		"scripts/ was read: %d script(s) besides the module that assigns the name" % readers_scanned)
	_check(readers.is_empty(),
		"and no script but the module that assigns it names \"CircuitBuilder\" at all, so no production code identifies a world by name (%s)" % str(readers))
	notes.append("world node names, in build order: %s - the builder's name alternates with a Godot dummy" % str(world_names))


func _run() -> void:
	print("--- PLAYER DOOR: the four unheld connects, in the scene the game runs ---")
	main = load(SCENE_PATH).instantiate()
	get_root().add_child(main)
	await process_frame
	await process_frame

	_the_scene()
	await _build_button()
	await _enter_key()
	await _lap()
	await _race_announcement()
	await _reads_the_box_not_the_argument()
	_the_scene_has_no_floor()
	_the_name_is_not_the_worlds()

	print("")
	for note in notes:
		print("  ", note)
	print("PLAYER DOOR %d assertions, failures=%d" % [asserted, bad])
	quit(1 if bad > 0 else 0)


# The CODE of a .gd source: comment lines blanked and trailing comments cut,
# with the line count preserved so a scan that reports a line number still
# reports the right one. A question about what the code DOES is answered from
# this. A question about what is MENTIONED anywhere is a different question
# and reads the raw file; which one a scan is asking is decided by the
# direction of its assertion and not by habit.
#
# WHY THIS EXISTS. 066 found that the first version of record_id_test's
# session scan was satisfied by a comment saying OS.get_process_id() in
# prose, and fixed it in that one function. 067 asked the same question of
# every source scan in tests/ and MEASURED three more, each flipped from FAIL
# to PASS by one comment line. See TRAPS 64.
#
# NOT A PARSER. A "#" inside a string literal cuts the line early, which can
# only lose a code match and never invent one - so this is safe in the one
# direction that matters: nothing a comment says can make a presence check
# pass.
static func _code_of(source: String) -> String:
	var out := ""
	for raw in source.split("\n"):
		var line := str(raw)
		if line.strip_edges().begins_with("#"):
			out += "\n"
			continue
		var hash_at := line.find("#")
		out += (line if hash_at < 0 else line.substr(0, hash_at)) + "\n"
	return out
