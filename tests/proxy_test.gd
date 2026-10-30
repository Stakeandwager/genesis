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
	#
	# --- 093: AND FOUR OF THESE FIVE READS WERE ANSWERABLE BY A COMMENT ---
	#
	# 067 fixed this class for .gd sources and wrote the exclusion down
	# plainly: source_scan_test's header says interpret.js's comments are
	# "//" and not "#", so _code_of() is the wrong reader for it, "and
	# nothing about them was measured in 067". Nothing came back to it for
	# twenty-six commits. 093 measured it, ONE FAULT AT A TIME, each alone in
	# its own copy of the project with its own config/name, the diff read
	# before each run, against an unpatched control of 26 assertions,
	# failures=0 (TRAPS 50, TRAPS 80):
	#
	#   the key read pointed at a DIFFERENT env var, the
	#     old name left behind in a comment               26/0   SILENT
	#   MAX_BODY and the entire 413 branch DELETED, the
	#     cap left behind in a comment                    26/0   SILENT
	#   the POST guard DELETED, "POST only" left behind
	#     in a comment                                    26/0   SILENT
	#   the field allowlist replaced by `body = sent`,
	#     the three names left behind in a comment        26/0   SILENT
	#
	# None of those is a wording fault. The first makes the sentence a web
	# player is shown name an environment variable the function does not
	# read - 057 built that sentence specifically so the two could not drift
	# apart, and this is the drift it was built to catch. The last turns this
	# into the open relay the file's own header says it must never be: "a
	# function that forwards whatever it is handed is an open relay with
	# somebody's credit card behind it." So every read here that asks what
	# the CODE DOES now goes through _js_without_comments().
	#
	# ONE OF THE FIVE IS RIGHT TO READ THE RAW FILE AND IS LEFT ALONE, and it
	# is the half a blanket fix would have broken (TRAPS 11 cuts both ways):
	# "no key is written into it" asks what is MENTIONED ANYWHERE, because a
	# key sitting in a comment is still a published key. Measured both ways
	# rather than argued: a fake AIza-prefixed key added in a comment gives
	# 26 assertions, failures=1 against the raw read, and would have passed
	# in silence through the stripper. That is source_scan_test's DIRECTION
	# rule - a question about what the code DOES is answered from the code; a
	# question about what is MENTIONED reads the raw file - and the direction
	# decides the reader, not habit.
	var path := "res://netlify/functions/interpret.js"
	var exists := FileAccess.file_exists(path)
	_check(exists, "the function is in the repository")
	var js_code := ""
	if exists:
		var file := FileAccess.open(path, FileAccess.READ)
		var source := file.get_as_text()
		file.close()
		js_code = _js_without_comments(source)
		_check(js_code.contains("Netlify.env.get(\"GEMINI_API_KEY\")"),
			"it reads the key from the environment, not from a file - in code, not in a comment")
		# RAW on purpose: see the paragraph above. A key in a comment is a
		# published key, so this one question is asked of the whole file.
		_check(not source.contains("AIza"),
			"and no key is written into it, anywhere, comments included")
		_check(js_code.contains("system_instruction") and js_code.contains("contents")
			and js_code.contains("generationConfig"),
			"it forwards only the three fields Genesis sends - in code, not in a comment")
		_check(js_code.contains("MAX_BODY"),
			"it caps the size of what it will forward - in code, not in a comment")
		_check(js_code.contains("POST only"),
			"and refuses anything but a POST - in code, not in a comment")

	# The reader held by its own probes, the way this file already holds
	# _code_of() below: prose in, nothing out; code in, the needle out. A
	# reader that came back empty would pass every presence check above by
	# seeing nothing, which is TRAPS 75's shape.
	_check(not _js_without_comments("// MAX_BODY = 1\n").contains("MAX_BODY"),
		"a whole-line // comment is blanked before any question is asked of it")
	_check(not _js_without_comments("const x = 1; // MAX_BODY\n").contains("MAX_BODY"),
		"and a trailing // comment is cut")
	_check(_js_without_comments("const MAX_BODY = 200;\n").contains("MAX_BODY"),
		"while a real line survives, so the reads above are not passing by seeing nothing")
	# THE KNOWN HAZARD, asserted rather than hoped about. "//" inside a string
	# literal cuts the line early - this very file has one, in ENDPOINT's
	# "https://generativelanguage...". _code_of() says the same of "#" and
	# gives the reason this is safe in the one direction that matters: losing
	# text can only make a presence check FAIL, never pass. That is why every
	# use of this reader above is a POSITIVE presence check and why the one
	# negative check in this block reads the raw file instead.
	_check(not _js_without_comments("const u = \"https://host/path\";\n").contains("host/path"),
		"and a // inside a string literal cuts the line early, which loses text and cannot invent it")

	# --- 093: the statuses the function ITSELF returns, and what Genesis
	#          tells a player when one arrives ---
	#
	# The two reads above are one step from this question and never took it:
	# the function is held to REFUSE a non-POST and to CAP the body, and
	# nothing in this repository asked what a player is told when either
	# fires. Read off interpret.js's own code rather than listed here, so a
	# status ADDED to the function is driven by this suite from the moment it
	# is added (TRAPS 82).
	#
	# WHAT THIS ASSERTS: that each one gets a sentence that says something,
	# and that the sentence names the code that arrived. Nothing more.
	#
	# WHAT IT DELIBERATELY DOES NOT ASSERT, AND THIS IS THE ANSWER TO THE
	# QUESTION 092 LEFT AS THE FIRST LIVE ENTRY. That entry asked whether
	# anything the code already states could require _friendly_http_error's
	# 400 and 404 arms, the way the retry tie reads WORTH_RETRYING, so that
	# an arm commented out would go red instead of taking two assertions with
	# it in silence. THE ANSWER IS NO, AND interpret.js IS THE PROOF RATHER
	# THAN THE CANDIDATE. It is the one other place in the repository that
	# states HTTP statuses in code, and it states FOUR it can return - read
	# below rather than typed here - of which TWO, 405 and 413, HAVE NO ARM
	# AND ARE RIGHT NOT TO: the generic default names the code and says what
	# it honestly can. So this file states which statuses ARRIVE, never which
	# arms must EXIST, and a requirement built on it as though it were the
	# second would fail on correct code. 092's "leave it" stands, and it is
	# written here beside the reader so the next session does not re-ask it.
	#
	# AND A GREEN ROW HERE IS NOT A CLAIM THAT THE SENTENCE IS RIGHT. The 503
	# this function returns means "this Genesis has no AI configured" - a
	# deployment mistake that no number of retries will fix - and Genesis
	# retries it three times and then says the service is busy and to try
	# again in a minute, which is false. That is already measured, already
	# written down, and already the owner's: "Human decision needed" 19.
	# Nothing here changes it. What this row holds is that the sentence SAYS
	# SOMETHING and NAMES 503. Whether it says the TRUE thing is a decision
	# about what the site should say about itself, and a check written over it
	# would be a test guarding an assumption (TRAPS 6).
	#
	# WHAT IS NOT READABLE FROM HERE, said rather than left to be assumed:
	# the function also returns `status: answer.status`, Google's own status
	# unchanged, which is not a literal and is skipped - asserted below, not
	# just described. So these four are the statuses the FUNCTION originates,
	# not the set a player can meet. Whether Google can send a code no arm
	# expects is the live-path question 092 recorded and this container still
	# cannot answer: there is no API key here.
	if exists:
		var originated := _js_statuses(js_code)
		_check(originated.size() > 0,
			"the function's own statuses were read off its code rather than typed out here: %s" % str(originated))
		for code in originated:
			var said: String = interpreter._friendly_http_error(int(code))
			_check(said.strip_edges() != "",
				"a %d from the function gets a sentence that says something" % code)
			_check(said.contains(str(code)),
				"and it names the code that arrived rather than one beside it: '%s'" % said)

	# And that reader held by its own probes too, positive and negative.
	_check(_js_statuses("      status: 405,\n") == [405],
		"a numeric status literal is read")
	_check(_js_statuses("      status: \"UNAVAILABLE\",\n").is_empty(),
		"a status that is a word is not a code")
	_check(_js_statuses("    status: answer.status,\n").is_empty(),
		"and the passthrough of Google's own status is not a literal, so it is skipped and not guessed at")
	_check(_js_statuses("      code: 503,\n").is_empty(),
		"a `code` field inside an error BODY is not the HTTP status of the response")
	_check(_js_statuses(_js_without_comments("// status: 418\n")).is_empty(),
		"and a status named only in a comment is not one the function returns")

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
	# guard for a wording reason.
	# CORRECTED IN 093 RATHER THAN DELETED, because what it said had become
	# false and a false sentence left standing is TRAPS 14. It read: "The two
	# reads above are NOT put through _code_of(): interpret.js and
	# export_presets.web.cfg are JavaScript and an ini file, whose comments
	# are // and ; and not #. That is stated rather than quietly skipped, and
	# nothing about them was measured here." The first half is still true and
	# is still the reason: _code_of() strips "#" and is the wrong reader for
	# either file. The second half is no longer: 093 measured interpret.js,
	# found four of its five reads answerable by a comment, and put the four
	# that ask what the code DOES through _js_without_comments() instead.
	# export_presets.web.cfg is NOT in that change and this is the whole
	# reason: its one read asks whether a key is MENTIONED, which is a
	# question about the raw file by the same direction rule that keeps the
	# AIza read raw. Nothing about an ini comment reader was measured, and
	# nothing needs to be until a read of that file asks what its code does.
	# See TRAPS 64 and TRAPS 90.
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


