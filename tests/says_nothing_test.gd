extends SceneTree

# --- 095: a default that answers an ABSENT key, and a value that is PRESENT
#          and says nothing ---
#
# WHERE THIS CAME FROM. 094 found one site by accident and wrote the general
# rule down rather than fixing the instance (TRAPS 11): CommandParser's
# "no reason given" answered a MISSING reason and not a present and empty one,
# so an UNSUPPORTED answer could refuse a player with the empty string, or
# with the six characters "<null>". HANDOVER's first live "Next action" asked
# for the READING to be widened before the count was trusted. It was, and the
# widening is what this file holds.
#
# WHAT THE WIDENED READING FOUND, and it is bigger than the grep could see.
# The grep was get("<key>", "<string literal>") and found thirteen sites. A
# parse of every .get() in scripts/ - 324 with a default, read across line
# breaks, classified by the KIND of the default - found two things that
# pattern cannot:
#
#   a default held in an IDENTIFIER or an EXPRESSION. CommandParser's own
#   fault is one of these (get("reason", reason)); LookTool reads
#   get("skin", DEFAULT_SKIN) twice.
#
#   AND THE SECOND HALF OF THE RULE, which is the part worth the commit:
#   A GUARD THAT ANSWERS THE EMPTY STRING DOES NOT ANSWER NULL. str(null) in
#   GDScript is the six-character string "<null>", which is not empty, so
#   thirteen sites written `if label == ""` let it through as a WORD. Those
#   sites all have an EMPTY default and were therefore outside the grep's
#   class entirely.
#
# MEASURED BY DRIVING IT, NOT BY READING IT (TRAPS 48), before a line was
# changed. The four worst, each reproduced in a throwaway copy:
#
#   a dungeon whose room was named null            validate ok=TRUE, and the
#                                                  room was KEPT as "<null>"
#   a thing named null                             ok=TRUE, kept as "<null>",
#                                                  while a thing named "" was
#                                                  correctly refused one
#                                                  branch above it
#   TrackBuilder.readback, difficulty null         "to make corner 1 <null>"
#   a boots/car/look spec with colour/paint/skin   "the ordinary  boots",
#   as the empty string, off the REFUSED-spec       "the ordinary  car",
#   readback path (ToolRegistry.asked_spec)         "a plain  head"
#
# Nothing in scripts/ or tests/ contained the substring "<null>" at all, so
# nothing could have noticed any of it. A dungeon could be built, today, with
# a room a player would see called <null>.
#
# WHAT THIS SUITE ASSERTS, AND WHY IT IS NOT A WORDING CHECK (TRAPS 6,
# TRAPS 14). "The readback says 'a room'" would test the wording and would
# pass against a site that had never been fixed, because the absent key always
# said that. What is asserted here is the PROPERTY, as an equality between
# measured outputs:
#
#   a value that says nothing is answered exactly as an ABSENT key is
#   answered.
#
# The expected sentence is never written down. It is taken from the same code,
# in the same run, by asking the same function with the key left out - so a
# site whose default WORDING changes legitimately moves nothing here, and a
# site that stops answering one of the four forms fails by name. Section 5 is
# the catch that needs no enumeration at all: no sentence any of these doors
# produces may contain "<null>".
#
# AND THE TOOL ROWS ARE KEYED OFF defaults() AND NOT LISTED HERE (TRAPS 82),
# so a tool that gains a text field is driven from the moment it gains it.
#
# --- 102: AND THE HEADER ABOVE IS AMENDED RATHER THAN LEFT, because this
#          commit makes part of it incomplete ---
#
# Everything above is about a value that is PRESENT and says nothing - null,
# empty, blank - reaching a sentence. 102 found the other half at the same
# doors: a readback that produces NO SENTENCE AT ALL. Three of the eleven
# commands the whitelist admits returned the empty string from
# WorldRegistry.readback() whenever the one key that says WHAT was asked for
# could not be read, and main.gd's _show_readback() returns on an empty line,
# so the player was told nothing. See section 7 and TRAPS 102.
#
# AND THE CHECKS IN THIS FILE COULD NOT SEE IT, which is why the amendment is
# here and not only in section 7. Six groups asked
# `said_in_this_run.size() > before_X`; _record() appends the empty string like
# any other, so a door that said nothing satisfied "said something". Measured:
# with the fault present and that floor in place, 108 assertions, failures=0.
# Every one of those sites asks about the CONTENT now (_said_something_since),
# and section 5's screen is unchanged - it never could have seen this, because
# the empty string contains no "<null>".
#
# WHAT IT IS NOT. It is a fault-finder for the five sites above and a guard
# against drift afterwards. It says nothing about whether the default WORD is
# the right word - the word for a nameless room is the owner's wording, not
# this file's - and nothing about the sites 095 measured and deliberately did
# not change, which are named in HANDOVER: a value that says nothing and is
# REFUSED either way, where the refusal quotes '<null>' back at the player.
# Those are refusals, not kept names, and their wording is the owner's.
#
# 103: THAT SENTENCE QUOTED THE WORD AS "a room" AND IS AMENDED RATHER THAN
# LEFT, because this commit changed it. The fallback is now the bare noun
# DungeonModule.UNNAMED_ROOM and the article is put on by whichever of the
# three sentences renders it: "a room" carried the article INSIDE the word, so
# two of those three sentences said it twice ("entered through a 10 m a room",
# "with a lamp in the a room") and the third said it not at all. Measured, and
# reachable with a room name of plain null. NOTHING IN THIS FILE WOULD HAVE
# FAILED ON ANY OF IT - the five said_or() assertions below pass "a room" as
# their own argument and are about said_or, not about the dungeon's choice -
# and the check that holds it now is in said_article_test, which is where
# 043 put the article rule. TRAPS 14 in its smallest form.

