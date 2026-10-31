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
	# 044: and a value that is a number but not a WHOLE one is not a step
	# either. around_problem() has refused 1.5 since 036 and this read it as
	# step 1, so the one function written so the check and the placement
	# could not disagree about "around" disagreed with the check about the
	# only value 040 taught the check to refuse. NOT REACHABLE by a player:
	# the schema pass runs around_problem() on every step and returns before
	# anything is prepared or placed, so no plan carrying a fraction gets
	# this far. It is a divergence rather than a fault, and it is closed here
	# because the whole reason this function exists is that two readings of
	# one field drifted apart once already (036).
	if Readback.is_fraction(raw):
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
	# 040: the three sentences stay as 036 wrote them - they are the best of
	# the five doors' and the reason this one was already right. What moved is
	# the DECISION: Readback.ordinal_index() now answers "is this a usable
	# position in a list" for all five, so the four that used to truncate and
	# the one that refused cannot drift apart again (TRAPS 31's last rule).
	if Readback.is_fraction(raw):
		# 041: this clause was the one 040 held up as already right, and it was
		# still saying the number back by hand - String.num(number, 2) rounds
		# 1.504 to "1.50". Said through the same reading as the other four.
		return "step %d: 'around' must be a whole step number (1 to %d), not %s" % [
			index, highest, Readback.number_said(raw)]
	if Readback.ordinal_index(raw, highest) < 0:
		return "step %d: 'around' is %d, and it must be an earlier step (1 to %d)" % [
			index, int(number), highest]
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
#
# --- 102: the three commands whose readback could say NOTHING AT ALL ---
#
# 032 found that SPAWN_OPPONENTS and MODIFY_TRACK had "no readback AT ALL as a
# single command - WorldRegistry.readback returned the empty string" and gave
# both a sentence. That was a command whose readback was empty for EVERY
# request. THIS IS THE SAME FAULT ONE CONDITION IN: a command whose readback
# is there for a request it can read and ABSENT for one it cannot, which is
# why every suite built around 032's class walked past it - they all drive
# requests Genesis can read.
#
# MEASURED, by driving main.gd and reading the history panel the player sees:
#
#   EQUIP car                         "I understand: you want a red car ..."
#   EQUIP hovercraft                  NOTHING
#   EQUIP with no tool, or tool null  NOTHING
#   ORDER go_to room 1                "I understand: you want to send ..."
#   ORDER dance, or no goal           NOTHING
#   PLAN with no steps                NOTHING
#   THE SAME EQUIP, one step inside a PLAN   "I understand: you want a tool."
#   THE SAME ORDER, one step inside a PLAN   "I understand: you want an order."
#
# So the identical step read back as a word inside a plan and as silence on
# its own, because _doing() below had the fallback and this door had not.
# main.gd's _show_readback() RETURNS on an empty line, so the player is not
# told what Genesis understood and `awaiting_readback` is never set - the
# refusal that follows is the only thing said. A readback exists to make a
# dropped clause visible (TRAPS 8); it cannot do that by saying nothing.
#
# THE RULE, AND IT IS THE RULE AND NOT THE THREE INSTANCES (TRAPS 11): a
# readback says something about every request the parser admits, and a part it
# could not read gets a WORD rather than silence. Every other door in Genesis
# already keeps it - "to shut a door" for a door with no sides,
# "to make a corner hard" for a corner that was not named,
# "to put opponents on the track" for a count that was not given,
# "to send someone somewhere" for a room that was not given. Driven over all
# eleven commands the whitelist admits, 171 rows, the only three that could
# say nothing were EQUIP, ORDER and PLAN, nine rows each, and every one of
# those nine was the single key that says WHAT was asked for.
#
# AND THE WORDS ARE NOT NEW, which is the reason this is a fix and not a
# wording decision. "a tool" and "an order" are what _doing() has said for
# exactly these inputs since 022, so they are the owner's words at the door
# he has already seen. "a plan" is Readback.article("plan"), which is the same
# mechanism _doing() uses for a step command it does not recognise - measured:
# a plan step whose command is PLAN already reads back as "a plan" today. The
# words are his to change; what cannot stand is the silence.
#
# AND THIS TABLE IS NOT DERIVED FROM THE COMMAND NAME, WHICH WAS TRIED AND
# MEASURED BEFORE IT WAS TYPED (TRAPS 82 points the other way here and the
# reason is worth keeping). Readback.article() over the three command names
# gives "a plan" and "an order" correctly and "AN EQUIP" for EQUIP, because
# EQUIP's subject is a TOOL and its command name is a verb. The nouns are not
# the commands, so there is nothing to derive from; a twelfth command whose
# readback can come back empty therefore needs a row here, and
# says_nothing_test section 7 is what says so - it drives every command the
# whitelist admits and fails by name on one that says nothing.
const UNREAD_SAID := {
	"EQUIP": "a tool",
	"ORDER": "an order",
	"PLAN": "a plan",
}

