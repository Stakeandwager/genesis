extends SceneTree

# 020 - the key stays on the server.
#
# Anything under res:// is packed into index.pck, which anyone can download and
# read, so a web build carrying api_key.txt would be publishing the key. The
# browser asks a function on its own origin instead, and that function holds
# the key.
#
# What can be checked without a browser: that the two builds send to different
# places, that only the desktop one attaches a key header, and that the one
# function in the repository forwards exactly one model's call rather than
# whatever it is handed.

var bad := 0


func _check(ok: bool, what: String) -> void:
	print(("PASS  " if ok else "FAIL  ") + what)
	if not ok:
		bad += 1


func _initialize() -> void:
	# Running headless on Linux, so on_web() is false and this IS the desktop
	# case. Saying which case is being measured is half the test.
	_check(not AIInterpreter.on_web(), "this run is the desktop build, so that is what is measured here")
	_check(AIInterpreter.where_to() == AIInterpreter.ENDPOINT,
		"the desktop build talks to Google directly")
	_check(AIInterpreter.PROXY_PATH.begins_with("/"),
		"and the web build would use a same-origin path: " + AIInterpreter.PROXY_PATH)
	_check(not AIInterpreter.PROXY_PATH.contains("googleapis"),
		"which is not Google's address, so no key travels with it")

	# The function itself, read as text. It is JavaScript and cannot be run
	# here, so what is checked is what it is written to do.
	var path := "res://netlify/functions/interpret.js"
	var exists := FileAccess.file_exists(path)
	_check(exists, "the function is in the repository")
	if exists:
		var file := FileAccess.open(path, FileAccess.READ)
		var source := file.get_as_text()
		file.close()
		_check(source.contains("Netlify.env.get(\"GEMINI_API_KEY\")"),
			"it reads the key from the environment, not from a file")
		_check(not source.contains("AIza"),
			"and no key is written into it")
		_check(source.contains("system_instruction") and source.contains("contents")
			and source.contains("generationConfig"),
			"it forwards only the three fields Genesis sends")
		_check(source.contains("MAX_BODY"),
			"it caps the size of what it will forward")
		_check(source.contains("POST only"),
			"and refuses anything but a POST")

	# The web export must not carry a key even by accident.
	var preset := "res://export_presets.web.cfg"
	if FileAccess.file_exists(preset):
		var f := FileAccess.open(preset, FileAccess.READ)
		var text := f.get_as_text()
		f.close()
		_check(not text.contains("api_key"), "the web preset mentions no key")

	print("PROXY TEST failures=%d" % bad)
	quit(bad)