const CommandParser = preload("res://scripts/command_parser.gd")
const DungeonModule = preload("res://scripts/dungeon_module.gd")
const NpcGoals = preload("res://scripts/npc_goals.gd")
const Readback = preload("res://scripts/readback.gd")
const SectionValidator = preload("res://scripts/section_validator.gd")
const ToolRegistry = preload("res://scripts/tool_registry.gd")
const TrackBuilder = preload("res://scripts/track_builder.gd")
const WorldRegistry = preload("res://scripts/world_registry.gd")

# The four forms a key can take. ABSENT is the one every default was already
# written for; the other three are the ones that were not.
const ABSENT := "ABSENT"
const FORMS := ["EMPTY", "BLANK", "NULL"]

var asserted := 0
var bad := 0
# Every sentence this run produced, for section 5. Collected rather than
# declared, so it is exactly as wide as the run.
var said_in_this_run: Array[String] = []


func _check(ok: bool, what: String) -> void:
	asserted += 1
	if not ok:
		bad += 1
		print("  FAIL  ", what)


# A dictionary with `key` set to the form asked for, or left out for ABSENT.
func _with(base: Dictionary, key: String, form: String) -> Dictionary:
	var out := base.duplicate(true)
	match form:
		ABSENT: out.erase(key)
		"EMPTY": out[key] = ""
		"BLANK": out[key] = "   "
		"NULL": out[key] = null
		_: out[key] = form
	return out


func _record(said: String) -> void:
	said_in_this_run.append(said)


# --- 102: "it said something" counted COLLECTED sentences, not sentences that
#          say anything ---
#
# Every group below used to ask `said_in_this_run.size() > before_X`. _record()
# appends the empty string like any other, so a door that said NOTHING AT ALL
# satisfied "driving %s's readback with a null in it said something" - and
# three of them did. EQUIP, ORDER and PLAN returned "" from
# WorldRegistry.readback for every form of the one key that says WHAT was
# asked for: nine rows apiece out of 171 driven, found by driving main.gd and
# reading the panel, not by this suite. Section 5's screen could not see it
# either - the empty string contains no "<null>".
#
# So the suite written to find a readback that says nothing could not see a
# readback that says nothing, because it counted the collection and not the
# content (TRAPS 75's shape, at the door this file is named for). The question
# is asked of the CONTENT now, at all eight sites and in one function, and
# section 7 asks it per ROW at the door a player meets.
func _said_something_since(before: int) -> bool:
	for i in range(before, said_in_this_run.size()):
		if str(said_in_this_run[i]).strip_edges() != "":
			return true
	return false


func _how_many_said_something(before: int) -> int:
	var n := 0
	for i in range(before, said_in_this_run.size()):
		if str(said_in_this_run[i]).strip_edges() != "":
			n += 1
	return n


func _initialize() -> void:
	_the_reader()
	_the_speller()
	_the_tools()
	_the_dungeon()
	_the_track()
	_the_unsupported_reason()
	_every_door_with_a_null_in_it()
	_no_readback_says_nothing()
	# 103: BEFORE the screen below, not after it. This section _record()s every
	# sentence it drives, and section 6 is a screen over what the collectors
	# have put in that collection - a section added after it would be screened
	# by nothing and would look exactly like one that was.
	_no_plan_step_says_nothing()
	_no_engine_null_in_anything_said()
	print("SAYS NOTHING %d assertions, failures=%d" % [asserted, bad])
	quit(1 if bad > 0 else 0)


# --- 1. the reader itself ---
#
# Driven directly, because every other section rests on it and a reader that
# is wrong in one of the four forms would make the equalities below agree
# about the wrong answer.
func _the_reader() -> void:
	for form in FORMS:
		var d := _with({}, "name", form)
		_check(Readback.said(d, "name") == "",
			"said() reads a %s value as saying nothing (got '%s')" % [form, Readback.said(d, "name")])
		_check(Readback.said_or(d, "name", "a room") == "a room",
			"said_or() gives the fallback for a %s value (got '%s')" % [form, Readback.said_or(d, "name", "a room")])
	_check(Readback.said({}, "name") == "", "said() reads an absent key as saying nothing")
	_check(Readback.said_or({}, "name", "a room") == "a room", "said_or() gives the fallback for an absent key")
	# And the half that must NOT change: a value that does say something.
	_check(Readback.said({"name": "  great hall  "}, "name") == "great hall",
		"said() strips the edges of a value that says something")
	_check(Readback.said_or({"name": "great hall"}, "name", "a room") == "great hall",
		"said_or() returns a value that says something")
	_check(Readback.said_or({"name": " great hall "}, "name", "a room") == " great hall ",
		"said_or() returns it AS IT WAS SENT, because a readback shows what was heard")


