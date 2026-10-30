extends SceneTree

# --- 099: the type of every ledger field the session report reads ---
#
# WHAT THIS MEASURES. `user://track_log.jsonl` is one line of JSON per record,
# written by this game and editable with any text editor. `SessionReport` is
# the only consumer of it in `scripts/` - grepped for `read_session` and for
# `TrackLog.PATH`, which between them name `main.gd:545` and nothing else -
# and five of its reads assumed a field's type.
#
# DRIVEN BEFORE ANYTHING WAS CHANGED, a hand-written session of ten records
# with one field forced to a wrong type at a time, through the real door into
# `summarise()` and `describe()`:
#
#   int(r.get("player_place", 0))      broke on Array, Dictionary, null
#   bool(r.get("revision_pending"))    broke on String, Array, Dictionary, null
#   var reasons: Array = r.get(...)    broke on String, Dictionary, number, null
#   var why: Array = r.get(...)        the same four
#   (r.get("steps", []) as Array)      the same four
#
# AND THE CONSEQUENCE WAS NOT A CRASH, which is why this suite asserts what it
# asserts. A GDScript runtime error of this kind ABANDONS THE FUNCTION: so
# `summarise()` returned an EMPTY dictionary, `describe()` was handed it and
# failed on its own first line, and the real `/session end` - driven through
# the scene the game launches - printed a BLANK report into the history panel,
# wrote a `session_summary` record carrying FOUR keys and no numbers at all,
# set the status label to "Results in the history panel", and recorded the
# request as "ok". That is PROTOCOL section 2's *missing evidence must not
# become success*, at the one artefact a testing session exists to produce.
#
# SO THE CAPABILITY UNDER TEST IS NOT A SENTENCE (TRAPS 6, TRAPS 14). Nothing
# here asserts that any line reads a particular way. Section 2 asks whether
# the summary SURVIVED - whether it still carries every key it carries for an
# undamaged session - and whether the fallback was COUNTED. Section 4 asks
# whether the real `/session end` still puts numbers in the ledger.
#
# AND THE CLASS IS CLOSED BY THE CODE AND NOT BY A LIST TYPED HERE (TRAPS 82,
# TRAPS 11). Section 1 reads `scripts/session_report.gd` and asserts that the
# set of fields read through `_field()` is EXACTLY the set of keys in
# `FIELD_TYPES`: a sixth read added without a row fails by its own name, and a
# row with no read fails by its own name. It then asserts that no field in the
# table is read any other way, and that the three shapes measured breaking
# above appear nowhere in the file.

const SOURCE := "res://scripts/session_report.gd"
const SID := "record-type-test"

# Every value a hand-edited JSON file can hold, plus an int, because a record
# read back through JSON gives a float where one written in-process gives an
# int and FIELD_TYPES admits both. Not a list of "bad" values: which of these
# is bad for which field is DERIVED from the table below, both ways.
const SAMPLES := [null, false, true, 2, 2.0, "x", [], {}, ["a"], {"k": 1}]

var asserted := 0
var bad := 0
var main: Node


func _check(ok: bool, what: String) -> void:
	asserted += 1
	if not ok:
		bad += 1
		print("  FAIL  ", what)


func _initialize() -> void:
	_run.call_deferred()


# The file's code with comments blanked, so a question about what the code
# DOES is answered from the code and never from prose (TRAPS 63).
static func _code_of(source: String) -> String:
	var out := ""
	for raw in source.split("\n"):
		var line := str(raw)
		if line.strip_edges().begins_with("#"):
			out += "\n"
			continue
		var hash_at := line.find("#")
		out += (line if hash_at < 0 else line.substr(0, hash_at)) + "\n"
	return out


func _source() -> String:
	var file := FileAccess.open(SOURCE, FileAccess.READ)
	_check(file != null, "scripts/session_report.gd could be opened and read")
	if file == null:
		return ""
	var text := file.get_as_text()
	file.close()
	return _code_of(text)


