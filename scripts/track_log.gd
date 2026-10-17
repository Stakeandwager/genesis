extends RefCounted
class_name TrackLog

# --- Prototype 002A - Step A6: The experiment record ---
# Every composed-track attempt, successful or not, is appended here as one
# line of JSON. Failed generations are kept on purpose: they are results too.
# The file lives in Godot's user data folder, outside the project, so it is
# never committed by accident.
#
# --- 002G: player testing sessions ---
# While a session is running (/session NAME), every record written here gets
# a "session" field: {"name": ..., "id": ...}. The id is the name plus the
# start time, so two sessions with the same tester stay apart. Outside a
# session nothing is added, so records look exactly as they always have.

const PATH := "user://track_log.jsonl"

# {"name": ..., "id": ..., "started": ...} while a session runs, else empty.
static var session: Dictionary = {}


# 003: every record gets an id, so that evidence arriving later - the player
# confirming or correcting what Genesis said it understood - can be written
# as its own record pointing back at this one. The original interpretation
# is never edited: history is added to, not rewritten.
static var serial: int = 0

# 059: and the id has to be UNIQUE, because it is the only thing tying a
# later record to an earlier one. It was "<unix seconds>-<serial>", and
# `serial` restarts at 0 in every process, so TWO WRITERS ON ONE LEDGER mint
# the same ids whenever they overlap inside one wall-clock second. Measured,
# not inferred: two Godot processes appending three records each to one
# user://track_log.jsonl collided on EVERY id in 8 of 12 paired runs.
#
# One ledger with two writers is not a hypothetical - it is the normal state
# of this repository. Every copy of the project shares one user:// (TRAPS 50)
# and run_tests.sh starts 64 suite processes against it, one after another, a
# fraction of a second apart.
#
# WHAT A DUPLICATE COSTS, read off the readers rather than guessed:
#   - session_report._understanding() keys evidence by id, so of two records
#     sharing one, the report attributes ONE's understanding verdict to the
#     OTHER and the owner reads a true-looking score about the wrong request.
#   - game_controller.gd:420 writes a delivery's evidence as
#     "about": <the order's id>, so a duplicate makes the proof of a
#     delivery point at two orders.
#   - every reader that scans for an id takes the FIRST match and says
#     nothing (intent_door_test._record_for, ledger_said_test, and three
#     more), so the wrong record is returned as the right one, silently.
#
# The fix is the writer's own identity in the id, so no clock granularity can
# make two processes agree. OS.get_process_id() rather than a random salt
# because it NAMES the writer: a duplicate is now impossible and a record
# also says which process wrote it. Nothing parses this string - grepped
# across scripts/ and tests/, every consumer compares it whole - so widening
# it breaks no reader.
static func next_id() -> String:
	serial += 1
	return "%d-%d-%d" % [Time.get_unix_time_from_system(), OS.get_process_id(), serial]


static func append(record: Dictionary) -> void:
	if not record.has("id"):
		record["id"] = next_id()
	if not session.is_empty():
		record["session"] = {"name": session["name"], "id": session["id"]}

	var file: FileAccess
	if FileAccess.file_exists(PATH):
		file = FileAccess.open(PATH, FileAccess.READ_WRITE)
		if file:
			file.seek_end()
	else:
		file = FileAccess.open(PATH, FileAccess.WRITE)

	if file == null:
		push_warning("Could not write the track log at " + location())
		return

	file.store_line(JSON.stringify(record))
	file.close()


# Something the player did that is not a world: started driving, started a
# race, or found the AI unavailable. Only written during a session, so
# experiments and ordinary play leave the log as it was.
static func event(name: String, details: Dictionary = {}) -> void:
	if session.is_empty():
		return
	var record := {"type": "session_event", "time": Time.get_datetime_string_from_system(), "event": name}
	record.merge(details)
	append(record)


# Every record of one session, oldest first.
static func read_session(id: String) -> Array:
	var out: Array = []
	if not FileAccess.file_exists(PATH):
		return out
	var file := FileAccess.open(PATH, FileAccess.READ)
	if file == null:
		return out
	while not file.eof_reached():
		var line := file.get_line().strip_edges()
		if line == "":
			continue
		var record = JSON.parse_string(line)
		if typeof(record) != TYPE_DICTIONARY:
			continue
		var tag = record.get("session", null)
		if typeof(tag) == TYPE_DICTIONARY and str(tag.get("id", "")) == id:
			out.append(record)
	file.close()
	return out


# The real folder on this computer, so it can be found in File Explorer.
static func location() -> String:
	return ProjectSettings.globalize_path(PATH)
