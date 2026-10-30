extends SceneTree

# --- 098: the type of every field a saved world file carries ---
#
# WHAT THIS MEASURES, and why it is not world_store.gd's own word for it.
#
# WorldStore.load_world() is the ONLY door between a save file a player can
# edit by hand and every reader of that file: main.gd quotes its "command"
# back in a refusal, puts its "name" into the ledger record AND into the next
# prompt the model is sent, puts its "saved" into that record's source, and
# compares its "metrics" against what was just built. Before 098 that door
# checked THREE things over SIX fields - the text parsed to a dictionary,
# "command" was PRESENT, "parameters" was a dictionary - so a field present
# with the wrong type walked through it.
#
# Driven in 098, through the real main.gd, before anything was changed:
#
#   "command": null   -> "'<NULL>' is not a command this game has."
#   "command": 7      -> "'7.0' is not a command this game has."
#   "command": []     -> "'[]' is not a command this game has."
#   "name": null      -> ledger record request "load <null>", AND the next
#                        prompt: The player asked for: "load <null>"
#   "name": 12        -> "load 12.0", and the same prompt line
#   "saved": null     -> the record's source carried "saved": null
#   "metrics": null   -> the load check was SKIPPED IN SILENCE: the one build
#                        whose right answer was written down in advance was
#                        not compared, and nothing said so.
#
# THE SHAPE OF THIS SUITE IS THE POINT, because the fault was a check that
# knew about fewer fields than the file has. Nothing here is keyed off a list
# of field names written in a test. Section 1 calls save_world() FOR REAL and
# reads the file back off disk, so the fields under test are the fields the
# game writes; a seventh field added to save_world() without a type beside it
# fails in section 1 BY ITS OWN NAME (TRAPS 82), and a field that stops being
# type-checked fails in section 2 by its name. There is no expected count in
# this file.
#
# AND SECTION 4 ASKS THE CAPABILITY AND NOT THE WORDING (TRAPS 6, TRAPS 14).
# It does not assert that any sentence reads a particular way. It drives the
# real /load path and asks whether ANY sentence a player meets, and any field
# of the record written, carries the engine's spelling of a value - screened
# through Readback.ENGINE_NOTHING, CASE-INSENSITIVELY, because 096 and 097
# both found this class hiding behind a to_upper() (TRAPS 78).

var main: Node3D
var asserted := 0
var bad := 0
var written_by_save_world: Dictionary = {}
# Per FIELD, how many wrong-typed forms of it section 2 actually saw refused
# and how many sentences section 4 actually screened. Measured in 098 before
# they existed: emptying section 4's collection gave 88 assertions,
# failures=0 - SILENT - and emptying the poison list gave 28, failures=0 -
# SILENT. Both are the hole 096 wrote down and 097 closed in says_nothing_test,
# found a third time in the suite written to close it. The close is the same
# one: not a count of the whole collection, which is a floor a lost field
# falls inside (TRAPS 85), but a question asked OF EACH FIELD, so a field
# that stops being driven fails BY ITS OWN NAME and no number appears here.
var refused_forms: Dictionary = {}
var screened_sentences: Dictionary = {}

const NAME := "world-file-test"


func _check(ok: bool, what: String) -> void:
	asserted += 1
	if not ok:
		bad += 1
		print("  FAIL  ", what)


func _initialize() -> void:
	_run.call_deferred()


# main.gd, stood up from the scene the game actually launches, as
# controller_reach_test and command_schema_test both do.
func _make_main() -> void:
	main = load(str(ProjectSettings.get_setting("application/run/main_scene"))).instantiate()
	get_root().add_child(main)


func _path() -> String:
	return "%s/%s%s" % [WorldStore.FOLDER, NAME, WorldStore.SUFFIX]


func _write(data: Dictionary) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(WorldStore.FOLDER))
	var file := FileAccess.open(_path(), FileAccess.WRITE)
	# Checked rather than assumed: an open that came back null would otherwise
	# abandon this function and every assertion below it, which is the shape
	# 078 found reading as a pass.
	_check(file != null, "the hand-written save file could be opened for writing")
	if file == null:
		return
	file.store_string(JSON.stringify(data, "\t"))
	file.close()


func _read_file() -> Variant:
	var file := FileAccess.open(_path(), FileAccess.READ)
	if file == null:
		return null
	var text := file.get_as_text()
	file.close()
	return JSON.parse_string(text)


# A world that really builds, so the /load path in section 4 reaches the end
# of main._load_world() rather than stopping at a schema refusal. Eight
# sections, because a track needs two to forty.
static func _buildable() -> Dictionary:
	var sections: Array = []
	for i in 4:
		sections.append({"type": "straight", "length": 200})
		sections.append({"type": "corner", "radius": 40, "angle": 90})
	return {"mode": "circuit", "sections": sections}


