extends WorldModule
class_name DungeonModule

# --- 002I: a dungeon of rooms and doors ---
# The third world, and the first that is a GRAPH rather than a path or a set
# of rectangles. The AI designs rooms and which doors join them; Godot works
# out where every room physically goes, exactly as "around": N lets the AI
# name intent and leave placement to the game.
#
#   validate    rooms and doors are legal, and refer to rooms that exist
#   pre_check   every room must be reachable from the entrance
#   solve       place the rooms on a lattice, no overlaps
#   post_check  the dungeon must fit, and no corridor may cross a room
#   measure     rooms, doors, floor, how deep, how many ways round
#   build       floors and walls
#
# WHY A LATTICE
# Every room sits centred in its own slot, PITCH metres square, so the space
# between slots is always empty. A corridor between neighbouring rooms is one
# straight run through that empty space. A corridor between rooms further
# apart travels in the lanes at half-slot coordinates, where no room ever is.
# A corridor therefore cannot pass through a room it does not serve, whatever
# the AI designs. The post_check still looks, as a guard against a mistake in
# this file rather than against anything the AI did.
#
# PITCH comes from the largest room the AI asked for, so the lattice always
# has room for everything in it.

const MIN_ROOMS := 2
const MAX_ROOMS := 24
const MAX_DOORS := 48
const MAX_THINGS := 8                    # 015: objects that can be carried
const THING_SIZE := 0.9                  # metres across, a crate or a lamp
const THING_COLOUR := Color(0.78, 0.62, 0.22)
const MIN_SIDE := 4.0                    # metres, smallest room
const MAX_SIDE := 40.0                   # metres, largest room
const GAP := 6.0                         # empty lane between slots
const CORRIDOR := 4.0                    # corridor width
const MAX_RING := 4                      # rings out a room may be placed
const MAX_EXTENT := 1400.0               # metres across, either way

# Heights, following the farm so that nothing is ever buried inside
# anything else. Each slab is drawn from the ground up, so a lower number
# means a slab hidden inside a taller one.
const PAD_HEIGHT := 1.0                  # the bare floor under everything
# Corridors sit just UNDER the room floor, not 0.3 m below it. The old gap
# made every doorway a step up, and a CharacterBody3D cannot climb a step: a
# walker reached 1 room in 5 while the geometric check still reported 5 of 5
# (walker_test.gd). The remaining 2 cm keeps room floors drawing on top where
# the two overlap, which is all the difference was ever for.
const CORRIDOR_HEIGHT := 1.58            # corridors sit just under the room floor
const ROOM_HEIGHT := 1.6                 # room floors sit above corridors
const WALL_HEIGHT := 3.0                 # walls stand on the room floor
const WALL_THICK := 0.8

const PAD_COLOUR := Color(0.16, 0.15, 0.17)
const ROOM_COLOUR := Color(0.40, 0.38, 0.42)
const ENTRANCE_COLOUR := Color(0.52, 0.44, 0.26)
const CORRIDOR_COLOUR := Color(0.28, 0.27, 0.31)
const WALL_COLOUR := Color(0.22, 0.21, 0.25)

# North, east, south, west, in slots.
const DIRS := [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]


func command() -> String:
	return "CREATE_DUNGEON"


func display_name() -> String:
	return "dungeon"


func prompt_section() -> String:
	return """CREATE_DUNGEON - design a dungeon of rooms joined by doors
{"command": "CREATE_DUNGEON", "parameters": {"intent": {"style": STYLE}, "rooms": [ROOM, ROOM, ...], "doors": [[A, B], ...], "things": [THING, ...]}}

ROOM: {"name": NAME, "width": W, "depth": D} where NAME is a short lowercase label with underscores, and W and D are 4 to 40 metres
DOOR: [A, B] where A and B are room numbers, 1 for the first room in your list. A door joins two different rooms, and the same pair may only be joined once.
THING: {"name": NAME, "in": R} - an object sitting in room R, which a character can pick up and carry. R is a room's name or its number counting from 1. NAME is a short lowercase label with underscores and may not be the name of a room. At most 8.
If the player names something that is IN the dungeon - "a lamp in the store", "with a key in the entrance", "a chest somewhere" - it MUST appear in "things", in the room they said. A room is a place; a thing is an object inside one, and the two are never swapped. Leave "things" out only when the player asked for nothing to be in it.
Use 2 to 24 rooms and at most 48 doors. Do not give positions: the game works out where every room goes and runs the corridors.
Room 1 is the entrance, where the player comes in.
Every room must be reachable from room 1 by following doors, or the design is refused. More doors than rooms is allowed and makes loops: ways round that come back."""


func record_fields(parameters: Dictionary, attempt: Dictionary) -> Dictionary:
	var intent = parameters.get("intent", {})
	var fields := {
		"world": display_name(),
		"intent": intent if typeof(intent) == TYPE_DICTIONARY else {},
		"command": command(),
		"proposed_rooms": parameters.get("rooms", []),
		"proposed_doors": parameters.get("doors", []),
		"proposed_things": parameters.get("things", []),
		"attempt": int(attempt.get("attempt", 1)),
	}
	if attempt.has("revision_of"):
		fields["revision_of"] = attempt["revision_of"]
	return fields


# --- what the AI proposed ---

