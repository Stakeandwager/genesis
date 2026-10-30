extends SceneTree

# --- 067: the scans that read this project's own source, and which text they
#          read ---
#
# WHERE THIS CAME FROM. 066's first deliberate fault PASSED. Its new scan
# searched whole files in tests/ for OS.get_process_id(), and the comment that
# commit had just written into handler_wiring_test says the call in prose - so
# reverting that suite's session name to the bare string it was supposed to
# catch changed nothing. 066 narrowed that one function and wrote the lesson
# down: "a check a comment can satisfy is not a check. Scan code, not
# comments." (TRAPS 63.)
#
# IT NARROWED ONE FUNCTION. The question nobody asked is the one TRAPS 11 asks
# every time: how many OTHER scans in tests/ read this project's source, and
# how many of them are answerable by prose? Nine files did, as of 067 - the
# class is DERIVED and has grown since, so read it off _class() and not off
# this paragraph. THREE MORE WERE SATISFIED BY A COMMENT, measured one at a
# time in throwaway copies before anything was changed, each flipped from FAIL
# to PASS by ONE comment line:
#
#   handler_wiring_test's guard that its PLACEHOLDER constant is the string
#   main.gd writes - 47 assertions, failures=0, on a false claim.
#   player_door_test's guard that no suite reaches the main scene by a path of
#   its own - defeated by a comment saying it did NOT use the setting.
#   check_wiring_test's guard that BY_HAND's row still names a function that
#   exists - defeated by "Renamed from func quarrel_with(reason)".
#
# AND THE RULE IS NOT "SCAN CODE, NOT COMMENTS", which is where this file
# earns its place. Applied as written, that would have NARROWED two checks
# that are wide on purpose: controller_reach_test and refusal_reach_test both
# collect every FAILED_ name in scripts/ and assert each has a row, and a name
# that appears only in a comment still has to be answered for, because
# somebody reading that comment will go looking for the row. The rule is about
# DIRECTION:
#
#   a question about what the code DOES is answered from the code;
#   a question about what is MENTIONED anywhere reads the raw file.
#
# refusal_reach_test now asks both of one scan, with the texts separated.
#
# WHAT THIS FILE HOLDS, AND IT IS AT FILE GRANULARITY ON PURPOSE. There is no
# shared library in tests/ - every suite stands alone, which is this project's
# convention - so the rule cannot be held by one implementation everybody
# calls. What is held instead: every file in tests/ that reads a .gd source
# under res://scripts or res://tests goes through a function named _code_of(),
# every one of them DEFINES it, and all of those definitions are
# byte-identical. A suite that scans source without it fails here, by name.
#
# WHAT THIS DOES NOT PROVE, said plainly because the gap is the interesting
# part: it does not prove that every NEEDLE inside a member goes through
# _code_of(), only that the member has it and uses it somewhere. A suite could
# strip comments for one scan and read raw text for the next, and this file
# would pass. The per-needle half is held inside each member, by the negative
# controls 067 added beside each fixed scan - prose in, nothing out; code in,
# the needle out - and those are assertions about the reader rather than about
# the wording. Narrowing this to per-needle granularity needs a parser, and a
# parser written here would be the next thing nothing holds to account.
#
# NOT IN SCOPE, and stated rather than quietly skipped: proxy_test also reads
# netlify/functions/interpret.js and export_presets.web.cfg. Their comment
# syntax is "//" and ";", not "#", so _code_of() is the wrong reader for them.
#
# --- 093: AND THE SECOND HALF OF THAT PARAGRAPH IS CORRECTED, NOT DELETED ---
#
# It used to end "and nothing about them was measured in 067". That was true
# when it was written and it stayed true for twenty-six commits, which is the
# whole lesson: a stated exclusion reads like a closed question and is an open
# one with a note attached. 093 measured interpret.js and found FOUR of
# proxy_test's five reads of it answerable by a comment - the env var the key
# comes from, the size cap, the POST guard and the field allowlist, each
# injected alone against a control of 26 assertions, failures=0, each SILENT,
# and the first of them byte-identical to the baseline across the whole --all
# set. Those four now go through proxy_test's own _js_without_comments().
# TRAPS 90.
#
# TWO THINGS THAT FOLLOW, AND BOTH BELONG HERE RATHER THAN BEING REDERIVED.
# FIRST: the fifth read is RIGHT to read the raw file and was left alone. "No
# key is written into it" asks what is MENTIONED ANYWHERE, because a key in a
# comment is still a published key - measured, a fake AIza-prefixed key in a
# comment gives failures=1 raw and would pass through a stripper. That is this
# file's DIRECTION rule, and it is why applying "scan code, not comments" to
# all five would have introduced a fault while fixing four.
# SECOND: export_presets.web.cfg is NOT in that change, deliberately. Its one
# read asks the same MENTIONED question, so the raw file is the right text and
# no ini comment reader was written. None is needed until a read of that file
# asks what its code does.
#
# THIS FILE STILL HOLDS NOTHING ABOUT EITHER, which is the honest statement of
# where the convention ends: section 2 and section 3 are about _code_of() in
# files that read .gd sources, and a .js reader is held by its own probes
# beside its own reads in proxy_test and by nothing here.

