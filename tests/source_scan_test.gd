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


# --- 108: an equality between two counts the suite derived from ONE collection
#          (HANDOVER's first live entry as of 107) ---
#
# WHERE THIS CAME FROM. 107 fixed `scan_floor_test`'s section 2 - an assertion
# that could not fail under a sentence that was the opposite of the truth
# (TRAPS 107) - and named its weaker sibling: section 3's
# `asked_for_null == open_kind`, where BOTH counters are incremented while
# walking `sites` under the same predicate, so the equality cannot fail. It
# then asked the question it could not answer in one commit: HOW MANY MORE OF
# THAT SHAPE ARE THERE, in the 76 suites it did not read?
#
# THIS TABLE IS THE ANSWER, AND THE SHAPE TURNED OUT NOT TO BE THE CLASS.
# FOUR sites in THREE files, measured over all 80 files in tests/ - and
# exactly ONE of the four is vacuous. The other three compare counts taken
# under DIFFERENT predicates over one collection, which is a real question
# with a real answer. So "two counts of one array" is a shape a reader must
# look at, not a fault; the verdict is per site and is written here.
#
# WHY A TABLE AND NOT A PASS/FAIL RULE, said plainly because it is the honest
# limit of this section. Telling the vacuous case from the live one means
# deciding whether two predicates are equivalent - `match str(kind): "open":`
# against `if str(kind) != "open": continue` - and that is not decidable by a
# scanner. What IS decidable is the shape. So the scan finds the shape, every
# site must carry a row, and the row carries the reading. A fifth site
# arriving fails here BY NAME with nothing to read it, which is the only thing
# this section can honestly promise.
#
# AND TRAPS 106's RULE APPLIES BEFORE ANY OF IT IS BELIEVED: the scan must
# find the instance the rule came from, by file and function, or it holds
# nothing. It is asserted by name in section 8, not left to the table. The
# first route to this enumeration - a prototype in another language, run over
# the same directory before any of this was written - MISSED that instance,
# because `open_kind` is incremented on a `match` arm (`"open": open_kind +=
# 1`) and the prototype only matched `+=` at the start of a line. It reported
# 3 sites in 3 files and one of the three was a parse artifact: a `(` inside a
# string literal ran its reader past the end of a `_check(` and swallowed the
# next assertion whole. Both narrownesses are controlled in section 9.
const COUNTER_EQUALITIES := {
	"layout_key_test.gd::_lane_width_is_the_threshold::written==farms": {
		"verdict": "CAN FAIL",
		"why": "`farms` counts the iterations that got past both `continue`s; `written` counts the subset of those whose layout has a lane_width key. A solve() that stopped writing the key makes written < farms, which is the thing asserted",
	},
	"scan_floor_test.gd::_run::files_at_kind,open_kind==sites.size()": {
		"verdict": "CAN FAIL",
		"why": "107 read this one and said so: it is vacuous only until a THIRD reading idiom is classified, and on that day the sum stops balancing and names itself. A guard against a real future change, which is what TRAPS 6 says to keep and label",
	},
	"scan_floor_test.gd::_run::asked_for_null==open_kind": {
		"verdict": "CANNOT FAIL ON tests/",
		"why": "THE INSTANCE THIS SECTION EXISTS FOR. Both counters walk `sites` and both advance on kind == open - one on a `match` arm, one after a `continue` on the negation - so no input to that scan can separate them. The `> 0` conjunct beside it IS live: it fires if the classifier ever calls every open a get_files_at. Labelled in scan_floor_test section 3 rather than deleted, because the equality still fires on a change to that section's own predicate (measured in 108)",
	},
	"source_scan_test.gd::_run::mentions==on_extends": {
		"verdict": "CAN FAIL",
		"why": "`mentions` counts every line of session_test.gd naming a res:// source path; `on_extends` counts the subset that begin with `extends`. A second mention anywhere else in that file makes them differ, which is the claim section 4 is making. 107 said it had read every _check in THIS file and did not name this one - so the shape was under-counted in the file the question was asked from",
	},
}


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

	# AND THE ONE PLACE THIS READER IS WRONG, DRIVEN RATHER THAN DESCRIBED.
	# It takes the FIRST `#` on the line and does not know whether that `#` is
	# inside a string literal, so a line of real code whose own string holds a
	# `#` is TRUNCATED at it. That is not hypothetical and it is not harmless
	# in general: it is the mechanism that made 108 and 109 disagree about a
	# count of this very directory (see the long note above _counter_equalities
	# for the arithmetic). A reader that blanks comments THIS way reports 528
	# `_check` conditions with an `==` in tests/; one that knows a `#` inside
	# quotes is not a comment reports 524, and 524 is the number whose 54 sites
	# match 109's hand read site for site.
	#
	# MEASURED, at this commit, over both directories: 77 lines in tests/ and
	# 0 in scripts/ lose code to this. NONE of the 77 hides a needle any scan
	# in tests/ looks for - checked by taking every discarded tail and
	# searching it for the needles these suites use (res:// paths,
	# DirAccess.open, get_files_at, FileAccess.open, get_file_as_string,
	# _code_of, extends, preload, load, .size()); the only tails holding one
	# are five deliberate comment-blanking fixtures, where the text after the
	# `#` is the fixture and not code. So this is a property of the reader that
	# is ASSERTED here rather than a fault that is left open.
	#
	# NO POPULATION LINE IS WRITTEN FOR THE 77, DELIBERATELY. It would move
	# every time anyone wrote a `#` inside a string anywhere in tests/, with no
	# fault behind the movement, and scripts/ - the directory where a hidden
	# needle would actually cost something - is 0. A number that churns without
	# a fault behind it is the motion this project is trying not to accumulate.
	var in_quotes := "\tvar s := \"" + "#" + " %s\"\n" % needle
	_check(not _code_of(in_quotes).contains(needle),
		"a needle after a # INSIDE A DOUBLE-QUOTED STRING is discarded as well, because the reader cuts at the first # and does not know it is inside quotes")
	var in_single := "\tvar s := '" + "#" + " %s'\n" % needle
	_check(not _code_of(in_single).contains(needle),
		"and the same inside a single-quoted string, so this is about the # and not about one quote style")
	_check(_code_of("\tvar s := \"%s\"\n" % needle).contains(needle),
		"while the same string with no # in it keeps the needle, so the two above are not passing by seeing nothing")

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

	# --- 6. every registry-keyed table read in tests/ has a gate above it ---
	#
	# 105's own next entry. The six suites that guard correctly do so because
	# six authors each wrote the guard; nothing asked them to and nothing
	# noticed the one that did not. This asks.
	#
	# THE ACCESSORS FIRST, because a scan whose needles have been renamed finds
	# nothing, and finding nothing looks exactly like finding nothing wrong
	# (TRAPS 6). Each name is read back out of scripts/ as a declared function
	# before the sweep below is believed.
	var declared := _scripts_code()
	_check(not declared.is_empty(), "the code of scripts/ was read, so the accessor check below is not passing on an empty string")
	for call_name in _registry_calls():
		var bare := str(call_name).get_slice(".", 1).trim_suffix("()")
		_check(declared.contains("func " + bare + "("),
			"%s is still declared in scripts/, so this scan's needle for it is current" % str(call_name))

	var keyed := _registry_keyed_class()
	var keyed_sites := keyed.size()
	var keyed_files := {}
	var unguarded: Array = []
	var guarded_in: Array = []
	for site in keyed:
		var row: Dictionary = site
		keyed_files[str(row["file"])] = true
		if bool(row["guarded"]):
			guarded_in.append(str(row["where"]))
		else:
			unguarded.append(str(row["where"]))

	# THE BREADTH IN ONE LINE, so a reader never infers it from an absence of
	# failures (TRAPS 105's own rule, 078's floor). A scan that reached no
	# code at all would report 0 of 0 and pass every assertion below it.
	_check(keyed_sites > 0,
		"%d table read(s) keyed on a registry or whitelist were found in %d file(s) of tests/ - IF THIS FAILS, the scan reached no code: check _registry_calls() against scripts/ before believing tests/ has none" % [keyed_sites, keyed_files.size()])
	_check(unguarded.is_empty(),
		"every one of them has a has()-and-leave gate above it, so a member the table has no row for is reported and not thrown on: %s" % str(guarded_in) if unguarded.is_empty() else
		"a table in tests/ is indexed by a key that came from a registry with no gate above the read - a member with no row THROWS, and a script error in a SceneTree prints no verdict at all (TRAPS 105): " + ", ".join(PackedStringArray(unguarded)))

	# --- 7. and the scanner itself, on sources whose answer is known ---
	#
	# Section 6 is a presence check over code nobody wrote for it, so it can
	# be satisfied by a classifier that calls everything guarded, and its
	# breadth line can be satisfied by one site it read correctly by luck.
	# These five sources are the controls. The fourth is the shape TRAPS 105
	# is actually about and the reason `_guarded_above()` is not a `has()`
	# grep.
	var loop := "\tfor command in CommandParser.allowed_" + "commands():\n"
	var bare_read := loop + "\t\tvar row: Dictionary = table[command]\n"
	_check(_keyed_reads(bare_read).size() == 1,
		"a bare index read inside a registry loop is one site")
	_check(not bool((_keyed_reads(bare_read)[0] as Dictionary)["guarded"]),
		"and it is reported UNGUARDED, so section 6 is not passing by finding nothing")

	var gated := loop + "\t\tif not table.has(command):\n\t\t\tcontinue\n\t\tvar row: Dictionary = table[command]\n"
	var gated_sites := _keyed_reads(gated)
	_check(gated_sites.size() == 1 and bool((gated_sites[0] as Dictionary)["guarded"]),
		"the same read with has()-then-continue above it is reported GUARDED, so the two answers are distinguishable")

	# An ASSERTION is not a gate. This is the 76-commit fault itself, in four
	# lines: the membership question asked, recorded, and nothing leaving the
	# iteration on the answer.
	var asked_only := loop + "\t\t_check(table.has(command), \"there is a row for %s\" % command)\n\t\tvar row: Dictionary = table[command]\n"
	var asked_sites := _keyed_reads(asked_only)
	_check(asked_sites.size() == 1 and not bool((asked_sites[0] as Dictionary)["guarded"]),
		"a has() ASSERTION with nothing leaving the loop under it is UNGUARDED, which is the fault TRAPS 105 is about and the reason this is not a has() grep")

	# An `if not has():` whose block does NOT leave is the same fault wearing
	# the guard's clothes, and it is the one a reader skims past.
	var gate_that_does_not = loop + "\t\tif not table.has(command):\n\t\t\tbad += 1\n\t\tvar row: Dictionary = table[command]\n"
	var soft_sites := _keyed_reads(gate_that_does_not)
	_check(soft_sites.size() == 1 and not bool((soft_sites[0] as Dictionary)["guarded"]),
		"and an `if not has():` with no continue or return under it is UNGUARDED too")

	# THE TWO SHAPES THE FIRST VERSION OF THIS SCAN MISSED, controlled here
	# because they are not hypothetical: it found 4 sites where a prototype of
	# the same scan found 8, and the two missing shapes are the ones below -
	# one of them `command_schema_test`'s own, the site TRAPS 105 is about.
	var via_local := "\tvar whitelist: Array = CommandParser.allowed_" + "commands()\n\tfor command in whitelist:\n\t\tvar row = table[command]\n"
	var local_sites := _keyed_reads(via_local)
	_check(local_sites.size() == 1 and not bool((local_sites[0] as Dictionary)["guarded"]),
		"a registry call assigned to a local and the LOCAL iterated is still a registry-keyed loop")

	var via_alias := loop + "\t\tvar name := str(command)\n\t\tvar row = table[name]\n"
	var alias_sites := _keyed_reads(via_alias)
	_check(alias_sites.size() == 1 and not bool((alias_sites[0] as Dictionary)["guarded"]),
		"and a key DERIVED from the loop variable - str(command) - is still a key from elsewhere")

	# A WRITE creates the key and cannot throw, so it is not a site at all.
	_check(_keyed_reads(loop + "\t\tout[command] = 1\n").is_empty(),
		"a write to a table under a registry key is not a site, because an assignment creates the key")

	# AND THE LOOP SOURCE MATTERS. The same read keyed off a local collection
	# is not in the class: the keys came from the table's own author.
	_check(_keyed_reads("\tfor command in SOUND:\n\t\tvar row = table[command]\n").is_empty(),
		"while a loop over a local collection is not scanned at all, so section 6's sites are registry-keyed and not every index read in tests/")

	# --- 8. every equality between two counts of ONE collection, and the
	#        reading that rules on each one (HANDOVER's first live entry as of
	#        107) ---
	#
	# The shape, over all of tests/ rather than the two files 107 read. See
	# COUNTER_EQUALITIES above for where this came from, what the shape turned
	# out to be, and why the verdict is a row and not an assertion.
	var eq_sites := _counter_equality_class()
	var eq_files := {}
	var eq_keys := {}
	for site in eq_sites:
		var row: Dictionary = site
		eq_files[str(row["file"])] = true
		eq_keys[str(row["key"])] = str(row["where"])

	# THE BREADTH IN ONE LINE, so a reader never infers it from an absence of
	# failures (TRAPS 105's own rule, 078's floor). A scan that reached no code
	# at all would report 0 of 0 and pass the two table assertions below it,
	# because an empty class satisfies a table nobody is asked to match.
	_check(eq_sites.size() > 0,
		"%d assertion(s) comparing two counts of one collection were found in %d file(s) of tests/ - IF THIS FAILS, the scan reached no code: check _counter_equalities() against a built source in section 9 before believing tests/ has none" % [eq_sites.size(), eq_files.size()])

	# TRAPS 106's RULE, FIRST AND BY NAME, because everything else here is a
	# scan judging its own output: the instance this section was written for
	# must be in the class the scan derives. It is named by file and function
	# and counter, not by line, so moving it does not break this and renaming
	# it does.
	var came_from := "scan_floor_test.gd::_run::asked_for_null==open_kind"
	_check(eq_keys.has(came_from),
		"the instance this section came from is found by the scan that is supposed to hold it: %s at %s" % [
			came_from, str(eq_keys.get(came_from, "NOT FOUND"))])

	# EVERY SITE HAS A ROW, so a fifth one arriving fails here with nothing to
	# read it rather than joining the class in silence.
	for site in eq_sites:
		var row: Dictionary = site
		_check(COUNTER_EQUALITIES.has(str(row["key"])),
			"%s has a row saying whether its equality can fail" % str(row["where"]))

	# AND EVERY ROW IS STILL A SITE, so one LEAVING is noticed too - a row
	# whose assertion was deleted or rewritten would otherwise sit here
	# describing code that is gone, which is TRAPS 14's shape applied to this
	# table.
	for key in COUNTER_EQUALITIES:
		_check(eq_keys.has(str(key)),
			"%s is still an equality between two counts of one collection, so its row here is current" % str(key))

	# AND THE TABLE IS NOT A LIST OF ONE KIND. If every row said CAN FAIL the
	# table would be a formality; if every row said the opposite, the shape
	# would be the class after all. Both verdicts are present, counted off the
	# rows rather than stated in the comment above them.
	var can_fail := 0
	var cannot := 0
	for key in COUNTER_EQUALITIES:
		var row: Dictionary = COUNTER_EQUALITIES[key]
		if str(row["verdict"]).begins_with("CAN FAIL"):
			can_fail += 1
		else:
			cannot += 1
		_check(not str(row["why"]).is_empty(),
			"%s says why, in the row rather than in a comment" % str(key))
	_check(can_fail > 0 and cannot > 0,
		"and both verdicts are in the table, so the shape is a reading and not a rule: %d can fail, %d cannot" % [can_fail, cannot])

	# --- 9. the counter-equality reader, on sources whose answer is known ---
	#
	# Section 8 is a shape check over code nobody wrote for it, so it can be
	# satisfied by a reader that finds one site by luck and a table that was
	# written from that one site. These are the controls, and the first two are
	# the two narrownesses the first route to this enumeration actually had
	# (TRAPS 106): not hypothetical, measured, and each one cost the scan the
	# instance it was written to find.
	var decl := "func _f() -> void:\n\tvar a := 0\n\tvar b := 0\n"
	var two_loops := decl + "\tfor x in items:\n\t\ta += 1\n\tfor y in items:\n\t\tb += 1\n"

	# THE MATCH ARM, which is how scan_floor_test counts open_kind and is the
	# reason the first route reported 3 sites instead of 4.
	var on_arm := decl + "\tfor x in items:\n\t\tmatch x:\n\t\t\t\"open\": a += 1\n\tfor y in items:\n\t\tif y: continue\n\t\tb += 1\n"
	var arm_found := _counter_equalities(on_arm + "\t_check" + "(a == b, \"same\")\n")
	_check(arm_found.size() == 1,
		"a counter advanced on a match arm is still advanced inside its loop, which is the read the first route to this enumeration missed")

	# THE BRACKET INSIDE A MESSAGE, which ran the first route's reader past the
	# end of one _check( and made it report the NEXT assertion's text as a
	# site. The message here closes a paren that was never opened in code.
	var past_the_end := two_loops + "\t_check" + "(a == b, \"opens a ( and never closes it\")\n\t_check" + "(1 == 2, \"next\")\n"
	var past_found := _counter_equalities(past_the_end)
	_check(past_found.size() == 1 and int((past_found[0] as Dictionary)["line"]) == 8,
		"and a bracket inside a message does not run the condition reader into the next assertion: %d site(s)" % past_found.size())

	# THE PLAIN CASE, and the two things the key is built from.
	var plain := _counter_equalities(two_loops + "\t_check" + "(a == b, \"same\")\n")
	_check(plain.size() == 1, "two counters over one collection compared for equality is one site")
	_check(str((plain[0] as Dictionary)["coll"]) == "items" and str((plain[0] as Dictionary)["left"]) == "a" and str((plain[0] as Dictionary)["right"]) == "b",
		"and the collection and both counters are read off the code, which is what the row key is made of")

	# DIFFERENT COLLECTIONS ARE NOT THE SHAPE: two counts of two things can
	# differ for a reason that has nothing to do with either loop.
	_check(_counter_equalities(decl + "\tfor x in items:\n\t\ta += 1\n\tfor y in others:\n\t\tb += 1\n\t_check" + "(a == b, \"x\")\n").is_empty(),
		"while two counters over DIFFERENT collections are not in the class at all")

	# A COUNT WITH NO LOOP BEHIND IT is not a count of a collection.
	_check(_counter_equalities(decl + "\ta += 1\n\tfor y in items:\n\t\tb += 1\n\t_check" + "(a == b, \"x\")\n").is_empty(),
		"and a counter advanced outside every loop is not a count of anything this section is about")

	# A LITERAL IS NOT A COUNTER. refusal_reach_test's `worlds == 3` is the
	# case: it asserts the registry's size against a number somebody typed,
	# which is a different question and a falsifiable one.
	_check(_counter_equalities(decl + "\tfor x in items:\n\t\ta += 1\n\t_check" + "(a == 3, \"x\")\n").is_empty(),
		"and an equality against a typed number is not two counts of one collection")

	# SIZE() ON THE RIGHT IS the shape - it is how scan_floor_test's
	# conservation assertion is written - but only when the collection is the
	# one the counters walked.
	var summed := _counter_equalities(two_loops + "\t_check" + "(a + b == items.size(), \"x\")\n")
	_check(summed.size() == 1 and str((summed[0] as Dictionary)["right"]) == "items.size()",
		"a sum of two counters against the size of the collection they walked is one site")
	_check(_counter_equalities(two_loops + "\t_check" + "(a + b == others.size(), \"x\")\n").is_empty(),
		"and the same sum against the size of a DIFFERENT collection is not")

	# AND THE SOURCE IS CODE. A site inside a comment is not a site, which is
	# this file's own direction rule and the reason _code_of() is in the path.
	_check(_counter_equalities(_code_of(two_loops + "\t# _check" + "(a == b, \"commented out\")\n")).is_empty(),
		"and an assertion that exists only in a comment is not a site, because the scan reads what _code_of() leaves")

	print("SOURCE SCAN %d assertions, failures=%d" % [asserted, bad])
	quit(bad)


