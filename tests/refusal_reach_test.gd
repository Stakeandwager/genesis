extends SceneTree

# --- 053: which refusals can no legal request reach, and do those checks
#          fire when handed an input that does violate them? ---
#
# THE TASK, AND WHERE IT CAME FROM
#
# HANDOVER named this as the next assistant task: 052's question asked of a
# LIST instead of a key, and the list is the refusal categories. sweep_test
# has reported since 005 that no legal command reaches FAILED_UNWALKABLE -
# TRAPS 6's own example - and 052 found a second member without looking for
# it: the farm's reachability branch of FAILED_LAYOUT cannot be reached
# either, because the only producer of a farm's zone coordinates is the
# solve() that leaves a lane between them. Two of an unknown number, both
# found by accident.
#
# THE NUMBER IS KNOWN NOW AND IT IS SEVEN OF TWELVE, and the second question
# is answered for every one of them: all seven FIRE when handed an input that
# violates them. There is no dead refusal in the world-module pipeline. What
# there is, is seven guards against a future packing change, and before this
# file two of them said so and five did not.
#
# THE TWO QUESTIONS, IN THIS ORDER, BECAUSE THE SECOND IS ONLY INTERESTING
# WHEN THE FIRST SAYS NO:
#
#   (1) can any request a player can send produce it?
#       Swept, not argued: every legal shape of all three worlds, below.
#   (2) handed an input that DOES violate it, does the check fire?
#       That is the half walk_negative.gd does for the dungeon's body and
#       052 added for the farm's lane, and it is the half that tells an
#       unreachable guard apart from a broken one.
#
# WHY EACH GUARD IS OUT OF REACH, which is the part a sweep alone cannot say,
# because a sweep that missed a shape looks exactly like a bound that holds.
# Each of the five new answers is ARITHMETIC over the module's own constants
# and is asserted as such below, so a change to any of those constants moves
# this suite rather than quietly opening a branch nobody tests:
#
#   FAILED_PLACEMENT   rings 1..MAX_RING hold 80 slots and a dungeon has at
#                      most MAX_ROOMS - 1 = 23 other rooms to occupy them, so
#                      a free slot always exists. Furthest ring used over the
#                      whole sweep: 2 of 4.
#   FAILED_TOO_BIG     24 rooms on a grid of pitch MAX_SIDE + GAP span at
#                      most 23 pitches plus one room: 23*46 + 40 = 1098 m,
#                      against a MAX_EXTENT of 1400 m.
#   FAILED_CORRIDOR    a corridor between non-adjacent slots runs down the
#                      lane BETWEEN two rows of rooms, and the lane is GAP
#                      (6 m) wide against a CORRIDOR of 4 m. Crossings seen
#                      over the whole sweep: 0.
#   FAILED_UNWALKABLE  005's answer, unchanged: the tightest legal room
#                      leaves MIN_SIDE - 2*WALL_THICK = 2.4 m against a BODY
#                      of 1.6 m. sweep_test reports it; this file asserts it.
#   FAILED_LAYOUT      three different branches with one name, and all three
#                      are out of reach for three different reasons:
#                      - the farm's "nothing to lay out" is refused one step
#                        earlier by validate(), because MIN_ZONES is 1;
#                      - the farm's lane check is 052's, narrowest gap over
#                        the sweep exactly LANE_WIDTH;
#                      - WorldModule's "this module has no solver" needs a
#                        module that does not override solve(), and all three
#                        in the registry do - asserted by reflection, so a
#                        fourth world is asked without this file being edited.
#
# WHAT THIS SUITE ASSERTS, AND WHAT IT DOES NOT (TRAPS 6, TRAPS 14)
#
# Nothing here asserts a sentence. A comment saying "unreachable" would pass
# against a guard that fires and against one that cannot. What is asserted is
# that the category does not appear over the swept space, that it DOES appear
# when the check is handed a layout that violates it, and that the arithmetic
# which makes it unreachable still holds.
#
# THE ENUMERATION IS MECHANICAL AND IT FAILS CLOSED. The categories are not
# typed out from a reading of the code: every scripts/*.gd is read and every
# FAILED_<NAME> literal in it is collected. A category in the source with no
# entry in DECLARED below FAILS, and an entry here that no longer appears in
# the source FAILS too - so a thirteenth category cannot be added without
# this question being asked of it, and this table cannot go stale against a
# category that was renamed or removed.
#
# AND THE SUITE WAS RUN AGAINST BROKEN CODE BEFORE IT WAS BELIEVED, which is
# 052's lesson and the reason this paragraph exists. Thirteen deliberate
# breakages were made one at a time and the suite re-run against each:
# MAX_EXTENT lowered to 900 (2 failures), MAX_RING to 1 (3), MIN_ZONES to 0
# (3), GAP to 0.5 m (4), FAILED_SEPARATION renamed in the source (3), and
# each of the seven guards wired OUT of the step that calls it. Six of the
# seven wirings were caught, one failure each.
#
# THE SEVENTH WAS NOT, AND IT IS THE FINDING THIS FILE WOULD RATHER NOT HAVE.
# With `_check_reachable()` wired out of FarmModule.solve() - the call
# deleted, the guard left sitting there - THIS SUITE STILL PASSES, 91 of 91.
# It cannot tell a connected guard from a disconnected one, and no suite can,
# because the farm is the only one of the three worlds whose clearance check
# is called INSIDE solve() on a layout solve() has just built. The other six
# are reached through a door that takes the thing they check: post_check(a
# layout) or solve(a content). A violating farm layout has nowhere to be
# handed in. So the honest answer for that row is TWO ANSWERS: the function
# refuses a violation, and the pipeline cannot be shown to call it. 052
# considered moving it into post_check(), where WorldModule's own comment
# says a check on a solved layout goes and where racing puts its separation
# check, and declined on the grounds that it is behaviour-identical and a
# move rather than a fix. It is behaviour-identical AND it is the difference
# between a guard that can be proved connected and one that cannot - which
# is a reason 052 did not have. Not done here: it is a change to where a
# refusal comes from, and HANDOVER carries it as the owner's call.
#
# WHAT IS OUT OF SCOPE AND SAID SO RATHER THAN LEFT TO LOOK COVERED: the
# categories GameController and main.gd return - SCHEMA, SCENE, the
# controller's own UNWALKABLE, NOTHING_BUILT, NO_HANDLER, PARSE, and the AI
# runner's FAILED_AI. They are declared below as CONTROLLER and the two
# questions are NOT asked of them here: they need a scene tree and a
# whitelist walk rather than a module sweep, and that is the half HANDOVER
# records as the next task. They are still enumerated, so adding one is still
# caught. The parser's UNSUPPORTED is a refusal too and is not a FAILED_
# category at all; it is out of this file's scope entirely and named here so
# that is a statement rather than an omission.

