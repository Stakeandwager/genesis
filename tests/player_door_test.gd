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
# 128: the time scale the second lap of section 3 is driven at, and the band
# the lap time has to land in as a multiple of the simulated span. The band is
# wide because what it has to tell apart is wide: at this scale a wall clock
# reads about 1/LAP_SCALE times the simulated span, or about zero under
# --fixed-fps, and both are far outside it.
const LAP_SCALE := 0.1
const LAP_FLOOR := 0.25
const LAP_CEILING := 3.0
# 129: section 8 drives one whole race at LAP_SCALE and compares the two
# durations it reports. RACE_LAP_TICKS and RACE_GRACE_TICKS are in engine
# ticks rather than seconds, so the frame rate is not written into either;
# RACE_GRACE_TICKS is UNSCALED because what it covers is the countdown, which
# runs before the scale is set. STEP_METRES is under CheckpointTracker.REACH
# so no checkpoint is stepped over.
const RACE_OPPONENTS := 1
const STEP_METRES := 20.0
const RACE_LAP_TICKS := 4.0
const RACE_GRACE_TICKS := 6.0
const RACE_SUM_FLOOR := 0.5
# 130: section 9 drives LAP_BOUNDARY_LAPS laps at one constant step and asks
# what the lap time is measured BETWEEN. LAP_AGREE is how far the laps may
# differ from the best of them as a fraction of it; every lap is driven at the
# same speed along the same line, so they must agree, and the fault this
# section is about makes the first one 0.82 of the rest.
const LAP_BOUNDARY_LAPS := 3
const LAP_AGREE := 0.10
# 132: section 10 drives the standing start with the car's own throttle
# instead of teleporting it. STANDING_HOLD_FRAMES is how long the car is held
# ON the line at zero throttle - the wait a player sits out - and
# STANDING_DRIVE_FRAMES is the ceiling on the real-physics run that follows,
# generous because how long a car takes to cover CheckpointTracker.REACH is
# the car's business and not a number this suite should know. Both are in
# ENGINE TICKS, so the frame rate is written into neither. CLOCK_RAN is the
# fraction of the held span the tracker's own clock has to have advanced by
# for the subtraction under it to mean anything.
# 133: section 11 holds the OTHER two placements inside the start line's
# REACH - the /race grid and a world rebuilt while driving. GRID_HOLD_MULTIPLE
# is how many times the countdown's own length the watching loop may run
# before it stops waiting for the countdown to expire, so the frame rate is
# written into neither it nor REBUILD_HOLD_FRAMES, which is in ENGINE TICKS.
# GRID_SENTENCE is the opening of main.gd:862's countdown status line and is
# section 11's control: the label carrying it is production saying it ran past
# the update_progress call one line above.
const GRID_HOLD_MULTIPLE := 4
const REBUILD_HOLD_FRAMES := 240
const GRID_SENTENCE := "Race starts in"
const STANDING_HOLD_FRAMES := 240
const STANDING_DRIVE_FRAMES := 3600
const CLOCK_RAN := 0.9
const A_LENGTH := 300
const B_LENGTH := 400
const C_LENGTH := 500
# 134: section 12's floor on the number of .gd files it read out of scripts/.
# A FLOOR and not the count, for the reason KNOWN is a floor in
# source_scan_test: a new script arriving is not a failure, and a scan that
# reached nothing is. `ls scripts/*.gd` was 37 at 134.
const PLACE_AT_FILES_FLOOR := 25
# 134: the three members of TRAPS 125's class, as keys into PLACE_AT_SITES.
# Typed here and derived there, so the two have to agree: this list is what
# sections 10 and 11 between them hold, and the table is what the code says.
const PLAYER_PLACEMENTS := [
	"main.gd::_start_driving::car",
	"main.gd::_on_controller_log::car",
	"race_director.gd::start::player",
]

