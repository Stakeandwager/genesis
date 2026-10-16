extends SceneTree

# --- 051: the panel beside a REFUSAL, and the layer each of its lines reads ---
#
# THE TASK, AND WHERE IT CAME FROM
#
# HANDOVER named the next assistant task: 047 and 049 between them put every
# panel line of all three worlds beside the geometry it describes, FOR A
# WORLD THAT WAS BUILT, and `main.gd` draws the panel from a second place as
# well - `record.get("metrics", record.get("proposed_metrics", {}))` - so a
# request that was REFUSED gets a panel too, under the line "(measurements
# below describe the proposal, not a built track)". It said nothing in tests/
# had ever produced that panel, that the caveat line is what makes it honest,
# and it asked two questions of it:
#
#   does every line stay inside what that caveat covers?
#   is the caveat shown in every case it is owed?
#
# BOTH HAD AN ANSWER AND BOTH ANSWERS WERE NO. And the reason nothing had
# ever asked is that all four of the panel's decisions were inline in
# main.gd's _on_track_measured, which needs a RichTextLabel and a running UI:
# the MODULES' lines were reachable - panel_built_test and counted_said_test
# call metric_lines() - and the decision about WHICH WORLD THE PANEL IS
# DESCRIBING was reachable from nothing. 051 moved those four decisions into
# WorldRegistry.panel_lines(), which is what this suite can call.
#
# WHAT WAS MEASURED, headless, before anything was changed
#
# 1. THE CAVEAT IS OWED ON A CONSTRUCTION FAULT AND WAS DRIVEN BY VALIDATION.
#    A plan prepares every world before it builds any of them, so a plan
#    refused after a step has been worked out emits that step's record with
#    result=VALID (the proposal was fine) and construction=FAILED (nothing
#    was built). The panel asked `result`:
#
#      step 1, a dungeon, in a plan whose step 2 will not validate
#        RESULT "Valid dungeon", in GREEN
#        all ten measurement lines of a dungeon that does not exist
#        NO caveat, because the caveat asked `result`
#        NO reason either, for the same reason
#
#    Reachable two ways: a step that will not validate, and two worlds with
#    no "around", which is the shape of the prompt's own PLAN skeleton.
#
# 2. AND THE WORLD THAT WAS NAMED WHERE THERE WAS NONE.
#    `record.get("world", "circuit")` stood a Prototype 001 circuit in for
#    any record with no `world` key, and `world` is written by
#    WorldModule.record_fields() - so it is absent from every record that is
#    not a world. Measured, driven through GameController:
#
#      EQUIP a car   result=VALID   no `world`   "RESULT Valid circuit"
#      ORDER go_to   result=VALID   no `world`   "RESULT Valid circuit"
#      CLEAR_WORLD   result=VALID   no `world`   "RESULT Valid circuit"
#
#    The last is the sharpest: the command whose whole job is to take a world
#    AWAY, reported in green as a valid circuit.
#
#    AND THE DEFAULT HAD NEVER BEEN DORMANT, which is why nobody saw it:
#    RacingModule.record_fields() deliberately omits `world` - racing records
#    have never carried it and record_proposal_test asserts they still don't
#    - so "circuit" fired on EVERY CIRCUIT, where it was right. A default
#    that is correct for the one case it was written for and wrong for seven
#    others cannot be found by reading the circuit.
#
# 3. AND A VERDICT PRINTED FOR A RECORD THAT HAS NONE.
#    `record_load_check()` writes the only emitted record with no `result`
#    key: it carries an `outcome` instead, because it judges a world that
#    came back off disk rather than a proposal. `if valid ... else FAILED`
#    has no case for that, so a load check whose outcome is SAME made the
#    panel read "RESULT  FAILED: " - in RED, with an empty category where the
#    reason should be. Pre-existing and identical before 051.
#
# WHAT THIS SUITE ASSERTS, AND WHAT IT DOES NOT (TRAPS 6, TRAPS 14)
#
# NOTHING HERE ASSERTS A SENTENCE. "The caveat says the measurements describe
# a proposal" tests nothing: it would pass against a panel that showed the
# caveat on every record and against one that showed it on none. So every
# line carries the ROLE it plays and this suite asks for roles - is there a
# caveat, is there a reason, is there a verdict - and about the one thing the
# panel NAMES, it asks whether the name belongs to this record, never how the
# sentence is phrased.
#
# The sweep is over CommandParser.allowed_commands() and WorldRegistry, not
# over a list typed here, so a twelfth command or a fourth world is asked the
# same questions without this file being edited.
#
# It does NOT assert that the caveat's wording is right, that a load check
# should show anything in particular, or that the duplicate ledger id found
# in the same measuring is fixed - that one is recorded in HANDOVER and left
# for its own commit. And NO MODEL SENT ANY OF THIS: every request here was
# typed by hand and this harness has no key.

