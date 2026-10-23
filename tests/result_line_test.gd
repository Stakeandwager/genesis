extends SceneTree

# --- 077: the result line nothing read, and the two early exits 076 left ---
#
# WHERE THIS CAME FROM. 076 gave the remaining 55 suites an assertion count on
# their result line, closing the class TRAPS 73 names: a line that reports only
# how many assertions FAILED cannot report that one stopped running. It then
# wrote down, in TRAPS 73 and under "Next action", exactly what it had NOT
# done:
#
#   "Nothing asserts the counts. No suite checks that a result line carries
#    one ... A suite added without a count would be caught by nobody - which
#    is how this class reached 55 members in the first place."
#
# That is this file. It is the reader the 71 counts never had.
#
# AND IT FOUND TWO ON ITS FIRST RUN, which is the reason it is worth having
# rather than a tidy-up. 076 counted SUITES and fixed the last result line of
# each. The class is not suites, it is RESULT LINES, and three suites print
# more than one: an early exit that gives up before the body runs prints its
# own. 076 rewrote report_test's early-exit line and said so. It did not ask
# how many others there were. There were two:
#
#   look_test.gd:32        "LOOK TEST failures=%d"    - the picture it could
#                          not write; _check(false) has run, so the line is
#                          true, and it still carried no count.
#   load_check_test.gd:62  "LOAD CHECK failures=%d"   - worse, see below.
#
# TRAPS 11, one commit after the commit that quoted TRAPS 11 at itself.
#
# THE SECOND ONE WAS NOT ONLY MISSING A COUNT. _measure() has two ways out
# that return {}. One calls _check(false) first, so bad is 1 and the line read
# "failures=1". The other - measure() returning nothing at all - records
# nothing, so the line read "LOAD CHECK failures=0" and the suite quit(1).
# run_tests.sh reads the LINE and not the exit code, so a load check that had
# measured nothing whatsoever would have been counted as a pass. Missing
# evidence becoming success is the one thing PROTOCOL names by name. That path
# now records the failure before it prints.
#
# THE THIRD THING, FOUND WHILE MEASURING THE FIRST TWO AND HELD HERE BECAUSE
# IT IS THE SAME QUESTION ASKED OF THE OTHER CHANNEL. A suite reports its
# result twice: the line it prints, and the code it exits with. FIVE suites
# ended "quit()" or "quit(0)" below a line that reports a variable number of
# failures, so running one of them alone - which this project's own runner
# tells you to do when something looks wrong - gave $? = 0 on a failing suite.
# Neither runner reads the exit code (run_tests.sh uses it only to spot a
# timeout, run_tests.bat not at all), so nothing was being mis-reported today;
# what was true is that one of the two channels had stopped being connected to
# anything. Section 4 holds it and all five are fixed.
#
# WHAT THIS FILE ASSERTS, AND IT IS A SCAN OF SOURCE, SAID PLAINLY. It cannot
# run 72 suites to read their output - the slow two take minutes apiece - so
# it reads what each suite's result line WILL print. That is a question about
# what the code does, so it is answered from the code and not from the raw
# file (TRAPS 64): comments are blanked by the same _code_of() the other ten
# scanners use, and section 5 proves a count mentioned only in a comment does
# not satisfy it.
#
# WHAT IT DOES NOT PROVE, because the gap is the part worth writing down:
#
#   - It does not prove a count is CORRECT. "%d assertions" fed by a live
#     counter is all that can be read statically; whether that counter is
#     incremented at every site that decides pass or fail is per-file work and
#     was done by hand in 076, member by member.
#   - It does not prove quit(1) is the right code on a path, only that the
#     path cannot exit 0 while its line reports failures. A non-zero literal
#     can never turn a failure into a success, which is the direction that
#     matters.
#   - It reads one "extends" into tests/ to find an inherited counter, because
#     session_test has one. Two levels would not be found. Section 6 proves
#     that step is load-bearing rather than decorative.

var asserted := 0
var bad := 0

