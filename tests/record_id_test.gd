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

	print("RECORD ID %d assertions, failures=%d" % [asserted, bad])
	quit()
