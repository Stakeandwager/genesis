extends SceneTree

# --- 062: the view, which is the one layer nothing had ever measured ---
#
# THE TASK, AND WHERE IT CAME FROM
#
# HANDOVER's "Next action" at 061, in its own words: "The twelve differences
# that are visual, and nothing in this repository can see any of them. [...]
# The question to ask is not 'does the fixture match' any more, it is WHAT IN
# THIS PROJECT IS ONLY EVER TRUE ON A SCREEN, and what would it take to
# measure one of them headless? camera.look_at_from_position and
# _restore_frame are arithmetic and could be asserted without a pixel."
#
# They are, and this file does it. Nothing here draws a pixel or opens a
# window: a frustum is a matrix, a transform is twelve floats, and whether a
# point is inside a frustum is arithmetic that does not care whether anybody
# is looking.
#
# WHAT WAS MEASURED, AND WHAT IT FOUND
#
# GameController has exactly two functions that decide what is on screen:
# _frame_view(), which pulls the camera back far enough to hold the world
# that was just built and grows the ground pad under it, and _restore_view(),
# which puts both back the way the scene has them. Before this file NO SUITE
# READ EITHER. 65 suites, grepped and COUNTED rather than remembered: the word
# "camera" appears in 17 of them and in exactly THREE assertions -
# explore_test's two, that a particular camera is `current`, and
# player_door_test's one, that the controller holds a camera at all. Every
# other appearance is a comment. Nothing read where a camera is, what it is
# aimed at, or what it can see.
#
# ASKED AS A CLASS RATHER THAN AS ONE CALL (TRAPS 11), that turned up a fault
# a player can reach. The rule the two functions are between them keeping is:
#
#   WHEN A REQUEST LEAVES THE WORLD EMPTY, THE VIEW GOES BACK TO THE SCENE'S
#   OWN CAMERA AND THE SCENE'S OWN 200 M PAD.
#
# There are THREE paths that empty the world without building another,
# enumerated by reading every call of _clear_world_node() in
# game_controller.gd rather than from memory, and section 4 holds that count
# so a fourth cannot be added in silence:
#
#   CLEAR_WORLD                  _clear_world()            restores
#   a sectionless CREATE_TRACK   _build_prototype_ring()   restores
#   a PLAN that fails in pass 3  _execute_plan()           DID NOT
#
# (Named by function and not by line. Section 4 finds the lines by reading
# the file, and a line number written into a comment is a claim that goes
# stale the next time anybody inserts a paragraph above it - which is what
# this commit's own eighteen lines of comment did to the first draft of this
# block.)
#
# The third one was the fault, and it is NOT hypothetical - measured in a
# throwaway copy outside the repository (TRAPS 50) before a line was changed,
# with the plan a player meets first: two worlds and no "around" between
# them. Both farms build in pass 3, _place() centres both on the origin,
# neither contains the other, and the plan fails AFTER the standing world has
# been cleared for building. What was left on screen:
#
#   after a 500 m circuit      camera (455.2, 528.0, 238.4), pad 1452 m at (310, -250)
#   after CLEAR_WORLD          camera (0, 90, 110), pad 200 m at origin      <- the scene's
#   after a sectionless build  camera (0, 90, 110), pad 200 m at origin      <- the scene's
#   after the failed plan      camera (455.2, 528.0, 238.4), pad 1452 m at (310, -250)
#                              with world children = 0
#
# A camera and a 1452 m pad still framed on a circuit that is no longer
# there. 040 is the commit that stopped this same function destroying a
# standing world it had not yet decided it could replace; this is the half of
# that path that was only ever visible, which is exactly why it survived 040.
# It is one line in game_controller.gd and section 3 is what holds it.
#
# WHY THE VIEWPORT IS RESIZED, WHICH IS THE PART THAT WOULD HAVE MADE THIS
# SUITE MEANINGLESS (TRAPS 6)
#
# A frustum depends on the aspect ratio. A headless Godot gives the root
# window 64 x 64, which is an aspect no player has ever seen, and the first
# draft of section 2 asked its question at that size: THREE of the four
# corners of a world's footprint were inside the frustum and the fourth was
# off the left edge, at every circuit size tried. That is not a finding about
# Genesis, it is a finding about 64 x 64 - at the size project.godot
# configures, 1152 x 648, all four are inside with room to spare. So the
# viewport is set from the SETTING, never from a literal, and section 2
# asserts that the window actually took the size before it believes anything
# that depends on it.
#
# WHAT THIS FILE DOES NOT PROVE, said here rather than left to be found:
#
#   - THAT ANYTHING IS LEGIBLE, OR LIT, OR THE RIGHT COLOUR. Six of 061's
#     twelve differences are the light, the environment, the camera's place
#     and angle, the panel's anchors and three strings. This file measures
#     the camera's place and angle, which is one of the six, and says nothing
#     about the other five. A world inside the frustum of a scene with no
#     light in it is a black screen, and nothing here would notice.
#   - THAT THE PANELS DO NOT COVER THE WORLD. _frame_view aims right of and
#     nearer than the centre precisely because the command panel covers the
#     bottom and the history and metrics panels cover the right. Where those
#     panels actually end is a Control layout under a CanvasLayer, which is
#     laid out but never drawn here, so this file asserts the world is in the
#     3D frustum and NOT that it is in the part of the frustum a player can
#     see.
#   - THAT A PLAYER CAN SEE THE DIFFERENCE between the scene's camera and the
#     stand-in 061 retired. It asserts they are not the same arithmetic.
#   - ANYTHING ABOUT THE WEB BUILD. The browser's canvas is whatever the page
#     gives it, and no browser has ever run this.

