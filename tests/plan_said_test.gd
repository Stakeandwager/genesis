extends SceneTree

# 032 - every command the whitelist allows reads back, and so does every
# world inside a plan.
#
# THE QUESTION, AND WHY IT IS THE ONE 031 LEFT
#
# 031 asked, of every field of every world's LONG readback: change one field
# of the request, and does the sentence change? Eleven fields were silent.
# This asks the same question one layer up, where HANDOVER said 031 had not
# reached, and of the other axis - not every field of one command, but every
# COMMAND the whitelist admits:
#
#   change one field of a request, and the sentence must change -
#   for each of CommandParser.allowed_commands(), and again inside a PLAN.
#
# That second half matters more than it looks. WorldRegistry.readback sends a
# PLAN to _plan_readback and never to a world's long readback, so for a
# multi-world request the short line is the ONLY description a player is ever
# shown. A field silent there is a field said nowhere.
#
# WHY IT IS DRIVEN BY THE WHITELIST ITSELF
#
# The commands come from CommandParser.allowed_commands() and the worlds from
# WorldRegistry.modules(), which are the two lists that decide what Genesis
# can be asked for. A command added to the whitelist therefore adds a row
# here on its own, and this suite FAILS until two requests for it are listed
# below and its sentence tells them apart. A suite that enumerated by hand is
# how two whitelisted commands kept an empty readback for the project's whole
# life while 028, 029, 030 and 031 all read the file they were missing from.
#
# WHAT WAS A FINDING AND WHAT IS A GUARD (TRAPS 6)
#
# Measured against the code as it stood before 032, Godot 4.7.1 headless:
# EIGHT of these assertions FAILED and the rest passed. The number is eight
# and not the four faults below because two of the four are each caught at
# both layers, which is the point of asserting at both.
#
#   FINDINGS, four faults in eight assertions:
#     SPAWN_OPPONENTS  no readback AT ALL as a single command -
#                      WorldRegistry.readback returned the empty string - and
#                      the raw JSON token "a spawn_opponents" inside a plan,
#                      where eight opponents and two read back the same.
#                      2 assertions.
#     MODIFY_TRACK     the same, "a modify_track": corner 1 made hard and
#                      corner 3 made easy read back identically. 2 assertions.
#     a farm           two zones and five read back as "a farm", through
#                      readback_short and inside a plan alike. 2 assertions.
#     a circuit        four sections and twelve read back as "a race
#                      circuit", likewise. 2 assertions.
#
#   GUARDS, and they have always passed:  CREATE_FARM, CREATE_TRACK,
#   CREATE_DUNGEON and CLEAR_WORLD, EQUIP, ORDER, SHUT, OPEN as single
#   commands; a dungeon's room count inside a plan (the only world that
#   counted its pieces before 032); the four doings inside a plan; a dropped
#   step; a dropped world; and the relationship between two worlds.
#
# WHAT THIS SUITE DOES NOT ASSERT
#
# That a plan names a world's MEASUREMENTS. It does not, deliberately: a
# plan's meaning is mostly how its worlds are RELATED, and a line long enough
# to bury that at the end is a line nobody finishes. So a farm whose barn is
# 20 m and one whose barn is 50 m still read alike inside a plan, and the
# count is the one field the short line carries. That is a limitation, it is
# recorded as one in HANDOVER, and it is the owner's to widen or leave.
#
# Nothing here asserts WHAT a sentence says, only that two different requests
# say different things. Every line of wording in 032 can be rephrased and
# this suite stays green.

var bad := 0


