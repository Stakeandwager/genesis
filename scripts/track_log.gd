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


static func append(record: Dictionary) -> void:
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