# No scene resource path is written out in this file. It reaches the scene
# through application/run/main_scene, like every other suite since 061, and
# player_door_test holds the rule that the literal lives in exactly one place:
# the file that compares the path with the setting. THE FIRST DRAFT OF THIS
# SUITE CARRIED A SCENE_PATH CONSTANT, SPELLED OUT IN FULL, THAT IT NEVER
# USED, and 061's guard failed naming this file - which is 061's enumeration
# doing exactly the job TRAPS 59 was written about, on the first new suite
# written after it.

# One smallest valid request per world kind. Section 1 asserts that EVERY
# command WorldRegistry knows about has one, so a fourth kind of world cannot
# be added without this suite asking the same question of it (TRAPS 11).
const SAMPLE := {
	"CREATE_TRACK": '{"command": "CREATE_TRACK", "parameters": {"mode": "circuit", "sections": [{"type": "straight", "length": 300}, {"type": "corner", "radius": 60, "angle": 90}, {"type": "straight", "length": 300}, {"type": "corner", "radius": 60, "angle": 90}, {"type": "straight", "length": 300}, {"type": "corner", "radius": 60, "angle": 90}, {"type": "straight", "length": 300}, {"type": "corner", "radius": 60, "angle": 90}]}}',
	"CREATE_FARM": '{"command": "CREATE_FARM", "parameters": {"zones": [{"type": "barn", "width": 40, "depth": 40}, {"type": "pasture", "width": 60, "depth": 60}]}}',
	"CREATE_DUNGEON": '{"command": "CREATE_DUNGEON", "parameters": {"rooms": [{"name": "entrance", "width": 12, "depth": 12}, {"name": "store", "width": 12, "depth": 12}], "doors": [[1, 2]]}}',
}

# A two-world plan with no "around". Both worlds are placed on the origin,
# neither contains the other, and the plan fails in pass 3 - after the
# standing world has been cleared for building. The one path in the class
# that did not put the view back.
const PLAN_FAILS_LATE := '{"command": "PLAN", "parameters": {"steps": [{"command": "CREATE_FARM", "parameters": {"zones": [{"type": "barn", "width": 40, "depth": 40}]}}, {"command": "CREATE_FARM", "parameters": {"zones": [{"type": "barn", "width": 60, "depth": 60}]}}]}}'

# A plan whose second step cannot be worked out at all. It fails in PASS 1,
# before anything is cleared, so the standing world AND its framing must both
# survive untouched. 040's rule, asked from the view's side.
const PLAN_FAILS_EARLY := '{"command": "PLAN", "parameters": {"steps": [{"command": "CREATE_FARM", "parameters": {"zones": [{"type": "barn", "width": 40, "depth": 40}]}}, {"command": "CREATE_FARM", "parameters": {"zones": [{"type": "nonsense", "width": 40, "depth": 40}]}}]}}'

