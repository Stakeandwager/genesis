extends SceneTree

# --- 063: the light and the environment, which nothing had ever read ---
#
# THE TASK, AND WHERE IT CAME FROM
#
# HANDOVER's "Next action" at 062, in its own words: "The light and the
# environment, which are the next two of the six, and are probably not
# measurable the way the camera was. A DirectionalLight3D at a rotation and a
# WorldEnvironment with a sky are state a suite can read off the scene - that
# much is the same trick as section 0 - but whether anything is LIT is a
# renderer's answer and this container has none. The honest smallest step is
# the one section 0 already takes for the camera: assert that the scene HAS
# them, with the values it has, so the day one is deleted or switched off a
# suite says so. That is a guard, not a measurement, and should be labelled
# as one (TRAPS 6)."
#
# It is labelled: sections 0 and 3 below are guards and say so. But the
# estimate in that paragraph was too pessimistic in one place, and that is
# what this file is actually about: WHICH WAY A LIGHT POINTS IS ARITHMETIC,
# exactly as a camera's aim turned out to be, and asking it found a fault.
#
# WHAT WAS MEASURED, AND WHAT IT FOUND
#
# A DirectionalLight3D emits along its own local -Z. Its POSITION is ignored
# by the engine entirely - a directional light is infinitely far away and has
# no place - so a directional light's orientation is the whole of what it
# does. scenes/main.tscn had this from the project's first commit (614a1f5,
# Prototype 001) and no commit between then and 063 touched the line:
#
#   transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -45, -30, 0)
#
# That is an IDENTITY basis with an origin of (-45, -30, 0). Read back off an
# instance of the scene before anything was changed:
#
#   rotation_degrees                       (0, 0, 0)
#   direction the light travels            (0, 0, -1)       <- horizontal
#   N.L for a horizontal surface           0.000000         <- exactly zero
#   N.L for a wall facing +Z               1.000000
#
# THE SUN POINTED ALONG THE GROUND. Every horizontal surface in Genesis - the
# 200 m pad the game starts on, the pad a built world stands on, a track's
# road, a farm's zones, a dungeon's floors - took EXACTLY ZERO direct light
# from it, because a surface whose normal is perpendicular to the direction
# the light travels receives none under any diffuse model. The only surfaces
# the sun reached were walls facing +Z.
#
# AND THE THREE NUMBERS SAY WHAT WAS MEANT. (-45, -30, 0) in the origin slots
# of a node whose position does nothing, on a node whose rotation does
# everything, is a rotation written into the wrong field. The fix moves them
# into the basis and changes nothing else. THE ANGLE ITSELF IS THE OWNER'S TO
# TUNE and HANDOVER says so: using the project's own three numbers is the
# least inventive choice available, not a claim that -45 and -30 are right.
#
# WHAT IS NOT CLAIMED HERE, AND IT MATTERS
#
# "The screen was black" would be FALSE and is asserted nowhere (TRAPS 15, a
# limitation stated wider than it is true). The WorldEnvironment's
# Environment has background_mode = SKY with a ProceduralSkyMaterial, and its
# ambient source is BG with sky_contribution 1.0 and energy 1.0 - so a
# horizontal surface was still lit by the SKY, flatly and from every
# direction at once, with no sun term and no shadows (shadow_enabled is
# false). What the fault cost is the directional half of the lighting, which
# is the half that makes a shape read as a shape. How much that is worth
# looking at is a judgement for a pair of eyes and is in HANDOVER as one.
#
# NOTHING HERE RENDERS ANYTHING. No pixel is drawn and no window is opened.
# Every number in this file is a transform, a dot product or a property read
# off a resource. A suite in this container CANNOT answer "is it lit" and
# does not pretend to; what it answers is "can the sun reach a floor at
# all", which is a dot product, and the answer was no.
#
# AND A DELIBERATE FAULT CAUGHT THIS FILE'S FIRST DRAFT, WHICH IS WORTH MORE
# THAN THE FIX (TRAPS 51). That draft asked every question of the RUNNING
# GAME, on the reasoning that the light a player gets is a stronger subject
# than the light the file describes. It is - for a light. It is the WEAKER
# subject for a camera, and section 2 asks its class question of both: the
# live camera has already been aimed by the startup circuit's framing, so
# with the scene's camera rotation DELETED the draft reported 0 failures and
# the class assertion passed on a camera that had no rotation in the file at
# all. Section 2 now reads the scene as the game LAUNCHES it. Caught by
# injecting the fault, not by reading the code.