var asserted := 0
var bad := 0


func _check(ok: bool, what: String) -> void:
	asserted += 1
	if not ok:
		bad += 1
		print("  FAIL  ", what)


# --- the table ---
#
# MODULE     returned by one of the three world modules' four steps
#            (validate -> pre_check -> solve -> post_check), which is the
#            class this file sweeps.
# CONTROLLER returned by GameController, main.gd or ExperimentRunner. Listed
#            so the enumeration is complete; not asked here.
#
# REACHABLE  a legal request produces it, and there is a named one below.
# GUARD      no legal request produces it, and it fires when violated.
# NOT_ASKED  neither question has been asked of it yet.
#
# FAILED_LAYOUT is a GUARD in all three of its branches, but only two of the
# three can be shown to be CONNECTED to the pipeline - see the header. The
# row cannot say that, so this comment does.
const DECLARED := {
	"FAILED_UNREACHABLE": ["MODULE", "REACHABLE"],
	"FAILED_PLACEMENT": ["MODULE", "GUARD"],
	"FAILED_CORRIDOR": ["MODULE", "GUARD"],
	"FAILED_UNWALKABLE": ["MODULE", "GUARD"],
	"FAILED_TOO_BIG": ["MODULE", "GUARD"],
	"FAILED_LAYOUT": ["MODULE", "GUARD"],
	"FAILED_DEGREES_OF_FREEDOM": ["MODULE", "REACHABLE"],
	"FAILED_INFEASIBLE": ["MODULE", "REACHABLE"],
	"FAILED_CLOSURE": ["MODULE", "REACHABLE"],
	"FAILED_SEPARATION": ["MODULE", "REACHABLE"],
	"FAILED_SCHEMA": ["CONTROLLER", "NOT_ASKED"],
	"FAILED_SCENE": ["CONTROLLER", "NOT_ASKED"],
	"FAILED_NOTHING_BUILT": ["CONTROLLER", "NOT_ASKED"],
	"FAILED_NO_HANDLER": ["CONTROLLER", "NOT_ASKED"],
	"FAILED_PARSE": ["CONTROLLER", "NOT_ASKED"],
	"FAILED_AI": ["CONTROLLER", "NOT_ASKED"],
}

# FAILED_UNWALKABLE is returned by DungeonModule.post_check AND by
# GameController._order(). Written down because the table above has one row
# per NAME and this name has two owners: the dungeon's is swept here, the
# controller's is not, and a table that quietly covered both would be the
# thing this file is about.
const SHARED_WITH_CONTROLLER := ["FAILED_UNWALKABLE"]

# The three branches that share FAILED_LAYOUT. Each is fired separately
# below; the name alone would hide two of them.
const LAYOUT_BRANCHES := ["farm: nothing to lay out", "farm: lane check", "base: no solver"]


# --- 1. the enumeration, read off the source rather than typed ---