var main: Node3D
var asserted := 0
var bad := 0
var lines: Array = []

# The scene's own values, read off a fresh instance of the scene the game
# launches rather than written out here as literals. Everything section 0 and
# section 3 assert about "back where it started" is compared against these.
var scene_camera_transform: Transform3D
var scene_camera_far := 0.0
var scene_camera_near := 0.0
var scene_ground_size := Vector3.ZERO
var scene_ground_position := Vector3.ZERO


func _check(ok: bool, what: String) -> void:
	asserted += 1
	if ok:
		lines.append("PASS  " + what)
	else:
		bad += 1
		lines.append("  FAIL  " + what)


func _initialize() -> void:
	_run.call_deferred()


# 061: the scene the game launches, through the setting rather than by path.
func _make_main() -> void:
	main = load(str(ProjectSettings.get_setting("application/run/main_scene"))).instantiate()
	get_root().add_child(main)


func _type(text: String) -> void:
	main._handle_request(text)
	await process_frame
	await process_frame


func _camera() -> Camera3D:
	return main.controller.camera


func _ground() -> CSGBox3D:
	return main.controller.ground_box


func _near(a: float, b: float, tolerance := 0.01) -> bool:
	return absf(a - b) <= tolerance


# The world's real footprint in the scene, taken off the geometry that is
# standing rather than off any number the controller reported about it. A
# camera framing the bounds a module CLAIMED, while the nodes stand
# somewhere else, would pass an assertion written the other way round.
func _world_footprint() -> AABB:
	var out := AABB()
	var first := true
	var stack: Array = [main.controller.world_node]
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		for child in node.get_children():
			stack.append(child)
		if not (node is VisualInstance3D):
			continue
		var box: AABB = (node as VisualInstance3D).get_aabb()
		var world := (node as Node3D).global_transform
		for i in 8:
			var corner: Vector3 = world * (box.position + Vector3(
				box.size.x * float(i & 1),
				box.size.y * float((i >> 1) & 1),
				box.size.z * float((i >> 2) & 1)))
			if first:
				out = AABB(corner, Vector3.ZERO)
				first = false
			else:
				out = out.expand(corner)
	return out


# The four corners of a footprint on the ground plane.
func _footprint_corners(box: AABB) -> Array:
	return [
		Vector3(box.position.x, 0.0, box.position.z),
		Vector3(box.position.x + box.size.x, 0.0, box.position.z),
		Vector3(box.position.x, 0.0, box.position.z + box.size.z),
		Vector3(box.position.x + box.size.x, 0.0, box.position.z + box.size.z),
	]


func _view_is_the_scene_s(label: String) -> void:
	var camera := _camera()
	var ground := _ground()
	_check(camera.transform.is_equal_approx(scene_camera_transform),
		"%s: the camera is back where the scene has it (%s)" % [label, str(camera.transform.origin)])
	_check(_near(camera.far, scene_camera_far) and _near(camera.near, scene_camera_near, 0.0001),
		"%s: the camera's near and far are back to the scene's (%.3f, %.1f)" % [label, camera.near, camera.far])
	_check(ground.size.is_equal_approx(scene_ground_size) and ground.position.is_equal_approx(scene_ground_position),
		"%s: the ground pad is back to the scene's %.0f m at %s" % [label, ground.size.x, str(ground.position)])


