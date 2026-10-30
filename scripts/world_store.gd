extends RefCounted
class_name WorldStore

# --- Saved worlds ---
# A world is saved as the description that made it: a list of sections, or
# zones, or the steps of a plan. A few hundred bytes, not geometry.
#
# That matters for three reasons. The files are tiny, so they can be shared.
# A world rebuilt tomorrow uses today's builder, so old worlds improve as the
# game does. And loading goes through the same validator as everything else,
# so an edited file cannot smuggle anything past the whitelist.

const FOLDER := "user://worlds"
const SUFFIX := ".world.json"

# --- 098: the type of every field a saved file carries ---
#
# load_world() is the ONLY door between a file a player can edit by hand and
# every reader of that file. It checked that the text parsed to a dictionary,
# that "command" was PRESENT, and that "parameters" was a dictionary - three
# checks over six fields - so a present field of the wrong type walked
# straight through it. Driven in 098, not argued: a file whose "command" is
# null read back to the player as "'<NULL>' is not a command this game has",
# one whose "command" is the number 7 as "'7.0'", and one whose "name" is
# null put "load <null>" into the ledger record AND into the next prompt the
# model is sent. A file whose "metrics" was null skipped the load check in
# silence, which is a measurement not taken reported as nothing to report.
#
# So the check is per FIELD and the field is named when it fails, and the
# types are declared here because this is the function that reads them.
# The list is held against the code rather than beside it -
# tests/world_file_test.gd calls save_world() for real, reads the file back,
# and asserts that these keys and these types are exactly the ones it wrote,
# so a seventh field added to save_world() fails by its own name (TRAPS 82).
const FIELD_TYPES := {
    "name": TYPE_STRING,
    "saved": TYPE_STRING,
    "request": TYPE_STRING,
    "command": TYPE_STRING,
    "parameters": TYPE_DICTIONARY,
    "metrics": TYPE_DICTIONARY,
}

# PRESENCE AND TYPE ARE TWO DIFFERENT QUESTIONS, and 098's first draft of this
# function asked only the second - which let a file with NO "parameters" key
# load, where the check it replaced had refused one. main.gd:599 and :608 read
# world["parameters"] by index and world["command"] likewise, so an absent one
# is not a defaulted read, it is a crash. Those two reads are why these two
# fields are here and the other four are not: "name", "saved" and "metrics"
# are read through get() with a working default at main.gd:595, :596 and :614,
# and "request" is not read from a saved file at all.
#
# THE SECOND HALF OF THE RULE, and it is the half easiest to lose later: a
# field that is merely MISSING is not damage. A save file written by an
# earlier Genesis may not carry every field this one writes, and tightening
# this into "all six are required" would stop those files loading.
# world_file_test section 3 removes each field in turn and requires exactly
# this split, so moving a field between the two fails by its own name.
const REQUIRED := ["command", "parameters"]


static func save_world(name_given: String, command: String, parameters: Dictionary, metrics: Dictionary, request: String) -> Dictionary:
    var name := clean_name(name_given)
    if name == "":
        return {"ok": false, "message": "Give the world a name, for example: /save hillclimb"}

    DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(FOLDER))
    var file := FileAccess.open(_path(name), FileAccess.WRITE)
    if file == null:
        return {"ok": false, "message": "Could not write to " + _path(name)}

    file.store_string(JSON.stringify({
        "name": name,
        "saved": Time.get_datetime_string_from_system(),
        "request": request,
        "command": command,
        "parameters": parameters,
        "metrics": metrics,
    }, "\t"))
    file.close()
    return {"ok": true, "message": "Saved as '%s'. Type /load %s to build it again." % [name, name]}


static func load_world(name_given: String) -> Dictionary:
    var name := clean_name(name_given)
    if not FileAccess.file_exists(_path(name)):
        return {"ok": false, "message": "There is no world called '%s'. Type /worlds to see what there is." % name}

    var file := FileAccess.open(_path(name), FileAccess.READ)
    if file == null:
        return {"ok": false, "message": "Could not read '%s'." % name}

    var data = JSON.parse_string(file.get_as_text())
    file.close()

    if typeof(data) != TYPE_DICTIONARY or not missing_fields(data).is_empty() \
            or not damaged_fields(data).is_empty():
        return {"ok": false, "message": "The file for '%s' is damaged." % name}

    return {"ok": true, "message": "", "world": data}


static func list_worlds() -> Array:
    var out: Array = []
    var dir := DirAccess.open(FOLDER)
    if dir == null:
        return out
    for file_name in dir.get_files():
        if file_name.ends_with(SUFFIX):
            out.append(file_name.substr(0, file_name.length() - SUFFIX.length()))
    out.sort()
    return out


static func remove_world(name_given: String) -> Dictionary:
    var name := clean_name(name_given)
    if not FileAccess.file_exists(_path(name)):
        return {"ok": false, "message": "There is no world called '%s'." % name}
    DirAccess.remove_absolute(ProjectSettings.globalize_path(_path(name)))
    return {"ok": true, "message": "Deleted '%s'." % name}


# --- 042: the one place that says how many worlds are saved ---
#
# This was two strings written inline in Main._list_worlds(), and the status
# line said "1 saved worlds" the first time anybody typed /save and then
# /worlds. Main is a Node3D that needs a scene tree, so no suite could reach
# the sentence; moved here, it is a static function with the count read
# through Readback.plural() and tests/counted_said_test.gd reads it. A
# sentence a test cannot reach is a sentence nothing is checking (TRAPS 36).
static func saved_line(names: Array) -> String:
    return "%s: %s" % [Readback.plural(names.size(), "saved world"), ", ".join(PackedStringArray(names))]


static func location() -> String:
    return ProjectSettings.globalize_path(FOLDER)


# Names become filenames, so they are kept plain on purpose.
static func clean_name(name_given: String) -> String:
    var cleaned := ""
    for character in name_given.strip_edges().to_lower():
        if character.is_valid_identifier() or character == "-" or character.is_valid_int():
            cleaned += character
        elif character == " ":
            cleaned += "-"
    return cleaned.substr(0, 40)


# Which fields a reader will index by name and the file has not got, in
# REQUIRED order. Returns the NAMES for the same reason damaged_fields() does.
static func missing_fields(data: Dictionary) -> Array:
    var out: Array = []
    for field in REQUIRED:
        if not data.has(field):
            out.append(field)
    return out


# Which fields of a parsed save file are not the type save_world() wrote, in
# FIELD_TYPES order. Returns the NAMES rather than a bool so a suite can say
# which field it is and so a field that stops being checked fails by name.
# An absent field is not damage; a present one of the wrong type is.
static func damaged_fields(data: Dictionary) -> Array:
    var out: Array = []
    for field in FIELD_TYPES:
        if data.has(field) and typeof(data[field]) != FIELD_TYPES[field]:
            out.append(field)
    return out


static func _path(name: String) -> String:
    return "%s/%s%s" % [FOLDER, name, SUFFIX]