# --- 106: a table indexed by a key that came from a registry (TRAPS 105) ---
#
# WHERE THIS CAME FROM. 105 found that `command_schema_test` asserted
# `table.has(command)` off the whitelist and then read `table[command]` by
# index fourteen lines below the assertion. An assertion in these suites
# RECORDS and falls through, so a whitelisted command with no row reached the
# index read, which THROWS - and a script error in a `SceneTree` abandons
# `_initialize` before `quit()`, so the suite took the runner's 600-second
# timeout and printed none of the rows it had already found, including the one
# naming exactly what was wrong. Latent for 76 commits.
#
# 105 FIXED THE INSTANCE AND READ THE CLASS BY HAND: seven suites key a
# hand-written table on an enumerated whitelist or registry, six already
# guarded it, `command_schema_test` was the only outlier. **That reading was
# a reading.** Nothing asserted that the six keep their guards, and 105 wrote
# that down as its own next entry rather than leaving it to be rediscovered.
# This section is that assertion.
#
# WHAT IS A KEY "FROM ELSEWHERE", and the scope is NAMED because a grep has a
# scope and a rule does not (TRAPS 98). In scope: the loop variable of a
# `for ... in <accessor>()` over one of the registry and whitelist accessors
# in `_registry_calls()`, and anything DERIVED from it - `var word :=
# str(command)`, `var cmd := m.command()` - because a value computed from a
# member the table's author never saw is just as absent from the table.
#
# NOT IN SCOPE, said plainly rather than quietly skipped:
#   - per-member accessors that also answer with keys from elsewhere -
#     `module.lists()`, `t.defaults()`, `FarmModule.CROP_COLOURS.keys()`.
#     Measured: 6, 3 and 1 `for ... in` sites in tests/ today. The rule
#     covers them; this scan does not, and that is a bounded exclusion with
#     a note attached rather than a closed question (TRAPS 90).
#   - `scripts/`. The fault 105 found was in a suite, and so is every member
#     of the class it read. The same question asked of `scripts/` is a
#     different scan.
#   - a key reached through a function call rather than a local - a table
#     indexed inside a helper the loop calls. This scan is per-loop-body and
#     does not follow calls.
#
# AND THE SCAN IS NOT TRUSTED ON ITS OWN SAY-SO. Section 7 drives
# `_keyed_reads()` with synthetic sources whose answer is known, including the
# shape TRAPS 105 is actually about - a `has()` ASSERTION with no `continue`
# under it - so a classifier that answered "guarded" to everything, or that
# found nothing at all, fails there rather than passing here in silence.