# No scene resource path is written out in this file. It reaches the scene
# through application/run/main_scene, and player_door_test holds the rule
# that the literal lives in exactly one place - the file that compares the
# path with the setting. 062's first draft tripped that guard twice; this one
# is written knowing about it.

# One smallest valid request, so section 3 can ask its question with a world
# standing rather than only on the startup circuit. Section 3 is a guard and
# not a sweep over world kinds, for the reason given there: nothing that
# builds a world touches a light, so a loop over three kinds would be three
# copies of one answer.
const CIRCUIT := '{"command": "CREATE_TRACK", "parameters": {"mode": "circuit", "sections": [{"type": "straight", "length": 300}, {"type": "corner", "radius": 60, "angle": 90}, {"type": "straight", "length": 300}, {"type": "corner", "radius": 60, "angle": 90}, {"type": "straight", "length": 300}, {"type": "corner", "radius": 60, "angle": 90}, {"type": "straight", "length": 300}, {"type": "corner", "radius": 60, "angle": 90}]}}'

var main: Node3D
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
	_run.call_deferred()


# 061: the scene the game launches, through the setting rather than by path.
func _make_main() -> void:
	main = load(str(ProjectSettings.get_setting("application/run/main_scene"))).instantiate()
	get_root().add_child(main)


func _type(text: String) -> void:
	main._handle_request(text)
	await process_frame
	await process_frame


func _walk(node: Node, out: Array) -> void:
	out.append(node)
	for child in node.get_children():
		_walk(child, out)


# Every node of the scene, found by walking it rather than by naming the
# nodes this file expects. A light added beside the one that is there gets
# asked the same questions (TRAPS 11), and a light DELETED makes the count
# assertions fail rather than leaving an enumeration quietly empty - which
# was checked by deleting it, not assumed.
func _of_class(all: Array, klass: String) -> Array:
	var out: Array = []
	for node in all:
		if node.is_class(klass):
			out.append(node)
	return out


# A node's transform relative to the scene root, composed by walking parents.
#
# WHY NOT global_transform: sections 0 to 2 read an instance of the scene
# that is NOT in the tree, because a second main.gd in the tree takes its own
# turn at everything, the shared ledger included (TRAPS 56). On a node
# outside a tree global_transform prints an error and RETURNS IDENTITY, and
# identity is the one answer that must never arrive here by accident: the
# first probe of this fault was taken that way and was right only because
# the basis it happened to be reading really was identity. This composes the
# chain instead, so what it returns is arithmetic on values that are there.
func _relative(node: Node3D, root: Node3D) -> Transform3D:
	var out := node.transform
	var at: Node = node.get_parent()
	while at != null:
		if at is Node3D:
			out = (at as Node3D).transform * out
		if at == root:
			break
		at = at.get_parent()
	return out


# is_visible_in_tree() for an instance that is not in a tree: the same
# question - does any ancestor have it switched off - composed by hand.
func _shown(node: Node, root: Node) -> bool:
	var at: Node = node
	while at != null:
		if at is Node3D and not (at as Node3D).visible:
			return false
		if at is CanvasItem and not (at as CanvasItem).visible:
			return false
		if at == root:
			break
		at = at.get_parent()
	return true


# The direction the light actually travels: a Light3D emits along its own
# local -Z, so this is the one number that decides what it can reach.
func _travel(basis: Basis) -> Vector3:
	return -basis.z.normalized()