# --- 12's TABLE: every `place_at` CALL SITE in `scripts/`, with the reason it
#     is in or out of TRAPS 125's class (134) ---
#
# WHERE THIS CAME FROM. TRAPS 128 is a count: two documents and a source-file
# header all said TRAPS 125's class had TWO members, every one of the two was
# handled correctly, and `grep -rn place_at scripts/` had a THIRD - reachable
# by typing one ordinary command. 133 read the grep, wrote the row for the
# third member (section 11), and left the tripwire out on purpose. This is the
# tripwire. The thing that went wrong was not that a placement was unhandled;
# it was that NOTHING FAILED when the class gained a member, so the count
# lived in prose and went stale there for two commits.
#
# WHY A TABLE AND NOT A COUNT, which is the same answer source_scan_test's
# `COUNTER_EQUALITIES` gives for the same reason. A count of seven against the
# number 7 fails on a fourth placement, but it fails WITH NOTHING TO READ: it
# cannot say which site arrived, and it cannot say whether the arrival is in
# the class or out of it. What a scanner CAN decide is the shape - the file,
# the enclosing function and the receiver of every `.place_at(` call in the
# comment-stripped code. What it cannot decide is whether a given call can
# move the body `CheckpointTracker.update_progress` is reading: that needs
# `race_director.gd:333` to be read as only ever reached for a car that is not
# the player's. So the scan finds the sites, EVERY site must carry a row here,
# and the row carries the reading. An eighth site fails BY NAME.
#
# AND THE SCOPE IS `scripts/` AND NOT THE TWO FILES THAT HOLD THE THREE
# (TRAPS 11). The class is *where is the player's car placed*, asked of the
# code. A scan narrowed to `main.gd` and `race_director.gd` would answer it
# for today's tree and miss the first placement written into a new file, which
# is the fault this entry exists to stop rather than a smaller version of it.
#
# `player` IS THE VERDICT AND IT IS NOT DECIDABLE BY THE SCAN. `true` means
# the call can place the body the lap tracker reads - a member of TRAPS 125's
# class, and one that must be held by a row. `false` means it cannot, and the
# `why` says what stops it.
const PLACE_AT_SITES := {
	"main.gd::_start_driving::car": {
		"player": true,
		"why": "`/drive`, on the line. Section 10 drives this one with the car's own throttle and five of its rows were seen red against the first version of 130's fix",
	},
	"main.gd::_on_controller_log::car": {
		"player": true,
		"why": "A WORLD REBUILT WHILE DRIVING - the member TRAPS 128 is about. A CREATE_TRACK that succeeds while the player is driving re-spreads the checkpoints and puts the car back on the NEW start line, inside REACH, from a standstill, with the clock re-armed. Held by section 11b",
	},
	"race_director.gd::start::player": {
		"player": true,
		"why": "the `/race` grid, a row behind the line. Held GEOMETRICALLY by section 11a and not under throttle, because `race_director.gd:140`-`141` clears `auto_drive` every physics frame while the race runs (TRAPS 127) - a harness limit, measured, and not a reason to change production",
	},
	"race_director.gd::start::car": {
		"player": false,
		"why": "the same function, one loop above: it places an OPPONENT. The loop runs over the cars the director spawned and the player is placed after it, on the line below. An opponent's position is never passed to the player's CheckpointTracker",
	},
	"race_director.gd::_recover::car": {
		"player": false,
		"why": "`_recover(r)` is reached only from the `_drive` and `_physics_process` paths that call it for `r[\"car\"] != _player`, so the body it lifts back onto the road is never the player's. Said rather than rounded up (TRAPS 128)",
	},
	"main.gd::_on_ordered::npc": {
		"player": false,
		"why": "an NPC's Walker at the start of an errand. `Walker.place_at` is a different function (`walker.gd:191`) on a different body, and no walker position reaches the lap tracker",
	},
	"main.gd::_start_exploring::walker": {
		"player": false,
		"why": "the player's WALKER at the start of `/explore`, also `walker.gd:191`. `/explore` builds no circuit and `checkpoint_tracker.checkpoints` is empty on that path, so there is no line for it to be inside",
	},
}

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
# main.gd:858 - the only production caller of update_progress(), grepped - is
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

	# 130: THE START LINE IS A MARKER NOW, SO THIS LOOP DRIVES IT. Until 130
	# it ran range(1, size), stopped at checkpoints[11], and the row under it
	# still read "and reaching the line again counts one lap" - a sentence
	# neither the loop nor the tracker required, because checkpoints[0] was
	# never a target. The two rows below are the sentence split in half, and
	# the first of them FAILS against the pre-130 tracker: it had already
	# counted the lap a twelfth of a circuit before the line. TRAPS 124.
	main.car.global_position = checkpoints[0]
	await process_frame
	await process_frame

	for i in range(1, checkpoints.size()):
		main.car.global_position = checkpoints[i]
		await process_frame
		await process_frame

	_check(main.checkpoint_tracker.lap_count == 0,
		"passing every checkpoint in order is not yet a lap: the line has not been reached again (got %d)" % main.checkpoint_tracker.lap_count)

	main.car.global_position = checkpoints[0]
	await process_frame
	await process_frame

	_check(main.checkpoint_tracker.lap_count == 1,
		"and reaching the line again counts one lap (got %d)" % main.checkpoint_tracker.lap_count)
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
	notes.append("LAP: car position -> main.gd:858 -> tracker -> lap_completed -> " + expected)

	# --- 128: the lap time is the SIMULATION's duration, not the wall's ---
	#
	# WHY THIS ROW IS NOT "last_lap_time > 0.0". That row above is true of a
	# wall clock and of a simulation clock alike whenever the lap takes more
	# than a millisecond of real time, which it does when this suite is run
	# the way run_tests.sh runs it. It is the row 127 found reading 0.000 s
	# and FAILING at --fixed-fps 120, seven runs out of eight - a lap the
	# engine had simulated in 0.17 s, timed by a clock that had not ticked.
	# So "> 0.0" cannot tell the two clocks apart in the configuration the
	# runner actually uses, and a row that cannot fail against the fault it
	# is about is TRAPS 6.
	#
	# THIS ROW SEPARATES THEM WITHOUT SLEEPING AND IN EITHER CONFIGURATION.
	# Engine.time_scale scales the delta the engine hands out and does not
	# touch the wall: at 0.1 a lap that takes a tenth of a second of real
	# time is a hundredth of a second of simulated time. A wall clock then
	# reads about ten times the simulated span with no --fixed-fps, and about
	# zero with it, and both are outside the band below. The scale is set
	# BEFORE the /drive that re-arms the tracker, so every frame of the lap
	# it times is a scaled frame.
	#
	# WHAT IT ASSERTS IS THE CAPABILITY AND NOT A NUMBER (TRAPS 6, TRAPS 14).
	# Nothing here is typed in as an expected lap time. The band is a ratio
	# against the simulated span this suite itself stepped, read off
	# Engine.get_physics_frames() and Engine.physics_ticks_per_second rather
	# than off the tracker, so the two sides of the comparison have different
	# sources. Change the fixture, the checkpoint count or the frame rate and
	# this row still holds; put a wall clock back in the tracker and it fails.
	Engine.time_scale = LAP_SCALE
	main._handle_request("/drive")
	await process_frame
	if main.car == null:
		Engine.time_scale = 1.0
		_check(false, "and a second /drive put a car back on the circuit")
		return
	main.car.freeze = true
	_check(main.checkpoint_tracker.lap_count == 0,
		"a second /drive re-armed the tracker, so the next lap is timed from zero (lap_count %d)" % main.checkpoint_tracker.lap_count)

	var tick := 1.0 / float(Engine.physics_ticks_per_second)
	var wall_at_start := -1
	var frames_at_start := -1
	# 130: the line, then the eleven, then the line again - the order the
	# tracker requires since the start line became a marker. The lap this
	# times is a WHOLE lap now; before 130 it was ten of twelve segments, and
	# the band below is a ratio against the span this suite stepped, so it
	# holds either way.
	var order: Array = [0]
	for i in range(1, checkpoints.size()):
		order.append(i)
	order.append(0)
	for i in order:
		main.car.global_position = checkpoints[int(i)]
		await process_frame
		if frames_at_start < 0 and main.checkpoint_tracker.lap_started:
			# The tracker has just taken its own lap start. Read the engine's
			# frame counter and the wall at the same moment it did.
			wall_at_start = Time.get_ticks_msec()
			frames_at_start = Engine.get_physics_frames()
		await process_frame

	var wall_span := float(Time.get_ticks_msec() - wall_at_start) / 1000.0
	var sim_span := float(Engine.get_physics_frames() - frames_at_start) * tick * Engine.time_scale
	var timed: float = main.checkpoint_tracker.last_lap_time
	Engine.time_scale = 1.0

	_check(main.checkpoint_tracker.lap_count == 1,
		"and the slowed lap was counted (lap_count %d)" % main.checkpoint_tracker.lap_count)
	_check(timed > sim_span * LAP_FLOOR and timed < sim_span * LAP_CEILING,
		"and the lap time is the SIMULATED duration and not the wall's: timed %.4f s, simulated %.4f s, wall %.4f s, band %.4f to %.4f" % [
			timed, sim_span, wall_span, sim_span * LAP_FLOOR, sim_span * LAP_CEILING])
	_check(is_equal_approx(Engine.time_scale, 1.0),
		"and the engine's time scale is back to 1.0 for the sections after this one (%.2f)" % Engine.time_scale)
	notes.append("LAP CLOCK: at time_scale %.2f the tracker timed %.4f s over a %.4f s simulated span and a %.4f s wall span" % [
		LAP_SCALE, timed, sim_span, wall_span])


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


