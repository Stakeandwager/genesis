extends SceneTree

# 027 - the seven things the prompt says Genesis CANNOT do, checked.
#
# 050: THERE ARE EIGHT NOW, and this header would otherwise be a count that
# had stopped being true - the thing TRAPS 14 is about. The eighth is
# "Genesis cannot be ASKED anything", added to the prompt in 050 because a
# refusal is bound to name a missing part FROM that list and a question had
# none, so the model had to invent a reason or send a command. It is
# asserted the same way the seven below are - as facts about the code, never
# as words in the prompt - but in tests/asked_test.gd, with the rest of that
# finding: the eleven commands that answer nothing, and the measurements and
# positions Genesis already has and has no door to.
#
# WHY THIS SUITE EXISTS
# TRAPS 14 is a limitation nobody rechecked: HANDOVER said "no persistence of
# any kind" while /save and /load had been in main.gd for releases, 023 copied
# the sentence into the AI's capability list, and log_023_test then asserted
# that the prompt CONTAINED those words - so the suite was guarding the false
# claim instead of finding it. 025 fixed that one member of the list.
#
# This is the rest of the list. The prompt's limitations were the only claims
# about Genesis with no test behind them at all: the capability half at least
# points at a function (log_023_test's last section), and the limitation half
# was asserted as PROSE or not at all. A limitation is a claim about Genesis,
# and a false one is a false refusal waiting to be printed to a player.
#
# So each of the seven is asserted as a FACT ABOUT THE CODE, never as a
# sentence in the prompt. "The prompt says nothing persists" tests nothing.
#
# WHAT THE AUDIT FOUND
# Five of the seven are true at exactly the width they are stated. Two were
# stated WIDER than the code, and both would have produced a false refusal of
# an ordinary request:
#
#   "A sequence of steps to be done in order is not possible."
#     carry is itself a staged errand - walk to the thing, pick it up at the
#     waypoint where it stands, carry it on to the room. "take the red key to
#     room 3" is ONE order, and it is one of only two goals Genesis has. The
#     owner's own 023 session asked for precisely that.
#
#   "No zone of a farm is checked against anything else for overlap, so
#    'do not let the circuit cross the barn' cannot be promised."
#     True about CHECKING and false about the outcome a player would get.
#     Zones are laid out in rows with a lane between them and cannot overlap
#     each other at all. What is unchecked is a zone against something
#     OUTSIDE the farm - a road, or a world a PLAN puts around it.
#
# Both sentences were narrowed in the prompt in this commit, and the facts
# that make the narrower wording true are asserted below.

var bad := 0
var asserted := 0


func _check(ok: bool, what: String) -> void:
	asserted += 1
	print(("PASS  " if ok else "FAIL  ") + what)
	if not ok:
		bad += 1


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	_one_character()
	await _one_order_and_a_staged_errand()
	_no_locks()
	_built_not_left()
	_one_set_of_equipment()
	_farm_zones_and_what_is_outside()
	_farm_size_comes_from_the_zones()
	_the_prompt_has_not_gone_back_to_the_wider_claim()
	_a_rule_scoped_to_a_sentence()

	print("LIMITS TEST %d assertions, failures=%d" % [asserted, bad])
	quit(bad)


# --- 1. "There is ONE character." ---
#
# The fact that makes it true is that an ORDER has no way to NAME a character.
# If a "who" field is ever added, the validated goal will carry it and this
# fails - at which point the limitation has to come out of the prompt.
func _one_character() -> void:
	var rooms: Array = [{"name": "hall"}, {"name": "room_2"}]
	var checked: Dictionary = NpcGoals.validate(
		{"goal": "go_to", "room": 1, "who": "the courier"}, rooms)
	_check(bool(checked.get("ok", false)), "an order with an invented 'who' still validates")
	var goal: Dictionary = checked.get("goal", {})
	_check(not goal.has("who"), "and the validated goal has no way to name a character")
	_check(goal.keys().size() == 4,
		"a goal is exactly goal/room/room_name/thing (it is %s)" % str(goal.keys()))