# The CODE of every .gd in scripts/, concatenated. Its own read in its own
# function, with its own null question, because scan_floor_test holds both of
# those about every directory read in tests/ (078, 083) - and the floor that
# says what fails when it comes back empty is section 6's first assertion.
func _scripts_code() -> String:
	var out := ""
	var dir := DirAccess.open("res://scripts")
	if dir == null:
		return out
	for file_name in dir.get_files():
		var name := str(file_name)
		if not name.ends_with(".gd"):
			continue
		var handle := FileAccess.open("res://scripts/" + name, FileAccess.READ)
		if handle == null:
			continue
		out += _code_of(handle.get_as_text())
		handle.close()
	return out


# Every registry-keyed table read in tests/, as
# {"file","where","guarded"} per site. A DERIVED class: a suite that keys a
# table on a registry tomorrow is a site by arriving, with no row to add
# anywhere.
func _registry_keyed_class() -> Array:
	var out: Array = []
	var dir := DirAccess.open("res://tests")
	if dir == null:
		return out
	for file_name in dir.get_files():
		var name := str(file_name)
		if not name.ends_with(".gd"):
			continue
		var handle := FileAccess.open("res://tests/" + name, FileAccess.READ)
		if handle == null:
			continue
		var found := _keyed_reads(_code_of(handle.get_as_text()))
		handle.close()
		for site in found:
			var row: Dictionary = site
			out.append({
				"file": name,
				"where": "%s:%d  %s[%s]" % [name, int(row["line"]), str(row["table"]), str(row["key"])],
				"guarded": bool(row["guarded"]),
			})
	return out