# --- 0. what the controller captured, and whose camera it is ---
#
# original_camera_transform is the whole of what /view and every cleared
# world return to. Until 061 every suite that stood main.gd up built its own
# camera - at (0, 80, 120) and LEVEL - so this value had never once been the
# game's in a test run. It is asserted against a fresh instance of the scene
# rather than against numbers written here, so the day somebody moves the
# camera in the editor this says what moved and not that a literal is stale.
func _what_was_captured() -> void:
	var controller: GameController = main.controller
	_check(controller.camera != null and controller.ground_box != null,
		"the controller found the scene's camera and ground pad")
	_check(controller.original_camera_transform.is_equal_approx(scene_camera_transform),
		"the captured camera transform IS the scene's: origin %s" % str(controller.original_camera_transform.origin))
	_check(_near(controller.original_camera_far, scene_camera_far)
			and _near(controller.original_camera_near, scene_camera_near, 0.0001),
		"the captured near and far ARE the scene's (%.3f, %.1f)" % [controller.original_camera_near, controller.original_camera_far])
	_check(controller.original_ground_size.is_equal_approx(scene_ground_size)
			and controller.original_ground_position.is_equal_approx(scene_ground_position),
		"the captured ground pad IS the scene's %.0f m at %s" % [controller.original_ground_size.x, str(controller.original_ground_position)])

	# main.gd shows an unrecorded circuit at startup, which FRAMES the view.
	# So the capture has to happen before that, and this is the assertion
	# that says it did: the thing /view returns to is the scene's camera and
	# not the first world's framing.
	_check(not _camera().transform.is_equal_approx(scene_camera_transform),
		"the startup circuit has already moved the live camera, so the capture was not of a framed view")

	# The scene's camera is PITCHED DOWN. This is one of 061's twelve
	# differences and the only one of the six visual ones anything can read:
	# the stand-in's camera was level, so -Z was (0, 0, -1) and its basis.z.y
	# was 0. A level camera at (0, 90, 110) looks out over the horizon and
	# the world is not in front of it at all.
	_check(scene_camera_transform.basis.z.y > 0.1,
		"the scene's camera is pitched down towards the ground, not level (basis.z.y = %.4f)" % scene_camera_transform.basis.z.y)
	# And what it is pitched at is arithmetic, not a judgement: the basis is a
	# rotation about X, so the pitch is readable straight off it.
	var pitch := rad_to_deg(asin(scene_camera_transform.basis.z.y))
	_check(pitch > 20.0 and pitch < 70.0,
		"the scene's camera looks down at %.1f deg, which is between a horizon and a plan view" % pitch)


# --- 1. the framing arithmetic, solved back out of what it set ---
#
# _frame_view takes a centre and a span and sets FIVE things from them: the
# pad's size, the pad's position, the camera's far, the camera's near and the
# camera's transform. This solves the span and the centre back out of the
# camera and then asks whether the other four agree with them. If the pad
# were ever centred on one world and the camera aimed at another - which is
# what a plan step or a stale bounds read would do - these are the
# assertions that cannot both pass.
#
# Every constant comes from GameController, never retyped here. A test that
# hard-codes 0.80 passes after somebody changes FRAME_HEIGHT and means
# nothing (TRAPS 28).
func _framing_is_consistent(label: String) -> void:
	var camera := _camera()
	var ground := _ground()
	var span: float = camera.transform.origin.y / GameController.FRAME_HEIGHT
	_check(span > 0.0, "%s: the camera stands above the world (span %.1f m)" % [label, span])

	var aim := camera.transform.origin - Vector3(0.0, span * GameController.FRAME_HEIGHT, span * GameController.FRAME_DISTANCE)
	var centre := aim - Vector3(span * GameController.FRAME_SHIFT_RIGHT, 0.0, span * GameController.FRAME_SHIFT_NEAR)

	# The camera is actually LOOKING at the point it was placed to look at.
	# look_at_from_position sets a basis; this is the half of the call that a
	# position assertion alone would not notice.
	var forward := -camera.transform.basis.z.normalized()
	var to_aim := (aim - camera.transform.origin).normalized()
	_check(forward.dot(to_aim) > 0.9999,
		"%s: the camera is aimed at the point it was placed to aim at (dot %.6f)" % [label, forward.dot(to_aim)])

	_check(_near(ground.position.x, centre.x, 0.5) and _near(ground.position.z, centre.z, 0.5),
		"%s: the ground pad is centred where the camera is aimed (pad %s, solved %s)" % [
			label, str(Vector2(ground.position.x, ground.position.z)), str(Vector2(centre.x, centre.z))])
	_check(_near(ground.position.y, scene_ground_position.y, 0.001),
		"%s: framing never moves the pad vertically" % label)

	var expect_size := maxf(scene_ground_size.x, span * 2.2)
	_check(_near(ground.size.x, expect_size, 1.0) and _near(ground.size.z, expect_size, 1.0),
		"%s: the pad is square and %.0f m across, which is the wider of the scene's and 2.2 spans" % [label, ground.size.x])
	_check(_near(ground.size.y, scene_ground_size.y, 0.001),
		"%s: framing never changes the pad's thickness" % label)

	_check(_near(camera.far, maxf(scene_camera_far, span * 4.0), 1.0),
		"%s: far is the further of the scene's and four spans (%.0f m)" % [label, camera.far])
	_check(_near(camera.near, clampf(span * 0.02, scene_camera_near, 20.0), 0.01),
		"%s: near is a fiftieth of the span, floored at the scene's and capped at 20 m (%.3f m)" % [label, camera.near])
	_check(camera.near < camera.far and camera.near > 0.0,
		"%s: the near plane is in front of the far one" % label)