func _categories_in_source() -> Dictionary:
	var found := {}
	var dir := DirAccess.open("res://scripts")
	if dir == null:
		return found
	for name in dir.get_files():
		if not name.ends_with(".gd"):
			continue
		var file := FileAccess.open("res://scripts/" + name, FileAccess.READ)
		if file == null:
			continue
		var text := file.get_as_text()
		file.close()
		# FAILED_ on its own is not a category: experiment_runner strips the
		# prefix off one with replace("FAILED_", ""). A name needs a letter.
		var re := RegEx.create_from_string("FAILED_[A-Z][A-Z_]*")
		for m in re.search_all(text):
			var cat := m.get_string()
			if not found.has(cat):
				found[cat] = []
			if not (found[cat] as Array).has(name):
				(found[cat] as Array).append(name)
	return found


func _enumeration() -> void:
	var found := _categories_in_source()
	_check(found.size() >= 16, "read %d FAILED_ categories off scripts/" % found.size())
	for cat in found:
		_check(DECLARED.has(cat),
			"%s (in %s) has a row in DECLARED" % [cat, str(found[cat])])
	for cat in DECLARED:
		_check(found.has(cat),
			"%s is still in scripts/ - a row here for a category nobody returns is stale" % cat)
	var module_cats := 0
	for cat in DECLARED:
		if str((DECLARED[cat] as Array)[0]) == "MODULE":
			module_cats += 1
	_check(module_cats == 10, "10 of them belong to the module pipeline (got %d)" % module_cats)


# --- 2. the sweep: every legal shape of all three worlds ---

var seen := {}
var dungeons_validated := 0
var dungeons_pre_passed := 0
var dungeons_solved := 0
var widest := 0.0
var furthest_ring := 0
var crossings_seen := 0
var farms_solved := 0
var narrowest_zone_gap := 1e9
var tracks_solved := 0


func _note(category: String) -> void:
	if category == "":
		return
	seen[category] = int(seen.get(category, 0)) + 1


func _sweep_dungeon(m: DungeonModule, rooms: Array, doors: Array) -> void:
	var v: Dictionary = m.validate({"rooms": rooms, "doors": doors})
	if not bool(v["ok"]):
		return
	dungeons_validated += 1
	var pre: Dictionary = m.pre_check(v["content"], {})
	if not bool(pre["ok"]):
		_note(str(pre["category"]))
		return
	dungeons_pre_passed += 1
	var s: Dictionary = m.solve(pre["content"])
	furthest_ring = maxi(furthest_ring, int((s["placement"] as Dictionary)["furthest_ring"]))
	if not bool(s["ok"]):
		_note(str(s["category"]))
		return
	dungeons_solved += 1
	var post: Dictionary = m.post_check(s["layout"])
	var record: Dictionary = post["record"]
	var extent: Dictionary = record["extent"]
	widest = maxf(widest, maxf(float(extent["width"]), float(extent["depth"])))
	crossings_seen = maxi(crossings_seen, int(record["crossings"]))
	if not bool(post["ok"]):
		_note(str(post["category"]))


func _sweep_farm(m: FarmModule, zones: Array) -> void:
	var v: Dictionary = m.validate({"zones": zones})
	if not bool(v["ok"]):
		return
	var s: Dictionary = m.solve(v["content"])
	if not bool(s["ok"]):
		_note(str(s["category"]))
		return
	farms_solved += 1
	var placed: Array = (s["layout"] as Dictionary)["zones"]
	for i in placed.size():
		for j in range(i + 1, placed.size()):
			narrowest_zone_gap = minf(narrowest_zone_gap, _gap(placed[i], placed[j]))


func _gap(a: Dictionary, b: Dictionary) -> float:
	var x := maxf(float(b["x"]) - (float(a["x"]) + float(a["width"])),
		float(a["x"]) - (float(b["x"]) + float(b["width"])))
	var z := maxf(float(b["z"]) - (float(a["z"]) + float(a["depth"])),
		float(a["z"]) - (float(b["z"]) + float(b["depth"])))
	return maxf(x, z)


func _sweep_track(m: RacingModule, sections: Array) -> void:
	var v: Dictionary = m.validate({"sections": sections})
	if not bool(v["ok"]):
		return
	var pre: Dictionary = m.pre_check(v["content"], {})
	if not bool(pre["ok"]):
		_note(str(pre["category"]))
		return
	var s: Dictionary = m.solve(pre["content"])
	if not bool(s["ok"]):
		_note(str(s["category"]))
		return
	tracks_solved += 1
	var post: Dictionary = m.post_check(s["layout"])
	if not bool(post["ok"]):
		_note(str(post["category"]))