# The files in tests/ that print NO result line, with the reason each one is
# not in the class. These are not skipped: section 1 asserts of every one of
# them that it really prints no such line, so a file that starts printing one
# joins the class and is asked the same questions as the rest. A row here that
# has stopped being true is a row to strike, and it should never go unremarked
# (TRAPS 14).
const NO_RESULT_LINE := {
	"prompt_test.gd": "prints the AI's prompt for a human to read and has no verdict to give",
	"replay.gd": "a tool that needs REPLAY_LOG and REPLAY_OUT set, not a suite",
	"sweep_test.gd": "prints a VERDICT by design, because what it reports is a finding",
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


# --- the needles, BUILT rather than typed ---
#
# Every needle below is assembled from pieces so that no line of this file is
# itself mistaken for a result line. This file has exactly one, at the bottom
# of _run(), and it is in the class and asked the same questions as every
# other. The same trick source_scan_test uses on res:// paths, for the same
# reason: a scanner that can be answered by its own source is not a scanner.
func _print_call() -> String:
	return "pri" + "nt("


func _verdict_words() -> Array:
	return ["fail" + "ures=", "ba" + "d="]


func _assertions_word() -> String:
	return " asser" + "tions"


func _quit_call() -> String:
	return "qui" + "t("


# --- reading ---

var _code_cache := {}


func _code_for(name: String) -> String:
	if _code_cache.has(name):
		return str(_code_cache[name])
	var file := FileAccess.open("res://tests/" + name, FileAccess.READ)
	if file == null:
		_code_cache[name] = ""
		return ""
	var code := _code_of(file.get_as_text())
	file.close()
	_code_cache[name] = code
	return code


func _test_files() -> Array:
	var out: Array = []
	var dir := DirAccess.open("res://tests")
	if dir == null:
		return out
	for file_name in dir.get_files():
		var name := str(file_name)
		if name.ends_with(".gd"):
			out.append(name)
	out.sort()
	return out


# A result line is a line of CODE that calls print and names one of the two
# verdict words the runners match on. Returned as [line number, text], so a
# failure below can say where to look rather than what to grep for.
func _result_lines_of(name: String) -> Array:
	var out: Array = []
	var number := 0
	for raw in _code_for(name).split("\n"):
		var line := str(raw)
		number += 1
		if not line.contains(_print_call()):
			continue
		var verdict := false
		for word in _verdict_words():
			if line.contains(str(word)):
				verdict = true
		if verdict:
			out.append([number, line])
	return out


# --- what a line says ---

# The count is a conversion specifier immediately before the word, so a number
# typed into the format string ("TOOL TEST 21 assertions") is not one: it
# would not move when an assertion stopped running, which is the whole fault.
func _carries_a_count(line: String) -> bool:
	var at := line.find(_assertions_word())
	if at < 2:
		return false
	var spec := line.substr(at - 2, 2)
	return spec == "%d" or spec == "%s"


# The line with every string literal removed, leaving the format arguments.
func _without_strings(line: String) -> String:
	var out := ""
	var inside := false
	var i := 0
	while i < line.length():
		var c := line.substr(i, 1)
		if inside and c == "\\":
			i += 2
			continue
		if c == "\"":
			inside = not inside
			i += 1
			continue
		if not inside:
			out += c
		i += 1
	return out


# The top-level format arguments of a print line, in order.
func _format_args(line: String) -> Array:
	var bare := _without_strings(line)
	var at := bare.find("%")
	if at < 0:
		return []
	var rest := bare.substr(at + 1).strip_edges()
	if not rest.begins_with("["):
		while rest.ends_with(")"):
			rest = rest.substr(0, rest.length() - 1)
		return [rest.strip_edges()]
	rest = rest.substr(1)
	var out: Array = []
	var current := ""
	var depth := 0
	for i in rest.length():
		var c := rest.substr(i, 1)
		if depth == 0 and c == "]":
			break
		if depth == 0 and c == ",":
			out.append(current.strip_edges())
			current = ""
			continue
		if c == "(" or c == "[":
			depth += 1
		elif c == ")" or c == "]":
			depth -= 1
		current += c
	if current.strip_edges() != "":
		out.append(current.strip_edges())
	return out


# The names in an expression. A run of digits is not a name, which is how a
# literal argument is told from a counter.
func _names_in(expression: String) -> Array:
	var out: Array = []
	var current := ""
	var text := expression + " "
	for i in text.length():
		var c := text.substr(i, 1)
		var wordy := (c >= "a" and c <= "z") or (c >= "A" and c <= "Z") or (c >= "0" and c <= "9") or c == "_"
		if wordy:
			current += c
			continue
		if current != "":
			var head := current.substr(0, 1)
			var numeric := head >= "0" and head <= "9"
			if not numeric and not out.has(current):
				out.append(current)
		current = ""
	return out


func _name_before(line: String, at: int) -> String:
	var i := at - 1
	while i >= 0 and line.substr(i, 1) == " ":
		i -= 1
	var name := ""
	while i >= 0:
		var c := line.substr(i, 1)
		var wordy := (c >= "a" and c <= "z") or (c >= "A" and c <= "Z") or (c >= "0" and c <= "9") or c == "_"
		if not wordy:
			break
		name = c + name
		i -= 1
	return name


# Every name this code increments or appends to: the names that can carry a
# count. A name that is only ever read cannot.
func _mutated_in(code: String) -> Array:
	var out: Array = []
	for raw in code.split("\n"):
		var line := str(raw)
		for marker in ["+=", ".append("]:
			var at := line.find(str(marker))
			while at > 0:
				var name := _name_before(line, at)
				if name != "" and not out.has(name):
					out.append(name)
				at = line.find(str(marker), at + 1)
	return out


# The suite in tests/ this one extends, or "" - session_test is the one that
# has one, and its counter lives in the parent.
func _parent_of(name: String) -> String:
	var marker := "res:/" + "/tests/"
	for raw in _code_for(name).split("\n"):
		var line := str(raw)
		if not line.strip_edges().begins_with("extends"):
			continue
		var at := line.find(marker)
		if at < 0:
			continue
		var rest := line.substr(at + marker.length())
		var end := rest.find("\"")
		if end > 0:
			return rest.substr(0, end)
	return ""


func _live_names(name: String) -> Array:
	var out := _mutated_in(_code_for(name))
	var parent := _parent_of(name)
	if parent != "" and parent != name:
		for extra in _mutated_in(_code_for(parent)):
			if not out.has(extra):
				out.append(str(extra))
	return out


# The argument of the first quit() within four lines below a result line, or
# "<none>" if there is not one. "" is a real answer and means quit().
func _quit_below(name: String, number: int) -> String:
	var lines := _code_for(name).split("\n")
	for offset in range(1, 5):
		var index := number - 1 + offset
		if index >= lines.size():
			break
		var line := str(lines[index])
		var at := line.find(_quit_call())
		if at < 0:
			continue
		var rest := line.substr(at + _quit_call().length())
		var close := rest.rfind(")")
		return (rest if close < 0 else rest.substr(0, close)).strip_edges()
	return "<none>"


func _shares_a_name(one: Array, two: Array) -> bool:
	for name in one:
		if two.has(name):
			return true
	return false


func _run() -> void:
	print("--- 077: every result line in tests/, and whether it can report a loss ---")

	var files := _test_files()
	var members: Array = []
	for name in files:
		if not _result_lines_of(str(name)).is_empty():
			members.append(str(name))

	# --- 1. the class enumerates itself, and the exclusions are facts ---
	#
	# Not a floor and not a list: every .gd in tests/ is either a member or
	# carries a row in NO_RESULT_LINE, so a suite added tomorrow is in the
	# class by arriving, and a tool added tomorrow has to be accounted for.
	# That is the property the 71 counts were missing.
	_check(not files.is_empty(), "tests/ was read and holds %d .gd files" % files.size())
	_check(members.size() > 0, "%d of them print a result line" % members.size())
	for name in files:
		var is_member: bool = members.has(str(name))
		var excused: bool = NO_RESULT_LINE.has(str(name))
		var says := ""
		if is_member and excused:
			says = "prints a result line AND carries a row here saying it does not - strike the row"
		elif is_member:
			says = "is in the class"
		elif excused:
			says = "prints no result line, because it " + str(NO_RESULT_LINE[name])
		else:
			says = "prints no result line and has no row here - give it one, or add the row"
		_check(is_member != excused, "%s %s" % [name, says])
	for name in NO_RESULT_LINE:
		_check(files.has(str(name)), "%s still exists, so its row here is current" % str(name))

	# --- 2. every result line carries an assertion count ---
	#
	# Every line, not every suite. Three suites print one from an early exit
	# as well as from the end of the body, and that is where 076's two
	# survivors were.
	var lines_seen := 0
	for name in members:
		for row in _result_lines_of(str(name)):
			lines_seen += 1
			var number: int = row[0]
			var text: String = str(row[1])
			_check(_carries_a_count(text),
				"%s:%d says how many ran, not only how many failed" % [name, number])
	_check(lines_seen >= members.size(),
		"%d result lines across %d suites, so a suite with two was not read as one" % [lines_seen, members.size()])

	# --- 3. and the count is a counter, not a number somebody typed ---
	for name in members:
		var live := _live_names(str(name))
		for row in _result_lines_of(str(name)):
			var number: int = row[0]
			var text: String = str(row[1])
			var args := _format_args(text)
			var first: String = str(args[0]) if not args.is_empty() else ""
			_check(_shares_a_name(_names_in(first), live),
				"%s:%d gets its count from something the suite increments (%s)" % [name, number, first])

	# --- 4. and the other channel agrees with it ---
	#
	# The code a suite exits with is its second report. quit() and quit(0)
	# below a line that reports a variable number of failures cannot say a
	# suite failed; a non-zero literal can never say one passed, which is the
	# direction that matters, so it is allowed and named as allowed.
	for name in members:
		for row in _result_lines_of(str(name)):
			var number: int = row[0]
			var text: String = str(row[1])
			var code := _quit_below(str(name), number)
			var args := _format_args(text)
			var reported: String = str(args[args.size() - 1]) if not args.is_empty() else ""
			var names := _names_in(code)
			var ok := false
			var why := ""
			if code == "<none>":
				why = "no quit() follows it"
			elif code == "" or code == "0":
				why = "quit(%s) cannot report a failure" % code
			elif names.is_empty():
				ok = true
				why = "quit(%s), a non-zero literal, which cannot report a pass" % code
			elif _shares_a_name(names, _names_in(reported)):
				ok = true
				why = "quit(%s) reports what the line reports" % code
			else:
				why = "the line reports %s and quit(%s) names something else" % [reported, code]
			_check(ok, "%s:%d exits with a code that can say it failed: %s" % [name, number, why])

	# --- 5. the reader itself, which is the half this file can prove ---
	#
	# Built sources rather than files, so these answer for the reader and not
	# for whatever happens to be on disk. The needles are assembled the same
	# way the scan's are, so none of these lines is a result line either.
	var head := "\t" + _print_call() + "\"X %d" + _assertions_word() + ", " + str(_verdict_words()[0])
	var with_count := head + "%d\" % [asserted, bad])"
	var without_count := "\t" + _print_call() + "\"X " + str(_verdict_words()[0]) + "%d\" % bad)"
	var typed_count := "\t" + _print_call() + "\"X 21" + _assertions_word() + ", " + str(_verdict_words()[0]) + "%d\" % bad)"
	var in_a_comment := "\t# " + _print_call() + "\"X %d" + _assertions_word() + ", " + str(_verdict_words()[0]) + "%d\" % [asserted, bad])"

	_check(_carries_a_count(with_count), "a line with a specifier before the word carries a count")
	_check(not _carries_a_count(without_count), "a line without the word does not")
	_check(not _carries_a_count(typed_count),
		"and neither does a number typed into the format string, which would never move")
	_check(_code_of(in_a_comment).strip_edges() == "",
		"a result line written in a comment is not code, so it can satisfy nothing here (TRAPS 63)")

	_check(_format_args(with_count) == ["asserted", "bad"], "the format arguments are read in order")
	_check(_format_args(without_count) == ["bad"], "a single argument is read without its brackets")
	_check(_names_in("21") .is_empty(), "a run of digits is not a name, so a literal argument is not a counter")
	_check(_names_in("lines.size() - _notes()") == ["lines", "size", "_notes"],
		"and an expression yields every name in it, so a count built from a list is read")

	_check(_mutated_in("\tasserted += 1\n").has("asserted"), "a name that is incremented is live")
	_check(_mutated_in("\tfailures.append(what)\n").has("failures"), "and so is one that is appended to")
	_check(not _mutated_in("\tvar n := asserted\n\tprin" + "t(asserted)\n").has("asserted"),
		"while a name that is only ever read is not")

	# --- 6. the inherited counter, asserted rather than assumed ---
	#
	# session_test extends drive_test and prints a count it never increments
	# itself: without the one "extends" step, section 3 fails on it. This
	# asserts the step is load-bearing, so nobody later removes it as tidy-up,
	# and that it is ONE level and not a general resolver.
	var session := "session_test.gd"
	_check(members.has(session), "%s is in the class" % session)
	_check(_parent_of(session) == "drive_test.gd",
		"%s extends drive_test.gd, which is where its counter lives" % session)
	_check(not _mutated_in(_code_for(session)).has("asserted"),
		"%s increments nothing called asserted in its own code" % session)
	_check(_live_names(session).has("asserted"),
		"and the one extends step is what finds it, so section 3 is not passing by accident")
	_check(_parent_of("look_test.gd") == "",
		"while a suite that extends SceneTree has no parent in tests/")

	print("RESULT LINE %d assertions, failures=%d" % [asserted, bad])
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
