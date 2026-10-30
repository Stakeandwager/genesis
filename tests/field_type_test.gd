extends SceneTree

# --- 100: the four reads in tests/replay.gd, held in a full run ---
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
# WHAT IS HELD AND WHAT IS NOT, said plainly (TRAPS 6, TRAPS 14). Held: the
# reader converts, the table and the call sites agree in both directions, the
# value that comes out fits the typed member it is assigned to, and nothing a
# JSON file can hold reaches `RacingModule`'s read of `revision_of` as a
# non-Dictionary. NOT held: the rest of `replay.gd` - the REPLAY_LOG and
# REPLAY_OUT guards, the grouping, the output file - which no suite drives and
# which is still the person running the tool's to check. That half of 099a's
# entry stays open and says so in docs/HANDOVER.md.
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


func _run() -> void:
	_the_class_is_closed_by_the_code()
	_every_field_against_every_type()
	_the_attempt_dictionary()
	_the_value_fits_the_member()

	print("FIELD TYPE %d assertions, failures=%d" % [asserted, bad])
	quit(1 if bad > 0 else 0)