func validate(parameters: Dictionary) -> Dictionary:
	var errors: Array = []

	if parameters.has("intent") and typeof(parameters["intent"]) != TYPE_DICTIONARY:
		errors.append("intent must be an object, for example {\"style\": \"crypt\"}")

	var raw_rooms = parameters.get("rooms", null)
	if typeof(raw_rooms) != TYPE_ARRAY:
		return {"ok": false, "errors": ["rooms must be a list"], "content": {}}
	var raw_doors = parameters.get("doors", null)
	if typeof(raw_doors) != TYPE_ARRAY:
		return {"ok": false, "errors": ["doors must be a list"], "content": {}}

	var rooms: Array = raw_rooms
	var doors: Array = raw_doors
	if rooms.size() < MIN_ROOMS or rooms.size() > MAX_ROOMS:
		errors.append("a dungeon needs %d to %d rooms (got %d)" % [MIN_ROOMS, MAX_ROOMS, rooms.size()])
	if doors.size() > MAX_DOORS:
		errors.append("at most %d doors (got %d)" % [MAX_DOORS, doors.size()])

	var clean_rooms: Array = []
	var names := {}
	for i in rooms.size():
		var n := i + 1
		if typeof(rooms[i]) != TYPE_DICTIONARY:
			errors.append("room %d must be an object" % n)
			continue
		var room: Dictionary = rooms[i]
		var label := str(room.get("name", "")).strip_edges().to_lower()
		if label == "":
			label = "room_%d" % n
		if names.has(label):
			errors.append("room %d: two rooms are both called '%s'" % [n, label])
		names[label] = true
		var width := _side(room, "width", n, errors)
		var depth := _side(room, "depth", n, errors)
		clean_rooms.append({"name": label, "width": width, "depth": depth})

	var clean_doors: Array = []
	var seen_pairs := {}
	for i in doors.size():
		var n := i + 1
		var pair = doors[i]
		if typeof(pair) != TYPE_ARRAY or (pair as Array).size() != 2:
			errors.append("door %d must be a pair of room numbers, for example [1, 2]" % n)
			continue
		# Read through the same door as every other number out of a request.
		# An object or a null in a door pair used to throw here, and the throw
		# abandoned validate() mid-way: it returned {} - no "ok", no "errors" -
		# and game_controller reads check["ok"] directly.
		var raw_a := Readback.as_number((pair as Array)[0])
		var raw_b := Readback.as_number((pair as Array)[1])
		if is_nan(raw_a) or is_nan(raw_b):
			errors.append("door %d must be a pair of room numbers, for example [1, 2]" % n)
			continue
		var a := int(raw_a)
		var b := int(raw_b)
		if a < 1 or a > rooms.size() or b < 1 or b > rooms.size():
			errors.append("door %d: [%d, %d] names a room that does not exist (rooms are 1 to %d)" % [n, a, b, rooms.size()])
			continue
		if a == b:
			errors.append("door %d: a room cannot have a door to itself" % n)
			continue
		var key := "%d-%d" % [mini(a, b), maxi(a, b)]
		if seen_pairs.has(key):
			errors.append("door %d: rooms %d and %d are already joined" % [n, a, b])
			continue
		seen_pairs[key] = true
		clean_doors.append(Vector2i(mini(a, b) - 1, maxi(a, b) - 1))

	# --- 015: things that can be picked up ---
	# A thing is a name and the room it starts in. Nothing else: no weight, no
	# use, no value. An object exists so that an errand can be about something
	# arriving rather than about somebody walking.
	var clean_things: Array = []
	var raw_things = parameters.get("things", [])
	if typeof(raw_things) != TYPE_ARRAY:
		errors.append("things must be a list")
		raw_things = []
	var things: Array = raw_things
	if things.size() > MAX_THINGS:
		errors.append("at most %d things in a dungeon (got %d)" % [MAX_THINGS, things.size()])
	var thing_names := {}
	for i in things.size():
		var n := i + 1
		if typeof(things[i]) != TYPE_DICTIONARY:
			errors.append("thing %d must be an object, for example {\"name\": \"lamp\", \"in\": 1}" % n)
			continue
		var thing: Dictionary = things[i]
		var label := str(thing.get("name", "")).strip_edges().to_lower().replace(" ", "_")
		if label == "":
			errors.append("thing %d: no name" % n)
			continue
		if thing_names.has(label):
			errors.append("thing %d: two things are both called '%s'" % [n, label])
			continue
		if names.has(label):
			errors.append("thing %d: '%s' is already the name of a room" % [n, label])
			continue
		thing_names[label] = true
		# 019: a room may be named or numbered here, exactly as it may be in
		# an order. The AI reached for the name without being asked to -
		# reasonably, since names are how rooms are addressed everywhere else -
		# and every test had used a number, so nothing had ever exercised it.
		var where := _room_index(thing.get("in", null), clean_rooms)
		if where < 0:
			var given = thing.get("in", null)
			errors.append("thing %d: '%s' is in '%s', and this dungeon's rooms are %s" % [
				n, label, "nothing" if given == null else str(given),
				", ".join(_room_names(clean_rooms))])
			continue
		clean_things.append({"name": label, "in": where})

	if errors.is_empty() and clean_doors.size() < clean_rooms.size() - 1:
		errors.append("%d rooms need at least %d doors to all be reachable (got %d)" % [
			clean_rooms.size(), clean_rooms.size() - 1, clean_doors.size()])

	if not errors.is_empty():
		return {"ok": false, "errors": errors, "content": {}}
	return {"ok": true, "errors": [], "content": {
		"rooms": clean_rooms, "doors": clean_doors, "things": clean_things}}


# Which room something is in: a number counting from 1, or a room's name.
# Returns the index counting from 0, or -1 for neither.
static func _room_index(given, rooms: Array) -> int:
	if given == null:
		return -1
	if typeof(given) == TYPE_INT or typeof(given) == TYPE_FLOAT:
		var number := int(given)
		return number - 1 if number >= 1 and number <= rooms.size() else -1
	var wanted := str(given).to_lower().strip_edges().replace(" ", "_")
	for i in rooms.size():
		if str((rooms[i] as Dictionary).get("name", "")).to_lower() == wanted:
			return i
	return -1


static func _room_names(rooms: Array) -> Array:
	var out: Array = []
	for r in rooms:
		out.append(str((r as Dictionary).get("name", "")).replace("_", " "))
	return out


# --- the one numeric reader in Genesis that did not check its type ---
#
# SectionValidator._number, FarmModule._number and the two tools' _bounded all
# ask typeof() before converting. This asked nothing, and float() on a value
# out of JSON throws for null, an object and a list. The throw abandoned the
# rest of validate(), so no error was ever appended and `ok` came back TRUE
# for a room 0 m across: the validator approving a spec it had not read. The
# type check two hundred lines down this same file, in _things_said(), is the
# convention this function missed - a file does not inherit a project's rules
# by sitting in its folder (trap 18), and neither does a function.
#
# It refuses rather than clamping now, in both senses: NAN goes back instead
# of a clamped value, and nothing is accepted on the strength of it. The old
# clampf() was inert only because an error was appended beside it, which is a
# guarantee held by two lines agreeing rather than by one.
func _side(room: Dictionary, field: String, n: int, errors: Array) -> float:
	if not room.has(field):
		errors.append("room %d: no %s, and it must be %.0f to %.0f m" % [n, field, MIN_SIDE, MAX_SIDE])
		return NAN
	var value := Readback.measure(room, field)
	if is_nan(value):
		errors.append("room %d: %s must be a number, %.0f to %.0f m" % [n, field, MIN_SIDE, MAX_SIDE])
		return NAN
	if value < MIN_SIDE or value > MAX_SIDE:
		errors.append("room %d: %s is %.0f m, and must be %.0f to %.0f m" % [n, field, value, MIN_SIDE, MAX_SIDE])
		return NAN
	return value


# --- can this dungeon work at all? ---

# Step 3: a room nobody can walk to is not a room. This is checked on the
# door graph alone, before anything is placed, so a sealed room costs
# nothing to refuse.
func pre_check(content: Dictionary, record: Dictionary) -> Dictionary:
	var rooms: Array = content["rooms"]
	var doors: Array = content["doors"]
	var reach := _reachable(rooms.size(), doors)
	var unreachable: Array = reach["unreachable"]

	record["reachability"] = {
		"reached": reach["reached"],
		"room_count": rooms.size(),
		"loops": doors.size() - rooms.size() + 1,
	}

	if unreachable.is_empty():
		return {"ok": true, "category": "", "reasons": [], "content": content}

	var names := PackedStringArray()
	for i in unreachable:
		names.append("%s (room %d)" % [str(rooms[i]["name"]), int(i) + 1])
	return {
		"ok": false,
		"category": "FAILED_UNREACHABLE",
		"reasons": [
			"no way to walk from the entrance to %s" % ", ".join(names),
			"every room must be reachable from room 1 by following doors",
		],
		"content": content,
	}


# Breadth-first from room 1. Returns how many rooms were reached, how far
# each one is in doors, and which were never reached.
func _reachable(count: int, doors: Array) -> Dictionary:
	var links := {}
	for i in count:
		links[i] = []
	for door in doors:
		var d: Vector2i = door
		links[d.x].append(d.y)
		links[d.y].append(d.x)

	var depth := {0: 0}
	var queue: Array = [0]
	while not queue.is_empty():
		var at: int = queue.pop_front()
		for nxt in links[at]:
			if not depth.has(nxt):
				depth[nxt] = int(depth[at]) + 1
				queue.append(nxt)

	var unreachable: Array = []
	for i in count:
		if not depth.has(i):
			unreachable.append(i)
	return {"reached": depth.size(), "depth": depth, "unreachable": unreachable, "links": links}