# --- section 1: the class is the code's, not this file's ---
func _the_class_is_closed_by_the_code() -> void:
	var code := _source()
	if code == "":
		return

	var read := {}
	var call := RegEx.new()
	call.compile("_field\\(r,\\s*\"([a-z_]+)\"")
	for hit in call.search_all(code):
		read[hit.get_string(1)] = true

	var tabled: Array = SessionReport.FIELD_TYPES.keys()
	tabled.sort()
	var found: Array = read.keys()
	found.sort()
	_check(found == tabled,
		"every field read through _field() has a row in FIELD_TYPES and every row is read - table %s, read %s" % [
			str(tabled), str(found)])

	# And no field in the table is reached any other way, which is the half a
	# set comparison cannot see: a read left behind beside the new one.
	for field in tabled:
		_check(not code.contains("r.get(\"%s\"" % field),
			"\"%s\" is read through _field() and nowhere through a bare r.get()" % field)

	# The three shapes measured breaking above, swept for by shape rather than
	# by field, so a SIXTH field arriving in one of them is caught without a
	# row being added here.
	for shape in ["int(r.get(", "bool(r.get(", ": Array = r.get("]:
		_check(not code.contains(shape),
			"no record field is read as \"%s...\" - the shape driven abandoning summarise()" % shape)

	# Not vacuous: the scan sees those shapes when they are there, and does not
	# see one that is only mentioned in a comment.
	_check(_code_of("\tvar x: Array = r.get(\"reasons\", [])\n").contains(": Array = r.get("),
		"and the shape scan sees that shape in code when it is present")
	_check(not _code_of("# it used to be var x: Array = r.get(\"reasons\", [])\n").contains(": Array = r.get("),
		"and does not see it in a comment that merely mentions it (TRAPS 63)")


# A session that reaches every counting path in summarise(): a world, an
# UNSUPPORTED refusal, a refusal with a category, a PLAN, a race result, a
# drive, and the AI being unavailable.
static func _session() -> Array:
	return [
		{"type": "session_event", "event": "session_start", "time": "2026-10-30T10:00:00"},
		{"id": "r1", "time": "2026-10-30T10:00:10", "request": "a dungeon",
			"raw_command": "{\"command\":\"CREATE_DUNGEON\"}", "command": "CREATE_DUNGEON",
			"result": "VALID", "readback": "a dungeon"},
		{"type": "understanding", "about": "r1", "understanding": "CONFIRMED",
			"evidence": "said yes", "time": "2026-10-30T10:00:12"},
		{"id": "r2", "time": "2026-10-30T10:00:20", "request": "fly to the moon",
			"raw_command": "{\"command\":\"UNSUPPORTED\"}", "command": "UNSUPPORTED",
			"result": "INVALID", "category": "UNSUPPORTED", "reasons": ["Genesis has no flight"]},
		{"id": "r3", "time": "2026-10-30T10:00:30", "request": "a track of -4 corners",
			"raw_command": "{\"command\":\"CREATE_TRACK\"}", "command": "CREATE_TRACK",
			"result": "INVALID", "category": "OUT_OF_RANGE", "reasons": ["corners cannot be negative"],
			# game_controller.gd:1207 writes revision_pending only as `true`, so
			# in a real ledger the field is PRESENT or ABSENT and never false.
			# An explicit false is written here because this suite has to have a
			# record to force the field ON, and false is what the read's own
			# default means. The FIRST draft of this suite left it out, and its
			# own "the session above carries a X to force" assertion caught
			# that the field was never exercised at all.
			"revision_pending": false},
		{"id": "r4", "time": "2026-10-30T10:00:40", "request": "a dungeon and an errand",
			"raw_command": "{\"command\":\"PLAN\"}", "command": "PLAN",
			"result": "VALID", "steps": ["CREATE_DUNGEON", "ORDER"]},
		{"type": "race_result", "player_place": 2, "time": "2026-10-30T10:00:50"},
		{"type": "session_event", "event": "drive", "time": "2026-10-30T10:00:55"},
		{"type": "session_event", "event": "ai_unavailable", "request": "a farm",
			"reason": "no connection", "time": "2026-10-30T10:00:58"},
		{"type": "session_event", "event": "session_end", "time": "2026-10-30T10:01:00"},
	]


# The record in that session which actually carries each field, so forcing a
# type exercises the read rather than a record that never reaches it. Read off
# the session above by looking for the field, not written out as an index.
static func _carrier(field: String) -> int:
	var session := _session()
	for i in session.size():
		if (session[i] as Dictionary).has(field):
			return i
	return -1


