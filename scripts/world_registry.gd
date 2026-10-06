extends RefCounted
class_name WorldRegistry

# --- The registry of world modules ---
# The one place that knows which kinds of world exist. The command whitelist
# and the AI's vocabulary are both built from this list, so a module cannot
# be half-added: if it is here, it is whitelisted, described to the AI,
# validated and measured; if it is not, the AI cannot reach it at all.

static func modules() -> Array:
	return [FarmModule.new(), RacingModule.new()]


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


# Everything the AI needs to know about the worlds it can ask for.
static func prompt_sections() -> String:
	var parts := PackedStringArray()
	for module in modules():
		# A world whose rules live elsewhere (racing's, in the standing
		# instructions) adds nothing here, not even a blank line.
		var section := (module as WorldModule).prompt_section()
		if section != "":
			parts.append(section)
	return "\n".join(parts)