var asserted := 0
var bad := 0

# The members, so a file that STOPS scanning source is noticed too. A row here
# that has left the class is not a failure of the code - it is a row to strike
# - but it should never go unremarked (TRAPS 14).
#
# NO COUNT IS WRITTEN IN THIS SENTENCE. It said "the nine members as of 067"
# while the list held ten, because 075 added formula_test and left the number;
# 077 added an eleventh and struck the number rather than correcting it, since
# a count in a comment beside the array it counts is TRAPS 24's shape and the
# array is right there to be read. Section 1 asserts against KNOWN.size().
#
# 079 ADDED THE THREE ROWS 078 MEASURED AS MISSING, so this list now names
# every member of the derived class rather than twelve of fifteen, and the
# sentence in section 1 - "so one LEAVING is noticed" - is true of all of
# them. Section 1's assertion is UNCHANGED and is still a floor: the owner's
# design choice is not being changed here, and what that leaves open is
# written at section 1 rather than left to be rediscovered.
const KNOWN := [
	# 079: in the class since 070, named here for the first time. Its
	# hardcoded-plural sweep reads every scripts/*.gd through _source() and
	# its own comment says why that read has to be of the CODE: "a scan a
	# comment can satisfy is not a check". 078 measured that this row was
	# absent and that the file could therefore stop scanning source in
	# silence; the deliberate departure is measured in 079.
	"agreement_test.gd",
	"check_wiring_test.gd",
	"controller_reach_test.gd",
	# 075: formula_test joined the class when its new rule-claim rows stopped
	# asserting that a named suite's FILE exists and started reading that
	# suite's CODE for the constant the rule is about. This suite caught it
	# the same run: two FAILs, by name.
	"formula_test.gd",
	"handler_wiring_test.gd",
	"player_door_test.gd",
	# 079: in the class since 073, which is the commit that WROTE this file -
	# read off git and not guessed: its first version already did
	# DirAccess.open("res:/" "/scripts") to look for a stray prompt template,
	# which is a question about what the code CONTAINS answered from the
	# code. So it was a member for five commits with no row here, and it was
	# the second of the three 078 measured as missing.
	"prompt_numeral_test.gd",
	"proxy_test.gd",
	"record_id_test.gd",
	"refusal_reach_test.gd",
	# 092: retry_test joined the class when it stopped driving three HTTP
	# codes typed into itself and started reading the match arms of
	# _friendly_http_error OFF ai_interpreter.gd, so that an arm added to
	# that function is driven from the moment it is added. This suite
	# caught the departure the same run, two FAILs by name, before the row
	# was added or the _code_of() was written - which is the only reason
	# either happened.
	"retry_test.gd",
	# 077: result_line_test reads every suite's CODE to find the line it
	# prints, so it is in this class by the same door formula_test came in
	# by: a question about what the code DOES, answered from the code.
	"result_line_test.gd",
	# 078: scan_floor_test reads every suite's CODE to find its DirAccess.open
	# sites, so it is in this class by the same door result_line_test came in
	# by. Added here for the reason this list exists - so a file that STOPS
	# scanning source is noticed - and not because section 1 required it:
	# KNOWN is a floor by design. 078 then measured that floor and recorded
	# the gap rather than acting on it: the derived class had FIFTEEN members
	# and this list named TWELVE. The three it did not name are the three
	# rows 079 added, each carrying its own note; that measurement is spent,
	# and the sentence stating it has been struck rather than left to read as
	# current (TRAPS 14).
	"scan_floor_test.gd",
	"scene_light_test.gd",
	# 079: THIS FILE IS A MEMBER OF ITS OWN CLASS and was the third row 078
	# measured as missing - it reads tests/ to derive the class and reads
	# each member to compare the readers, so _class() returns it. Asserted
	# rather than left to be noticed, which is the same thing
	# scan_floor_test did for its own row.
	"source_scan_test.gd",
	"view_frame_test.gd",
]