# --- 2. every text field of every tool, through the REFUSED-spec readback ---
#
# The fields are read off each tool's own defaults(), so this drives whatever
# text fields the tools have rather than whatever was true in 095. The path is
# ToolRegistry.readback(), which is the one a player actually meets: a spec
# that fails validation is still described, from asked_spec(), so these
# readers see what was SENT.
func _the_tools() -> void:
	var driven := 0
	for tool in ToolRegistry.tools():
		var t := tool as ToolModule
		var base := {"tool": t.name(), "spec": {}}
		for key in t.defaults():
			if typeof(t.defaults()[key]) != TYPE_STRING:
				continue
			driven += 1
			var absent := ToolRegistry.readback({"tool": t.name(), "spec": {}})
			_record(absent)
			for form in FORMS:
				var spec := _with({}, str(key), form)
				var got := ToolRegistry.readback({"tool": t.name(), "spec": spec})
				_record(got)
				_check(got == absent,
					"%s readback: '%s' as a %s value is said as it is when the key is absent ('%s' vs '%s')" % [
						t.name(), str(key), form, got, absent])
	# The denominator, so a reader that goes blind fails instead of passing on
	# an empty loop (TRAPS 75).
	_check(driven >= 5,
		"the tools declare text fields for this to drive (drove %d)" % driven)


# --- 3. the dungeon's names, at the validator AND at the readback ---
#
# Two different doors, because the fault was at both and they answer
# differently: the validator KEEPS a name (so a null one became a room called
# <null> in a built world), and the readback SAYS one before anything is
# validated at all.
func _the_dungeon() -> void:
	var dungeon := DungeonModule.new()
	var sound := {
		"intent": {"style": "a dungeon"},
		"rooms": [{"name": "hall", "width": 10.0, "depth": 10.0},
			{"name": "vault", "width": 10.0, "depth": 10.0}],
		"doors": [[1, 2]],
	}

	# (a) the room name the validator keeps.
	var kept_absent := _room_kept(dungeon, sound, ABSENT)
	_check(kept_absent != "", "a room with no name is still given one (got '%s')" % kept_absent)
	for form in FORMS:
		var kept := _room_kept(dungeon, sound, form)
		_check(kept == kept_absent,
			"a room named by a %s value is kept as a room with no name is kept ('%s' vs '%s')" % [
				form, kept, kept_absent])

	# (b) the thing name, which the validator REFUSES rather than renames -
	# the site's own policy, applied to all four forms rather than to two.
	var thing_base: Dictionary = sound.duplicate(true)
	thing_base["things"] = [{"in": 1}]
	var absent_verdict := _thing_verdict(dungeon, thing_base, ABSENT)
	for form in FORMS:
		var verdict := _thing_verdict(dungeon, thing_base, form)
		_check(verdict == absent_verdict,
			"a thing named by a %s value is answered as a thing with no name is ('%s' vs '%s')" % [
				form, verdict, absent_verdict])

	# (c) the readback, over RAW parameters, before anything is validated.
	var said_absent := _dungeon_said(dungeon, sound, ABSENT)
	_record(said_absent)
	for form in FORMS:
		var said := _dungeon_said(dungeon, sound, form)
		_record(said)
		_check(said == said_absent,
			"the dungeon readback says a %s room name as it says an absent one ('%s' vs '%s')" % [
				form, said, said_absent])


func _room_kept(dungeon: DungeonModule, sound: Dictionary, form: String) -> String:
	var p: Dictionary = sound.duplicate(true)
	(p["rooms"] as Array)[0] = _with({"width": 10.0, "depth": 10.0}, "name", form)
	var res: Dictionary = dungeon.validate(p)
	if not bool(res.get("ok", false)):
		return "REFUSED: " + str(res.get("errors", []))
	var rooms: Array = (res["content"] as Dictionary)["rooms"]
	return str((rooms[0] as Dictionary).get("name", ""))


func _thing_verdict(dungeon: DungeonModule, base: Dictionary, form: String) -> String:
	var p: Dictionary = base.duplicate(true)
	(p["things"] as Array)[0] = _with({"in": 1}, "name", form)
	var res: Dictionary = dungeon.validate(p)
	return "%s %s" % [str(res.get("ok", "?")), str(res.get("errors", []))]


func _dungeon_said(dungeon: DungeonModule, sound: Dictionary, form: String) -> String:
	var p: Dictionary = sound.duplicate(true)
	(p["rooms"] as Array)[0] = _with({"width": 40.0, "depth": 40.0}, "name", form)
	return dungeon.readback(p)


# --- 4. the track's difficulty, at the readback ---
#
# TrackBuilder.readback() already had the empty branch and not the null one,
# which is why this is the clearest single instance of the second half of the
# rule: the site's policy was right and its reading was two forms short.
func _the_track() -> void:
	var absent := TrackBuilder.readback({"corner": 1})
	_record(absent)
	for form in FORMS:
		var got := TrackBuilder.readback(_with({"corner": 1}, "difficulty", form))
		_record(got)
		_check(got == absent,
			"the track readback says a %s difficulty as it says an absent one ('%s' vs '%s')" % [
				form, got, absent])
	# And the half that must not change, or the equality above could be had by
	# a reader that ignores the field altogether (TRAPS 79's shape).
	var named := TrackBuilder.readback({"corner": 1, "difficulty": "hard"})
	_record(named)
	_check(named != absent and named.contains("hard"),
		"a difficulty that DOES say something is still said ('%s')" % named)


