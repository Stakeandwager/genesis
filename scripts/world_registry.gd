extends RefCounted
class_name WorldRegistry

# --- The registry of world modules ---
# The one place that knows which kinds of world exist. The command whitelist
# and the AI's vocabulary are both built from this list, so a module cannot
# be half-added: if it is here, it is whitelisted, described to the AI,
# validated and measured; if it is not, the AI cannot reach it at all.

static func modules() -> Array:
	return [FarmModule.new(), RacingModule.new(), DungeonModule.new()]


static func commands() -> Array:
	var out: Array = []
	for module in modules():
		out.append((module as WorldModule).command())
	return out


static func find(command: String) -> WorldModule:
	for module in modules():
		if (module as WorldModule).command() == command:
			return module
	return null


# --- 003: one reading of where a world goes ---
# "around": N centres this world on an earlier step. The AI writes it at the
# step level or inside parameters and means the same thing either way, so
# both are read - here, once, and nowhere else.
#
# This exists because they were read in two places and disagreed. The
# readback said "one inside the other" while the builder, reading only the
# step level, placed them unrelated and refused the plan. A readback that
# describes something other than what Genesis will do is worse than no
# readback: it teaches a player to trust a line that is not true. The line
# and the placement now come from the same answer and cannot diverge.
#
# This forgives the SHAPE of a step, never its vocabulary: the whitelist and
# the validators are untouched, so an invented command or field is refused
# exactly as before.
static func around_of(step: Dictionary) -> int:
	var step_parameters: Dictionary = step.get("parameters", {})
	return int(step.get("around", step_parameters.get("around", 0)))


# --- 003: what Genesis understood ---
# One line describing the command Genesis is about to carry out, in plain
# English, built from the STRUCTURED COMMAND and never from what the player
# typed. A line built from the player's own words would hand their sentence
# back to them and confirm nothing; built from the command, it says what
# Genesis will really do, so a dropped word shows up as a line that does not
# match what was asked.
#
# This lives here rather than in Readback because composing it needs the
# modules, and the modules need Readback's wording helpers. Readback stays a
# leaf and nothing references in a circle.
static func readback(command: String, parameters: Dictionary) -> String:
	match command:
		"UNSUPPORTED":
			# The AI says what it understood even when it cannot build it:
			# being told the right thing is impossible is a different answer
			# from being told the wrong thing is.
			return str(parameters.get("understood", "")).strip_edges()
		"CLEAR_WORLD":
			return "to clear everything away"
		"EQUIP":
			return ToolRegistry.readback(parameters)
		"PLAN":
			return _plan_readback(parameters)
	var module := find(command)
	return module.readback(parameters) if module else ""


# A plan's meaning is mostly how its worlds are RELATED, so that is what this
# reads out, and each world is named in a few words so the relationship is
# not buried at the end of a sentence nobody finishes.
#
# "around": N centres one world on another; which ends up inside depends on
# sizes nothing has solved yet when this line is written, so it says "one
# inside the other" rather than claiming a direction Genesis has not worked
# out. With no "around" anywhere the worlds are unrelated, and the line says
# "side by side" - which is exactly the case a player must be able to catch,
# because the build will succeed either way.
static func _plan_readback(parameters: Dictionary) -> String:
	var raw = parameters.get("steps", null)
	if typeof(raw) != TYPE_ARRAY or (raw as Array).is_empty():
		return ""

	var parts := PackedStringArray()
	var related := false
	for entry in (raw as Array):
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var step: Dictionary = entry
		var step_command := str(step.get("command", "")).to_upper()
		var step_parameters: Dictionary = step.get("parameters", {})
		var module := find(step_command)
		parts.append(module.readback_short(step_parameters) if module else Readback.article(step_command.to_lower()))
		# The same reading the builder uses, so the line cannot promise a
		# relationship the placement will not deliver.
		if around_of(step) >= 1:
			related = true

	if parts.is_empty():
		return ""
	if parts.size() == 1:
		return parts[0]
	return Readback.join_list(parts) + (", one inside the other" if related else ", side by side")


# Everything the AI needs to know about the worlds it can ask for.
# Since 002H every world describes itself, racing included, so this is the
# whole of the AI's world vocabulary. A module that returns nothing adds
# nothing, not even a blank line.
static func prompt_sections() -> String:
	var parts := PackedStringArray()
	for module in modules():
		var section := (module as WorldModule).prompt_section()
		if section != "":
			parts.append(section)
	return "\n\n".join(parts)
