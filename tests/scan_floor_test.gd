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
# --- 083: and the class was derived from ONE idiom of directory read ---
#
# 082 found this while giving scene_light_test a floor and left it as the live
# "Next action": _sites() derived its class from the open call alone, so the
# SEVEN get_files_at reads in tests/ - six in player_door_test, one in
# scene_light_test - were outside the class and had no row. That is TRAPS 11
# in the suite whose whole job is floors.
#
# 082 ALSO WROTE THAT THE CONSEQUENCE WAS NIL, AND IT WAS NOT. Its evidence
# was one run with five of player_door_test's six reads redirected at an empty
# directory at once: 69 assertions, failures=2, so "nothing is silent today".
# It said in as many words not to read that as proof that each read is held on
# its own, and it was right. 083 measured them ONE AT A TIME, each in a
# throwaway copy with its own config/name (TRAPS 50), the suite run alone:
#
#   player_door_test  :297 tests/      by_setting.size() >= 16   CAUGHT  69, 1
#   player_door_test  :349 (variable)  literals.is_empty()       SILENT  69, 0
#   player_door_test  :680 tests/      with_collision.is_empty() SILENT  69, 0
#   player_door_test  :688 scripts/    in_scripts.is_empty()     SILENT  69, 0
#   player_door_test  :696 tests/      own_floor.size() >= 2     CAUGHT  69, 1
#   player_door_test  :762 scripts/    readers.is_empty()        SILENT  69, 0
#   scene_light_test  :405 scripts/    scanned > 0 ...           CAUGHT  27, 1
#
# FOUR OF THE SEVEN WERE SILENT, and all four assert an ABSENCE - at their
# greenest when the read has looked at nothing, which is TRAPS 75's direction.
# One of them underwrites a sentence in its own file: "no production code
# identifies a world by name" is why the alternating world name is said to
# cost nothing today. The five-at-once run read as coverage because the THIRD
# read of tests/ fired and covered for the other two; that is TRAPS 78's shape
# - a measurement taken at the wrong granularity, read as a result. All four
# now carry a floor and all four fail by name; the two that already fired
# still fire.
#
# AND THE IDIOM LIST IS A WHITELIST, not a pair of needles (TRAPS 79). Every
# line of code in tests/ that names DirAccess is classified: open and
# get_files_at are READS and are asked for a row; remove_absolute and
# make_dir_recursive_absolute are WRITES and are not; anything else FAILS and
# names itself, so a third way of reading a directory arrives as a failure
# rather than as silence. Both lists are asserted to be classifying something,
# because a whitelist that matches nothing is TRAPS 75 one layer out.
#
# THE TWO IDIOMS ARE NOT ASKED THE SAME QUESTIONS, and that is deliberate
# rather than an omission. open() hands back a handle that can be null and
# section 3 asks whether it is tested; get_files_at() hands back an array and
# there is no handle to test, so section 3 does not ask. What covers a
# get_files_at site is the floor and nothing else, which is why four of them
# were silent and why the kind is carried in the row rather than inferred.
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