# The accessors that answer with members a table's author never saw. Split
# across a `+` for the same reason `_needles()` is: this file is itself in
# `tests/` and this scan reads every file there, so a name written whole here
# would be a name this suite could find in its own source.
#
# EACH ONE IS ASSERTED TO STILL EXIST in `scripts/` below. A renamed accessor
# would otherwise empty this scan silently, which is the one failure mode a
# grep-shaped check has (TRAPS 6): finding nothing looks exactly like finding
# nothing wrong.
func _registry_calls() -> Array:
	return [
		"CommandParser.allowed_" + "commands()",
		"ToolRegistry." + "tools()",
		"ToolRegistry." + "names()",
		"ToolRegistry.free_" + "kit()",
		"WorldRegistry." + "modules()",
		"WorldRegistry." + "commands()",
	]


# Every `TABLE[key]` READ inside a registry-keyed loop in one source, as
# {"table","key","line","guarded"}. The source is expected to be CODE already
# - comments blanked by _code_of() - so nothing a comment says can add a site
# or take one away.
#
# GUARDED means: somewhere above the read, inside the same loop body, a line
# says `not TABLE.has(<the key or an alias>)` AND the block indented under
# that line reaches a `continue` or a `return`. The second half is the whole
# point: TRAPS 105's fault had the membership question ASKED fourteen lines
# above the read and nothing acting on the answer, so a check that accepted
# `has()` alone would have called the fault guarded.
func _keyed_reads(code: String) -> Array:
	var out: Array = []
	var lines := code.split("\n")
	var in_for := RegEx.create_from_string("^([\\t ]*)for[\\t ]+([A-Za-z_][A-Za-z0-9_]*)[\\t ]+in[\\t ]+(.+):[\\t ]*$")
	var alias_of := RegEx.create_from_string("^[\\t ]*var[\\t ]+([A-Za-z_][A-Za-z0-9_]*)[^=]*:?=[\\t ]*(.*)$")
	var words := RegEx.create_from_string("[A-Za-z_][A-Za-z0-9_]*")

	# A registry call assigned to a local and the LOCAL iterated, which is what
	# `command_schema_test` and `record_proposal_test` both do - `var whitelist:
	# Array = CommandParser.allowed_commands()`, then `for command in
	# whitelist:`. The first version of this function matched only the call on
	# the `for` line itself and therefore MISSED THE CANONICAL SITE, the one
	# TRAPS 105 is about. Measured against a prototype of the same scan rather
	# than reasoned about, and it is why section 7 controls this shape.
	var from_registry := {}
	for i in range(lines.size()):
		var m := alias_of.search(str(lines[i]))
		if m == null:
			continue
		for call_name in _registry_calls():
			if m.get_string(2).contains(str(call_name)):
				from_registry[m.get_string(1)] = true

	for i in range(lines.size()):
		var head := in_for.search(str(lines[i]))
		if head == null:
			continue
		var source := head.get_string(3)
		var is_registry := false
		for call_name in _registry_calls():
			if source.contains(str(call_name)):
				is_registry = true
		if from_registry.has(source.strip_edges()):
			is_registry = true
		if not is_registry:
			continue
		var base := head.get_string(1).length()

		# The body: every line indented further than the `for`, blanks
		# included so a blank line does not end a loop.
		var body: Array = []
		var j := i + 1
		while j < lines.size():
			var line := str(lines[j])
			if line.strip_edges() == "":
				body.append(j)
				j += 1
				continue
			if (line.length() - line.lstrip("\t ").length()) <= base:
				break
			body.append(j)
			j += 1

		# The keys: the loop variable, and anything a `var` in the body
		# computes from a key already known.
		var keys := {head.get_string(2): true}
		for n in body:
			var m := alias_of.search(str(lines[n]))
			if m == null:
				continue
			# ANY identifier derived from a known key makes the result a key
			# too: `var name := str(command)` and `var cmd := m.command()` are
			# both values the table's author never saw. The first version took
			# the FIRST identifier in the expression, which read `str` out of
			# `str(command)` and lost four sites - measured, which is the only
			# reason this reads the whole expression.
			for word in words.search_all(m.get_string(2)):
				if keys.has(word.get_string(0)):
					keys[m.get_string(1)] = true

		for n in body:
			var line := str(lines[n])
			for key in keys.keys():
				var read := RegEx.create_from_string("([A-Za-z_][A-Za-z0-9_]*)[\\t ]*\\[[\\t ]*" + str(key) + "[\\t ]*\\]([\\t ]*=[^=]|[\\t ]*$)?")
				for hit in read.search_all(line):
					# `out[key] = x` WRITES the key and cannot throw. Only a
					# read is a site.
					var trailing := hit.get_string(2)
					if trailing != "" and trailing.strip_edges().begins_with("="):
						continue
					out.append({
						"table": hit.get_string(1),
						"key": str(key),
						"line": n + 1,
						"guarded": _guarded_above(lines, body, n, hit.get_string(1), keys),
					})
	return out