var asserted := 0
var bad := 0
var c: GameController
var seen: Array = []


func _check(ok: bool, what: String) -> void:
	asserted += 1
	if not ok:
		bad += 1
		print("  FAIL  ", what)


func _initialize() -> void:
	await _setup()
	await _a_world_that_was_not_built_says_so()
	await _the_caveat_reads_the_construction_layer()
	_a_record_names_only_a_world_it_has()
	await _no_command_names_a_world_it_is_not_about()
	await _a_record_with_no_verdict_gets_no_verdict_line()
	_the_panel_has_a_line_for_every_claim_it_makes()
	print("PANEL REFUSED %d assertions, failures=%d" % [asserted, bad])
	quit(bad)


func _setup() -> void:
	var root := Node3D.new()
	get_root().add_child(root)
	c = GameController.new()
	root.add_child(c)
	c.setup(root)
	c.track_measured.connect(func(r): seen.append(r.duplicate(true)))
	await process_frame


# The roles a panel has, in order, so an assertion can ask what the panel
# DID rather than what it said.
func _roles(record: Dictionary) -> PackedStringArray:
	var out := PackedStringArray()
	for line in WorldRegistry.panel_lines(record):
		out.append(str((line as Dictionary)["role"]))
	return out


func _line_of(record: Dictionary, role: String) -> Dictionary:
	for line in WorldRegistry.panel_lines(record):
		var entry: Dictionary = line
		if str(entry["role"]) == role:
			return entry
	return {}


func _dungeon() -> Dictionary:
	return {"rooms": [{"name": "hall", "width": 12, "depth": 12},
		{"name": "vault", "width": 20, "depth": 20}], "doors": [[1, 2]]}


# --- 1. the fault, driven through the real pipeline ---
#
# Not a record typed into this file: a plan whose second step will not
# validate, so the first step's world is worked out, measured and never
# built. The record that comes out of that is the one the panel was wrong
# about, and it is produced by GameController and not by this suite.
func _a_world_that_was_not_built_says_so() -> void:
	seen.clear()
	c.execute("PLAN", {"steps": [
		{"command": "CREATE_DUNGEON", "parameters": _dungeon()},
		{"command": "CREATE_FARM", "parameters": {
			"zones": [{"type": "barn", "width": 500, "depth": 20}]}}]})
	await process_frame
	await process_frame

	var unbuilt: Dictionary = {}
	for r in seen:
		var rec: Dictionary = r
		if str(rec.get("result", "")) == "VALID" and not WorldRegistry.panel_built(rec):
			unbuilt = rec
			break

	_check(not unbuilt.is_empty(),
		"a plan refused after a step is worked out emits that step's world with a valid proposal and no construction")
	if unbuilt.is_empty():
		return

	# The two halves of the finding, as facts about the panel and not as
	# sentences: it carries measurements, and it admits nothing was built.
	_check(not (unbuilt.get("metrics", {}) as Dictionary).is_empty(),
		"and that record carries the measurements the panel draws from")
	var roles := _roles(unbuilt)
	_check("metric" in roles,
		"so the panel shows measurement lines for a world that does not exist (%s)" % str(roles))
	_check("caveat" in roles,
		"and the panel says they are not of a built world")
	_check("reason" in roles,
		"and the panel gives the reason nothing was built")

	# The direction that makes it a fault and not a rule about plans: the
	# SAME record with construction=BUILT is not caveated. If the caveat were
	# driven by anything else, one of these two would be wrong.
	var built := unbuilt.duplicate(true)
	built["construction"] = "BUILT"
	built["reasons"] = []
	var built_roles := _roles(built)
	_check(not ("caveat" in built_roles),
		"while a record that WAS built carries no caveat (%s)" % str(built_roles))
	_check("metric" in built_roles,
		"and still shows its measurements")


