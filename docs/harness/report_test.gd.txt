extends SceneTree
func _initialize() -> void:
	var records := [
		{"type":"session_event","time":"2026-10-08T09:00:00","event":"session_start"},
		# confirmed
		{"time":"2026-10-08T09:00:10","id":"a","request":"build a farm with a pond","readback":"a farm with a 50 m pond","result":"VALID","command":"CREATE_FARM","source":{"source":"ai"},"metrics":{}},
		{"type":"understanding","about":"a","understanding":"CONFIRMED","evidence":"SAID_SO","strength":"strong"},
		# corrected, by asking again
		{"time":"2026-10-08T09:01:00","id":"b","request":"a race track in a farm","readback":"a farm and a race circuit, side by side","result":"VALID","command":"PLAN","source":{"source":"ai"},"metrics":{}},
		{"type":"understanding","about":"b","understanding":"CORRECTED","evidence":"ASKED_AGAIN","strength":"strong"},
		# accepted by driving it
		{"time":"2026-10-08T09:02:00","id":"c","request":"a fast circuit","readback":"a closed circuit with two 800 m straights","result":"VALID","command":"CREATE_TRACK","source":{"source":"ai"},"metrics":{}},
		{"type":"understanding","about":"c","understanding":"ACCEPTED_BY_USE","evidence":"DROVE_IT","strength":"medium"},
		# moved on
		{"time":"2026-10-08T09:03:00","id":"d","request":"a dungeon","readback":"a dungeon of four rooms joined by three doors","result":"VALID","command":"CREATE_DUNGEON","source":{"source":"ai"},"metrics":{}},
		{"type":"understanding","about":"d","understanding":"ACCEPTED_BY_SILENCE","evidence":"MOVED_ON","strength":"weak"},
		# never judged
		{"time":"2026-10-08T09:04:00","id":"e","request":"a big farm","readback":"a farm with a 300 m corn field","result":"VALID","command":"CREATE_FARM","source":{"source":"ai"},"metrics":{}},
	]
	var s := SessionReport.summarise(records)
	print(SessionReport.describe("stranger-1", s))
	var u: Dictionary = s["understanding"]
	var bad := 0
	if int(u["readbacks"]) != 5: print("FAIL readbacks ", u["readbacks"]); bad += 1
	if int(u["judged"]) != 4: print("FAIL judged ", u["judged"]); bad += 1
	if int(u["counts"]["UNKNOWN"]) != 1: print("FAIL unknown"); bad += 1
	if int(u["strong"]) != 2: print("FAIL strong ", u["strong"]); bad += 1
	if absf(float(u["rate"]) - 0.75) > 0.001: print("FAIL rate ", u["rate"]); bad += 1
	print("REPORT TEST failures=%d" % bad)
	quit(bad)