# --- 093: the same question, asked of JavaScript ---
#
# The CODE of a .js source: "//" comment lines blanked and trailing "//"
# comments cut, with the line count preserved, exactly as _code_of() does for
# "#". It is NOT named _code_of() and that is deliberate twice over: the two
# readers strip different markers, and source_scan_test holds that every
# _code_of() in tests/ is byte-identical to every other, so a second thing
# wearing that name would either break that assertion or quietly weaken it.
# The name also avoids containing the substring "_code_of(", which is what
# that suite greps for to decide a file HAS a reader of its own - a file
# carrying only this one must not be able to answer that question.
#
# WHY IT EXISTS. 067 asked "which of this project's source scans can a comment
# answer" of every .gd read in tests/ and fixed three. It wrote interpret.js
# down as out of scope for the reader it had, and that exclusion stood for
# twenty-six commits while five reads of a deployed function rested on it.
# Four of them were measured silent in 093, each fault alone in its own copy.
# See TRAPS 90.
#
# NOT A PARSER, and the same caveat _code_of() states, with a live example:
# "//" inside a string literal cuts the line early, and ENDPOINT's
# "https://generativelanguage..." in that very file does it. That can only
# lose a match and never invent one, so it is safe for a POSITIVE presence
# check and NOT safe for a negative one - which is why the only "not
# contains" question asked of that file reads the raw text instead. Both
# halves are asserted beside the reads rather than left here as a claim.
static func _js_without_comments(source: String) -> String:
	var out := ""
	for raw in source.split("\n"):
		var line := str(raw)
		if line.strip_edges().begins_with("//"):
			out += "\n"
			continue
		var at := line.find("//")
		out += (line if at < 0 else line.substr(0, at)) + "\n"
	return out


# Every HTTP status the function returns as a LITERAL, in source order and
# without duplicates. `status: answer.status` - Google's own status, passed
# back unchanged - is not a literal and is skipped, which is asserted beside
# the reader rather than described: a reader that guessed at it would be
# claiming to know Google's set, and this container cannot.
#
# Only digits immediately after "status:" count, so `status: "UNAVAILABLE"` is
# not a code and neither is a `code:` field inside an error body, which is a
# different thing that happens to carry the same number three times in this
# file. Hand it text that has already been through _js_without_comments() when
# the question is what the function DOES.
static func _js_statuses(source: String) -> Array:
	var out: Array = []
	for raw in source.split("\n"):
		var line := str(raw)
		var at := line.find("status:")
		while at >= 0:
			var rest := line.substr(at + 7).strip_edges()
			var digits := ""
			for i in rest.length():
				var c := rest[i]
				if c >= "0" and c <= "9":
					digits += c
				else:
					break
			if digits != "" and not out.has(int(digits)):
				out.append(int(digits))
			at = line.find("status:", at + 7)
	return out


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