# --- 5. the UNSUPPORTED reason, which is 094's own finding ---
#
# The one refusal a player meets when Genesis says it cannot do the thing at
# all. Driven through CommandParser.parse() as a raw JSON answer, which is the
# shape the AI actually sends.
func _the_unsupported_reason() -> void:
	var absent := str(CommandParser.parse('{"command":"UNSUPPORTED","parameters":{}}').get("error", ""))
	_record(absent)
	_check(absent != "", "an UNSUPPORTED answer with no reason still says something ('%s')" % absent)
	var bodies := {
		"EMPTY": '{"command":"UNSUPPORTED","parameters":{"reason":""}}',
		"BLANK": '{"command":"UNSUPPORTED","parameters":{"reason":"   "}}',
		"NULL": '{"command":"UNSUPPORTED","parameters":{"reason":null}}',
	}
	for form in bodies:
		var got := str(CommandParser.parse(str(bodies[form])).get("error", ""))
		_record(got)
		_check(got == absent,
			"an UNSUPPORTED reason that is %s is answered as a missing one is ('%s' vs '%s')" % [
				form, got, absent])
	# A reason that says something is still the player's own words.
	var real := str(CommandParser.parse('{"command":"UNSUPPORTED","parameters":{"reason":"no dragons in this game"}}').get("error", ""))
	_record(real)
	_check(real == "no dragons in this game",
		"a reason that DOES say something is passed through ('%s')" % real)


# --- 6. and the catch that needs no enumeration ---
#
# Every sentence the sections above produced, asked one question. "<null>" is
# the engine's own debug spelling of a value that is not there; it is never a
# word in this game, and a player who reads it has been handed a bug report
# instead of a sentence. This is the only assertion here that would have
# caught all five of 095's sites without knowing what they were.
#
# The denominator is asserted, because an empty collection would pass this in
# silence - TRAPS 75, which is the shape half this project's findings have.
func _no_engine_null_in_anything_said() -> void:
	# 102: the denominator counts sentences that SAY something, for the reason
	# written beside _said_something_since().
	_check(_how_many_said_something(0) >= 20,
		"this run produced sentences to examine (%d of %d collected)" % [
			_how_many_said_something(0), said_in_this_run.size()])
	# 096: THE SCREEN ITSELF WAS ONE GREP WIDE (TRAPS 78). It looked for the
	# lower-case spelling, and CommandParser puts the command through
	# to_upper() before it is quoted - so "Rejected command: <NULL>" was
	# reachable, was being produced, and this check could not see it. Measured:
	# the sweep below found 43 leaking call sites with a case-insensitive
	# screen and 42 with this one, and the one it could not see was that
	# sentence. The question is about the ENGINE'S SPELLING reaching a player,
	# and a sentence that has been upper-cased on the way is the same fault.
	var leaking: Array[String] = []
	for said in said_in_this_run:
		if said.to_lower().contains(Readback.ENGINE_NOTHING.to_lower()):
			leaking.append(said)
	_check(leaking.is_empty(),
		"no sentence any of these doors produced contains the engine's spelling of nothing (%d sentences)" % said_in_this_run.size() if leaking.is_empty() else
		"a sentence a player reads contains the engine's spelling of nothing: " + str(leaking))


# --- 096: the speller itself ---
#
# Driven directly, for the reason section 1 is: the sweep below rests on it,
# and a reader wrong in one form would make the sweep agree about nothing.
func _the_speller() -> void:
	_check(Readback.spelled(null) == "null",
		"spelled() says a null in the notation it arrived in (got '%s')" % Readback.spelled(null))
	_check(not Readback.spelled(null).to_lower().contains(Readback.ENGINE_NOTHING.to_lower()),
		"spelled() does not hand back the engine's spelling")
	# THE FIGURE THAT WAS WRONG IN TWELVE PLACES, now measured rather than
	# counted by eye: str(null) is SIX characters, not five. Asserted so the
	# comments that say six are tied to something.
	_check(str(null).length() == 6,
		"the engine's spelling of nothing is six characters (got %d)" % str(null).length())
	_check(Readback.ENGINE_NOTHING == str(null),
		"the reader's own constant is what the engine actually prints ('%s' vs '%s')" % [
			Readback.ENGINE_NOTHING, str(null)])
	# A null NESTED in a container is the same fault one level down, which is
	# why spelled() answers the rendering and not only `value == null`.
	for nested in [[null], {"a": null}, [[null]]]:
		_check(not Readback.spelled(nested).to_lower().contains(Readback.ENGINE_NOTHING.to_lower()),
			"spelled() answers a null inside a container (got '%s')" % Readback.spelled(nested))
	# And the half that must NOT change: a value that says something is said
	# exactly as str() says it, edges and all (TRAPS 8).
	for keeps in ["hall", "  hall  ", "", "   ", 1, 2.5, true, [1, 2]]:
		_check(Readback.spelled(keeps) == str(keeps),
			"spelled() leaves a value that says something exactly as it was ('%s' vs '%s')" % [
				Readback.spelled(keeps), str(keeps)])