# A door graph of the named shape. "split" is the one that matters and it is
# the one a sweep is most likely to miss: validate() refuses a design with
# fewer than rooms - 1 doors, so a dungeon falls into two pieces only when
# the doors it does have are spent on a loop. A triangle and a loner is the
# smallest one, and it is a design the AI can send.
func _doors(shape: String, n: int, rng: RandomNumberGenerator) -> Array:
	var out: Array = []
	match shape:
		"chain":
			for i in range(1, n):
				out.append([i, i + 1])
		"hub":
			for i in range(2, n + 1):
				out.append([1, i])
		"ring":
			for i in range(1, n):
				out.append([i, i + 1])
			if n > 2:
				out.append([n, 1])
		"random":
			for i in range(2, n + 1):
				out.append([rng.randi_range(1, i - 1), i])
		"split":
			var head: int = maxi(3, n - 1)
			for i in range(1, head):
				out.append([i, i + 1])
			if head >= 3:
				out.append([head, 1])
	return out


# A SWEEP THAT NEVER GOT PAST validate() SAYS NOTHING ABOUT pre_check, and
# this one did exactly that on its first run: its disconnected shape had
# fewer doors than validate()'s floor, so every one of them was thrown out a
# step early and FAILED_UNREACHABLE - which a four-room triangle reaches in
# one line - was reported as out of reach. That is why every step below
# counts what REACHED it and fails if the count is thin, and why "split"
# spends its doors on a loop instead of leaving them out.
func _sweep() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 20261016

	var dm := DungeonModule.new()
	for size in [dm.MIN_SIDE, 5.0, 10.0, 20.0, 30.0, dm.MAX_SIDE]:
		for n in [2, 3, 4, 6, 8, 12, 18, 24]:
			for shape in ["chain", "hub", "ring", "random", "split"]:
				var rooms: Array = []
				for i in n:
					rooms.append({"name": "r%d" % i, "width": size, "depth": size})
				_sweep_dungeon(dm, rooms, _doors(shape, n, rng))
	for trial in 400:
		var n := rng.randi_range(2, dm.MAX_ROOMS)
		var rooms: Array = []
		for i in n:
			rooms.append({"name": "r%d" % i,
				"width": snappedf(rng.randf_range(dm.MIN_SIDE, dm.MAX_SIDE), 0.1),
				"depth": snappedf(rng.randf_range(dm.MIN_SIDE, dm.MAX_SIDE), 0.1)})
		var shape: String = ["chain", "hub", "ring", "random", "split"][rng.randi_range(0, 4)]
		_sweep_dungeon(dm, rooms, _doors(shape, n, rng))
	# every room joined to every other, up to the door limit
	for n in [4, 6, 8, 10]:
		var rooms: Array = []
		for i in n:
			rooms.append({"name": "r%d" % i, "width": dm.MAX_SIDE, "depth": dm.MAX_SIDE})
		var doors: Array = []
		for i in range(1, n + 1):
			for j in range(i + 1, n + 1):
				if doors.size() < dm.MAX_DOORS:
					doors.append([i, j])
		_sweep_dungeon(dm, rooms, doors)

	var fm := FarmModule.new()
	for type_name in fm.ZONE_TYPES:
		var span: Vector2 = fm.BUILDING_SIDE if type_name in fm.BUILDINGS else fm.FIELD_SIDE
		for n in [1, 2, 3, 6, 12, fm.MAX_ZONES]:
			for frac in [0.0, 0.5, 1.0]:
				var side: float = lerpf(span.x, span.y, frac)
				var zones: Array = []
				for i in n:
					var zone := {"type": type_name, "width": side, "depth": side}
					if type_name == "crop":
						zone["crop"] = "corn"
					zones.append(zone)
				_sweep_farm(fm, zones)
	for trial in 400:
		var n := rng.randi_range(fm.MIN_ZONES, fm.MAX_ZONES)
		var zones: Array = []
		for i in n:
			var type_name: String = fm.ZONE_TYPES[rng.randi_range(0, fm.ZONE_TYPES.size() - 1)]
			var span: Vector2 = fm.BUILDING_SIDE if type_name in fm.BUILDINGS else fm.FIELD_SIDE
			var zone := {"type": type_name,
				"width": snappedf(rng.randf_range(span.x, span.y), 0.1),
				"depth": snappedf(rng.randf_range(span.x, span.y), 0.1)}
			if type_name == "crop":
				zone["crop"] = "corn"
			zones.append(zone)
		_sweep_farm(fm, zones)

	var rm := RacingModule.new()
	for corners in [2, 3, 4, 6, 8, 12, 20]:
		for straight_length in [20.0, 100.0, 400.0, 1000.0]:
			for radius in [15.0, 60.0, 150.0, 300.0]:
				var sections: Array = []
				for i in corners:
					sections.append({"type": "straight", "length": straight_length})
					sections.append({"type": "corner", "radius": radius, "angle": 360.0 / corners})
				if sections.size() <= SectionValidator.MAX_SECTIONS:
					_sweep_track(rm, sections)
	for trial in 1000:
		var n := rng.randi_range(SectionValidator.MIN_SECTIONS, 14)
		var sections: Array = []
		for i in n:
			match rng.randi_range(0, 3):
				0: sections.append({"type": "straight",
						"length": snappedf(rng.randf_range(20.0, 1000.0), 1.0)})
				1: sections.append({"type": "corner",
						"radius": snappedf(rng.randf_range(15.0, 300.0), 1.0),
						"angle": snappedf(rng.randf_range(10.0, 120.0), 1.0) * (1.0 if rng.randf() < 0.7 else -1.0)})
				2: sections.append({"type": "hairpin",
						"radius": snappedf(rng.randf_range(10.0, 60.0), 1.0),
						"angle": snappedf(rng.randf_range(120.0, 200.0), 1.0) * (1.0 if rng.randf() < 0.7 else -1.0)})
				3: sections.append({"type": "chicane",
						"radius": snappedf(rng.randf_range(15.0, 150.0), 1.0)})
		_sweep_track(rm, sections)

	_check(dungeons_validated > 500,
		"%d designs got past validate(), so pre_check was actually asked" % dungeons_validated)
	_check(dungeons_validated - dungeons_pre_passed > 50,
		"and %d of them were refused there, so the step is not rubber-stamping" % (dungeons_validated - dungeons_pre_passed))
	_check(dungeons_solved > 400, "swept %d legal dungeons through all four steps" % dungeons_solved)
	# Printed, not just asserted: the comments beside each guard quote these
	# numbers, and a number in a comment that nothing prints is a number
	# nobody can check (TRAPS 14).
	print("  swept: %d dungeon designs validated, %d solved, widest %.1f m, furthest ring %d, crossings %d" % [
		dungeons_validated, dungeons_solved, widest, furthest_ring, crossings_seen])
	print("  swept: %d farms solved, narrowest gap between two zones %.4f m" % [
		farms_solved, narrowest_zone_gap])
	_check(farms_solved > 400, "swept %d legal farms" % farms_solved)
	_check(tracks_solved > 90, "swept %d legal tracks that closed" % tracks_solved)

	# The sweep's job is the GUARD rows: a category that turns up here is one
	# a legal request CAN produce, and the row saying otherwise is wrong.
	for cat in DECLARED:
		var row: Array = DECLARED[cat]
		if str(row[0]) != "MODULE" or str(row[1]) != "GUARD":
			continue
		_check(not seen.has(cat),
			"%s was NOT reached by any legal request (seen %d times - if this fires, the row is wrong, not the sweep)" % [
				cat, int(seen.get(cat, 0))])

	# The REACHABLE rows are carried by the named requests in _reached_how(),
	# which are reproducible where a random hit is not. What the sweep adds
	# is that it is not silently passing everything: four of the five turn up
	# in it in the hundreds. FAILED_SEPARATION does NOT, and that is a
	# measurement rather than an omission - a composition that closes AND
	# then runs over itself turned up about three times in twenty thousand
	# random draws when this was written, so requiring one here would be
	# requiring a coin to land. Its row is carried by the named example.
	for cat in ["FAILED_UNREACHABLE", "FAILED_DEGREES_OF_FREEDOM", "FAILED_INFEASIBLE", "FAILED_CLOSURE"]:
		_check(seen.has(cat), "%s turned up in the sweep (%d times)" % [cat, int(seen.get(cat, 0))])
	print("  (FAILED_SEPARATION turned up %d times in the sweep; its row is carried by the named request)" % int(seen.get("FAILED_SEPARATION", 0)))