# --- 103: 102'S OWN RULE, ONE LEVEL IN: A PLAN *STEP* THAT SAID NOTHING ---
#
# 102 gave the PLAN door its word, so a plan whose `steps` could not be read
# says "a plan" instead of nothing. It did not ask the same question of a
# single STEP inside a readable plan, and _doing()'s last line - the one for a
# command this file has no sentence for - answered Readback.article() on the
# command token, which is "" when the token says nothing.
#
# MEASURED, by driving WorldRegistry.readback("PLAN", ...) before anything was
# changed, with the step's own `command` spoiled in the eight forms 102 used:
#
#   one step, command absent or ""        "a plan"   (102's door caught it)
#   a sound world, then that step         "a dungeon of a room, then "
#   that step, then a sound ORDER         " and an order to send someone to
#                                          room 1"
#   command "   "                         "a    " / "a     and an order ..."
#
# So the whole-readback case was covered and the per-step case was not: the
# sentence kept its connective and lost the thing the connective joins. A
# dangling "then" is worse than the silence 102 fixed, because it reads as a
# complete sentence about a step that was never named.
#
# THE WORD IS NOT NEW AND IS NOT DERIVED FROM A COMMAND NAME, which is the
# half UNREAD_SAID above could not supply - there is no command here to key
# on. It is the noun this project already uses for the thing: every refusal
# this step is about to get says "step %d: ...", plan_list() calls them steps,
# and the prompt asks the model for steps. Rendered through
# Readback.article(), the same mechanism the line below already used, so there
# is no second spelling of it. The word is the owner's to change; the silence
# is not his and was never anyone's decision.
const UNREAD_STEP_NOUN := "step"


# The word for a command whose subject could not be read at all.
static func _unread_said(command: String) -> String:
	return str(UNREAD_SAID.get(command, ""))


# What this door said, or the command's own word if it said nothing. The test
# is strip_edges() and not == "", because a value that says nothing includes
# the blank one - 095's rule, and the half the two guards in _doing() were
# missing: `if kit != ""` let three spaces through as a sentence.
static func _said_or_unread(command: String, said: String) -> String:
	return said if said.strip_edges() != "" else _unread_said(command)


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
			# 102: the word, not the silence. See UNREAD_SAID above.
			return _said_or_unread("EQUIP", ToolRegistry.readback(parameters))
		"ORDER":
			return _said_or_unread("ORDER", NpcGoals.readback(parameters))
		"SHUT":
			return NpcGoals.door_readback(parameters, true)
		"OPEN":
			return NpcGoals.door_readback(parameters, false)
		"PLAN":
			# 102: the guard is at the CALLER and not inside _plan_readback,
			# because that function has two ways to come back empty - steps
			# that are not a non-empty array, and steps whose every entry was
			# skipped for not being a dictionary - and one guard here covers
			# both.
			return _said_or_unread("PLAN", _plan_readback(parameters))
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
		# 097: a READBACK that said "a <null>". _doing()'s fallback below says
		# an unrecognised command back as a word - Readback.article(command
		# .to_lower()) - so a plan step whose command is null read back as
		# "a <null>", the engine's own debug spelling in the one line a player
		# reads before anything is validated. MEASURED by driving main.gd; this
		# door is outside says_nothing_test's sweep, which drives
		# WorldRegistry.readback() only for the REGISTERED module commands and
		# never for PLAN. Spelling only, and the sweep is widened to the whole
		# whitelist in the same commit so the next one is caught by the check
		# rather than by a reading (TRAPS 93).
		var step_command := Readback.spelled(step.get("command", "")).to_upper()
		var step_parameters: Dictionary = step.get("parameters", {})
		var module := find(step_command)
		if module != null:
			places.append(module.readback_short(step_parameters))
			# --- 044: the readback asks what was ASKED FOR, not what resolves ---
			#
			# This read around_of(step) >= 1, under a comment saying it was
			# "the same reading the builder uses, so the line cannot promise
			# a relationship the placement will not deliver". That claim was
			# false in both directions. For "around": 1.5 around_of() gave 1,
			# so the line read "one inside the other" for a plan the schema
			# pass then refused - a promise no placement would deliver. For
			# "around": null it gave 0, so the line read "side by side" for a
			# request that plainly asked for containment - the dropped clause
			# a readback exists to make visible (TRAPS 8).
			#
			# A readback is the interpretation layer and the question here is
			# whether this step asked to sit inside an earlier one. That is a
			# fact about the REQUEST, so it is read off the request. Whether
			# the step number is usable is the validation layer's question and
			# around_problem() answers it, in its own sentence, naming the
			# value (041) and the range. Keeping the two layers apart is
			# PROTOCOL section 2 and it is what this line was getting wrong.
			if _has_around(step):
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
			# 102: the fallback word is read off UNREAD_SAID rather than
			# written here, so this door and the single-command door above
			# cannot say different things about the same step again.
			var asked := NpcGoals.readback(parameters)
			return "an order %s" % asked if asked.strip_edges() != "" else _unread_said("ORDER")
		"EQUIP":
			return _said_or_unread("EQUIP", ToolRegistry.readback(parameters))
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
	#
	# 103: and when the token itself says nothing, there is no word to say
	# back, so the step gets the noun for what it is rather than silence. See
	# UNREAD_STEP_NOUN for the measurement and for why the word is not keyed
	# on a command. Readback.article() answers a token of three spaces as ""
	# since 103 as well, so one test covers all three forms.
	var token := Readback.article(command.to_lower())
	return token if token != "" else Readback.article(UNREAD_STEP_NOUN)


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


