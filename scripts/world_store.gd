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

    if typeof(data) != TYPE_DICTIONARY or not data.has("command") or typeof(data.get("parameters")) != TYPE_DICTIONARY:
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


static func _path(name: String) -> String:
    return "%s/%s%s" % [FOLDER, name, SUFFIX]