# --- 0. the scene has a sun and a sky, and both are switched on ---
#
# THIS SECTION IS A GUARD AND NOT A MEASUREMENT (TRAPS 6). Every assertion in
# it passed on the scene as it stood before this commit and on the scene
# after it; none can fail on any input a player can give, because nothing a
# player types touches either node. What it is for is the day somebody
# deletes the light, sets its energy to zero, clears the environment or
# switches the ambient source off - all of which are one property away in the
# editor and none of which any suite could see before this file existed.
# Counted rather than remembered, and the first count written here was WRONG
# and is corrected rather than quietly fixed (TRAPS 14): "light" appears as a
# substring EIGHT times in scripts/, not four - "slightly", "lightweight",
# "lightened", "a light go-kart", "light on your feet". What is zero is the
# thing that matters: "DirectionalLight", "Light3D", "WorldEnvironment",
# "light_energy" and "ambient" appeared NOWHERE in scripts/ or tests/ before
# this file - not in an assertion and not in a comment. The nearest thing to
# a mention is circuit_builder.gd:123, "Winding chosen so the road faces up,
# towards the light", which ASSUMES a light overhead and is the one line in
# the project that would have been falsified by reading the scene. A layer
# with no reader does not have no faults; it has faults nobody has counted
# (TRAPS 60).
func _the_scene_has_light_in_it(all: Array, root: Node3D) -> void:
	var lights := _of_class(all, "Light3D")
	_check(lights.size() >= 1,
		"GUARD: the scene has %d light(s) in it" % lights.size())
	for node in lights:
		var light: Light3D = node
		_check(light.visible, "GUARD: %s is visible" % light.name)
		_check(light.light_energy > 0.0,
			"GUARD: %s has energy above zero (%.3f)" % [light.name, light.light_energy])
		_check(light.light_color.r + light.light_color.g + light.light_color.b > 0.0,
			"GUARD: %s is not coloured black (%s)" % [light.name, str(light.light_color)])
		# A visible node under an invisible parent is invisible. Asked of the
		# chain and not of the node, because "visible" alone answers a
		# narrower question than the one being asked.
		_check(_shown(light, root),
			"GUARD: %s is shown, so no ancestor of it has been switched off" % light.name)

	var environments := _of_class(all, "WorldEnvironment")
	_check(environments.size() >= 1,
		"GUARD: the scene has %d WorldEnvironment(s) in it" % environments.size())
	for node in environments:
		var holder: WorldEnvironment = node
		var env: Environment = holder.environment
		_check(env != null, "GUARD: %s holds an Environment resource" % holder.name)
		if env == null:
			continue
		_check(env.background_mode == Environment.BG_SKY,
			"GUARD: %s's background is a sky (mode %d)" % [holder.name, env.background_mode])
		_check(env.sky != null and env.sky.sky_material != null,
			"GUARD: and the sky has a material on it (%s)" % [
				"none" if env.sky == null or env.sky.sky_material == null else env.sky.sky_material.get_class()])
		# The ambient term, which is what a surface the sun does not reach is
		# lit by. Stated as the engine computes it: ambient is the ambient
		# COLOUR and the SKY mixed by sky_contribution, scaled by energy. So
		# "there is some ambient light" is three properties and not one, and
		# this scene's ambient colour being pure black is not a fault while
		# the sky contribution is 1.
		_check(env.ambient_light_source != Environment.AMBIENT_SOURCE_DISABLED,
			"GUARD: %s's ambient light is not switched off (source %d)" % [holder.name, env.ambient_light_source])
		_check(env.ambient_light_energy > 0.0,
			"GUARD: and its ambient energy is above zero (%.3f)" % env.ambient_light_energy)
		var from_sky: bool = env.ambient_light_sky_contribution > 0.0 and env.sky != null
		var from_colour: bool = env.ambient_light_sky_contribution < 1.0 \
			and env.ambient_light_color.r + env.ambient_light_color.g + env.ambient_light_color.b > 0.0
		_check(from_sky or from_colour,
			"GUARD: and it comes from somewhere - sky contribution %.2f, colour %s" % [
				env.ambient_light_sky_contribution, str(env.ambient_light_color)])


