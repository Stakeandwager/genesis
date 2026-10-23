extends SceneTree

# 031 - a readback names every field its validator accepts.
#
# THE RULE, AND WHY IT IS A FACT AND NOT A WORDING
#
# A readback exists for one thing: to let a player catch Genesis building the
# wrong thing correctly. It can only do that if a request that differs from
# theirs reads back differently from theirs. So the test is not "does the
# sentence contain the word 'angle'" - that is a wording, and rephrasing the
# line would break it while dropping a field would not. The test is:
#
#   change ONE field of the request, and the sentence must change.
#
# That asserts the capability. Every line below rephrases freely and still
# passes; every line below fails the moment a field stops being said.
#
# WHY IT IS DRIVEN BY THE VALIDATORS' OWN TABLES
#
# The fields come from SectionValidator.FIELDS, which is the one place that
# says what a section type is made of, and from the rooms and things a
# dungeon's validator reads. A type that GROWS a field therefore grows a
# row here on its own, and this suite fails until the sentence grows with
# it - including a field with no alternative value listed below, which is
# reported rather than skipped. A test that enumerates its subjects by hand
# is how eight of the ten section types kept a silent field through 028,
# 029 and 030, each of which was looking straight at them (TRAPS 21).
#
# WHAT WAS A FINDING AND WHAT IS A GUARD (TRAPS 6)
#
# Measured against the code as it stood before 031, Godot 4.7.1 headless:
# eleven of these assertions FAILED and the rest passed.
#
#   FINDINGS, eight in a circuit:  a corner's angle, a hairpin's angle, a
#   banked corner's angle, a loop segment's angle, a chicane's radius, a
#   chicane's direction, a crest's grade, a dip's grade.
#   FINDINGS, three in a dungeon:  the name, width and depth of every room
#   after the first - one assertion each, and they stand for all of them.
#
#   GUARDS, and they have always passed:  every field of a farm's zones,
#   a car's spec, boots' spec, a look's spec, a dungeon's things, the
#   entrance room, a straight's length, an uphill and downhill's length and
#   grade, a banked corner's bank. Those are here so the rule cannot be
#   broken later, not because anything was wrong with them.

var bad := 0
var asserted := 0


func _initialize() -> void:
	_circuit_sections()
	_dungeon_rooms_and_things()
	_farm_zones()
	_tool_specs()
	print("SAID FIELDS %d assertions, failures=%d" % [asserted, bad])
	quit(bad)


# The sentence must change when the field changes. Nothing is asserted about
# WHAT it changes to.
func _differs(where: String, field: String, said_a: String, said_b: String) -> void:
	asserted += 1
	if said_a != said_b and said_a != "" and said_b != "":
		print("PASS  %-26s %-10s %s" % [where, field, said_a])
		return
	bad += 1
	if said_a == "" or said_b == "":
		print("FAIL  %-26s %-10s a readback said nothing at all" % [where, field])
		return
	print("FAIL  %-26s %-10s silent: both requests read back as \"%s\"" % [where, field, said_a])