func _run() -> void:
	_make_main()
	await process_frame
	await process_frame

	_the_fields_save_world_writes()
	_every_field_of_the_wrong_type()
	_a_file_that_is_merely_older()
	await _nothing_said_carries_the_engines_spelling()

	WorldStore.remove_world(NAME)
	print("WORLD FILE %d assertions, failures=%d" % [asserted, bad])
	quit(1 if bad > 0 else 0)


# --- 1. the declaration is held against the function, not beside it ---
#
# WorldStore.FIELD_TYPES is a list of field names in a source file, which is
# the shape TRAPS 82 warns about: it can drift from the function it describes
# and nothing would notice. So it is asserted against what save_world()
# ACTUALLY WROTE, read back off the file, in both directions and by name.
func _the_fields_save_world_writes() -> void:
	var result := WorldStore.save_world(NAME, "CREATE_TRACK", _buildable(), {"length_m": 1051.0}, "a square track")
	_check(bool(result.get("ok", false)), "save_world wrote a file (%s)" % str(result.get("message", "")))
	if not bool(result.get("ok", false)):
		return

	var data = _read_file()
	_check(typeof(data) == TYPE_DICTIONARY, "the file save_world wrote parses to a dictionary")
	if typeof(data) != TYPE_DICTIONARY:
		return
	written_by_save_world = data

	for field in data:
		_check(WorldStore.FIELD_TYPES.has(field),
			"save_world writes '%s', so load_world declares a type for it" % str(field))
		if WorldStore.FIELD_TYPES.has(field):
			_check(typeof(data[field]) == WorldStore.FIELD_TYPES[field],
				"'%s' is declared as the type save_world really wrote (%d)" % [str(field), typeof(data[field])])

	for field in WorldStore.FIELD_TYPES:
		_check(data.has(field),
			"load_world declares a type for '%s', and save_world writes that field" % str(field))

	# And the good file loads. Everything below is a departure from this one.
	var loaded := WorldStore.load_world(NAME)
	_check(bool(loaded.get("ok", false)),
		"the file save_world just wrote loads (%s)" % str(loaded.get("message", "")))


# --- 2. one field at a time, set to a type save_world cannot write ---
#
# The fields come from section 1's file, so this loop cannot go stale against
# save_world(), and the poison values are chosen by what save_world writes
# rather than per field: it writes no nulls - every parameter is typed String
# or Dictionary and Time.get_datetime_string_from_system() is a String - and
# it writes no arrays anywhere at the top level. So null and [] are the wrong
# type for every field there is, and neither needs a table.
#
# EACH FIELD IS NAMED IN ITS OWN ASSERTION. A field that stops being checked
# fails here by its name rather than by a count coming out one short, which
# is the property 097 put into says_nothing_test for the same reason.
func _every_field_of_the_wrong_type() -> void:
	if written_by_save_world.is_empty():
		_check(false, "section 1 produced a file for section 2 to poison")
		return

	for field in written_by_save_world:
		for poison in [null, []]:
			var data := written_by_save_world.duplicate(true)
			data[field] = poison
			_write(data)

			_check(WorldStore.damaged_fields(data) == [field],
				"damaged_fields names '%s' and only '%s' when it is %s" % [
					str(field), str(field), "null" if poison == null else "an array"])

			var loaded := WorldStore.load_world(NAME)
			var refused := not bool(loaded.get("ok", true))
			if refused:
				refused_forms[field] = int(refused_forms.get(field, 0)) + 1
			_check(refused,
				"a file whose '%s' is %s is refused" % [
					str(field), "null" if poison == null else "an array"])
			# The sentence is the one that already existed for a damaged file.
			# Asserted as "it says the file is damaged", not by quoting the
			# whole sentence, so rewording it is not a failure here.
			_check(str(loaded.get("message", "")).to_lower().contains("damaged"),
				"the refusal for '%s' says the file is damaged" % str(field))
			_check(not str(loaded.get("message", "")).to_lower().contains(
					Readback.ENGINE_NOTHING.to_lower()),
				"the refusal for '%s' does not quote the engine's spelling" % str(field))

	# And nothing is refused for a reason that is not there: the untouched
	# file has no damaged field at all.
	_check(WorldStore.damaged_fields(written_by_save_world).is_empty(),
		"the file save_world wrote has no damaged field")

	# THE LOOP ABOVE IS ASKED WHETHER IT RAN. An empty poison list, or a
	# field quietly dropped from it, is otherwise a silent pass: measured at
	# 28 assertions, failures=0.
	for field in written_by_save_world:
		_check(int(refused_forms.get(field, 0)) > 0,
			"section 2 drove '%s' with at least one wrong type and saw it refused" % str(field))