# --- 2. the rule, asked of the layer and not of the case ---
#
# `result` is the validation layer and `construction` is the construction
# layer. The caveat is a claim about what was BUILT, so it must follow
# `construction` and must not follow `result`. Asked as a truth table over
# both fields, so neither can be the one that decides by accident.
func _the_caveat_reads_the_construction_layer() -> void:
	seen.clear()
	c.execute("CREATE_DUNGEON", _dungeon())
	await process_frame
	var base: Dictionary = {}
	for r in seen:
		var rec: Dictionary = r
		if rec.has("metrics") and not (rec["metrics"] as Dictionary).is_empty():
			base = rec
			break
	_check(not base.is_empty(), "a built dungeon gives a record with measurements to vary")
	if base.is_empty():
		return

	# Every combination of the two verdicts, including the two that cannot
	# arise today: a check that cannot fail is worth labelling, and these
	# two CAN, because a plan makes the VALID/not-BUILT corner reachable and
	# the fourth is the one that would appear the day a build is recorded
	# without a valid proposal.
	for verdict in ["VALID", "FAILED"]:
		for construction in ["BUILT", "FAILED", "CLEARED", "UNSUPPORTED"]:
			var rec := base.duplicate(true)
			rec["result"] = verdict
			rec["construction"] = construction
			var roles := _roles(rec)
			var caveated: bool = "caveat" in roles
			_check(caveated == (construction != "BUILT"),
				"result=%s construction=%s: caveat=%s, and it is owed exactly when nothing was built" % [
					verdict, construction, str(caveated)])

	# And the direction PROTOCOL fixes: a record with NO construction field
	# is not treated as built. Missing evidence must not become success.
	var silent := base.duplicate(true)
	silent.erase("construction")
	_check("caveat" in _roles(silent),
		"a record that says nothing about construction is not called built")
	_check(not WorldRegistry.panel_built(silent),
		"and panel_built() says so in one place rather than at each reader")


# --- 3. the name, and the record it has to come from ---
func _a_record_names_only_a_world_it_has() -> void:
	# Every world, named by its own module. Read off the registry so a fourth
	# world is asked without this file being edited - and asked of the
	# CIRCUIT in particular, whose record carries no `world` key at all, so
	# the name cannot come from the ledger field.
	for entry in WorldRegistry.modules():
		var module: WorldModule = entry
		# The record as that world really writes it - record_fields() is what
		# fills it in the game - so this asks the rule of a real record shape
		# and not of one typed here. Two of the three carry `world` and the
		# circuit does not, which is the point: all three must still be named
		# by display_name() and not by a field two of them happen to have.
		var rec: Dictionary = module.record_fields({}, {"attempt": 1})
		rec["result"] = "VALID"
		rec["construction"] = "BUILT"
		rec["metrics"] = {}
		var said := str(_line_of(rec, "result").get("value", ""))
		_check(said.ends_with(module.display_name()),
			"a %s's panel names a %s (%s)" % [module.display_name(), module.display_name(), said])
		# And names no OTHER world, which is the half a default would pass.
		for other in WorldRegistry.modules():
			var them: WorldModule = other
			if them.display_name() == module.display_name():
				continue
			_check(not (them.display_name() in said),
				"and does not name a %s (%s)" % [them.display_name(), said])

	# The circuit, stated as the fact that made the old default invisible.
	var racing := RacingModule.new()
	_check(not racing.record_fields({}, {"attempt": 1}).has("world"),
		"a circuit's record still carries no 'world' field, so its name is the module's")