# --- 2. "A character takes ONE order at a time ... but carry is staged." ---
#
# Two separate facts, and the prompt was getting the second one wrong.
#
# ONE AT A TIME: a second route REPLACES the first. The test gives routes of
# different lengths, so a queue would show up as the sum.
# STAGED: fetch() puts a pickup waypoint INSIDE one route. That is a sequence
# of steps done in order, inside a single order, and refusing "take the key to
# room 3" as a sequence denies the only errand Genesis has.
func _one_order_and_a_staged_errand() -> void:
	var npc := Npc.new()
	root.add_child(npc)
	await physics_frame

	var short_route: Array = [Vector2(0, 0), Vector2(4, 0)]
	var long_route: Array = [Vector2(0, 0), Vector2(4, 0), Vector2(8, 0), Vector2(12, 0)]

	npc.follow(long_route)
	_check(npc.marks.size() == long_route.size(),
		"an order is the route it was given (%d marks)" % npc.marks.size())
	npc.follow(short_route)
	_check(npc.marks.size() == short_route.size(),
		"a new order REPLACES the old one (%d marks, not %d)" % [
			npc.marks.size(), long_route.size() + short_route.size()])

	# The thing a carrier fetches is reparented to the body, so it has to have
	# a Node3D parent to be put back into - the world node, in the game.
	var world := Node3D.new()
	root.add_child(world)
	var thing := Node3D.new()
	world.add_child(thing)
	await physics_frame
	npc.fetch(long_route, thing, 2)
	_check(npc.pickup_at == 2,
		"carry picks the thing up at a waypoint inside the route (mark %d)" % npc.pickup_at)
	_check(npc.marks.size() > npc.pickup_at + 1,
		"and the route CONTINUES past it, which is what makes carry a staged errand")
	_check(NpcGoals.GOALS.has("carry"), "carry is a goal the AI may ask for")

	npc.follow(short_route)
	_check(npc.pickup_at == -1, "and a plain order clears the pickup stage")

	world.queue_free()
	npc.queue_free()
	await physics_frame


# --- 3. "No locks." ---
#
# A door is shut or open and nothing else, and a key is a thing with a name.
# The whitelists are where this is true or false: if LOCK ever becomes a
# command or unlock ever becomes a goal, this fails.
func _no_locks() -> void:
	var commands: Array = CommandParser.allowed_commands()
	for word in ["LOCK", "UNLOCK", "LOCK_DOOR", "UNLOCK_DOOR"]:
		_check(not commands.has(word), "'%s' is not a command Genesis has" % word)
	for word in ["unlock", "lock", "open_with_key", "use_key"]:
		_check(not NpcGoals.GOALS.has(word), "'%s' is not a goal a character can be given" % word)

	# A door's state is the one binary, and set_shut is the only way to move it.
	var layout: Dictionary = {}
	_check(not DungeonModule.is_shut(layout, 0, 1), "a door with no state is open")
	DungeonModule.set_shut(layout, 0, 1, true)
	_check(DungeonModule.is_shut(layout, 0, 1), "and shut once it has been shut")
	DungeonModule.set_shut(layout, 0, 1, false)
	_check(not DungeonModule.is_shut(layout, 0, 1), "and open again, with nothing in between")

	# And a key is validated exactly as a lamp is: same fields, same shape.
	var module := DungeonModule.new()
	var rooms: Array = [{"name": "hall", "width": 10, "depth": 10},
		{"name": "room_2", "width": 10, "depth": 10}]
	var with_key: Dictionary = module.validate({"rooms": rooms, "doors": [[1, 2]],
		"things": [{"name": "red_key", "in": 1}]})
	var with_lamp: Dictionary = module.validate({"rooms": rooms, "doors": [[1, 2]],
		"things": [{"name": "lamp", "in": 1}]})
	_check(bool(with_key.get("ok", false)) and bool(with_lamp.get("ok", false)),
		"a key and a lamp both validate")
	var key_thing: Dictionary = _first_thing(with_key)
	var lamp_thing: Dictionary = _first_thing(with_lamp)
	_check(not key_thing.is_empty() and key_thing.keys() == lamp_thing.keys(),
		"and a key carries no field a lamp does not: %s" % str(key_thing.keys()))


func _first_thing(validated: Dictionary) -> Dictionary:
	var content: Dictionary = validated.get("content", {})
	var things = content.get("things", [])
	if typeof(things) != TYPE_ARRAY or (things as Array).is_empty():
		return {}
	var first = (things as Array)[0]
	return first if typeof(first) == TYPE_DICTIONARY else {}


