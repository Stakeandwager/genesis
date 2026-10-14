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
	return [CarTool.new(), BootsTool.new(), LookTool.new()]


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
	if bool(checked["ok"]):
		return tool.readback(checked["spec"])
	# An invalid spec is still described, so a player can see what Genesis
	# thought they asked for even when it cannot be given to them.
	#
	# 022: it used to be described by falling back to defaults, which made the
	# readback describe a tool nobody asked for. A photo refused for being
	# missing read back as "a plain tan head" - true of the defaults, and a
	# flat untruth about the request. The readback's only job is to catch a
	# dropped clause, so describing the defaults instead of the request is the
	# one thing it must never do. The asked-for fields are laid over the
	# defaults first, so what is said back is what was heard.
	return tool.readback(asked_spec(tool, parameters))


# The defaults with whatever the player actually asked for laid on top,
# unchecked. Only for saying back a refused request: it is what was HEARD, not
# what will be given, and nothing may be built from it.
static func asked_spec(tool: ToolModule, parameters: Dictionary) -> Dictionary:
	var spec: Dictionary = tool.defaults()
	var given = parameters.get("spec", {})
	if typeof(given) != TYPE_DICTIONARY:
		return spec
	for key in (given as Dictionary):
		if not spec.has(key):
			continue
		# A value of the wrong kind entirely - "power": "lots" - is left out
		# rather than laid over, because a readback built from it would read
		# as a confident sentence about a number that was never a number. The
		# refusal below says what was wrong with it.
		if _same_kind(spec[key], (given as Dictionary)[key]):
			spec[key] = (given as Dictionary)[key]
	return spec


static func _same_kind(mine: Variant, theirs: Variant) -> bool:
	var numbers := [TYPE_INT, TYPE_FLOAT]
	if numbers.has(typeof(mine)):
		return numbers.has(typeof(theirs))
	return typeof(mine) == typeof(theirs)


# What every tool gives a player who has asked for nothing. This is the free
# equipment: it always exists, it always works, and it is what Genesis has
# always handed out.
static func free_kit() -> Dictionary:
	var out := {}
	for tool in tools():
		out[(tool as ToolModule).name()] = (tool as ToolModule).defaults()
	return out