# --- 2. the capability: what was built is in the view that was framed ---
#
# This is the question the arithmetic above exists to answer, and it is the
# one a player would ask. Both halves are measured off the geometry standing
# in the scene, not off anything a module said about it.
func _world_is_in_view(label: String) -> void:
	var box := _world_footprint()
	_check(box.size.x > 0.0 and box.size.z > 0.0,
		"%s: something was actually built to look at (%.0f by %.0f m)" % [label, box.size.x, box.size.z])

	var camera := _camera()
	var outside: Array = []
	for corner in _footprint_corners(box):
		if not camera.is_position_in_frustum(corner):
			outside.append(str(corner))
	_check(outside.is_empty(),
		"%s: every corner of the world's footprint is inside the camera's frustum%s" % [
			label, "" if outside.is_empty() else " (outside: " + ", ".join(outside) + ")"])

	var ground := _ground()
	var pad_min := Vector2(ground.position.x - ground.size.x * 0.5, ground.position.z - ground.size.z * 0.5)
	var pad_max := Vector2(ground.position.x + ground.size.x * 0.5, ground.position.z + ground.size.z * 0.5)
	var off: Array = []
	for corner in _footprint_corners(box):
		var here := Vector2(corner.x, corner.z)
		if here.x < pad_min.x or here.x > pad_max.x or here.y < pad_min.y or here.y > pad_max.y:
			off.append(str(corner))
	_check(off.is_empty(),
		"%s: the world stands on the ground pad, not off the edge of it%s" % [
			label, "" if off.is_empty() else " (off: " + ", ".join(off) + ")"])