# --- where everything goes ---

# Step 4: walk the door graph from the entrance, giving each room the nearest
# free slot to the room that admitted it. Deterministic: the same design
# always produces the same dungeon.
func solve(content: Dictionary) -> Dictionary:
	var rooms: Array = content["rooms"]
	var doors: Array = content["doors"]

	var pitch := 0.0
	for room in rooms:
		pitch = maxf(pitch, maxf(float(room["width"]), float(room["depth"])))
	pitch += GAP

	var links: Dictionary = _reachable(rooms.size(), doors)["links"]
	var slots := {0: Vector2i.ZERO}
	var taken := {Vector2i.ZERO: true}
	var queue: Array = [0]
	var failed: Array = []
	var furthest_ring := 0

	while not queue.is_empty():
		var at: int = queue.pop_front()
		var here: Vector2i = slots[at]
		for nxt in links[at]:
			if slots.has(nxt):
				continue
			var found := false
			for radius in range(1, MAX_RING + 1):
				for offset in _ring(radius):
					var step: Vector2i = offset
					var candidate := here + step
					if taken.has(candidate):
						continue
					slots[nxt] = candidate
					taken[candidate] = true
					queue.append(nxt)
					furthest_ring = maxi(furthest_ring, radius)
					found = true
					break
				if found:
					break
			if not found:
				failed.append(nxt)

	var ok := slots.size() == rooms.size()
	var out := {
		"ok": ok,
		"category": "FAILED_PLACEMENT",
		"reasons": [],
		"layout": {"rooms": rooms, "doors": doors, "pitch": pitch, "slots": slots,
			"things": content.get("things", [])},
		"placement": {
			"pitch": pitch,
			"placed": slots.size(),
			"room_count": rooms.size(),
			"furthest_ring": furthest_ring,
			"failed": failed,
		},
	}
	if ok:
		out["category"] = ""
	else:
		var names := PackedStringArray()
		for i in failed:
			names.append("%s (room %d)" % [str(rooms[int(i)]["name"]), int(i) + 1])
		out["reasons"] = [
			"no space left for %s" % ", ".join(names),
			"each room is placed near the room it has a door from, within %d rings of it" % MAX_RING,
		]
	return out


# Every slot exactly `radius` rings out from a room, the ones straight off a
# wall before the corner ones, so rooms sit beside their neighbour where they
# can and fan out when they must.
func _ring(radius: int) -> Array:
	var out: Array = []
	for manhattan in range(radius, radius * 2 + 1):
		for du in range(-radius, radius + 1):
			for dv in range(-radius, radius + 1):
				if maxi(absi(du), absi(dv)) != radius:
					continue
				if absi(du) + absi(dv) != manhattan:
					continue
				out.append(Vector2i(du, dv))
	return out


func solve_record(result: Dictionary) -> Dictionary:
	return {"placement": result["placement"]}


# What the AI is told when the rooms would not fit. Plain facts Godot
# measured, and the one thing the AI can actually change.
func correction_feedback(result: Dictionary) -> String:
	var placement: Dictionary = result["placement"]
	var layout: Dictionary = result["layout"]
	var rooms: Array = layout["rooms"]
	var doors: Array = layout["doors"]

	var door_count := {}
	for i in rooms.size():
		door_count[i] = 0
	for door in doors:
		var d: Vector2i = door
		door_count[d.x] = int(door_count[d.x]) + 1
		door_count[d.y] = int(door_count[d.y]) + 1

	var busiest := 0
	for i in rooms.size():
		if int(door_count[i]) > int(door_count[busiest]):
			busiest = i

	var lines := PackedStringArray()
	lines.append("Godot tried to place your dungeon and could not fit every room.")
	lines.append("")
	lines.append("It placed %d of %d rooms. Each room goes in a square slot %.0f m across, next to the room it has a door from, and it may be moved up to %d slots away to find space." % [
		int(placement["placed"]), int(placement["room_count"]), float(placement["pitch"]), MAX_RING])
	var failed: Array = placement["failed"]
	var names := PackedStringArray()
	for i in failed:
		names.append("%s (room %d)" % [str(rooms[int(i)]["name"]), int(i) + 1])
	lines.append("There was no slot left for %s." % ", ".join(names))
	lines.append("")
	lines.append("Your busiest room is %s (room %d), with %d doors. A room with many doors crowds every room around it." % [
		str(rooms[busiest]["name"]), busiest + 1, int(door_count[busiest])])
	lines.append("The slot size comes from your largest room, %.0f m, so one big room makes every slot big." % (float(placement["pitch"]) - GAP))
	lines.append("")
	lines.append("Revise the design so it fits: spread the doors out so no one room carries most of them, or use fewer rooms. Keep everything else about your dungeon that you can. Return ONLY the complete JSON command, in the same format as before.")
	return "\n".join(lines)


# --- the solved dungeon ---

# Step 5: the dungeon must fit, and no corridor may pass through a room it
# does not serve. The second of those cannot happen by construction, so it is
# a guard against a mistake here, not a gate on the AI.
func post_check(layout: Dictionary) -> Dictionary:
	var rects := _rects(layout)
	var bounds := _bounds(layout, rects)
	var across: Vector2 = bounds["max"] - bounds["min"]

	var crossings: Array = []
	for door in layout["doors"]:
		var d: Vector2i = door
		for leg in _corridor(layout, d.x, d.y):
			for i in rects.size():
				if i == d.x or i == d.y:
					continue
				if _overlaps(leg, rects[i]):
					crossings.append("%s to %s passes through %s" % [
						str(layout["rooms"][d.x]["name"]),
						str(layout["rooms"][d.y]["name"]),
						str(layout["rooms"][i]["name"])])
					break

	# 005: what a body can actually reach through what will be built. Kept
	# beside the logical reachability pre_check already did, never merged
	# with it: when the two disagree, the disagreement is the finding.
	var walk := walkable(layout)

	var record := {
		"extent": {
			"width": across.x,
			"depth": across.y,
			"limit": MAX_EXTENT,
		},
		"crossings": crossings.size(),
		"walkable": walk,
	}

	if not crossings.is_empty():
		return {"ok": false, "category": "FAILED_CORRIDOR", "reasons": crossings, "record": record}
	if not (walk["unreachable"] as Array).is_empty():
		var why: Array = [
			"every room has a door to it, but a person %.1f m across cannot get to %s" % [
				BODY, ", ".join(walk["unreachable"])],
		]
		for b in walk["blocked_doors"]:
			why.append(str(b))
		return {"ok": false, "category": "FAILED_UNWALKABLE", "reasons": why, "record": record}
	if across.x > MAX_EXTENT or across.y > MAX_EXTENT:
		return {
			"ok": false,
			"category": "FAILED_TOO_BIG",
			"reasons": [
				"this dungeon would be %.0f m by %.0f m, and the limit is %.0f m" % [across.x, across.y, MAX_EXTENT],
				"slots are %.0f m across because the largest room is %.0f m" % [float(layout["pitch"]), float(layout["pitch"]) - GAP],
				"use smaller rooms, fewer rooms, or a less strung-out chain of doors",
			],
			"record": record,
		}
	return {"ok": true, "category": "", "reasons": [], "record": record}


