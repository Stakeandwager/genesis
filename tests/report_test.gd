extends SceneTree

# The session summary, over a session with one of every kind of evidence.
#
# This suite was on run_tests.sh's BROKEN list from 014 to 024, recorded as
# "hangs with no output at all; cause unknown". It did not hang and it was not
# silent. It threw a script error on its last assertion - `u["rate"]`, a key
# 012 deleted - and a script error in a SceneTree aborts _initialize before
# quit() is ever reached, so the process sat there until the harness's 600 s
# timeout killed it. The error was on stderr, after a screenful of correct
# output on stdout. Ten minutes of waiting and a glance at the tail is what
# "hangs with no output" was. See TRAPS 13.
#
# The stale assertion is worth stating, because it is the one 012 was written
# to abolish. Before 012 the score was a single `rate`, and
# ACCEPTED_BY_SILENCE counted in both halves of it: here that gave
# (confirmed 1 + by use 1 + silence 1) / judged 4 = 0.75, which is what the
# old assertion demanded. A player who answered nothing scored full marks for
# saying nothing. 012 removed silence from the denominator and replaced the
# single rate with a range, because a bare "no" could be either a misreading
# or a change of mind. The assertions below are written against that rule and
# one of them fails if silence is ever let back into the fraction.
#
# Assertions are read with get() and a sentinel rather than [] on purpose: a
# key that goes missing must produce a FAIL line and a clean exit, not another
# ten-minute hang for the next person.

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

	var bad := 0
	var u: Dictionary = s.get("understanding", {})
	if u.is_empty():
		print("FAIL no understanding block in the summary")
		print("REPORT TEST failures=1")
		quit(1)
		return

	bad += _eq(u, "readbacks", 5)
	bad += _eq(u, "judged", 4)
	bad += _eq(u, "accepted", 2)      # confirmed + accepted by use. Not silence.
	bad += _eq(u, "moved_on", 1)      # counted, reported, and not in the score
	bad += _eq(u, "bearing", 3)       # the 2 accepted + 1 corrected. Silence is not here.
	bad += _eq(u, "strong", 2)        # confirmed + corrected + disputed

	var counts: Dictionary = u.get("counts", {})
	bad += _eq(counts, "UNKNOWN", 1)
	bad += _eq(counts, "ACCEPTED_BY_SILENCE", 1)

	# Nobody said a bare "no", so the best and worst readings of the session
	# meet, and they meet at 2 of the 3 that bear on it - not at 3 of 4.
	bad += _near(u, "rate_best", 2.0 / 3.0)
	bad += _near(u, "rate_worst", 2.0 / 3.0)
	if absf(float(u.get("rate_best", -1.0)) - 0.75) < 0.001:
		print("FAIL rate_best is 0.75: silence is back in the fraction (012)")
		bad += 1

	# 012's rule, checked rather than asserted: removing the record that was
	# accepted by silence must not move the score or the denominator. If
	# silence is ever added back to `bearing`, these two differ and this fails.
	var without := records.duplicate()
	without.remove_at(without.size() - 2)   # d's understanding record
	without.remove_at(without.size() - 2)   # d's own record
	var u2: Dictionary = SessionReport.summarise(without).get("understanding", {})
	if int(u2.get("bearing", -1)) != int(u.get("bearing", -2)):
		print("FAIL silence changed the denominator: %s with, %s without"
			% [u.get("bearing", "?"), u2.get("bearing", "?")])
		bad += 1
	if absf(float(u2.get("rate_worst", -1.0)) - float(u.get("rate_worst", -2.0))) > 0.001:
		print("FAIL silence changed the score: %s with, %s without"
			% [u.get("rate_worst", "?"), u2.get("rate_worst", "?")])
		bad += 1
	if int(u2.get("moved_on", -1)) != 0:
		print("FAIL moved_on should be 0 without the silent record, was ", u2.get("moved_on", "?"))
		bad += 1

	print("REPORT TEST failures=%d" % bad)
	quit(bad)


# A missing key is a failure with a name, never a crash: a crash here skips
# quit() and hangs the harness for its whole timeout, which is how this suite
# spent ten releases on the broken list.
func _eq(d: Dictionary, key: String, want: int) -> int:
	if not d.has(key):
		print("FAIL no key '%s'" % key)
		return 1
	if int(d[key]) != want:
		print("FAIL %s is %s, expected %d" % [key, d[key], want])
		return 1
	return 0


func _near(d: Dictionary, key: String, want: float) -> int:
	if not d.has(key):
		print("FAIL no key '%s'" % key)
		return 1
	if absf(float(d[key]) - want) > 0.001:
		print("FAIL %s is %s, expected %f" % [key, d[key], want])
		return 1
	return 0