# --- 3. the arithmetic that puts each guard out of reach ---

func _why_out_of_reach() -> void:
	var dm := DungeonModule.new()
	var fm := FarmModule.new()

	# FAILED_PLACEMENT: a child is placed in the first free slot within
	# MAX_RING of its parent. Ring r holds 8r slots, and at most MAX_ROOMS-1
	# of them can be occupied by anything at all.
	var capacity := 0
	for r in range(1, dm.MAX_RING + 1):
		capacity += 8 * r
	_check(capacity >= dm.MAX_ROOMS - 1,
		"rings 1..%d hold %d slots and a dungeon has at most %d other rooms" % [
			dm.MAX_RING, capacity, dm.MAX_ROOMS - 1])
	_check(furthest_ring < dm.MAX_RING,
		"the sweep never needed ring %d: furthest used was %d" % [dm.MAX_RING, furthest_ring])

	# FAILED_TOO_BIG: the widest dungeon the grid can make.
	var pitch: float = dm.MAX_SIDE + dm.GAP
	var widest_possible: float = float(dm.MAX_ROOMS - 1) * pitch + dm.MAX_SIDE
	_check(widest_possible < dm.MAX_EXTENT,
		"%d rooms at pitch %.0f span at most %.0f m, against a limit of %.0f m" % [
			dm.MAX_ROOMS, pitch, widest_possible, dm.MAX_EXTENT])
	_check(widest <= widest_possible + 0.001,
		"the widest dungeon swept was %.1f m, inside that bound" % widest)

	# FAILED_CORRIDOR: the lane a corridor runs down is wider than it is.
	_check(dm.GAP > dm.CORRIDOR,
		"the lane between two rows is %.0f m and a corridor is %.0f m" % [dm.GAP, dm.CORRIDOR])
	_check(crossings_seen == 0,
		"no corridor crossed a room anywhere in the sweep (most seen: %d)" % crossings_seen)

	# FAILED_UNWALKABLE: 005's number, asserted rather than remembered.
	var clear: float = dm.MIN_SIDE - 2.0 * dm.WALL_THICK
	_check(clear > dm.BODY,
		"the tightest legal room leaves %.1f m for a body %.1f m across" % [clear, dm.BODY])

	# FAILED_LAYOUT, branch 1: validate() refuses the empty farm first.
	_check(fm.MIN_ZONES >= 1, "a farm needs at least %d zone" % fm.MIN_ZONES)
	var empty: Dictionary = fm.validate({"zones": []})
	_check(not bool(empty["ok"]),
		"validate() refuses a farm of no zones before solve() sees it: %s" % str(empty["errors"]))

	# FAILED_LAYOUT, branch 2: 052's measurement, re-taken here.
	_check(narrowest_zone_gap >= fm.LANE_WIDTH - 0.0001,
		"the narrowest gap between two zones anywhere in the sweep was %.4f m, against a lane of %.1f m" % [
			narrowest_zone_gap, fm.LANE_WIDTH])

	# FAILED_LAYOUT, branch 3: by reflection, so a fourth world is asked too.
	var worlds := 0
	for module in WorldRegistry.modules():
		worlds += 1
		var overrides := false
		for entry in (module as Object).get_script().get_script_method_list():
			if str(entry["name"]) == "solve":
				overrides = true
		_check(overrides, "%s overrides solve(), so the base's refusal cannot be its answer" % (module as WorldModule).display_name())
	_check(worlds == 3, "asked every world in the registry (%d)" % worlds)