# --- 005: logical and physical reachability, measured apart ---
# pre_check already refuses a dungeon with a room no door leads to. That is
# LOGICAL reachability: a property of the graph the AI proposed.
#
# It says nothing about whether a person could actually get there. The walls
# are built by cutting each doorway out of a side, and if that cut ever
# misses - as the hub/chain wording once did - a room ends up logically
# connected and physically sealed. Every check Genesis had would pass and
# the dungeon would be unplayable.
#
# So this walks the corridors through the geometry as built, with a body of
# a real width, and reports what can actually be reached. The two numbers
# are kept apart on purpose: when they disagree, the disagreement is the
# finding.

const BODY := 1.6                # metres across, about a person
const STEP := 0.5                # how finely a corridor is walked


# Can a body this wide get from room to room through what was built?
# Returns reached rooms, and every door it could not get through.
func walkable(layout: Dictionary) -> Dictionary:
	var rooms: Array = layout["rooms"]
	var rects := _rects(layout)

	# The floor: rooms and corridors. Anywhere else is not somewhere to walk.
	var floors: Array = []
	for r in rects:
		floors.append(r)
	var openings := {}
	for i in rooms.size():
		openings[i] = []
	for door in layout["doors"]:
		var d: Vector2i = door
		var legs := _corridor(layout, d.x, d.y)
		for leg in legs:
			floors.append(leg)
		if not legs.is_empty():
			openings[d.x].append(legs[0])
			openings[d.y].append(legs[legs.size() - 1])

	# The walls, exactly the ones build() puts up.
	var walls: Array = []
	for i in rooms.size():
		for w in _wall_rects(rects[i], openings[i]):
			walls.append(w)

	# Walk each door's corridor and see whether a body fits the whole way.
	var passable := {}
	var blocked: Array = []
	for door in layout["doors"]:
		var d: Vector2i = door
		# 018: a door somebody has shut is not a way through. The same
		# function answers both "is this doorway wide enough" and "is it
		# open", so routing, the walkability metric and the character's own
		# plan cannot disagree about it.
		if is_shut(layout, d.x, d.y):
			blocked.append(d)
			continue
		var path := _corridor_path(layout, d.x, d.y)
		var stuck := _first_blockage(path, floors, walls)
		if stuck.is_empty():
			passable[d] = true
		else:
			blocked.append("%s to %s: %s" % [
				str(rooms[d.x]["name"]), str(rooms[d.y]["name"]), str(stuck["why"])])

	# Reachability over the doors a body can actually use.
	var links := {}
	for i in rooms.size():
		links[i] = []
	for door in passable:
		var d: Vector2i = door
		links[d.x].append(d.y)
		links[d.y].append(d.x)
	var seen := {0: true}
	var queue: Array = [0]
	while not queue.is_empty():
		var at: int = queue.pop_front()
		for nxt in links[at]:
			if not seen.has(nxt):
				seen[nxt] = true
				queue.append(nxt)

	var unreachable: Array = []
	for i in rooms.size():
		if not seen.has(i):
			unreachable.append(str(rooms[i]["name"]))

	return {
		"reached": seen.size(),
		"room_count": rooms.size(),
		"unreachable": unreachable,
		"blocked_doors": blocked,
		"body": BODY,
	}


# Where the first blockage is on this path, or nothing. A point is walkable
# when it is on a floor and no wall is within half a body of it.
func _first_blockage(path: Array, floors: Array, walls: Array) -> Dictionary:
	var half := BODY * 0.5
	for point in path:
		var p: Vector2 = point
		var on_floor := false
		for f in floors:
			if (f as Rect2).has_point(p):
				on_floor = true
				break
		if not on_floor:
			return {"why": "the way out is not floored at (%.0f, %.0f)" % [p.x, p.y]}
		for w in walls:
			if (w as Rect2).grow(half).has_point(p):
				return {"why": "a wall blocks the doorway at (%.0f, %.0f)" % [p.x, p.y]}
	return {}


# The corridor as points to walk, from one room's middle to the other's.
func _corridor_path(layout: Dictionary, a: int, b: int) -> Array:
	var pitch := float(layout["pitch"])
	var slots: Dictionary = layout["slots"]
	var sa: Vector2i = slots[a]
	var sb: Vector2i = slots[b]
	var from := Vector2(sa.x, sa.y) * pitch
	var to := Vector2(sb.x, sb.y) * pitch

	var corners: Array = [from]
	if absi(sa.x - sb.x) + absi(sa.y - sb.y) != 1:
		var za := (float(sa.y) + (0.5 if sb.y > sa.y else -0.5)) * pitch
		var zb := (float(sb.y) + (0.5 if sa.y > sb.y else -0.5)) * pitch
		var xb := (float(sb.x) + (0.5 if sa.x > sb.x else -0.5)) * pitch
		corners.append(Vector2(from.x, za))
		corners.append(Vector2(xb, za))
		corners.append(Vector2(xb, zb))
		corners.append(Vector2(to.x, zb))
	corners.append(to)

	var out: Array = []
	for i in corners.size() - 1:
		var p0: Vector2 = corners[i]
		var p1: Vector2 = corners[i + 1]
		var span := p0.distance_to(p1)
		var steps := maxi(1, int(span / STEP))
		for k in steps + 1:
			out.append(p0.lerp(p1, float(k) / float(steps)))
	return out


# --- measurements ---

func measure(layout: Dictionary) -> Dictionary:
	var rooms: Array = layout["rooms"]
	var doors: Array = layout["doors"]
	var rects := _rects(layout)

	var floor_area := 0.0
	var largest := 0.0
	var largest_name := ""
	for i in rooms.size():
		var area := float(rooms[i]["width"]) * float(rooms[i]["depth"])
		floor_area += area
		if area > largest:
			largest = area
			largest_name = str(rooms[i]["name"])

	var corridor_area := 0.0
	var corridor_length := 0.0
	for door in doors:
		var d: Vector2i = door
		for leg in _corridor(layout, d.x, d.y):
			corridor_area += leg.size.x * leg.size.y
			corridor_length += maxf(leg.size.x, leg.size.y) - CORRIDOR

	var reach := _reachable(rooms.size(), doors)
	var depth: Dictionary = reach["depth"]
	var deepest := 0
	var deepest_name := ""
	for i in depth:
		if int(depth[i]) > deepest:
			deepest = int(depth[i])
			deepest_name = str(rooms[int(i)]["name"])

	var links: Dictionary = reach["links"]
	var dead_ends := 0
	for i in rooms.size():
		if (links[i] as Array).size() == 1:
			dead_ends += 1

	var bounds := _bounds(layout, rects)
	var across: Vector2 = bounds["max"] - bounds["min"]

	var walk := walkable(layout)
	return {
		"room_count": rooms.size(),
		"door_count": doors.size(),
		"walk_reached": int(walk["reached"]),
		"walk_blocked": (walk["blocked_doors"] as Array).size(),
		"floor_area": floor_area,
		"corridor_area": corridor_area,
		"corridor_length": corridor_length,
		"largest_room": largest_name,
		"largest_room_area": largest,
		"deepest": deepest,
		"deepest_room": deepest_name,
		"dead_ends": dead_ends,
		"loops": doors.size() - rooms.size() + 1,
		"pitch": float(layout["pitch"]),
		"width": across.x,
		"depth": across.y,
	}


# --- geometry, shared by the checks, the measurements and the building ---

