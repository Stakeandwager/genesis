extends SceneTree

# --- 065: the last of 061's six - the scene's strings and the panels' rects ---
#
# THE TASK, AND WHERE IT CAME FROM
#
# HANDOVER's "Next action" at 063, in its own words: "The command panel's
# anchors and the three strings in the scene - the last of 061's six, and the
# only part of the visual layer a headless suite has not been pointed at. The
# strings are the cheap half and the same trick as section 0 here [...] The
# anchors are the harder half, and worth a careful look before any assertion
# is written: a Control's anchors_preset and grow_* flags are state a suite
# can read, but get_rect() on a laid-out-never-drawn Control under a
# CanvasLayer may or may not be meaningful headless, and THAT SHOULD BE
# ESTABLISHED BY MEASURING IT IN A THROWAWAY COPY before anything is asserted
# off it - an assertion resting on a rect that is always zero would be TRAPS 6
# again."
#
# It was measured in a throwaway copy first, the warning was right to be
# written, and THE ANSWER IS NARROWER AND SHARPER THAN "frames must be
# stepped" - which was this file's own first draft, and which its section 1
# then failed. Measured three ways in one process, Godot 4.7.1 headless, each
# a CanvasLayer and a PanelContainer added to the root and read IMMEDIATELY:
#
#   added inside _initialize(), before the engine has run a frame   S: (0, 0)
#   added from a deferred call, one frame having begun               S: (1152, 120)
#   added later still                                               S: (1152, 120)
#
# SO THE LAYOUT IS NOT DEFERRED AND FRAMES DO NOT NEED STEPPING. A Control
# gets its rect as it enters the tree, and the ONLY window in which a rect
# reads zero is before the viewport's first layout pass - which is to say
# inside _initialize(), which is exactly where a SceneTree script starts and
# therefore exactly where a suite written the obvious way would read it.
#
# THAT MAKES THE `_run.call_deferred()` IDIOM THESE SUITES USE LOAD-BEARING
# and not a matter of style. scene_light_test, view_frame_test and this file
# all open with it; none of them said why, and for anything that reads a rect
# the reason is this. A suite that did its work directly in _initialize()
# would assert off (0, 0) and pass on anything at all - TRAPS 6 - which is
# the trap 063 predicted, sitting one line further back than predicted.
# Section 1 asserts both halves, so the day the engine changes its mind the
# next session is told which way.
#
# TWO THINGS 063's PARAGRAPH UNDERCOUNTED, AND BOTH ARE TRAPS 11
#
# 1. THE STRINGS ARE FOUR, NOT THREE. 063 named TitleLabel's text, InputBox's
#    placeholder and BuildButton's text. scenes/main.tscn also sets
#    StatusLabel.text = "Status: Waiting", and that one IS read by code -
#    main.gd:22 holds it and overwrites it - which is precisely why it was
#    easy to leave out of a list of "strings nothing reads". The class is
#    "a string this scene sets", and it has four members. Section 0 holds all
#    four, and enumerates rather than naming, so a fifth is caught.
#
# 2. THE PANELS ARE THREE, NOT ONE. "The command panel's anchors" names the
#    one panel that is in the scene. Two more are built in code and added to
#    the same CanvasLayer - main.gd:916 HistoryPanel and main.gd:954
#    MetricsPanel - and both are positioned with ABSOLUTE PIXEL OFFSETS from
#    the top edge, where the command panel's are relative to the bottom. The
#    rule a player cares about belongs to all three together: panels do not
#    sit on top of one another and do not hang off the screen. Section 2 asks
#    it of every pair, and section 3 closes the class off the tree.
#
# THE WORST CASE IS BOUNDED, AND THAT IS WHAT MAKES IT ASSERTABLE
#
# project.godot sets no window size, so the base viewport is Godot's default
# 1152 x 648, with stretch mode "canvas_items" and aspect "expand". Measured
# by asking the root for several sizes:
#
#   asked 1152 x 1152   logical viewport 1152 x 1152
#   asked 1152 x  800   logical viewport 1152 x  799
#   asked 1152 x  648   logical viewport 1152 x  648
#   asked 1152 x  500   logical viewport 1492 x  648      <- height FLOORED
#
# Under "expand" the logical viewport never goes BELOW the base size in either
# axis: ask for a shorter window and the height stays 648 and the width grows
# instead. So 648 is a floor on the logical height, the base viewport is the
# tightest the vertical layout can ever be, and a suite that checks the panels
# there has checked them everywhere. Section 2 asserts the floor itself rather
# than assuming it.
#
# WHAT IT FOUND, WHICH IS NOT A FAULT BUT IS EIGHT PIXELS FROM ONE
#
# At the base viewport the three panels do not overlap - measured, not
# assumed. But the margin is thin and nothing was holding it:
#
#   HistoryPanel    y   10 .. 250     absolute, from the top
#   MetricsPanel    y  258 .. 520     absolute, from the top
#   CommandPanel    y  528 .. 648     its content height, from the BOTTOM
#
# EIGHT PIXELS between the metrics panel's bottom edge and the command
# panel's top edge, and the two numbers come from different files. 520 is
# offset_bottom in main.gd:961; 528 is 648 minus the command panel's 120 px
# of content height, which is the sum of four children's minimum sizes and
# therefore moves with the FONT. One point of extra font size, or a fifth row
# in that VBoxContainer, and the command panel grows UPWARD - grow_vertical =
# 0 against a bottom anchor - into the metrics panel. Nothing in this
# repository would have said so. Now section 2 does.
#
# NOT A FAULT TODAY and not fixed here: the layout is correct as it stands,
# and moving a panel is a visual judgement about what the screen should look
# like, which is the owner's (HANDOVER "Human decision needed"). What this
# file does is hold the eight pixels so the day they go the suite says which
# two edges met.
#
# WHAT IS NOT CLAIMED HERE, AND IT MATTERS
#
# NOTHING IS RENDERED AND NO PIXEL IS DRAWN. Every number below is a rect
# computed by the layout engine, which runs headless; none of it is evidence
# that anything is legible, that the panel style is visible, or that text
# fits inside its own box. A Control under a CanvasLayer is laid out and never
# drawn here, exactly as 062 and 063 recorded.
#
# AND IT IS STILL NOT ASSERTED THAT THE PANELS DO NOT COVER THE WORLD. 062
# wrote that question down as the owner's and 063 repeated it. It is now
# PARTLY answerable and deliberately not answered: the panels' rects are
# known and the camera's frustum is known, but which part of a framed world a
# player needs to see is a judgement about the game and not arithmetic. What
# is new is only that the inputs exist; see HANDOVER.