# --- 4. the sweep, over the whitelist rather than over a list typed here ---
#
# Every command the game allows, driven for real, and the one question asked
# of each: does any line the PANEL words name a world this record is not
# about? The modules' own measurement lines are not asked - they are
# measured against geometry by panel_geometry_test and panel_built_test, and
# what is on trial here is main.gd's old decision.
func _no_command_names_a_world_it_is_not_about() -> void:
	var worlds := PackedStringArray()
	for entry in WorldRegistry.modules():
		worlds.append((entry as WorldModule).display_name())

	var requests := {
		"CREATE_DUNGEON": _dungeon(),
		"CREATE_FARM": {"zones": [{"type": "barn", "width": 20, "depth": 20}]},
		"CREATE_TRACK": {"sections": [
			{"type": "straight", "length": 200.0},
			{"type": "corner", "radius": 60.0, "angle": 90.0},
			{"type": "straight", "length": 200.0},
			{"type": "corner", "radius": 60.0, "angle": 90.0},
			{"type": "straight", "length": 200.0},
			{"type": "corner", "radius": 60.0, "angle": 90.0},
			{"type": "straight", "length": 200.0},
			{"type": "corner", "radius": 60.0, "angle": 90.0}]},
		"EQUIP": {"tool": "car", "spec": {}},
		"ORDER": {"goal": "go_to", "room": 2},
		"SHUT": {"door": [1, 2]},
		"OPEN": {"door": [1, 2]},
		"PLAN": {"steps": [{"command": "CREATE_DUNGEON", "parameters": _dungeon()}]},
		"SPAWN_OPPONENTS": {"count": 2},
		"MODIFY_TRACK": {"corner": 1, "radius": 50.0},
		"CLEAR_WORLD": {},
	}

	for command in CommandParser.allowed_commands():
		var name := str(command)
		_check(requests.has(name),
			"this suite has a request for %s (a new command needs one here)" % name)
		if not requests.has(name):
			continue
		# A dungeon stands first, so ORDER, SHUT and OPEN have something to
		# act on and reach their VALID path rather than being refused early.
		c.execute("CREATE_DUNGEON", _dungeon())
		await process_frame
		seen.clear()
		c.execute(name, requests[name])
		await process_frame
		await process_frame
		_check(not seen.is_empty(), "%s writes a record the panel is drawn from" % name)
		for r in seen:
			var rec: Dictionary = r
			var about := str(rec.get("world", ""))
			var module := WorldRegistry.find(str(rec.get("command", "")))
			if module:
				about = module.display_name()
			for role in ["result", "caveat"]:
				var said := str(_line_of(rec, role).get("value", ""))
				if said == "":
					continue
				for world in worlds:
					if str(world) == about:
						continue
					_check(not (str(world) in said),
						"%s's %s line names no %s (%s)" % [name, role, str(world), said])


# --- 5. a record with no verdict ---
#
# Produced by record_load_check() rather than typed here, because the fact
# that matters is that the one emitted record with no `result` key is one the
# game really writes.
func _a_record_with_no_verdict_gets_no_verdict_line() -> void:
	seen.clear()
	c.record_load_check("dungeon", {"outcome": "SAME", "differences": [],
		"not_measured": [], "said": "a line"})
	await process_frame
	_check(seen.size() == 1, "a load check writes one record")
	if seen.is_empty():
		return
	var rec: Dictionary = seen[0]
	_check(not rec.has("result"),
		"and that record carries no validation verdict, because it judges a world and not a proposal")
	var roles := _roles(rec)
	_check(not ("result" in roles),
		"so the panel states none for it (%s)" % str(roles))
	_check(not ("caveat" in roles),
		"and caveats nothing, having no measurements to caveat (%s)" % str(roles))

	# The direction that keeps this from being a check that cannot fail: a
	# record that DOES carry a verdict gets the line.
	var with_verdict := rec.duplicate(true)
	with_verdict["result"] = "FAILED"
	with_verdict["category"] = "FAILED_SOMETHING"
	_check("result" in _roles(with_verdict),
		"while a record that carries one is given the line")


# --- 6. the shape of the panel itself ---
func _the_panel_has_a_line_for_every_claim_it_makes() -> void:
	var rec := {"result": "VALID", "construction": "BUILT",
		"command": "CREATE_DUNGEON", "intent": {"style": "crypt"}, "metrics": {}}
	for line in WorldRegistry.panel_lines(rec):
		var entry: Dictionary = line
		_check(entry.has("role") and entry.has("label") and entry.has("value") and entry.has("kind"),
			"every panel line says what it is, what it is called and what it reads (%s)" % str(entry))
		_check(str(entry["kind"]) in [WorldRegistry.PANEL_LABEL, WorldRegistry.PANEL_VALUE,
			WorldRegistry.PANEL_GOOD, WorldRegistry.PANEL_BAD],
			"and its kind is one main.gd has a colour for (%s)" % str(entry["kind"]))

	# 037's field, which is the one line of the panel that reads the request
	# rather than the world.
	_check(str(_line_of(rec, "requested").get("value", "")) == "crypt",
		"the REQUESTED line says the style the model wrote")
	var styleless := rec.duplicate(true)
	styleless["intent"] = "not an object"
	_check(str(_line_of(styleless, "requested").get("value", "")) == "not stated",
		"and an intent that is not an object is not a style")