# --- 3. a file that is merely OLDER must still load, and a file missing a
#        field a reader INDEXES must not ---
#
# THIS SECTION CAUGHT 098'S OWN REGRESSION AND IS WRITTEN UP RATHER THAN
# TIDIED, because the first version of it asserted the regression as correct.
# 098's first draft of load_world() replaced
# `typeof(data.get("parameters")) != TYPE_DICTIONARY` - which refuses an
# ABSENT "parameters" as well as a wrong-typed one - with a type check that
# only fired on a field that was PRESENT. So a file with no "parameters" key
# began to load, and main.gd:599 reads world["parameters"] BY INDEX. The
# first version of this loop treated every field but "command" as optional,
# so it passed, and a test that passes on a regression is TRAPS 6 exactly: it
# guarded the assumption that only "command" is indexed instead of checking
# which fields are.
#
# WHAT IT ASKS NOW. Each field is removed in turn, and which answer is right
# comes from WorldStore.REQUIRED rather than from a name written here, so
# moving a field between required and optional fails by that field's name.
# Both directions are asserted, because a door that refuses everything passes
# half of this as easily as a door that refuses nothing.
func _a_file_that_is_merely_older() -> void:
	if written_by_save_world.is_empty():
		return

	for field in written_by_save_world:
		var data := written_by_save_world.duplicate(true)
		data.erase(field)
		_write(data)
		var loaded := WorldStore.load_world(NAME)
		if WorldStore.REQUIRED.has(field):
			_check(not bool(loaded.get("ok", true)),
				"a file with no '%s' is refused: a reader indexes it by name" % str(field))
			_check(WorldStore.missing_fields(data) == [field],
				"missing_fields names '%s' and only '%s'" % [str(field), str(field)])
		else:
			_check(bool(loaded.get("ok", false)),
				"a file that merely lacks '%s' still loads (%s)" % [
					str(field), str(loaded.get("message", ""))])
			_check(WorldStore.missing_fields(data).is_empty(),
				"'%s' is not required, so missing_fields says nothing about it" % str(field))

	# AND THE SPLIT ITSELF IS ASSERTED, so REQUIRED cannot quietly become
	# every field or none: each name in it is a field save_world writes, and
	# at least one field is required and at least one is not.
	for field in WorldStore.REQUIRED:
		_check(written_by_save_world.has(field),
			"REQUIRED names '%s', which is a field save_world writes" % str(field))
	_check(not WorldStore.REQUIRED.is_empty(), "at least one field is required")
	_check(WorldStore.REQUIRED.size() < written_by_save_world.size(),
		"at least one field is optional, so section 3 measures both answers")


# --- 4. driven through main.gd: what a player meets, and what is recorded ---
#
# Every sentence this path produces and every field of the record it writes,
# asked ONE question: does any of it carry the engine's spelling of a value?
# Screened case-insensitively, because the same class hid behind a to_upper()
# at CommandParser in 096 and at _execute_plan in 097 (TRAPS 78).
#
# The record is read off the ledger rather than off main.gd's members, so
# what is screened is what was written down.
func _nothing_said_carries_the_engines_spelling() -> void:
	if written_by_save_world.is_empty():
		return

	for field in written_by_save_world:
		for poison in [null, []]:
			var data := written_by_save_world.duplicate(true)
			data[field] = poison
			_write(data)

			var before := _ledger().size()
			main._load_world("/load " + NAME)
			await process_frame
			await process_frame

			var said: Array = [main.status_label.text, main.pending_request,
				JSON.stringify(main.pending_source),
				str(main.controller.last_build.get("request", "")),
				JSON.stringify(main.controller.last_build)]
			var all := _ledger()
			for i in range(before, all.size()):
				said.append(JSON.stringify(all[i]))

			screened_sentences[field] = int(screened_sentences.get(field, 0)) + said.size()
			_check(not said.is_empty(),
				"'%s' as %s: the /load path said something to screen" % [
					str(field), "null" if poison == null else "an array"])
			for one in said:
				_check(not str(one).to_lower().contains(Readback.ENGINE_NOTHING.to_lower()),
					"'%s' as %s: nothing said or recorded spells a value the engine's way (%s)" % [
						str(field), "null" if poison == null else "an array",
						str(one).substr(0, 120)])

			# And the refusal a player reads is the damaged-file one, so the
			# request did not quietly do nothing.
			_check(str(main.status_label.text).to_lower().contains("damaged"),
				"'%s' as %s: the player is told the file is damaged" % [
					str(field), "null" if poison == null else "an array"])

	# AND THE SCREEN IS ASKED WHETHER IT SCREENED ANYTHING, per field, for the
	# reason given where screened_sentences is declared: with the collection
	# made to collect nothing this section was 88 assertions, failures=0.
	for field in written_by_save_world:
		_check(int(screened_sentences.get(field, 0)) > 0,
			"section 4 screened at least one sentence for '%s'" % str(field))


func _ledger() -> Array:
	var out: Array = []
	var file := FileAccess.open(TrackLog.PATH, FileAccess.READ)
	if file == null:
		return out
	while not file.eof_reached():
		var line := file.get_line().strip_edges()
		if line == "":
			continue
		var record = JSON.parse_string(line)
		if typeof(record) == TYPE_DICTIONARY:
			out.append(record)
	file.close()
	return out