# --- 8. the lap time and the finish time of ONE race, side by side (129) ---
#
# WHAT THIS HOLDS, AND WHY SECTION 3 DOES NOT ALREADY HOLD IT. 128 changed
# CheckpointTracker from a wall clock to the simulation's clock and said, in
# scripts/checkpoint_tracker.gd's own comment, that "a lap time and the finish
# time of the race it was driven in are the same clock". That sentence was
# READ OFF TWO SOURCES - checkpoint_tracker.gd and race_director.gd:138, both
# `+= delta` in _physics_process - and the two sentences it is about were
# never printed side by side in one race and compared. Section 3 drives a lap
# with no race running at all, so it cannot hold it. This section drives a
# whole /race to its finish and reads BOTH numbers out of the one history.
#
# AND IT RUNS AT Engine.time_scale = LAP_SCALE, WHICH IS NOT DECORATION
# (TRAPS 6). MEASURED, in a throwaway clone whose checkpoint_tracker.gd is the
# PRE-128 wall-clock one, driving this same race:
#
#   at time_scale 1.0   the wall clock's laps summed to 0.93 of the finish
#                       time and each full lap was 3 ms off the span the
#                       suite stepped - INSIDE the tolerances below, so
#                       every row here PASSES against the fault it is about
#   at time_scale 0.1   the same laps summed to 8.47 TIMES the finish time
#                       and each full lap was 0.49 s - 294 ticks - off
#
# So a version of this section written without the scale would have been a
# section that cannot fail against the thing it certifies. The numbers for
# both trees are in HANDOVER's 129 entry.
#
# WHAT IS ASSERTED IS THE CAPABILITY AND NOT A NUMBER (TRAPS 6, TRAPS 14). No
# lap time, finish time or ratio is typed in as an expected answer. The lap
# rows are compared against the simulated span THIS SUITE stepped, read off
# Engine.get_physics_frames() and Engine.physics_ticks_per_second - a third
# source, neither of the two clocks - and the sum row is a comparison of the
# two numbers the player was shown against each other. Change the fixture,
# the checkpoint count, the lap count or the frame rate and these rows hold.
#
# WHERE THE SUM BAND COMES FROM, SO IT IS NOT A NUMBER PULLED OUT OF THE AIR.
# 130 REWROTE THIS PARAGRAPH BECAUSE 130 MOVED THE BOUNDARY IT DESCRIBES, and
# what it said before is kept here because the band did not move with it.
# ~~The tracker starts timing at the first checkpoint after the line and
# counts a lap when it reaches the LAST checkpoint, so of a RACE_LAPS-lap race
# it times RACE_LAPS laps less two twelfths of one: about 0.94 of the race at
# a steady speed.~~ Since 130 the tracker times from the start line to the
# start line, so it times RACE_LAPS WHOLE laps - but the race's clock runs
# from GO, which is BEFORE the car reaches the line for the first time, and a
# lap is counted within CheckpointTracker.REACH BEFORE the line while the race
# finishes AT it. So the sum is still below the finish time for any track and
# any speed, by a smaller margin than before, and still far above half of it.
# Both edges are asserted; the measured value is in the note.
func _one_race_two_clocks() -> void:
	main._handle_request("/drive")
	await process_frame
	if main.car == null:
		_check(false, "a /drive before the race put a car on the circuit")
		return
	var line: PackedVector3Array = main._track_centreline()
	if line.size() < CheckpointTracker.CHECKPOINT_COUNT:
		_check(false, "and the circuit has a centreline to drive (%d points)" % line.size())
		return

	main._handle_request("/race %d" % RACE_OPPONENTS)
	await process_frame
	_check(main.race.running, "/race %d started a race on the player's circuit" % RACE_OPPONENTS)
	if not main.race.running:
		return

	# The countdown is run at the engine's own rate: at LAP_SCALE it would
	# cost COUNTDOWN / LAP_SCALE seconds of real time to wait out, and what
	# has to be scaled is the LAPS. The few frames of countdown that the
	# race's clock keeps past zero are the reason the finish-time row below
	# carries a grace, and it says so there.
	var frames := 0
	while frames < 120 * 30 and main.race.countdown_left() > 0.0:
		await physics_frame
		frames += 1
	_check(main.race.countdown_left() == 0.0,
		"and the countdown is spent after %d physics frames" % frames)

	Engine.time_scale = LAP_SCALE
	await physics_frame
	await physics_frame
	var tick := 1.0 / float(Engine.physics_ticks_per_second)
	var frames_at_go := Engine.get_physics_frames()

	# Nobody steers in a headless test, so the car is moved along the line the
	# checkpoints were spread along - main.gd's own _track_centreline() - and
	# frozen, because a loose car drifts off the point it was put on. The step
	# is under REACH so no checkpoint is skipped, and well inside the race
	# director's SEARCH_WINDOW so it never loses which point the car is at.
	main.car.freeze = true
	var n := line.size()
	var span := 0.0
	for i in n:
		span += line[i].distance_to(line[(i + 1) % n])
	var spacing := span / float(n)
	var step := clampi(int(floor(STEP_METRES / maxf(spacing, 0.01))), 1, 15)

	var timed: Array = []
	var marks: Array = []
	var counted := 0
	var at := 0
	var steps := 0
	while not main.race.finished and steps < 20000:
		at += step
		steps += 1
		main.car.global_position = line[at % n] + Vector3(0.0, 0.5, 0.0)
		await process_frame
		if main.checkpoint_tracker.lap_count > counted:
			counted = main.checkpoint_tracker.lap_count
			timed.append(main.checkpoint_tracker.last_lap_time)
			marks.append(Engine.get_physics_frames())

	var sim_span := float(Engine.get_physics_frames() - frames_at_go) * tick * LAP_SCALE
	var finish_time := float(main.race.racers[0]["finish_time"])
	var last_lap: float = main.checkpoint_tracker.last_lap_time
	var lap_count: int = main.checkpoint_tracker.lap_count
	var hist := _history()
	Engine.time_scale = 1.0

	_check(main.race.finished,
		"and the player drove it to the finish, %d m of road at %.1f m a step (%d steps)" % [int(span), step * spacing, steps])
	if not main.race.finished:
		main.race.stop()
		main._stop_driving()
		return

	_check(lap_count == RaceDirector.RACE_LAPS,
		"the tracker counted the race's %d laps as the player drove them (counted %d)" % [RaceDirector.RACE_LAPS, lap_count])

	# From lap 2 on. Since 130 lap 1 is a whole lap like the others, but it
	# starts when the car first reaches the START LINE, and the mark this
	# suite has for its lower edge is GO - a few frames earlier, with the car
	# still on the grid. So the span stepped from GO is still not the span
	# lap 1 was timed over. Every lap after it runs from one lap count to the
	# next, which is exactly the span between two marks. Whether lap 1 is a
	# whole lap is section 9's question and it is asked there in metres.
	var tolerance := RACE_LAP_TICKS * tick * LAP_SCALE
	for k in range(1, timed.size()):
		var stepped := float(int(marks[k]) - int(marks[k - 1])) * tick * LAP_SCALE
		_check(absf(float(timed[k]) - stepped) <= tolerance,
			"lap %d's time is the SIMULATED span the suite stepped over it and not the wall's: timed %.4f s, stepped %.4f s, allowed %.4f s" % [
				k + 1, float(timed[k]), stepped, tolerance])

	# The other member of the same class, held here for the first time: the
	# race's own clock. A grace of RACE_GRACE_TICKS UNSCALED ticks is allowed
	# above the stepped span because finish_time is `_clock - COUNTDOWN` and
	# the countdown was run before the scale was set, so the few frames by
	# which the race's clock passed COUNTDOWN are unscaled and are counted
	# into it. A wall clock here reads about 1/LAP_SCALE times the span and is
	# nowhere near the grace.
	var grace := RACE_GRACE_TICKS * tick
	_check(finish_time >= sim_span - tolerance and finish_time <= sim_span + grace,
		"and the finish time is the simulated span too: %.4f s against %.4f s stepped, allowed %.4f s over" % [
			finish_time, sim_span, grace])

	# The row this section exists for: the two numbers THE PLAYER WAS SHOWN,
	# out of one race, compared against each other rather than against the
	# code that made them.
	var sum := 0.0
	for t in timed:
		sum += float(t)
	_check(sum < finish_time,
		"the laps the player was shown sum to LESS than the finish time he was shown, as the geometry says they must: %.4f s of laps, %.4f s raced" % [sum, finish_time])
	_check(sum > finish_time * RACE_SUM_FLOOR,
		"and to more than %.2f of it, so the two sentences are the same clock and not two: %.4f of the finish time" % [
			RACE_SUM_FLOOR, sum / maxf(finish_time, 0.0001)])

	# Built from each object's OWN number through its OWN formatter, so this
	# asserts the two handlers reported what happened rather than that some
	# line containing "Lap" or "Finished" was written.
	var lap_line := "Lap %d completed in %s" % [lap_count, main.checkpoint_tracker.get_formatted_time(last_lap)]
	_check(hist.contains(lap_line),
		"and both sentences are in the one history: " + lap_line)
	_check(hist.contains("in %s." % main.race._format(finish_time)),
		"and \"Finished P... in %s.\", the race's own number through the race's own formatter" % main.race._format(finish_time))
	_check(is_equal_approx(Engine.time_scale, 1.0),
		"and the engine's time scale is back to 1.0 (%.2f)" % Engine.time_scale)

	notes.append("ONE RACE: %d laps timed %s summing to %.4f s, finish time %.4f s (%.4f of it), stepped span %.4f s at time_scale %.2f" % [
		lap_count, str(timed.map(func(t): return "%.4f" % float(t))), sum, finish_time, sum / maxf(finish_time, 0.0001), sim_span, LAP_SCALE])

	main.race.stop()
	main._stop_driving()