var main: Node
var asserted := 0
var bad := 0
var lines: Array = []


func _check(ok: bool, what: String) -> void:
	asserted += 1
	if ok:
		lines.append("PASS  " + what)
	else:
		bad += 1
		lines.append("  FAIL  " + what)


func _initialize() -> void:
	# Measured HERE and nowhere else: this is the only moment in the process
	# at which the engine has not yet laid anything out, and section 1's first
	# assertion is about it. Everything else waits for _run().
	before_first_frame = _read_a_fresh_rect()
	_run.call_deferred()


func _walk(node: Node, out: Array) -> void:
	out.append(node)
	for child in node.get_children():
		_walk(child, out)


# The scene the game launches, through the setting rather than by path (061).
func _scene() -> PackedScene:
	return load(str(ProjectSettings.get_setting("application/run/main_scene")))


# --- Section 0: GUARD - the strings scenes/main.tscn sets ---
#
# Read off a FRESH instance that is never added to the tree. The file is the
# right subject for "is a value there to be got at all": main.gd overwrites
# StatusLabel's text within a frame of the game starting, so the running game
# would answer this question about itself and not about the scene. That is
# 063's fault 8, one layer along (TRAPS 61).
#
# These cannot fail on anything a player types - nothing a request reaches
# writes TitleLabel, InputBox.placeholder_text or BuildButton.text anywhere in
# scripts/ - so they are a guard and say so in the output. They fail the day
# somebody empties one in the editor, which before this file no suite could
# see.
func _the_scene_still_says_something(fresh: Node) -> void:
	var all: Array = []
	_walk(fresh, all)

	# Enumerated, not named: every Control in the scene that carries a string
	# a player reads. A new label added to the panel joins this list without
	# anybody editing the list.
	var shown: Array = []
	for node in all:
		if node is Control:
			var c := node as Control
			for property in ["text", "placeholder_text"]:
				if property in c and str(c.get(property)) != "":
					shown.append([c.name, property, str(c.get(property))])

	# The count is asserted for the reason 063's fault 2 gives: an enumeration
	# over nothing passes every assertion inside it in silence.
	_check(shown.size() == 4,
		"GUARD: the scene sets %d strings a player reads (expected 4)" % shown.size())

	for entry in shown:
		_check(str(entry[2]).strip_edges() != "",
			"GUARD: %s.%s is not blank or whitespace" % [entry[0], entry[1]])

	# And each of the four by name, with the value the scene carries, so the
	# failure says WHICH string went rather than that a count moved.
	var expected := {
		"TitleLabel": ["text", "WHAT DO YOU WANT TO PLAY?"],
		"InputBox": ["placeholder_text", "make a race track"],
		"BuildButton": ["text", "BUILD"],
		"StatusLabel": ["text", "Status: Waiting"],
	}
	for name in expected:
		var node: Node = fresh.find_child(str(name), true, false)
		_check(node != null, "GUARD: the scene still has a %s in it" % name)
		if node == null:
			continue
		var property: String = str(expected[name][0])
		var want: String = str(expected[name][1])
		_check(property in node and str(node.get(property)) == want,
			"GUARD: %s.%s is %s" % [name, property, JSON.stringify(want)])

	# The box a player types into starts EMPTY, which is a different claim
	# from its placeholder being set and is the one that would break if
	# somebody put the example sentence in `text` by mistake - where it would
	# be submitted rather than suggested.
	var box: LineEdit = fresh.find_child("InputBox", true, false) as LineEdit
	_check(box != null and box.text == "",
		"GUARD: InputBox.text is empty - the example is a placeholder, not a value")


