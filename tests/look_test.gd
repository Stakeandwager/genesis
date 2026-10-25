extends SceneTree

# 021 - how a body looks, as a tool with no bounded capabilities at all.
#
# Every field here is free, because none of them changes what anybody can do.
# What is still enforced is the wall: a picture that is not there, is not a
# picture, or is too small to be a face is refused with the reason - the same
# treatment a car's power gets, applied to a file.
#
# 090: THOSE ARE THREE SENTENCES AND THIS FILE HELD TWO OF THEM. The third -
# too small - was executed by no suite in the repository, measured rather
# than noticed (TRAPS 87). It is driven below, and the three are asserted to
# be three DIFFERENT sentences, each of which says something.

var bad := 0
var asserted := 0

func _check(ok: bool, what: String) -> void:
	asserted += 1
	print(("PASS  " if ok else "FAIL  ") + what)
	if not ok:
		bad += 1

func _initialize() -> void:
	var look := LookTool.new()
	# 022: this used to expect res://testface.png to be lying about. It was -
	# on the machine where 021 was written, where it had been made by hand and
	# never committed. On a clean checkout the "a real picture is accepted"
	# assertion failed for the whole of 021's life, including on the owner's
	# machine, and said "there is no file at ..." as though the tool were at
	# fault. A suite that needs a file it does not make is not a suite; it is a
	# suite plus somebody's desk. So it makes its own picture now, and deletes
	# it afterwards.
	var real := _make_a_picture()
	if real == "":
		_check(false, "could not write a test picture to disk")
		# 077: this line carried no assertion count. The _check above has run,
		# so it was true - and a line that cannot say how many ran cannot say
		# one stopped running (TRAPS 73). One of the two 076 left.
		print("LOOK TEST %d assertions, failures=%d" % [asserted, bad])
		quit(1)
		return

	_check(ToolRegistry.names().has("look"), "look is in the registry")
	_check(ToolRegistry.free_kit().size() == 3, "the free kit now has three tools")
	_check(ToolRegistry.prompt_sections().contains("EQUIP look"),
		"the AI is told about it without the prompt being edited")

	# Nothing here is bounded, which is the point.
	var free: Dictionary = look.defaults()
	_check(str(free["face"]) == "" and str(free["skin"]) == "tan",
		"what you get for nothing is a plain tan head")
	_check(look.readback(free) == "a plain tan head", "which reads back as: " + look.readback(free))

	# The wall still stands, applied to a file.
	var missing: Dictionary = look.validate({"tool": "look", "spec": {"face": "C:/nope/absent.png"}})
	_check(not bool(missing["ok"]) and str(missing["errors"][0]).contains("no file"),
		"a picture that is not there is refused: " + str(missing["errors"][0]))
	var not_a_picture: Dictionary = look.validate({"tool": "look", "spec": {"face": "res://project.godot"}})
	_check(not bool(not_a_picture["ok"]), "a file that is not a picture is refused")

	# 090: THE THIRD OF trouble_with()'s THREE SENTENCES, AND IT WAS REACHED
	# BY NOTHING. LookTool.trouble_with() refuses a picture for three
	# different reasons - it is not there, it is not an image, or it is too
	# small to be a face - and two lines above this one hold two of them. The
	# third was executed by no suite in the repository: measured by
	# instrumenting every sentence site in the three tool validators and in
	# NpcGoals, running all 74 suites one at a time in a throwaway copy, and
	# collecting the sites each one reached (TRAPS 87). A rule applied to two
	# members of a three-member list is TRAPS 11's shape at the scale of
	# three adjacent lines.
	var small := Image.create(8, 8, false, Image.FORMAT_RGB8)
	small.fill(Color(0.2, 0.4, 0.6))
	var small_path := "user://test_face_too_small.png"
	if small.save_png(small_path) != OK:
		_check(false, "could not write an 8 by 8 picture to disk")
	else:
		var tiny := ProjectSettings.globalize_path(small_path)
		var too_small: Dictionary = look.validate({"tool": "look", "spec": {"face": tiny}})
		_check(not bool(too_small["ok"]),
			"a picture too small to be a face is refused")
		# WHAT IS ASSERTED IS NOT THE WORDING. Every sentence here may be
		# rewritten. What is asserted is that the three faults a picture can
		# have draw THREE DIFFERENT refusals, each of which says something -
		# which is the property that makes a probe a measurement rather than
		# a second label, and it is the same property 089 asserted for the
		# controller's branches. Before 090 the "not a picture" line above
		# asserted only that ok was false, so it would have passed against a
		# refusal that said nothing at all.
		var whys: Array = []
		for result in [missing, not_a_picture, too_small]:
			var errs: Array = (result as Dictionary).get("errors", []) as Array
			var why := "" if errs.is_empty() else str(errs[0])
			_check(why.strip_edges() != "",
				"a refused picture is told why (said: \"%s\")" % why)
			if not whys.has(why):
				whys.append(why)
		_check(whys.size() == 3,
			"and the three faults draw three different refusals (%d distinct: %s)" % [
				whys.size(), str(whys)])
		_clean_up(tiny)
	var bad_skin: Dictionary = look.validate({"tool": "look", "spec": {"skin": "chartreuse"}})
	_check(not bool(bad_skin["ok"]), "a skin this game has not got is refused")
	var invented: Dictionary = look.validate({"tool": "look", "spec": {"hairstyle": "mullet"}})
	_check(not bool(invented["ok"]), "an invented field is refused")

	# A real picture.
	var ok: Dictionary = look.validate({"tool": "look", "spec": {"face": real, "skin": "deep"}})
	_check(bool(ok["ok"]), "a real picture is accepted: " + str(ok["errors"]))
	if bool(ok["ok"]):
		var said: String = look.readback(ok["spec"])
		_check(said == "your own face, on deep skin", "and reads back as: " + said)
		_check(not said.contains("/") and not said.contains("\\"),
			"the readback does not say the path back")

		var texture: Texture2D = LookTool.face_texture(real)
		_check(texture != null, "the picture becomes a texture")
		if texture:
			_check(texture.get_width() == texture.get_height(),
				"squared off, %d by %d, so a portrait is not smeared" % [
					texture.get_width(), texture.get_height()])
			_check(texture.get_width() <= LookTool.MAX_SIDE,
				"and capped at %d" % LookTool.MAX_SIDE)

		# It reaches the body.
		var w := Walker.new()
		w._ready()
		w.wear(ok["spec"])
		var head := w.get_node_or_null("Head")
		_check(head != null, "the body has a head")
		if head:
			var face = head.get_node_or_null("Face")
			_check(face != null and face.visible, "and the face is showing on it")
		w.free()

	# A picture that vanishes leaves a plain head rather than a crash.
	var w2 := Walker.new()
	w2._ready()
	w2.wear({"face": "res://gone.png", "skin": "olive"})
	var head2 = w2.get_node_or_null("Head")
	var face2 = head2.get_node_or_null("Face") if head2 else null
	_check(face2 != null and not face2.visible,
		"a picture that has vanished leaves a plain head, not a crash")
	w2.free()

	_clean_up(real)
	print("LOOK TEST %d assertions, failures=%d" % [asserted, bad])
	quit(bad)


# A picture of nothing in particular, 600 across so the cap at MAX_SIDE is
# really exercised, and taller than it is wide so the centre-square crop is
# too. Written beside the project rather than into it: res:// is read-only in
# an exported build and this must work the same way everywhere.
func _make_a_picture() -> String:
	var image := Image.create(600, 800, false, Image.FORMAT_RGB8)
	for y in 800:
		for x in 600:
			image.set_pixel(x, y, Color(float(x) / 600.0, float(y) / 800.0, 0.5))
	var path := "user://test_face_fixture.png"
	if image.save_png(path) != OK:
		return ""
	return ProjectSettings.globalize_path(path)


func _clean_up(path: String) -> void:
	if path != "" and FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