# --- 051: the measurements panel, and the layer each of its lines speaks for ---
#
# Every decision the panel makes about a record, in one function a suite can
# call. All four of them were inline in main.gd's _on_track_measured, which
# needs a RichTextLabel and a running UI, so NOTHING in tests/ had ever
# reached them: 047 and 049 between them put every panel line of all three
# worlds beside the geometry it describes, and the question of WHICH WORLD a
# panel is describing - which is what main.gd decided, not the modules - had
# never been asked of anything. HANDOVER named it as the next task and asked
# two questions of it: does every line stay inside what the caveat covers,
# and is the caveat shown in every case it is owed. Both had an answer and
# both answers were no.
#
# THE RULE, AND IT IS THE RULE AND NOT THE THREE INSTANCES (TRAPS 11): every
# line here is a CLAIM, and a claim is read from the field that answers it.
# Genesis keeps four evidence layers apart in one record and the panel is the
# place they are printed together, so this is where reading the wrong one
# costs something:
#
#   RESULT is the VALIDATION layer. "Valid dungeon" is a claim about the
#     PROPOSAL, so `result` is the right field and it keeps it. What it may
#     NOT do is name a world the record does not have - see below.
#   The caveat and the REASON are the CONSTRUCTION layer. "not a built
#     dungeon" is a claim about what was BUILT, and `construction` is the
#     field that answers it. Both were driven from `result`.
#
# A record with no `construction` key is treated as NOT built, because that
# is the direction PROTOCOL fixes: missing evidence must not become success.
#
# MEASURED, headless, before any of this was written:
#
#   a plan whose step 2 will not validate, step 1 a dungeon
#     step 1's record   result=VALID  construction=FAILED  category=FAILED_SCENE
#     the panel          RESULT "Valid dungeon" in GREEN, all ten measurement
#                        lines of a dungeon that does not exist, NO caveat and
#                        NO reason, because both asked `result`.
#   two worlds in a plan with no "around" (the shape of the prompt's own PLAN
#   skeleton): the same, twice, and the records are mutated to FAILED after
#   they are emitted and appended to the ledger a second time under the same
#   id - which is a separate finding, measured and left for its own commit.
#
# AND THE WORLD THAT WAS NAMED WHERE THERE WAS NONE, which is the half a
# player meets without a plan. `record.get("world", "circuit")` stood a
# Prototype 001 circuit in for any record whose `world` key is absent, and
# `world` is written by WorldModule.record_fields() - so it is absent from
# every record that is not a world. Measured, driven through GameController:
#
#   EQUIP a car   result=VALID  no `world` key  panel: "RESULT Valid circuit"
#   ORDER go_to   result=VALID  no `world` key  panel: "RESULT Valid circuit"
#   CLEAR_WORLD   result=VALID  no `world` key  panel: "RESULT Valid circuit"
#
# The last is the sharpest: a command whose whole job is to take a world
# AWAY, reported in green as a valid circuit. A record that names no world
# now names its COMMAND instead, which is the field it does have, and the
# wording of that is "Human decision needed" 17 rather than a thing this
# decided.
#
# Each line carries the ROLE it plays, so a suite can ask whether the caveat
# is there without asserting a sentence (TRAPS 6, TRAPS 14): what is being
# tested is whether the panel says a world was built, not which words it
# chose to say it in.
const PANEL_LABEL := "label"
const PANEL_VALUE := "value"
const PANEL_GOOD := "good"
const PANEL_BAD := "bad"


