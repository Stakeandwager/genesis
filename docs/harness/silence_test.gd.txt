extends SceneTree

# 012 - silence is an observation, not a verdict.
#
# ACCEPTED_BY_SILENCE used to be added to the accepted total and so landed in
# both halves of the fraction. A player who typed six requests and answered
# none of them scored 100% understood: a perfect mark awarded for saying
# nothing. The display called it "weak"; the arithmetic called it "yes".
#
# This is the session that proves it, and would have passed before.

var bad := 0


func _check(ok: bool, what: String) -> void:
	print(("PASS  " if ok else "FAIL  ") + what)
	if not ok:
		bad += 1


func _readback(id: String, request: String) -> Dictionary:
	return {"time": "2026-10-13T12:00:00", "id": id, "request": request,
		"readback": "a dungeon of three rooms", "result": "VALID",
		"command": "CREATE_DUNGEON", "source": {"source": "ai"}, "metrics": {}}


func _silence(id: String) -> Dictionary:
	return {"type": "understanding", "about": id,
		"understanding": "ACCEPTED_BY_SILENCE", "evidence": "MOVED_ON", "strength": "weak"}


func _initialize() -> void:
	# --- a player who never answered anything ---
	var quiet: Array = [{"type": "session_event", "time": "2026-10-13T11:59:00", "event": "session_start"}]
	for i in 4:
		quiet.append(_readback("q%d" % i, "build a dungeon"))
		quiet.append(_silence("q%d" % i))

	var s: Dictionary = SessionReport.summarise(quiet)
	var u: Dictionary = s["understanding"]
	_check(int(u["counts"]["ACCEPTED_BY_SILENCE"]) == 4, "four of them moved on without answering")
	_check(int(u["moved_on"]) == 4, "which is reported under its own heading")
	_check(int(u["accepted"]) == 0, "none of it counts as acceptance")
	_check(int(u["bearing"]) == 0, "and none of it bears on understanding")
	_check(float(u["rate_worst"]) < 0.0,
		"so no score is given at all, where the old arithmetic gave 100%")

	var said := SessionReport.describe("quiet", s)
	_check(said.contains("nothing bears on understanding"),
		"the report says so in words rather than printing a number")
	_check(said.contains("moved on without answering 4"),
		"and still reports what the player actually did")

	# --- one real answer among the silence ---
	var mixed: Array = [{"type": "session_event", "time": "2026-10-13T11:59:00", "event": "session_start"}]
	for i in 3:
		mixed.append(_readback("m%d" % i, "build a dungeon"))
		mixed.append(_silence("m%d" % i))
	mixed.append(_readback("m9", "build a farm"))
	mixed.append({"type": "understanding", "about": "m9", "understanding": "CONFIRMED",
		"evidence": "SAID_SO", "strength": "strong"})

	var s2: Dictionary = SessionReport.summarise(mixed)
	var u2: Dictionary = s2["understanding"]
	_check(int(u2["bearing"]) == 1, "one answer among three silences bears on one thing, not four")
	_check(absf(float(u2["rate_worst"]) - 1.0) < 0.001, "and that one was understood")
	_check(int(u2["moved_on"]) == 3, "the three silences are still on the record")

	print("SILENCE TEST failures=%d" % bad)
	quit(bad)
