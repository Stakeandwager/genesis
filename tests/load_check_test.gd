extends SceneTree

# 025 - a load is verified like a delivery.
#
# The save file has carried the measurements Genesis took the day a world was
# built since worlds were first saveable. Load rebuilt the world, measured it
# again, and threw the comparison away. "Loaded 'vault'" was a claim about a
# file being read, dressed as a claim about a world coming back.
#
# The adversarial half is the half that matters, and it is the same shape as
# false_delivery_test: edit the saved description so the rebuilt world really
# is different, and demand that Genesis says so. A verification that only ever
# says RESTORED is not a verification.
#
# THE OTHER HALF IS THE FALSE ALARM
# JSON has one number type, so every integer in that file comes back as a
# float - room_count 3 saved, 3.0 returned. A comparison that does not know
# that reports seven changed measurements on every single load, which is the
# loudest possible way to say nothing, and a warning nobody can switch off is
# a warning nobody reads.

var bad := 0
var asserted := 0


func _check(ok: bool, what: String) -> void:
	asserted += 1
	print(("PASS  " if ok else "FAIL  ") + what)
	if not ok:
		bad += 1


# A dungeon built the way the controller builds one: validated, solved, then
# measured. Returns its metrics.
func _measure(parameters: Dictionary) -> Dictionary:
	var module := DungeonModule.new()
	var checked: Dictionary = module.validate(parameters)
	if not bool(checked["ok"]):
		_check(false, "the test's own dungeon is invalid: %s" % str(checked["errors"]))
		return {}
	var solved: Dictionary = module.solve(checked["content"])
	return module.measure(solved["layout"])


# What the measurements look like after a trip through the save file.
func _through_the_file(metrics: Dictionary) -> Dictionary:
	var back = JSON.parse_string(JSON.stringify(metrics))
	return back if typeof(back) == TYPE_DICTIONARY else {}


func _initialize() -> void:
	var three := {
		"rooms": [
			{"name": "hall", "width": 20, "depth": 20},
			{"name": "store", "width": 10, "depth": 10},
			{"name": "vault", "width": 10, "depth": 10}],
		"doors": [[1, 2], [2, 3]],
		"things": [{"name": "lamp", "in": "store"}]}

	var measured := _measure(three)
	if measured.is_empty():
		print("LOAD CHECK failures=%d" % bad)
		quit(1)
		return

	_the_same_world_comes_back(measured)
	_a_tampered_file_is_caught(measured, three)
	_nothing_recorded_is_inconclusive(measured)
	_a_measurement_this_version_dropped(measured)
	_every_outcome_says_what_was_not_saved()

	print("LOAD CHECK %d assertions, failures=%d" % [asserted, bad])
	quit(1 if bad > 0 else 0)


# --- the same description, rebuilt, measured again ---
#
# The geometry is deterministic, so this must come back RESTORED - and it must
# come back RESTORED through the file, which is where the integers turn into
# floats.
func _the_same_world_comes_back(measured: Dictionary) -> void:
	var recorded := _through_the_file(measured)
	_check(not recorded.is_empty(), "the metrics survive a trip through the file")

	# The thing the naive comparison gets wrong, asserted directly so nobody
	# "simplifies" _same back into ==.
	var whole_numbers := 0
	for key in measured:
		if typeof(measured[key]) == TYPE_INT:
			whole_numbers += 1
			_check(typeof(recorded.get(key)) == TYPE_FLOAT,
				"%s left as an int and came back a float" % str(key))
	_check(whole_numbers >= 5, "there are %d whole-number measurements to get wrong" % whole_numbers)
	_check(recorded != measured, "so the two dictionaries are not equal, and == would fail every load")

	var verdict := LoadCheck.compare(recorded, measured)
	print("      %s" % str(verdict["said"]))
	_check(str(verdict["outcome"]) == "RESTORED",
		"and the same world still reports RESTORED, not %s" % str(verdict["outcome"]))
	_check((verdict["differences"] as Array).is_empty(), "with nothing listed as different")
	_check(str(verdict["said"]).contains("%d of %d" % [measured.size(), measured.size()]),
		"saying how many measurements were checked")


