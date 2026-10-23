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
#
# --- 057: AND WHETHER A WEB REQUEST IS EVER SENT AT ALL, WHICH NOTHING ASKED
#
# Everything above asserts where a request WOULD go and what the function
# would do with it. Nothing asserted that a request is MADE. It was not, on
# the web, ever: _send() refused every one of them before _post() could run.
#
# The guard was `if api_key == ""`, with no on_web() exemption, and on the web
# api_key is ALWAYS "" by design - _load_key() returns before reading anything
# (ai_interpreter.gd, "a web build has no key by design") and nothing else in
# the project assigns it, grepped rather than remembered. is_available()
# answers TRUE on the web, so main.gd let the request through; _send() then
# killed it and told the player to check api_key.txt, a file a web build must
# never carry. The proxy 020 built could not be reached at any price, and
# setting GEMINI_API_KEY in the site's environment would not have changed it.
#
# FOUR PLACES ALREADY KNEW THE RULE and the fifth did not: where_to() sends to
# the proxy, is_available() answers true, _post() attaches no key header,
# _load_key() looks for no file. That is TRAPS 35's shape - a rule carried to
# four doors when there were five - so the fix is not a second `and not
# on_web()` but ONE function both readers call, with the build passed in as an
# argument so that the web case can be measured in a harness that cannot flip
# OS.has_feature("web").
#
# WHAT THESE ASSERTIONS DO NOT PROVE, said rather than left to be assumed:
# that a web build actually reaches the proxy and gets an answer. No browser
# ran here and no web export was made. What is proved is the DECISION, for
# both builds, and that the desktop guard still fires through the real
# interpret() door. The round trip needs the owner's machine.

var bad := 0
var asserted := 0
var interpreter: AIInterpreter


func _check(ok: bool, what: String) -> void:
	asserted += 1
	print(("PASS  " if ok else "FAIL  ") + what)
	if not ok:
		bad += 1


func _initialize() -> void:
	interpreter = AIInterpreter.new()
	get_root().add_child(interpreter)

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

	# --- 057: the key decision, for BOTH builds ---
	#
	# One function answers it, and these four rows are the whole truth table.
	# The THIRD is the finding: before 057 a web build with no local key was
	# refused here, which is every web build there has ever been.
	_check(AIInterpreter.key_missing_for(false, "") == true,
		"desktop with no key: refused here, which is right and always was")
	_check(AIInterpreter.key_missing_for(false, "a-key") == false,
		"desktop with a key: sent")
	_check(AIInterpreter.key_missing_for(true, "") == false,
		"WEB with no local key: SENT, because on the web the key is the server's")
	_check(AIInterpreter.key_missing_for(true, "a-key") == false,
		"web with a key sitting around: sent, and the key is not used")

	# Both readers route through that one answer rather than deciding again.
	# This can only be evaluated for the build this run IS - desktop, and
	# whatever key it has - so it covers one row of the four above and is
	# written down as covering one. The web rows are the function's alone.
	_check(interpreter.is_available()
			== (not AIInterpreter.key_missing_for(AIInterpreter.on_web(), interpreter.api_key)),
		"is_available() agrees with the function it calls, for THIS build (desktop, key %s)"
			% ("present" if interpreter.api_key != "" else "absent"))

	# A guard, not a finding (TRAPS 6): if a sixth place starts comparing the
	# key on its own, this fails rather than going quietly wrong. The only
	# comparison lives inside key_missing_for(), on its ARGUMENT.
	# READ OFF THE CODE (067). A commented-out comparison is not a comparison,
	# and until 067 a comment in ai_interpreter.gd containing "api_key ==" -
	# an explanation of the one that is there, say - would have failed this
	# guard for a wording reason. The two reads above are NOT put through
	# _code_of(): interpret.js and export_presets.web.cfg are JavaScript and
	# an ini file, whose comments are "//" and ";" and not "#". That is stated
	# rather than quietly skipped, and nothing about them was measured here.
	# See TRAPS 64.
	var src_path := "res://scripts/ai_interpreter.gd"
	var sf := FileAccess.open(src_path, FileAccess.READ)
	var src := _code_of(sf.get_as_text())
	sf.close()
	_check(not src.contains("api_key ==") and not src.contains("api_key !="),
		"nothing in ai_interpreter.gd compares api_key except the one function, in code and not in a comment")
	_check(not _code_of("# api_key == \"\"\n\tvar x := 1  # api_key != \"\"\n").contains("api_key ="),
		"and the reader it uses does not see that comparison in a comment, on its own line or after code")
	_check(_code_of('\tif api_key == "":\n').contains("api_key =="),
		"while it does see it in a line of code, so the guard above is not passing by seeing nothing")

	# --- 057: and the sentence a refused key produces ---
	#
	# The desktop one names a file. The web one cannot, because there is no
	# such file there; it names the environment variable the function reads -
	# and the name is checked against the FUNCTION'S OWN SOURCE rather than
	# typed out here twice, so the two cannot drift apart.
	var desk := AIInterpreter.key_refused_message(false, 401)
	var web := AIInterpreter.key_refused_message(true, 401)
	_check(desk.contains("api_key.txt"),
		"the desktop build still says to check api_key.txt")
	_check(not web.contains("api_key.txt"),
		"the web build does NOT send the player to a file a web build never carries")
	if exists:
		var ff := FileAccess.open(path, FileAccess.READ)
		var fsrc := ff.get_as_text()
		ff.close()
		_check(fsrc.contains(AIInterpreter.KEY_ENV_NAME),
			"and the name it tells them to check, '%s', is the one the function reads" % AIInterpreter.KEY_ENV_NAME)
	_check(web.contains("401") and desk.contains("401"),
		"both still carry the HTTP code")

	# --- 057: the desktop guard still fires, through the real door ---
	#
	# Not the predicate this time: interpret() -> _send(), with api_key "" on
	# a build where on_web() is false. Nothing is sent and the player is told.
	# This is the half of the call that a harness CAN walk.
	interpreter.api_key = ""
	var failures: Array = []
	interpreter.interpretation_failed.connect(func(reason: String) -> void: failures.append(reason))
	interpreter.interpret("a circuit with two straights")
	await process_frame
	_check(failures.size() == 1,
		"a desktop build with no key refuses the request through interpret() (got %d)" % failures.size())
	if failures.size() == 1:
		_check(str(failures[0]).contains("No API key"),
			"and says so: " + str(failures[0]))
	_check(not interpreter.busy,
		"and no request was put on the wire")

	print("PROXY TEST %d assertions, failures=%d" % [asserted, bad])
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