# Is there a `not TABLE.has(<a key>)` above `at`, in this body, with a
# `continue` or `return` in the block under it?
func _guarded_above(lines: PackedStringArray, body: Array, at: int, table: String, keys: Dictionary) -> bool:
	for n in body:
		if int(n) >= at:
			break
		var line := str(lines[int(n)])
		var asks := false
		for key in keys.keys():
			if line.contains("not " + table + ".has(" + str(key) + ")"):
				asks = true
		if not asks:
			continue
		# The block under the question. An assertion is not a gate: if
		# nothing here leaves the iteration, the read below is reached
		# anyway, which is exactly the fault TRAPS 105 is about.
		var indent := line.length() - line.lstrip("\t ").length()
		var k := int(n) + 1
		while k < lines.size():
			var under := str(lines[k])
			if under.strip_edges() == "":
				k += 1
				continue
			if (under.length() - under.lstrip("\t ").length()) <= indent:
				break
			if under.contains("continue") or under.contains("return"):
				return true
			k += 1
	return false



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

# Every assertion in tests/ that compares two counts derived from ONE
# collection, as {"file","key","where","left","right","coll","func"} per site.
# A DERIVED class: a suite that writes one tomorrow is a site by arriving,
# which is why COUNTER_EQUALITIES is asked to name the whole class rather than
# a floor of it.
func _counter_equality_class() -> Array:
	var out: Array = []
	var dir := DirAccess.open("res://tests")
	if dir == null:
		return out
	for file_name in dir.get_files():
		var name := str(file_name)
		if not name.ends_with(".gd"):
			continue
		var handle := FileAccess.open("res://tests/" + name, FileAccess.READ)
		if handle == null:
			continue
		var found := _counter_equalities(_code_of(handle.get_as_text()))
		handle.close()
		for site in found:
			var row: Dictionary = site
			out.append({
				"file": name,
				"key": "%s::%s::%s==%s" % [name, str(row["func"]), str(row["left"]), str(row["right"])],
				"where": "%s:%d" % [name, int(row["line"])],
				"left": str(row["left"]),
				"right": str(row["right"]),
				"coll": str(row["coll"]),
				"func": str(row["func"]),
			})
	return out