# --- two requests for every command the whitelist allows ---
#
# PLAN is the container and is exercised by _plan_layer() below rather than
# by a pair here. Everything else needs a pair, and a command with no pair is
# a FAIL and never a skip.
var pairs := {
	"CREATE_FARM": [
		{"zones": [{"type": "barn", "width": 20.0, "depth": 20.0}]},
		{"zones": [{"type": "barn", "width": 50.0, "depth": 20.0}]},
	],
	"CREATE_TRACK": [
		{"sections": [{"type": "straight", "length": 300.0}, {"type": "corner", "radius": 50.0, "angle": 180.0},
			{"type": "straight", "length": 300.0}, {"type": "corner", "radius": 50.0, "angle": 180.0}]},
		{"sections": [{"type": "straight", "length": 800.0}, {"type": "corner", "radius": 50.0, "angle": 180.0},
			{"type": "straight", "length": 800.0}, {"type": "corner", "radius": 50.0, "angle": 180.0}]},
	],
	"CREATE_DUNGEON": [
		{"rooms": [{"name": "hall", "width": 12.0, "depth": 10.0}, {"name": "vault", "width": 20.0, "depth": 10.0}],
			"doors": [[1, 2]]},
		{"rooms": [{"name": "hall", "width": 30.0, "depth": 10.0}, {"name": "vault", "width": 20.0, "depth": 10.0}],
			"doors": [[1, 2]]},
	],
	"CLEAR_WORLD": [{}, {}],
	"EQUIP": [
		{"tool": "boots", "spec": {"push": 900.0}},
		{"tool": "boots", "spec": {"push": 600.0}},
	],
	"ORDER": [
		{"goal": "carry", "thing": "red_key", "room": "room 3"},
		{"goal": "carry", "thing": "red_key", "room": "room 2"},
	],
	"SHUT": [
		{"between": ["room 1", "room 2"]},
		{"between": ["room 2", "room 3"]},
	],
	"OPEN": [
		{"between": ["room 1", "room 2"]},
		{"between": ["room 2", "room 3"]},
	],
	"MODIFY_TRACK": [
		{"corner": 1, "difficulty": "hard"},
		{"corner": 3, "difficulty": "easy"},
	],
	"SPAWN_OPPONENTS": [
		{"count": 8},
		{"count": 2},
	],
}

# CLEAR_WORLD takes no fields at all, so two requests for it are necessarily
# the same request. It is the one command whose pair cannot differ, and it is
# named here rather than quietly skipped: the assertion made of it instead is
# that it says SOMETHING.
const NO_FIELDS := ["CLEAR_WORLD"]


func _initialize() -> void:
	_every_command()
	_every_world_in_a_plan()
	_plan_layer()
	print("PLAN SAID failures=%d" % bad)
	quit(bad)


# The sentence must change when the request changes. Nothing is asserted
# about WHAT it changes to.
func _differs(where: String, said_a: String, said_b: String) -> void:
	if said_a != said_b and said_a != "" and said_b != "":
		print("PASS  %-34s %s" % [where, said_a])
		return
	bad += 1
	if said_a == "" or said_b == "":
		print("FAIL  %-34s a readback said NOTHING AT ALL" % where)
		return
	print("FAIL  %-34s silent: both requests read back as \"%s\"" % [where, said_a])


func _check(ok: bool, what: String) -> void:
	print(("PASS  " if ok else "FAIL  ") + what)
	if not ok:
		bad += 1


# --- 1. every command the whitelist allows, as a single command ---
func _every_command() -> void:
	print("-- every command in CommandParser.allowed_commands() --")
	for entry in CommandParser.allowed_commands():
		var command := str(entry)
		if command == "PLAN":
			continue
		if not pairs.has(command):
			bad += 1
			print("FAIL  %-34s whitelisted and not listed in this suite" % command)
			continue
		var two: Array = pairs[command]
		var said_a := WorldRegistry.readback(command, two[0])
		var said_b := WorldRegistry.readback(command, two[1])
		if command in NO_FIELDS:
			_check(said_a != "", "%s has no fields, and still says something: \"%s\"" % [command, said_a])
			continue
		_differs(command, said_a, said_b)


