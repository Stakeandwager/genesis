extends SceneTree

# --- 078: the load check that passed having loaded nothing ---
#
# WHERE THIS CAME FROM. 077 found that load_check_test's _measure() had a way
# out that recorded nothing, so the suite printed "LOAD CHECK failures=0" and
# called quit(1); run_tests.sh reads the LINE and not the exit code, so a load
# check that had measured nothing whatsoever would have been counted as a
# pass. It fixed that path in load_check_test.gd and did not ask how many
# OTHER suites could print a pass having measured nothing. This file is the
# answer one filename away, and it was the worst of them: UNTIL THIS COMMIT it
# was named in no document in this repository - not TRAPS.md, not HANDOVER.md,
# not either runner - and nothing had ever read it. TRAPS 75 and the 078
# section name it now, which is the point of writing them; the claim is in the
# past tense because this commit is what made it false (TRAPS 14). Neither
# runner names it still: both find it by globbing tests/.
#
# MEASURED, NOT ARGUED, before anything here was changed: a throwaway project
# with its own config/name (TRAPS 50) and an EMPTY scripts/ directory ran this
# file unchanged and it printed
#
#   LOADCHECK 0 assertions, bad=0        exit code 0
#
# and run_tests.sh matches "*bad=0" as a pass. Both channels said the scripts
# all load when not one had been looked at. Missing evidence becoming success
# is the one thing PROTOCOL.md names by name.
#
# AND THE OPEN WAS NEVER CHECKED. This was the only one of the nine files in
# tests/ that calls DirAccess.open which did not test the result for null -
# the other eight all do. dir.get_files() on a null dir throws, which
# run_tests.sh does catch as a SCRIPT ERROR, so that path was loud rather than
# silent; it was still not an assertion, and a thrown error in _initialize
# never reaches quit(), which is what put report_test on the broken list for
# ten releases (TRAPS 13). It is a recorded failure now.
#
# THE GENERAL RULE, which is the part worth keeping and is applied in 078 to
# every member of the class rather than to this file alone (TRAPS 11):
#
#   a scan that reads a directory must assert that the read produced
#   something, or its cleanest result is the one it gives when it has looked
#   at nothing.
#
# tests/scan_floor_test.gd holds that rule for every DirAccess.open site in
# tests/. The two other members that did not hold it - controller_reach_test
# (two sites) and prompt_numeral_test (one) - are fixed in the same commit,
# and the measurement that found all three is in docs/HANDOVER.md.


func _initialize() -> void:
	var bad := 0
	var asserted := 0
	var loaded := 0
	var dir := DirAccess.open("res://scripts")

	# The open, as an assertion rather than as a crash.
	asserted += 1
	if dir == null:
		print("FAIL  scripts/ could not be read")
		bad += 1
	else:
		for f in dir.get_files():
			if not f.ends_with(".gd"):
				continue
			loaded += 1
			asserted += 1
			var s = load("res://scripts/" + f)
			if s == null or not (s as Script).can_instantiate():
				print("CANNOT LOAD: ", f)
				bad += 1

	# The floor. Without it the line below reports a pass on an empty read,
	# which is what it did before 078 and is recorded in the header.
	asserted += 1
	if loaded == 0:
		print("FAIL  scripts/ yielded no .gd file to load, so this check measured nothing")
		bad += 1

	print("LOADCHECK %d assertions, bad=%d" % [asserted, bad])
	quit(bad)
