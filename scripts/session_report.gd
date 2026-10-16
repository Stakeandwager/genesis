extends RefCounted
class_name SessionReport

# --- 002G: what one player testing session showed ---
# Reads one session's records from the track log and counts what the test
# plan asks for: time to the first world, requests that failed, things the
# player asked for that Genesis cannot do, whether they drove or raced, and
# whether they went on to make another world.
#
# Counting rules, so the numbers mean the same every time:
# - A request is counted once, by its final result. A first attempt that was
#   sent back to the AI for a correction is not counted; the correction is.
# - The steps inside a plan are not counted separately; the plan is.
# - /load is counted as a load, not as a request.
# - The AI being unavailable (busy, no connection) counts as a failed request.
# - 033: "worlds built" counts WORLDS. Four of the eleven commands the
#   whitelist admits are not worlds - EQUIP, ORDER, SHUT, OPEN - and until
#   033 every valid record was counted as a world, so a session of boots and
#   doors reported worlds it had never built and quoted a request for boots
#   as the first one. Which commands are worlds is read off
#   WorldRegistry.commands() and never written out here.

static func summarise(records: Array) -> Dictionary:
	var started := ""
	var ended := ""
	var requests := 0
	var built := 0
	var edits := 0
	var loads := 0
	var failed: Array = []          # [request, why]
	var cannot: Array = []          # [request, reason]
	var done_otherwise: Array = []  # [request, command] - valid, and not a world
	var by_genesis := 0             # records Genesis wrote about its own housekeeping
	var first_world_time := ""
	var first_world_request := ""
	var drives := 0
	var races_started := 0
	var races_finished: Array = []  # places
	var ai_down := 0
	var judged := {}                # record id -> the evidence about it
	var readbacks: Array = []       # every record that showed the player a readback

	for r in records:
		var time := str(r.get("time", ""))
		if started == "" and time != "":
			started = time
		if time != "":
			ended = time

		var type := str(r.get("type", ""))
		# 003 Stage 2: evidence about an earlier readback. Counted on its own
		# axis and never mixed with whether anything was built.
		if type == "understanding":
			judged[str(r.get("about", ""))] = r
			continue
		if type == "session_event":
			match str(r.get("event", "")):
				"session_start":
					started = time
				"drive":
					drives += 1
				"race_start":
					races_started += 1
				"ai_unavailable":
					ai_down += 1
					requests += 1
					failed.append([str(r.get("request", "")), "the AI was unavailable: " + str(r.get("reason", ""))])
			continue
		if type == "race_result":
			races_finished.append(int(r.get("player_place", 0)))
			continue
		if not r.has("result"):
			continue
		if bool(r.get("revision_pending", false)) or _is_plan_step(r):
			continue

		var source := str(r.get("source", {}).get("source", "")) if typeof(r.get("source", null)) == TYPE_DICTIONARY else ""
		if source == "saved":
			loads += 1
			continue
		# --- 033: a record Genesis wrote about itself ---
		# /session NAME clears the world before the tester's first sentence,
		# so that nothing of the last tester's is left over. Since 033 that
		# clear leaves a record, which is right - the world did go, and the
		# ledger should say so - but it is NOT something the player asked
		# for, and counting it would put a request in the tester's report
		# that the tester never typed. Counted on its own axis instead.
		# session_test caught this: it reported 8 requests for a script that
		# made 7.
		if source == "game_command":
			by_genesis += 1
			continue

		requests += 1
		if str(r.get("readback", "")) != "":
			readbacks.append(r)
		var request := str(r.get("request", ""))
		if str(r.get("result", "")) == "VALID":
			# --- 033: a count that names worlds, counting worlds ---
			# This used to be every valid record, so a player who equipped
			# boots and shut a door read as "Worlds built: 2. Made another:
			# yes", with "First world after 40 s" quoting a request for
			# boots. Measured, not inferred: a session of one EQUIP, one
			# SHUT and one ORDER and no world at all reported three worlds
			# built and a first world. Four of the eleven commands the
			# whitelist admits are not worlds at all.
			if _builds_a_world(r):
				built += 1
				if typeof(r.get("source", null)) == TYPE_DICTIONARY and r["source"].has("edit"):
					edits += 1
				if first_world_time == "":
					first_world_time = time
					first_world_request = request
			else:
				# Still a request that worked, and still worth seeing. It is
				# counted on its own axis rather than folded into a number
				# whose name is about worlds.
				done_otherwise.append([request, str(r.get("command", ""))])
		elif str(r.get("category", "")) == "UNSUPPORTED":
			var reasons: Array = r.get("reasons", [])
			cannot.append([request, str(reasons[0]) if not reasons.is_empty() else ""])
		else:
			var why: Array = r.get("reasons", [])
			failed.append([request, str(r.get("category", "")) + (": " + str(why[0]) if not why.is_empty() else "")])

	return {
		"started": started,
		"ended": ended,
		"minutes": _seconds_between(started, ended) / 60.0,
		"requests": requests,
		"worlds_built": built,
		"changes": edits,
		"loads": loads,
		"failed": failed,
		"cannot_do": cannot,
		"done_otherwise": done_otherwise,
		"by_genesis": by_genesis,
		"ai_unavailable": ai_down,
		"seconds_to_first_world": _seconds_between(started, first_world_time) if first_world_time != "" else -1.0,
		"first_world_request": first_world_request,
		"drove": drives,
		"races_started": races_started,
		"race_places": races_finished,
		"made_another": built >= 2,
		"understanding": _understanding(readbacks, judged),
	}