# --- 096: EVERY DOOR, WITH A NULL IN EVERY FIELD, AND NO LIST OF SITES ---
#
# WHY THIS EXISTS AND WHY IT IS NOT A LONGER TABLE. 095 fixed the half of this
# class where a value that says nothing was KEPT, wrote in its commit message
# and in HANDOVER that "a readback can no longer say <null>", and left the
# refusal half for the owner. BOTH halves of that were short:
#
#   THE CLAIM WAS FALSE WHEN IT WAS WRITTEN. Three readbacks still said it -
#   the farm's zone type and crop, the circuit's section type, and the door
#   readback's room name - every one of them the same `str(x.get(k, ""))` with
#   an `== ""` guard that 095 fixed at the dungeon and the track. The grep
#   that found 095's thirteen sites is 81 lines long for that shape today, so
#   the class was never going to be closed by reading it site by site.
#
#   AND THE REFUSAL HALF WAS SIX DOORS IN HANDOVER AND NINE IN THE CODE: the
#   section type, the zone type and the door's room name were not on the list.
#
# So the check is not a list. It is an EXECUTION SWEEP with a denominator,
# which is the method TRAPS 87 came out of: drive every door that makes a
# sentence, poison one leaf of the request at a time, collect everything said,
# and ask one question of all of it. A site that starts leaking is caught
# whether or not anybody thought of it, and a door added to the game is driven
# from the moment its module or tool is registered.
#
# MEASURED BEFORE THE FIX, over the same 214 sentences this drives: 43 leaking
# call sites, 26 distinct sentences. After: 0.
#
# WHAT IT ASSERTS IS THE PROPERTY AND NEVER THE WORDING (TRAPS 6, TRAPS 14).
# No sentence is written down here. The only claims are "the engine's spelling
# of nothing does not appear, in any case" and "this sweep actually drove
# something", and a site whose wording changes legitimately moves neither.
#
# A MODULE WITH NO FIXTURE IS A FAILURE AND NEVER A SKIP, which is the shape
# built_count_test and ledger_said_test both use: a world nobody drives here
# is a world whose sentences nobody is checking.
const SOUND := {
	"CREATE_FARM": {"intent": {"style": "a farm"}, "zones": [
		{"type": "crop", "crop": "wheat", "width": 40.0, "depth": 40.0},
		{"type": "barn", "width": 20.0, "depth": 20.0}]},
	"CREATE_TRACK": {"intent": {"style": "a street circuit"}, "mode": "circuit", "sections": [
		{"type": "straight", "length": 200.0},
		{"type": "corner", "radius": 50.0, "angle": 90.0},
		{"type": "straight", "length": 200.0},
		{"type": "corner", "radius": 50.0, "angle": 90.0},
		{"type": "straight", "length": 200.0},
		{"type": "corner", "radius": 50.0, "angle": 90.0},
		{"type": "straight", "length": 200.0},
		{"type": "corner", "radius": 50.0, "angle": 90.0}]},
	"CREATE_DUNGEON": {"intent": {"style": "a dungeon"}, "rooms": [
		{"name": "hall", "width": 10.0, "depth": 10.0},
		{"name": "vault", "width": 10.0, "depth": 10.0}],
		"doors": [[1, 2]], "things": [{"name": "red key", "in": 1}]},
}


# 097: one sound request per command the whitelist admits, for group (f). The
# worlds reuse SOUND above rather than repeating it. These are the PARAMETERS
# a readback is handed, not whole requests - WorldRegistry.readback() takes the
# command apart from them.
const PLAN_SHAPE := {"steps": [
	{"command": "EQUIP", "parameters": {"tool": "boots"}},
	{"command": "ORDER", "parameters": {"goal": "go_to", "room": 2}},
]}


static func _shapes() -> Dictionary:
	var out := {
		"PLAN": PLAN_SHAPE,
		"MODIFY_TRACK": {"corner": 1, "difficulty": "hard"},
		"SPAWN_OPPONENTS": {"count": 3},
		"CLEAR_WORLD": {},
		"EQUIP": {"tool": "boots", "spec": {"colour": "brown"}},
		"ORDER": {"goal": "carry", "thing": "red key", "room": 2},
		"SHUT": {"between": ["hall", "vault"]},
		"OPEN": {"between": ["hall", "vault"]},
	}
	for command in SOUND:
		out[command] = SOUND[command]
	return out