# The same session with the field ERASED from the record that carries it.
static func _without(field: String) -> Array:
	var session := _session()
	var at := _carrier(field)
	if at >= 0:
		(session[at] as Dictionary).erase(field)
	return session


static func _with(field: String, value: Variant) -> Array:
	var session := _session()
	var at := _carrier(field)
	if at >= 0:
		(session[at] as Dictionary)[field] = value
	return session


# --- section 2: both directions, every field against every type ---
#
# For each field in the table and each value a JSON file can hold, the table
# itself says which answer is right, so over-tightening and under-tightening
# are caught by the same loop. Nothing here is a list of bad values.
func _every_field_against_every_type() -> void:
	var control: Dictionary = SessionReport.summarise(_session())
	var control_keys: Array = control.keys()
	control_keys.sort()
	_check(int((control["damaged"] as Dictionary)["records"]) == 0,
		"the undamaged session reports no damaged record (got %d)" % int((control["damaged"] as Dictionary)["records"]))

	# THE SUITE'S OWN FLOOR. An emptied or narrowed SAMPLES would run fewer
	# rows and still print failures=0, which is the silence 096 and 097 found
	# twice. Every type a JSON file can hold must be in there, named by the
	# engine rather than counted here.
	var covered := {}
	for value in SAMPLES:
		covered[typeof(value)] = true
	for needed in [TYPE_NIL, TYPE_BOOL, TYPE_INT, TYPE_FLOAT, TYPE_STRING, TYPE_ARRAY, TYPE_DICTIONARY]:
		_check(covered.has(needed),
			"the samples include a %s, so every type a hand-edited file can hold is asked about" % type_string(needed))

	for field in SessionReport.FIELD_TYPES:
		var at := _carrier(field)
		_check(at >= 0, "the session above carries a \"%s\" to force" % field)
		if at < 0:
			continue
		var admits: Array = SessionReport.FIELD_TYPES[field] as Array
		var yes := 0
		var no := 0
		for value in SAMPLES:
			if admits.has(typeof(value)):
				yes += 1
			else:
				no += 1
		_check(yes > 0 and no > 0,
			"\"%s\" is asked about in both directions: %d types it admits, %d it refuses" % [field, yes, no])

		for value in SAMPLES:
			var wrong := not admits.has(typeof(value))
			var label := "%s = %s (%s)" % [field, JSON.stringify(value), type_string(typeof(value))]

			# The door's own answer, by field name rather than as a bool.
			_check(SessionReport.damaged_fields({field: value}).has(field) == wrong,
				"damaged_fields() names \"%s\" exactly when the table refuses the type - %s" % [field, label])

			var summary: Dictionary = SessionReport.summarise(_with(field, value))
			# THE CAPABILITY: the function was not abandoned. An abandoned
			# summarise() returns {}, so this is the assertion that fails on
			# every row of the table before 099.
			var keys: Array = summary.keys()
			keys.sort()
			_check(keys == control_keys,
				"the summary still carries every key it carries for an undamaged session - %s" % label)
			if keys != control_keys:
				continue

			# THE RULE ITSELF, asserted and not merely described: a field of a
			# type this game does not write is read EXACTLY as an absent one.
			# One assertion per row, and it is the ONLY one here that can see
			# the `steps` read - a wrong type there abandons
			# _builds_a_world() rather than summarise(), so the summary
			# survives whole and a PLAN silently stops counting as a world.
			# Measured: with that read reverted, this fails and nothing else
			# in section 2 does.
			if wrong:
				var as_absent: Dictionary = SessionReport.summarise(_without(field))
				var differs: Array = []
				for key in as_absent:
					if key == "damaged":
						continue
					if str(summary.get(key, "<MISSING>")) != str(as_absent[key]):
						differs.append(key)
				_check(differs.is_empty(),
					"a damaged field is read exactly as an absent one - %s%s" % [
						label, "" if differs.is_empty() else " - differs at %s" % str(differs)])

			var dmg: Dictionary = summary["damaged"] as Dictionary
			_check((dmg["fields"] as Array).has(field) == wrong,
				"the summary names \"%s\" among its damaged fields exactly when the table refuses it - %s" % [field, label])
			_check(int(dmg["records"]) == (1 if wrong else 0),
				"it counts %d damaged record - %s" % [1 if wrong else 0, label])
			_check(int(dmg["read"]) == _session().size(),
				"and it says how many records it read, as the denominator - %s" % label)

			# And describe() survives it too, which is the second half of what
			# was abandoned: before 099 it returned an empty string.
			var said := SessionReport.describe("probe", summary)
			_check(said != "", "describe() still produces a report - %s" % label)
			# And a degraded report does not read as a complete one. Asserted
			# as "it is not the same report, and it names the field", never as
			# a sentence: the line can be reworded freely.
			# A value the table ADMITS also changes the report - a true
			# revision_pending costs a request, an empty steps costs a world -
			# so only one direction of this is a fact about damage. The first
			# draft asserted the biconditional and its own run said so.
			var control_said := SessionReport.describe("probe", control)
			if wrong:
				_check(said != control_said,
					"a damaged session's report is not the undamaged one - %s" % label)
			_check(said.contains(field) == wrong,
				"and it names \"%s\" exactly when that field was damaged - %s" % [field, label])


