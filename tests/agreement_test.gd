extends SceneTree

# --- 070: a count and the word that agrees with it, decided by hand ---
#
# WHERE THIS CAME FROM
#
# HANDOVER's live entry was the regex-breadth axis, continued at the three
# patterns 068 read and did not take. The first of the three was named like
# this: "container_door_test's and counted_said_test's \\b1 [a-z_]+s\\b cannot
# see a plural that does not end in s".
#
# THAT NAMED ONE PATTERN AND THERE WERE TWO DIFFERENT ONES. Measured in Godot
# before anything was changed:
#
#   container_door_test  \\b1 [a-z]+s\\b    "1 dead_ends" BLIND
#   counted_said_test    \\b1 [a-z_]+s\\b   "1 dead_ends" CAUGHT
#
# The entry wrote the wider pattern for both. "dead_ends" is a key of the very
# metrics dictionary container_door_test's sweep runs over, and "banked_corner"
# and "loop_segment" reach a panel through RacingModule._counted() whenever the
# validator accepts a type the prompt does not offer. That is TRAPS 66 again,
# in the handover entry that names this task (TRAPS 67).
#
# AND FEEDING THE PATTERNS THE REST OF THEIR CLASS FOUND A LIVE FAULT THAT IS
# NOT A NOUN AT ALL.
#
# The widening a multi-word noun would need - "\\b1 [a-z_]+(?: [a-z_]+)*s\\b",
# so that "1 saved worlds" is seen - was measured against the sentences
# Genesis already produces, and it matches two that are CORRECT:
#
#   "1 of them changes to the last world"
#   "1 readback that bears on it"
#
# Both are right at one and wrong at every other count, because the word
# agreeing with the count is a VERB. The second reads it from
# Readback.agrees(). THE FIRST DECIDED IT BY HAND AND GOT IT WRONG:
#
#   session_report.gd:242  "Worlds built: %d (%d of them changes ...)"
#
# Measured by producing the line rather than by reading it:
#
#   edits=0  ->  Worlds built: 1 (0 of them changes to the last world).
#   edits=1  ->  Worlds built: 2 (1 of them changes to the last world).
#   edits=2  ->  Worlds built: 3 (2 of them changes to the last world).
#   edits=3  ->  Worlds built: 4 (3 of them changes to the last world).
#
# Correct at exactly ONE of the four, and the one it is correct at is the one
# the comment fourteen lines above it was written about: "042: the count and
# the noun after it are one fact, read from Readback.plural() and never
# written out again". The file states the rule and then breaks it, which is
# TRAPS 22's shape. `docs/HANDOVER.md` quoted the wrong form as real output
# at its 033 section, where the transcript is now annotated rather than
# rewritten: it is a record of what Genesis said, and it said that.
#
# THE GENERAL RULE, stated so it can be applied rather than admired: a
# sentence that states a count and a word that agrees with it must read that
# agreement from Readback.agrees(), whether the agreeing word is a NOUN, a
# VERB or a PRONOUN, and whether the count is a variable or a constant. 042
# put the noun behind that reader and swept for nouns. A verb and a pronoun
# are the same single fact - count == 1 - decided somewhere else.
#
# WHAT THIS SUITE ASSERTS, AND WHY IT IS A FACT AND NOT A WORDING (TRAPS 6)
#
# Every agreement assertion below is a ROUND TRIP against Readback.agrees():
# the word Genesis actually said is compared with what agrees() answers for
# the count that was actually passed. No agreeing word is typed into this
# file as the expected answer, so a sentence reworded in a way that stays
# true does not fail here, and a sentence whose word stops following its
# count does - which is the fault and not the phrasing.
#
# WHAT IT DOES NOT PROVE, said plainly because the gap is the interesting
# part. Some of these sentences are held by a SOURCE SCAN and not by a
# produced one, because this harness cannot stand them up: RaceDirector's
# announcement needs a race on stepped physics, AIInterpreter's two HTTP
# sentences need the node, DungeonModule's ring budget needs a placement that
# actually runs out of space, and the AI PROMPT's two floors in
# racing_module.gd are a sentence no player ever reads. For those the scan
# says the hand-written decision is gone and that the sentence reads a
# Readback function; it does not watch the word change with the count. The
# ones that ARE produced are produced: session_report's four and
# FeasibilityGate's floor refusal, each a round trip above.
#
# 080: NO COUNT IS WRITTEN IN THIS PARAGRAPH ANY MORE. It used to say "four of
# the nine sites" and "the five that are produced", and that arithmetic left
# the PROMPT out altogether - the tenth row of 070's own table, which had no
# pin at all until 080 gave it one. A count in a comment about a class the
# code carries is the next session's stale count (079's rule, TRAPS 24), and
# this one was load-bearing while it was wrong: it read as though every member
# were accounted for.
#
# And the multi-word hole is closed by DERIVING the nouns from the code
# rather than by widening the regex: every string literal handed to
# Readback.plural() in scripts/ is collected, and the disagreeing form of
# each is swept for. A tenth noun added in scripts/ is covered without this
# file being edited. The generic regex is kept beside it for the nouns that
# never appear as a literal - RacingModule._counted() passes str(type) and
# FarmModule passes str(key) - because those two cannot be collected this
# way, which is the half the regex is still needed for.