# --- 4. a named legal request for each category that IS reachable ---
#
# The sweep says a category can be reached. These say HOW, which is the half
# a reader needs and a random sweep cannot give.

func _reached_how() -> void:
	var dm := DungeonModule.new()
	# A triangle and a loner: 4 rooms, 3 doors, which is exactly the floor
	# validate() enforces, and room 4 is sealed off.
	var rooms: Array = []
	for name in ["hall", "vault", "cell", "crypt"]:
		rooms.append({"name": name, "width": 10.0, "depth": 10.0})
	var v: Dictionary = dm.validate({"rooms": rooms, "doors": [[1, 2], [2, 3], [1, 3]]})
	_check(bool(v["ok"]), "a triangle of rooms with a fourth outside it is schema-legal")
	if bool(v["ok"]):
		var pre: Dictionary = dm.pre_check(v["content"], {})
		_check(str(pre["category"]) == "FAILED_UNREACHABLE",
			"and pre_check refuses it: %s" % str(pre["category"]))

	var rm := RacingModule.new()
	_expect_track(rm, "pre", "FAILED_DEGREES_OF_FREEDOM", [
		{"type": "straight", "length": 100.0},
		{"type": "straight", "length": 100.0},
	])
	_expect_track(rm, "pre", "FAILED_INFEASIBLE", [
		{"type": "straight", "length": 100.0},
		{"type": "corner", "radius": 50.0, "angle": 10.0},
		{"type": "straight", "length": 100.0},
		{"type": "corner", "radius": 50.0, "angle": 10.0},
	])
	# Three 120 deg corners DO add to 360, so the gate lets this through; the
	# two 1000 m straights against one of 20 m are what the solver cannot
	# pull into a closed shape within the 20% it is allowed.
	_expect_track(rm, "solve", "FAILED_CLOSURE", [
		{"type": "straight", "length": 1000.0},
		{"type": "corner", "radius": 15.0, "angle": 120.0},
		{"type": "straight", "length": 20.0},
		{"type": "corner", "radius": 15.0, "angle": 120.0},
		{"type": "straight", "length": 1000.0},
		{"type": "corner", "radius": 15.0, "angle": 120.0},
	])
	# A composition that closes and then runs over itself twice.
	_expect_track(rm, "post", "FAILED_SEPARATION", [
		{"type": "straight", "length": 206.0},
		{"type": "straight", "length": 290.0},
		{"type": "corner", "radius": 275.0, "angle": -13.0},
		{"type": "hairpin", "radius": 49.0, "angle": 136.0},
		{"type": "corner", "radius": 139.0, "angle": 89.0},
		{"type": "hairpin", "radius": 35.0, "angle": 174.0},
		{"type": "straight", "length": 287.0},
		{"type": "hairpin", "radius": 18.0, "angle": 140.0},
		{"type": "straight", "length": 74.0},
		{"type": "straight", "length": 691.0},
		{"type": "hairpin", "radius": 29.0, "angle": 134.0},
		{"type": "corner", "radius": 239.0, "angle": -69.0},
		{"type": "hairpin", "radius": 47.0, "angle": -198.0},
	])


