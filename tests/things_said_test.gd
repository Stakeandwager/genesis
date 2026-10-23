extends SceneTree

# 016 - the readback must name what is in the dungeon.
#
# A dungeon built with a lamp read back exactly like one without. The player
# asked for a lamp, the AI left it out, the line said nothing about it, and
# the omission only surfaced when the errand was refused for having nothing to
# carry. A readback silent about part of the request cannot catch a dropped
# clause, which is the only thing it is for.

func _initialize() -> void:
	var m := DungeonModule.new()
	var bad := 0
	var asserted := 0
	var rooms := [{"name": "store", "width": 10, "depth": 10},
		{"name": "vault", "width": 10, "depth": 10}]

	var trials := [
		[{"rooms": rooms, "doors": [[1, 2]]}, ""],
		[{"rooms": rooms, "doors": [[1, 2]], "things": [{"name": "lamp", "in": 1}]},
			", with a lamp in the store"],
		[{"rooms": rooms, "doors": [[1, 2]],
			"things": [{"name": "red_key", "in": 1}, {"name": "chest", "in": 2}]},
			", with a red key in the store and a chest in the vault"],
	]
	for t in trials:
		asserted += 1
		var said: String = m.readback(t[0])
		var tail: String = said.substr(said.length() - String(t[1]).length()) if String(t[1]) != "" else ""
		var ok: bool = said.ends_with(String(t[1])) if String(t[1]) != "" else not said.contains(", with ")
		print(("PASS  " if ok else "FAIL  ") + said)
		if not ok:
			bad += 1

	# 019: a room may be NAMED here, which is what the AI reached for first
	# and what every test had missed by always using a number.
	var by_name: Dictionary = m.validate({"rooms": [
		{"name": "store", "width": 10, "depth": 10},
		{"name": "vault", "width": 10, "depth": 10}],
		"doors": [[1, 2]], "things": [{"name": "lamp", "in": "store"}]})
	var named_ok: bool = bool(by_name["ok"]) and int((by_name["content"]["things"] as Array)[0]["in"]) == 0
	asserted += 1
	print(("PASS  " if named_ok else "FAIL  ") + "a thing may name the room it is in: " + str(by_name["errors"]))
	if not named_ok:
		bad += 1
	var named_said: String = m.readback({"rooms": rooms, "doors": [[1, 2]],
		"things": [{"name": "lamp", "in": "store"}]})
	var named_line: bool = named_said.ends_with(", with a lamp in the store")
	asserted += 1
	print(("PASS  " if named_line else "FAIL  ") + named_said)
	if not named_line:
		bad += 1

	var nowhere: Dictionary = m.validate({"rooms": rooms, "doors": [[1, 2]],
		"things": [{"name": "lamp", "in": "kitchen"}]})
	var refused: bool = not bool(nowhere["ok"]) and str(nowhere["errors"][0]).contains("store")
	asserted += 1
	print(("PASS  " if refused else "FAIL  ") + "a room that is not there is refused, naming the ones that are")
	if not refused:
		bad += 1

	# The two differ, which is the whole point.
	var without: String = m.readback({"rooms": rooms, "doors": [[1, 2]]})
	var with_one: String = m.readback({"rooms": rooms, "doors": [[1, 2]],
		"things": [{"name": "lamp", "in": 1}]})
	asserted += 1
	if without == with_one:
		print("FAIL  a dungeon with a lamp reads back the same as one without")
		bad += 1
	else:
		print("PASS  a dungeon with a lamp does not read back like one without")

	print("THINGS SAID %d assertions, failures=%d" % [asserted, bad])
	quit(bad)