const READER := "res://scripts/readback.gd"

# The one place a count and a plural are written together on purpose, named
# rather than skipped by file, with the reason. This is the PLURAL BRANCH of a
# Readback.agrees() call: agrees() makes the decision and the two forms are
# handed to it, which is how plural() itself carries an irregular plural. The
# branch can only be reached when the count is not one, so the words in it are
# right by construction.
const ALLOWED_BY_HAND := {
	"session_report.gd: %d times": "the plural branch of a Readback.agrees() call",
}

# --- 070: the hand-decided agreements, each pinned to the reader it routes
# --- its count through, because the scan above cannot see a revert that takes
# --- its own needle with it
#
# MEASURED, as deliberate fault 5 of 070, and it is a fault in the GUARD and
# not in the code: reverting dungeon_module.gd's ring budget to "%d rings"
# PASSED every check in this file. The hardcoded-plural scan builds its
# needles from the nouns handed to Readback.plural() in scripts/, and that
# site was the only call in the project passing "ring" - so the revert deleted
# the fault and the needle that catches it in one edit. A scan whose class is
# derived from the code it is checking is blind to exactly the change that
# shrinks the class.
#
# These rows are a weaker kind of assertion than the produced sentences above:
# they say the sentence is BUILT from a Readback reader, not that its word was
# watched changing with its count. That is the most a harness can say about
# the sentences it cannot stand up, and it is said plainly here rather than
# dressed up as a measurement.
#
# 080: THE PIN IS PER SITE AND IT USED TO BE PER FILE, which is the same fault
# one level up (TRAPS 11). The table was keyed by file and asked contains(),
# so one needle held one site however many the file had. Measured, each in its
# own throwaway copy with its own config/name (TRAPS 50), reading the FAIL
# lines:
#
#   ai_interpreter.gd carries TWO of these sentences with the SAME needle
#   text. Either one reverted alone - "Genesis tried " + str(MAX_ATTEMPTS) +
#   " times", which no "%d <plural>" needle can see - scored 47 assertions,
#   failures=0. Only reverting BOTH failed.
#
#   race_director.gd's announcement carries TWO agreements and the table named
#   one. 070 itself replaced "%d laps against %d opponent%s" with two
#   Readback.plural() calls; the "lap" half was never tabled. Reverting it the
#   NAIVE way, back to "%d laps", scored 47 assertions, failures=0, because
#   "lap" is the only literal of its kind in scripts/ - fault 5's shape again,
#   in a file that already had a row.
#
#   racing_module.gd's two PROMPT plurals - the tenth row of 070's own table,
#   and the one it called "TRAPS 11 inside 068's own fix" - had NO ROW AT ALL
#   and are not among the produced sentences either. Written out by hand in
#   the hiding form, agreement_test scored 47 failures=0 AND prompt_bounds_test
#   scored 72 failures=0: the prompt is byte-identical while both floors are 2,
#   so no fingerprint moves. 070 recorded that second half and not the first.
#
# So the key is now the file and the VALUE IS A LIST OF [needle, least] ROWS,
# one row per hand-decided agreement, and the loop COUNTS occurrences instead
# of asking whether there is one. The count is a FLOOR and not an equality, so
# it goes stale in the safe direction: a third HTTP sentence that correctly
# reads the reader passes without this file moving, and a site that stops
# reading it drops the count below the floor and fails. An arrival that
# forgets its row is still silent - the same shape of gap source_scan_test
# records under "Human decision needed" 32, and here it cannot be closed by
# deriving the class: the members are the sites 070 found deciding agreement BY
# HAND, and dungeon_module.gd has nineteen Readback.plural() calls of which one
# is a member. See HANDOVER's "Next action", where that is written down as a
# limitation rather than left as a task.
#
# feasibility_gate.gd and racing_module.gd state the same two floors in two
# places - the refusal a player reads and the prompt the model reads - with
# the same two noun literals and the constants reached by their own name in
# one file and qualified in the other, so the four calls are four distinct
# needles and all four are rowed. They have to be: the derived needle for
# either noun survives ONE of its two call sites being reverted and vanishes
# only when both go, which is how fault 5 hid.
#
# session_report.gd keeps ONE row for four hand-decided agreements on purpose:
# the other three are PRODUCED above, by round trip against agrees(), which is
# the stronger assertion. A row would add nothing a produced sentence has not
# already said.
const READS_THE_READER := {
	"race_director.gd": [
		["Readback.plural(RACE_LAPS, \"lap\")", 1],
		["Readback.plural(count, \"opponent\")", 1],
	],
	"ai_interpreter.gd": [
		["Readback.plural(MAX_ATTEMPTS, \"time\")", 2],
	],
	"dungeon_module.gd": [
		["Readback.plural(MAX_RING, \"ring\")", 1],
	],
	"experiment_runner.gd": [
		["Readback.plural(int(wait), \"second\")", 1],
	],
	"feasibility_gate.gd": [
		["Readback.plural(MIN_STRAIGHTS, \"straight\")", 1],
		["Readback.plural(MIN_TURNS, \"corner or hairpin\", \"corners or hairpins\")", 1],
	],
	"racing_module.gd": [
		["Readback.plural(FeasibilityGate.MIN_STRAIGHTS, \"straight\")", 1],
		["Readback.plural(FeasibilityGate.MIN_TURNS, \"corner or hairpin\", \"corners or hairpins\")", 1],
	],
	"session_report.gd": [
		["Readback.agrees(int(s[\"changes\"]), \"changes\", \"change\")", 1],
	],
}