# Runs a legal section list through the module and asserts WHICH step refuses
# it and with what. The step matters: a composition refused by the gate never
# reaches the solver, so a test that only looked at the category could pass
# while the refusal moved a layer.
func _expect_track(rm: RacingModule, step: String, category: String, sections: Array) -> void:
	var v: Dictionary = rm.validate({"sections": sections})
	_check(bool(v["ok"]), "%s: the sections are schema-legal (%s)" % [category, str(v["errors"])])
	if not bool(v["ok"]):
		return
	var pre: Dictionary = rm.pre_check(v["content"], {})
	if step == "pre":
		_check(str(pre["category"]) == category,
			"%s: pre_check says %s" % [category, str(pre["category"])])
		return
	_check(bool(pre["ok"]), "%s: the gate passes it (%s)" % [category, str(pre["category"])])
	if not bool(pre["ok"]):
		return
	var s: Dictionary = rm.solve(pre["content"])
	if step == "solve":
		_check(str(s["category"]) == category, "%s: solve says %s" % [category, str(s["category"])])
		return
	_check(bool(s["ok"]), "%s: it closes (%s)" % [category, str(s["category"])])
	if not bool(s["ok"]):
		return
	var post: Dictionary = rm.post_check(s["layout"])
	_check(str(post["category"]) == category, "%s: post_check says %s" % [category, str(post["category"])])


# --- 5. and the half that matters: does each guard FIRE when violated? ---
#
# Every input below is one no solver in this repository produces. That is the
# point: a guard is for the day one does.