# --- 4. "A saved world comes back as it was BUILT, not as it was LEFT." ---
#
# The reason this is true is structural and worth asserting rather than
# describing: a save carries the PARAMETERS of the command that built the
# world, and the state a player changes afterwards lives in the LAYOUT. A door
# shut at runtime is set on the layout by set_shut and has nowhere to go in a
# save file.
#
# 025 made this claim honest. This is the assertion it did not have.
func _built_not_left() -> void:
	var module := DungeonModule.new()
	var parameters: Dictionary = {
		"rooms": [{"name": "hall", "width": 12, "depth": 12},
			{"name": "room_2", "width": 10, "depth": 10}],
		"doors": [[1, 2]],
		"things": [{"name": "red_key", "in": 1}],
	}
	var validated: Dictionary = module.validate(parameters)
	_check(bool(validated.get("ok", false)), "the dungeon to be saved is valid")
	var content: Dictionary = validated.get("content", {})
	_check(not content.has("shut"),
		"a dungeon's own description has no notion of a shut door")

	var pre: Dictionary = module.pre_check(content, {})
	var solved: Dictionary = module.solve(pre.get("content", content))
	var layout: Dictionary = solved.get("layout", {})
	_check(not layout.is_empty(), "and it solves to a layout")

	# Shut a door, as a player may at any moment, then rebuild from the
	# parameters a save file would have kept.
	DungeonModule.set_shut(layout, 0, 1, true)
	_check(DungeonModule.is_shut(layout, 0, 1), "a door is shut in the standing world")

	var again: Dictionary = module.solve(module.pre_check(
		module.validate(parameters).get("content", {}), {}).get("content", {}))
	var rebuilt: Dictionary = again.get("layout", {})
	_check(not rebuilt.is_empty(), "the saved description rebuilds")
	_check(not DungeonModule.is_shut(rebuilt, 0, 1),
		"and the shut door comes back OPEN, which is what the prompt promises")

	# What a save file actually contains, read back off disk rather than
	# assumed. The suite makes its own file and removes it (TRAPS 7).
	var saved: Dictionary = WorldStore.save_world(
		"limits-test-tmp", "CREATE_DUNGEON", parameters, {"rooms": 2}, "a test world")
	if not bool(saved.get("ok", false)):
		_check(false, "a world can be saved: %s" % str(saved.get("message", "")))
		return
	var loaded: Dictionary = WorldStore.load_world("limits-test-tmp")
	_check(bool(loaded.get("ok", false)), "and loaded again")
	var world: Dictionary = loaded.get("world", {})
	var keys: Array = world.keys()
	for absent in ["shut", "kit", "equipment", "carried", "npc"]:
		_check(not keys.has(absent),
			"a save file keeps no '%s', so there is no state to come back" % absent)
	var kept: Dictionary = world.get("parameters", {})
	_check(not kept.has("shut"), "and the kept parameters carry no door state")
	WorldStore.remove_world("limits-test-tmp")
	_check(not WorldStore.list_worlds().has("limits-test-tmp"),
		"the test's own save file is cleaned up after it")


# --- 5. "One set of equipment at a time." ---
#
# The fact underneath "two cars cannot be compared" is that a kit has one slot
# per TOOL NAME, not a list. If a kit ever becomes a list per tool, this fails
# and the limitation is no longer true.
func _one_set_of_equipment() -> void:
	var kit: Dictionary = ToolRegistry.free_kit()
	var names: Array = ToolRegistry.names()
	_check(kit.size() == names.size(),
		"a kit has one slot per tool (%d slots, %d tools)" % [kit.size(), names.size()])
	for tool_name in names:
		_check(kit.has(tool_name), "and a slot for '%s'" % str(tool_name))
		_check(typeof(kit.get(tool_name)) == TYPE_DICTIONARY,
			"'%s' holds ONE spec, not a list of them" % str(tool_name))