# --- Section 1: MEASUREMENT - when a rect is real, and when it is zero ---
#
# The fact every later assertion rests on, asserted here rather than taken on
# trust from a probe. Both halves are the measurement.
#
# The subject is a CanvasLayer and a PanelContainer built by hand, NOT a
# second copy of scenes/main.tscn: instantiating that scene runs main.gd's
# _ready, which stands up a GameController and opens the shared ledger, and
# two of those in one process is TRAPS 56. What is being measured here is the
# engine's layout timing, which a three-node tree answers exactly as well.
#
# `before_first_frame` is filled in by _initialize() below, because the window
# it measures has closed by the time _run() is called.
var before_first_frame: Vector2 = Vector2(-1.0, -1.0)


# A CanvasLayer holding a PanelContainer with a Label in it, so the panel has
# a content minimum size to be laid out to - the same shape as the scene's
# command panel and nothing else.
func _a_panel_in_a_layer() -> CanvasLayer:
	var layer := CanvasLayer.new()
	var panel := PanelContainer.new()
	panel.anchor_right = 1.0
	panel.anchor_top = 1.0
	panel.anchor_bottom = 1.0
	panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	var label := Label.new()
	label.text = "measured"
	panel.add_child(label)
	layer.add_child(panel)
	return layer


func _read_a_fresh_rect() -> Vector2:
	var layer := _a_panel_in_a_layer()
	get_root().add_child(layer)
	var size: Vector2 = (layer.get_child(0) as Control).get_rect().size
	get_root().remove_child(layer)
	layer.free()
	return size


