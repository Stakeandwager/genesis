extends SceneTree

# --- 103: the fourth case asserted the wording of a sentence that was wrong ---
#
# This suite is the one place in tests/ that produced the dungeon readback's
# HUB clause - ", with four rooms off <name>" - and it held it with the string
# "with four rooms off hall" TYPED IN. That clause named its room RAW, with no
# article, since 003 (d6abe81, 8 October, 95 commits before this one, counted
# with git rev-list), and 043 then put the definite article into ONE function,
# Readback.the(), and made every other sentence in DungeonModule read it. This
# one was missed, and the typed expectation here FROZE the fault: the fix to
# scripts/dungeon_module.gd made this suite fail, which is how it was found.
#
# A suite that spells out a sentence cannot tell a rewording from a regression
# (TRAPS 82), and it is worse than that when the spelling it froze was wrong.
# So the hub room's name is now read through the same function the code reads -
# reword Readback.the() and this moves with it; name the room by hand again and
# it fails. The case list says which ROOM the clause must name, and the suite
# renders it.
#
# said_article_test holds the same clause from the other direction, with a
# numbered name and an ordinary one, so the two-sentence rule is not held only
# by this file's one case. See TRAPS 103.
func _initialize() -> void:
	var m := DungeonModule.new()
	var bad := 0
	var asserted := 0
	var cases := [
		["a row of five (what the player asked for)",
		 [["room_one",10,10],["room_two",10,10],["room_three",10,10],["room_four",10,10],["room_five",10,10]],
		 [[1,2],[2,3],[3,4],[4,5]], "each one leading to the next"],
		["a hall with four rooms off it",
		 [["great_hall",20,20],["a",10,10],["b",10,10],["c",10,10],["d",10,10]],
		 [[1,2],[1,3],[1,4],[1,5]], "with four rooms off it"],
		["two rooms",
		 [["entrance",10,10],["vault",10,10]], [[1,2]], "each one leading to the next"],
		# 103: the expectation is BUILT from the room the clause must name,
		# through the one function that decides the article, instead of being
		# spelled out. "hall" is not a label, so the() gives it "the hall".
		["a hall part way along a chain",
		 [["entrance",10,10],["hall",20,20],["a",10,10],["b",10,10],["c",10,10]],
		 [[1,2],[2,3],[2,4],[2,5]], "with four rooms off %s" % Readback.the("hall")],
	]
	for c in cases:
		asserted += 1
		var rooms: Array = []
		for r in c[1]:
			rooms.append({"name": r[0], "width": r[1], "depth": r[2]})
		var line := m.readback({"rooms": rooms, "doors": c[2]})
		if line.contains(str(c[3])):
			print("PASS  %-40s %s" % [c[0], line])
		else:
			bad += 1
			print("FAIL  %-40s %s\n      expected to contain: %s" % [c[0], line, c[3]])
	print("SHAPE TEST %d assertions, failures=%d" % [asserted, bad])
	quit(bad)