func _every_door_with_a_null_in_it() -> void:
	var before := said_in_this_run.size()

	# (a) every registered world module, at its validator and both readbacks.
	var modules := 0
	for module in WorldRegistry.modules():
		var m := module as WorldModule
		var cmd := m.command()
		_check(SOUND.has(cmd),
			"this sweep has a sound request for %s to poison (a module with none is not being driven)" % cmd)
		if not SOUND.has(cmd):
			continue
		modules += 1
		# 097: PER THING AND NOT PER RUN. 096 left this as its third live
		# entry, MEASURED: empty one of the sweep's groups and the whole thing
		# was silent, because the denominator at the bottom is a floor over the
		# WHOLE collection. 096 named the fix as a per-group count and warned
		# against closing it with hardcoded expected counts (TRAPS 82). This is
		# neither: it asks, of each thing the REGISTRY declares, whether
		# driving it produced a sentence at all - so there is no number here to
		# maintain and a group that stops driving one of its members fails by
		# that member's name. 097 had to write it because 097 adds a sixth
		# group, (f), with the same hole.
		var before_module := said_in_this_run.size()
		for poisoned in _one_null_each(SOUND[cmd]):
			_errors_said(m.validate(poisoned))
			_record(WorldRegistry.readback(cmd, poisoned))
			_record(m.readback_short(poisoned))
		_check(_said_something_since(before_module),
			"driving %s with a null in it said something" % cmd)
	_check(modules >= 3, "the registry declares world modules for this to drive (drove %d)" % modules)

	# (b) the section validator directly, because RacingModule delegates to it
	# and the delegate is where the sentences are written.
	var before_sections := said_in_this_run.size()
	for poisoned in _one_null_each(SOUND["CREATE_TRACK"]):
		_errors_said(SectionValidator.validate(poisoned))
	_check(_said_something_since(before_sections),
		"driving the section validator with a null in it said something")

	# (c) every registered tool, at its validator and at the readback a player
	# meets for a REFUSED spec. Keyed off defaults(), like section 2.
	var tools := 0
	for tool in ToolRegistry.tools():
		var t := tool as ToolModule
		tools += 1
		var before_tool := said_in_this_run.size()
		for poisoned in _one_null_each({"tool": t.name(), "spec": t.defaults().duplicate(true)}):
			_errors_said(t.validate(poisoned))
			_record(ToolRegistry.readback(poisoned))
		_check(_said_something_since(before_tool),
			"driving the %s with a null in it said something" % t.name())
	_check(tools >= 3, "the registry declares tools for this to drive (drove %d)" % tools)

	# (d) the orders and the doors, which are the dungeon's own sentences and
	# live in NpcGoals rather than in the module.
	var rooms := [{"name": "hall"}, {"name": "vault"}]
	var things := [{"name": "red key"}]
	var layout := {"rooms": rooms, "doors": [Vector2i(0, 1)]}
	for base in [{"goal": "go_to", "room": 2}, {"goal": "carry", "thing": "red key", "room": 2}]:
		var before_goal := said_in_this_run.size()
		for poisoned in _one_null_each(base):
			_errors_said(NpcGoals.validate(poisoned, rooms, things))
			_record(NpcGoals.readback(poisoned))
		_check(_said_something_since(before_goal),
			"driving a %s order with a null in it said something" % str(base["goal"]))
	var before_door := said_in_this_run.size()
	for poisoned in _one_null_each({"between": ["hall", "vault"]}):
		_errors_said(NpcGoals.validate_door(poisoned, rooms, layout))
		_record(NpcGoals.door_readback(poisoned, true))
		_record(NpcGoals.door_readback(poisoned, false))
	_check(_said_something_since(before_door),
		"driving a door with a null in it said something")

	# (f) 097: EVERY COMMAND THE WHITELIST ADMITS, through the one readback a
	# player meets before anything is validated. (a) above drives
	# WorldRegistry.readback() for the REGISTERED MODULE commands only, which
	# is three of the eleven, so PLAN's readback was never driven here at all -
	# and it said "a <null>" for a plan whose step command is null, because
	# _doing()'s fallback says an unrecognised command back as a word. Found by
	# driving main.gd, not by reading the code; fixed in world_registry.gd in
	# the same commit. Keyed off CommandParser.allowed_commands() rather than a
	# list beside the code (TRAPS 82), so a twelfth command is driven from the
	# moment the whitelist admits it, and off SHAPES keyed by command so a
	# command with no shape here is a FAILURE and never a skip - the same rule
	# (a) uses for a module with no fixture.
	var SHAPES := _shapes()
	var commands := 0
	for command in CommandParser.allowed_commands():
		_check(SHAPES.has(command),
			"this sweep has a request for %s to poison (a command with none is not being driven)" % command)
		if not SHAPES.has(command):
			continue
		commands += 1
		var before_command := said_in_this_run.size()
		# 102: PER ROW AND NOT PER GROUP, at this door only. The floor below
		# is right for the groups that drive VALIDATORS - a refusal is owed
		# once per request, not once per field - but this group drives the one
		# READBACK a player meets before anything is validated, and that line
		# is owed for every request the parser admits. A floor here passed
		# while three of the eleven commands said nothing for every form of
		# their subject, because the other leaves of the same request still
		# produced sentences.
		for poisoned in _one_null_each(SHAPES[command]):
			var said := WorldRegistry.readback(command, poisoned)
			_record(said)
			_check(said.strip_edges() != "",
				"%s's readback says something for %s" % [command, JSON.stringify(poisoned)])
		_check(_said_something_since(before_command),
			"driving %s's readback with a null in it said something" % command)
	_check(commands == CommandParser.allowed_commands().size(),
		"every command the whitelist admits was driven (%d of %d)" % [
			commands, CommandParser.allowed_commands().size()])

	# (e) the parser, whose own field is the command.
	#
	# 102: THIS GROUP'S OWN FIXTURE WAS WRONG ABOUT ONE OF ITS THREE BODIES,
	# and the floor that counted collected sentences is what hid it. The row
	# `{"command":"CREATE_FARM","parameters":null}` was listed here as a body
	# the parser refuses; it does not. `parameters` of the wrong type is
	# SILENTLY DROPPED to `{}` by parse() - read off command_parser.gd, the
	# branch is `if data.has("parameters") and typeof(...) == TYPE_DICTIONARY`
	# with no else - so the parse comes back ok=true with error "", and
	# _record("") satisfied "parsing ... said something" because the empty
	# string was still a collected entry.
	#
	# The question is asked of the parse RESULT now rather than of a belief
	# about it: a body the parser REFUSES must say why, and a body it ACCEPTS
	# must be answered by the readback a player meets, which is the line shown
	# before anything is validated. Either way the player is told something.
	# The third row is therefore still driven and is still load-bearing - it
	# is the one that proves the drop is quiet.
	for body in [
		'{"command":null,"parameters":{}}',
		'{"command":"CREATE_FARM","parameters":null}',
		'{"command":["x"],"parameters":{}}',
	]:
		var before_body := said_in_this_run.size()
		var parsed := CommandParser.parse(body)
		var refused := not bool(parsed.get("ok", false))
		if refused:
			_record(str(parsed.get("error", "")))
			_check(_said_something_since(before_body),
				"the parser refusing %s said why" % body)
		else:
			_record(WorldRegistry.readback(str(parsed.get("command", "")),
				parsed.get("parameters", {})))
			_check(_said_something_since(before_body),
				"%s is ACCEPTED by the parser and the readback says something" % body)

	# The denominator (TRAPS 75). A sweep that drives nothing passes every
	# absence question ever asked of it, which is half this project's findings.
	var drove := _how_many_said_something(before)
	_check(drove >= 150, "the sweep produced sentences that say something (%d of %d collected)" % [
		drove, said_in_this_run.size() - before])