# --- a circuit, every type and every field out of SectionValidator.FIELDS ---
func _circuit_sections() -> void:
	var r := RacingModule.new()

	# A sound section of each type, and a second legal value for each field.
	# Every value here is inside the validator's own bounds, so what is
	# measured is a readback describing two buildable circuits and not two
	# refusals.
	var base := {
		"straight": {"type": "straight", "length": 250.0},
		"uphill": {"type": "uphill", "length": 200.0, "grade": 8.0},
		"downhill": {"type": "downhill", "length": 200.0, "grade": 8.0},
		"crest": {"type": "crest", "length": 200.0, "grade": 8.0},
		"dip": {"type": "dip", "length": 200.0, "grade": 8.0},
		"corner": {"type": "corner", "radius": 50.0, "angle": 90.0},
		"hairpin": {"type": "hairpin", "radius": 20.0, "angle": 150.0},
		"banked_corner": {"type": "banked_corner", "radius": 60.0, "angle": 90.0, "bank": 12.0},
		"chicane": {"type": "chicane", "radius": 40.0, "offset": 12.0, "direction": "left"},
		"loop_segment": {"type": "loop_segment", "radius": 30.0, "angle": 180.0},
	}
	var other := {
		"length": 300.0, "radius": 45.0, "angle": -110.0, "grade": 14.0,
		"bank": 20.0, "offset": 18.0, "direction": "right",
	}

	for type in SectionValidator.FIELDS:
		asserted += 1
		if not base.has(type):
			bad += 1
			print("FAIL  circuit / %s has no sound example here; add one" % type)
			continue
		for field in (SectionValidator.FIELDS[type] as Array):
			asserted += 1
			if not other.has(field):
				# A field nobody thought to vary is the whole fault this
				# suite is about, so it is a failure and not a skip.
				bad += 1
				print("FAIL  circuit / %-16s %-10s no second value listed; add one" % [type, field])
				continue
			var a: Dictionary = (base[type] as Dictionary).duplicate()
			var b: Dictionary = (base[type] as Dictionary).duplicate()
			b[field] = other[field]
			_differs("circuit / " + str(type), str(field),
				r.readback({"sections": [a]}), r.readback({"sections": [b]}))

		# And the same piece twice over, which is how a player meets it: a
		# group named for one measurement was a group whose own name was
		# false of half its members.
		for field in (SectionValidator.FIELDS[type] as Array):
			if not other.has(field):
				continue
			var same: Dictionary = (base[type] as Dictionary).duplicate()
			var differing: Dictionary = (base[type] as Dictionary).duplicate()
			differing[field] = other[field]
			_differs("circuit pair / " + str(type), str(field),
				r.readback({"sections": [same, same.duplicate()]}),
				r.readback({"sections": [same, differing]}))

	# A sound circuit really is sound, or everything above is comparing two
	# descriptions of two refusals.
	var circuit := {"sections": [
		{"type": "straight", "length": 400.0},
		{"type": "corner", "radius": 50.0, "angle": 90.0},
		{"type": "straight", "length": 400.0},
		{"type": "corner", "radius": 50.0, "angle": 90.0},
		{"type": "straight", "length": 200.0},
		{"type": "corner", "radius": 50.0, "angle": 90.0},
		{"type": "straight", "length": 200.0},
		{"type": "corner", "radius": 50.0, "angle": 90.0}]}
	var checked := r.validate(circuit)
	asserted += 1
	if bool(checked["ok"]):
		print("PASS  circuit / whole        valid     %s" % r.readback(circuit))
	else:
		bad += 1
		print("FAIL  circuit / whole        the example circuit does not validate: %s" % str(checked["errors"]))

	# A measurement that did not arrive is still left out rather than
	# printed as a number nobody gave (TRAPS 8). The 031 phrases are new
	# readers of a raw request and each one has to obey it.
	for section in [{"type": "corner", "radius": 50.0},
			{"type": "corner", "radius": 50.0, "angle": null},
			{"type": "chicane", "offset": 12.0},
			{"type": "loop_segment", "radius": 30.0, "angle": {}},
			{"type": "crest", "length": 200.0, "grade": [8]}]:
		var said := r.readback({"sections": [section]})
		asserted += 1
		if said != "" and not said.contains("0 deg") and not said.contains("0%") and not said.contains("nan"):
			print("PASS  circuit / unmeasured  %-10s %s" % [str(section["type"]), said])
		else:
			bad += 1
			print("FAIL  circuit / unmeasured  %-10s invented a measurement: %s" % [str(section["type"]), said])


