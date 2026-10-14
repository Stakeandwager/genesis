extends SceneTree
func _rec(id, req, rb): return {"time":"2026-10-09T14:00:00","id":id,"request":req,"readback":rb,"result":"VALID","command":"CREATE_FARM","source":{"source":"ai"},"metrics":{}}
func _ev(about, status): return {"type":"understanding","about":about,"understanding":status}
func _initialize() -> void:
	var records := [
		_rec("a","a farm","a farm with a pond"), _ev("a","CONFIRMED"),
		_rec("b","a dungeon","a hall with four rooms off it"), _ev("b","DISPUTED"),
		_rec("c","a track","a circuit with two straights"), _ev("c","ACCEPTED_BY_USE"),
		_rec("d","a farm","a farm with a barn"), _ev("d","REVISED"),
		_rec("e","a dungeon","a dungeon of three rooms"), _ev("e","CORRECTED"),
	]
	var s := SessionReport.summarise(records)
	print(SessionReport.describe("range", s))
	var u: Dictionary = s["understanding"]
	var bad := 0
	# accepted 2 (confirmed + use), corrected 1, disputed 1, revised excluded
	if int(u["bearing"]) != 4: print("FAIL bearing ", u["bearing"]); bad += 1
	if absf(float(u["rate_worst"]) - 0.50) > 0.001: print("FAIL worst ", u["rate_worst"]); bad += 1
	if absf(float(u["rate_best"]) - 0.75) > 0.001: print("FAIL best ", u["rate_best"]); bad += 1
	if int(u["counts"]["REVISED"]) != 1: print("FAIL revised"); bad += 1
	print("RANGE TEST failures=%d" % bad)
	quit(bad)
