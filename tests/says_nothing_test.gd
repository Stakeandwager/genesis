extends SceneTree

# --- 095: a default that answers an ABSENT key, and a value that is PRESENT
#          and says nothing ---
#
# WHERE THIS CAME FROM. 094 found one site by accident and wrote the general
# rule down rather than fixing the instance (TRAPS 11): CommandParser's
# "no reason given" answered a MISSING reason and not a present and empty one,
# so an UNSUPPORTED answer could refuse a player with the empty string, or
# with the five characters "<null>". HANDOVER's first live "Next action" asked
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
#   GDScript is the five-character string "<null>", which is not empty, so
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
# WHAT IT IS NOT. It is a fault-finder for the five sites above and a guard
# against drift afterwards. It says nothing about whether the default WORD is
# the right word - "a room" for a nameless room is the owner's wording, not
# this file's - and nothing about the sites 095 measured and deliberately did
# not change, which are named in HANDOVER: a value that says nothing and is
# REFUSED either way, where the refusal quotes '<null>' back at the player.
# Those are refusals, not kept names, and their wording is the owner's.

const CommandParser = preload("res://scripts/command_parser.gd")
const DungeonModule = preload("res://scripts/dungeon_module.gd")
const Readback = preload("res://scripts/readback.gd")
const ToolRegistry = preload("res://scripts/tool_registry.gd")
const TrackBuilder = preload("res://scripts/track_builder.gd")

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


func _initialize() -> void:
	_the_reader()
	_the_tools()
	_the_dungeon()
	_the_track()
	_the_unsupported_reason()
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
	_check(said_in_this_run.size() >= 20,
		"this run produced sentences to examine (%d)" % said_in_this_run.size())
	var leaking: Array[String] = []
	for said in said_in_this_run:
		if said.contains("<" + "null>"):
			leaking.append(said)
	_check(leaking.is_empty(),
		"no sentence any of these doors produced contains the engine's spelling of nothing (%d sentences)" % said_in_this_run.size() if leaking.is_empty() else
		"a sentence a player reads contains the engine's spelling of nothing: " + str(leaking))