var lines: Array = []
var failures: Array = []


func _check(ok: bool, what: String) -> void:
	lines.append("%s %s" % ["PASS" if ok else "FAIL", what])
	if not ok:
		failures.append(what)


# The text of a file's own _code_of(), from its header line to the first line
# that is not part of it. Comments are stripped so that a question about what
# the code DOES is answered from the code and never from prose (TRAPS 63).
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


func _source(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	return _code_of(file.get_as_text())


func _scripts() -> Array:
	var out: Array = []
	var dir := DirAccess.open("res://scripts")
	if dir == null:
		return out
	for name in dir.get_files():
		if str(name).ends_with(".gd"):
			out.append("res://scripts/%s" % str(name))
	out.sort()
	return out


func _initialize() -> void:
	_the_reader()
	_the_session_line()
	_the_session_siblings()
	_the_gates_floor()
	_no_agreement_by_hand()
	_the_sites_read_the_reader()
	_the_nouns_off_the_code()
	_the_sweeps_breadth()

	for line in lines:
		print(line)
	print("")
	print("AGREEMENT %d assertions, failures=%d" % [lines.size(), failures.size()])
	quit(1 if failures.size() > 0 else 0)


# --- the one reading, so the rest of this suite is measuring what it thinks ---
#
# agrees() decides one thing: is this count one. Asserted as a property of the
# function and not as a quoted string, and asserted for a VERB as well as a
# noun, because the verb is the half 042's sweep could not see.
func _the_reader() -> void:
	_check(Readback.agrees(1, "changes", "change") == "changes",
		"agrees() says the singular word at one")
	for n in [0, 2, 3, 11]:
		_check(Readback.agrees(n, "changes", "change") == "change",
			"agrees() says the plural word at %d" % n)
	_check(Readback.agrees(1, "it", "them") == "it" and Readback.agrees(2, "it", "them") == "them",
		"and it answers for a pronoun on the same fact")


# --- session_report.gd:242 — the verb that was right at one count of four ---
func _the_session_line() -> void:
	for edits in [0, 1, 2, 3]:
		var summary := _session_summary(edits)
		var line := ""
		for row in summary.split("\n"):
			if str(row).begins_with("Worlds built"):
				line = str(row)
		_check(line != "", "a session of %d change(s) reports a worlds-built line" % edits)
		if line == "":
			continue

		# THE FACT: the count in the sentence is the count of changes, and the
		# word after it is the word agrees() answers for that count. Both read
		# off the sentence; neither typed in.
		# THE VERB ITSELF, read out of the sentence by position and compared
		# whole. "of them" is the grammatical subject the verb follows, so it
		# is part of the fact; the rest of the sentence is wording, and fault
		# 10 below rewords the tail and this still passes.
		#
		# Compared WHOLE and not by contains(), because "changes" contains
		# "change": the first form of this assertion passed the wrong verb at
		# a count of one and was caught by its own negative control.
		var verb := _verb_after(line, "%d of them " % edits)
		var want := Readback.agrees(edits, "changes", "change")
		_check(verb == want,
			"at %d changes the verb follows the count - wanted \"%s\", said \"%s\" (%s)" % [
				edits, want, verb, line])


# --- the three other agreements in the same function, at the same door ---
#
# All three were decided by hand and all three were CORRECT. They are here
# because they are second copies of the fact the line above got wrong, and a
# second copy is what TRAPS 11 is about: the fix is to the class.
func _the_session_siblings() -> void:
	# "yes, once" / "yes, N times" — the drove line.
	for drove in [1, 2, 3]:
		var said := _drove_line(_session_summary_with({"drove": drove}))
		var want := Readback.agrees(drove, "yes, once", "yes, %d times" % drove)
		_check(said.contains(want),
			"drove %d reads \"%s\" (said: %s)" % [drove, want, said])

	# The bare "no" count and the pronoun after it, in the understanding block.
	for disputed in [1, 2]:
		var summary := _summary_with_disputes(disputed)
		var want_noun := Readback.agrees(disputed, "one bare \"no\"",
			"%d bare \"no\"s" % disputed)
		var want_pronoun := Readback.agrees(disputed, "it", "them")
		_check(summary.contains(want_noun),
			"%d disputed reads \"%s\" (said: %s)" % [
				disputed, want_noun, summary.replace("\n", " | ")])
		_check(summary.contains("read %s below" % want_pronoun),
			"and the pronoun after it follows the same count (\"%s\")" % want_pronoun)


# --- feasibility_gate.gd:83 — a bound stated to the player, plural by hand ---
#
# The count here is a CONSTANT, so this sentence was true and stayed true; it
# is in the class because the plural was written out beside a number the owner
# can change. Produced rather than read: the floor refusal is reached by a
# composition that is short of turns.
func _the_gates_floor() -> void:
	var sections: Array = []
	for i in FeasibilityGate.MIN_STRAIGHTS + 1:
		sections.append({"type": "straight", "length": 200.0})
	var gate: Dictionary = FeasibilityGate.check(sections)
	var reasons := " | ".join(PackedStringArray(gate.get("reasons", [])))
	_check(not bool(gate.get("ok", true)),
		"a composition of straights alone does not clear the gate")

	var want_straights := Readback.plural(FeasibilityGate.MIN_STRAIGHTS, "straight")
	var want_turns := Readback.plural(FeasibilityGate.MIN_TURNS,
		"corner or hairpin", "corners or hairpins")
	_check(reasons.contains("at least %s and %s" % [want_straights, want_turns]),
		"the floor refusal states both bounds through plural() - wanted \"at least %s and %s\" (said: %s)" % [
			want_straights, want_turns, reasons])


# --- the class, held mechanically: nothing decides agreement by hand ---
#
# The idiom is "is this count one, answered inline": a conditional on == 1 or
# != 1 whose branches are the two forms of a word. Scanned over code with
# comments stripped, so the rule cannot be satisfied by prose (TRAPS 63).
#
# This is the half that catches the TENTH site. It cannot catch a sentence
# that states the wrong word with no conditional at all - which is exactly
# what session_report.gd:242 was - and that limit is why the five produced
# sentences above are produced and not scanned.
func _no_agreement_by_hand() -> void:
	var idioms := ["== 1 else", "!= 1 else", "else \"s\""]
	var offenders: Array = []
	for path in _scripts():
		# readback.gd is where the decision BELONGS - agrees() is the one
		# reader, and its body is the idiom. Skipped by name, and asserted
		# below to still be there, so this scan cannot pass by the reader
		# having been deleted.
		if path == READER:
			continue
		var code := _source(path)
		for idiom in idioms:
			if code.contains(idiom):
				offenders.append("%s: %s" % [path.get_file(), idiom])
	_check(offenders.is_empty(),
		"no file in scripts/ but the reader decides \"is this count one\" inline%s" % (
			"" if offenders.is_empty() else " - %s" % "; ".join(PackedStringArray(offenders))))
	_check(_source(READER).contains("== 1 else"),
		"and the reader itself still makes that decision, in one place (%s)" % READER)

	# THE OTHER IDIOM, which is the one session_report.gd:242 actually was: a
	# format string that writes a count and then the plural of the noun beside
	# it, with no conditional anywhere. The conditional scan above cannot see
	# that shape, so it is swept for by name, using the plurals derived from
	# the call sites rather than a list typed here (TRAPS 66).
	var hardcoded: Array = []
	for path in _scripts():
		if path == READER:
			continue
		var code := _source(path)
		for pair in _plural_nouns():
			var needle := "%%d %s" % str((pair as Array)[1])
			if not code.contains(needle):
				continue
			var row := "%s: %s" % [path.get_file(), needle]
			if ALLOWED_BY_HAND.has(row):
				continue
			hardcoded.append(row)
	_check(hardcoded.is_empty(),
		"no file in scripts/ writes a count and the plural of its noun together%s" % (
			"" if hardcoded.is_empty() else " - %s" % "; ".join(PackedStringArray(hardcoded))))

	# Every allowance is asserted to be STILL THERE, so a row cannot go stale
	# in the direction that matters: if one is fixed, this fails and the row
	# has to be struck rather than left as cover for the next one.
	for row in ALLOWED_BY_HAND:
		var parts: Array = str(row).split(": ")
		var code2 := _source("res://scripts/%s" % str(parts[0]))
		_check(code2.contains(str(parts[1])),
			"the allowance \"%s\" is still what it says it is - %s" % [
				row, str(ALLOWED_BY_HAND[row])])

	# And the scan is not vacuous: the idiom it looks for is one it finds when
	# it is there. A negative control on the READER, not on the wording.
	_check(_code_of("\tvar s := \"\" if count == 1 else \"s\"\n").contains("== 1 else"),
		"and the scan sees that idiom in code when it is present")
	_check(not _code_of("# the plural used to be \"\" if count == 1 else \"s\"\n").contains("== 1 else"),
		"and does not see it in a comment that merely mentions it (TRAPS 63)")


# --- the hand-decided agreements, pinned one by one ---
func _the_sites_read_the_reader() -> void:
	for file in READS_THE_READER:
		var code := _source("res://scripts/%s" % str(file))
		for row in READS_THE_READER[file]:
			var needle := str((row as Array)[0])
			var least := int((row as Array)[1])
			var seen := code.count(needle)
			_check(seen >= least,
				"%s routes %s through the reader: %s (found %d)" % [
					file, Readback.plural(least, "count"), needle, seen])

	# And the counting is not vacuous, which is the half contains() could not
	# have: a needle present TWICE is counted twice, so a floor of two can fail
	# at one, and a needle only MENTIONED in a comment is counted none (TRAPS
	# 63/64 - the same control the scan above carries).
	var twice := "\tvar a := Readback.plural(N, \"x\")\n\tvar b := Readback.plural(N, \"x\")\n"
	_check(_code_of(twice).count("Readback.plural(N, \"x\")") == 2,
		"a needle written twice in code is counted twice, so a floor of two can fall to one")
	_check(_code_of("# Readback.plural(N, \"x\") used to be here\n").count("Readback.plural(N, \"x\")") == 0,
		"and a needle only mentioned in a comment is counted none (TRAPS 63)")


# --- the nouns, derived from the code and not listed in this file ---
#
# Every string literal handed to Readback.plural() in scripts/. Collected so
# the sweep below can be fed the real class rather than a reading of it
# (TRAPS 66), and so a noun added later is covered without this file moving.
func _the_nouns_off_the_code() -> void:
	var nouns := _plural_nouns()
	var singulars := PackedStringArray()
	for pair in nouns:
		singulars.append(str((pair as Array)[0]))
	_check(nouns.size() >= 10,
		"the nouns Genesis counts are read off scripts/ (%d found: %s)" % [
			nouns.size(), ", ".join(singulars)])

	# The check below is only interesting if the class actually contains a
	# member the generic regex cannot match. Asserted, not assumed: at least
	# one noun has a space in it, and today that is "saved world" - the one
	# noun this project has ALREADY shipped the fault on, inline in
	# Main._list_worlds(), per world_store.gd's own comment.
	var multiword: Array = []
	for pair in nouns:
		if str((pair as Array)[0]).contains(" "):
			multiword.append(str((pair as Array)[1]))
	_check(not multiword.is_empty(),
		"at least one of them is more than one word, so the pattern half is not the whole net (%s)" % str(multiword))
	var irregular: Array = []
	for pair in nouns:
		var both: Array = pair as Array
		if str(both[1]) != str(both[0]) + "s":
			irregular.append("%s -> %s" % [str(both[0]), str(both[1])])
	_check(not irregular.is_empty(),
		"and at least one plural is not the singular plus an s, so the pair is read from the call and not assembled here (%s)" % str(irregular))


# --- the regex-breadth question, asked of both sweeps at once ---
#
# For every noun in the derived class, the disagreeing form "1 <plural>" is a
# sentence Genesis must never say. This asserts WHICH NET CATCHES IT: the
# generic pattern where it can, and the noun-derived needle where it cannot.
# A noun no net catches fails here.
func _the_sweeps_breadth() -> void:
	# Every member of the derived class must be visible to the net. This is the
	# assertion that fails if the net is only the regex: "1 saved worlds" and
	# "1 corners or hairpins" are members and the regex cannot spell either.
	var unseen: Array = []
	for pair in _plural_nouns():
		var wrong := "1 %s" % str((pair as Array)[1])
		if _counts_one_in_plural(wrong) == "":
			unseen.append(wrong)
	_check(unseen.is_empty(),
		"the net sees a count of one in the plural for every noun scripts/ counts%s" % (
			"" if unseen.is_empty() else " - MISSED: %s" % "; ".join(PackedStringArray(unseen))))

	# The underscore members, which is the measured divergence this task began
	# at: container_door_test's pattern was blind to all three.
	for member in ["1 dead_ends", "1 banked_corners", "1 loop_segments"]:
		_check(_counts_one_in_plural(member) != "",
			"and it sees a plural spelled with an underscore (%s)" % member)

	# AND IT MUST NOT CATCH A SENTENCE THAT IS RIGHT. These are the controls
	# that found session_report.gd:242: a greedy multi-word pattern matches
	# all three, and the first two are correct English at a count of one.
	for control in ["1 of them changes to the last world",
			"1 readback that bears on it", "1 saved world", "1 room"]:
		var hit := _counts_one_in_plural(control)
		_check(hit == "",
			"and it does not flag a sentence that agrees (%s)%s" % [
				control, "" if hit == "" else " - flagged \"%s\"" % hit])

	# And the net applied to the sentences THIS suite caused to be produced,
	# so the class is swept and not merely described.
	var said: Array = []
	for edits in [0, 1, 2, 3]:
		said.append(_session_summary(edits))
	said.append(_summary_with_disputes(2))
	said.append(_drove_line(_session_summary_with({"drove": 1})))
	var caught: Array = []
	for sentence in said:
		for line in str(sentence).split("\n"):
			var hit2 := _counts_one_in_plural(str(line))
			if hit2 != "":
				caught.append("\"%s\" in: %s" % [hit2, str(line)])
	_check(caught.is_empty(), "no sentence counts one of anything in the plural%s" % (
		"" if caught.is_empty() else " - %s" % "; ".join(PackedStringArray(caught))))


# --- helpers ---

# Every noun a Readback.plural() call in scripts/ hands in, as [singular,
# plural]. The plural is the call's own third argument when it has one and
# singular + "s" when it does not, which is exactly what plural() itself does
# - so the pair is read from the call site and never guessed here. "corner or
# hairpin" is why this matters: its plural is "corners or hairpins", which no
# rule about adding an "s" would produce.
func _plural_nouns() -> Array:
	var found := {}
	var call := RegEx.new()
	call.compile("Readback\\.plural\\([^,]+,\\s*\"([^\"]+)\"(?:\\s*,\\s*\"([^\"]+)\")?")
	for path in _scripts():
		for hit in call.search_all(_source(path)):
			var singular := hit.get_string(1)
			var many := hit.get_string(2)
			found[singular] = many if many != "" else singular + "s"
	var out: Array = []
	var keys: Array = found.keys()
	keys.sort()
	for k in keys:
		out.append([k, found[k]])
	return out


# THE NET, in one function both halves of this suite call: does this line
# count ONE of something and then wear the plural? Returns the offending text
# or "".
#
# It is two readers and not one, because neither alone covers the class:
#
#   the PATTERN, \b1 [a-z_]+s\b, which is the two older suites' sweep. It
#   covers any single-word noun including the ones no literal can be
#   collected for - RacingModule._counted() passes str(type) and
#   FarmModule passes str(key) - and it cannot spell a noun with a space.
#
#   the NOUNS, derived from the call sites above, which cover a multi-word
#   noun and an irregular plural and nothing that is not in scripts/.
#
# A greedy multi-word pattern would do away with the second half and was
# measured instead of assumed: it flags "1 of them changes to the last world"
# and "1 readback that bears on it", both of which are CORRECT at a count of
# one. Widening the pattern would have turned the net into a liar in order to
# see two nouns.
func _counts_one_in_plural(line: String) -> String:
	var pattern := RegEx.new()
	pattern.compile("\\b1 [a-z_]+s\\b")
	var hit := pattern.search(line)
	if hit != null:
		return hit.get_string()
	for pair in _plural_nouns():
		var wrong := "1 %s" % str((pair as Array)[1])
		if line.contains(wrong):
			return wrong
	return ""


# The single word that follows `after` in `line`, or "" if it is not there.
# Returned whole so a caller compares words and never substrings.
func _verb_after(line: String, after: String) -> String:
	var at := line.find(after)
	if at < 0:
		return ""
	var rest := line.substr(at + after.length())
	var word := ""
	for i in rest.length():
		var ch := rest[i]
		if ch >= "a" and ch <= "z":
			word += ch
		else:
			break
	return word


func _session_summary(edits: int) -> String:
	var records: Array = [{"type": "session_event",
		"time": "2026-10-08T09:00:00", "event": "session_start"}]
	records.append({"time": "2026-10-08T09:00:01", "id": "r0",
		"request": "a farm with a barn", "readback": "a farm with a 20 m barn",
		"result": "VALID", "command": "CREATE_FARM",
		"source": {"source": "ai"}, "metrics": {}})
	for i in edits:
		records.append({"time": "2026-10-08T09:00:1%d" % i, "id": "e%d" % i,
			"request": "make the barn bigger", "readback": "a farm with a 30 m barn",
			"result": "VALID", "command": "CREATE_FARM",
			"source": {"source": "ai", "edit": true}, "metrics": {}})
	records.append({"type": "session_event",
		"time": "2026-10-08T09:01:00", "event": "session_end"})
	return SessionReport.describe("tester", SessionReport.summarise(records))


# The summary dictionary with one field forced, for the lines whose count is
# not worth standing a whole session up to produce.
func _session_summary_with(overrides: Dictionary) -> Dictionary:
	var records: Array = [{"type": "session_event",
		"time": "2026-10-08T09:00:00", "event": "session_start"},
		{"type": "session_event", "time": "2026-10-08T09:01:00", "event": "session_end"}]
	var s: Dictionary = SessionReport.summarise(records)
	for key in overrides:
		s[key] = overrides[key]
	return s


func _drove_line(s: Dictionary) -> String:
	for row in SessionReport.describe("tester", s).split("\n"):
		if str(row).begins_with("Drove:"):
			return str(row)
	return ""


func _summary_with_disputes(disputed: int) -> String:
	var records: Array = [{"type": "session_event",
		"time": "2026-10-08T09:00:00", "event": "session_start"}]
	# One readback that bears on understanding and is confirmed, so the rate
	# can be stated, plus `disputed` bare "no"s, which is what puts the
	# between-two-rates branch and its pronoun on screen.
	records.append({"time": "2026-10-08T09:00:01", "id": "ok0",
		"request": "a farm with a barn", "readback": "a farm with a 20 m barn",
		"result": "VALID", "command": "CREATE_FARM",
		"source": {"source": "ai"}, "metrics": {}})
	records.append({"type": "understanding", "about": "ok0",
		"understanding": "CONFIRMED", "evidence": "SAID_SO", "strength": "strong"})
	for i in disputed:
		records.append({"time": "2026-10-08T09:00:2%d" % i, "id": "d%d" % i,
			"request": "a dungeon with a hall and a vault",
			"readback": "a dungeon entered through a 12 m hall",
			"result": "VALID", "command": "CREATE_DUNGEON",
			"source": {"source": "ai"}, "metrics": {}})
		records.append({"type": "understanding", "about": "d%d" % i,
			"understanding": "DISPUTED", "evidence": "SAID_SO", "strength": "strong"})
	records.append({"type": "session_event",
		"time": "2026-10-08T09:01:00", "event": "session_end"})
	return SessionReport.describe("tester", SessionReport.summarise(records))
