extends SceneTree

# --- 059: the id two writers could both mint ---
#
# WHERE THIS CAME FROM, AND IT WAS NOT ON THE ROADMAP
#
# HANDOVER's next assistant task was the seven connect() rows of main.gd's
# sixteen still marked NOT_ASKED. They were measured (the answers are in
# HANDOVER's 059 section). While measuring them, intent_door_test failed
# EIGHT, EIGHT, SEVEN and EIGHT under four wire-outs that cannot reach it -
# two experiment connects, a lap connect and a button connect, none of which
# that suite mentions - and failed NOTHING under the other three or under a
# pristine control run of the same copy.
#
# That is TRAPS 50's signature read off the page: "a suite fails under a
# change that cannot possibly affect it, the same suite fails under every
# change, and the failures vanish when the measurement is repeated." The
# varying count - 7 one time, 8 the next - is the part that settles it. A
# wire-out does not fail a different number of assertions each time.
#
# THE CAUSE, MEASURED RATHER THAN REASONED ABOUT
#
# TrackLog.next_id() was "<unix seconds>-<serial>". `serial` is a static that
# restarts at 0 in every process. So two processes writing to one ledger mint
# THE SAME IDS whenever they overlap inside one wall-clock second.
#
# Two Godot processes, three records each, one user://track_log.jsonl,
# twelve paired runs: EVERY id collided in EIGHT of the twelve. Not a
# theory about a clock - a count.
#
# And one ledger with two writers is the normal state of this repository, not
# an edge case. Every copy of the project shares one user:// (TRAPS 50), and
# run_tests.sh starts 63 processes against it a fraction of a second apart.
# intent_door_test looks its own record up by id with _record_for(), which
# returns the FIRST match in the file - so when handler_wiring_test (the
# suite that runs immediately before it) had already written that id, the
# lookup returned handler_wiring_test's record and the assertions about this
# suite's own request failed.
#
# WHAT IT COST BEYOND THE HARNESS, read off the readers rather than guessed:
#
#   - session_report._understanding() keys evidence by id. Of two records
#     sharing one, the report attributes ONE's understanding verdict to the
#     OTHER - a true-looking score about the wrong request, in the artefact
#     this project exists to keep.
#   - game_controller.gd:420 writes a delivery's evidence as
#     "about": <the order's id>. A duplicate makes the proof of a delivery
#     point at two orders.
#   - FIVE suites and session_report scan for an id and take the first
#     match. Not one of them says anything when there are two.
#
# AND IT INVALIDATES PART OF THE METHOD THIS PROJECT MEASURES WITH. Every
# commit since 055 reports "the lists were diffed and are identical". Those
# diffs were taken with a suite in them that can fail for this reason in
# roughly two runs out of three. The claims were true of the runs they
# describe; the instrument had a coin flip in it. That is the finding worth
# more than the connect rows this session was sent to measure.
#
# WHAT IS ASSERTED HERE, AND WHAT IS NOT (TRAPS 6, TRAPS 14)
#
# The capability, not the wording: an id is a UNIQUE handle on a record. The
# assertions below are about uniqueness and about the mechanism that makes it
# impossible to lose, never about how the string reads.
#
# AND THE FIRST DRAFT OF THIS FILE ASSERTED SOMETHING FALSE ABOUT GENESIS,
# which is recorded here rather than quietly corrected (TRAPS 6, TRAPS 14).
# It asserted "no two records in the ledger share an id" and FAILED in a
# full run, on 2 of 22 ids. Reading the records rather than the count: a
# PLAN request writes THREE records under ONE id - the plan's own, and one
# for each world it builds - because they are all the same request, and
# intent_door_test._plan_record() exists precisely because an id is not
# enough to tell them apart. Records sharing an id WITHIN one process is
# deliberate and has been since PLAN existed.
#
# So a bare no-duplicates assertion is a claim about Genesis that is simply
# untrue, and it would have failed for an honest reason while saying nothing
# about the fault this file is for. The invariant that WAS broken, and the
# only one worth asserting, is narrower:
#
#   two records written by DIFFERENT PROCESSES must never share an id.
#
#   HELD HERE:
#     - every id in the ledger carries a writer, and records that share an
#       id share a writer - the real invariant, not "no duplicates"
#     - this process cannot mint an id that is already in the ledger, which
#       in a full run is a ledger 62 other processes have written to. THIS IS
#       THE ASSERTION THE FAULT BROKE.
#     - the id carries the writing process's own identity, so the day that
#       component is dropped this suite says so rather than waiting for a
#       collision to happen to land
#     - a writer differing ONLY in process identity mints a different id
#     - append() gives an id to a record that arrives without one, and does
#       not overwrite one that arrives with it
#
#   NOT HELD HERE, AND SAID PLAINLY: that two real OS processes never
#   collide is NOT asserted by this file. Asserting it needs a second
#   process, and a suite that spawns one would be this project's first, and
#   a test that races a clock passes or fails on where the second boundary
#   falls - which is the fault itself, not a test for it. The proof that the
#   old code DID collide is the 8-of-12 count above, taken by hand and
#   recorded in HANDOVER. The proof that the new code CANNOT is structural
#   and is the third assertion: two processes have two process ids.
#
# NOT VERIFIED BY THIS FILE AT ALL: nothing was rendered, no model was
# asked anything, and no request left the container.