# --- 7. 102: THE SUBJECT IN EVERY FORM, NOT ONLY NULL ---
#
# Group (f) above poisons LEAVES WITH NULL, which is 095's class. The fault
# 102 found is wider than null and narrower than the whole request: it is the
# one key of each command that says WHAT was asked for - `tool`, `goal`,
# `steps` - and it emptied the readback in EVERY form, not just as null.
# Measured on the code before the fix, over the same shapes group (f) uses:
#
#   171 rows driven, 27 said NOTHING AT ALL
#   EQUIP   9 of 9: tool absent, "", "   ", null, a word, a number, [], {},
#           and no parameters at all
#   ORDER   9 of 9, the same nine, driven by `goal`
#   PLAN    9 of 9, the same nine, driven by `steps`
#   the other EIGHT commands: 0 of their rows, every form
#
# So a fix that guarded null alone would have left eight ninths of it
# standing, and a check that drove null alone would have said so. This drives
# every top-level key of every command's own shape in all eight forms, plus
# the request with no parameters at all - and the forms are what a hand-edited
# model answer can actually contain.
#
# WHAT IT ASSERTS AND WHY IT IS NOT A WORDING CHECK (TRAPS 6, TRAPS 14). Not
# that any door says any sentence: that every door says SOMETHING, and that a
# request Genesis CAN read is not answered with the fallback word. The words
# themselves are read off WorldRegistry.UNREAD_SAID rather than typed here
# (TRAPS 82), so the owner can change any of them without touching this file,
# and a word removed from that table fails by its command's name.
const SPOIL := ["ABSENT", "EMPTY", "BLANK", "NULL", "WORD", "NUMBER", "LIST", "DICT"]


func _spoil(form: String) -> Variant:
	match form:
		"EMPTY": return ""
		"BLANK": return "   "
		"NULL": return null
		"WORD": return "hovercraft"
		"NUMBER": return 7
		"LIST": return []
		"DICT": return {}
	return null


func _no_readback_says_nothing() -> void:
	var SHAPES := _shapes()
	var rows := 0
	for command in CommandParser.allowed_commands():
		# The same rule group (f) uses: a command with no shape here is a
		# FAILURE and never a skip, so a twelfth command joins this sweep from
		# the moment the whitelist admits it.
		_check(SHAPES.has(command),
			"this sweep has a request for %s to spoil (a command with none is not being driven)" % command)
		if not SHAPES.has(command):
			continue
		var sound: Dictionary = SHAPES[command]

		# a) the request Genesis CAN read says something, and says something
		#    other than the word kept for a request it cannot.
		var said_sound := WorldRegistry.readback(command, sound)
		rows += 1
		_check(said_sound.strip_edges() != "",
			"%s's readback says something for a request it can read" % command)
		var word := str(WorldRegistry.UNREAD_SAID.get(command, ""))
		if word != "":
			_check(said_sound != word,
				"%s's fallback word has not swallowed a request it can read (said '%s')" % [
					command, said_sound])

		# b) no parameters at all.
		rows += 1
		var said_bare := WorldRegistry.readback(command, {})
		_record(said_bare)
		_check(said_bare.strip_edges() != "",
			"%s's readback says something with no parameters at all" % command)

		# c) every top-level key of its own shape, in every form. The keys are
		#    the shape's rather than a list here, so a command whose request
		#    gains a field is driven on that field from the moment it has it.
		for key in sound.keys():
			for form in SPOIL:
				rows += 1
				var spoiled: Dictionary = sound.duplicate(true)
				if form == "ABSENT":
					spoiled.erase(key)
				else:
					spoiled[str(key)] = _spoil(form)
				var said := WorldRegistry.readback(command, spoiled)
				_record(said)
				_check(said.strip_edges() != "",
					"%s's readback says something with '%s' %s" % [command, str(key), form])

	# The words themselves are a class and are asked about here rather than
	# left to the three call sites: a word for a command the whitelist does
	# not admit is dead, and a word that says nothing is not a word.
	for command in WorldRegistry.UNREAD_SAID:
		_check(command in CommandParser.allowed_commands(),
			"%s, which has a fallback word, is a command the whitelist admits" % str(command))
		_check(str(WorldRegistry.UNREAD_SAID[command]).strip_edges() != "",
			"%s's fallback word says something" % str(command))

	# The denominator (TRAPS 75), derived from the whitelist rather than
	# remembered: at least the bare request and the sound one per command.
	_check(rows >= CommandParser.allowed_commands().size() * 2,
		"the sweep drove rows for every command (%d rows, %d commands)" % [
			rows, CommandParser.allowed_commands().size()])


# Every sentence a refusal gave, into the same collection section 6 reads.
func _errors_said(result: Dictionary) -> void:
	for e in result.get("errors", []):
		_record(str(e))


# The sound request, and then one copy per LEAF of it with that leaf set to
# null - nested fields included, because a zone's type and a section's type
# are leaves two levels down and are exactly where this was found.
func _one_null_each(base: Dictionary) -> Array:
	var out: Array = [base.duplicate(true)]
	var paths: Array = []
	_leaves(base, "", paths)
	for path in paths:
		var copy: Dictionary = base.duplicate(true)
		_plant(copy, (str(path).substr(1)).split("/"), 0)
		out.append(copy)
	return out


func _leaves(value: Variant, prefix: String, out: Array) -> void:
	match typeof(value):
		TYPE_DICTIONARY:
			for key in (value as Dictionary):
				_leaves((value as Dictionary)[key], prefix + "/" + str(key), out)
		TYPE_ARRAY:
			for i in (value as Array).size():
				_leaves((value as Array)[i], prefix + "/" + str(i), out)
		_:
			out.append(prefix)