# --- section 3: a type the table ADMITS is still used, not merely tolerated ---
#
# The half a "does it survive" assertion cannot see. A _field() that returned
# its fallback for everything would pass section 2 on every row and lose every
# number in the report.
func _an_admitted_type_is_used() -> void:
	var places: Array = (SessionReport.summarise(_with("player_place", 3)) as Dictionary)["race_places"]
	_check(places.has(3), "an int player_place is USED: the race places carry it (got %s)" % str(places))
	var as_float: Array = (SessionReport.summarise(_with("player_place", 3.0)) as Dictionary)["race_places"]
	_check(as_float.has(3), "and a float one is too, which is what a JSON round trip gives (got %s)" % str(as_float))

	# revision_pending true means "this attempt was sent back for a
	# correction", and such a record is NOT counted as a request.
	var kept := int((SessionReport.summarise(_session()) as Dictionary)["requests"])
	var skipped := int((SessionReport.summarise(_with("revision_pending", true)) as Dictionary)["requests"])
	_check(skipped == kept - 1,
		"a revision_pending of true is USED: one fewer request is counted (%d against %d)" % [skipped, kept])

	# reasons: the first one reaches the line the owner reads.
	var cannot: Array = (SessionReport.summarise(_with("reasons", ["no flight here"])) as Dictionary)["cannot_do"]
	var carried := false
	for row in cannot:
		if str((row as Array)[1]) == "no flight here":
			carried = true
	_check(carried, "a reasons array is USED: its first reason reaches the report (got %s)" % str(cannot))

	# steps: a PLAN is a world when one of its steps is.
	var built := int((SessionReport.summarise(_session()) as Dictionary)["worlds_built"])
	var no_world := int((SessionReport.summarise(_with("steps", ["ORDER"])) as Dictionary)["worlds_built"])
	_check(no_world == built - 1,
		"a steps array is USED: a plan of no world is not counted as one (%d against %d)" % [no_world, built])