# What the session showed about whether Genesis was understood.
#
# The strengths are kept apart on purpose. Silence is the easiest evidence to
# collect and the least worth having, so a high score made of it must stay
# visible as such rather than disappearing into one number.
static func _understanding(readbacks: Array, judged: Dictionary) -> Dictionary:
	var counts := {
		"CONFIRMED": 0, "CORRECTED": 0, "DISPUTED": 0, "REVISED": 0,
		"ACCEPTED_BY_USE": 0, "ACCEPTED_BY_SILENCE": 0, "UNKNOWN": 0,
	}
	var corrections: Array = []
	var disputes: Array = []
	for r in readbacks:
		var id := str(r.get("id", ""))
		if not judged.has(id):
			counts["UNKNOWN"] = int(counts["UNKNOWN"]) + 1
			continue
		var evidence: Dictionary = judged[id]
		var status := str(evidence.get("understanding", "UNKNOWN"))
		if not counts.has(status):
			status = "UNKNOWN"
		counts[status] = int(counts[status]) + 1
		if status == "CORRECTED":
			corrections.append([str(r.get("request", "")), str(r.get("readback", "")),
				str(evidence.get("evidence", ""))])
		elif status == "DISPUTED":
			disputes.append([str(r.get("request", "")), str(r.get("readback", ""))])

	var judged_count := readbacks.size() - int(counts["UNKNOWN"])
	var disputed := int(counts["DISPUTED"])

	# --- 012: silence is an observation, not a verdict ---
	# ACCEPTED_BY_SILENCE used to be added to the accepted total and so landed
	# in both halves of the fraction. A player who typed six requests and
	# never once answered a readback scored 100% understood - a perfect mark
	# awarded for saying nothing. The label said "weak" while the arithmetic
	# said "yes".
	#
	# Moving on is a thing a player DID, and it is still counted and still
	# reported, under its own heading. It is simply not evidence about whether
	# they were understood. People who were misread usually say so, but
	# usually is not evidence, and a number that quietly turns absence into
	# agreement is the exact failure this layer exists to prevent.
	#
	# The honest consequence is uncomfortable and is left to stand: a session
	# where nobody answered anything now reports that nothing bears on
	# understanding, rather than reporting that everything was understood.
	var accepted := int(counts["CONFIRMED"]) + int(counts["ACCEPTED_BY_USE"])
	var moved_on := int(counts["ACCEPTED_BY_SILENCE"])

	# A deliberate change of mind says nothing about whether the first
	# reading was right, so it is not in the denominator at all. Counting it
	# would measure how often people change their minds and call the result
	# comprehension. Silence is now excluded for the same reason.
	var bearing := accepted + int(counts["CORRECTED"]) + disputed

	# Every "no" that did not say WHY could be either. Rather than guess,
	# the score is given as the range it actually sits in: best if every
	# dispute was a change of mind, worst if every one was a misreading.
	# They meet when nobody said a bare no.
	var best := float(accepted + disputed) / float(bearing) if bearing > 0 else -1.0
	var worst := float(accepted) / float(bearing) if bearing > 0 else -1.0
	return {
		"readbacks": readbacks.size(),
		"counts": counts,
		"judged": judged_count,
		"accepted": accepted,
		"moved_on": moved_on,
		"bearing": bearing,
		"rate_best": best,
		"rate_worst": worst,
		"strong": int(counts["CONFIRMED"]) + int(counts["CORRECTED"]) + disputed,
		"corrections": corrections,
		"disputes": disputes,
	}