# Each room's footprint in metres, centred in its slot.
func _rects(layout: Dictionary) -> Array:
	var pitch := float(layout["pitch"])
	var slots: Dictionary = layout["slots"]
	var out: Array = []
	for i in (layout["rooms"] as Array).size():
		var room: Dictionary = layout["rooms"][i]
		var slot: Vector2i = slots[i]
		var size := Vector2(float(room["width"]), float(room["depth"]))
		out.append(Rect2(Vector2(slot.x, slot.y) * pitch - size * 0.5, size))
	return out


func _bounds(layout: Dictionary, rects: Array) -> Dictionary:
	var low := Vector2(INF, INF)
	var high := Vector2(-INF, -INF)
	for rect in rects:
		var r: Rect2 = rect
		low = low.min(r.position)
		high = high.max(r.position + r.size)
	for door in layout["doors"]:
		var d: Vector2i = door
		for leg in _corridor(layout, d.x, d.y):
			low = low.min(leg.position)
			high = high.max(leg.position + leg.size)
	return {"min": low, "max": high}


# The corridor between two rooms, as rectangles in metres.
#
# Neighbouring slots get one straight run: the lane between them is empty by
# construction, so nothing can be in the way. Rooms further apart are joined
# through the lanes at half-slot coordinates, where no room ever is, so the
# route leaves its own slot, stays in empty ground the whole way, and enters
# the other slot.
func _corridor(layout: Dictionary, a: int, b: int) -> Array:
	var pitch := float(layout["pitch"])
	var slots: Dictionary = layout["slots"]
	var sa: Vector2i = slots[a]
	var sb: Vector2i = slots[b]
	var from := Vector2(sa.x, sa.y) * pitch
	var to := Vector2(sb.x, sb.y) * pitch

	var points: Array = []
	if absi(sa.x - sb.x) + absi(sa.y - sb.y) == 1:
		points = [from, to]
	else:
		var za := (float(sa.y) + (0.5 if sb.y > sa.y else -0.5)) * pitch
		var zb := (float(sb.y) + (0.5 if sa.y > sb.y else -0.5)) * pitch
		var xb := (float(sb.x) + (0.5 if sa.x > sb.x else -0.5)) * pitch
		points = [
			from,
			Vector2(from.x, za),
			Vector2(xb, za),
			Vector2(xb, zb),
			Vector2(to.x, zb),
			to,
		]

	var legs: Array = []
	for i in points.size() - 1:
		var leg := _leg(points[i], points[i + 1])
		if leg.size.x > 0.0 and leg.size.y > 0.0:
			legs.append(leg)
	return legs


func _leg(from: Vector2, to: Vector2) -> Rect2:
	if from.is_equal_approx(to):
		return Rect2()
	var half := CORRIDOR * 0.5
	var low := from.min(to) - Vector2(half, half)
	var high := from.max(to) + Vector2(half, half)
	return Rect2(low, high - low)


func _overlaps(a: Rect2, b: Rect2) -> bool:
	return a.intersects(b)


# --- building it ---

# --- 003: the dungeon as a container ---

# The ground the dungeon stands on. Normally that is the rooms and corridors
# with a lane of rock around them, but a plan may have asked this dungeon to
# contain another world, and then the rock is pushed out to make room. The
# rooms never move: the dungeon the player described is the one they get.
func _ground(layout: Dictionary) -> Array:
	var bounds := _bounds(layout, _rects(layout))
	return grown(bounds["min"] - Vector2(GAP, GAP), bounds["max"] + Vector2(GAP, GAP), layout)


func extent(layout: Dictionary) -> Vector2:
	var ground := _ground(layout)
	return (ground[1] as Vector2) - (ground[0] as Vector2)


# --- 018: doors that can be shut ---
#
# A doorway was a permanent gap in a wall. Nothing in the world could change
# while a character was crossing it, so nothing could ever interfere with an
# errand - and an errand that cannot be interfered with proves very little.
#
# Shut doors live in the layout, so every question about getting about reads
# the same list: walkable(), route(), the metrics panel and the body itself.
# Shut is a property of the WORLD, not of anybody's plan, which is why a
# character that set off through an open door and finds it closed stops rather
# than re-planning around a door it remembers.
static func door_key(a: int, b: int) -> Vector2i:
	return Vector2i(mini(a, b), maxi(a, b))


static func is_shut(layout: Dictionary, a: int, b: int) -> bool:
	var closed = layout.get("shut", [])
	if typeof(closed) != TYPE_ARRAY:
		return false
	return (closed as Array).has(door_key(a, b))


# Shut or open one door, in the layout. Returns whether anything changed, so a
# command that shuts a door already shut can say so rather than claiming work.
static func set_shut(layout: Dictionary, a: int, b: int, closed: bool) -> bool:
	if not layout.has("shut"):
		layout["shut"] = []
	var list: Array = layout["shut"]
	var key := door_key(a, b)
	if closed and not list.has(key):
		list.append(key)
		return true
	if not closed and list.has(key):
		list.erase(key)
		return true
	return false


# Where a door stands, in this node's own coordinates: the middle of the
# corridor between two rooms. A shut door is built here, and it is real -
# a body walks into it rather than through it.
func door_spot(layout: Dictionary, a: int, b: int) -> Vector2:
	var path := _corridor_path(layout, a, b)
	if path.is_empty():
		return Vector2.ZERO
	return path[path.size() / 2]


# --- 014: a way through, for something that has to walk it ---
#
# Routing is over the door graph, not a navigation mesh, and over the doors
# walkable() says a body can PHYSICALLY pass - so a route can never be planned
# through a doorway 005 already proved is sealed. The measurement built then
# is the thing a character plans with now.
#
# Waypoints come back in this node's own coordinates: the corridor legs
# between each pair of rooms, then the centre of the room being entered.
func route(layout: Dictionary, from_room: int, to_room: int) -> Array:
	var rooms: Array = layout["rooms"]
	if from_room < 0 or to_room < 0 or from_room >= rooms.size() or to_room >= rooms.size():
		return []
	var rects := _rects(layout)
	if from_room == to_room:
		var here: Rect2 = rects[to_room]
		return [here.position + here.size * 0.5]

	var walk: Dictionary = walkable(layout)
	var sealed := {}
	for d in (walk["blocked_doors"] as Array):
		var b: Vector2i = d
		sealed[Vector2i(mini(b.x, b.y), maxi(b.x, b.y))] = true

	var near := {}
	for i in rooms.size():
		near[i] = []
	for door in layout["doors"]:
		var e: Vector2i = door
		if sealed.has(Vector2i(mini(e.x, e.y), maxi(e.x, e.y))):
			continue
		near[e.x].append(e.y)
		near[e.y].append(e.x)

	var came := {from_room: -1}
	var queue := [from_room]
	while not queue.is_empty():
		var at: int = queue.pop_front()
		if at == to_room:
			break
		for n in near[at]:
			if not came.has(n):
				came[n] = at
				queue.append(n)
	if not came.has(to_room):
		return []

	var order: Array = []
	var step := to_room
	while step != -1:
		order.push_front(step)
		step = int(came[step])

	var marks: Array = []
	for i in range(1, order.size()):
		for p in _corridor_path(layout, int(order[i - 1]), int(order[i])):
			marks.append(p)
		var rect: Rect2 = rects[int(order[i])]
		marks.append(rect.position + rect.size * 0.5)
	return marks