# --- 1. the measurement: can the sun reach a floor at all ---
#
# This is the section that failed before the fix, and it fails on arithmetic
# rather than on an opinion. A surface takes direct light in proportion to
# the cosine of the angle between its normal and the direction back towards
# the light; at ninety degrees that cosine is zero, under any diffuse model
# anybody has ever shipped. The sun pointed along the ground, so every
# horizontal surface in Genesis took exactly none.
#
# THE NORMAL IS TAKEN OFF THE PAD THAT IS IN THE SCENE, not written here as
# Vector3.UP. If somebody ever tilts the ground, the question follows it.
func _the_sun_can_reach_a_floor(all: Array, root: Node3D, ground: CSGBox3D) -> void:
	var lights := _of_class(all, "Light3D")
	var up := _relative(ground, root).basis.y.normalized()
	_check(up.length() > 0.9, "the ground pad has an up direction to be lit from (%s)" % str(up))

	for node in lights:
		var light: Light3D = node
		var basis := _relative(light, root).basis
		# An ORIENTED node with an identity basis is a node whose whole job
		# is undone. Said as its own assertion, separately from the cosine
		# below, because the two fail for different reasons - and that is
		# measured rather than claimed: a sun rotated to point at the SKY
		# passes this one and fails the next three.
		_check(not basis.is_equal_approx(Basis.IDENTITY),
			"%s has a rotation at all, which for a light is the whole of what it does (rotation_degrees %s)" % [
				light.name, str(light.rotation_degrees)])

		var travel := _travel(basis)
		var cosine := up.dot(-travel)
		_check(cosine > 0.1,
			"%s reaches the ground pad's top face: N.L = %.6f (travel %s)" % [light.name, cosine, str(travel)])

		# The same fact in degrees, and the one place in this file that is a
		# BAND rather than a fact - labelled, because 10 and 80 are a
		# judgement about what a sun looks like and not something measured.
		# A sun on the horizon and a sun straight overhead both light a floor
		# and neither looks like daylight.
		var elevation := rad_to_deg(asin(clampf(-travel.y, -1.0, 1.0)))
		_check(elevation > 10.0 and elevation < 80.0,
			"JUDGEMENT (band, not a fact): %s stands %.1f deg above the horizon, neither on it nor straight overhead" % [
				light.name, elevation])

		if light is DirectionalLight3D:
			var sun: DirectionalLight3D = light
			# A DirectionalLight3D is infinitely far away: the engine ignores
			# its position completely. So numbers in those three slots do
			# nothing at all, and three of them on a node with no rotation
			# are a rotation written into the wrong field - which is exactly
			# what this scene had from its first commit to 063. Asserted only
			# for the directional case, because an OmniLight3D's position is
			# the whole of what IT does.
			_check(sun.transform.origin.is_equal_approx(Vector3.ZERO),
				"%s has nothing written in the position the engine ignores (%s)" % [
					sun.name, str(sun.transform.origin)])

			# And the same direction decides where the procedural sky draws
			# the sun disk, so this is one condition with two consequences on
			# screen. Asked through the sky mode that makes it true, rather
			# than claimed in a comment: with LIGHT_AND_SKY the light is in
			# the sky as well as on the ground.
			if sun.sky_mode == DirectionalLight3D.SKY_MODE_LIGHT_AND_SKY:
				_check(-travel.y > 0.0,
					"%s draws its sun disk above the horizon rather than on it (height %.4f)" % [
						sun.name, -travel.y])


# --- 2. the class: every node whose job is its direction, and the closure ---
#
# TRAPS 11: the fault was one light with no rotation, and the rule it comes
# from is wider than lights. Two kinds of node in this scene do their job by
# POINTING - a Camera3D and a Light3D - and the fault was that one of the two
# had been given a position and no rotation while the other had both. So the
# question is asked of both classes, off the scene, and a third node of
# either kind added tomorrow is asked it too.
#
# IT IS ASKED OF THE SCENE AS THE GAME LAUNCHES IT AND NOT OF THE RUNNING
# GAME, and that is the whole of what a deliberate fault taught this file.
# _frame_view() AIMS the live camera on every build, so a camera with no
# rotation in the scene at all is pointed correctly within a frame of the
# game starting: the first draft read the running tree, and with the scene's
# camera rotation deleted it reported 0 failures. The fault is still caught
# in this repository - view_frame_test section 0 holds the scene's camera to
# being pitched, off its own fresh instance - but a class assertion that
# cannot see a missing rotation is not holding the class.
#
# (This is not that assertion repeated. 062 asserts the camera's pitch in
# detail; this is the weaker thing both classes can be held to at once,
# which is what makes it a statement about the class rather than about the
# camera.)
func _everything_that_points_has_been_pointed(all: Array, root: Node3D) -> void:
	var oriented: Array = []
	for node in all:
		if node.is_class("Camera3D") or node.is_class("Light3D"):
			oriented.append(node)
	_check(oriented.size() >= 2,
		"the scene has %d node(s) whose job is decided by which way they point" % oriented.size())
	var unpointed: Array = []
	for node in oriented:
		if _relative(node, root).basis.is_equal_approx(Basis.IDENTITY):
			unpointed.append("%s (%s)" % [node.name, node.get_class()])
	_check(unpointed.is_empty(),
		"and every one of them has been given a rotation in the scene%s" % (
			"" if unpointed.is_empty() else ": " + ", ".join(unpointed) + " has none"))

	# THE CLOSURE, read off the source: the scene's light and the scene's
	# environment are ALL the light and ALL the environment the game has.
	# Without this, section 0's guard is a guard on one node of an unknown
	# number - a module that built its own light would be unmeasured and
	# nothing would say so. The count is EXACT and not a floor, because the
	# claim is that the class is closed (TRAPS 6).
	var makers: Array = []
	for name in DirAccess.get_files_at("res://scripts"):
		if not name.ends_with(".gd"):
			continue
		var body := FileAccess.get_file_as_string("res://scripts/%s" % name)
		var number := 0
		for line in body.split("\n"):
			number += 1
			var text: String = (line as String).strip_edges()
			if text.begins_with("#"):
				continue
			# Any constructor of a light or an environment. Matched on the
			# class-name stems rather than on a list of the Light3D
			# subclasses, so a SpotLight3D counts.
			if text.contains("Light3D.new()") or text.contains("WorldEnvironment.new()") \
					or text.contains("Environment.new()"):
				makers.append("%s:%d %s" % [name, number, text])
	_check(makers.is_empty(),
		"nothing in scripts/ makes a light or an environment of its own, so the scene's are all the game has%s" % (
			"" if makers.is_empty() else " (found: " + str(makers) + ")"))