func _plant(into: Variant, path: PackedStringArray, at: int) -> void:
	var step := path[at]
	var last := at == path.size() - 1
	if typeof(into) == TYPE_DICTIONARY:
		if last:
			(into as Dictionary)[step] = null
		else:
			_plant((into as Dictionary)[step], path, at + 1)
	elif typeof(into) == TYPE_ARRAY:
		if last:
			(into as Array)[int(step)] = null
		else:
			_plant((into as Array)[int(step)], path, at + 1)


# --- 9. 103: A PLAN *STEP* THAT SAID NOTHING, WHICH SECTION 7 DRIVES PAST ---
#
# Section 7 spoils every TOP-LEVEL key of every command's request, and PLAN's
# top-level key is `steps`. Spoil it in any of the eight forms and
# _plan_readback() returns "" and 102's door answers "a plan", which is
# exactly what section 7 asserts and it is correct. The STEP's own `command`
# is one level further in, so nothing here reached it, and WorldRegistry's
# _doing() answered Readback.article() on the token - "" when the token says
# nothing. MEASURED on 102's code, before anything was changed:
#
#   one step, command absent or ""   "a plan"            section 7's catch
#   a sound world, then that step    "a dungeon of a room, then "
#   that step, then a sound ORDER    " and an order to send someone to room 1"
#   command "   "                    "a    " / "a     and an order ..."
#
# So the half the readback kept was the CONNECTIVE and the half it lost was
# the thing the connective joins, which reads as a finished sentence about a
# step that was never named. That is why this section asks TWO questions and
# not one: "it says something" is satisfied by the sound half of a plan, and
# would have passed every row above that has a world in it.
#
# THE SECOND QUESTION IS ABOUT THE CLAUSES. The sentence is cut at the three
# joins _plan_readback() and Readback._join() use - ", then ", " and " and
# ", " - and no piece of it may be empty. That is the fault stated as a
# property of the sentence rather than as a list of the four shapes above, so
# a ninth form or a third position is covered without being enumerated here.
#
# NOT ASSERTED: the WORD. UNREAD_STEP_NOUN is the owner's, and what is held
# here is that it says something and that it is reached - never its spelling.
func _no_plan_step_says_nothing() -> void:
	var sound_world := {"command": "CREATE_DUNGEON", "parameters": {
		"rooms": [{"name": "hall", "width": 10, "depth": 10}], "doors": []}}
	var sound_order := {"command": "ORDER", "parameters": {"goal": "go_to", "room": 1}}

	var noun: String = WorldRegistry.UNREAD_STEP_NOUN
	_check(noun.strip_edges() != "", "the word for a step that says nothing says something")
	_check(Readback.article(noun).strip_edges() != "",
		"and it survives the reader that renders it (article('%s') is '%s')" % [
			noun, Readback.article(noun)])

	# The controls first, so a sweep that silently stopped driving anything
	# cannot pass on the strength of its own emptiness (TRAPS 75).
	var driven := 0
	for control in [[sound_world], [sound_world, sound_order], [sound_order]]:
		var said := WorldRegistry.readback("PLAN", {"steps": control})
		_record(said)
		_check(said.strip_edges() != "", "a plan of sound steps says something ('%s')" % said)
		_check(_no_empty_clause(said), "and no clause of it is empty ('%s')" % said)

	for form in SPOIL:
		var step := {"parameters": {}}
		if form != "ABSENT":
			step["command"] = _spoil(form)
		# Alone, after a sound world, and before a sound order: the first is
		# the only position 102's door can rescue, and the other two are where
		# the connective was left holding nothing.
		for place in [[step], [sound_world, step], [step, sound_order]]:
			driven += 1
			var said := WorldRegistry.readback("PLAN", {"steps": place})
			_record(said)
			_check(said.strip_edges() != "",
				"a plan whose step command is %s says something (%d steps, got '%s')" % [
					form, (place as Array).size(), said])
			_check(_no_empty_clause(said),
				"and no clause of it is empty (%s, %d steps, got '%s')" % [
					form, (place as Array).size(), said])

	_check(driven == SPOIL.size() * 3,
		"every form was driven in every position (%d rows, expected %d)" % [
			driven, SPOIL.size() * 3])


# No piece of this sentence is empty OR nothing but an article, cut at the
# joins the plan readback and Readback._join() actually use. A sentence that
# kept its connective and lost what the connective joins is the 103 fault, and
# it is invisible to "it said something" whenever any other part of the plan
# could be read.
#
# THE SECOND HALF WAS ADDED BECAUSE THE FIRST HALF PASSED AN INJECTED FAULT
# (TRAPS 6). With Readback.article()'s emptiness test put back to `word == ""`,
# a step command of three spaces renders as "a" and four spaces, and
# strip_edges() on that is "a" - not empty, so the clause test was satisfied by
# an article with nothing after it. The article words are typed in as facts
# about English, which is how this file holds its other such facts, and not
# read back out of the function under test.
const ARTICLES := ["a", "an", "the"]


func _no_empty_clause(said: String) -> bool:
	if said.strip_edges() == "":
		return false
	var pieces: Array = [said]
	for join in [", then ", " and ", ", "]:
		var next: Array = []
		for piece in pieces:
			for part in str(piece).split(join, true):
				next.append(part)
		pieces = next
	for piece in pieces:
		var clause := str(piece).strip_edges()
		if clause == "" or clause.to_lower() in ARTICLES:
			return false
	return true
