extends RefCounted
class_name TrackLog

# --- Prototype 002A - Step A6: The experiment record ---
# Every composed-track attempt, successful or not, is appended here as one
# line of JSON. Failed generations are kept on purpose: they are results too.
# The file lives in Godot's user data folder, outside the project, so it is
# never committed by accident.

const PATH := "user://track_log.jsonl"


static func append(record: Dictionary) -> void:
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


# The real folder on this computer, so it can be found in File Explorer.
static func location() -> String:
	return ProjectSettings.globalize_path(PATH)