func _check(ok: bool, what: String) -> void:
	asserted += 1
	if ok:
		print("PASS  ", what)
	else:
		bad += 1
		print("  FAIL  ", what)


func _initialize() -> void:
	_run.call_deferred()


# The needles are BUILT rather than typed, so this file does not answer its
# own questions out of its own source: every paragraph above that talks about
# a res:// path would otherwise be a source read as far as the scan is
# concerned. The same trick record_id_test's session scan uses, and for the
# same reason.
func _needles() -> Array:
	return ["res:/" + "/scripts", "res:/" + "/tests"]


# Every file in tests/ whose CODE reads a .gd source out of this repository,
# as name -> the "file:line" of each place it names one.
#
# An `extends` is not a read: session_test.gd's only mention of res://tests is
# the line that says it extends drive_test.gd. That exclusion is asserted as a
# fact in section 4 rather than left as a claim in this comment.
func _class() -> Dictionary:
	var out := {}
	var dir := DirAccess.open("res://tests")
	if dir == null:
		return out
	for file_name in dir.get_files():
		var name := str(file_name)
		if not name.ends_with(".gd"):
			continue
		var file := FileAccess.open("res://tests/" + name, FileAccess.READ)
		if file == null:
			continue
		var code := _code_of(file.get_as_text())
		file.close()
		if not code.contains("FileAccess"):
			continue
		var sites: Array = []
		var number := 0
		for raw in code.split("\n"):
			var line := str(raw)
			number += 1
			if line.strip_edges().begins_with("extends"):
				continue
			for needle in _needles():
				if line.contains(str(needle)):
					sites.append("%s:%d" % [name, number])
					break
		if not sites.is_empty():
			out[name] = sites
	return out


# The text of a file's own _code_of(), from its header line to the first line
# that is neither blank nor indented. Returned verbatim, so two copies that
# have drifted by a character do not compare equal.
func _definition(name: String) -> String:
	var file := FileAccess.open("res://tests/" + name, FileAccess.READ)
	if file == null:
		return ""
	var lines := file.get_as_text().split("\n")
	file.close()
	var header := "static func _code" + "_of(source: String) -> String:"
	var out := ""
	var inside := false
	for raw in lines:
		var line := str(raw)
		if not inside:
			if line.begins_with(header):
				inside = true
				out = line + "\n"
			continue
		if line.strip_edges() != "" and not (line.begins_with("\t") or line.begins_with(" ")):
			break
		out += line + "\n"
	return out.strip_edges()


