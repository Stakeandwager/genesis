extends RefCounted
class_name WorldRegistry

# --- The registry of world modules ---
# The one place that knows which kinds of world exist. The command whitelist
# and the AI's vocabulary are both built from this list, so a module cannot
# be half-added: if it is here, it is whitelisted, described to the AI,
# validated and measured; if it is not, the AI cannot reach it at all.

# --- 032: one reading, applied to the one sentence written twice here ---
# CLEAR_WORLD's line was spelled out in full in BOTH readback() and _doing(),
# the two functions 032 extends. They agreed, and nothing was making them: it
# is TRAPS 16's shape waiting for the release where one of them is reworded.
# Every other command's sentence already came from exactly one function
# (NpcGoals, ToolRegistry, and since 032 TrackBuilder and OpponentBuilder),
# and this is the last one that did not. Fixing the two commands with no
# sentence while leaving one written twice would be the instance and not the
# class (TRAPS 11).
const CLEARED := "to clear everything away"

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
	var raw = around_given(step)
	var number := Readback.as_number(raw)
	if is_nan(number):
		return 0
	return int(number)


# --- 036: the value as the AI wrote it, before anything converts it ---
#
# around_of() used to be `int(step.get(...))`, and int() has no constructor
# for null, {} or []. The call did not return 0: it THREW, and a throw
# abandons the function and leaves the caller holding int's default - which
# is 029's mechanism, in a reading that no validator stands in front of.
# Measured headless: a plan step written `"around": null` threw here three
# times per request (once in _fit_plan, once in _place, once in the readback)
# and the plan was refused for the worlds OVERLAPPING - a sentence about
# geometry for a field Genesis could not read.
#
# So the conversion is Readback.as_number()'s now, like every validator's,
# and this returns the value UNCONVERTED so a caller that must say what was
# wrong with it can tell MISSING from NOT A NUMBER from OUT OF RANGE. Those
# are three different sentences to a player and one number to int().
static func around_given(step: Dictionary) -> Variant:
	var step_parameters: Dictionary = step.get("parameters", {})
	if step.has("around"):
		return step["around"]
	return step_parameters.get("around", null)


# --- 036: what is wrong with this step's "around", in a player's words ---
#
# The prompt TELLS the model to write `"around": N`, so this is a field a
# player's request reaches by design, and it was the only prompted field in
# Genesis that nothing checked. Every other numeric field names itself when
# it is refused (029, 030); this one was silently read as 0 and the plan was
# then refused for a consequence of that.
#
# One reading, here, for the reason around_of() is here: the field may be
# written at the step level or inside parameters, and a check that looked in
# one place would pass a step the builder then reads from the other.
#
# Returns "" when there is nothing wrong. An ABSENT "around" is not wrong -
# a step that does not surround anything is the ordinary case.
static func around_problem(step: Dictionary, index: int, _step_count: int) -> String:
	if not _has_around(step):
		return ""
	var raw = around_given(step)
	# Only an EARLIER step can be surrounded, and that is measured rather
	# than assumed: _place() centres this world on plan_footprints[N - 1],
	# and plan_footprints holds only the worlds already placed. A forward
	# reference used to half-work - _fit_plan() grew the container, _place()
	# centred nothing, and the plan was then refused for overlapping.
	var highest := index - 1
	if highest < 1:
		return "step %d: 'around' names an earlier step, and nothing comes before step 1" % index
	var number := Readback.as_number(raw)
	if is_nan(number):
		return "step %d: 'around' must be a whole number, the step this world goes around (1 to %d)" % [
			index, highest]
	if number != floor(number):
		return "step %d: 'around' must be a whole step number (1 to %d), not %s" % [
			index, highest, String.num(number, 2)]
	var at := int(number)
	if at < 1 or at > highest:
		return "step %d: 'around' is %d, and it must be an earlier step (1 to %d)" % [
			index, at, highest]
	return ""


