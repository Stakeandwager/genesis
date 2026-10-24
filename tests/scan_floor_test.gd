extends SceneTree

# --- 078: the scans that read a directory, and whether an empty read is a
#          pass ---
#
# WHERE THIS CAME FROM. 077 closed the result-line class: every line now says
# how many assertions RAN as well as how many failed, because a line that
# reports only failures cannot report that an assertion stopped running. It
# then wrote down what it had not done, and that sentence is the live entry in
# HANDOVER's "Next action":
#
#   "nothing holds that asserted is incremented at every site that decides
#    pass or fail ... it cannot see whether the increment happens on every
#    path."
#
# Reading for that found something sharper than a drifted counter. A count
# only sounds an alarm if somebody reads the alarm, and the loudest possible
# reading - ZERO - was being read as a pass. THREE suites could print a clean
# result line having measured nothing, and one of them printed a clean line
# having measured nothing AT ALL:
#
#   loadcheck.gd              "LOADCHECK 0 assertions, bad=0", exit 0
#   controller_reach_test.gd  two scan sites, 120 assertions, failures=0
#   prompt_numeral_test.gd    one scan site, 116 assertions, failures=0
#
# MEASURED, NOT ARGUED. Each was run in a throwaway project with its own
# config/name (TRAPS 50), with its DirAccess.open pointed at a directory that
# EXISTS AND IS EMPTY - which is the case a null check cannot see, and
# prompt_numeral_test had a null check. The numbers above are those runs. The
# six other members of the class failed that same run, by name, between 1 and
# 37 failures apiece, so the class was already two thirds right and it was the
# missing third that mattered: run_tests.sh matches "*bad=0" and
# "*failures=0" as a pass, so loadcheck's line was a pass in both channels.
#
# THE RULE, and it is this project's own rule rather than a new one.
# record_id_test already states it in as many words:
#
#   _check(not starts.is_empty(),
#       "at least one suite in tests/ starts a session, so this section is
#        measuring something")
#
# What 078 does is apply it everywhere it holds (TRAPS 11):
#
#   a scan that reads a directory must assert that the read produced
#   something, or its cleanest result is the one it gives when it has looked
#   at nothing.
#
# THE DIRECTION THAT MAKES THIS WORSE THAN A MISSING COUNT, and the reason two
# of the four sites were assertions that PASSED rather than assertions that
# vanished: an absence proved by reading nothing is not an absence.
# prompt_numeral_test's row asserts no file holds a STRAY prompt template, and
# controller_reach_test's asserts that nothing in scripts/ appends to
# corner_nodes - which is the PREMISE for its claim that two refusal branches
# are out of a player's reach. Both of those rows are at their greenest when
# the scan has read the fewest files. That is TRAPS 6 - a test that guards an
# assumption instead of checking a fact - and TRAPS 14, because the second one
# underwrites a published claim about what Genesis cannot do.
#
# WHAT THIS FILE HOLDS. The class is DERIVED, not listed: every .gd in tests/
# whose CODE calls DirAccess.open on a res:// path is a site, found by reading
# the code and not by a list anybody maintains, so a scan added tomorrow is in
# the class by arriving and fails here until it is accounted for. Of each site
# it asks two questions it can answer from the source:
#
#   1. is the open checked for null, in the function that opened it;
#   2. is there a named assertion that fails when the read comes back empty.
#
# WHAT IT DOES NOT PROVE, said plainly, because this is the half that matters
# and the half a scan cannot reach. It does NOT prove a floor is load-bearing.
# FLOORS names the condition that covers each site and this file asserts that
# condition is still in that file's code; it cannot prove that condition would
# actually fail on an empty read. Proving that needs the suite RUN against an
# empty directory, which cannot be done from inside a sibling suite - it takes
# a throwaway project per suite. That measurement was taken for all eleven
# sites in 078 and the numbers are recorded in docs/HANDOVER.md; what this
# file adds is that the named floor cannot be deleted or renamed in silence,
# and that a NEW read arrives with no floor named at all.
#
# A SECOND THING IT DOES NOT PROVE, and it is the honest limit of the rows
# below. check_wiring_test's _no_door_rows does "if dir == null: continue",
# which on a null read drops its assertions rather than recording them - the
# vanishing this whole class is about. It is covered at SUITE level and not at
# site level: _verdict_functions' floor is in the same suite and fires on any
# bad read of scripts/, so the suite cannot report a pass. That is why its row
# below names a condition in a different function, and it is the one row here
# where the floor and the site are not in the same place.


var asserted := 0
var bad := 0