# --- 4. the class, read off the source so it cannot grow in silence ---
#
# Section 3 asserts the rule at the three paths that empty the world. This
# asserts that three is all of them, by counting the calls in
# game_controller.gd rather than by trusting the list in this header. The
# count is EXACT and not a floor: the claim is that the class is closed, and
# a floor would pass on a fourth path nobody had classified (TRAPS 6).
func _the_class_is_closed() -> void:
	# Read off the CODE (067). The per-line skips below already dropped a
	# whole-line comment; _code_of() also cuts a comment that follows code on
	# the same line, which nothing was doing. See TRAPS 64.
	#
	# THE GUARD IS ON THE RAW READ, AND THAT IS THE WHOLE POINT (084, TRAPS 81).
	# Until 084 it read `_check(_code_of(...) != "", "game_controller.gd was
	# read")`, which COULD NOT FAIL: a file that is not there reads as the
	# empty string, and `_code_of("")` is "\n" and not "" - `"".split("\n")`
	# is one empty element, so the stripper emits one newline for it. Measured
	# in Godot 4.7.1 (raw len 0, stripped len 1, byte 10) and measured in this
	# suite: with the path redirected at a file that does not exist, the guard
	# PASSED and the three counts below did the catching - 82 assertions,
	# failures=3 and not 4.
	var raw := FileAccess.get_file_as_string("res://scripts/game_controller.gd")
	_check(raw != "", "game_controller.gd was read (%d bytes)" % raw.length())
	# And the reason the line above is on `raw`, asserted on a built source
	# rather than left as a sentence in this comment, so the day it stops being
	# true this suite says so and the guard can move back.
	_check(FileAccess.get_file_as_string("res://scripts/A_FILE_GENESIS_DOES_NOT_HAVE.gd") == "",
		"a file that is not there reads as the empty string, which is what makes the guard above load-bearing")
	_check(_code_of("") != "",
		"and _code_of() of that empty read is NOT empty, which is why asking the stripped text whether the read worked cannot fail")
	var source := _code_of(raw)

	var clears: Array = []
	var restores: Array = []
	var frames: Array = []
	# Where each function begins, so a call can be attributed to one.
	var starts: Array = []
	var number := 0
	for line in source.split("\n"):
		number += 1
		var text: String = (line as String).strip_edges()
		if text.begins_with("#"):
			continue
		if text.begins_with("func "):
			starts.append(number)
		if text.contains("_clear_world_node()") and not text.begins_with("func "):
			clears.append(number)
		if text.contains("_restore_view()") and not text.begins_with("func "):
			restores.append(number)
		if text.contains("_frame_view(") and not text.begins_with("func "):
			frames.append(number)

	# Six calls, and what follows each one is why there are only three paths
	# in the class: three of the six are followed by a build and a framing,
	# so the view is replaced rather than restored.
	#
	#   pass 3 of a plan, cleared to build        -> builds, then frames
	#   a plan that failed after clearing         -> RESTORES (062; this is the fault)
	#   a world replacing another                 -> builds, then frames or places
	#   show_unrecorded                           -> builds, then frames
	#   a sectionless CREATE_TRACK                -> restores
	#   CLEAR_WORLD                               -> restores
	_check(clears.size() == 6,
		"the world is emptied at exactly 6 places in game_controller.gd (found %d: %s)" % [clears.size(), str(clears)])
	_check(restores.size() == 3,
		"the view is restored at exactly 3 of them (found %d: %s)" % [restores.size(), str(restores)])
	_check(frames.size() == 3,
		"the view is framed at exactly 3 places (found %d: %s)" % [frames.size(), str(frames)])

	# And every restore stands in a function that has ALREADY emptied the
	# world, which is the structural half of the count above: three calls in
	# three functions that each empty the world first.
	#
	# THE FIRST DRAFT OF THIS CHECK MEASURED THE WRONG THING, and it is
	# recorded rather than quietly replaced (TRAPS 6, TRAPS 14). It asserted
	# that each restore sat within three LINES of a clear, which passed on
	# the code as it was and FAILED the moment 062 added its restore with a
	# comment above it - a check on how long a comment is, dressed as a check
	# on where a call is. Caught by running it.
	var orphans: Array = []
	for at in restores:
		var cleared_first := false
		var start := 0
		for boundary in starts:
			if int(boundary) <= at and int(boundary) > start:
				start = int(boundary)
		for clear_at in clears:
			if int(clear_at) > start and int(clear_at) < at:
				cleared_first = true
		if not cleared_first:
			orphans.append(at)
	_check(orphans.is_empty(),
		"every restore stands in a function that emptied the world first%s" % ("" if orphans.is_empty() else " (orphans: " + str(orphans) + ")"))

	# Nothing in scripts/ writes the camera's transform except these two
	# functions and the two cameras a player rides. Asked off the source
	# because a third writer is how two readings of one view would start.
	var writers: Array = []
	for name in ["game_controller.gd", "main.gd", "car.gd", "walker.gd"]:
		var text := _code_of(FileAccess.get_file_as_string("res://scripts/" + name))
		for line in text.split("\n"):
			var stripped: String = (line as String).strip_edges()
			if stripped.begins_with("#"):
				continue
			if stripped.contains("camera.transform =") or stripped.contains("camera.look_at_from_position"):
				writers.append(name + ": " + stripped)
	_check(writers.size() == 2,
		"exactly two lines in scripts/ move the overhead camera (found %d: %s)" % [writers.size(), str(writers)])