var asserted := 0
var bad := 0


func _check(ok: bool, what: String) -> void:
	asserted += 1
	if ok:
		print("PASS  ", what)
	else:
		bad += 1
		print("  FAIL  ", what)


func _initialize() -> void:
	_run.call_deferred()


# Every id in the ledger, in file order, with duplicates kept so they can be
# counted. Read as an outsider would, off disk.
func _ids_on_disk() -> Array:
	var out: Array = []
	if not FileAccess.file_exists(TrackLog.PATH):
		return out
	var file := FileAccess.open(TrackLog.PATH, FileAccess.READ)
	if file == null:
		return out
	while not file.eof_reached():
		var line := file.get_line().strip_edges()
		if line == "":
			continue
		var record = JSON.parse_string(line)
		if typeof(record) == TYPE_DICTIONARY and (record as Dictionary).has("id"):
			out.append(str((record as Dictionary)["id"]))
	file.close()
	return out


func _duplicates(ids: Array) -> Array:
	var seen := {}
	var twice := {}
	for id in ids:
		if seen.has(id):
			twice[id] = true
		seen[id] = true
	return twice.keys()


# The writer an id names, or "" if it names none. Read off the id's own
# fields rather than from the format written out again (TRAPS 28).
func _writer_of(id: String) -> String:
	var fields := id.split("-")
	return str(fields[1]) if fields.size() == 3 else ""


# Ids in the ledger that name no writer at all. One of these is a record
# written by the pre-059 code, or by something that minted an id itself
# instead of asking TrackLog for one.
func _writerless(ids: Array) -> Array:
	var out: Array = []
	for id in ids:
		if _writer_of(str(id)) == "":
			out.append(str(id))
	return out


# --- 066: the id class, read off the source rather than remembered ---
#
# TRAPS 56's "Do" ends with an instruction this file did not follow: "then ask
# it of the class and write down the size of the answer, grepped rather than
# remembered." 059 fixed ONE member of the class and the other two were
# written into HANDOVER and TRAPS as prose. Prose is not a reader: nothing in
# this repository would have said anything if a fourth time-minted identifier
# had been added, and nothing said anything about the two that were left.
#
# Sections 8 and 9 are that reader. 8 is about the HARNESS and holds a rule;
# 9 is about GENESIS and holds a fact, because the product's two unmoved
# identifiers are "Human decision needed" 22 and a suite does not get to
# answer that.

# Every file in tests/ that starts a named session, and the lines it does it
# on. A session start is "/session <something other than end>"; "/session end"
# and a bare "/session" are not starts.
#
# The needle is BUILT rather than typed, so that this file does not match
# itself: every line below that talks about the command would otherwise be a
# session start as far as this scan is concerned.
func _session_starts() -> Dictionary:
	var needle := "\"/" + "session "
	var out := {}
	var dir := DirAccess.open("res://tests")
	if dir == null:
		return out
	for file_name in dir.get_files():
		var name := str(file_name)
		if not name.ends_with(".gd"):
			continue
		var file := FileAccess.open("res://tests/" + name, FileAccess.READ)
		if file == null:
			continue
		# Read off the CODE (067). The per-line skip below already dropped a
		# whole-line comment; _code_of() also cuts a trailing one, and the
		# line count is preserved so the "file:line" this reports is right.
		var source := _code_of(file.get_as_text())
		file.close()
		var found: Array = []
		var number := 0
		for raw in source.split("\n"):
			var line := str(raw)
			number += 1
			if line.strip_edges().begins_with("#"):
				continue
			var at := line.find(needle)
			if at < 0:
				continue
			# An assertion MESSAGE is not a session start. Found by fault 2:
			# session_test.gd:62 reads _check(..., "/session alone reports the
			# running session"), and the first version of this scan counted it,
			# so the fault's report named a line that starts nothing. Harmless
			# where the file does start a session elsewhere; a file whose ONLY
			# mention of the command is in a message would have been flagged
			# for nothing. Nothing in tests/ runs a command from inside a
			# _check() argument, so this cannot hide a real start.
			if line.contains("_check("):
				continue
			# What follows the command word. "end" is not a start.
			var rest := line.substr(at + needle.length()).strip_edges()
			if rest.begins_with("end"):
				continue
			found.append("%s:%d" % [name, number])
		if not found.is_empty():
			out[name] = found
	return out