static func panel_built(record: Dictionary) -> bool:
	return str(record.get("construction", "")) == "BUILT"


# [{"role", "label", "value", "kind"}], in the order the panel prints them.
static func panel_lines(record: Dictionary) -> Array:
	var lines: Array = []
	# 037's field, read exactly as main.gd read it: the style the model wrote
	# on the request, or "not stated". An `intent` that is not an object is
	# not a style, and says so rather than throwing.
	var intent = record.get("intent", {})
	var style := "not stated"
	if typeof(intent) == TYPE_DICTIONARY and (intent as Dictionary).has("style"):
		style = str((intent as Dictionary)["style"])
	lines.append(_panel_line("requested", "REQUESTED", style, PANEL_VALUE))

	# RESULT states the VALIDATION layer's verdict, so it is printed only when
	# the record HAS one. `if valid ... else FAILED` printed a verdict for a
	# record with no `result` key at all, and there is exactly one of those:
	# record_load_check()'s. Measured, a load check whose outcome is "SAME"
	# made the panel read "RESULT  FAILED: " - a successful verification of a
	# reloaded world, reported in red as a failure, with an empty category
	# where the reason should be. Pre-existing and identical before 051; what
	# a load check's panel should say instead is "Human decision needed" 17,
	# because its record carries an `outcome`, a `said` and a `differences`
	# list and not one of them has ever been in the panel.
	if record.has("result"):
		if str(record["result"]) == "VALID":
			lines.append(_panel_line("result", "RESULT", "Valid " + _panel_subject(record), PANEL_GOOD))
		else:
			lines.append(_panel_line("result", "RESULT", "FAILED: " + str(record.get("category", "")), PANEL_BAD))

	var m: Dictionary = record.get("metrics", record.get("proposed_metrics", {}))
	var reasons: Array = record.get("reasons", [])
	if m.is_empty():
		if not reasons.is_empty():
			lines.append(_panel_line("reason", "REASON", str(reasons[0]), PANEL_BAD))
		return lines

	var module := find(str(record.get("command", "")))
	if not panel_built(record):
		lines.append(_panel_line("caveat", "",
			"(measurements below describe the proposal, not a built %s)" % _panel_subject(record),
			PANEL_LABEL))
	if module:
		for line in module.metric_lines(m, record):
			lines.append(_panel_line("metric", str((line as Array)[0]), str((line as Array)[1]), PANEL_VALUE))
	if not reasons.is_empty():
		lines.append(_panel_line("reason", "REASON", str(reasons[0]), PANEL_BAD))
	return lines


# What this record is ABOUT, named by the one function that names a world.
#
# NOT from the record's `world` field first, and that is the whole point.
# RacingModule.record_fields() deliberately omits `world` - racing records
# have never carried it, record_proposal_test asserts they still don't, and
# the owner's ledger is comparable across releases BECAUSE it is left alone
# (TRAPS 14, in the direction that says check before changing). So the old
# `record.get("world", "circuit")` was not a default that had never fired:
# it fired on EVERY CIRCUIT, where it happened to be right, which is exactly
# why nobody saw it standing a circuit in for a car.
#
# A world is named through display_name() - 032's rule, and the reason a
# plan says "a circuit of four sections" and not "a race circuit". So the
# module names it when there is one, which covers all three worlds without
# reading a ledger field at all; `world` is the fallback for the one record
# that sets it and has no module (a PLAN says "plan"); and anything else is
# named by its `command`, which _new_record() always writes. Nothing is
# invented and no world's name stands in for a record that has none.
static func _panel_subject(record: Dictionary) -> String:
	var module := find(str(record.get("command", "")))
	if module and module.display_name() != "":
		return module.display_name()
	var world := str(record.get("world", ""))
	if world != "":
		return world
	return str(record.get("command", "request"))


static func _panel_line(role: String, label: String, value: String, kind: String) -> Dictionary:
	return {"role": role, "label": label, "value": value, "kind": kind}