# Which room a point is standing in, counting from 0, or -1 for none. This is
# how arrival is decided, and it is decided HERE, by the thing that owns the
# geometry, rather than by the character that was sent.
func room_of(layout: Dictionary, point: Vector2) -> int:
	var rects := _rects(layout)
	for i in rects.size():
		if (rects[i] as Rect2).has_point(point):
			return i
	return -1


func build(root: Node3D, layout: Dictionary) -> Dictionary:
	var rooms: Array = layout["rooms"]
	var rects := _rects(layout)
	var ground := _ground(layout)
	var low: Vector2 = ground[0]
	var high: Vector2 = ground[1]

	_slab(root, "Ground", low, high, PAD_HEIGHT, PAD_COLOUR)

	# Corridors first, so a room floor always sits on top where they meet.
	var openings := {}
	for i in rooms.size():
		openings[i] = []
	var n := 0
	for door in layout["doors"]:
		var d: Vector2i = door
		n += 1
		var legs := _corridor(layout, d.x, d.y)
		for k in legs.size():
			var leg: Rect2 = legs[k]
			_slab(root, "Corridor_%d_%d" % [n, k + 1], leg.position, leg.position + leg.size,
				CORRIDOR_HEIGHT, CORRIDOR_COLOUR)
		if not legs.is_empty():
			openings[d.x].append(legs[0])
			openings[d.y].append(legs[legs.size() - 1])

	for i in rooms.size():
		var rect: Rect2 = rects[i]
		var colour := ENTRANCE_COLOUR if i == 0 else ROOM_COLOUR
		_slab(root, "Room_%d_%s" % [i + 1, str(rooms[i]["name"])],
			rect.position, rect.position + rect.size, ROOM_HEIGHT, colour)
		_walls(root, i + 1, rect, openings[i])

	# 018: a shut door is a slab across the corridor, with collision, so it
	# stops a body the way a wall does rather than by rule.
	for door in layout["doors"]:
		var d: Vector2i = door
		if not is_shut(layout, d.x, d.y):
			continue
		var at := door_spot(layout, d.x, d.y)
		var legs := _corridor(layout, d.x, d.y)
		var across := true
		if not legs.is_empty():
			var leg: Rect2 = legs[legs.size() / 2]
			across = leg.size.x >= leg.size.y
		_door_slab(root, "%d_%d" % [d.x + 1, d.y + 1], at, across)

	# 015: a thing stands on the floor of the room it starts in, slightly off
	# centre so it is not underneath whoever walks in. It is a real body with
	# collision, because a thing you can walk through is a picture of a thing.
	var placed: Array = []
	for i in (layout.get("things", []) as Array).size():
		var thing: Dictionary = (layout["things"] as Array)[i]
		var room: Rect2 = rects[int(thing["in"])]
		var spot := room.position + room.size * 0.5 + Vector2(room.size.x * 0.22, 0.0)
		var node := _thing(root, str(thing["name"]), spot)
		placed.append({"name": str(thing["name"]), "node": node, "from": int(thing["in"])})

	# 008: where a body comes in. The entrance is room 1 by definition, and a
	# body starts at its centre, standing on its floor. Reported in this
	# node's own coordinates, as the drivable surface is, so a plan that moves
	# the dungeon moves where the player appears with it.
	var entrance: Rect2 = rects[0]
	return {
		"bounds_min": low,
		"bounds_max": high,
		"room_count": rooms.size(),
		"door_count": (layout["doors"] as Array).size(),
		"standable": {
			"node": root,
			# 014: what a character needs in order to be sent anywhere. The
			# layout travels with the surface so routing and arrival are
			# answered by this module, not worked out again elsewhere.
			"layout": layout,
			"rooms": rooms,
			"command": command(),
			"entrance": Vector3(
				entrance.position.x + entrance.size.x * 0.5,
				ROOM_HEIGHT + 1.0,
				entrance.position.y + entrance.size.y * 0.5),
			"heading": 0.0,
			"things": placed,
		},
		# 015: the things, as they stand in the world. A delivery is checked by
		# reading a thing's POSITION out of the scene, never by asking whoever
		# carried it - the same wall as a character not reporting its own
		# arrival.
		"things": placed,
	}


# Four walls per room, each broken where a corridor meets it. A wall is built
# as the pieces left over after the openings on that side are cut out, so a
# doorway is a real gap rather than a wall drawn over a corridor.
func _walls(root: Node3D, number: int, rect: Rect2, openings: Array) -> void:
	var sides := [
		{"name": "north", "axis": "x", "fixed": rect.position.y, "from": rect.position.x, "to": rect.position.x + rect.size.x},
		{"name": "south", "axis": "x", "fixed": rect.position.y + rect.size.y, "from": rect.position.x, "to": rect.position.x + rect.size.x},
		{"name": "west", "axis": "y", "fixed": rect.position.x, "from": rect.position.y, "to": rect.position.y + rect.size.y},
		{"name": "east", "axis": "y", "fixed": rect.position.x + rect.size.x, "from": rect.position.y, "to": rect.position.y + rect.size.y},
	]

	for side in sides:
		var cuts: Array = []
		for opening in openings:
			var o: Rect2 = opening
			if not _touches(o, rect, str(side["name"])):
				continue
			if str(side["axis"]) == "x":
				cuts.append(Vector2(o.position.x, o.position.x + o.size.x))
			else:
				cuts.append(Vector2(o.position.y, o.position.y + o.size.y))
		cuts.sort_custom(func(a: Vector2, b: Vector2) -> bool: return a.x < b.x)

		var at := float(side["from"])
		var stop := float(side["to"])
		var piece := 0
		for cut in cuts:
			var c: Vector2 = cut
			if c.x > at:
				piece += 1
				_wall_piece(root, number, str(side["name"]), piece, side, at, minf(c.x, stop))
			at = maxf(at, c.y)
		if at < stop:
			piece += 1
			_wall_piece(root, number, str(side["name"]), piece, side, at, stop)


# Does this corridor leg cross that side of the room? A leg crosses a side
# when it spans the line that side sits on, and overlaps the room along it.
func _touches(leg: Rect2, rect: Rect2, side: String) -> bool:
	var leg_low := leg.position
	var leg_high := leg.position + leg.size
	var room_low := rect.position
	var room_high := rect.position + rect.size
	var spans_x := leg_low.x < room_high.x and leg_high.x > room_low.x
	var spans_z := leg_low.y < room_high.y and leg_high.y > room_low.y
	match side:
		"north":
			return spans_x and leg_low.y <= room_low.y and leg_high.y > room_low.y
		"south":
			return spans_x and leg_low.y < room_high.y and leg_high.y >= room_high.y
		"west":
			return spans_z and leg_low.x <= room_low.x and leg_high.x > room_low.x
		"east":
			return spans_z and leg_low.x < room_high.x and leg_high.x >= room_high.x
	return false