# The summary as a few plain lines for the history panel.
static func describe(name: String, s: Dictionary) -> String:
	var lines := PackedStringArray()
	# 042: the count and the noun after it are one fact, read from
	# Readback.plural() and never written out again. A session of ONE request
	# - the commonest session a first-time tester has - said "1 minutes, 1
	# requests" here, "1 seconds" below, and "1 readbacks" in the
	# understanding block. 034 swept the validators and the dungeon's
	# measurements; this file was not in that sweep. See TRAPS 36.
	lines.append("Session '%s': %s, %s." % [name,
		Readback.plural(int(roundf(float(s["minutes"]))), "minute"),
		Readback.plural(int(s["requests"]), "request")])
	if float(s["seconds_to_first_world"]) >= 0.0:
		lines.append("First world after %s, from \"%s\"." % [_duration(float(s["seconds_to_first_world"])), s["first_world_request"]])
	else:
		lines.append("No world was built.")
	lines.append("Worlds built: %d (%d of them changes to the last world). Made another: %s." % [int(s["worlds_built"]), int(s["changes"]), "yes" if bool(s["made_another"]) else "no"])
	var places: Array = s["race_places"]
	var placed := PackedStringArray()
	for p in places:
		placed.append("P%d" % int(p))
	lines.append("Drove: %s. Races started: %d, finished: %d%s." % [
		"no" if int(s["drove"]) == 0 else ("yes, once" if int(s["drove"]) == 1 else "yes, %d times" % int(s["drove"])),
		int(s["races_started"]), places.size(), " (" + ", ".join(placed) + ")" if not places.is_empty() else ""])
	var failed: Array = s["failed"]
	lines.append("Failed requests: %d%s" % [failed.size(), ":" if not failed.is_empty() else "."])
	for f in failed:
		lines.append("  \"%s\" - %s" % [f[0], f[1]])
	var cannot: Array = s["cannot_do"]
	lines.append("Asked for things Genesis cannot do: %d%s" % [cannot.size(), ":" if not cannot.is_empty() else "."])
	for c in cannot:
		lines.append("  \"%s\" - %s" % [c[0], c[1]])
	# 033: the requests that worked and were not worlds. They used to be
	# inside "Worlds built", which is why that number was wrong.
	var other: Array = s.get("done_otherwise", [])
	lines.append("Other requests that worked: %d%s" % [other.size(), ":" if not other.is_empty() else "."])
	for o in other:
		lines.append("  \"%s\" - %s" % [o[0], o[1]])

	var u: Dictionary = s.get("understanding", {})
	if not u.is_empty():
		var c: Dictionary = u["counts"]
		lines.append("")
		lines.append("Understanding: %s, %d with evidence." % [
			Readback.plural(int(u["readbacks"]), "readback"), int(u["judged"])])
		lines.append("  for:     confirmed %d (strong), accepted by use %d (medium)" % [
			int(c["CONFIRMED"]), int(c["ACCEPTED_BY_USE"])])
		lines.append("  against: said Genesis misread them %d (strong)" % int(c["CORRECTED"]))
		lines.append("  either:  said no without saying why %d (strong, unattributable)" % int(c["DISPUTED"]))
		lines.append("  moved on without answering %d  (observed, not evidence, not counted)" % int(c["ACCEPTED_BY_SILENCE"]))
		lines.append("  changed their mind %d  (says nothing about understanding, not counted)" % int(c["REVISED"]))
		lines.append("  no evidence %d" % int(c["UNKNOWN"]))
		if float(u["rate_worst"]) < 0.0:
			lines.append("  nothing bears on understanding: no score can be given")
		elif int(c["DISPUTED"]) == 0:
			lines.append("  understood: %.0f%% of the %s that %s on it" % [
				float(u["rate_worst"]) * 100.0, Readback.plural(int(u["bearing"]), "readback"),
				Readback.agrees(int(u["bearing"]), "bears", "bear")])
		else:
			lines.append("  understood: between %.0f%% and %.0f%% of the %s that %s on it" % [
				float(u["rate_worst"]) * 100.0, float(u["rate_best"]) * 100.0,
				Readback.plural(int(u["bearing"]), "readback"),
				Readback.agrees(int(u["bearing"]), "bears", "bear")])
			lines.append("    (the %s could be a misreading or a change of mind; read %s below)" % [
				"one bare \"no\"" if int(c["DISPUTED"]) == 1 else "%d bare \"no\"s" % int(c["DISPUTED"]),
				"it" if int(c["DISPUTED"]) == 1 else "them"])
		var corrections: Array = u["corrections"]
		if not corrections.is_empty():
			lines.append("  said Genesis misread them:")
			for item in corrections:
				lines.append("    \"%s\" -> read back as \"%s\" (%s)" % [item[0], item[1], item[2]])
		var disputes: Array = u["disputes"]
		if not disputes.is_empty():
			lines.append("  said no, reason not given - judge these by eye:")
			for item in disputes:
				lines.append("    \"%s\" -> read back as \"%s\"" % [item[0], item[1]])
	return "\n".join(lines)