func _a_rect_is_real_once_a_frame_has_begun() -> void:
	# The half measured before the first frame, in _initialize().
	_check(before_first_frame == Vector2.ZERO,
		"read inside _initialize(), before the engine's first frame, a Control's rect is %s" % before_first_frame)

	# The half measured here, a frame having begun. Read IMMEDIATELY on
	# entering the tree, with nothing awaited: that is the claim.
	var now: Vector2 = _read_a_fresh_rect()
	_check(now.x > 0.0 and now.y > 0.0,
		"read after a frame has begun, the same panel's rect is %s immediately on entering the tree - no frame need be stepped" % now)
	_check(now.x == get_root().get_visible_rect().size.x,
		"and it spans the viewport's full width (%.0f px), so the number is the layout's and not a leftover" % now.x)

	# The consequence, stated as an assertion rather than a comment: the only
	# way to read a zero is to read before the first frame, and these suites'
	# deferred start is what steps past it.
	_check(before_first_frame != now,
		"so _run.call_deferred() is load-bearing for every rect below, not a stylistic choice")


# --- Section 2: MEASUREMENT - the three panels at the tightest viewport ---
#
# The base viewport is the worst case and the floor is asserted, not assumed.
func _the_panels_keep_off_each_other() -> void:
	var base := Vector2i(
		int(ProjectSettings.get_setting("display/window/size/viewport_width")),
		int(ProjectSettings.get_setting("display/window/size/viewport_height")))
	_check(base.x > 0 and base.y > 0,
		"the project's base viewport is %d x %d" % [base.x, base.y])

	# Ask for a window SHORTER than the base and confirm the logical viewport
	# refuses to follow it down. This is what makes "checked at the base size"
	# mean "checked everywhere" rather than "checked at one size".
	get_root().size = Vector2i(base.x, int(base.y / 2.0))
	for _i in 4:
		await process_frame
	var squashed: Vector2 = get_root().get_visible_rect().size
	_check(squashed.y == float(base.y),
		"asked for a window half as tall, the logical viewport height stays %.0f - the base size is a floor" % squashed.y)

	# Now the worst case itself.
	get_root().size = base
	for _i in 4:
		await process_frame
	var view: Vector2 = get_root().get_visible_rect().size
	_check(view == Vector2(base), "measuring at the base viewport, %s" % view)

	var panels := _top_level_controls()
	_check(panels.size() == 3,
		"the UI layer holds %d top-level panels (expected 3: one from the scene, two built in code)" % panels.size())

	# Every pair, not the pair that was interesting. Three panels is three
	# pairs and all three are asked.
	for i in panels.size():
		var a: Control = panels[i]
		for j in range(i + 1, panels.size()):
			var b: Control = panels[j]
			_check(not a.get_rect().intersects(b.get_rect()),
				"%s and %s do not overlap" % [a.name, b.name])

	# And on the screen at all: a panel positioned off the bottom or the right
	# is invisible without overlapping anything.
	var screen := Rect2(Vector2.ZERO, view)
	for p in panels:
		var c: Control = p
		_check(screen.encloses(c.get_rect()),
			"%s sits inside the viewport: %s within %s" % [c.name, c.get_rect(), screen])

	# The eight pixels, named and held. This is the assertion that fails when
	# the font grows or a row is added to the command panel - the one thing in
	# this layout that can move without anybody editing a coordinate.
	var command: Control = _named(panels, "CommandPanel")
	var metrics: Control = _named(panels, "MetricsPanel")
	if command != null and metrics != null:
		var clearance: float = command.get_rect().position.y - metrics.get_rect().end.y
		_check(clearance > 0.0,
			"the command panel's top edge (%.0f) is below the metrics panel's bottom edge (%.0f)" % [
				command.get_rect().position.y, metrics.get_rect().end.y])
		_check(clearance >= 8.0,
			"JUDGEMENT: %.0f px of clearance between them, and 8 is the measured margin at 065 - a smaller number means the command panel has grown upward into the metrics panel" % clearance)

	# The command panel's own anchoring, which is what 063 asked for: it is
	# pinned to the bottom edge and grows upward off its content, so its
	# height is NOT a coordinate anybody wrote down.
	if command != null:
		_check(command.anchor_top == 1.0 and command.anchor_bottom == 1.0,
			"the command panel is anchored to the bottom edge (top=%.1f bottom=%.1f)" % [
				command.anchor_top, command.anchor_bottom])
		_check(command.anchor_left == 0.0 and command.anchor_right == 1.0,
			"and stretched across the full width (left=%.1f right=%.1f)" % [
				command.anchor_left, command.anchor_right])
		_check(command.grow_vertical == Control.GROW_DIRECTION_BEGIN,
			"and grows upward, so extra content eats into the screen above it")
		_check(command.get_rect().end.y == view.y,
			"its bottom edge is the viewport's bottom edge (%.0f)" % view.y)
		_check(command.get_rect().size.y == command.get_combined_minimum_size().y,
			"its height (%.0f) is its content's minimum, not a number anybody chose" % command.get_rect().size.y)


