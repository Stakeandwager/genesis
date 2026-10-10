extends SceneTree
func _initialize() -> void:
	var m := DungeonModule.new()
	var bad := 0
	var cases := [
		["a row of five (what the player asked for)",
		 [["room_one",10,10],["room_two",10,10],["room_three",10,10],["room_four",10,10],["room_five",10,10]],
		 [[1,2],[2,3],[3,4],[4,5]], "each one leading to the next"],
		["a hall with four rooms off it",
		 [["great_hall",20,20],["a",10,10],["b",10,10],["c",10,10],["d",10,10]],
		 [[1,2],[1,3],[1,4],[1,5]], "with four rooms off it"],
		["two rooms",
		 [["entrance",10,10],["vault",10,10]], [[1,2]], "each one leading to the next"],
		["a hall part way along a chain",
		 [["entrance",10,10],["hall",20,20],["a",10,10],["b",10,10],["c",10,10]],
		 [[1,2],[2,3],[2,4],[2,5]], "with four rooms off hall"],
	]
	for c in cases:
		var rooms: Array = []
		for r in c[1]:
			rooms.append({"name": r[0], "width": r[1], "depth": r[2]})
		var line := m.readback({"rooms": rooms, "doors": c[2]})
		if line.contains(str(c[3])):
			print("PASS  %-40s %s" % [c[0], line])
		else:
			bad += 1
			print("FAIL  %-40s %s\n      expected to contain: %s" % [c[0], line, c[3]])
	print("SHAPE TEST failures=%d" % bad)
	quit(bad)