# --- 9. what a lap time is measured BETWEEN (130) ---
#
# 128 fixed HOW a lap is timed - the engine's delta and not the wall - and 129
# drove a whole race to hold that claim. Neither asked what the duration is
# measured BETWEEN, and 129 found the answer by accident while driving: the
# first reported lap came out 0.8209 of the three after it, on the same track
# at the same constant speed. next_index started at 1 and was only ever
# incremented or reset to 1, so checkpoints[0] - the start line - was never a
# target: timing began at checkpoints[1] and the lap was counted at
# checkpoints[11], ten of twelve segments. And because best_lap_time is a min,
# that short lap became the "best lap" on main.gd:869-873's status line and in
# the history for the rest of the session, a time the player had not driven
# and could not beat. TRAPS 124, and the proximity trap that fixing it
# produced is TRAPS 125.
#
# WHAT THIS SECTION ASSERTS IS GEOMETRY, NOT TIME, AND THAT IS THE POINT. The
# two rows that catch the boundary read WHERE the car was when each lap was
# counted and HOW FAR it had driven, off main._track_centreline() - the same
# line the checkpoints were spread along, which is a third source and neither
# clock. Nothing is typed in as an expected distance: the circuit's length is
# summed from that centreline, and the tolerance is one step of this suite's
# own driving plus CheckpointTracker.REACH at each end.
#
#   the boundary   the car is within REACH of checkpoints[0] - the start line
#                  - every time a lap is counted. Before 130 it was about a
#                  twelfth of a circuit short of it.
#   the span       the distance driven during lap 1, and during lap 2, is the
#                  circuit's length. Before 130 lap 1 was ten twelfths.
#
# AND THE THIRD ROW IS THE ONE THE PLAYER SEES. Every lap here is driven at
# one constant step along one line, so the laps must agree with each other;
# the row holds that best_lap_time agrees with ALL of them, which is exactly
# the harm the short first lap did. No lap time is typed in.
#
# THE TIME SCALE IS NOT SET HERE AND THAT IS A CHOICE WITH A REASON (TRAPS 6).
# What is under test is the span, and both sides of every row are in units a
# scale cannot touch - metres, and laps as a fraction of each other. A scale
# here would be a knob that cannot change the answer. The clock question is
# section 3's second half and section 8's, and it is driven at LAP_SCALE
# there.
#
# AGAINST THE PRE-130 TRACKER ALL THREE ROWS FAIL. The numbers are in
# HANDOVER's 130 entry.
func _a_lap_is_a_whole_lap() -> void:
	main._handle_request("/drive")
	await process_frame
	if main.car == null:
		_check(false, "a /drive put a car on the circuit to drive laps on")
		return
	var line: PackedVector3Array = main._track_centreline()
	if line.size() < CheckpointTracker.CHECKPOINT_COUNT:
		_check(false, "and the circuit has a centreline to drive (%d points)" % line.size())
		return
	_check(main.checkpoint_tracker.lap_count == 0,
		"and re-armed the tracker, so these laps are timed from zero (lap_count %d)" % main.checkpoint_tracker.lap_count)

	# Nobody steers in a headless test, so the car is moved along the line the
	# checkpoints were spread along and frozen, because a loose car drifts off
	# the point it was put on. The step is under REACH so no checkpoint is
	# stepped over, and it is CONSTANT, which is what makes the laps
	# comparable to each other without a number being typed in.
	main.car.freeze = true
	var n := line.size()
	var circuit := 0.0
	for i in n:
		circuit += line[i].distance_to(line[(i + 1) % n])
	var spacing := circuit / float(n)
	var step := clampi(int(floor(STEP_METRES / maxf(spacing, 0.01))), 1, 15)

	var timed: Array = []
	var off_line: Array = []
	var rounds: Array = []
	var driven := 0.0
	var driven_at_start := -1.0
	var counted := 0
	var at := 0
	var steps := 0
	var limit := int(float(LAP_BOUNDARY_LAPS + 2) * float(n) / float(step)) + 200
	while counted < LAP_BOUNDARY_LAPS and steps < limit:
		var was: Vector3 = line[at % n]
		at += step
		steps += 1
		var now: Vector3 = line[at % n]
		driven += was.distance_to(now)
		main.car.global_position = now + Vector3(0.0, 0.5, 0.0)
		await process_frame
		if driven_at_start < 0.0 and main.checkpoint_tracker.lap_started:
			driven_at_start = driven
		if main.checkpoint_tracker.lap_count > counted:
			counted = main.checkpoint_tracker.lap_count
			timed.append(main.checkpoint_tracker.last_lap_time)
			rounds.append(driven)
			off_line.append(Vector2(now.x - line[0].x, now.z - line[0].z).length())

	var best: float = main.checkpoint_tracker.best_lap_time

	_check(counted == LAP_BOUNDARY_LAPS,
		"%d laps were counted as the car drove them at %.1f m a step over a %.0f m circuit (counted %d in %d steps)" % [
			LAP_BOUNDARY_LAPS, step * spacing, circuit, counted, steps])
	if timed.size() < 2 or driven_at_start < 0.0:
		main._stop_driving()
		return

	# THE BOUNDARY. Where the car was, in metres from the start line, each
	# time a lap was counted.
	for k in off_line.size():
		_check(float(off_line[k]) <= CheckpointTracker.REACH,
			"lap %d was counted AT the start line: %.1f m from it, REACH is %.1f m" % [
				k + 1, float(off_line[k]), CheckpointTracker.REACH])

	# THE SPAN. How far the car drove during the lap, against the circuit this
	# suite measured for itself. One step at each end plus REACH at each end is
	# the whole of the slack in a lap detected by proximity.
	var allowed: float = float(step) * spacing * 2.0 + CheckpointTracker.REACH * 2.0
	var lap1: float = float(rounds[0]) - driven_at_start
	_check(absf(lap1 - circuit) <= allowed,
		"lap 1 is a WHOLE lap: %.1f m driven over it against a %.1f m circuit, allowed %.1f m off" % [
			lap1, circuit, allowed])
	for k in range(1, rounds.size()):
		var lap: float = float(rounds[k]) - float(rounds[k - 1])
		_check(absf(lap - circuit) <= allowed,
			"and so is lap %d: %.1f m against %.1f m" % [k + 1, lap, circuit])

	# WHAT THE PLAYER IS SHOWN. Every lap was driven at the same step along the
	# same line, so every lap must agree with the best of them.
	for k in timed.size():
		_check(best > 0.0 and absf(float(timed[k]) - best) <= best * LAP_AGREE,
			"the best lap the player is shown is a lap he drove: lap %d read %.4f s against a best of %.4f s, allowed %.4f s off" % [
				k + 1, float(timed[k]), best, best * LAP_AGREE])

	var shown := "Lap %d completed in %s (best %s)" % [
		counted,
		main.checkpoint_tracker.get_formatted_time(float(timed[timed.size() - 1])),
		main.checkpoint_tracker.get_formatted_time(best),
	]
	_check(_history().contains(shown),
		"and the last of them reached him through the handler, with the tracker's own times: " + shown)

	notes.append("LAP SPAN: %d laps at %.1f m a step over %.0f m: driven %s m, timed %s s, best %.4f s, counted %s m from the line" % [
		counted, step * spacing, circuit,
		str(([("%.1f" % lap1)] + range(1, rounds.size()).map(func(k): return "%.1f" % (float(rounds[k]) - float(rounds[k - 1]))))),
		str(timed.map(func(t): return "%.4f" % float(t))), best,
		str(off_line.map(func(d): return "%.1f" % float(d)))])

	main._stop_driving()