# --- 6. Farm zones, and the thing that really is unchecked ---
#
# The claim as it stood - "no zone of a farm is checked against anything else
# for overlap" - was true about checking and false about what a player gets.
# The layout packs zones into rows with a lane between them, so no two can
# overlap. Swept over random legal farms rather than argued from the code:
# that is a sample of the legal space, not a proof over it, and the suite says
# which.
#
# What IS unchecked is a zone against something outside the farm. The only
# separation check Genesis has is road against road, and it is handed sections
# and nothing else - so it cannot be looking at a zone.
func _farm_zones_and_what_is_outside() -> void:
	var module := FarmModule.new()
	var rng := RandomNumberGenerator.new()
	rng.seed = 20261014
	var types: Array = ["barn", "farmhouse", "silo", "pasture", "orchard", "pond", "yard"]
	var farms := 0
	var overlapping := 0
	var tightest := 1e9

	for trial in 300:
		var zones: Array = []
		for i in rng.randi_range(2, 8):
			var type: String = str(types[rng.randi_range(0, types.size() - 1)])
			var limit: Vector2 = module.BUILDING_SIDE if type in module.BUILDINGS else module.FIELD_SIDE
			zones.append({"type": type,
				"width": snappedf(rng.randf_range(limit.x, limit.y), 1.0),
				"depth": snappedf(rng.randf_range(limit.x, limit.y), 1.0)})
		var validated: Dictionary = module.validate({"zones": zones})
		if not bool(validated.get("ok", false)):
			continue
		var solved: Dictionary = module.solve(validated.get("content", {}))
		if not bool(solved.get("ok", false)):
			continue
		var placed = (solved.get("layout", {}) as Dictionary).get("zones", null)
		if typeof(placed) != TYPE_ARRAY:
			_check(false, "a solved farm has a list of placed zones")
			return
		farms += 1
		for a in (placed as Array).size():
			for b in range((placed as Array) .size()):
				if b <= a:
					continue
				var gap: Vector2 = _gap_between((placed as Array)[a], (placed as Array)[b])
				if gap.x > 0.0 and gap.y > 0.0:
					overlapping += 1
				else:
					tightest = minf(tightest, maxf(-gap.x, -gap.y))

	_check(farms > 100, "swept %d legal farms" % farms)
	_check(overlapping == 0,
		"no two zones overlap in any of them (%d overlaps)" % overlapping)
	_check(tightest >= module.LANE_WIDTH - 0.01,
		"the tightest gap between two zones is %.1f m, a lane's width" % tightest)

	# And the limit that really is a limit: nothing compares a zone with a
	# road. SeparationCheck is the only separation Genesis measures, and the
	# only thing it is given is the track's own sections.
	var sections: Array = [
		{"type": "straight", "length": 120.0},
		{"type": "corner", "radius": 40.0, "angle": 90.0},
		{"type": "straight", "length": 120.0},
		{"type": "corner", "radius": 40.0, "angle": 90.0},
		{"type": "straight", "length": 120.0},
		{"type": "corner", "radius": 40.0, "angle": 90.0},
		{"type": "straight", "length": 120.0},
		{"type": "corner", "radius": 40.0, "angle": 90.0},
	]
	var separation: Dictionary = SeparationCheck.check(sections)
	_check(separation.has("closest_sections"),
		"the separation check reports which SECTIONS came closest")
	for key in separation.keys():
		_check(not str(key).contains("zone"),
			"and reports nothing about a zone ('%s')" % str(key))


# Overlap on each axis. Positive on both means the rectangles intersect;
# otherwise the negatives are the gaps.
func _gap_between(a: Dictionary, b: Dictionary) -> Vector2:
	var ax := float(a.get("x", 0.0))
	var az := float(a.get("z", 0.0))
	var bx := float(b.get("x", 0.0))
	var bz := float(b.get("z", 0.0))
	return Vector2(
		minf(ax + float(a.get("width", 0.0)), bx + float(b.get("width", 0.0))) - maxf(ax, bx),
		minf(az + float(a.get("depth", 0.0)), bz + float(b.get("depth", 0.0))) - maxf(az, bz))


# --- 7. "A farm's overall size cannot be given." ---
#
# True because validate() keeps nothing but the zones: a size asked for at the
# top level is dropped before anything is laid out, and the farm that comes
# out is the size the zones make it. Asked for 500 m, measured in tens.
func _farm_size_comes_from_the_zones() -> void:
	var module := FarmModule.new()
	var zones: Array = [{"type": "barn", "width": 20, "depth": 20},
		{"type": "yard", "width": 20, "depth": 20}]
	var validated: Dictionary = module.validate(
		{"zones": zones, "width": 500, "depth": 500, "size": 500})
	_check(bool(validated.get("ok", false)), "a farm asked for at 500 m still validates")
	var content: Dictionary = validated.get("content", {})
	_check(content.keys() == ["zones"],
		"and nothing but the zones survives it (%s)" % str(content.keys()))

	var solved: Dictionary = module.solve(content)
	var metrics: Dictionary = module.measure(solved.get("layout", {}))
	var width := float(metrics.get("farm_width", -1.0))
	var depth := float(metrics.get("farm_depth", -1.0))
	_check(width > 0.0 and depth > 0.0, "the farm is measured: %.0f m by %.0f m" % [width, depth])
	_check(width < 200.0 and depth < 200.0,
		"and is the size its zones make it, not the 500 m asked for")