# The walls of one room as flat rectangles, doorways already cut out. The
# builder raises these into boxes and the walker tests against them, so what
# is checked is exactly what is built.
func _wall_rects(rect: Rect2, openings: Array) -> Array:
	var sides := [
		{"name": "north", "axis": "x", "fixed": rect.position.y, "from": rect.position.x, "to": rect.position.x + rect.size.x},
		{"name": "south", "axis": "x", "fixed": rect.position.y + rect.size.y, "from": rect.position.x, "to": rect.position.x + rect.size.x},
		{"name": "west", "axis": "y", "fixed": rect.position.x, "from": rect.position.y, "to": rect.position.y + rect.size.y},
		{"name": "east", "axis": "y", "fixed": rect.position.x + rect.size.x, "from": rect.position.y, "to": rect.position.y + rect.size.y},
	]
	var out: Array = []
	for side in sides:
		var cuts: Array = []
		for opening in openings:
			var o: Rect2 = opening
			if not _touches(o, rect, str(side["name"])):
				continue
			if str(side["axis"]) == "x":
				cuts.append(Vector2(o.position.x, o.position.x + o.size.x))
			else:
				cuts.append(Vector2(o.position.y, o.position.y + o.size.y))
		cuts.sort_custom(func(a: Vector2, b: Vector2) -> bool: return a.x < b.x)

		var at := float(side["from"])
		var stop := float(side["to"])
		for cut in cuts:
			var c: Vector2 = cut
			if c.x > at:
				out.append(_flat(side, at, minf(c.x, stop)))
			at = maxf(at, c.y)
		if at < stop:
			out.append(_flat(side, at, stop))
	return out


func _flat(spec: Dictionary, from: float, to: float) -> Rect2:
	var fixed := float(spec["fixed"])
	var half := WALL_THICK * 0.5
	if str(spec["axis"]) == "x":
		return Rect2(from, fixed - half, to - from, WALL_THICK)
	return Rect2(fixed - half, from, WALL_THICK, to - from)


func _wall_piece(root: Node3D, number: int, side: String, piece: int, spec: Dictionary, from: float, to: float) -> void:
	if to - from < 0.1:
		return
	var wall := MeshInstance3D.new()
	var box := BoxMesh.new()
	var fixed := float(spec["fixed"])
	if str(spec["axis"]) == "x":
		box.size = Vector3(to - from, WALL_HEIGHT, WALL_THICK)
		wall.position = Vector3((from + to) * 0.5, ROOM_HEIGHT + WALL_HEIGHT * 0.5, fixed)
	else:
		box.size = Vector3(WALL_THICK, WALL_HEIGHT, to - from)
		wall.position = Vector3(fixed, ROOM_HEIGHT + WALL_HEIGHT * 0.5, (from + to) * 0.5)
	wall.mesh = box
	wall.name = "Wall_%d_%s_%d" % [number, side, piece]
	wall.material_override = _material(WALL_COLOUR)
	_solid(wall, box.size)
	root.add_child(wall)


# One shut door: a slab filling the corridor, standing on its floor.
func _door_slab(root: Node3D, label: String, at: Vector2, across: bool) -> void:
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.6, WALL_HEIGHT, CORRIDOR + 1.0) if across else Vector3(CORRIDOR + 1.0, WALL_HEIGHT, 0.6)
	mesh.mesh = box
	mesh.name = "Door_" + label
	mesh.material_override = _material(Color(0.62, 0.26, 0.20))
	mesh.position = Vector3(at.x, CORRIDOR_HEIGHT + WALL_HEIGHT * 0.5, at.y)
	_solid(mesh, box.size)
	root.add_child(mesh)


# One thing: a small box with collision, sitting on the room floor.
func _thing(root: Node3D, label: String, at: Vector2) -> Node3D:
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(THING_SIZE, THING_SIZE, THING_SIZE)
	mesh.mesh = box
	mesh.name = "Thing_" + label
	mesh.material_override = _material(THING_COLOUR)
	mesh.position = Vector3(at.x, ROOM_HEIGHT + THING_SIZE * 0.5, at.y)
	_solid(mesh, box.size)
	root.add_child(mesh)
	return mesh


func _slab(root: Node3D, name_for: String, from: Vector2, to: Vector2, height: float, colour: Color) -> void:
	var slab := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(to.x - from.x, height, to.y - from.y)
	slab.mesh = box
	slab.name = name_for
	slab.material_override = _material(colour)
	slab.position = Vector3((from.x + to.x) * 0.5, height * 0.5, (from.y + to.y) * 0.5)
	_solid(slab, box.size)
	root.add_child(slab)


# --- 007: the dungeon becomes solid ---
# Until now every floor and wall was a bare MeshInstance3D: something to look
# at, nothing to stand on. A body dropped into it fell through the world and
# walked through stone, which is why geometric reachability was the only kind
# that could be measured - there was nothing to collide with.
#
# Collision is taken from the SAME box size the mesh was built from, never
# re-derived, for the reason _wall_rects exists: a checker that measures
# something other than what was built is worse than no checker.
func _solid(piece: Node3D, size: Vector3) -> void:
	var body := StaticBody3D.new()
	body.name = "Solid"
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	body.add_child(shape)
	piece.add_child(body)