# Every directory read in tests/, as "file::function" (plus "#N" where one
# function holds more than one) -> the assertion that fails when that read
# comes back empty. Both idioms since 083.
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
	"player_door_test.gd::_the_scene#1": {
		"floor": "by_setting.size() >= 16",
		"why": "083: the two assertions this read feeds are absences; the count beside them is what fires. Measured on its own: 69 assertions, failures=1",
	},
	"player_door_test.gd::_the_scene#2": {
		"floor": "literals_min > 0",
		"why": "083 ADDED THIS FLOOR; the read was silent on its own at 69 assertions, failures=0. Its path is a LOOP VARIABLE over two directories, so the floor is on the SMALLER of the two counts - a total would stay positive with one directory empty",
	},
	"player_door_test.gd::_the_scene_has_no_floor#1": {
		"floor": "tests_scanned > 0",
		"why": "083 ADDED THIS FLOOR; silent on its own at 69 assertions, failures=0. The third read in this function fired and covered for it in 082's five-at-once run (TRAPS 78)",
	},
	"player_door_test.gd::_the_scene_has_no_floor#2": {
		"floor": "scripts_scanned > 0",
		"why": "083 ADDED THIS FLOOR; silent on its own at 69 assertions, failures=0, and it is the only read of scripts/ in this function, so no sibling could have covered it",
	},
	"player_door_test.gd::_the_scene_has_no_floor#3": {
		"floor": "own_floor.size() >= 2",
		"why": "083: the one read in this function that already fired on an empty read, 69 assertions, failures=1, and the reason the other two looked held",
	},
	"player_door_test.gd::_the_name_is_not_the_worlds": {
		"floor": "readers_scanned > 0",
		"why": "083 ADDED THIS FLOOR; silent on its own at 69 assertions, failures=0. The absence it holds underwrites a sentence in its own file - no production code identifies a world by name - which is why the alternating world name is said to cost nothing today (TRAPS 14)",
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
	"refusal_reach_test.gd::_sites_in_code": {
		"floor": "places_counted >= 16",
		"why": "081: the per-category PLACE counts come from this read, and every one of the sixteen equalities that compare a row's number against it would compare zero with zero on a scripts/ that opened and held nothing. The floor is on the caller's side, as its sibling's is",
	},
	"result_line_test.gd::_test_files": {
		"floor": "not files.is_empty()",
		"why": "077 built this one with its floor, which is why it was the one scan that could not pass on an empty read",
	},
	"scan_floor_test.gd::_test_files": {
		"floor": "not files.is_empty()",
		"why": "this file reads tests/ to find the sites, so it is a member of its own class and is asked the same two questions",
	},
	"scene_light_test.gd::_everything_that_points_has_been_pointed": {
		"floor": "scanned > 0 and lines_read > 0",
		"why": "082 wrote this floor while fixing the light whitelist, and 083 is what put the site in this class at all. Re-measured on its own: 27 assertions, failures=1",
	},
	"source_scan_test.gd::_class": {
		"floor": "members.size() >= KNOWN.size()",
		"why": "its section 1 already names TRAPS 6 as the reason it is there",
	},
	# 106: two reads arrived with the registry-keyed sweep, and this suite
	# named both of them on the run that added them - which is the class
	# working rather than a chore. Each is in its own function on purpose: two
	# reads in one function would share one key, and section 2's claim about
	# that is weaker than it reads (see HANDOVER 106).
	"source_scan_test.gd::_registry_keyed_class": {
		"floor": "keyed_sites > 0",
		"why": "106: every assertion about a guard comes out of this sweep, so an empty read leaves section 6 with nothing to judge and its clean result would mean it had looked at no code at all",
	},
	"source_scan_test.gd::_scripts_code": {
		"floor": "not declared.is_empty()",
		"why": "106: the accessor needles are checked against this text, and a scan whose needles have been renamed finds nothing - which looks exactly like finding nothing wrong (TRAPS 6)",
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


# 083: the second idiom. Assembled for the same reason as the first - this
# file's own header tabulates seven get_files_at sites, and a needle its own
# source answers is not a needle.
func _files_at_call() -> String:
	return "DirAcc" + "ess.get_files_at("


# The class prefix itself, so every DirAccess line in tests/ can be
# classified and an unrecognised member can fail by name (TRAPS 79).
func _dir_prefix() -> String:
	return "DirAcc" + "ess."


# The members of DirAccess that READ a directory, and the kind each site gets.
# A whitelist: see _writing_members() for the rest, and _scan() for what
# happens to a member in neither.
func _reading_members() -> Dictionary:
	return {"open": "open", "get_files_at": "files_at"}


# The members that do NOT read a directory. Named rather than skipped, so the
# two lists together have to account for every DirAccess call in tests/.
func _writing_members() -> Dictionary:
	return {"remove_absolute": true, "make_dir_recursive_absolute": true}


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


# The DirAccess member named on a line, or "" - the word after the prefix.
func _member_on(line: String) -> String:
	var at := line.find(_dir_prefix())
	if at < 0:
		return ""
	var rest := line.substr(at + _dir_prefix().length())
	var name := ""
	for i in rest.length():
		var c := rest.substr(i, 1)
		var wordy := (c >= "a" and c <= "z") or (c >= "A" and c <= "Z") or (c >= "0" and c <= "9") or c == "_"
		if not wordy:
			break
		name += c
	return name


# The path argument of a directory read, as ["literal", path] or
# ["expression", text]. An expression is a variable, a concatenation or a
# format - a path this file cannot resolve by reading.
#
# WHY AN EXPRESSION IS ADMITTED RATHER THAN DROPPED, and it is the whole
# reason this function exists. Until 083 the class was filtered by "the quoted
# string on this line begins res://", and player_door_test's second read takes
# a loop VARIABLE over two res:// directories. It would have been dropped in
# silence - and it is one of the four that 083 measured as silent. A site this
# file cannot classify is a site that needs a row, not a site to skip; its row
# says which directories it reads. The cost is named under "Limitations": a
# user:// read spelled as an expression would be admitted too, which errs
# towards asking for a row that is not needed rather than towards dropping one
# that is.
func _argument_on(line: String, call: String) -> Array:
	var at := line.find(call)
	if at < 0:
		return ["none", ""]
	var trimmed := line.substr(at + call.length()).strip_edges()
	if trimmed.begins_with("\""):
		var body := trimmed.substr(1)
		var close_at := body.find("\"")
		if close_at >= 0:
			return ["literal", body.substr(0, close_at)]
		return ["expression", trimmed]
	var cut := trimmed.find(")")
	return ["expression", trimmed.substr(0, cut) if cut >= 0 else trimmed]


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


# Every directory read in tests/, read off the CODE so a call written in a
# comment is not one (TRAPS 64), and classified rather than filtered.
#
# Returns {"sites": [...], "writes": [...], "unknown": [...], "elsewhere":
# [...]}. Every line of code in tests/ naming DirAccess lands in exactly one
# of the four, and section 1a asserts that "unknown" is empty, that the
# writing list is classifying something, that both reading idioms are present,
# and that the four together account for every DirAccess call in the code of
# tests/ - a classifier that classifies nothing is TRAPS 75 one layer out.
#
# THE KEY IS "file::function", WITH "#N" WHEN THE FUNCTION HOLDS MORE THAN ONE
# READ. Until 083 no function in tests/ held two, and section 2 asserted it.
# Two now do: player_door_test._the_scene holds two and
# ._the_scene_has_no_floor holds three, two of those three over the SAME
# directory, so neither the function nor the path tells them apart. N is the
# source order of the read inside its function. A line number would have been
# simpler and would go stale on every unrelated edit above it; an ordinal goes
# stale exactly when a read is added to, removed from or reordered inside that
# function, which is when the row has to be read again anyway. The FIFTEEN
# functions holding exactly one read keep their bare key - thirteen open sites
# and two get_files_at ones, counted off the rows rather than remembered - so
# adding a second read to one of them renames BOTH and fails section 1 in both
# directions, by name.
func _scan() -> Dictionary:
	var sites: Array = []
	var writes: Array = []
	var unknown: Array = []
	var elsewhere: Array = []
	var reading := _reading_members()
	var writing := _writing_members()
	for name in _test_files():
		var file_name := str(name)
		var lines := Array(_code_for(file_name).split("\n"))
		var found: Array = []
		for i in lines.size():
			var line := str(lines[i])
			if not line.contains(_dir_prefix()):
				continue
			var member := _member_on(line)
			var where := "%s:%d %s%s" % [file_name, i + 1, _dir_prefix(), member]
			if writing.has(member):
				writes.append(where)
				continue
			if not reading.has(member):
				unknown.append(where)
				continue
			var call := _open_call() if member == "open" else _files_at_call()
			var argument := _argument_on(line, call)
			var how := str(argument[0])
			var path := str(argument[1])
			# A literal that is not res:// is another filesystem - user://
			# worlds and ledgers - and not this repository's own files.
			if how == "literal" and not path.begins_with(_res_prefix()):
				elsewhere.append("%s (%s)" % [where, path])
				continue
			found.append({
				"file": file_name,
				"func": _function_at(lines, i),
				"kind": str(reading[member]),
				"how": how,
				"var": _declared_on(line),
				"path": path,
				"line": i + 1,
				"body": _function_body(lines, i),
			})
		# the ordinal, per function, once the whole file is read
		var per_function := {}
		for site in found:
			var f := str((site as Dictionary)["func"])
			per_function[f] = int(per_function.get(f, 0)) + 1
		var seen_so_far := {}
		for site in found:
			var row: Dictionary = site
			var f := str(row["func"])
			var n := int(seen_so_far.get(f, 0)) + 1
			seen_so_far[f] = n
			row["key"] = "%s::%s" % [file_name, f] if int(per_function[f]) == 1 else "%s::%s#%d" % [file_name, f, n]
			sites.append(row)
	return {"sites": sites, "writes": writes, "unknown": unknown, "elsewhere": elsewhere}


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
	print("--- 078/083: every directory read in tests/, and whether an empty read can pass ---")

	var scan := _scan()
	var sites: Array = scan["sites"]
	var keys: Array = []
	for site in sites:
		keys.append(str((site as Dictionary)["key"]))

	# --- 1. the class enumerates itself, in both directions ---
	#
	# A derived class and not a list: a scan added tomorrow is a site by
	# arriving. Every site must have a row, and every row must name a site
	# that still exists - a row that has gone stale is a row to strike, and it
	# should never go unremarked (TRAPS 14).
	_check(not sites.is_empty(), "tests/ was read and holds %d directory reads" % sites.size())

	# --- 1a. every DirAccess line in tests/ is CLASSIFIED, not filtered ---
	#
	# 083. A read that this file does not recognise must fail and name itself,
	# or the class is a blacklist of the two idioms somebody thought of
	# (TRAPS 79). The two counts below fail for different reasons: "unknown"
	# fires on a third idiom arriving, and the floor under the reading list
	# fires when the whole classification has read nothing at all.
	var unknown: Array = scan["unknown"]
	var writes: Array = scan["writes"]
	var elsewhere: Array = scan["elsewhere"]
	_check(unknown.is_empty(),
		"every DirAccess call in tests/ is a member this file classifies as a read or not a read (%s)" % str(unknown))
	_check(not writes.is_empty(),
		"and the not-a-read list is classifying something: %d call(s) that change a directory rather than read one" % writes.size())
	var open_kind := 0
	var files_at_kind := 0
	for site in sites:
		match str((site as Dictionary)["kind"]):
			"open": open_kind += 1
			"files_at": files_at_kind += 1
	_check(open_kind > 0 and files_at_kind > 0,
		"and BOTH reading idioms are in the class, so neither is held by a list of one: %d open, %d get_files_at" % [open_kind, files_at_kind])
	_check(open_kind + files_at_kind == sites.size(),
		"and every site carries one of the two kinds, so none was counted without one (%d of %d)" % [open_kind + files_at_kind, sites.size()])
	# CONSERVATION, which is what "classified rather than filtered" means:
	# every DirAccess line in the code of tests/ is in exactly one of the four
	# buckets. Counted off the files here rather than inside _scan(), so the
	# total is arrived at twice by different code.
	#
	# "elsewhere" HOLDS A READ OF ANOTHER FILESYSTEM - a user:// ledger or
	# saved world - AND IS EMPTY TODAY. That is stated and not asserted: the
	# first draft of this section asserted it was non-empty, which is a claim
	# about tests/ that is false, and the suite's own run caught it. What IS
	# asserted is that the reader tells such a path apart, proven on a built
	# source in section 6, and that nothing falls outside the four.
	# COUNTED IN CALLS AND NOT IN LINES, and the difference is the one hole
	# left in the classifier. _member_on() reads the FIRST DirAccess call on a
	# line, so a line carrying two would have its second classified by nobody.
	# There is no such line in tests/ today - counted, not assumed - and
	# counting CALLS is what makes the day there is one a failure rather than
	# a silence: the buckets hold one entry for that line and this total holds
	# two, so the sum stops balancing and says so. Handling it would be the
	# cheaper-looking fix and the wrong one; a case that does not exist should
	# arrive as a failure, not as a branch nobody has ever run.
	var dir_calls := 0
	for name in _test_files():
		dir_calls += _occurrences(_code_for(str(name)), _dir_prefix())
	_check(dir_calls == sites.size() + writes.size() + unknown.size() + elsewhere.size(),
		"and the four buckets account for every DirAccess call in tests/: %d = %d read + %d write + %d unknown + %d elsewhere" % [
			dir_calls, sites.size(), writes.size(), unknown.size(), elsewhere.size()])
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
	#
	# ASKED OF ONE OF THE TWO KINDS, AND THAT IS THE POINT RATHER THAN AN
	# EXEMPTION (083). open() hands back a handle that can be null;
	# get_files_at() hands back an array and there is no handle to test, so
	# there is nothing here it could be asked. A get_files_at site is held by
	# its floor and by nothing else, which is why four of the seven were
	# silent. The count of sites actually asked is asserted below, so this
	# section cannot go quiet by classifying everything as the kind it does
	# not ask.
	var asked_for_null := 0
	for site in sites:
		var s: Dictionary = site
		if str(s["kind"]) != "open":
			continue
		asked_for_null += 1
		var name: String = str(s["var"])
		var body: String = str(s["body"])
		var checked := name != "" and (body.contains(name + " == null") or body.contains(name + " != null"))
		_check(checked,
			"%s:%d tests %s for null in %s, rather than throwing on it" % [
				str(s["file"]), int(s["line"]), name if name != "" else "<unnamed>", str(s["func"])])
	_check(asked_for_null == open_kind and asked_for_null > 0,
		"and the null question was put to every site that has a handle to test: %d of %d" % [asked_for_null, open_kind])

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

	# 083's reader, answered from built sources for the same reason: the
	# second idiom, the member name, and the argument that is not a literal.
	var a_files_at := "\tfor name in " + _files_at_call() + "\"" + _res_prefix() + "scripts\"):"
	var a_variable := "\tfor name in " + _files_at_call() + "dir):"
	var a_removal := "\t" + _dir_prefix() + "remove_absolute(path)"
	_check(_member_on(a_files_at) == "get_files_at", "the DirAccess member is read off the line")
	_check(_member_on(a_removal) == "remove_absolute",
		"and a call that changes a directory names its own member, so it is classified rather than skipped")
	_check(_member_on("\tvar n := 1") == "", "and a line that names no DirAccess member yields none")
	_check(_reading_members().has(_member_on(a_files_at)) and not _reading_members().has(_member_on(a_removal)),
		"so the reading list admits the one and refuses the other, by member and not by needle (TRAPS 79)")
	_check(str(_argument_on(a_files_at, _files_at_call())[0]) == "literal"
			and str(_argument_on(a_files_at, _files_at_call())[1]) == _res_prefix() + "scripts",
		"a quoted path is read as a literal")
	_check(str(_argument_on(a_variable, _files_at_call())[0]) == "expression",
		"and a path that is a VARIABLE is read as an expression rather than as an empty string - the filter that dropped player_door_test's second read until 083")
	_check(str(_argument_on(a_call, _open_call())[1]) == _res_prefix() + "scripts",
		"and the same reader answers for the first idiom, so the two are not read by two rules")
	_check(str(_argument_on(a_user_path, _open_call())[0]) == "literal"
			and not str(_argument_on(a_user_path, _open_call())[1]).begins_with(_res_prefix()),
		"and a user:// read is a literal that is not this repository's, so it is filed as elsewhere rather than asked for a floor")

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
