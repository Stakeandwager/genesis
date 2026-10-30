extends ToolModule
class_name LookTool

# --- 021: how you look ---
#
# The third tool, and the first with NO bounded capabilities at all. Every
# field here is free, because every field here changes how a body looks and
# none of them changes what it can do.
#
# That division already existed: CarTool bounds power, braking, steering and
# grip, and leaves paint and nickname alone; BootsTool bounds push, weight,
# footing and turning, and leaves colour alone. A face is unambiguously the
# second kind, so it needed no new idea - only a tool to live in. A tool with
# an empty bounded half is worth having for its own sake: it proves the
# interface is about describing things, not about limiting them.
#
# THE PHOTO STAYS ON THIS MACHINE
# A picture is read off disk, turned into a texture and drawn. It is not
# uploaded, not stored anywhere by Genesis, and nothing is derived from it -
# no template, no measurements, no identity. That keeps this cosmetic rather
# than biometric, and the line is far easier to hold from the start than to
# walk back across later. The spec carries a PATH, never an image.

const DEFAULT_SKIN := "tan"

# Big enough to recognise a face, small enough that a web build does not grow
# by megabytes per player.
const MAX_SIDE := 512

const SKINS := {
	"tan": Color(0.78, 0.62, 0.48),
	"fair": Color(0.92, 0.80, 0.70),
	"olive": Color(0.66, 0.56, 0.40),
	"brown": Color(0.46, 0.33, 0.24),
	"deep": Color(0.30, 0.21, 0.16),
	"grey": Color(0.55, 0.55, 0.58),
	"green": Color(0.42, 0.56, 0.38),
}


func name() -> String:
	return "look"


func prompt_section() -> String:
	return """EQUIP look - how the player's body looks
{"command": "EQUIP", "parameters": {"tool": "look", "intent": {"style": STYLE}, "spec": {"face": PATH, "skin": SKIN}}}

face: the path to a picture on the player's own computer, used as the face. Only give this when the player names a file or says to use a photo of themselves; otherwise leave it out.
skin: one of %s.
Nothing here changes what the player can do, so nothing here has limits.""" % ", ".join(SKINS.keys())


func defaults() -> Dictionary:
	return {"face": "", "skin": DEFAULT_SKIN}


func validate(parameters: Dictionary) -> Dictionary:
	var errors: Array = []
	var spec := defaults()
	var given = parameters.get("spec", {})
	if typeof(given) != TYPE_DICTIONARY:
		return {"ok": false, "errors": [spec_error()], "spec": {}}

	var asked: Dictionary = given
	for key in asked:
		if not spec.has(key):
			errors.append("a look has no '%s' (it has %s)" % [str(key), ", ".join(spec.keys())])

	if asked.has("skin"):
		# 096: spelling only. A skin of null is refused by the same arm.
		var skin := Readback.spelled(asked["skin"]).to_lower().strip_edges()
		if not SKINS.has(skin):
			errors.append("'%s' is not a skin this game has (%s)" % [skin, ", ".join(SKINS.keys())])
		else:
			spec["skin"] = skin

	# A picture is checked by trying to open it, not by trusting its name. A
	# path that is not there, or is not an image, is refused with the reason -
	# the same wall every other spec goes through, applied to a file.
	if asked.has("face"):
		# 096: spelling only. A face of null said "there is no file at '<null>'";
		# it still says there is no file, and names what was sent.
		var path := Readback.spelled(asked["face"]).strip_edges()
		if path != "":
			var why := trouble_with(path)
			if why != "":
				errors.append(why)
			else:
				spec["face"] = path

	if not errors.is_empty():
		return {"ok": false, "errors": errors, "spec": {}}
	return {"ok": true, "errors": [], "spec": spec}


# What is wrong with this picture, or "" if nothing is. Separated out so the
# validator and anything that loads it later agree about what counts as usable.
static func trouble_with(path: String) -> String:
	if not FileAccess.file_exists(path):
		return "there is no file at '%s'" % path
	var image := Image.new()
	if image.load(path) != OK:
		return "'%s' is not a picture this game can read (try a .png or a .jpg)" % path
	if image.get_width() < 32 or image.get_height() < 32:
		return "'%s' is only %d by %d, which is too small to be a face" % [
			path, image.get_width(), image.get_height()]
	return ""


# The picture as a texture, square and no larger than MAX_SIDE. Returns null
# if it cannot be read, so a face that vanishes between being asked for and
# being worn leaves a plain head rather than a crash.
static func face_texture(path: String) -> Texture2D:
	if path == "" or not FileAccess.file_exists(path):
		return null
	var image := Image.new()
	if image.load(path) != OK:
		return null
	# Centre square, so a portrait is not stretched into a smear.
	var side := mini(image.get_width(), image.get_height())
	image = image.get_region(Rect2i(
		(image.get_width() - side) / 2, (image.get_height() - side) / 2, side, side))
	if side > MAX_SIDE:
		image.resize(MAX_SIDE, MAX_SIDE, Image.INTERPOLATE_LANCZOS)
	return ImageTexture.create_from_image(image)


# "your own face, on tan skin" / "a plain tan head"
#
# The path is never said back. A file path is the player's own machine and
# half of it is usually their name; saying it into a log nobody asked for is
# a small leak with no upside.
func readback(spec: Dictionary) -> String:
	# 095: a refused spec is described from ToolRegistry.asked_spec(), so this
	# reads what the player sent. A skin of "" read back as "a plain  head" -
	# measured through ToolRegistry.readback(). said_or() answers an empty,
	# whitespace or null value the way the absent key is already answered, and
	# a face that says nothing is no face, which is what said() decides here.
	var skin := Readback.said_or(spec, "skin", DEFAULT_SKIN)
	if Readback.said(spec, "face") != "":
		return "your own face, on %s skin" % skin
	return "a plain %s head" % skin


func summary(spec: Dictionary) -> String:
	# 095: summary() is only ever handed the VALIDATED spec, where skin is one
	# of SKINS and face has been opened as a file, so neither reader can meet
	# a value that says nothing today - driven and confirmed. They are changed
	# anyway, because the rule is the same rule and a reader that is right by
	# the grace of the door in front of it is TRAPS 11's next instance.
	if Readback.said(spec, "face") != "":
		return "That's you. The picture stays on this computer."
	return "A plain %s head." % Readback.said_or(spec, "skin", DEFAULT_SKIN)