# --- 3. and the light a player actually gets ---
#
# Sections 0 to 2 read the scene as a file. This reads the game that has been
# running since _make_main(), with a world built through the door a player
# types into - so the two halves are "what the scene says" and "what is
# standing after a build", and neither stands in for the other.
#
# IT IS ALSO A GUARD (TRAPS 6), and section 2's closure is the reason:
# nothing in scripts/ makes a light, and nothing in scripts/ writes one, so
# no request a player can type can move the sun and these assertions cannot
# fail on today's code. They are here because _frame_view() and
# _restore_view() DO write the camera and the pad on every build and every
# clear, and the day a third function joins them and decides to help by
# moving the light, this is what says so. One build and one reading, not a
# loop over the three world kinds, because the answer does not depend on what
# was built: a sweep over kinds would be three copies of one reading dressed
# up as three measurements.
func _the_sun_survives_the_game(ground: CSGBox3D) -> void:
	var all: Array = []
	_walk(main, all)
	var lights := _of_class(all, "Light3D")
	_check(lights.size() >= 1, "GUARD: the running game has %d light(s)" % lights.size())
	var up := ground.global_transform.basis.y.normalized()
	for node in lights:
		var light: Light3D = node
		var cosine := up.dot(-_travel(light.global_transform.basis))
		_check(light.is_visible_in_tree() and light.light_energy > 0.0 and cosine > 0.1,
			"GUARD: %s still lights the pad with a world standing on it (N.L = %.6f)" % [light.name, cosine])


func _run() -> void:
	_make_main()
	await process_frame
	await process_frame

	# The scene as the game launches it, off an instance that is deliberately
	# NOT added to the tree: a second main.gd in the tree would take its own
	# turn at everything, the shared ledger included (TRAPS 56). Every
	# transform read off it is composed by _relative() rather than asked for
	# as a global, for the reason given there. Freed at the end of the three
	# sections that use it.
	var fresh: Node3D = load(str(ProjectSettings.get_setting("application/run/main_scene"))).instantiate()
	var all: Array = []
	_walk(fresh, all)
	_check(all.size() > 1, "the scene the game launches has %d nodes in it" % all.size())
	var fresh_ground: CSGBox3D = fresh.get_node("Ground/CSGBox3D")
	_check(fresh_ground != null, "and a ground pad in it to be lit")

	_the_scene_has_light_in_it(all, fresh)
	_the_sun_can_reach_a_floor(all, fresh, fresh_ground)
	_everything_that_points_has_been_pointed(all, fresh)
	fresh.free()

	await _type(CIRCUIT)
	_check(main.controller.world_node.get_child_count() > 0,
		"a circuit was built to be lit")
	_the_sun_survives_the_game(main.controller.ground_box)

	print("")
	for line in lines:
		print(line)
	print("SCENE LIGHT %d assertions, failures=%d" % [asserted, bad])
	quit(bad)