# --- the half that decides whether any of this is worth having ---
#
# Six ways the world that comes back is not the world that was saved. Each one
# must be reported, and the line must name the measurement and both numbers,
# because "something changed" is not evidence a player can act on.
func _a_tampered_file_is_caught(measured: Dictionary, three: Dictionary) -> void:
	# 1. A room taken out of the description before it is rebuilt.
	var two := three.duplicate(true)
	(two["rooms"] as Array).remove_at(2)
	two["doors"] = [[1, 2]]
	two["things"] = [{"name": "lamp", "in": "store"}]
	var smaller := _measure(two)
	var caught := LoadCheck.compare(_through_the_file(measured), smaller)
	print("      %s" % str(caught["said"]))
	_check(str(caught["outcome"]) == "DIFFERENT", "a room removed is caught")
	_check(str(caught["said"]).contains("room count is 2 where it was 3"),
		"and named with both numbers: '%s'" % str(caught["said"]))

	# 2. A room made bigger, which moves the floor area and the slot pitch.
	var bigger := three.duplicate(true)
	(bigger["rooms"] as Array)[2]["width"] = 30
	(bigger["rooms"] as Array)[2]["depth"] = 30
	var grown := _measure(bigger)
	var caught_growth := LoadCheck.compare(_through_the_file(measured), grown)
	_check(str(caught_growth["outcome"]) == "DIFFERENT", "a room resized is caught")
	_check((caught_growth["differences"] as Array).size() >= 2,
		"with every measurement it moved listed, not just the first (%d)" % (caught_growth["differences"] as Array).size())

	# 3. A door taken away. Not any door: the validator refuses a design whose
	# rooms cannot all be reached, so a save file cannot smuggle back a
	# dungeon with an orphaned room - which is worth knowing, because that
	# would have been the most dangerous kind of "restored". What CAN change
	# is a loop. Same rooms, all still reachable, a different dungeon to walk.
	var looped := {
		"rooms": [
			{"name": "hall", "width": 20, "depth": 20},
			{"name": "store", "width": 10, "depth": 10},
			{"name": "vault", "width": 10, "depth": 10},
			{"name": "crypt", "width": 10, "depth": 10}],
		"doors": [[1, 2], [2, 3], [3, 4], [4, 1]]}
	var in_a_row := looped.duplicate(true)
	in_a_row["doors"] = [[1, 2], [2, 3], [3, 4]]
	var with_loop := _measure(looped)
	var without := _measure(in_a_row)
	_check(not with_loop.is_empty() and not without.is_empty(), "both four-room dungeons are legal")
	var caught_door := LoadCheck.compare(_through_the_file(with_loop), without)
	print("      %s" % str(caught_door["said"]))
	_check(str(caught_door["outcome"]) == "DIFFERENT", "a loop closed up is caught")
	_check(str(caught_door["said"]).contains("door count") or str(caught_door["said"]).contains("loops"),
		"and says what stopped connecting: '%s'" % str(caught_door["said"]))

	# 4. A single number edited by hand in the file, by less than a metre.
	var nudged := _through_the_file(measured)
	nudged["corridor_length"] = float(nudged["corridor_length"]) + 0.5
	var caught_nudge := LoadCheck.compare(nudged, measured)
	_check(str(caught_nudge["outcome"]) == "DIFFERENT", "half a metre of corridor is caught")

	# 5. But not a difference that is only how a number was printed. A
	# tolerance that catches nothing is as useless as one that catches
	# everything.
	var rounded := _through_the_file(measured)
	rounded["corridor_length"] = float(rounded["corridor_length"]) + 0.001
	_check(str(LoadCheck.compare(rounded, measured)["outcome"]) == "RESTORED",
		"a thousandth of a metre is printing, not a different world")

	# 6. A name changed, not a number. The largest room being a different
	# room is a different world even when the areas happen to match.
	var renamed := _through_the_file(measured)
	renamed["largest_room"] = "cellar"
	var caught_name := LoadCheck.compare(renamed, measured)
	_check(str(caught_name["outcome"]) == "DIFFERENT", "a changed name is caught")
	_check(str(caught_name["said"]).contains("'hall'") and str(caught_name["said"]).contains("'cellar'"),
		"with both names quoted: '%s'" % str(caught_name["said"]))


# --- cannot tell means cannot tell ---
#
# A plan's last_build carries no metrics, and the oldest save files predate
# some of them. The one thing Genesis must not do is call that a success.
func _nothing_recorded_is_inconclusive(measured: Dictionary) -> void:
	var verdict := LoadCheck.compare({}, measured)
	_check(str(verdict["outcome"]) == "INCONCLUSIVE",
		"a file with no measurements is INCONCLUSIVE, not RESTORED")
	_check(str(verdict["said"]).contains("cannot tell"), "and says cannot tell in those words")
	_check(not str(verdict["said"]).contains("match"), "without implying anything matched")


# --- a measurement this version of Genesis no longer takes ---
#
# That is evidence about the CODE, not about the world. A measure() that has
# changed must not read as a corrupted save, or every release would warn about
# every old world. It is reported, and it does not make the load DIFFERENT.
func _a_measurement_this_version_dropped(measured: Dictionary) -> void:
	var recorded := _through_the_file(measured)
	recorded["sconces"] = 4.0
	var verdict := LoadCheck.compare(recorded, measured)
	_check(str(verdict["outcome"]) == "RESTORED",
		"a measurement Genesis has stopped taking is not a different world")
	_check((verdict["not_measured"] as Array).has("sconces"), "but it is reported")
	_check(str(verdict["said"]).contains("no longer measures sconces"),
		"by name: '%s'" % str(verdict["said"]))

	# And if that is ALL there was, nothing was checked, so Genesis says so
	# rather than passing a comparison it never made.
	var only_gone := LoadCheck.compare({"sconces": 4.0}, measured)
	_check(str(only_gone["outcome"]) == "INCONCLUSIVE",
		"a file Genesis can no longer check at all is INCONCLUSIVE")


# --- RESTORED must never be read as "everything is back" ---
#
# A save file holds the description that made a world, not the state it was
# left in. So the good outcome has to say what did not come back, in the same
# breath, or it becomes the next entry in TRAPS.
func _every_outcome_says_what_was_not_saved() -> void:
	var measured := _measure({
		"rooms": [{"name": "hall", "width": 20, "depth": 20}, {"name": "store", "width": 10, "depth": 10}],
		"doors": [[1, 2]]})
	for verdict in [
		LoadCheck.compare(_through_the_file(measured), measured),
		LoadCheck.compare({}, measured),
	]:
		var said := str((verdict as Dictionary)["said"])
		_check(said.contains("equipment"), "%s says equipment did not come back" % str((verdict as Dictionary)["outcome"]))
		_check(said.contains("doors were shut"), "and that shut doors did not")
		_check(said.contains("carried"), "and that carried things did not")

	# The prompt says the same thing to the AI, so it stops telling players
	# that nothing persists - which it did, because 023 told it to.
	var prompt: String = AIInterpreter.SYSTEM_PROMPT
	_check(not prompt.contains("Nothing persists"), "the prompt no longer claims nothing persists")
	_check(prompt.contains("as it was BUILT, not as it was LEFT"),
		"it says what a saved world really brings back")
	_check(prompt.contains("SAVES AND LOADS"), "and lists saving as something Genesis does")
