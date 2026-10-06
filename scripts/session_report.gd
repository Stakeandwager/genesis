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

static func summarise(records: Array) -> Dictionary:
	var started := ""
	var ended := ""
	var requests := 0
	var built := 0
	var edits := 0
	var loads := 0
	var failed: Array = []          # [request, why]
	var cannot: Array = []          # [request, reason]
	var first_world_time := ""
	var first_world_request := ""
	var drives := 0
	var races_started := 0
	var races_finished: Array = []  # places
	var ai_down := 0

	for r in records:
		var time := str(r.get("time", ""))
		if started == "" and time != "":
			started = time
		if time != "":
			ended = time

		var type := str(r.get("type", ""))
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

		requests += 1
		var request := str(r.get("request", ""))
		if str(r.get("result", "")) == "VALID":
			built += 1
			if typeof(r.get("source", null)) == TYPE_DICTIONARY and r["source"].has("edit"):
				edits += 1
			if first_world_time == "":
				first_world_time = time
				first_world_request = request
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
		"ai_unavailable": ai_down,
		"seconds_to_first_world": _seconds_between(started, first_world_time) if first_world_time != "" else -1.0,
		"first_world_request": first_world_request,
		"drove": drives,
		"races_started": races_started,
		"race_places": races_finished,
		"made_another": built >= 2,
	}


# The summary as a few plain lines for the history panel.
static func describe(name: String, s: Dictionary) -> String:
	var lines := PackedStringArray()
	lines.append("Session '%s': %.0f minutes, %d requests." % [name, float(s["minutes"]), int(s["requests"])])
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
	return "\n".join(lines)


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
		return "%d seconds" % int(seconds)
	return "%d min %02d s" % [int(seconds) / 60, int(seconds) % 60]