# --- a dungeon, every room and not only the one you come in by ---
func _dungeon_rooms_and_things() -> void:
	var d := DungeonModule.new()
	var rooms := [{"name": "hall", "width": 12.0, "depth": 12.0},
		{"name": "vault", "width": 20.0, "depth": 20.0},
		{"name": "crypt", "width": 16.0, "depth": 16.0}]
	var doors := [[1, 2], [2, 3]]
	var other := {"name": "armoury", "width": 33.0, "depth": 33.0}

	# Every room, not just the first: the entrance passed this before 031
	# and every room after it did not.
	for which in rooms.size():
		for field in ["name", "width", "depth"]:
			var a: Array = []
			var b: Array = []
			for room in rooms:
				a.append((room as Dictionary).duplicate())
				b.append((room as Dictionary).duplicate())
			(b[which] as Dictionary)[field] = other[field]
			_differs("dungeon / room %d" % (which + 1), str(field),
				d.readback({"rooms": a, "doors": doors}),
				d.readback({"rooms": b, "doors": doors}))

	# 016's rule, asserted the same way it is asserted for every other
	# field rather than by its wording.
	for field in ["name", "in"]:
		var ta := {"name": "lamp", "in": 1}
		var tb := {"name": "lamp", "in": 1}
		tb[field] = {"name": "torch", "in": 2}[field]
		_differs("dungeon / thing", str(field),
			d.readback({"rooms": rooms, "doors": doors, "things": [ta]}),
			d.readback({"rooms": rooms, "doors": doors, "things": [tb]}))

	# The door list is a request field of its own, and the count says it.
	_differs("dungeon / doors", "doors",
		d.readback({"rooms": rooms, "doors": [[1, 2], [2, 3]]}),
		d.readback({"rooms": rooms, "doors": [[1, 2], [2, 3], [1, 3]]}))

	# A room with no side that is a number is named without a size, never
	# with a 0 (TRAPS 8). It is the rest of the rooms' turn to obey it.
	var unmeasured := d.readback({"rooms": [
		{"name": "hall", "width": 12.0, "depth": 12.0},
		{"name": "vault", "width": null, "depth": 20.0}], "doors": [[1, 2]]})
	asserted += 1
	if unmeasured.contains("vault") and not unmeasured.contains("0 m vault"):
		print("PASS  dungeon / unmeasured   room      %s" % unmeasured)
	else:
		bad += 1
		print("FAIL  dungeon / unmeasured   room      %s" % unmeasured)

	# And a sound dungeon is sound, so the above is not two refusals.
	var checked := d.validate({"rooms": rooms, "doors": doors})
	asserted += 1
	if bool(checked["ok"]):
		print("PASS  dungeon / whole        valid     %s" % d.readback({"rooms": rooms, "doors": doors}))
	else:
		bad += 1
		print("FAIL  dungeon / whole        the example dungeon does not validate: %s" % str(checked["errors"]))


# --- a farm, which has passed this since it was written ---
func _farm_zones() -> void:
	var f := FarmModule.new()
	var base := {"type": "crop", "width": 40.0, "depth": 40.0, "crop": "corn"}
	var other := {"type": "pasture", "width": 60.0, "depth": 55.0, "crop": "wheat"}
	for field in base:
		var a: Dictionary = base.duplicate()
		var b: Dictionary = base.duplicate()
		b[field] = other[field]
		_differs("farm / zone", str(field),
			f.readback({"zones": [a]}), f.readback({"zones": [b]}))


# --- the tools, which have passed it too ---
func _tool_specs() -> void:
	var car := CarTool.new()
	var car_other := {"power": 1700.0, "braking": 29.0, "steering": 39.0,
		"grip": 19.0, "paint": "blue", "nickname": "bluebird"}
	_each_field("car / spec", car, car_other)

	var boots := BootsTool.new()
	var boots_other := {"push": 550.0, "weight": 110.0, "footing": 14.0,
		"turning": 11.0, "brake": 28.0, "colour": "red", "nickname": "seven league"}
	_each_field("boots / spec", boots, boots_other)

	var look := LookTool.new()
	_each_field("look / spec", look, {"face": "res://icon.svg", "skin": "pale"})


# Every field of a tool's spec comes from its own defaults(), which is the
# tool's statement of what it is made of - the same reason the circuit reads
# SectionValidator.FIELDS rather than a list kept here.
func _each_field(where: String, tool: ToolModule, other: Dictionary) -> void:
	var defaults: Dictionary = tool.defaults()
	for field in defaults:
		asserted += 1
		if not other.has(field):
			bad += 1
			print("FAIL  %-26s %-10s no second value listed; add one" % [where, field])
			continue
		var a: Dictionary = defaults.duplicate()
		var b: Dictionary = defaults.duplicate()
		b[field] = other[field]
		_differs(where, str(field), tool.readback(a), tool.readback(b))