# --- 10. the standing start, DRIVEN rather than teleported (132) ---
#
# WHAT THIS HOLDS AND WHY NOTHING ELSE HOLDS IT. TRAPS 125 is about a
# boundary event detected by proximity: `at_line` answers *where is the car*,
# and a lap boundary asks *did it pass*. Those differ in exactly one place -
# a car standing still inside the zone - and that is where a start line is.
# 130 fixed it with `_left_line` / `_began_at_line`: the line counts as
# reached only once the car has been CLEAR of it, and a car that began inside
# it is timed from the moment it drove off. Every row that has ever held that
# rule moved the car by assignment. Section 3 freezes it and sets
# `global_position`; section 9 steps it along the centreline frozen; section 8
# steps it through a whole race. A teleport out of the zone is not a car
# driving out of it: it skips the acceleration, the suspension settling and
# the seconds a player actually spends sitting on the line, which is the span
# the fault put into lap 1.
#
# SO THIS SECTION NEVER WRITES A POSITION. `/drive` places the car - that
# placement is the premise and is asserted, not assumed - and then the car is
# driven by its own `auto_drive` throttle through its own `_physics_process`,
# which is the same door the race director drives the opponents through
# (`race_director.gd:83`) and the one `physics_test` drives its cars
# through. `behaviour_test` uses the SIBLING door on the walker
# (`walker.gd:79`, `auto_walk`), which is not this one and is said so rather
# than rounded up. Nothing here types a distance or a time in.
#
# THE FOUR THINGS IT ASKS, IN ORDER:
#
#   the premise    `/drive` really does put the car inside the line's REACH,
#                  so there is a standing start here to be got wrong at all.
#   the wait       held at ZERO throttle for STANDING_HOLD_FRAMES of real
#                  physics, the lap clock does not start. This is the row the
#                  first version of 130's fix FAILED: it started the clock on
#                  the frame the car was placed, and section 8 read lap 1 at
#                  3.0992 s against 0.0833 s for laps 2 and 3 because the
#                  clock had run through the countdown. The numbers are in
#                  HANDOVER's 130 entry.
#   the moving off the clock starts only after the car has MOVED, and it is
#                  measured against how far the car drifted while it was
#                  held - its own suspension settling, measured in the same
#                  run - rather than against a number typed in here.
#   the clock      the tracker's clock DID advance through the wait, and the
#                  lap's start is AFTER that, so the wait is not inside lap 1.
#                  The first of those two is a guard and is labelled one
#                  below (TRAPS 6); the second cannot hold without it.
#
# THE SECOND MEMBER OF THE CLASS CANNOT BE DRIVEN FROM A TEST, AND THAT IS
# MEASURED RATHER THAN ASSUMED (TRAPS 11, TRAPS 14). TRAPS 125 names two
# places that put the car inside the line's REACH before the player has
# driven anywhere: `/drive`, on the line, which is this section; and `/race`,
# which places the player a row back with `_behind(GRID_SPACING * 2)` -
# `race_director.gd:96`-`97`, 20 m of centreline, measured at 23.41 m from
# the line in the plane with one opponent. The `/race` one is NOT held here
# because a real throttle cannot reach it: `race_director.gd:140`-`141` runs
# `if racing and _player.auto_drive: _player.auto_drive = false` in
# `_physics_process`, so the director takes the car back from `auto_drive`
# every physics frame for as long as the race runs. Measured in a throwaway
# copy outside the repository (TRAPS 50): with `auto_drive = true` and
# `auto_throttle = 1.0` re-asserted before every one of 3000 physics frames,
# `auto_drive` read false at every sample and the car moved 1.29 m in total
# at 0.0 km/h - the same 1.29 m it drifted standing still. The reading is in
# HANDOVER's 132 entry. That is the product behaving as written - in a race
# the player drives - and it is the reason section 8 steps the car instead.
# Nothing here changes it.
#
# THE TIME SCALE IS NOT SET, FOR THE SAME REASON SECTION 9 GIVES. Both sides
# of every row below are in units a scale cannot touch: metres, physics
# frames, and one duration compared against another duration from the same
# clock.
func _a_standing_start_is_driven() -> void:
	main._handle_request("/drive")
	await process_frame
	if main.car == null:
		_check(false, "a /drive put a car on the start line to drive off")
		return
	var t: CheckpointTracker = main.checkpoint_tracker
	if t.checkpoints.size() < CheckpointTracker.CHECKPOINT_COUNT:
		_check(false, "and spread the checkpoints the line is one of (%d)" % t.checkpoints.size())
		main._stop_driving()
		return

	var placed: Vector3 = main.car.global_position
	var tick := 1.0 / float(Engine.physics_ticks_per_second)

	# THE PREMISE. If /drive stopped placing the car inside the line's REACH
	# there would be no standing start to get wrong, and the three rows under
	# this one would pass without holding anything.
	_check(_from_line(t, placed) <= CheckpointTracker.REACH,
		"/drive placed the car INSIDE the start line's REACH, which is what makes this a standing start: %.2f m from it, REACH is %.1f m" % [
			_from_line(t, placed), CheckpointTracker.REACH])
	_check(not t.lap_started,
		"and no lap is timing on the frame it was placed")

	# THE WAIT. The car's own throttle, held at zero: gravity, suspension and
	# drag all run, and nothing drives it. This is a player sitting on the
	# line before he moves.
	main.car.auto_drive = true
	main.car.auto_steer = 0.0
	main.car.auto_throttle = 0.0
	var drift := 0.0
	var started_while_held := false
	var held := 0
	while held < STANDING_HOLD_FRAMES:
		await physics_frame
		held += 1
		drift = maxf(drift, placed.distance_to(main.car.global_position))
		if t.lap_started:
			started_while_held = true
	var waited_from_line := _from_line(t, main.car.global_position)
	var clock_at_go: float = t._clock

	_check(waited_from_line <= CheckpointTracker.REACH,
		"and after %d physics frames of ZERO throttle it is still inside that REACH, so the wait happened where it matters: %.2f m from the line, drifted %.3f m settling" % [
			held, waited_from_line, drift])
	_check(not started_while_held,
		"the lap clock did NOT start while the car stood on the line - not on any of those %d frames" % held)

	# A GUARD, LABELLED (TRAPS 6). The clock there is right today, so this
	# cannot fail against this tree. It is here because the row under it is a
	# subtraction, and a subtraction from a clock that never ran would pass
	# while holding nothing.
	_check(clock_at_go >= float(held) * tick * CLOCK_RAN,
		"GUARD: the tracker's own clock advanced through the wait: %.4f s against the %.4f s the suite held it for" % [
			clock_at_go, float(held) * tick])

	# THE MOVING OFF. Full throttle, and the only thing read is WHEN
	# lap_started first goes true and where the car was at that moment.
	main.car.auto_throttle = 1.0
	var frames := 0
	var at_frame := -1
	var at_moved := 0.0
	var at_from_line := 0.0
	var lap_start := 0.0
	while frames < STANDING_DRIVE_FRAMES and at_frame < 0:
		await physics_frame
		frames += 1
		if t.lap_started:
			at_frame = frames
			at_moved = placed.distance_to(main.car.global_position)
			at_from_line = _from_line(t, main.car.global_position)
			lap_start = t._lap_start

	_check(at_frame > 0,
		"and real throttle DID start it: the lap clock started %d physics frames after the throttle was opened" % at_frame)
	if at_frame < 0:
		notes.append("STANDING START: no lap started in %d frames at full throttle, %.2f m driven" % [
			frames, placed.distance_to(main.car.global_position)])
		main._stop_driving()
		return

	_check(at_moved > drift,
		"it started AFTER the car MOVED and not on the frame it was placed: %.2f m driven by then against %.3f m of drift while it was held" % [
			at_moved, drift])
	_check(at_from_line > CheckpointTracker.REACH,
		"and the car was CLEAR of the line when it started, which is the rule 130 wrote: %.2f m from it, REACH is %.1f m" % [
			at_from_line, CheckpointTracker.REACH])
	_check(lap_start >= clock_at_go,
		"so the wait is NOT inside lap 1: the lap is timed from %.4f s, and the clock already read %.4f s when the throttle was opened" % [
			lap_start, clock_at_go])

	notes.append("STANDING START, DRIVEN: held %d frames at zero throttle (drifted %.3f m, %.2f m from the line, clock %.4f s), then full throttle; lap clock started at frame %d, %.2f m driven, %.2f m from the line, _lap_start %.4f s" % [
		held, drift, waited_from_line, clock_at_go, at_frame, at_moved, at_from_line, lap_start])

	main._stop_driving()


