extends SceneTree

# --- 100, widened by 101: the parts of tests/replay.gd a full run holds ---
#
# WHY THIS FILE EXISTS. 099a fixed three reads of a record that came off a
# FILE in `tests/replay.gd` and measured them eighteen ways by hand, and then
# wrote down, as the first live entry in docs/HANDOVER.md, that the fix was
# HELD BY NOTHING: `replay.gd` is on `run_tests.sh`'s NOT_A_SUITE list and
# matched by `run_tests.bat`'s findstr, so neither runner drives it, and a
# later session could revert all three reads with every suite staying green.
# A measurement is not a standing check. This is the standing check.
#
# AND IT IS NOT A SUBPROCESS, WHICH IS THE OPTION THE ENTRY OFFERED AND THE
# REASON IT IS NOT TAKEN, MEASURED RATHER THAN ARGUED. Running `replay.gd`
# from a suite would need `OS.execute` - an idiom `tests/` has NOWHERE
# (grepped: zero hits) - and `replay.gd` DELETES `user://track_log.jsonl` on
# its first lines, which is the ledger the other suites in this run append to
# and four of them read. That is TRAPS 50 and TRAPS 97 by construction. So
# what is driven here is the two functions that do the reading, called
# directly, which is why both are `static` in that file.
#
# 101 ADDED THREE MORE STATIC FUNCTIONS TO THAT FILE FOR THE SAME REASON, and
# the subprocess option is STILL out for the same one: replay.gd deletes the
# shared ledger on the path that WORKS. What 101 changed is that a REFUSED run
# no longer does - it used to delete the ledger four statements in and refuse
# twenty lines later, measured three ways. See TRAPS 101 and section 7.
#
# WHAT IS HELD AND WHAT IS NOT, said plainly (TRAPS 6, TRAPS 14), AND THIS
# PARAGRAPH IS REWRITTEN BY 101 BECAUSE IT WOULD OTHERWISE BE FALSE - the
# version 100 wrote said the guards and the grouping were held by nothing,
# which was true when it was written and is the exact shape of TRAPS 14.
#
# HELD, sections 1-4: the reader converts, the table and the call sites agree
# in both directions, the value that comes out fits the typed member it is
# assigned to, and nothing a JSON file can hold reaches `RacingModule`'s read
# of `revision_of` as a non-Dictionary.
# HELD, sections 5-7 (101): the gate lets exactly one of eight combinations
# proceed and every refusal names a variable to set; every line of a record
# file lands in exactly one of three buckets and the month is read off
# REPLAY.MONTH rather than typed here; flattening the groups gives the records
# back in order, once each; and every destructive idiom in replay.gd sits
# BELOW the gate's return, which is the only thing a suite can hold about an
# irreversible act and is a guard rather than a measurement (TRAPS 6).
# NOT HELD: replay.gd's replay loop and its output write. Neither is a
# function of its inputs - the loop drives a live GameController through a
# SceneTree and reads the ledger back between groups, and the write is the
# side effect itself - and what a suite could still say about them has not
# been worked out, and that is still the live entry in docs/HANDOVER.md.
# HELD, section 8 (102): `prompt_test`, the other member of NOT_A_SUITE. THIS
# SENTENCE IS REWRITTEN BY 102 BECAUSE THE VERSION 101 WROTE - "prompt_test,
# the other member of NOT_A_SUITE, is checked by nothing at all" - IS MADE
# FALSE BY THIS COMMIT, and leaving it would be TRAPS 14 in its smallest form
# with nothing in tests/ able to fail on it. What section 8 holds is which part
# of the AI's prompt that tool prints, counted off both sources; what it does
# NOT hold is the tool's output, which is still printed for a human.
#
# HOW A BREAK LOOKS HERE, MEASURED IN 100 RATHER THAN ASSUMED, because the
# first draft of this comment got it wrong and that is TRAPS 14's shape.
# Five faults were injected into tests/replay.gd one at a time, each in its
# own throwaway copy with its own config/name, and every one was caught:
#
#   the bare index put back at the call site     160 assertions, failures=3
#                                                + 1 SCRIPT ERROR
#   a damaged revision_of passed on as {}        197 assertions, failures=8
#   the damage count removed from _field()       157 assertions, failures=40
#   _field() returns the value without checking   73 assertions, failures=31
#                                                + 6 SCRIPT ERRORs
#   FIELD_TYPES["source"] widened to TYPE_STRING 189 assertions, failures=2
#
# AND `Object.set()` DOES NOT THROW ON A TYPED MEMBER, which is the thing the
# last row measures and the reason section 4 asserts a typeof and not just an
# absence of errors. Handed a String for a Dictionary member it SILENTLY
# KEEPS THE OLD VALUE - no error of any kind - so a check that only made the
# assignment and looked for a crash would have passed. The real assignment is
# still made, because that is what asks the engine; what is read afterwards is
# the type the member actually holds.
#
# Section 3's RacingModule call is the other way round: it DOES raise.
# Measured, with the bare index injected back into replay.gd: "Invalid cast:
# could not convert value to 'Dictionary'" at the line below, which abandons
# THAT FUNCTION and not the process (TRAPS 96) - _run() carried on into
# section 4, so the output was "FIELD TYPE 160 assertions, failures=3" AND a
# SCRIPT ERROR. run_tests.sh tests for SCRIPT ERROR before it reads the
# result line, so that is what it reports. The same cast raised from
# _initialize directly, without the deferred _run, never reaches quit() at
# all: a one-file probe came back rc=124 with the same error and no
# end-of-run line (TRAPS 13).