func _material(colour: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = colour
	m.roughness = 0.95
	return m


# "a dungeon of 5 rooms joined by 4 doors, entered through a 40 m great_hall
#  with four rooms off it"
#
# A dungeon's meaning is its shape, not its room list, so this reads out how
# the rooms are joined: which room you come in by, whether everything hangs
# off one hall, whether it is a chain, and whether there is a way back round.
# "Four rooms off the great hall" is precisely the kind of thing a player can
# ask for and not get, with the room count still correct.
func readback(parameters: Dictionary) -> String:
	var raw_rooms = parameters.get("rooms", null)
	var raw_doors = parameters.get("doors", null)
	if typeof(raw_rooms) != TYPE_ARRAY or (raw_rooms as Array).is_empty():
		return "a dungeon"

	var rooms: Array = raw_rooms
	var names := PackedStringArray()
	var sizes: Array = []
	for entry in rooms:
		if typeof(entry) != TYPE_DICTIONARY:
			names.append("a room")
			sizes.append(0.0)
			continue
		var room: Dictionary = entry
		# The AI names rooms with underscores, as the format asks. A player
		# reading the line should see "great hall", not "great_hall".
		names.append(str(room.get("name", "a room")).replace("_", " "))
		# A side that is not a number leaves the room unmeasured rather than
		# 0 m, and an unmeasured entrance is described without a size below.
		# EITHER side, not both: size_of() draws the line in the same place
		# for a farm's zones, and a room reported as "6 m" because its depth
		# happened to read is a measurement standing in for one that did not.
		var w := Readback.measure(room, "width")
		var dp := Readback.measure(room, "depth")
		sizes.append(NAN if is_nan(w) or is_nan(dp) else maxf(w, dp))

	var doors: Array = raw_doors if typeof(raw_doors) == TYPE_ARRAY else []
	var degree := {}
	for i in rooms.size():
		degree[i] = 0
	var counted := 0
	for pair in doors:
		if typeof(pair) != TYPE_ARRAY or (pair as Array).size() != 2:
			continue
		var raw_a := Readback.as_number((pair as Array)[0])
		var raw_b := Readback.as_number((pair as Array)[1])
		if is_nan(raw_a) or is_nan(raw_b):
			continue
		var a := int(raw_a) - 1
		var b := int(raw_b) - 1
		if a < 0 or b < 0 or a >= rooms.size() or b >= rooms.size() or a == b:
			continue
		degree[a] = int(degree[a]) + 1
		degree[b] = int(degree[b]) + 1
		counted += 1

	var opening := "a dungeon of %s joined by %s" % [
		Readback.count_of(rooms.size(), "room"), Readback.count_of(counted, "door")]

	var entered := ", entered through %s" % _room_said(str(names[0]), float(sizes[0]))

	# --- 031: and the rooms that are not the entrance ---
	#
	# Until 031 this line named ONE room of however many were asked for. A
	# dungeon of a hall and a vault and one of a hall and a crypt read back
	# word for word the same, and so did one whose second room was 20 m and
	# one whose second room was 33 m: measured, three fields of every room
	# after the first went unsaid. The shape clause below names a second room
	# only when one room happens to carry most of the doors, so in a chain -
	# the commonest dungeon there is - nothing after the entrance was in the
	# sentence at all.
	#
	# That is the rule in "A readback must not be silent about part of the
	# request" with a whole clause missing, and it is the same fault 016
	# found for the THINGS in a dungeon and 031 found for a corner's angle.
	# One list, one rule, one commit (TRAPS 11).
	#
	# No order and no direction is claimed for them: a readback runs before
	# anything is validated, so "beyond it" or "then" would be a statement
	# about a layout nothing has solved and, for a proposal whose doors do
	# not connect, would be false. They are enumerated and nothing more.
	# Capped like every other list in Genesis, because a line nobody reads to
	# the end cannot catch anything.
	var rest := PackedStringArray()
	for i in range(1, rooms.size()):
		rest.append(_room_said(str(names[i]), float(sizes[i])))
	var also := "" if rest.is_empty() else ", along with " + Readback.join_capped(rest)

	var hub := 0
	for i in rooms.size():
		if int(degree[i]) > int(degree[hub]):
			hub = i
	var hub_doors := int(degree[hub])
	var shape := ""

	# A chain comes first, because every room in the middle of one has two
	# doors and would otherwise look like a hub. A room with two doors is
	# not a hall with rooms off it; it is a place you walk through.
	if counted == rooms.size() - 1 and hub_doors <= 2:
		shape = ", each one leading to the next"
	elif hub_doors >= 3 and hub_doors * 2 >= counted:
		# One room carries most of the doors: "four rooms off the hall".
		var off := Readback.count_of(hub_doors, "room")
		# A comma, like every other clause in this sentence. It used to run
		# straight on from the entrance - "a 20 m great hall with four rooms
		# off it" - and since 031 the rooms come between, so it would have
		# read "...and a 10 m d with four rooms off it".
		if hub == 0:
			shape = ", with %s off it" % off
		else:
			shape = ", with %s off %s" % [off, str(names[hub])]

	var loops := counted - rooms.size() + 1
	var round_again := ""
	if loops > 0:
		round_again = ", and %s back round" % Readback.count_of(loops, "way")

	return opening + entered + also + shape + round_again + _things_said(parameters, names)


# A room as a sentence says it: its size and its name, or its name alone when
# no side of it arrived as a number.
#
# One reading, for the same reason around_of() and _wall_rects() are one: the
# entrance and every other room are described by this one function, so the
# two cannot drift into saying the same thing differently - which is exactly
# how "the room 2" came back a release after it was fixed (TRAPS 10).
#
# A size that is not a number leaves the room unmeasured rather than 0 m. A
# readback that states a number the player never gave is trap 8, and the
# refusal is the thing that names the missing field.
func _room_said(name: String, size: float) -> String:
	if is_nan(size) or size <= 0.0:
		return Readback.article(name)
	return "a %.0f m %s" % [size, name]


# --- 016: say what is IN it ---
# The readback described the rooms and the doors and said nothing at all about
# the things, so a dungeon built with a lamp in it read back exactly like one
# without. A player asked for a lamp, the AI left it out, the line did not
# mention it, and nobody noticed until the errand was refused for having
# nothing to carry.
#
# A readback that is silent about part of what was asked for cannot be used to
# catch a dropped clause, which is the only reason it exists. So the things
# are named, with the room each is in, and a dungeon with nothing in it says
# nothing - silence then means "there is nothing", which is true.
func _things_said(parameters: Dictionary, names: PackedStringArray) -> String:
	var raw = parameters.get("things", null)
	if typeof(raw) != TYPE_ARRAY or (raw as Array).is_empty():
		return ""
	var said := PackedStringArray()
	for entry in (raw as Array):
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var thing: Dictionary = entry
		var label := str(thing.get("name", "")).replace("_", " ").strip_edges()
		if label == "":
			continue
		# The readback resolves a name the same way the validator does, or it
		# quietly drops the room and says "a lamp" - which is how the first
		# version read, and is exactly the half-silence this line exists to
		# prevent.
		var where := -1
		var given = thing.get("in", null)
		if typeof(given) == TYPE_INT or typeof(given) == TYPE_FLOAT:
			where = int(given) - 1
		else:
			var wanted := str(given).to_lower().strip_edges().replace(" ", "_")
			for i in names.size():
				if str(names[i]).to_lower().replace(" ", "_") == wanted:
					where = i
					break
		if where >= 0 and where < names.size():
			said.append("%s in the %s" % [Readback.article(label), str(names[where])])
		else:
			said.append(Readback.article(label))
	if said.is_empty():
		return ""
	return ", with " + Readback.join_list(said)


func readback_short(parameters: Dictionary) -> String:
	var rooms = parameters.get("rooms", null)
	if typeof(rooms) != TYPE_ARRAY or (rooms as Array).is_empty():
		return "a dungeon"
	return "a dungeon of %s" % Readback.count_of((rooms as Array).size(), "room")


func metric_lines(metrics: Dictionary, record: Dictionary) -> Array:
	var loops := int(metrics["loops"])
	var lines: Array = [
		["ROOMS", "%d   doors %d" % [int(metrics["room_count"]), int(metrics["door_count"])]],
		["SIZE", "%.0f m by %.0f m   (slots %.0f m)" % [
			float(metrics["width"]), float(metrics["depth"]), float(metrics["pitch"])]],
		["ROOM FLOOR", "%.0f m2" % float(metrics["floor_area"])],
		["CORRIDOR", "%.0f m long, %.0f m2" % [
			float(metrics["corridor_length"]), float(metrics["corridor_area"])]],
		["LARGEST ROOM", "%s   %.0f m2" % [
			str(metrics["largest_room"]), float(metrics["largest_room_area"])]],
		["DEEPEST", "%s   %d doors from the entrance" % [
			str(metrics["deepest_room"]), int(metrics["deepest"])]],
		["DEAD ENDS", "%d" % int(metrics["dead_ends"])],
		["WALKABLE", "%d of %d rooms reachable by a body %.1f m across" % [
			int(metrics["walk_reached"]), int(metrics["room_count"]), BODY]],
		["WAYS ROUND", "none, every room is on one path" if loops <= 0 else "%d loop%s" % [loops, "" if loops == 1 else "s"]],
	]
	if record.has("placement"):
		var p: Dictionary = record["placement"]
		lines.append(["PLACED", "%d of %d rooms, furthest %d slots from its neighbour" % [
			int(p["placed"]), int(p["room_count"]), int(p["furthest_ring"])]])
	return lines


func summary(metrics: Dictionary, _report: Dictionary) -> String:
	var loops := int(metrics["loops"])
	var ways := "one way round" if loops <= 0 else "%d way%s back round" % [loops, "" if loops == 1 else "s"]
	return "CREATE_DUNGEON built %d rooms joined by %d doors, %s\n%.0f m of corridor, deepest room %d doors in\n(full measurements in the metrics panel)" % [
		int(metrics["room_count"]), int(metrics["door_count"]), ways,
		float(metrics["corridor_length"]), int(metrics["deepest"])]