# --- 11. the OTHER two places a car starts inside the line (133) ---
#
# THE CLASS, AND IT HAS THREE MEMBERS AND NOT TWO. TRAPS 125 is about a
# boundary event detected by proximity: `at_line` answers *where is the car*
# and a lap boundary asks *did it pass*, and those differ in exactly one
# place - a car standing still inside the zone, which is where a start line
# is. It names TWO placements of the player's car inside the line's REACH,
# `/drive` and the `/race` grid, and `checkpoint_tracker.gd:33`-`43` names the
# same two. Every `place_at` call on the player's car in `scripts/` was read
# this commit and there are THREE:
#
#   main.gd:728           `/drive`, on the line - section 10 drives this one.
#   race_director.gd:97   the `/race` grid, a row behind the line.
#   main.gd:265           A WORLD REBUILT WHILE DRIVING. `_track_centreline()`
#                         is re-spread over the new circuit, the tracker is
#                         re-initialised at :261, and then the car is put back
#                         on the new start line at :265 - inside REACH, from a
#                         standstill, with the clock re-armed. Named by
#                         neither document, held by no row, and reachable by
#                         typing one command while driving.
#
# (`race_director.gd:89` and `:333` are also `place_at` calls and are NOT in
# the class: :89 places an OPPONENT, and :333 is `_recover`, which is reached
# only from `_drive(r, ...)` and `_physics_process` calls that only for
# `r["car"] != _player` - so neither can move the car the tracker is reading.
# Said rather than rounded up.)
#
# WHY THE GRID IS HELD GEOMETRICALLY AND NOT UNDER THROTTLE, WHICH IS A
# MEASUREMENT AND NOT A PREFERENCE (TRAPS 11, TRAPS 14). A test cannot drive
# the player's car while a race is running: `race_director.gd:140`-`141` runs
# `if racing and _player.auto_drive: _player.auto_drive = false` in
# `_physics_process`, so the director takes the `auto_drive` door back every
# physics frame and re-emits "GO!" each time something sets it. 132 measured
# it - false at every one of 3000 samples, 0.0 km/h, and the only travel was
# the 1.29 m the car drifts standing still - and TRAPS 127 is that reading.
# That is the product behaving as designed: in a race, the player drives. The
# limitation is the HARNESS's and not the car's, and nothing in `scripts/` is
# changed here to make a row reachable.
#
# SO WHAT IS HELD IS THE HALF THAT NEEDS NO THROTTLE, AND IT IS THE HALF THE
# FAULT WAS IN: the car is placed INSIDE the line's REACH, and no lap is
# timing at any point in the wait that follows. For the grid that wait is the
# countdown the player sits out, which is exactly the span the fault put into
# lap 1 - section 8 read lap 1 at 3.0992 s against 0.0833 s for laps 2 and 3
# against the first version of 130's fix, because the clock had run through
# the whole 3 s of it.
#
# NOTHING HERE READS `_left_line` OR `_began_at_line`, AND THAT IS DELIBERATE.
# Those two fields are 130's fix. A section that reads them cannot be run
# against the version of the tracker that lacks them, so it cannot be shown
# red against the fault it is about. Every row below reads only fields that
# exist on both: `lap_started`, `lap_count`, `checkpoints` and `_clock`.
#
# AND THE CONTROL IS PRODUCTION'S OWN LINE (TRAPS 6). "lap_started stayed
# false" is also what a tracker that was never shown the car would say.
# `main.gd:858` calls `checkpoint_tracker.update_progress(car.global_position)`
# and `main.gd:859`-`862` writes "Race starts in N..." onto the status label
# in the SAME `_process`, one line further down and inside a branch that
# requires the race to be running - so a status label reading that sentence is
# production saying it ran past the call, on a frame of the countdown. It is
# sampled on the countdown frames themselves rather than inferred, and the
# count of frames it was seen on is asserted and printed.
func _the_other_two_standing_starts() -> void:
	# --- 11a: the /race grid ---
	main._handle_request("/drive")
	await process_frame
	if main.car == null:
		_check(false, "a /drive before the grid rows put a car on the circuit")
		return
	main._handle_request("/race %d" % RACE_OPPONENTS)
	await process_frame
	_check(main.race.running,
		"/race %d formed a grid on the player's circuit" % RACE_OPPONENTS)
	if not main.race.running:
		main._stop_driving()
		return
	var t: CheckpointTracker = main.checkpoint_tracker
	if t.checkpoints.size() < CheckpointTracker.CHECKPOINT_COUNT:
		_check(false, "and the checkpoints the line is one of are spread (%d)" % t.checkpoints.size())
		main._stop_driving()
		return

	var tick := 1.0 / float(Engine.physics_ticks_per_second)
	var grid: Vector3 = main.car.global_position
	var grid_from_line := _from_line(t, grid)
	var clock_at_grid: float = t._clock
	# The tracker's clock is advanced in _physics_process and the loop below
	# steps PROCESS frames, because update_progress is called from
	# main.gd's _process. Without --fixed-fps those two counts are not the
	# same, so the span the guard compares against is read off the engine's
	# own physics-frame counter and never off the loop's.
	var physics_at_grid := Engine.get_physics_frames()

	# THE PREMISE. `_behind(GRID_SPACING * 2)` is 20 m of CENTRELINE at one
	# opponent, and how far that is in the plane is the circuit's shape to
	# decide - so it is measured here and not typed in. If the grid ever moved
	# outside REACH there would be no standing start on it to get wrong, and
	# every row under this one would pass while holding nothing.
	_check(grid_from_line <= CheckpointTracker.REACH,
		"/race placed the player's car INSIDE the start line's REACH, which is what makes the grid a standing start: %.2f m from it, REACH is %.1f m" % [
			grid_from_line, CheckpointTracker.REACH])
	_check(main.race.countdown_left() > 0.0,
		"and there is a countdown still to sit out - %.2f s of RaceDirector.COUNTDOWN %.1f" % [
			main.race.countdown_left(), RaceDirector.COUNTDOWN])
	_check(not t.lap_started,
		"and no lap is timing on the frame the grid was formed")

	# THE WAIT. Nothing here writes a position, a throttle or a flag: the
	# director holds the grid itself (race_director.gd:99-101, auto_drive with
	# zero throttle), and this loop only watches.
	var frames := 0
	var limit := int(ceil(RaceDirector.COUNTDOWN / tick)) * GRID_HOLD_MULTIPLE
	var started_in_countdown := false
	var counted_in_countdown := 0
	var left_reach := false
	var furthest := grid_from_line
	var said_the_countdown := 0
	while frames < limit and main.race.countdown_left() > 0.0:
		await process_frame
		frames += 1
		if t.lap_started:
			started_in_countdown = true
		counted_in_countdown = maxi(counted_in_countdown, t.lap_count)
		var away := _from_line(t, main.car.global_position)
		furthest = maxf(furthest, away)
		if away > CheckpointTracker.REACH:
			left_reach = true
		if main.status_label.text.begins_with(GRID_SENTENCE):
			said_the_countdown += 1
	var clock_at_go: float = t._clock
	var physics_in_countdown := int(Engine.get_physics_frames() - physics_at_grid)

	_check(main.race.countdown_left() == 0.0,
		"and the countdown really ran out rather than this loop giving up on it - %d frames of a %d-frame ceiling" % [
			frames, limit])
	_check(said_the_countdown > 0,
		"THE CONTROL, AND IT IS PRODUCTION'S OWN: the status label read \"%s...\" on %d of those %d frames, which is main.gd:859 one line PAST the update_progress call at :858 - so the tracker was shown the car on a countdown frame" % [
			GRID_SENTENCE, said_the_countdown, frames])
	_check(not left_reach,
		"and the car stayed INSIDE the line's REACH for the whole wait, so the wait happened where it matters - furthest %.2f m of REACH %.1f m, drifting %.3f m off the grid" % [
			furthest, CheckpointTracker.REACH, grid.distance_to(main.car.global_position)])
	_check(not started_in_countdown,
		"THE ROW: no lap clock started on ANY of those %d frames of countdown - which is the span the first version of 130's fix put inside lap 1" % frames)
	_check(counted_in_countdown == 0,
		"and no lap was COUNTED on the grid either (%d)" % counted_in_countdown)

	# A GUARD, LABELLED (TRAPS 6). The tracker's clock is right today, so this
	# cannot fail against this tree. It is here because "nothing started" is
	# also true of a tracker whose clock never ran, and a reader cannot tell
	# those apart from the rows above alone.
	_check(clock_at_go - clock_at_grid >= float(physics_in_countdown) * tick * CLOCK_RAN,
		"GUARD: and the tracker's own clock advanced through that wait - %.4f s against the %.4f s of PHYSICS frames the engine counted over it" % [
			clock_at_go - clock_at_grid, float(physics_in_countdown) * tick])
	# The note prints what was MEASURED and not what was asserted: a note
	# reading "lap_started false throughout" is a sentence that stays true on
	# a red run, which is the shape TRAPS 14 is about arriving in a print.
	notes.append("GRID START: /race placed the car %.2f m from the line (REACH %.1f); %d process frames of countdown watched over %d physics frames, furthest %.2f m, lap_started went true on one of them: %s, laps counted %d, tracker clock %.4f -> %.4f s, status label said \"%s\" on %d frames" % [
		grid_from_line, CheckpointTracker.REACH, frames, physics_in_countdown, furthest,
		started_in_countdown, counted_in_countdown,
		clock_at_grid, clock_at_go, GRID_SENTENCE, said_the_countdown])
	main._stop_driving()
	await process_frame

	# --- 11b: the third member - a world rebuilt while driving ---
	#
	# Reached by typing one CREATE_TRACK while driving. The length differs
	# from the standing world's so the circuit really is rebuilt, and which
	# one is standing afterwards is read off `_first_section_length()` rather
	# than assumed.
	main._handle_request("/drive")
	await process_frame
	if main.car == null:
		_check(false, "a /drive before the rebuild rows put a car on the circuit")
		return
	var before := _first_section_length()
	var rebuild_to := C_LENGTH if before != C_LENGTH else A_LENGTH
	main._handle_request(_track(rebuild_to))
	await process_frame
	await process_frame
	_check(main.driving and main.car != null,
		"a CREATE_TRACK typed WHILE DRIVING leaves the player driving, which is what makes main.gd:265 reachable")
	if not main.driving or main.car == null:
		main._stop_driving()
		return
	_check(_first_section_length() == rebuild_to and rebuild_to != before,
		"and it really is a different circuit under the car - first straight %d m, was %d m" % [
			_first_section_length(), before])

	t = main.checkpoint_tracker
	if t.checkpoints.size() < CheckpointTracker.CHECKPOINT_COUNT:
		_check(false, "and the new circuit's checkpoints are spread (%d)" % t.checkpoints.size())
		main._stop_driving()
		return
	var replaced: Vector3 = main.car.global_position
	var replaced_from_line := _from_line(t, replaced)
	var clock_at_replace: float = t._clock
	var physics_at_replace := Engine.get_physics_frames()

	_check(replaced_from_line <= CheckpointTracker.REACH,
		"THE THIRD MEMBER, AND NEITHER DOCUMENT NAMED IT: the rebuild put the car back INSIDE the new line's REACH from a standstill - %.2f m from it, REACH is %.1f m" % [
			replaced_from_line, CheckpointTracker.REACH])
	_check(not t.lap_started and t.lap_count == 0,
		"and the re-armed tracker is timing nothing on the frame it was replaced (lap_started %s, lap_count %d)" % [
			t.lap_started, t.lap_count])

	# The same wait section 10 holds on the line, at the car's own zero
	# throttle, on the placement nothing had held.
	main.car.auto_drive = true
	main.car.auto_steer = 0.0
	main.car.auto_throttle = 0.0
	var held := 0
	var started_while_replaced := false
	var drift := 0.0
	while held < REBUILD_HOLD_FRAMES:
		await process_frame
		held += 1
		drift = maxf(drift, replaced.distance_to(main.car.global_position))
		if t.lap_started:
			started_while_replaced = true
	var clock_after_hold: float = t._clock
	var physics_in_hold := int(Engine.get_physics_frames() - physics_at_replace)

	_check(_from_line(t, main.car.global_position) <= CheckpointTracker.REACH,
		"and after %d frames of ZERO throttle it is still inside that REACH - %.2f m from the line, drifted %.3f m settling" % [
			held, _from_line(t, main.car.global_position), drift])
	_check(not started_while_replaced,
		"THE ROW: no lap clock started on ANY of those %d frames either - the rule 130 wrote holds at the placement neither TRAPS 125 nor checkpoint_tracker.gd names" % held)
	_check(clock_after_hold - clock_at_replace >= float(physics_in_hold) * tick * CLOCK_RAN,
		"GUARD: and the tracker's clock advanced through THAT wait too - %.4f s against the %.4f s of PHYSICS frames the engine counted over it" % [
			clock_after_hold - clock_at_replace, float(physics_in_hold) * tick])
	notes.append("REBUILT WHILE DRIVING: first straight %d -> %d m, car replaced %.2f m from the new line (REACH %.1f), held %d process frames over %d physics frames at zero throttle (drifted %.3f m), lap_started went true on one of them: %s, tracker clock %.4f -> %.4f s" % [
		before, rebuild_to, replaced_from_line, CheckpointTracker.REACH, held, physics_in_hold, drift,
		started_while_replaced, clock_at_replace, clock_after_hold])
	main._stop_driving()


