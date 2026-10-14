extends SceneTree
func _initialize() -> void:
	var bad := 0
	var cases := [
		["yes", "build a farm", "CONFIRMED", "SAID_SO"],
		["no", "build a farm", "DISPUTED", "SAID_NO"],
		["no, I wanted the rooms in a row", "build a dungeon", "DISPUTED", "SAID_NO"],
		["that's not what I meant", "build a farm", "CORRECTED", "SAID_MISREAD"],
		["you misunderstood me, I said a pond", "build a farm", "CORRECTED", "SAID_MISREAD"],
		["I never said barns", "build a farm", "CORRECTED", "SAID_MISREAD"],
		["actually, make it bigger", "build a farm", "REVISED", "SAID_REVISED"],
		["instead give me a dungeon", "build a farm", "REVISED", "SAID_REVISED"],
		["no, actually I changed my mind", "build a farm", "REVISED", "SAID_REVISED"],
		["/drive", "build a track", "ACCEPTED_BY_USE", "DROVE_IT"],
		["put a race track in the farm", "make me a race track in a farm", "CORRECTED", "ASKED_AGAIN"],
		["build a dungeon", "build a farm with a pond", "ACCEPTED_BY_SILENCE", "MOVED_ON"],
	]
	for c in cases:
		var v := Understanding.judge(str(c[0]), str(c[1]), true)
		var u := str(v.get("understanding", "-")); var e := str(v.get("evidence", "-"))
		if u == str(c[2]) and e == str(c[3]):
			print("PASS  %-36s -> %s (%s)" % [str(c[0]).substr(0,36), u, e])
		else:
			bad += 1
			print("FAIL  %-36s -> %s/%s  expected %s/%s" % [str(c[0]).substr(0,36), u, e, c[2], c[3]])
	# driving says nothing when the request being judged built nothing
	var none := Understanding.judge("/drive", "a circuit that failed", false)
	if not none.is_empty():
		print("FAIL  /drive after a failed build -> ", none); bad += 1
	else:
		print("PASS  /drive after a failed build -> no verdict")
	var some := Understanding.judge("/drive", "a circuit", true)
	if str(some.get("evidence", "")) != "DROVE_IT":
		print("FAIL  /drive after a built world"); bad += 1
	else:
		print("PASS  /drive after a built world -> ACCEPTED_BY_USE (DROVE_IT)")
	for yes_no in ["yes", "no", "Yes.", "nope"]:
		if not Understanding.is_bare_answer(yes_no):
			print("FAIL  bare answer not spotted: ", yes_no); bad += 1
	for request in ["build a farm", "no, I wanted a row", "yes please build a dungeon"]:
		if Understanding.is_bare_answer(request):
			print("FAIL  request mistaken for a bare answer: ", request); bad += 1
	print("PASS  bare yes/no spotted, requests left alone")
	print("JUDGE TEST failures=%d" % bad)
	quit(bad)