# A line with the CONTENTS of every string literal replaced by x, so a bracket,
# a colon or an identifier inside a literal cannot be read as structure.
#
# THIS IS NOT A SECOND COMMENT STRIPPER and it is not a second _code_of()
# (TRAPS 89, and this file's own header): _code_of() is still the only reader
# of comments here and its byte-identical copies are still what section 3
# holds. What this does is the thing _code_of() deliberately does not - it
# leaves the literal's quotes in place and blanks what is between them - and
# it is needed because _code_of() cuts a line at its first `#` even inside a
# literal, which leaves an unterminated quote for the depth counting below to
# walk into. State is per line, so an unterminated quote ends with the line.
static func _masked(line: String) -> String:
	var out := ""
	var in_string := false
	var quote := ""
	var i := 0
	while i < line.length():
		var c := line.substr(i, 1)
		if in_string:
			if c == "\\" and i + 1 < line.length():
				out += "xx"
				i += 2
				continue
			if c == quote:
				out += c
				in_string = false
			else:
				out += "x"
		elif c == "\"" or c == "'":
			in_string = true
			quote = c
			out += c
		else:
			out += c
		i += 1
	return out


# Every counter equality in ONE source, as {"line","func","left","right",
# "coll"}. The source is expected to be CODE already - comments blanked by
# _code_of() - so nothing a comment says can add a site or take one away, and
# section 9 controls that with a commented-out site.
#
# A COUNTER is a local initialised to 0 on its own line and advanced with +=.
# ITS COLLECTION is the `for ... in X:` it is advanced inside, taken by
# indentation, so a `match` arm or an `if` between the two does not hide it -
# that omission is what made the first route to this enumeration miss the one
# instance it had to find (TRAPS 106).
# A SITE is a `_check()` whose condition has an `==` with counters on both
# sides, or counters on the left against `X.size()` on the right, where the set
# of collections reached on each side is the same and non-empty.
#
# WHAT THIS DOES NOT SEE, AND THE FIRST DRAFT OF THIS PARAGRAPH CLAIMED THE
# ANSWER WITHOUT LOOKING, which is TRAPS 14 in the file holding the rule
# against it. It said a count kept in a dictionary or an array element "does
# not occur in tests/ today - counted, not assumed". Nothing had been counted.
# WHAT WAS THEN COUNTED: tests/ holds 524 `_check` conditions containing an
# `==`; 54 of them have a container read - a `.size()` or a `[...]` - on BOTH
# sides of that `==`, and NONE of the 54 is in this scan's class, because
# neither side is a local advanced with `+=`. Two were read by hand and are
# honest assertions across two different sources
# (`field_type_test.gd:385`, `command_schema_test.gd:516`).
#
# 109 READ THE REST, AND FOUND ONE VACUOUS SITE AND A COUNT THAT DOES NOT
# REPRODUCE. Both halves matter and the second one is about this paragraph.
#
#   THE SITE: `claim_field_test.gd:363` asserted `contributing.size() ==
#   ToolRegistry.tools().size() + WorldRegistry.modules().size()` under the
#   message "every registry member is asked", with `contributing` appended to
#   exactly once per member by two loops holding no `continue` and no
#   condition. It could not fail. It is now membership by name, both ways, off
#   `ToolRegistry.names()` and `WorldRegistry.commands()`, with the count kept
#   beside it as the duplicate detector - see that file. It was the ONLY site
#   of the 55 read that no input and no duplicate can make fail;
#   `refusal_reach_test.gd:1222` is the same shape, already labelled as such
#   in 091, and a duplicate branch name does make it fire.
#
#   THE COUNT: 109 CALLED 524 AND 54 NOT REPRODUCIBLE. 110 RAN A THIRD ROUTE
#   AND THEY BOTH REPRODUCE EXACTLY. The definition that gives them, stated so
#   it can be re-derived rather than believed: a `#` starts a comment only
#   OUTSIDE a string literal; a `_check(` condition is its first argument, read
#   to the top-level comma by depth over string-masked text; a container read
#   is `.size()` or ANY `[`; the sides are the text either side of the first
#   top-level `==`. Under exactly that: 524 conditions with an `==`, and 54 of
#   them with a container read on both sides - at 3aa6589, the tree 108 and 109
#   both measured, AND at this commit.
#
#   AND THE PROOF IS NOT THE MATCHING NUMBER, WHICH COULD BE LUCK. It is that
#   the 54 sites under that definition are IDENTICAL, site for site, to the 54
#   that 109 read BY HAND and tabulated in docs/HANDOVER.md - 0 extra, 0
#   missing, the comparison taken against the table parsed out of that file
#   rather than retyped. 109 therefore held the independent enumeration that
#   confirmed 108 and compared its scan against neither it nor 108's sites.
#   That is TRAPS 108, and it is the inverse of TRAPS 106's shape.
#
#   WHAT DOES NOT REPRODUCE IS 109'S OWN THREE NUMBERS. 520, 34 and 53 are not
#   produced by any of twelve definitions tried, INCLUDING the one 109 states
#   it used: comments blanked the way `_code_of()` blanks them gives 528 and
#   55, not 520 and 53. The reason that reading is wrong is `_code_of()`
#   itself, and it is now asserted in section 9 part 4: it cuts at the first
#   `#` on a line even inside a string literal, and the four conditions it
#   corrupts in tests/ are - exactly - the four that test `_code_of()`'s own
#   blindness to a `#`. A reader that blanks comments the way the suites do
#   cannot read the assertions about the suites' blanking.
#
#   THE NUMBERS ARE LEFT STANDING AS 108 WROTE THEM, now confirmed rather than
#   disputed. All 54 sites were read individually in 109, by file and line,
#   with the verdict on each in docs/HANDOVER.md; the four in
#   `claim_field_test.gd` have since shifted line (363 -> 421, 478 -> 537,
#   554 -> 613, 640 -> 699) because 109 added lines above them, and the set is
#   otherwise unchanged.
#
# Also outside this scan, and not counted by it either: a counter advanced by
# anything but `+=`, and an equality between two counts of one collection that
# is computed and never asserted.
func _counter_equalities(code: String) -> Array:
	var out: Array = []
	var lines := code.split("\n")
	var var_zero := RegEx.create_from_string("^[\\t ]*var[\\t ]+([A-Za-z_][A-Za-z0-9_]*)[\\t ]*(?::[\\t ]*int[\\t ]*)?:?=[\\t ]*0[\\t ]*$")
	var inc := RegEx.create_from_string("(?:^[\\t ]*|[:;][\\t ]*)([A-Za-z_][A-Za-z0-9_]*)[\\t ]*\\+=")
	var for_line := RegEx.create_from_string("^([\\t ]*)for[\\t ]+[A-Za-z_][A-Za-z0-9_]*[\\t ]+in[\\t ]+(.+):[\\t ]*$")
	var func_line := RegEx.create_from_string("^[\\t ]*(?:static[\\t ]+)?func[\\t ]+([A-Za-z_][A-Za-z0-9_]*)")
	var word := RegEx.create_from_string("[A-Za-z_][A-Za-z0-9_]*")
	var size_call := RegEx.create_from_string("([A-Za-z_][A-Za-z0-9_]*)\\.size\\(\\)")

	# PASS 1: the counters, the collection each one is advanced inside, and the
	# function each line belongs to.
	var counters := {}
	var in_func := []
	var loop_indent: Array = []
	var loop_coll: Array = []
	var current := ""
	for i in range(lines.size()):
		var masked := _masked(str(lines[i]))
		in_func.append(current)
		if masked.strip_edges() == "":
			continue
		var indent := masked.length() - masked.lstrip("\t ").length()
		while not loop_indent.is_empty() and int(loop_indent[-1]) >= indent:
			loop_indent.resize(loop_indent.size() - 1)
			loop_coll.resize(loop_coll.size() - 1)
		var f := func_line.search(masked)
		if f != null:
			current = f.get_string(1)
			in_func[i] = current
			loop_indent.clear()
			loop_coll.clear()
		var v := var_zero.search(masked)
		if v != null and not counters.has(v.get_string(1)):
			counters[v.get_string(1)] = {}
		var a := inc.search(masked)
		if a != null and counters.has(a.get_string(1)):
			var where: String = str(loop_coll[-1]) if not loop_coll.is_empty() else "<no loop>"
			(counters[a.get_string(1)] as Dictionary)[where] = true
		var l := for_line.search(masked)
		if l != null:
			loop_indent.append(l.get_string(1).length())
			loop_coll.append(l.get_string(2).strip_edges())

	# PASS 2: the condition of every _check(), read from the _check( line
	# forward until the comma that ends the first argument. Depth is counted
	# over MASKED text, so a bracket inside a message cannot run the read past
	# the end of the call - which is the second thing the first route got
	# wrong.
	for i in range(lines.size()):
		var masked_line := _masked(str(lines[i]))
		var at := masked_line.find("_check(")
		if at < 0:
			continue
		var condition := ""
		var depth := 0
		var closed := false
		for j in range(i, mini(i + 12, lines.size())):
			var seg := _masked(str(lines[j]))
			if j == i:
				seg = seg.substr(at + 7)
			var k := 0
			while k < seg.length():
				var c := seg.substr(k, 1)
				if c == "(" or c == "[":
					depth += 1
				elif c == ")" or c == "]":
					if depth == 0:
						closed = true
						break
					depth -= 1
				elif c == "," and depth == 0:
					closed = true
					break
				condition += c
				k += 1
			if closed:
				break
			condition += " "
		if not closed:
			continue
		# Each top-level conjunct separately: `a == b and a > 0` is two claims
		# and only one of them is this shape.
		var parts: Array = []
		for chunk in condition.split(" and "):
			for piece in str(chunk).split(" or "):
				parts.append(str(piece))
		for part in parts:
			var text := str(part)
			var eq := text.find("==")
			if eq < 0:
				continue
			var left_text := text.substr(0, eq)
			var right_text := text.substr(eq + 2)
			var left_names := _counters_in(left_text, counters, word)
			var right_names := _counters_in(right_text, counters, word)
			if left_names.is_empty():
				continue
			var right_label := ",".join(PackedStringArray(right_names))
			var right_colls := _colls_of(right_names, counters)
			var s := size_call.search(right_text)
			if right_names.is_empty():
				if s == null:
					continue
				right_label = s.get_string(1) + ".size()"
				right_colls[s.get_string(1)] = true
			var left_colls := _colls_of(left_names, counters)
			if left_colls.is_empty() or left_colls.has("<no loop>") or right_colls.has("<no loop>"):
				continue
			var left_keys: Array = left_colls.keys()
			var right_keys: Array = right_colls.keys()
			left_keys.sort()
			right_keys.sort()
			if left_keys != right_keys:
				continue
			out.append({
				"line": i + 1,
				"func": str(in_func[i]) if i < in_func.size() else "",
				"left": ",".join(PackedStringArray(left_names)),
				"right": right_label,
				"coll": ",".join(PackedStringArray(left_keys)),
			})
	return out


# The counter names a piece of an expression mentions, sorted so a key written
# from them does not depend on which side of the `+` somebody typed first.
func _counters_in(text: String, counters: Dictionary, word: RegEx) -> Array:
	var seen := {}
	for m in word.search_all(text):
		var name := (m as RegExMatch).get_string(0)
		if counters.has(name):
			seen[name] = true
	var names: Array = seen.keys()
	names.sort()
	return names


# Every collection the given counters are advanced inside, as a set.
func _colls_of(names: Array, counters: Dictionary) -> Dictionary:
	var out := {}
	for name in names:
		for coll in (counters[str(name)] as Dictionary):
			out[str(coll)] = true
	return out

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