# --- Section 3: CLASS - the rule closed off the tree ---
#
# Sections 2's assertions are about the three panels that exist. This asks the
# question of the class: anything a player sees in the UI layer is a
# top-level Control under it, found by walking rather than by name, and the
# two rules that matter for all of them - on the screen, and not on top of
# each other - have been asked of every one. The closure is the point: a
# fourth panel added to main.gd joins the enumeration without this file being
# edited, and the count assertion means an enumeration that finds nothing
# cannot pass in silence.
func _nothing_else_draws_a_panel() -> void:
	var layer := main.get_node_or_null("UI")
	_check(layer is CanvasLayer, "the UI layer is a CanvasLayer")

	var every: Array = []
	_walk(main, every)
	var elsewhere: Array[String] = []
	for node in every:
		if node is CanvasLayer and node != layer:
			elsewhere.append(str(node.name))
	_check(elsewhere.is_empty(),
		"the scene has exactly one CanvasLayer, so one layer holds every panel%s" % (
			"" if elsewhere.is_empty() else " - found also: " + ", ".join(elsewhere)))

	var panels := _top_level_controls()
	_check(panels.size() > 0, "and %d panels under it to hold to the rule" % panels.size())
	for p in panels:
		var c: Control = p
		_check(c.is_visible_in_tree(),
			"%s is visible in the tree - a panel nobody can see is not holding any rule" % c.name)


func _top_level_controls() -> Array:
	var out: Array = []
	var layer := main.get_node_or_null("UI")
	if layer == null:
		return out
	for child in layer.get_children():
		if child is Control:
			out.append(child)
	return out


func _named(panels: Array, want: String) -> Control:
	for p in panels:
		if str((p as Control).name) == want:
			return p
	return null


func _run() -> void:
	# Section 0 reads the file. Nothing is added to the tree for it, so
	# main.gd never runs and never overwrites what is being read.
	var fresh: Node = _scene().instantiate()
	var all: Array = []
	_walk(fresh, all)
	_check(all.size() > 1, "the scene the game launches has %d nodes in it" % all.size())
	_the_scene_still_says_something(fresh)
	fresh.free()

	# Sections 1 to 3 need the layout engine, which needs frames.
	_a_rect_is_real_once_a_frame_has_begun()

	main = _scene().instantiate()
	get_root().add_child(main)
	for _i in 6:
		await process_frame
	_check(main.get_node_or_null("UI") != null, "the running game has a UI layer")

	await _the_panels_keep_off_each_other()
	_nothing_else_draws_a_panel()

	print("")
	for line in lines:
		print(line)
	print("SCENE UI %d assertions, failures=%d" % [asserted, bad])
	quit(bad)