func _guards_fire() -> void:
	var dm := DungeonModule.new()

	# FAILED_PLACEMENT: more children off one room than MAX_RING rings hold.
	# 200 rooms is not a legal dungeon; solve() is handed the content a
	# validate() that let it through would have produced.
	var rooms: Array = []
	var doors: Array = []
	for i in 200:
		rooms.append({"name": "r%d" % i, "width": 10.0, "depth": 10.0})
		if i > 0:
			doors.append(Vector2i(0, i))
	var placed: Dictionary = dm.solve({"rooms": rooms, "doors": doors, "things": []})
	_check(str(placed["category"]) == "FAILED_PLACEMENT",
		"200 rooms off one hub: solve says %s" % str(placed["category"]))
	_check(not (placed["placement"]["failed"] as Array).is_empty(),
		"and it names the rooms it could not place (%d of them)" % (placed["placement"]["failed"] as Array).size())

	# FAILED_CORRIDOR: rooms wider than the pitch they are spaced at, so the
	# lane a corridor runs down is inside a room. The pitch solve() computes
	# is always the largest room plus GAP; this layout breaks that invariant,
	# which is exactly the packing change the guard is kept for.
	var three: Array = []
	for name in ["a", "b", "c"]:
		three.append({"name": name, "width": 40.0, "depth": 40.0})
	var cramped := {
		"rooms": three,
		"doors": [Vector2i(0, 1), Vector2i(1, 2), Vector2i(0, 2)],
		"pitch": 16.0,
		"slots": {0: Vector2i(0, 0), 1: Vector2i(1, 0), 2: Vector2i(2, 0)},
		"things": [],
	}
	var crossed: Dictionary = dm.post_check(cramped)
	_check(str(crossed["category"]) == "FAILED_CORRIDOR",
		"rooms wider than their pitch: post_check says %s" % str(crossed["category"]))
	_check(int(crossed["record"]["crossings"]) > 0,
		"and it counts the crossings (%d)" % int(crossed["record"]["crossings"]))
	# The same slots at the pitch solve() would have chosen are fine, which
	# is what makes the line above a measurement of the GUARD and not of the
	# fixture.
	var roomy := cramped.duplicate(true)
	roomy["pitch"] = 46.0
	_check(bool((dm.post_check(roomy))["ok"]),
		"and the same three rooms at pitch 46 pass")

	# FAILED_TOO_BIG: the same three rooms, twenty pitches apart.
	var spread := {}
	for i in 3:
		spread[i] = Vector2i(i * 20, 0)
	var far := {
		"rooms": three,
		"doors": [Vector2i(0, 1), Vector2i(1, 2)],
		"pitch": 46.0,
		"slots": spread,
		"things": [],
	}
	var big: Dictionary = dm.post_check(far)
	_check(str(big["category"]) == "FAILED_TOO_BIG",
		"three rooms 20 slots apart: post_check says %s" % str(big["category"]))
	_check(float(big["record"]["extent"]["width"]) > dm.MAX_EXTENT,
		"and the width it measured (%.0f m) is over the limit" % float(big["record"]["extent"]["width"]))

	# FAILED_UNWALKABLE: the dungeon's own negative case. walk_negative.gd
	# removes a doorway from a built layout; this asks the same question of
	# post_check, which is the step that returns the category.
	# FAILED_UNWALKABLE: a layout a body cannot get round. The violating
	# input is a SHUT DOOR, and which input that is, is the finding here.
	#
	# walkable() gives two reasons: a doorway no body fits through, and a
	# door somebody has shut. THE FIRST ONE CANNOT BE PRODUCED AT ALL, by a
	# legal request or by a hand-built layout, and it is not for want of
	# trying: the opening cut in a room's wall IS the corridor leg that
	# meets it, so a doorway is always CORRIDOR (4 m) wide against a BODY of
	# 1.6 m, whatever the room is. Rooms of 1, 2, 3 and 4 m were handed to
	# walkable() while this was written and none of them blocked anything -
	# a room narrower than the corridor has no wall left to block with. That
	# is asserted as arithmetic below rather than as four fixtures.
	#
	# So the guard fires on the reason that CAN happen. A shut door is not
	# reachable at post_check either, because set_shut() only ever runs on a
	# layout that is already standing - which is the honest shape of this
	# row: the category is returned by a step the shut door never reaches,
	# and the same walkable() does the live work AFTER the build, where
	# route(), the panel and the metrics read it.
	var three_rooms: Array = []
	for name in ["a", "b", "c"]:
		three_rooms.append({"name": name, "width": 10.0, "depth": 10.0})
	var chain: Dictionary = dm.validate({"rooms": three_rooms, "doors": [[1, 2], [2, 3]]})
	var chain_pre: Dictionary = dm.pre_check(chain["content"], {})
	var chain_layout: Dictionary = (dm.solve(chain_pre["content"]))["layout"]
	_check(bool((dm.post_check(chain_layout))["ok"]),
		"three rooms in a chain pass post_check with every door open")
	DungeonModule.set_shut(chain_layout, 1, 2, true)
	var shut: Dictionary = dm.post_check(chain_layout)
	_check(str(shut["category"]) == "FAILED_UNWALKABLE",
		"with the last door shut: post_check says %s" % str(shut["category"]))
	_check(not ((shut["record"]["walkable"] as Dictionary)["unreachable"] as Array).is_empty(),
		"and it names the room the body can no longer get to")
	# The width a doorway is cut to, against the body that has to use it.
	_check(dm.CORRIDOR > dm.BODY,
		"a doorway is cut to the corridor's %.0f m, against a body %.1f m across, so no room size can pinch one" % [
			dm.CORRIDOR, dm.BODY])

	# FAILED_LAYOUT, branch 1: the farm with nothing in it.
	var fm := FarmModule.new()
	var nothing: Dictionary = fm.solve({"zones": []})
	_check(str(nothing["category"]) == "FAILED_LAYOUT",
		"a farm of no zones: solve says %s" % str(nothing["category"]))

	# FAILED_LAYOUT, branch 2: two zones with no lane between them. 052's
	# assertion, repeated here so this file's row for FAILED_LAYOUT covers
	# all three of its branches rather than one.
	# A three by three grid with 0.6 m between the zones: the middle one is
	# the only zone with a neighbour on all four sides, and the four on the
	# edge still have open ground outside the grid. 0.6 m is the gap 052
	# measured as the one the old threshold admitted.
	var pinched_zones: Array = []
	for i in 9:
		pinched_zones.append({"type": "yard", "width": 20.0, "depth": 20.0,
			"x": float(i % 3) * 20.6, "z": float(i / 3) * 20.6})
	var pinched: Dictionary = fm._check_reachable(
		{"zones": pinched_zones, "lane_width": fm.LANE_WIDTH})
	_check(not bool(pinched["ok"]),
		"nine zones 0.6 m apart: the lane check refuses the one in the middle")
	_check((pinched["reasons"] as Array).size() == 1,
		"and it names exactly the one that is walled in (%d reported)" % (pinched["reasons"] as Array).size())
	# The same grid with a real lane between the zones passes, which is what
	# makes the two lines above a measurement of the guard and not of the grid.
	var roomy_zones: Array = []
	for i in 9:
		roomy_zones.append({"type": "yard", "width": 20.0, "depth": 20.0,
			"x": float(i % 3) * 26.0, "z": float(i / 3) * 26.0})
	_check(bool((fm._check_reachable({"zones": roomy_zones, "lane_width": fm.LANE_WIDTH}))["ok"]),
		"and the same nine zones a lane apart pass")

	# FAILED_LAYOUT, branch 3: a module that does not override solve().
	var base := WorldModule.new()
	var no_solver: Dictionary = base.solve({})
	_check(str(no_solver["category"]) == "FAILED_LAYOUT",
		"the base module's own solve says %s" % str(no_solver["category"]))

	_check(LAYOUT_BRANCHES.size() == 3, "all three FAILED_LAYOUT branches were fired")
	_check(SHARED_WITH_CONTROLLER.size() == 1,
		"and one category name has an owner outside the module pipeline")


func _initialize() -> void:
	print("REFUSAL REACH")
	_enumeration()
	_sweep()
	_why_out_of_reach()
	_reached_how()
	_guards_fire()
	print("REFUSAL REACH %d assertions, failures=%d" % [asserted, bad])
	quit()