# --- 12. the tripwire: nothing failed when the class gained a member (134) ---
#
# THE ONE THING THIS SECTION ASSERTS, said before the rows so it cannot be
# read as more than it is: **the set of `place_at` call sites in `scripts/` is
# the set `PLACE_AT_SITES` carries a reading for, and the subset of them that
# can move the body the lap tracker reads is the three sections 10 and 11
# hold.** It is a TRIPWIRE and not a behaviour row, and the difference is
# labelled rather than left to be inferred (TRAPS 6): nothing a player does
# can make it fail, and no amount of it passing says a placement is handled
# correctly - sections 10 and 11 say that, and they were seen red. What it
# says is that the CLASS cannot grow, shrink or be renamed in silence, which
# is the one thing that did happen and that nothing noticed for two commits.
#
# THAT IT CAN FAIL AGAINST A LEGAL TREE IS MEASURED AND NOT ASSERTED
# (TRAPS 6, and the shape 133 got right for `Npc.elapsed`). THREE RED
# READINGS, each in a throwaway copy of the repository outside it with its own
# `config/name` (TRAPS 50), and each failed BY NAME:
#
#   a fourth placement  `_restart_lap()` added to `main.gd` - a new door that
#                       puts the car back on the start line, the same two
#                       lines `_start_driving` uses. 8 sites, 5 in main.gd,
#                       and the FAIL names `main.gd::_restart_lap::car` with
#                       the line the door was inserted at.
#   a placement removed `main.gd:661`'s `npc.place_at` commented out. 6 sites,
#                       and the FAIL names the ROW that has no site left.
#   the careless fix    the same fourth placement AND a table row for it
#                       marked `player: true`, with `PLAYER_PLACEMENTS`
#                       unchanged - which is the realistic path, because a
#                       maintainer who sees the first FAIL adds a row. The
#                       per-site rows go green and the CLASS row fails,
#                       printing all four members.
#
# The counts are in HANDOVER's 134 entry. Nothing in `scripts/` was changed in
# this repository to take them.
#
# THE SCAN'S OWN NARROWNESS IS CONTROLLED BELOW, over sources this function
# BUILDS, because TRAPS 106's rule applies before any of it is believed: a
# scan that reached no code would find no sites, every row would have nothing
# to contradict it, and the section would pass by finding nothing. So the
# read is asserted, the file count is asserted, and four properties of the
# scanner are driven over built text: a call is found, `func place_at(` is
# NOT a call, a call that exists only in a comment is not a call, and the
# enclosing function name is the one the call is actually inside.
func _the_class_cannot_grow_in_silence() -> void:
	var files := DirAccess.get_files_at("res://scripts")
	var read := 0
	var sites := {}
	for name in files:
		if not str(name).ends_with(".gd"):
			continue
		var raw := FileAccess.get_file_as_string("res://scripts/%s" % str(name))
		if raw == "":
			continue
		read += 1
		for site in _place_at_sites(_code_of(raw)):
			var row: Dictionary = site
			sites["%s::%s::%s" % [str(name), str(row["func"]), str(row["receiver"])]] = int(row["line"])

	# THE READ, ASKED AT THE READ (085, TRAPS 81). A directory that came back
	# empty and a file that came back empty both leave `sites` empty, and an
	# empty `sites` would satisfy every "has a row" assertion below.
	_check(read >= PLACE_AT_FILES_FLOOR,
		"scripts/ was read as code: %d .gd files, floor %d" % [read, PLACE_AT_FILES_FLOOR])
	_check(sites.size() > 0,
		"and the scan found place_at call sites in them (%d)" % sites.size())

	# EVERY SITE CARRIES A READING. This is the direction an ARRIVAL fails in.
	for key in sites:
		_check(PLACE_AT_SITES.has(str(key)),
			"the place_at call at %s:%d has a row saying whether it can place the body the lap tracker reads" % [
				str(key), int(sites[key])])

	# EVERY READING STILL HAS A SITE. This is the direction a REMOVAL, a
	# rename or a moved call fails in - and a row left standing for a call
	# site that is gone is a claim about the code that has stopped being true
	# (TRAPS 14), so it fails here rather than going unremarked.
	for key in PLACE_AT_SITES:
		_check(sites.has(str(key)),
			"and the row for %s still has a call site in scripts/" % str(key))

	# THE CLASS ITSELF: the subset that can move the body, derived from the
	# table rather than typed, against the three sections 10 and 11 hold.
	var in_class: Array = []
	for key in PLACE_AT_SITES:
		if bool((PLACE_AT_SITES[key] as Dictionary)["player"]):
			in_class.append(str(key))
	in_class.sort()
	var held := PLAYER_PLACEMENTS.duplicate()
	held.sort()
	_check(in_class == held,
		"TRAPS 125's class is the %d placements sections 10 and 11 hold, derived from the table: %s" % [
			held.size(), str(in_class)])

	# AND EVERY MEMBER OF IT IS IN A FILE THIS SUITE ACTUALLY DRIVES, so the
	# list above cannot be satisfied by three rows about code nothing runs.
	for key in held:
		var where := str(key).split("::")[0]
		_check(where == "main.gd" or where == "race_director.gd",
			"and %s is in a file sections 10 and 11 drive through the scene" % str(key))

	# --- the scanner, over sources this function builds (TRAPS 106) ---
	# `one_call` AND NOT `found`, WHICH IS NOT A STYLE CHOICE. The first draft
	# called it `found`, and `_the_scene` has a `var found := 0` that is a
	# counter - so source_scan_test's section 5 classified the three-conjunct
	# assertion below as an equality between two counts of one collection and
	# failed by name, asking for a row in its COUNTER_EQUALITIES. It is not
	# one; it is that scan's own narrowness meeting a name collision, measured
	# and recorded as TRAPS 131. The collision is removed here rather than
	# given a table row, because a row would record an avoidable name as a
	# permanent fact about this file.
	var call_only := "func _somewhere() -> void:\n\tcar.place_at(a, b)\n"
	var one_call := _place_at_sites(call_only)
	_check(one_call.size() == 1
			and str((one_call[0] as Dictionary)["func"]) == "_somewhere"
			and str((one_call[0] as Dictionary)["receiver"]) == "car",
		"the scan reads a place_at call as receiver + enclosing function (%s)" % str(one_call))

	var def_only := "func place_at(pos: Vector3, heading: float) -> void:\n\tpass\n"
	_check(_place_at_sites(def_only).is_empty(),
		"and a `func place_at(` DEFINITION is not a call site, which is why car.gd and walker.gd contribute none")

	var in_comment := _code_of("func _somewhere() -> void:\n\t# car.place_at(a, b)\n\tpass\n")
	_check(_place_at_sites(in_comment).is_empty(),
		"and a call that exists only in a comment is not a call site, because the scan reads what _code_of() leaves")

	var two_funcs := "func _first() -> void:\n\tpass\n\n\nfunc _second() -> void:\n\tplayer.place_at(a, b)\n"
	var later := _place_at_sites(two_funcs)
	_check(later.size() == 1 and str((later[0] as Dictionary)["func"]) == "_second",
		"and the enclosing function is the one the call is inside and not the first in the file (%s)" % str(later))

	# THE NOTE INTERPOLATES AND DOES NOT DESCRIBE (TRAPS 129). The class count
	# is attributed to the TABLE, because that is where it comes from - under
	# the first red reading below the code had FOUR player placements and the
	# table said three, and a note reading "3 of them can place the body" would
	# have been a false sentence about the code printed under a failure. The
	# number of sites carrying no row is printed for the same reason: it is the
	# fault, so the note has to carry it.
	var counts := {}
	var unread := 0
	for key in sites:
		var where := str(key).split("::")[0]
		counts[where] = int(counts.get(where, 0)) + 1
		if not PLACE_AT_SITES.has(str(key)):
			unread += 1
	notes.append("12: %d place_at call sites across %d .gd files of scripts/ (%s); %d with no row here; the table marks %d as able to place the body the lap tracker reads: %s" % [
		sites.size(), read, str(counts), unread, in_class.size(), str(in_class)])