# --- section 4: the real /session end, through the scene the game launches ---
#
# What `main._end_session()` does is the thing that was costing the report, and
# it is not reachable from summarise() alone: it reads the ledger off disk,
# merges the summary into a record, writes it, and only then describes it.
func _the_real_session_end() -> void:
	main = load(str(ProjectSettings.get_setting("application/run/main_scene"))).instantiate()
	get_root().add_child(main)
	await process_frame
	await process_frame

	# TrackLog.next_id() and not a clock: it carries the process id, which is
	# the whole of TrackLog 059. The first draft used the unix second, and two
	# runs of this suite inside one second shared a session id - caught by this
	# suite's own ledger assertion below.
	var id := "%s-%s" % [SID, TrackLog.next_id()]
	TrackLog.session = {"name": "record-type", "id": id, "started": "2026-10-30T10:00:00"}
	# Appended, never written over: this is the shared user:// every copy of
	# the project uses (TRAPS 50), and truncating it would take other suites'
	# records with it.
	# THE IDS ARE ASKED FOR AND NOT WRITTEN, which is TrackLog 059 and is
	# guarded by record_id_test: "an id naming no writer is ... one that minted
	# its own id instead of asking TrackLog for one". The session above names
	# its records "r1".."r4" so that the understanding record can point at one,
	# and those names go nowhere near the ledger - the hand-written id is
	# ERASED before each append so TrackLog mints one, and `about` is remapped
	# to the id it actually minted.
	#
	# MEASURED, not reasoned. The first draft appended the records with their
	# own ids and made record_id_test go failures=0 -> failures=2 on the SECOND
	# full run in one container, while the same two runs of the tree WITHOUT
	# this suite stayed at 0 both times. Two faults in one: duplicate ids, and
	# an id naming no writer.
	var forced := 0
	var written: Array = []
	var minted := {}
	for r in _session():
		var rec: Dictionary = r as Dictionary
		if rec.has("reasons"):
			rec["reasons"] = "a string"
			forced += 1
		var own := str(rec.get("id", ""))
		if rec.has("about"):
			rec["about"] = str(minted.get(str(rec["about"]), str(rec["about"])))
		rec.erase("id")
		TrackLog.append(rec)
		if own != "":
			minted[own] = str(rec.get("id", ""))
			written.append(str(rec.get("id", "")))
	# Counted off the session above rather than written here, so adding a
	# record with a `reasons` to it cannot leave this expectation stale.
	_check(forced > 0, "at least one record in the session above carries a \"reasons\" to damage")

	var before: int = main.history_log.get_parsed_text().length()
	main._run_local_command("/session end")
	await process_frame

	_check(TrackLog.session.is_empty(), "the session ended")

	# Every id this suite put in the shared ledger appears ONCE. Asserted here
	# rather than left to record_id_test, which is where the first draft's
	# duplicate was actually caught.
	var seen := {}
	var ledger := FileAccess.open(TrackLog.PATH, FileAccess.READ)
	if ledger != null:
		while not ledger.eof_reached():
			var l := ledger.get_line().strip_edges()
			if l == "":
				continue
			var rc = JSON.parse_string(l)
			if typeof(rc) != TYPE_DICTIONARY:
				continue
			var rid := str((rc as Dictionary).get("id", ""))
			seen[rid] = int(seen.get(rid, 0)) + 1
		ledger.close()
	_check(not written.is_empty(), "this suite wrote records with ids of its own")
	var twice: Array = []
	for rid in written:
		if int(seen.get(rid, 0)) != 1:
			twice.append("%s x%d" % [rid, int(seen.get(rid, 0))])
	_check(twice.is_empty(),
		"and each of them appears exactly once in the shared ledger (TrackLog 059)%s" % (
			"" if twice.is_empty() else " - %s" % str(twice)))
	var added: int = main.history_log.get_parsed_text().length() - before
	# Before 099 this was the length of "> /session end" and two newlines: the
	# report itself was empty. Asserted as "more than the request line", not
	# as a number of characters, so rewording the report is not a failure.
	_check(added > 40,
		"and the history panel got a report rather than a blank line (%d characters)" % added)

	var summary := {}
	var file := FileAccess.open(TrackLog.PATH, FileAccess.READ)
	_check(file != null, "the ledger could be read back off disk")
	if file != null:
		while not file.eof_reached():
			var line := file.get_line().strip_edges()
			if line == "":
				continue
			var rec = JSON.parse_string(line)
			if typeof(rec) != TYPE_DICTIONARY:
				continue
			if str((rec as Dictionary).get("type", "")) != "session_summary":
				continue
			var tag = (rec as Dictionary).get("session", null)
			if typeof(tag) == TYPE_DICTIONARY and str((tag as Dictionary).get("id", "")) == id:
				summary = rec as Dictionary
		file.close()

	# THE CAPABILITY, and it is the one the fault cost: the record this session
	# leaves behind carries its numbers. Before 099 it carried four keys.
	_check(not summary.is_empty(), "the session left a session_summary record of its own")
	for key in ["requests", "worlds_built", "loads", "damaged"]:
		_check(summary.has(key),
			"and that record carries \"%s\", the number the empty summary lost" % key)
	if summary.has("damaged"):
		var dmg = summary["damaged"]
		_check(typeof(dmg) == TYPE_DICTIONARY and int((dmg as Dictionary).get("records", 0)) == forced,
			"and it says %d of its records were damaged, rather than saying nothing (got %s)" % [forced, str(dmg)])


func _run() -> void:
	_the_class_is_closed_by_the_code()
	_every_field_against_every_type()
	_an_admitted_type_is_used()
	await _the_real_session_end()

	print("RECORD TYPE %d assertions, failures=%d" % [asserted, bad])
	quit(1 if bad > 0 else 0)