static func _has_around(step: Dictionary) -> bool:
	if step.has("around"):
		return true
	var step_parameters = step.get("parameters", {})
	return typeof(step_parameters) == TYPE_DICTIONARY and (step_parameters as Dictionary).has("around")


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
			return CLEARED
		# --- 032: the two commands the whitelist allowed and nothing described ---
		# Asked of every command in CommandParser.allowed_commands() at once
		# rather than of one, these two returned the empty string here and the
		# raw JSON token inside a plan. Each sentence is written in ONE
		# function, beside the fields it reads, and _doing() below calls the
		# same function, so a plan describes them exactly as well as a single
		# command does.
		"MODIFY_TRACK":
			return TrackBuilder.readback(parameters)
		"SPAWN_OPPONENTS":
			return OpponentBuilder.readback(parameters)
		"EQUIP":
			return ToolRegistry.readback(parameters)
		"ORDER":
			return NpcGoals.readback(parameters)
		"SHUT":
			return NpcGoals.door_readback(parameters, true)
		"OPEN":
			return NpcGoals.door_readback(parameters, false)
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
# --- 022: a plan is not always two worlds ---
#
# This used to describe every step as a thing in space and finish with "one
# inside the other" or "side by side". Since 014 a plan can hold an ORDER,
# and a dungeon plus an errand came out as "a dungeon of five rooms and an
# order, side by side" - which is not a relationship an order can be in, and
# said nothing whatever about WHICH errand. A readback that cannot describe
# half the request cannot catch a dropped clause in it.
#
# So the steps are now sorted into the two kinds they actually are. Worlds are
# places and keep their spatial line, which is still the thing a player must
# be able to catch, because the build succeeds either way. Everything else is
# something DONE once the places exist, so it is said after them, in its own
# words, with "then".
static func _plan_readback(parameters: Dictionary) -> String:
	var raw = parameters.get("steps", null)
	if typeof(raw) != TYPE_ARRAY or (raw as Array).is_empty():
		return ""

	var places := PackedStringArray()
	var doings := PackedStringArray()
	var related := false
	for entry in (raw as Array):
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var step: Dictionary = entry
		var step_command := str(step.get("command", "")).to_upper()
		var step_parameters: Dictionary = step.get("parameters", {})
		var module := find(step_command)
		if module != null:
			places.append(module.readback_short(step_parameters))
			# The same reading the builder uses, so the line cannot promise a
			# relationship the placement will not deliver.
			if around_of(step) >= 1:
				related = true
		else:
			doings.append(_doing(step_command, step_parameters))

	var said := ""
	if places.size() == 1:
		said = places[0]
	elif places.size() > 1:
		said = Readback.join_list(places) + (
			", one inside the other" if related else ", side by side")

	if doings.is_empty():
		return said
	var done := Readback.join_list(doings)
	return done if said == "" else "%s, then %s" % [said, done]


# A step that is not a world, said in the words that step's own readback uses,
# so a plan describes an order exactly as well as an order does on its own.
# One reading: these all come from the same functions the single-command
# readback calls, and nothing is phrased twice.
static func _doing(command: String, parameters: Dictionary) -> String:
	match command:
		"ORDER":
			var asked := NpcGoals.readback(parameters)
			return "an order %s" % asked if asked != "" else "an order"
		"EQUIP":
			var kit := ToolRegistry.readback(parameters)
			return kit if kit != "" else "a tool"
		"SHUT":
			return NpcGoals.door_readback(parameters, true)
		"OPEN":
			return NpcGoals.door_readback(parameters, false)
		"CLEAR_WORLD":
			return CLEARED
		"MODIFY_TRACK":
			return TrackBuilder.readback(parameters)
		"SPAWN_OPPONENTS":
			return OpponentBuilder.readback(parameters)
	# A command with no sentence of its own, said as the token the AI wrote.
	# Reachable only before validation refuses it, since _execute_plan admits
	# no command outside the whitelist - so what is printed here is a request
	# that is about to be refused, and saying the word back is more use than
	# saying nothing. Every whitelisted command has a case above, and
	# plan_said_test fails if one is ever added without one.
	return Readback.article(command.to_lower())


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