# Every `.place_at(` CALL in the given CODE, as receiver, enclosing function
# and line. A `func place_at(` declaration has no receiver and is not matched,
# which is the one distinction the scan has to make and is driven over built
# text in section 12 rather than trusted.
#
# NOT A PARSER, and narrow in the direction that matters: a receiver written
# as anything but a plain identifier - `_cars[i].place_at(...)` - is NOT
# matched, so this scan can MISS a site and can never invent one. A miss
# shows up as a row in PLACE_AT_SITES with no site, which fails. The
# alternative - a looser regex that matched an expression - would report a
# receiver nobody can key a table by.
func _place_at_sites(code: String) -> Array:
	var out: Array = []
	var call := RegEx.create_from_string("([A-Za-z_][A-Za-z0-9_]*)[\\t ]*\\.place_at[\\t ]*\\(")
	var func_line := RegEx.create_from_string("^[\\t ]*(?:static[\\t ]+)?func[\\t ]+([A-Za-z_][A-Za-z0-9_]*)")
	var current := ""
	var number := 0
	for raw in code.split("\n"):
		var line := str(raw)
		number += 1
		var f := func_line.search(line)
		if f != null:
			current = f.get_string(1)
		for m in call.search_all(line):
			out.append({
				"receiver": (m as RegExMatch).get_string(1),
				"func": current,
				"line": number,
			})
	return out


# How far a point is from the start line, in the plane, which is the same
# measure CheckpointTracker.update_progress uses to decide `at_line`.
func _from_line(t: CheckpointTracker, p: Vector3) -> float:
	return Vector2(p.x - t.checkpoints[0].x, p.z - t.checkpoints[0].z).length()


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
	await _one_race_two_clocks()
	await _a_lap_is_a_whole_lap()
	await _a_standing_start_is_driven()
	await _the_other_two_standing_starts()
	_the_class_cannot_grow_in_silence()

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