const SOURCE := "res://tests/replay.gd"
const CONTROLLER_SOURCE := "res://scripts/game_controller.gd"
const REPLAY := preload("res://tests/replay.gd")

# Every value a hand-edited JSON file can hold, plus an int, because a number
# read back through JSON is a float where one written in-process is an int.
# Not a list of "bad" values: which of these is bad for which field is
# DERIVED from REPLAY.FIELD_TYPES below, both ways.
const SAMPLES := [null, false, true, 2, 2.0, "x", [], {}, ["a"], {"k": 1}]

var asserted := 0
var bad := 0


func _check(ok: bool, what: String) -> void:
	asserted += 1
	if not ok:
		bad += 1
		print("  FAIL  ", what)


func _initialize() -> void:
	_run.call_deferred()


# The file's code with comments blanked, so a question about what the code
# DOES is answered from the code and never from prose (TRAPS 63).
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


func _source_of(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	_check(file != null, "%s could be opened and read" % path)
	if file == null:
		return ""
	var text := file.get_as_text()
	file.close()
	return _code_of(text)


# --- section 1: the class is the code's, not this file's ---
#
# Every `_field(<var>, "<name>"` call site in replay.gd, as name -> the set of
# record variables it was read off. The variable names are DERIVED from the
# matches rather than typed here, so the bare-read check below follows a
# rename instead of being silently bypassed by one.
func _read_sites(code: String) -> Dictionary:
	var out := {}
	var call := RegEx.new()
	call.compile("_field\\(\\s*([a-z_]+)\\s*,\\s*\"([a-z_]+)\"")
	for hit in call.search_all(code):
		var field := hit.get_string(2)
		if not out.has(field):
			out[field] = {}
		(out[field] as Dictionary)[hit.get_string(1)] = true
	return out


func _the_class_is_closed_by_the_code() -> void:
	var code := _source_of(SOURCE)
	if code == "":
		return

	var sites := _read_sites(code)
	var tabled: Array = REPLAY.FIELD_TYPES.keys()
	tabled.sort()
	var found: Array = sites.keys()
	found.sort()
	_check(found == tabled,
		"every field read through _field() has a row in FIELD_TYPES and every row is read - table %s, read %s" % [
			str(tabled), str(found)])

	# And no field in the table is reached any other way, which is the half a
	# set comparison cannot see: a read left beside the new one. THIS IS THE
	# CHECK 099a's OWN GREP DID NOT HAVE. `revision_of` was read as
	# `first["revision_of"]` - a BARE INDEX behind a has() guard, not a
	# `.get()` - so a sweep for the shape being fixed walked past it, and the
	# field went into current_attempt untyped and threw one process later in
	# scripts/. Both shapes are asked for here, off every record variable the
	# call sites actually use.
	for field in tabled:
		for holder in (sites.get(field, {}) as Dictionary).keys():
			var name := str(holder)
			_check(not code.contains("%s.get(\"%s\"" % [name, field]),
				"\"%s\" is not also read through a bare %s.get()" % [field, name])
			_check(not code.contains("%s[\"%s\"]" % [name, field]),
				"\"%s\" is not also read through a bare %s[] index, which is how the fourth one hid" % [
					field, name])


# --- section 2: every field against every type, derived both ways ---
func _every_field_against_every_type() -> void:
	for field in REPLAY.FIELD_TYPES.keys():
		var admitted: Array = REPLAY.FIELD_TYPES[field]
		var fallback := "FALLBACK-%s" % field

		# ABSENT is not damage: the record simply does not carry the field.
		var damaged: Array = []
		_check(REPLAY._field({}, str(field), fallback, damaged) == fallback,
			"\"%s\" absent reads as the default the call site named" % field)
		_check(damaged.is_empty(),
			"and an absent \"%s\" is not reported as damage, because it is not" % field)

		for sample in SAMPLES:
			damaged = []
			var got: Variant = REPLAY._field({str(field): sample}, str(field), fallback, damaged)
			var ok_type: bool = admitted.has(typeof(sample))
			if ok_type:
				_check(got == sample,
					"\"%s\" holding a %s is an admitted type and is read as itself" % [
						field, type_string(typeof(sample))])
				_check(damaged.is_empty(),
					"and an admitted \"%s\" is not reported as damage" % field)
			else:
				_check(got == fallback,
					"\"%s\" holding a %s is not admitted and reads as the default instead of throwing" % [
						field, type_string(typeof(sample))])
				_check(damaged.size() == 1,
					"and a damaged \"%s\" is COUNTED rather than swallowed (099's rule)" % field)
				if damaged.size() == 1:
					var d: Dictionary = damaged[0]
					_check(str(d.get("field", "")) == str(field) and str(d.get("type", "")) == type_string(typeof(sample)),
						"and the report names the field and the type it found: %s" % str(d))


# --- section 3: the dictionary that reaches current_attempt ---
func _the_attempt_dictionary() -> void:
	var damaged: Array = []
	_check(REPLAY._attempt_of({}, damaged) == {},
		"a record with no \"attempt\" is not an attempt at all, and reads as {}")
	_check(REPLAY._attempt_of({"revision_of": {"a": 1}}, damaged) == {},
		"and neither is one that carries only a revision_of, which is what this file did before 100")

	for sample in SAMPLES:
		damaged = []
		var got := REPLAY._attempt_of({"attempt": sample}, damaged)
		_check(typeof(got.get("attempt")) == TYPE_INT,
			"attempt holding a %s still yields an int, so game_controller.gd:644's int() cannot be handed rubbish" % type_string(typeof(sample)))

		damaged = []
		var with_rev := REPLAY._attempt_of({"attempt": 1, "revision_of": sample}, damaged)
		if typeof(sample) == TYPE_DICTIONARY:
			_check(with_rev.get("revision_of") == sample,
				"a revision_of that IS a dictionary is carried through unchanged")
		else:
			_check(not with_rev.has("revision_of"),
				"a revision_of holding a %s is left OUT rather than passed on as {}, so no comparison is invented" % type_string(typeof(sample)))
			_check(damaged.size() == 1,
				"and it is counted as damage, so the absence is explained rather than silent")

		# THE REAL CALL THAT THREW, made here rather than described. This is
		# `record["revision_of"].get("proposed_metrics", {})` -
		# racing_module.gd:151 - reached because game_controller.gd:656-657
		# copies current_attempt's revision_of onto the record. Measured on
		# e1c9b6d: null, a string, an array, a number and a bool each took
		# replay.gd to rc=124 with nothing written, first error
		# "Nonexistent function 'get'" at that line. If _attempt_of ever lets
		# one through again, this line throws and the run reports a timeout.
		if with_rev.has("revision_of"):
			var compared: Variant = (with_rev["revision_of"] as Dictionary).get("proposed_metrics", {})
			_check(true,
				"and RacingModule's own read of it answers rather than throwing (got %s)" % str(compared))


# --- section 4: the value fits the member it is assigned to ---
#
# The mapping from field to member is READ OFF THE CALL SITES, not typed
# here, and the member's declared type is read off game_controller.gd. So
# this asserts that two files agree, which is the thing that drifts.
func _the_value_fits_the_member() -> void:
	var code := _source_of(SOURCE)
	var controller_code := _source_of(CONTROLLER_SOURCE)
	if code == "" or controller_code == "":
		return

	var assign := RegEx.new()
	assign.compile("controller\\.(current_[a-z_]+)\\s*=\\s*_field\\(\\s*[a-z_]+\\s*,\\s*\"([a-z_]+)\"")
	var pairs := assign.search_all(code)
	_check(pairs.size() > 0, "at least one field is assigned straight onto a typed controller member")

	var controller := GameController.new()
	for hit in pairs:
		var member := hit.get_string(1)
		var field := hit.get_string(2)

		var declared := ""
		var decl := RegEx.new()
		decl.compile("var %s\\s*:\\s*([A-Za-z0-9_]+)" % member)
		var found := decl.search(controller_code)
		if found != null:
			declared = found.get_string(1)
		_check(declared != "",
			"%s is a DECLARED type in game_controller.gd, so there is something to fit (%s)" % [member, declared])

		for t in (REPLAY.FIELD_TYPES[field] as Array):
			_check(type_string(int(t)) == declared,
				"every type FIELD_TYPES admits for \"%s\" is the type %s is declared as: %s vs %s" % [
					field, member, type_string(int(t)), declared])

		# And the assignment itself, made for real against every sample,
		# then read back. MEASURED: set() on a typed member handed the wrong
		# type does NOT throw and does NOT warn - it silently keeps the old
		# value - so the assertion has to be about what the member HOLDS
		# afterwards. Making the assignment and seeing no error would pass
		# while the member kept a stale value.
		for sample in SAMPLES:
			var damaged: Array = []
			var got: Variant = REPLAY._field({field: sample}, field, {}, damaged)
			controller.set(member, got)
			_check(typeof(controller.get(member)) == typeof(got),
				"%s accepted what _field() returned for a \"%s\" holding a %s" % [
					member, field, type_string(typeof(sample))])
	controller.free()


# --- section 5: the gate, every combination of what it is given (101) ---
#
# 100 wrote down that the REPLAY_LOG and REPLAY_OUT guards were held by
# nothing, and 101 made the decision they take a pure function so that it can
# be asked here. THE PROPERTY IS NOT THE THREE SENTENCES, it is that exactly
# one of the eight combinations is allowed to proceed and that every refusal
# names the variable the person running the tool has to set. The sentences are
# checked for naming a variable, not for their wording (TRAPS 6, TRAPS 14).
func _the_gate_lets_exactly_one_combination_through() -> void:
	for log_in in ["", "/some/record/file.jsonl"]:
		for out_path in ["", "/some/output.json"]:
			for readable in [false, true]:
				var said := REPLAY._refusal(str(log_in), str(out_path), bool(readable))
				var should_go: bool = str(log_in) != "" and bool(readable) and str(out_path) != ""
				_check((said == "") == should_go,
					"REPLAY_LOG=%s readable=%s REPLAY_OUT=%s %s" % [
						"set" if str(log_in) != "" else "unset", str(readable),
						"set" if str(out_path) != "" else "unset",
						"is allowed to proceed" if should_go else "is refused"])
				if said == "":
					continue
				_check(said.contains("REPLAY_LOG") or said.contains("REPLAY_OUT"),
					"and the refusal names a variable to set rather than just failing: %s" % said)
				if str(log_in) != "" and not bool(readable):
					_check(said.contains(str(log_in)),
						"and a file it could not open is QUOTED, so the typo is visible: %s" % said)

	# And the order of the two is a fact and not an accident: a run with
	# NEITHER variable set is told about REPLAY_LOG, because that is the one
	# that decides whether there is anything to replay at all.
	_check(REPLAY._refusal("", "", false).contains("REPLAY_LOG"),
		"with nothing set at all, the first thing named is REPLAY_LOG")


# --- section 6: every line of a record file is accounted for (101) ---
#
# The month is READ OFF REPLAY.MONTH rather than typed here, so this follows
# the filter instead of pinning it. What is asserted is the IDENTITY -
# records + other_month + unreadable == lines - which is the thing that breaks
# when a line is silently dropped, and the SEPARATION of a line that could not
# be read from a line of another month, which is 099's rule: damage read as
# absence trades a loud empty answer for a quietly wrong one.
func _every_line_is_accounted_for() -> void:
	var month := str(REPLAY.MONTH)
	var other_month := "0001-01" if month != "0001-01" else "0002-02"

	var keep_a := {"time": month + "-02T10:00:00", "command": "CREATE_TRACK", "raw_command": "{}"}
	var keep_b := {"time": month + "-29T23:59:59", "command": "CLEAR_WORLD", "raw_command": "{}"}
	var wrong_month := {"time": other_month + "-02T10:00:00", "command": "CREATE_FARM"}
	var no_time := {"command": "CREATE_FARM"}

	var text := "\n".join([
		JSON.stringify(keep_a),
		"",
		"   ",
		"not json at all {",
		JSON.stringify(wrong_month),
		"[1, 2, 3]",
		"42",
		"\"a string\"",
		JSON.stringify(no_time),
		JSON.stringify(keep_b),
		"",
	])

	var read: Dictionary = REPLAY._records_of(text)
	var records: Array = read["records"]
	var counts: Dictionary = read["counts"]

	_check(records.size() == 2, "the two records of %s are kept (%d)" % [month, records.size()])
	_check(records.size() > 0 and records[0] == keep_a and records[-1] == keep_b,
		"and they come back in file order, unchanged")
	_check(int(counts["records"]) == records.size(),
		"the reported record count IS the number of records returned, not a second tally")
	_check(int(counts["lines"]) == 8,
		"blank and whitespace-only lines are not lines of a record file (%d)" % int(counts["lines"]))
	_check(int(counts["other_month"]) == 2,
		"a record of another month and a record with NO time are both 'other month' (%d)" % int(counts["other_month"]))
	_check(int(counts["unreadable"]) == 4,
		"broken JSON, an array, a number and a bare string are UNREADABLE, not absent (%d)" % int(counts["unreadable"]))

	# THE IDENTITY. This is the assertion that catches a line going missing,
	# whatever the reason, and it is asked of every text below as well.
	for sample_text in [text, "", "\n\n\n", JSON.stringify(keep_a), "{", JSON.stringify(wrong_month)]:
		var r: Dictionary = REPLAY._records_of(str(sample_text))
		var c: Dictionary = r["counts"]
		_check(int(c["records"]) + int(c["other_month"]) + int(c["unreadable"]) == int(c["lines"]),
			"every line is in exactly one of the three buckets (lines=%d)" % int(c["lines"]))
		_check(int(c["records"]) == (r["records"] as Array).size(),
			"and the kept count still matches the kept records")

	var empty: Dictionary = REPLAY._records_of("")
	_check((empty["records"] as Array).is_empty() and int((empty["counts"] as Dictionary)["lines"]) == 0,
		"an empty file is zero lines and zero records, rather than one empty record")

	# AND THE FILTER HAS ONE PLACE. The month literal appears on the const
	# line and nowhere else in the code, so a change to what this tool
	# replays cannot be made in one of two places. Derived from the constant,
	# so renaming the month moves the check with it.
	var code := _source_of(SOURCE)
	if code != "":
		var literal := "\"" + month + "\""
		_check(code.count(literal) == 1,
			"the month %s is written in the code exactly once (%d)" % [literal, code.count(literal)])


# --- section 7: the grouping loses nothing, and nothing is destroyed before
#                the gate (101) ---
#
# TWO PROPERTIES, and the first is deliberately not the grouping rule restated.
# A grouping that drops or duplicates a record is how this goes wrong, and
# FLATTENING THE GROUPS BACK gives an assertion that sees it without
# re-spelling the rule. The shapes below then say what the rule does.
#
# The second is the fault 101 found and is the only thing a suite can hold
# about an irreversible act: its POSITION. The ledger deletion was the fourth
# statement of _initialize and the guards were twenty lines below it, so every
# refused invocation destroyed the ledger first - measured three ways on
# 3f7ae94, each in a throwaway copy with its own config/name and a planted
# 52-line ledger, and three of three came back with the ledger GONE. This
# section is the guard against that coming back, and it is labelled as a
# guard rather than counted as the measurement (TRAPS 6).
func _a_record_is_in_exactly_one_group() -> void:
	var plain := func(c: String) -> Dictionary:
		return {"command": c, "raw_command": JSON.stringify({"command": c})}
	var step := func(c: String) -> Dictionary:
		return {"command": c, "raw_command": JSON.stringify({"command": "PLAN"})}
	var plan_end := func() -> Dictionary:
		return {"command": "PLAN", "raw_command": JSON.stringify({"command": "PLAN"})}

	var shapes := {
		"nothing at all": [],
		"one ordinary record": [plain.call("CREATE_TRACK")],
		"three ordinary records": [plain.call("CREATE_TRACK"), plain.call("CLEAR_WORLD"), plain.call("CREATE_FARM")],
		"a plan with two steps": [step.call("CREATE_FARM"), step.call("CREATE_TRACK"), plan_end.call()],
		"a plan between two ordinary records": [plain.call("CLEAR_WORLD"), step.call("CREATE_FARM"), plan_end.call(), plain.call("EQUIP")],
		"two plans running together": [step.call("CREATE_FARM"), plan_end.call(), step.call("CREATE_TRACK"), plan_end.call()],
		"a plan whose PLAN record never arrived": [plain.call("EQUIP"), step.call("CREATE_FARM"), step.call("CREATE_TRACK")],
	}
	var expected_groups := {
		"nothing at all": 0, "one ordinary record": 1, "three ordinary records": 3,
		"a plan with two steps": 1, "a plan between two ordinary records": 3,
		"two plans running together": 2, "a plan whose PLAN record never arrived": 2,
	}

	for what in shapes:
		var originals: Array = shapes[what]
		var groups: Array = REPLAY._group(originals)

		# NOTHING LOST, NOTHING DUPLICATED, ORDER KEPT.
		var flat: Array = []
		for g in groups:
			for r in (g as Array):
				flat.append(r)
		_check(flat == originals,
			"%s: flattening the groups gives the records back, in order, once each" % what)
		for g in groups:
			_check(not (g as Array).is_empty(), "%s: no group is empty" % what)
		_check(groups.size() == int(expected_groups[what]),
			"%s: %d groups (expected %d)" % [what, groups.size(), int(expected_groups[what])])

	# A plan's steps and its PLAN record are ONE execution, which is what the
	# grouping is for, asked of the group's contents rather than its count.
	var plan_shape: Array = shapes["a plan between two ordinary records"]
	var plan_groups: Array = REPLAY._group(plan_shape)
	if plan_groups.size() == 3:
		_check((plan_groups[1] as Array).size() == 2,
			"the step and its PLAN record are collected into one group")
		_check(str(((plan_groups[1] as Array)[-1] as Dictionary).get("command", "")) == "PLAN",
			"and the PLAN record is the one that closes it")

	# The raw command is matched without regard to case, because to_upper() is
	# what the code does and a ledger is a file somebody can edit.
	var lower: Array = [
		{"command": "CREATE_FARM", "raw_command": JSON.stringify({"command": "plan"})},
		{"command": "PLAN", "raw_command": JSON.stringify({"command": "plan"})},
	]
	_check(REPLAY._group(lower).size() == 1,
		"a raw command of \"plan\" in lower case still opens a plan group")


func _destructive_idioms() -> Array:
	return ["remove_absolu" + "te(", "FileAcc" + "ess.WRITE", "store_str" + "ing("]


func _nothing_is_destroyed_before_the_gate() -> void:
	var code := _source_of(SOURCE)
	if code == "":
		return
	var lines := code.split("\n")

	var gate_at := -1
	var leave_at := -1
	var destructive: Array = []
	for i in lines.size():
		var line := str(lines[i])
		# The CALL, not the definition: the definition has no `var refusal`.
		if gate_at < 0 and line.contains("_refusal(") and line.contains("var refusal"):
			gate_at = i
		if gate_at >= 0 and leave_at < 0 and line.strip_edges() == "return":
			leave_at = i
		for idiom in _destructive_idioms():
			if line.contains(str(idiom)):
				destructive.append([i, str(idiom)])

	_check(gate_at >= 0, "the gate is a call to _refusal() in the body, so there is a line to be after")
	_check(leave_at > gate_at,
		"and the gate can LEAVE: a bare return at line %d follows it at %d" % [leave_at + 1, gate_at + 1])
	# A whitelist that matches nothing is TRAPS 75 one layer out, so the list
	# is asserted to be classifying something before its members are judged.
	_check(destructive.size() >= 2,
		"the destructive idioms list found %d sites to place, not zero" % destructive.size())
	for site in destructive:
		var at: int = (site as Array)[0]
		var idiom: String = str((site as Array)[1])
		_check(at > leave_at,
			"%s at line %d is BELOW the gate's return at %d, so a refused run destroys nothing" % [
				idiom, at + 1, leave_at + 1])

	# And the three functions the sections above drive are the ones the tool
	# actually uses, so none of them is a parallel copy that can drift.
	for called in ["_refusal(", "_records_of(", "_group("]:
		_check(code.count(str(called)) >= 2,
			"%s is defined AND called in the body, so this suite drives live code" % str(called))


# --- section 8: what prompt_test prints, which is the OTHER member of
#     NOT_A_SUITE (102) ---
#
# WHERE THIS CAME FROM. 101 left as its first live entry that `prompt_test` -
# the other file on run_tests.sh's NOT_A_SUITE list - is checked by nothing at
# all, and said that before writing "it cannot be checked" anywhere, grep for
# what that denies (TRAPS 14). The grep found THREE DESCRIPTIONS OF IT AND
# TWO OF THEM WERE FALSE:
#
#   run_tests.sh:31            "prompt_test prints the AI's prompt for a
#                              human to read"
#   result_line_test.gd:88     the same sentence, as a ROW of NO_RESULT_LINE
#   docs/harness/README.md:43  "The AI's prompt is built from the registry
#                              and names every world"
#
# MEASURED by running it: it prints `ToolRegistry.prompt_sections()` - the
# TOOLS section, ONE OF THE THREE REGISTRY SECTIONS
# AIInterpreter.assembled_prompt() concatenates onto SYSTEM_PROMPT - and four
# EQUIP readbacks. It prints no world, no order and
# not SYSTEM_PROMPT, so the third sentence was false twice over: it names
# every TOOL and no world at all. Unchanged since the file was written at 006,
# and the row in result_line_test carries its own instruction that a row which
# has stopped being true "should never go unremarked (TRAPS 14)".
#
# AND ITS FOURTH PROBE PRINTED A BLANK LINE, which is the finding the entry's
# own question produced: "a file that only prints could still build what it
# prints wrongly". The probe is `{"tool":"hovercraft","spec":{}}` - a tool
# Genesis has not got, deliberately - and under a heading that says "EQUIP
# readbacks as the player would see them" it printed two spaces and nothing
# else. That was WorldRegistry.readback returning the empty string, and the
# player saw the same silence. Fixed in world_registry.gd and held by
# says_nothing_test section 7; this section holds what prompt_test IS.
#
# WHAT IS ASSERTED, AND IT IS A COUNT DERIVED BOTH WAYS RATHER THAN A SENTENCE
# (TRAPS 6, TRAPS 82). The registry sections of the prompt are read off
# assembled_prompt()'s own body - THREE of them, and SYSTEM_PROMPT is a
# constant rather than a call and is counted by neither side - and which of
# them prompt_test prints is read off prompt_test's body: it prints AT LEAST
# ONE and NOT ALL of them. A
# description saying "the AI's prompt" is then provably wrong, and a later
# session that widens prompt_test to print the whole prompt fails here and is
# told the three descriptions need rewriting. The runtime half is the
# relationship no source scan can see: what prompt_test prints is a non-empty
# substring of what the model is actually sent.
const PROMPT_TOOL := "res://tests/prompt_test.gd"
const INTERPRETER_SOURCE := "res://scripts/ai_interpreter.gd"


# Every registry call assembled_prompt() concatenates, read off its own body
# so a fifth part joins this class from the moment it is added.
func _prompt_parts(code: String) -> Array:
	var body := code.split("static func assembled_prompt() -> String:")
	if body.size() < 2:
		_check(false, "assembled_prompt() is defined in ai_interpreter.gd")
		return []
	var after := str(body[1])
	var ends := after.find("\nfunc ")
	if ends > 0:
		after = after.substr(0, ends)
	var call := RegEx.new()
	call.compile("([A-Za-z_]+)\\.(prompt_sections|prompt_section)\\(\\)")
	var out: Array = []
	for hit in call.search_all(after):
		var named := "%s.%s()" % [hit.get_string(1), hit.get_string(2)]
		if not named in out:
			out.append(named)
	return out


# Built from pieces so this file's own source cannot satisfy the scan, which
# is result_line_test's trick for the same reason.
func _verdict_words() -> Array:
	return ["fail" + "ures=", "ba" + "d="]


func _what_prompt_test_prints() -> void:
	var interpreter := _source_of(INTERPRETER_SOURCE)
	var tool_code := _source_of(PROMPT_TOOL)
	if interpreter == "" or tool_code == "":
		return

	var parts := _prompt_parts(interpreter)
	_check(parts.size() >= 3,
		"assembled_prompt() concatenates registry sections for this to count (found %s)" % str(parts))
	# SYSTEM_PROMPT is a constant and not a call, so it is in neither count, and
	# the check below is about the registry sections only. The runtime half two
	# dozen lines down is what holds that the whole prompt is bigger than them.

	var printed: Array = []
	for part in parts:
		if tool_code.contains(str(part)):
			printed.append(str(part))
	_check(printed.size() >= 1,
		"prompt_test prints at least one registry section of the AI's prompt (prints %s)" % str(printed))
	# The half that makes "the AI's prompt" false: it prints a PART.
	_check(printed.size() < parts.size(),
		"prompt_test prints SOME and not ALL of the prompt's %d registry sections (prints %d: %s) - if this fails, run_tests.sh, result_line_test's NO_RESULT_LINE row and docs/harness/README.md all need rewriting" % [
			parts.size(), printed.size(), str(printed)])
	# And it does not assemble the whole prompt by the one call that would.
	_check(not tool_code.contains("assembled_prompt("),
		"prompt_test does not call assembled_prompt(), so it cannot be printing the whole prompt")

	# The runtime half: what it prints really is part of what the model is
	# sent. No wording is written down - both sides are taken from the same
	# code in the same run.
	var whole := AIInterpreter.assembled_prompt()
	var shown := ToolRegistry.prompt_sections()
	_check("ToolRegistry.prompt_sections()" in printed,
		"the section prompt_test prints is ToolRegistry's, which is what the runtime half below reads")
	_check(shown.strip_edges() != "", "the section prompt_test prints says something (%d characters)" % shown.length())
	_check(whole.contains(shown),
		"what prompt_test prints is part of the prompt the model is actually sent")
	_check(whole.length() > shown.length(),
		"the prompt the model is sent is LONGER than what prompt_test prints (%d against %d characters)" % [
			whole.length(), shown.length()])

	# And "has no verdict to give", which is the other half of the row in
	# result_line_test and the reason both runners skip this file.
	for word in _verdict_words():
		_check(not tool_code.contains(str(word)),
			"prompt_test prints no verdict word, so neither runner can read a result off it")


func _run() -> void:
	_the_class_is_closed_by_the_code()
	_every_field_against_every_type()
	_the_attempt_dictionary()
	_the_value_fits_the_member()
	_the_gate_lets_exactly_one_combination_through()
	_every_line_is_accounted_for()
	_a_record_is_in_exactly_one_group()
	_nothing_is_destroyed_before_the_gate()
	_what_prompt_test_prints()

	print("FIELD TYPE %d assertions, failures=%d" % [asserted, bad])
	quit(1 if bad > 0 else 0)