# --- 033: which records are about building a world ---
# Read off WorldRegistry.commands(), the one list that says which worlds
# exist, so a world added later is counted for free and a command that is not
# a world can never be counted as one. The four that are not: EQUIP, ORDER,
# SHUT, OPEN - plus CLEAR_WORLD, MODIFY_TRACK and SPAWN_OPPONENTS, which
# before 033 wrote no record at all and so could not be counted either way.
#
# A PLAN is judged by the steps it actually built, which its own record
# lists: a plan of a dungeon and an errand built a world, a plan of one
# order did not. The step records are excluded separately by _is_plan_step,
# so the worlds inside a plan are counted once, through the plan.
static func _builds_a_world(r: Dictionary) -> bool:
	var command := str(r.get("command", ""))
	var worlds := WorldRegistry.commands()
	if worlds.has(command):
		return true
	if command != "PLAN":
		return false
	for step in (r.get("steps", []) as Array):
		if worlds.has(str(step)):
			return true
	return false


# A plan writes one record per step and then one for the plan itself, all
# with the plan as their raw command. Only the plan's own record counts.
static func _is_plan_step(r: Dictionary) -> bool:
	if str(r.get("command", "")) == "PLAN":
		return false
	# JSON.new().parse stays quiet on text that is not JSON (an AI answer that
	# was refused), where JSON.parse_string would print an error.
	var json := JSON.new()
	if json.parse(str(r.get("raw_command", ""))) != OK:
		return false
	var raw = json.data
	return typeof(raw) == TYPE_DICTIONARY and str(raw.get("command", "")).to_upper() == "PLAN"


static func _seconds_between(from: String, to: String) -> float:
	if from == "" or to == "":
		return 0.0
	return float(Time.get_unix_time_from_datetime_string(to) - Time.get_unix_time_from_datetime_string(from))


static func _duration(seconds: float) -> String:
	if seconds < 60.0:
		return Readback.plural(int(seconds), "second")
	return "%d min %02d s" % [int(seconds) / 60, int(seconds) % 60]