# --- the two sentences that were too wide, kept from coming back ---
#
# These are wording assertions and are worth exactly what wording assertions
# are worth, which is why every section above is a fact instead. They are here
# for the one job 025's "Nothing persists" check does: a sentence that has
# been shown to be false should not reappear in the prompt unnoticed.
func _the_prompt_has_not_gone_back_to_the_wider_claim() -> void:
	var prompt: String = AIInterpreter.SYSTEM_PROMPT
	_check(not prompt.contains("A sequence of steps to be done in order is not possible"),
		"the prompt no longer calls a sequence of steps impossible, which carry is")
	_check(not prompt.contains("No zone of a farm is checked against anything else for overlap"),
		"nor claims no zone is checked against anything, when none can overlap another")
	_check(prompt.contains("CHAIN OF ORDERS"),
		"it names what really cannot be done: a chain of orders")
	_check(prompt.contains("never refuse it as a sequence"),
		"and tells the AI not to refuse carry as a sequence")

	# And the checker now contradicts that refusal if it is made anyway, which
	# is the half 025 taught: narrowing the prompt is not the same as catching
	# the lie it used to invite (TRAPS 11).
	for lie in [
		"the NPC cannot pick up an object and take it to another room",
		"this game does not support fetching an item and delivering it",
		"objects cannot be carried from one room to another",
	]:
		_check(not RefusalCheck.quarrel_with(lie).is_empty(),
			"caught: '%s'" % lie)
	for honest in [
		"a character takes one order at a time, so a sequence of steps in order is not possible",
		"a step conditional on whether an earlier one worked is not possible",
		"there is no second character to carry anything",
	]:
		_check(RefusalCheck.quarrel_with(honest).is_empty(),
			"left alone, it is true: '%s'" % honest)


# --- 8. and the wall in front of a refusal, which was not standing ---
#
# RefusalCheck's own comments describe two rules, and both are scoped to a
# SENTENCE: the ABOUT_NUMBER guard ("verification of two NPCs is not
# possible" is honest, so leave it) and the ordering rule (the negation must
# come BEFORE the capability word). Neither was scoped to anything. _plain()
# replaced every "." with a space, and _denial_in() then split on "." - so
# every refusal was one sentence however long it was.
#
# The consequence ran the dangerous way: one honest clause about number
# ANYWHERE in a refusal silenced the whole check. That is the likeliest shape
# of a real refusal to one of the owner's hundred-word briefs - one true limit
# of number, one false claim about a capability - and 023's lesson was that
# those briefs are the realistic input.
#
# Every existing suite used single-sentence reasons, which is why nothing saw
# it. These are multi-sentence on purpose.
func _a_rule_scoped_to_a_sentence() -> void:
	var lie := "This game does not include a physics engine or simulation tools."
	var honest := "There are not two characters to compare."

	_check(not RefusalCheck.quarrel_with(lie).is_empty(),
		"the lie on its own is caught")
	_check(RefusalCheck.quarrel_with(honest).is_empty(),
		"and the honest sentence on its own is left alone")
	_check(not RefusalCheck.quarrel_with(honest + " " + lie).is_empty(),
		"an honest sentence BEFORE the lie no longer silences it")
	_check(not RefusalCheck.quarrel_with(lie + " " + honest).is_empty(),
		"nor does one after it")

	# And the ordering rule, which the same bug had widened to the whole
	# refusal: a negation in one sentence must not reach a capability word in
	# the next.
	_check(RefusalCheck.quarrel_with(
		"There is no second character here. The ledger is where every request goes.").is_empty(),
		"a negation in one sentence does not reach the next one")
	_check(RefusalCheck.quarrel_with(
		"Every request goes to the ledger. There is nobody else to send.").is_empty(),
		"and a capability stated plainly is not a denial of it")

	# What counts as a sentence, stated once and tested here. A comma or a
	# semicolon does not end one, because "does not support A, B, or C" is a
	# single list under a single negation - the shape three of the six real
	# refusals in 023 had.
	_check(RefusalCheck.sentences_of("One. Two! Three?").size() == 3,
		"a full stop, an exclamation and a question mark each end a sentence")
	_check(RefusalCheck.sentences_of("A, B; and C.").size() == 1,
		"a comma and a semicolon do not")
	_check(RefusalCheck.sentences_of("the road comes within 1.8 m of itself").size() == 1,
		"and a decimal point is not the end of a sentence")
	_check(not RefusalCheck.quarrel_with(
		"The game does not support automated NPC task sequences, autonomous door unlocking, or external status verification.").is_empty(),
		"so a list under one negation is still caught three items later")