func _run() -> void:
	_make_main()
	await process_frame
	await process_frame

	# The scene's own values, off a second instance of it. Freed immediately:
	# a spare main.gd in the tree would take a second turn at everything.
	var fresh: Node3D = load(str(ProjectSettings.get_setting("application/run/main_scene"))).instantiate()
	var fresh_camera: Camera3D = fresh.get_node("Camera3D")
	var fresh_ground: CSGBox3D = fresh.get_node("Ground/CSGBox3D")
	scene_camera_transform = fresh_camera.transform
	scene_camera_far = fresh_camera.far
	scene_camera_near = fresh_camera.near
	scene_ground_size = fresh_ground.size
	scene_ground_position = fresh_ground.position
	fresh.free()

	# --- the viewport, from the setting and never from a literal ---
	var width := int(ProjectSettings.get_setting("display/window/size/viewport_width"))
	var height := int(ProjectSettings.get_setting("display/window/size/viewport_height"))
	get_root().size = Vector2i(width, height)
	await process_frame
	_check(width > 0 and height > 0,
		"project.godot's viewport is %d x %d" % [width, height])
	_check(get_root().size == Vector2i(width, height),
		"the headless window took that size, so a frustum here is the game's shape (got %s)" % str(get_root().size))
	_check(get_root().size.x != get_root().size.y,
		"and it is not the 64 x 64 square a headless run starts with, which no player has seen")

	_what_was_captured()

	# --- 1 and 2, for every kind of world the registry knows about ---
	var commands: Array = WorldRegistry.commands()
	_check(commands.size() >= 3,
		"WorldRegistry knows about %d kinds of world" % commands.size())
	for command in commands:
		_check(SAMPLE.has(command),
			"this suite has a request for %s" % str(command))
		if not SAMPLE.has(command):
			continue
		await _type(SAMPLE[str(command)])
		_check(main.controller.world_node.get_child_count() > 0,
			"%s built something" % str(command))
		_framing_is_consistent(str(command))
		_world_is_in_view(str(command))

	# --- 3. the class: an emptied world puts the view back ---
	#
	# Each path is reached through _handle_request, which is the door a
	# player types into, and each is preceded by a real build so there is a
	# framing to undo. The framed state is asserted to be different from the
	# scene's first, so "it went back" is never passing because it never
	# moved.
	for path in [
		["CLEAR_WORLD", '{"command": "CLEAR_WORLD", "parameters": {}}'],
		["a sectionless CREATE_TRACK", '{"command": "CREATE_TRACK", "parameters": {}}'],
		["a PLAN that fails after clearing", PLAN_FAILS_LATE],
	]:
		var label: String = path[0]
		await _type(SAMPLE["CREATE_TRACK"])
		_check(not _camera().transform.is_equal_approx(scene_camera_transform),
			"%s: a circuit stands and the view has moved off the scene's camera" % label)
		await _type(path[1])
		await process_frame
		_check(main.controller.world_node.get_child_count() == 0,
			"%s: the world is empty afterwards" % label)
		_view_is_the_scene_s(label)

	# The other side of the same rule: a plan that fails BEFORE it clears
	# anything leaves the world standing, so the view must NOT be put back.
	# 040 established the world's half of this; this is the view's.
	await _type(SAMPLE["CREATE_TRACK"])
	var framed := _camera().transform
	var padded := _ground().size
	await _type(PLAN_FAILS_EARLY)
	await process_frame
	_check(main.controller.world_node.get_child_count() > 0,
		"a plan refused before it clears leaves the world standing")
	_check(_camera().transform.is_equal_approx(framed) and _ground().size.is_equal_approx(padded),
		"and leaves the view framed on it, untouched")

	# --- 5. /view comes back to the framed overhead camera ---
	#
	# Driving and walking each make their own camera live. /view hands the
	# view back, and what it hands back must be the world's framing and not
	# the scene's camera: a player who drives a circuit and stops is looking
	# at the circuit, not at the 200 m pad the game started on.
	await _type(SAMPLE["CREATE_TRACK"])
	var overhead := _camera().transform
	await _type("/drive")
	_check(main.driving, "/drive started on the standing circuit")
	_check(main.car != null and main.car.camera.current,
		"the car's camera is the live one while driving")
	_check(not _camera().current, "the overhead camera is not live while driving")
	await _type("/view")
	_check(not main.driving, "/view stopped driving")
	_check(_camera().current, "the overhead camera is live again")
	_check(_camera().transform.is_equal_approx(overhead),
		"and it is still framed on the circuit, not back at the scene's camera")

	_the_class_is_closed()

	print("")
	for line in lines:
		print(line)
	print("VIEW FRAME %d assertions, failures=%d" % [asserted, bad])
	quit(bad)


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