func _run() -> void:
	print("--- 067: the source scans in tests/, and the text each one reads ---")

	var members := _class()

	# --- 1. the class is enumerated and is not empty (TRAPS 6) ---
	#
	# A floor and not an equality, so a scanner added tomorrow does not have
	# to edit this line - but EVERY row in KNOWN is asserted below, so one
	# LEAVING is noticed. No count is written in this sentence either: it said
	# "the nine KNOWN" while the list held twelve.
	#
	# 079 MADE THAT TRUE OF EVERY MEMBER. Until then KNOWN named twelve of
	# the fifteen members _class() returns, so agreement_test.gd,
	# prompt_numeral_test.gd and source_scan_test.gd could each stop scanning
	# source and no suite would say so. The three rows are added and each
	# departure was measured.
	#
	# WHAT THIS STILL LEAVES OPEN, said here rather than left to be
	# rediscovered: the gap re-opens the day a sixteenth scanner arrives
	# WITHOUT adding its row, because this assertion is a floor and cannot
	# fail on an arrival. Requiring KNOWN to name the whole class would close
	# it and would make a new scanner's author see a FAIL until the row is
	# written - a change to the owner's stated design choice, so it is
	# recorded in docs/HANDOVER.md under "Human decision needed" and not made
	# here.
	_check(members.size() >= KNOWN.size(),
		"%d files in tests/ read a .gd source out of this repository (at least %d expected)" % [
			members.size(), KNOWN.size()])
	for name in KNOWN:
		_check(members.has(name),
			"%s still reads source, so its row here is current" % str(name))

	# --- 2. every one of them HAS the one reader ---
	#
	# ~~"every one of them goes through the one reader"~~ IS NOT WHAT THIS
	# SECTION MEASURES, and the heading and the message both said it was.
	# Struck rather than corrected (079's rule): what is asked is one
	# contains() PER FILE, so it answers "this file has a _code_of()
	# somewhere", not "this file routes its reads through it".
	#
	# MEASURED IN 081, not reasoned about. _class() above already collects
	# the SITES - out[name] is a list of "file:line" - and this loop throws
	# them away and asks the file one question. A SECOND, RAW read added to
	# proxy_test.gd, which already has a _code_of() and so already passes,
	# left this suite at 30 assertions, failures=0. The control separates the
	# two claims: the same raw read added to walk_negative.gd, which has no
	# _code_of() at all, FAILS here at 30 assertions, failures=2. So what is
	# held is the presence of the reader, and what is not held is its use.
	# TRAPS 77's shape, in the sibling table 080's one-grep screen cleared.
	#
	# AND IT IS NOT HYPOTHETICAL. Measured the same way: nine functions
	# across six files in tests/ take the text of a .gd source out of this
	# repository without naming _code_of() in the same function
	# (check_wiring_test._verdict_functions and ._no_door_rows,
	# controller_reach_test._enumeration, ._guard_no_handler and
	# ._guard_spawn_opponents, handler_wiring_test._why_two_are_unreachable,
	# record_id_test._run, refusal_reach_test._why_out_of_reach, and
	# source_scan_test._definition). Some are deliberate and safe -
	# _definition() reads verbatim ON PURPOSE and says so, _verdict_functions
	# strips comments inline itself - and the rest have not been read one by
	# one. That reading is the next action and is NOT claimed here.
	#
	# WHY NO ASSERTION IS ADDED FOR IT HERE (TRAPS 6). The per-function rule
	# was measured before it was believed and it is not a fact about this
	# repository: eleven of the twenty-five text-taking functions do not name
	# _code_of(), and most are legitimate. An assertion over them would need
	# a hand-written allow-list of exceptions - a hand table over a derived
	# class, which is the shape this whole investigation is about. The
	# honest unit is "is the text this read produces asked a question after
	# being stripped", which is dataflow and not a grep.
	var raw_readers: Array = []
	for name in members:
		var file := FileAccess.open("res://tests/" + str(name), FileAccess.READ)
		if file == null:
			raw_readers.append(str(name) + " (unreadable)")
			continue
		var code := _code_of(file.get_as_text())
		file.close()
		if not code.contains("_code" + "_of("):
			raw_readers.append("%s (%s)" % [name, ", ".join(PackedStringArray(members[name]))])
	_check(raw_readers.is_empty(),
		"every file that scans source HAS a _code_of() of its own - which is not the same as using it at every read, see above: %s" % str(members.keys()) if raw_readers.is_empty() else
		"a file in tests/ scans this project's source and has no _code_of() at all, so a comment can answer its questions: " + ", ".join(PackedStringArray(raw_readers)))

	# --- 3. and every copy of that reader is the same reader ---
	#
	# One function written out privately in every member of this class is
	# TRAPS 28's shape - a thing written out by hand in many places, counted
	# here by members.size() rather than by a number in this comment - and
	# the cost of a drifted copy is a scan that is blind in a way nothing
	# says. The convention that
	# every suite stands alone is the owner's and is not being changed here;
	# what is held is that the copies agree.
	var reference := ""
	var reference_from := ""
	var drifted: Array = []
	var missing: Array = []
	for name in members:
		var body := _definition(str(name))
		if body == "":
			missing.append(str(name))
			continue
		if reference == "":
			reference = body
			reference_from = str(name)
		elif body != reference:
			drifted.append(str(name))
	_check(missing.is_empty(),
		"every file that scans source defines _code_of() itself, because tests/ has no shared library (%s)" % str(missing))
	_check(reference != "", "one of them was read as the reference copy (%s)" % reference_from)
	_check(drifted.is_empty(),
		"and all %d copies are byte-identical to %s's (%s)" % [members.size(), reference_from, str(drifted)])

	# --- 4. the reader itself, which is the half this file can prove ---
	#
	# Prose in, nothing out. Code in, the needle out. The needle is one that
	# cannot occur in this repository, so a reader that ignored its argument
	# and answered from somewhere else would fail here.
	var needle := "A_NEEDLE_NOTHING_IN_GENESIS_HAS"
	_check(not _code_of("# %s\n" % needle).contains(needle),
		"a needle on a comment line is not in the code")
	_check(not _code_of("\tvar x := 1  # %s\n" % needle).contains(needle),
		"and neither is one after code on the same line")
	_check(not _code_of("\t\t# %s()\n" % needle).contains(needle),
		"and neither is one in an indented comment")
	_check(_code_of("\tvar %s := 1\n" % needle).contains(needle),
		"while a needle in a line of code is, so the three above are not passing by seeing nothing")

	# AND THE ONE PROPERTY THAT MAKES A GUARD VACUOUS (084, TRAPS 81). An
	# EMPTY source in - which is what `FileAccess.get_file_as_string()` returns
	# for a path that is not there, and what `open()` cannot give because it
	# returns null instead - and the output is NOT empty: `"".split("\n")` is
	# one empty element, so the stripper emits one newline for it. Measured in
	# Godot 4.7.1: raw length 0, stripped length 1, the byte 10.
	#
	# The consequence is that `_check(_code_of(read) != "", "the file was
	# read")` CANNOT FAIL, which is what the guard in view_frame_test's
	# _the_class_is_closed() was until 084 - measured there, with the path
	# redirected at a file that is not there, as a guard that PASSED while the
	# three counts beside it did the catching (82 assertions, failures=3).
	# A suite that wants to know a read worked must ask the RAW text.
	#
	# This is asserted of THIS file's copy, and section 3 above has already
	# asserted that every copy is byte-identical - so it is a property of
	# every copy in tests/ and not of this one. That is the only reason one
	# assertion is enough.
	_check(_code_of("") != "",
		"the code of an EMPTY source is not empty, so emptiness of a stripped read is no evidence the read worked (length %d)" % _code_of("").length())
	_check(_code_of("").strip_edges() == "",
		"while stripped of whitespace it is, which is the form the two prose controls above use and the form a scan may safely test")

	# The line count is preserved, which is not tidiness: record_id_test's
	# session scan reports "file:line" off this text, and 066's own fault 2
	# was a report that named a line that started nothing.
	var four := "# one\n\tvar x := 1\n# three\n\tvar y := 2"
	_check(_code_of(four).split("\n").size() == four.split("\n").size() + 1,
		"the code of a source has the same lines as the source, so a scan can still report where it looked")
	var blanked := _code_of(four).split("\n")
	_check(str(blanked[0]).strip_edges() == "" and str(blanked[2]).strip_edges() == "",
		"with the comment lines blanked in place rather than removed")
	_check(str(blanked[1]).contains("var x") and str(blanked[3]).contains("var y"),
		"and the code lines still on the lines they were on")

	# --- 5. the exclusion, asserted rather than claimed ---
	#
	# session_test.gd names res://tests and is NOT in the class, because the
	# only line it names it on is its `extends`. If it ever reads a source
	# file, it joins the class and section 2 asks it the same question as the
	# others - so this asserts the reason for the exclusion, not the
	# exclusion itself.
	var session := FileAccess.open("res://tests/session_test.gd", FileAccess.READ)
	_check(session != null, "session_test.gd can be read")
	if session != null:
		var code := _code_of(session.get_as_text())
		session.close()
		var mentions := 0
		var on_extends := 0
		for raw in code.split("\n"):
			var line := str(raw)
			var hit := false
			for n in _needles():
				if line.contains(str(n)):
					hit = true
			if not hit:
				continue
			mentions += 1
			if line.strip_edges().begins_with("extends"):
				on_extends += 1
		_check(mentions > 0 and mentions == on_extends,
			"session_test.gd names a res:// source path %d time(s) and every one is its `extends`, which is why it is not in the class" % mentions)
		_check(not members.has("session_test.gd"),
			"and the scan agrees it is not a source scanner")

	print("SOURCE SCAN %d assertions, failures=%d" % [asserted, bad])
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