# Every DirAccess.open site in tests/, as "file::function" -> the assertion
# that fails when that read comes back empty.
#
# "floor" is a CONDITION and not a message. A row that named the wording would
# be a test of the wording (TRAPS 6); the condition is the thing that decides,
# and section 3 counts occurrences, so two sites in one file sharing a
# condition need two of them in the code.
#
# NO COUNT IS WRITTEN IN THIS SENTENCE, and section 1 asserts against the
# derived class rather than against the size of this dictionary (TRAPS 24).
const FLOORS := {
	"agreement_test.gd::_scripts": {
		"floor": "nouns.size() >= 10",
		"why": "the nouns are read off scripts/ through this helper, so an empty read leaves none",
	},
	"check_wiring_test.gd::_verdict_functions": {
		"floor": "found.size() >= 30",
		"why": "the verdict functions come from this read and the floor is on the caller's side",
	},
	"check_wiring_test.gd::_no_door_rows": {
		"floor": "found.size() >= 30",
		"suite_level": true,
		"why": "this read's own path does 'continue' on null, so its assertions vanish rather than fail; _verdict_functions' floor is in the same suite and fires on any bad read of scripts/, which is what stops the suite reporting a pass. The one site here covered by another site's floor, named rather than quietly relied on",
	},
	"controller_reach_test.gd::_enumeration": {
		"floor": "scanned > 0",
		"why": "078: every assertion in this section comes out of the loop, so an empty read made none of them",
	},
	"controller_reach_test.gd::_guard_spawn_opponents": {
		"floor": "scanned > 0",
		"why": "078: the assertion here is an absence, and it underwrites the claim that SPAWN_OPPONENTS' two branches are unreachable",
	},
	"loadcheck.gd::_initialize": {
		"floor": "loaded == 0",
		"why": "078: this suite printed '0 assertions, bad=0' and exited 0 on an empty read, which run_tests.sh counts as a pass",
	},
	"prompt_numeral_test.gd::_initialize": {
		"floor": "scanned > 0",
		"why": "078: the stray-template row is an absence, and a null check cannot see a directory that is merely empty",
	},
	"record_id_test.gd::_session_starts": {
		"floor": "not starts.is_empty()",
		"why": "the row this project's own rule comes from: 'so this section is measuring something'",
	},
	"refusal_reach_test.gd::_categories_in_source": {
		"floor": "in_code.size() >= 16",
		"why": "the FAILED_ categories come from this read and the floor is on the caller's side",
	},
	"result_line_test.gd::_test_files": {
		"floor": "not files.is_empty()",
		"why": "077 built this one with its floor, which is why it was the one scan that could not pass on an empty read",
	},
	"scan_floor_test.gd::_test_files": {
		"floor": "not files.is_empty()",
		"why": "this file reads tests/ to find the sites, so it is a member of its own class and is asked the same two questions",
	},
	"source_scan_test.gd::_class": {
		"floor": "members.size() >= KNOWN.size()",
		"why": "its section 1 already names TRAPS 6 as the reason it is there",
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


# --- the needles, BUILT rather than typed ---
#
# This file's own call is a site and has a row, which is right. What must not
# happen is the needle itself being read as a twelfth site, so the needle is
# assembled from pieces. The same trick source_scan_test and result_line_test
# use, for the same reason: a scanner its own source can answer is not a
# scanner.
func _open_call() -> String:
	return "DirAcc" + "ess.open("


func _res_prefix() -> String:
	return "res:/" + "/"


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


# The name declared on a line, or "" - the variable an open is assigned to.
func _declared_on(line: String) -> String:
	var at := line.find("var ")
	if at < 0:
		return ""
	var rest := line.substr(at + 4)
	var name := ""
	for i in rest.length():
		var c := rest.substr(i, 1)
		var wordy := (c >= "a" and c <= "z") or (c >= "A" and c <= "Z") or (c >= "0" and c <= "9") or c == "_"
		if not wordy:
			break
		name += c
	return name


# The first quoted string on a line.
func _quoted_on(line: String) -> String:
	var open_at := line.find("\"")
	if open_at < 0:
		return ""
	var rest := line.substr(open_at + 1)
	var close_at := rest.find("\"")
	if close_at < 0:
		return ""
	return rest.substr(0, close_at)


# The name of the function a line of code sits in, or "<top>".
func _function_at(lines: Array, index: int) -> String:
	for i in range(index, -1, -1):
		var line := str(lines[i])
		var head := line.strip_edges()
		if not (head.begins_with("func ") or head.begins_with("static func ")):
			continue
		if line.begins_with("\t") or line.begins_with(" "):
			continue
		var rest := head.substr(5) if head.begins_with("func ") else head.substr(12)
		var name := ""
		for j in rest.length():
			var c := rest.substr(j, 1)
			var wordy := (c >= "a" and c <= "z") or (c >= "A" and c <= "Z") or (c >= "0" and c <= "9") or c == "_"
			if not wordy:
				break
			name += c
		return name
	return "<top>"


# The CODE of the function a line sits in: from its header to the first line
# that is neither blank nor indented.
func _function_body(lines: Array, index: int) -> String:
	var start := -1
	for i in range(index, -1, -1):
		var line := str(lines[i])
		var head := line.strip_edges()
		if (head.begins_with("func ") or head.begins_with("static func ")) and not (line.begins_with("\t") or line.begins_with(" ")):
			start = i
			break
	if start < 0:
		return ""
	var out := ""
	for i in range(start + 1, lines.size()):
		var line := str(lines[i])
		if line.strip_edges() != "" and not (line.begins_with("\t") or line.begins_with(" ")):
			break
		out += line + "\n"
	return out


# Every site in tests/: one row per DirAccess.open on a res:// path, read off
# the CODE so a call written in a comment is not one (TRAPS 64).
func _sites() -> Array:
	var out: Array = []
	for name in _test_files():
		var file_name := str(name)
		var lines := Array(_code_for(file_name).split("\n"))
		for i in lines.size():
			var line := str(lines[i])
			if not line.contains(_open_call()):
				continue
			var path := _quoted_on(line)
			if not path.begins_with(_res_prefix()):
				continue
			out.append({
				"file": file_name,
				"func": _function_at(lines, i),
				"var": _declared_on(line),
				"path": path,
				"line": i + 1,
				"body": _function_body(lines, i),
			})
	return out


func _occurrences(haystack: String, needle: String) -> int:
	if needle == "":
		return 0
	var n := 0
	var at := haystack.find(needle)
	while at >= 0:
		n += 1
		at = haystack.find(needle, at + 1)
	return n


func _run() -> void:
	print("--- 078: every directory read in tests/, and whether an empty read can pass ---")

	var sites := _sites()
	var keys: Array = []
	for site in sites:
		keys.append("%s::%s" % [str((site as Dictionary)["file"]), str((site as Dictionary)["func"])])

	# --- 1. the class enumerates itself, in both directions ---
	#
	# A derived class and not a list: a scan added tomorrow is a site by
	# arriving. Every site must have a row, and every row must name a site
	# that still exists - a row that has gone stale is a row to strike, and it
	# should never go unremarked (TRAPS 14).
	_check(not sites.is_empty(), "tests/ was read and holds %d directory reads" % sites.size())
	for i in sites.size():
		var site: Dictionary = sites[i]
		var key: String = str(keys[i])
		_check(FLOORS.has(key),
			"%s:%d (%s) has a row saying what fails when its read comes back empty" % [
				str(site["file"]), int(site["line"]), key])
	for key in FLOORS:
		_check(keys.has(str(key)),
			"%s is still a directory read, so its row here is current" % str(key))

	# --- 2. a unique key per site, so a row cannot cover two reads at once ---
	#
	# Two opens in one function would collide, and the row would silently
	# answer for whichever was asked first. Asserted rather than assumed.
	var seen := {}
	var collided: Array = []
	for key in keys:
		var k := str(key)
		if seen.has(k):
			collided.append(k)
		seen[k] = true
	_check(collided.is_empty(),
		"no function in tests/ opens two directories, so one row answers for one read (%s)" % str(collided))

	# --- 3. the open is checked for null, in the function that opened it ---
	#
	# This is the half loadcheck.gd failed: it was the only one of the eleven
	# that never tested the result, and dir.get_files() on a null dir throws
	# out of _initialize, which never reaches quit() (TRAPS 13).
	for site in sites:
		var s: Dictionary = site
		var name: String = str(s["var"])
		var body: String = str(s["body"])
		var checked := name != "" and (body.contains(name + " == null") or body.contains(name + " != null"))
		_check(checked,
			"%s:%d tests %s for null in %s, rather than throwing on it" % [
				str(s["file"]), int(s["line"]), name if name != "" else "<unnamed>", str(s["func"])])

	# --- 4. and the named floor is still in the code ---
	#
	# Counted, not merely present: two sites in one file that share a
	# condition need two of it, so deleting one is noticed. Read off the CODE,
	# so a condition left behind in a comment satisfies nothing.
	# A site's own floor is COUNTED: two sites in one file that share a
	# condition need two of it, so deleting one is noticed. A site marked
	# suite_level is covered by ANOTHER site's floor and is asked a weaker
	# question - that the condition is there at all - because counting it
	# would demand a second copy of an assertion that is deliberately
	# singular. Separating the two is not a convenience: the first version of
	# this section counted every row, and the suite's own first run caught the
	# _no_door_rows row by name for exactly that reason. The weaker question
	# is marked in the output so nobody reads it as the stronger one.
	var wanted := {}
	var shared: Array = []
	for i in sites.size():
		var key: String = str(keys[i])
		if not FLOORS.has(key):
			continue
		var row: Dictionary = FLOORS[key]
		var file_name: String = str((sites[i] as Dictionary)["file"])
		var floor_text: String = str(row["floor"])
		if bool(row.get("suite_level", false)):
			shared.append([key, file_name, floor_text])
			continue
		var tally_key := "%s\n%s" % [file_name, floor_text]
		wanted[tally_key] = int(wanted.get(tally_key, 0)) + 1
	for tally_key in wanted:
		var parts := str(tally_key).split("\n")
		var file_name := str(parts[0])
		var floor_text := str(parts[1])
		var need := int(wanted[tally_key])
		var got := _occurrences(_code_for(file_name), floor_text)
		_check(got >= need,
			"%s holds the condition '%s' %d time(s), and %d site(s) name it" % [
				file_name, floor_text, got, need])
		_check(not floor_text.contains("\""),
			"and that row names a condition rather than a message, so this is not a test of wording: '%s'" % floor_text)

	# The suite-level rows, asked the weaker question and told apart from the
	# rest. Each must also name a condition that some OTHER site's row names,
	# which is what "covered by another site's floor" means - a row that
	# invented a condition no site relies on would pass the presence check and
	# mean nothing.
	var site_floors := {}
	for i in sites.size():
		var key: String = str(keys[i])
		if not FLOORS.has(key):
			continue
		var row: Dictionary = FLOORS[key]
		if bool(row.get("suite_level", false)):
			continue
		site_floors["%s\n%s" % [str((sites[i] as Dictionary)["file"]), str(row["floor"])]] = true
	for entry in shared:
		var e: Array = entry
		var key: String = str(e[0])
		var file_name: String = str(e[1])
		var floor_text: String = str(e[2])
		_check(_occurrences(_code_for(file_name), floor_text) >= 1,
			"%s is covered at suite level, and '%s' is still in %s (weaker than the counted rows above)" % [
				key, floor_text, file_name])
		_check(site_floors.has("%s\n%s" % [file_name, floor_text]),
			"and that condition is a floor another site in %s names, so it is not one invented for this row" % file_name)

	# --- 5. this file is a member of its own class ---
	#
	# It reads tests/ to find the sites, so it is a site. Asserted rather than
	# left to be noticed, because a scanner exempt from its own rule is the
	# first thing to go stale.
	var mine := "scan_floor_test.gd::_test_files"
	_check(keys.has(mine), "%s is in the class it derives" % mine)
	_check(FLOORS.has(mine), "and it carries its own row like every other site")

	# --- 6. the reader itself, which is the half this file can prove ---
	#
	# Built sources rather than files, so these answer for the reader and not
	# for whatever happens to be on disk.
	var a_call := "\tvar dir := " + _open_call() + "\"" + _res_prefix() + "scripts\")"
	var in_a_comment := "\t# var dir := " + _open_call() + "\"" + _res_prefix() + "scripts\")"
	var a_user_path := "\tvar dir := " + _open_call() + "\"user:/" + "/worlds\")"

	_check(_declared_on(a_call) == "dir", "the name an open is assigned to is read off the line")
	_check(_declared_on("\tfor name in dir.get_files():") == "",
		"and a line that declares nothing yields no name")
	_check(_quoted_on(a_call) == _res_prefix() + "scripts", "the path is read off the line")
	_check(_quoted_on(a_user_path).begins_with(_res_prefix()) == false,
		"and a user:// open is not a res:// site, so the class is the repository's own files")
	_check(_code_of(in_a_comment).strip_edges() == "",
		"an open written in a comment is not code, so it is not a site (TRAPS 64)")

	var sample := Array(("func _one() -> void:\n\tvar dir := X\n\tif dir == null:\n\t\treturn\nfunc _two() -> void:\n\tpass\n").split("\n"))
	_check(_function_at(sample, 1) == "_one", "a line's enclosing function is read upwards to the header")
	_check(_function_at(sample, 5) == "_two", "and the nearest header above is the one, not the first in the file")
	_check(_function_body(sample, 1).contains("dir == null"),
		"a function's body is the indented run below its header")
	_check(not _function_body(sample, 1).contains("pass"),
		"and it stops at the next header, so a null check in the NEXT function does not count")

	_check(_occurrences("a == 1 and a == 1", "a == 1") == 2, "a condition is counted, not merely found")
	_check(_occurrences("scanned > 0", "loaded == 0") == 0, "and a condition that is absent counts zero")

	print("SCAN FLOOR %d assertions, failures=%d" % [asserted, bad])
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