# --- 2. every world, through the short line a plan reads ---
#
# Both layers: readback_short() directly, and the same world as the only step
# of a plan, because _plan_readback is what a player is actually shown and a
# line can be lost between the two.
func _every_world_in_a_plan() -> void:
	print("-- every world in WorldRegistry.modules(), inside a plan --")
	for entry in WorldRegistry.modules():
		var module: WorldModule = entry
		var piece: Array = module.pieces()
		if piece.size() != 2:
			bad += 1
			print("FAIL  %-34s declares no list of pieces" % module.command())
			continue
		var key := str(piece[0])
		var few: Dictionary = {key: _list_of(module, 2)}
		var many: Dictionary = {key: _list_of(module, 5)}

		_differs("%s short, 2 vs 5 %ss" % [module.display_name(), str(piece[1])],
			module.readback_short(few), module.readback_short(many))
		_differs("%s in a plan, 2 vs 5 %ss" % [module.display_name(), str(piece[1])],
			_plan([{"command": module.command(), "parameters": few}]),
			_plan([{"command": module.command(), "parameters": many}]))

		# The key a world declares must be the key its own validator reads,
		# or the count is taken off a field nothing builds from. Asserted by
		# asking the validator: a list under this key is never answered with
		# "<key> must be a list".
		var checked: Dictionary = module.validate(many)
		var complaint := "%s must be a list" % key
		var complained := false
		for problem in checked.get("errors", []):
			if str(problem) == complaint:
				complained = true
		_check(not complained, "%s reads its own \"%s\" as a list" % [module.command(), key])


# n pieces of whatever this world is made of, each legal on its own. The
# count is what is being measured, so the pieces are deliberately alike.
func _list_of(module: WorldModule, n: int) -> Array:
	var out: Array = []
	for i in n:
		match module.command():
			"CREATE_FARM":
				out.append({"type": "barn", "width": 20.0, "depth": 20.0})
			"CREATE_TRACK":
				out.append({"type": "straight", "length": 250.0})
			"CREATE_DUNGEON":
				out.append({"name": "room %d" % (i + 1), "width": 10.0, "depth": 10.0})
			_:
				out.append({})
	return out


func _plan(steps: Array) -> String:
	return WorldRegistry.readback("PLAN", {"steps": steps})


# --- 3. the plan layer itself: a dropped step, a dropped world, and the
# relationship between two worlds ---
#
# These are the things a plan says that no single command does, so they are
# the things only this layer can lose.
func _plan_layer() -> void:
	print("-- the plan layer --")
	var circuit := {"command": "CREATE_TRACK", "parameters":
		{"sections": [{"type": "straight", "length": 250.0}, {"type": "corner", "radius": 50.0, "angle": 180.0},
			{"type": "straight", "length": 250.0}, {"type": "corner", "radius": 50.0, "angle": 180.0}]}}
	var dungeon := {"command": "CREATE_DUNGEON", "parameters":
		{"rooms": [{"name": "hall", "width": 12.0, "depth": 10.0},
			{"name": "vault", "width": 20.0, "depth": 10.0}], "doors": [[1, 2]]}}
	var nested := dungeon.duplicate(true)
	nested["around"] = 1

	_differs("a world dropped from a plan", _plan([circuit, dungeon]), _plan([circuit]))
	_differs("the relationship between worlds", _plan([circuit, dungeon]), _plan([circuit, nested]))

	# Every doing, dropped. A step that vanishes from the request must vanish
	# from the sentence, which is the only way a player sees it went.
	for command in CommandParser.allowed_commands():
		var word := str(command)
		if word == "PLAN" or word.begins_with("CREATE_") or not pairs.has(word):
			continue
		var step := {"command": word, "parameters": (pairs[word] as Array)[0]}
		_differs("%s dropped from a plan" % word, _plan([dungeon, step]), _plan([dungeon]))
		if word in NO_FIELDS:
			continue
		var other := {"command": word, "parameters": (pairs[word] as Array)[1]}
		_differs("%s changed in a plan" % word, _plan([dungeon, step]), _plan([dungeon, other]))
