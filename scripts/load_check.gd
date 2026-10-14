extends RefCounted
class_name LoadCheck

# --- 025: a load is verified like a delivery ---
#
# Loading a saved world is the only build in Genesis whose correct answer was
# written down in advance. The save file has carried a "metrics" block since
# worlds were first saveable: the measurements Genesis took the day it was
# built. Load rebuilds the world and measures it again.
#
# Nobody compared them. The evidence was on disk, next to the request, and
# nothing read it. "Loaded 'vault'" was a claim about a file being opened,
# dressed as a claim about a world coming back.
#
# That is the project's own rule, unapplied in the one place it was cheapest
# to apply. A carrier's word is not a delivery; a successful file read is not
# a restored world. So:
#
#   RESTORED      every measurement recorded then matches the one taken now
#   DIFFERENT     at least one disagrees, and the line names which and by how
#                 much
#   INCONCLUSIVE  nothing was recorded to compare against, so Genesis says it
#                 cannot tell rather than guessing it went well
#
# WHAT THIS CANNOT SEE, AND WHY IT SAYS SO EVERY TIME
# A save file holds the DESCRIPTION that made the world - rooms, doors, the
# objects it was built with - and not the state it was left in. So a world
# comes back as it was BORN, not as it was LAST SEEN: equipment is back to the
# free kit, every door is open again, and a thing that was carried to the
# vault is back where it started. All of that is true of a RESTORED world, so
# RESTORED has to say it, or it is read as "everything is back" and becomes
# the next half-truth in docs/TRAPS.md.

# The geometry is deterministic - the same description always builds the same
# world - so this is not a physics tolerance. It is here only because a number
# goes to text and back on its way through the file.
const TOLERANCE := 0.01

# What the save file does not hold, and so what a RESTORED cannot vouch for.
const NOT_SAVED := ["equipment", "which doors were shut", "where things had been carried to"]


# recorded: the metrics block out of the save file.
# measured: what the module measured after rebuilding it.
# Returns {"outcome", "differences", "not_measured", "said"}.
static func compare(recorded: Dictionary, measured: Dictionary) -> Dictionary:
	if recorded.is_empty():
		return {
			"outcome": "INCONCLUSIVE",
			"differences": [],
			"not_measured": [],
			"said": "Built it, but cannot tell whether it came back the same: nothing was measured when this was saved. %s" % _caveat(),
		}

	var differences: Array = []
	var not_measured: Array = []
	for key in recorded:
		if not measured.has(key):
			# Evidence about THIS VERSION OF GENESIS, not about the world. A
			# measurement the game has stopped taking says nothing about
			# whether the rooms came back, so it is reported and it does not
			# make the load DIFFERENT. Conflating the two would turn every
			# change to a measure() into a corrupted-world warning.
			not_measured.append(str(key))
			continue
		if not _same(recorded[key], measured[key]):
			differences.append({
				"what": str(key),
				"was": recorded[key],
				"now": measured[key],
			})

	if not differences.is_empty():
		return {
			"outcome": "DIFFERENT",
			"differences": differences,
			"not_measured": not_measured,
			"said": "This is not the world that was saved. %s" % _list_differences(differences),
		}

	var checked := recorded.size() - not_measured.size()
	if checked <= 0:
		return {
			"outcome": "INCONCLUSIVE",
			"differences": [],
			"not_measured": not_measured,
			"said": "Built it, but nothing in the file can be checked against this version of Genesis any more. %s" % _caveat(),
		}

	var said := "Measured it against the day it was saved: %d of %d measurements match." % [checked, recorded.size()]
	if not not_measured.is_empty():
		said += " %d could not be checked, because this version no longer measures %s." % [
			not_measured.size(), _join(not_measured)]
	return {
		"outcome": "RESTORED",
		"differences": [],
		"not_measured": not_measured,
		"said": "%s %s" % [said, _caveat()],
	}


# Two recorded values, one of which has been through a text file.
#
# JSON has one number type, so every integer Genesis measured comes back as a
# float: room_count 3 is saved and returns as 3.0. Comparing the dictionaries
# directly reports all seven whole-number measurements as changed, every
# single load, which is the loudest possible way to say nothing. So numbers
# are compared as numbers and everything else as text.
static func _same(was: Variant, now: Variant) -> bool:
	var numbers := [TYPE_INT, TYPE_FLOAT]
	if numbers.has(typeof(was)) and numbers.has(typeof(now)):
		return absf(float(was) - float(now)) <= TOLERANCE
	if typeof(was) == TYPE_DICTIONARY and typeof(now) == TYPE_DICTIONARY:
		var mine: Dictionary = was
		var theirs: Dictionary = now
		if mine.size() != theirs.size():
			return false
		for key in mine:
			if not theirs.has(key) or not _same(mine[key], theirs[key]):
				return false
		return true
	if typeof(was) == TYPE_ARRAY and typeof(now) == TYPE_ARRAY:
		var left: Array = was
		var right: Array = now
		if left.size() != right.size():
			return false
		for i in left.size():
			if not _same(left[i], right[i]):
				return false
		return true
	return str(was) == str(now)


# "the corridor is 52 m where it was 104 m, and there are 2 doors where there
# were 4" - the numbers, both of them, so the player can see the size of the
# disagreement rather than being told there is one.
static func _list_differences(differences: Array) -> String:
	var parts := PackedStringArray()
	for d in differences:
		var one: Dictionary = d
		parts.append("%s is %s where it was %s" % [
			str(one["what"]).replace("_", " "), _number(one["now"]), _number(one["was"])])
	return Readback.join_list(parts) + "."


# A measurement in a sentence. Whole numbers lose their ".0", because "3
# rooms" is what a player counted and "3.00 rooms" reads like a machine
# apologising. GDScript's format has no %g, so this does the choosing itself.
static func _number(value: Variant) -> String:
	if typeof(value) == TYPE_INT:
		return str(int(value))
	if typeof(value) == TYPE_FLOAT:
		var f := float(value)
		if absf(f - round(f)) < 0.005:
			return str(int(round(f)))
		return "%.2f" % f
	return "'%s'" % str(value)


# Said on every outcome, including the good one. A save file holds the
# description, not the state, so "restored" never means "as you left it".
static func _caveat() -> String:
	return "A saved world is the description that made it, so %s came back." % _join(NOT_SAVED, "none of")


static func _join(items: Array, lead: String = "") -> String:
	var parts := PackedStringArray()
	for i in items:
		parts.append(str(i))
	var said := Readback.join_list(parts)
	return said if lead == "" else "%s %s" % [lead, said]
