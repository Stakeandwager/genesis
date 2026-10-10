extends RefCounted
class_name ToolRegistry

# --- 004: the registry of tools ---
# WorldRegistry's sibling, and for the same reason. The one place that knows
# which tools exist: the AI's vocabulary and the validator both come from
# this list, so a tool cannot be half-added. If it is here, it can be asked
# for, checked and used; if it is not, the AI cannot reach it at all.
#
# Adding a tool is one file and one entry below. Nothing else changes.

static func tools() -> Array:
	return [CarTool.new()]


static func find(tool_name: String) -> ToolModule:
	var wanted := tool_name.to_lower().strip_edges()
	for tool in tools():
		if (tool as ToolModule).name() == wanted:
			return tool
	return null


static func names() -> Array:
	var out: Array = []
	for tool in tools():
		out.append((tool as ToolModule).name())
	return out


# Everything the AI needs to know about the tools it may ask for.
static func prompt_sections() -> String:
	var parts := PackedStringArray()
	for tool in tools():
		var section := (tool as ToolModule).prompt_section()
		if section != "":
			parts.append(section)
	return "\n\n".join(parts)


# The spec said back in plain English, for the readback. Built from the
# structured command like every other readback in Genesis.
static func readback(parameters: Dictionary) -> String:
	var tool := find(str(parameters.get("tool", "")))
	if tool == null:
		return ""
	var checked := tool.validate(parameters)
	# An invalid spec is still described, so a player can see what Genesis
	# thought they asked for even when it cannot be given to them.
	var spec: Dictionary = checked["spec"] if bool(checked["ok"]) else tool.defaults()
	return tool.readback(spec)


# What every tool gives a player who has asked for nothing. This is the free
# equipment: it always exists, it always works, and it is what Genesis has
# always handed out.
static func free_kit() -> Dictionary:
	var out := {}
	for tool in tools():
		out[(tool as ToolModule).name()] = (tool as ToolModule).defaults()
	return out
