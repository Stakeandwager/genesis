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
# WHAT IT IS NOT. It is a fault-finder for the five sites above and a guard
# against drift afterwards. It says nothing about whether the default WORD is
# the right word - "a room" for a nameless room is the owner's wording, not
# this file's - and nothing about the sites 095 measured and deliberately did
# not change, which are named in HANDOVER: a value that says nothing and is
# REFUSED either way, where the refusal quotes '<null>' back at the player.
# Those are refusals, not kept names, and their wording is the owner's.

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


func _initialize() -> void:
	_the_reader()
	_the_speller()
	_the_tools()
	_the_dungeon()
	_the_track()
	_the_unsupported_reason()
	_every_door_with_a_null_in_it()
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
		_check(said_in_this_run.size() > before_module,
			"driving %s with a null in it said something" % cmd)
	_check(modules >= 3, "the registry declares world modules for this to drive (drove %d)" % modules)

	# (b) the section validator directly, because RacingModule delegates to it
	# and the delegate is where the sentences are written.
	var before_sections := said_in_this_run.size()
	for poisoned in _one_null_each(SOUND["CREATE_TRACK"]):
		_errors_said(SectionValidator.validate(poisoned))
	_check(said_in_this_run.size() > before_sections,
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
		_check(said_in_this_run.size() > before_tool,
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
		_check(said_in_this_run.size() > before_goal,
			"driving a %s order with a null in it said something" % str(base["goal"]))
	var before_door := said_in_this_run.size()
	for poisoned in _one_null_each({"between": ["hall", "vault"]}):
		_errors_said(NpcGoals.validate_door(poisoned, rooms, layout))
		_record(NpcGoals.door_readback(poisoned, true))
		_record(NpcGoals.door_readback(poisoned, false))
	_check(said_in_this_run.size() > before_door,
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
		for poisoned in _one_null_each(SHAPES[command]):
			_record(WorldRegistry.readback(command, poisoned))
		_check(said_in_this_run.size() > before_command,
			"driving %s's readback with a null in it said something" % command)
	_check(commands == CommandParser.allowed_commands().size(),
		"every command the whitelist admits was driven (%d of %d)" % [
			commands, CommandParser.allowed_commands().size()])

	# (e) the parser, whose own field is the command.
	for body in [
		'{"command":null,"parameters":{}}',
		'{"command":"CREATE_FARM","parameters":null}',
		'{"command":["x"],"parameters":{}}',
	]:
		var before_body := said_in_this_run.size()
		_record(str(CommandParser.parse(body).get("error", "")))
		_check(said_in_this_run.size() > before_body,
			"parsing %s said something" % body)

	# The denominator (TRAPS 75). A sweep that drives nothing passes every
	# absence question ever asked of it, which is half this project's findings.
	var drove := said_in_this_run.size() - before
	_check(drove >= 150, "the sweep produced sentences to examine (%d)" % drove)


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