# Does this source ask the OS who this process is, IN CODE? Comment lines are
# skipped, and that is not fastidiousness: the first version of section 8
# read the whole file, and the FIRST deliberate fault - reverting
# handler_wiring_test's session name to the bare string it had before 066 -
# PASSED, because the comment this file's own fix added to that suite says
# "OS.get_process_id()" in prose. A check a comment can satisfy is TRAPS 6
# in a test rather than in the code it measures.
# 067 moved the stripping this function did by hand into _code_of(), which is
# now the one reader every source scan in tests/ goes through - because the
# same blind spot was found in three more scans that had never been asked.
# Same rule, same answer, one implementation. See TRAPS 64.
func _asks_who_it_is(source: String) -> bool:
	return _code_of(source).contains("OS.get_process_id()")


# A line of a file in scripts/, by the text that identifies it. Returns "" if
# no line contains it, so an assertion can say the site has moved rather than
# failing on something unrelated.
func _script_line(path: String, contains: String) -> String:
	var file := FileAccess.open("res://scripts/" + path, FileAccess.READ)
	if file == null:
		return ""
	var source := _code_of(file.get_as_text())
	file.close()
	for raw in source.split("\n"):
		var line := str(raw)
		if line.contains(contains):
			return line
	return ""


func _run() -> void:
	print("--- 059: a record id is a unique handle, or it is not a handle ---")

	# --- 1. every id in the ledger names its writer ---
	#
	# In a full run this is a ledger that 62 other Godot processes have
	# written to before this suite started, which is exactly the situation
	# that broke intent_door_test. An id naming no writer is a record the
	# pre-059 code wrote, or one that minted its own id instead of asking
	# TrackLog for one - either way it is an id another process could mint
	# too.
	var before := _ids_on_disk()
	var nameless := _writerless(before)
	_check(nameless.is_empty(),
		"every id in the ledger names the process that wrote it (%d ids on disk, %d naming nobody%s)" % [
			before.size(), nameless.size(),
			"" if nameless.is_empty() else ": " + str(nameless.slice(0, 3))])

	# --- 2. records that share an id share a writer ---
	#
	# NOT "no two records share an id", which is false about Genesis: a PLAN
	# writes three records under one id, deliberately, because they are one
	# request. The first draft of this file asserted the false version and
	# duly failed on a PLAN. What must never happen is two PROCESSES sharing
	# an id, because then a reader scanning for it gets somebody else's
	# record - which is the fault this file is for.
	var writers_per_id := {}
	for id in before:
		var key := str(id)
		if not writers_per_id.has(key):
			writers_per_id[key] = {}
		(writers_per_id[key] as Dictionary)[_writer_of(key)] = true
	var shared := ""
	for key in writers_per_id:
		if (writers_per_id[key] as Dictionary).size() > 1:
			shared = str(key)
			break
	_check(shared == "",
		"no id in the ledger was written by two different processes" if shared == "" else
		"an id was written by two different processes: " + shared)

	# --- 2. this process cannot mint an id that is already in the ledger ---
	#
	# The old code could, and that is the whole fault: another process's
	# "<second>-1" is this process's "<second>-1" too. Minted, not written,
	# so the check is about the id and not about the file.
	var already := {}
	for id in before:
		already[id] = true
	var minted: Array = []
	for i in 40:
		minted.append(TrackLog.next_id())
	var clash := ""
	for id in minted:
		if already.has(id):
			clash = str(id)
			break
	_check(clash == "",
		"none of 40 fresh ids is already in the ledger" if clash == "" else
		"a fresh id was already in the ledger: " + clash)

	# --- 3. and they are distinct from each other ---
	var mine_dupes := _duplicates(minted)
	_check(mine_dupes.is_empty(),
		"and the 40 are distinct from one another (%d duplicated)" % mine_dupes.size())

	# --- 4. the mechanism: the writer's own identity is in the id ---
	#
	# This is the assertion that fails the day the process component is
	# dropped, instead of waiting for two processes to land in one second and
	# for somebody to notice which suite went red. Against the pre-059 code
	# the id has two fields and this fails.
	var one := TrackLog.next_id()
	var fields := one.split("-")
	_check(fields.size() == 3,
		"an id is three fields - when, who, and which (%d: %s)" % [fields.size(), one])
	if fields.size() == 3:
		_check(str(fields[1]) == str(OS.get_process_id()),
			"and the middle one is THIS process's id, so no other process can mint this id")

		# --- 5. a writer differing only in who it is mints a different id ---
		#
		# Built from this id's own fields rather than from the format typed
		# out again (TRAPS 28): same second, same serial, one different
		# writer. Under the pre-059 code there was no field to differ in and
		# the two were the same string.
		var other_pid := str(int(str(fields[1])) + 1)
		var as_other := "%s-%s-%s" % [fields[0], other_pid, fields[2]]
		_check(as_other != one,
			"the same second and the same serial, written by another process, is a different id")

	# --- 6. append() owns the id when the record has none ---
	#
	# The door every record in the ledger comes through. Checked both ways
	# because a writer that overwrote a caller's id would break the evidence
	# pointers in the other direction.
	var handed := TrackLog.next_id()
	var with_id := {"type": "id_test", "note": "arrived with an id", "id": handed}
	TrackLog.append(with_id)
	_check(str(with_id.get("id", "")) == handed,
		"append() leaves an id the caller already set")

	var without := {"type": "id_test", "note": "arrived without one"}
	TrackLog.append(without)
	_check(str(without.get("id", "")) != "",
		"and gives one to a record that arrives without it")

	# --- 7. and the invariant still holds after writing ---
	var after := _ids_on_disk()
	_check(_writerless(after).is_empty(),
		"every id still names its writer after this suite wrote to the ledger (%d ids, %d naming nobody)" % [
			after.size(), _writerless(after).size()])
	# The two records this suite wrote carry different ids: it asked for each
	# separately, so unlike a PLAN's three they are two requests, not one.
	_check(_duplicates([handed, str(without.get("id", ""))]).is_empty(),
		"and the two records this suite wrote carry different ids")
	_check(after.size() >= before.size() + 2,
		"and the two records this suite wrote are on disk (%d ids before, %d after)" % [
			before.size(), after.size()])

	# --- 8. THE HARNESS: every suite that starts a session names its own
	#        process (066, TRAPS 63) ---
	#
	# WHY THIS IS A SUITE AND NOT A NOTE. main.gd:515 mints a session id as
	# "<name> <datetime to the second>", and TrackLog.read_session() returns
	# every record carrying that id out of one user:// that every copy of this
	# project shares (TRAPS 50). So a suite that starts a session under a
	# fixed name, and then reads its own records back by id, is reading any
	# other process's records that started a session of the same name in the
	# same second.
	#
	# REPRODUCED BEFORE IT WAS FIXED, six paired concurrent runs of
	# handler_wiring_test against one ledger: in FIVE of the six, one of the
	# pair failed "the ledger gained exactly one ai_unavailable event (got 3)"
	# and returned early, scoring 44 assertions where a clean run scores 47.
	# A varying assertion count under a treatment that cannot reach the suite
	# is TRAPS 56's signature, and it is the trap that cost 059 a day.
	#
	# THE RULE, APPLIED TO THE CLASS AND NOT THE INSTANCE (TRAPS 11): a suite
	# that starts a session must name it with something only that process has.
	# Before 066 there were three such suites and ONE defended itself -
	# ledger_audit_test, with Time.get_ticks_msec(), which is a clock and
	# therefore the one thing TRAPS 56 says does not qualify at any
	# granularity.
	#
	# This is checked at FILE granularity on purpose: the name may be built
	# anywhere in the file (handler_wiring_test keeps it in a member, this
	# file's own fix to session_test keeps it in a local), so what is asserted
	# is that a file which starts a session also asks the OS who it is. A
	# fourth suite that starts a session without doing so fails here, by name.
	var starts := _session_starts()
	_check(not starts.is_empty(),
		"at least one suite in tests/ starts a session, so this section is measuring something (%d)" % starts.size())
	var undefended: Array = []
	for file_name in starts:
		var file := FileAccess.open("res://tests/" + str(file_name), FileAccess.READ)
		if file == null:
			undefended.append(str(file_name) + " (unreadable)")
			continue
		var source := file.get_as_text()
		file.close()
		if not _asks_who_it_is(source):
			undefended.append("%s (%s)" % [file_name, ", ".join(PackedStringArray(starts[file_name]))])
	_check(undefended.is_empty(),
		"every suite that starts a session names its own process: %s" % str(starts.keys()) if undefended.is_empty() else
		"a suite starts a session under a name another process could mint too: " + ", ".join(PackedStringArray(undefended)))

	# --- 9. GENESIS: the three members of the class, and which two are still
	#        the owner's to decide (066) ---
	#
	# NOT A RULE. A FACT, and labelled so nobody reads it as approval. The
	# session id and the experiment run_id are "Human decision needed" 22:
	# changing the session id changes session reports the owner already has,
	# and run_id needs an API key this harness does not have. 059 left both
	# deliberately and asked. Until he answers, what a suite can honestly do
	# is say that the answer has not changed - so that the day it does, the
	# next session is told rather than left to grep for it.
	#
	# Each site is found by the text that identifies it, so a site that MOVES
	# reports as moved rather than as fixed.
	var mint_record := _script_line("track_log.gd", "static func next_id")
	_check(mint_record != "",
		"the record id is minted in track_log.gd's next_id(), which is where this file's sections 1-7 found it")
	# THE ONE open() READ OF A NAMED FILE IN tests/ THAT HAD NO GUARD (085).
	# `open()` returns null for a path that is not there, so this is the idiom
	# that CAN be asked directly - and the null was being used as a branch
	# condition and never asserted. The read was held only by
	# `record_body != ""` below, whose message is about whether the mint asks
	# the OS who it is, so a moved or renamed track_log.gd reported as a
	# missing capability rather than as a missing file. See TRAPS 82: the 084
	# record bucketed this site under the string-returning idiom and concluded
	# that every open() read among the eight was guarded.
	var track_log := FileAccess.open("res://scripts/track_log.gd", FileAccess.READ)
	_check(track_log != null, "track_log.gd can be read")
	var record_body := ""
	if track_log != null:
		var track_log_source := track_log.get_as_text()
		track_log.close()
		if _asks_who_it_is(track_log_source):
			record_body = "track_log.gd"
	_check(record_body != "",
		"FIXED (059): the record id's mint asks the OS who this process is, in code and not in a comment")

	var mint_session := _script_line("main.gd", "TrackLog.session = {\"name\"")
	_check(mint_session != "",
		"the session id is minted in one place in main.gd, and this is it")
	if mint_session != "":
		# The capability, not the wording: what matters is whether a second
		# writer can read every value this recipe uses, not how the string
		# reads. `started` is a wall-clock datetime; nothing here is the
		# writer's own.
		_check(not mint_session.contains("OS.get_process_id()"),
			"OPEN (Human decision 22): the session id still carries no writer, so two testers of one name in one second still share it")
		_check(mint_session.contains("started"),
			"and what it carries instead is a wall-clock second, which TRAPS 56 says is not an identity")

	var mint_run := _script_line("experiment_runner.gd", "run_id = ")
	_check(mint_run != "",
		"the experiment run_id is minted in one place in experiment_runner.gd, and this is it")
	if mint_run != "":
		_check(not mint_run.contains("OS.get_process_id()") and mint_run.contains("Time."),
			"OPEN (Human decision 22): run_id is still a clock and nothing else - the weakest of the three, and it needs a key to reach")

	# The size of the class, stated rather than remembered. Three mints of an
	# identifier in scripts/, one fixed and two open. A fourth cannot be added
	# in silence: it has to come through one of these three functions or this
	# count is wrong.
	var mints := 0
	for line in [record_body, mint_session, mint_run]:
		if str(line) != "":
			mints += 1
	_check(mints == 3,
		"the class is three members - the record id, the session id and the experiment run_id (found %d)" % mints)

	print("RECORD ID %d assertions, failures=%d" % [asserted, bad])
	quit(bad)


# The CODE of a .gd source: comment lines blanked and trailing comments cut,
# with the line count preserved so a scan that reports a line number still
# reports the right one. A question about what the code DOES is answered from
# this. A question about what is MENTIONED anywhere is a different question
# and reads the raw file; which one a scan is asking is decided by the
# direction of its assertion and not by habit.
#
# WHY THIS EXISTS. 066 found that the first version of record_id_test's
# session scan was satisfied by a comment saying OS.get_process_id() in
# prose, and fixed it in that one function. 067 asked the same question of
# every source scan in tests/ and MEASURED three more, each flipped from FAIL
# to PASS by one comment line. See TRAPS 64.
#
# NOT A PARSER. A "#" inside a string literal cuts the line early, which can
# only lose a code match and never invent one - so this is safe in the one
# direction that matters: nothing a comment says can make a presence check
# pass.
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
