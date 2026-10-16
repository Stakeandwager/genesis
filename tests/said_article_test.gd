extends SceneTree

# --- 043: the article in front of a name, at the doors the one function never reached ---
#
# HANDOVER named the next assistant task as the audit 041 began and 042
# continued: for every fix in TRAPS, is the rule it produced applied
# everywhere it holds, or only where the fault was found? This is that
# question asked of TRAPS 10 and 23's rule - "a fact about a WORD lives in
# one function and every rendering reads it", put into Readback.is_label()
# and read by Readback.article() and NpcGoals._place() - and the answer is
# ONLY WHERE THE FAULT WAS FOUND, for the THIRD COMMIT RUNNING.
#
# Measured headless before anything was changed:
#
#   NpcGoals.readback, carry       "to have the key 2 carried to the vault"
#   NpcGoals.delivery_line x4      "The key 2 is in the vault."
#                                  "Cannot tell whether the key 2 got to ..."
#   NpcGoals.validate_door         "there is no door between the room 1
#                                   and the room 2"
#   DungeonModule._things_said     "... with a lamp in the room 1"
#   DungeonModule._room_said       "entered through a 12 m room 1"
#   GameController x2              "the key 2 is not in the world any more"
#   SectionValidator._forbid       "is not a uphill setting (a uphill has
#                                   length and grade)"
#
# The definite article had a function - NpcGoals._place() - and it was a
# ROOM-naming function in one file, so nothing else could read it. The file
# it lives in carried a comment reading "There is now no other way to name a
# room in this file", and validate_door's refusal two hundred lines above it
# named two rooms with a hand-written "the" (TRAPS 14: a claim about the
# code, unchecked).
#
# WHY NO SUITE SAW IT, which is the part worth keeping. log_022_test has
# asserted this exact rule on a dungeon readback since 031 - seven
# assertions - and every room it asks about has a width and depth of null.
# That is the ONE branch of _room_said() that calls article(); the branch
# beside it, the one every measured room takes, wrote "a" by hand. A correct
# assertion fed the one input that could not make it fail, which is 041's
# finding and 042's finding and now this one.
#
# AND THE ONE FUNCTION HAD THE FAULT AT ITS OWN EDGE, as 041's did.
# article() chose between "a" and "an" by the first LETTER, and TRAPS 10's
# own rule is to write the rule about the thing that makes it true - which
# is the SOUND. A size is rendered in front of a name, so "a 8 m hall", "a
# 11 m vault" and "a 80 by 20 m barn" are reachable in every dungeon
# readback and, through count_of(), in every farm readback.
#
# WHAT THIS SUITE ASSERTS, AND WHAT IT DOES NOT (TRAPS 6, TRAPS 14)
#
# FINDING, and the assertion that cannot be satisfied by rewording: every
# sentence that names a room or a thing contains that name EXACTLY as
# Readback.the() or Readback.article() renders it. Reword either function
# and this still passes; write an article by hand again and it fails.
#
# FINDING, two-directional, which is 042's lesson applied to this class: the
# same sentence is produced with a NUMBERED name and with an ORDINARY one,
# and it must drop the article for the first AND keep it for the second. A
# sweep for "the room 1" is blind to a dropped "the hall", and a function
# that returned the bare name always would pass a one-directional check.
#
# FINDING: which article a leading NUMBER takes, asserted as facts about
# English typed in here - 8, 11, 18, 80, 800, 11000 take "an"; 110, 180,
# 1100 take "a" - and not by re-reading the function under test.
#
# NOT ASSERTED. Nothing here has been near a model: every name was typed by
# hand. The two GameController sentences are reached through the function
# they were moved into and NOT through GameController, which is a Node3D no
# suite can instantiate - so what is checked is the sentence, not that the
# controller still calls it with the right thing. A word beginning with a
# LETTER is still decided by that letter, so "an hour" and "a unicorn" come
# out wrong and NOTHING HERE CLAIMS OTHERWISE: that needs pronunciation,
# which Genesis does not have. And this is the article; the plural on the
# other end of the noun is counted_said_test's.

const SPOKEN_AN := ["8", "11", "18", "80", "88", "800", "888", "8000", "11000", "18000"]
const SPOKEN_A := ["1", "2", "4", "7", "9", "10", "12", "20", "40", "110", "180", "1100", "1800", "110000"]

var failures: Array = []
var lines: Array = []
var said: Array = []        # every sentence this suite caused to be produced


func _check(ok: bool, what: String) -> void:
	if ok:
		lines.append("PASS  " + what)
	else:
		failures.append(what)
		lines.append("FAIL  " + what)


# Whole words, for 042's reason: "the hall" CONTAINS "hall", so a substring
# test cannot tell a dropped article from a kept one. See TRAPS 36.
func _says(text: String, phrase: String) -> bool:
	var re := RegEx.new()
	re.compile("(^|[^0-9A-Za-z_])%s([^0-9A-Za-z_]|$)" % phrase.replace(" ", "[ ]"))
	return re.search(text) != null


# The name appears EXACTLY as the one function renders it - which means the
# article it gives AND no article it does not.
#
# The first draft asserted only that the rendering appears in the sentence,
# and "a 12 m room 1" CONTAINS "12 m room 1", so the measured dungeon room -
# the fault this suite exists for - passed it. That is 042's substring
# blindness in a third costume: a check for what should be there cannot see
# what should not. Measured: the suite fails 27 times against the pre-043
# code with _named_as() and 15 times with _says() alone, so TWELVE
# assertions written to catch this fault passed against it.
func _named_as(text: String, want: String) -> bool:
	if not _says(text, want):
		return false
	if want.to_lower().begins_with("the ") or want.to_lower().begins_with("a ") \
			or want.to_lower().begins_with("an "):
		return true
	var stray := RegEx.new()
	stray.compile("\\b([Tt]he|[Aa]n?) %s\\b" % want.replace(" ", "[ ]"))
	return stray.search(text) == null


func _remember(texts) -> void:
	for t in texts:
		said.append(str(t))


func _initialize() -> void:
	_the_one_reading()
	_the_sound_not_the_letter()
	_an_errand()
	_a_dungeon_readback()
	_a_sections_refusal()
	_sweep()

	for line in lines:
		print(line)
	print("")
	print("SAID ARTICLE failures=%d" % failures.size())
	quit(1 if failures.size() > 0 else 0)


# --- the fact itself, and the two readers of it ---
func _the_one_reading() -> void:
	for label in ["room 2", "room_2", "chamber 3", "level 2", "key 2"]:
		_check(Readback.is_label(label), "'%s' is a label" % label)
	for name in ["vault", "large hall", "red key", "2", ""]:
		_check(not Readback.is_label(name), "'%s' is not a label" % name)

	# the() and article() are two readers of the same fact: whatever
	# is_label() says, BOTH must act on it, in both directions.
	for name in ["room_1", "chamber 3", "hall", "red key", "great hall"]:
		var plain := str(name).replace("_", " ")
		var definite := Readback.the(name)
		var indefinite := Readback.article(plain)
		if Readback.is_label(plain):
			_check(definite == plain, "the('%s') drops the article: '%s'" % [name, definite])
			_check(indefinite == plain, "article('%s') drops it too: '%s'" % [plain, indefinite])
		else:
			_check(definite == "the " + plain, "the('%s') keeps it: '%s'" % [name, definite])
			_check(indefinite.ends_with(plain) and indefinite != plain,
				"article('%s') keeps it: '%s'" % [plain, indefinite])
	_check(Readback.the("") == "", "the() has nothing to put an article in front of")
	_check(Readback.sentence_start("key 2") == "Key 2",
		"sentence_start raises the first letter only: '%s'" % Readback.sentence_start("key 2"))
	_check(Readback.sentence_start("the red key") == "The red key",
		"and not every word: '%s'" % Readback.sentence_start("the red key"))


# --- which article a number takes, as facts about English ---
#
# Typed in here rather than read from the function, so this fails if the
# function is rewritten to agree with itself.
func _the_sound_not_the_letter() -> void:
	for n in SPOKEN_AN:
		var got := Readback.article("%s m hall" % n)
		_check(got.begins_with("an "), "'%s m hall' is spoken with a vowel: '%s'" % [n, got])
		_remember([got])
	for n in SPOKEN_A:
		var got := Readback.article("%s m hall" % n)
		_check(got.begins_with("a ") and not got.begins_with("an "),
			"'%s m hall' is not: '%s'" % [n, got])
		_remember([got])
	# The letter half, unchanged and NOT claimed to be right.
	_check(Readback.article("orchard") == "an orchard", "a vowel letter still takes an")
	_check(Readback.article("barn") == "a barn", "a consonant still takes a")


# --- an errand, said with a numbered name and with an ordinary one ---
#
# Every sentence in the family, both ways. The pairs are built from the same
# call with only the name changed, so a function that always dropped the
# article would fail the second half.
func _an_errand() -> void:
	var pairs := [
		{"thing": "key_2", "room": "room_1", "labelled": true},
		{"thing": "red_key", "room": "vault", "labelled": false}]
	for entry in pairs:
		var case: Dictionary = entry
		var thing := str(case["thing"]).replace("_", " ")
		var room := str(case["room"]).replace("_", " ")
		var labelled: bool = case["labelled"]
		var want_thing := thing if labelled else "the " + thing
		var want_room := room if labelled else "the " + room

		var sentences := PackedStringArray([
			NpcGoals.readback({"goal": "carry", "thing": case["thing"], "room": case["room"]}),
			NpcGoals.delivery_line("DELIVERED", str(case["thing"]), str(case["room"]), ""),
			NpcGoals.delivery_line("NOT_DELIVERED", str(case["thing"]), str(case["room"]), ""),
			NpcGoals.delivery_line("NOT_DELIVERED", str(case["thing"]), str(case["room"]), str(case["room"])),
			NpcGoals.delivery_line("INCONCLUSIVE", str(case["thing"]), str(case["room"]), ""),
			NpcGoals.missing_thing_line(str(case["thing"]), "gone"),
			NpcGoals.missing_thing_line(str(case["thing"]), "roomless"),
			NpcGoals.outcome_line("ARRIVED", str(case["room"]), 10.0, 4.0),
			NpcGoals.door_readback({"between": [case["room"], "other"]}, true),
			NpcGoals.door_line({"a_name": case["room"], "b_name": "other"}, true, true)])
		_remember(sentences)
		for s in sentences:
			var text := str(s)
			if _says(text.to_lower(), thing):
				_check(_named_as(text, want_thing) or _named_as(text, Readback.sentence_start(want_thing)),
					"the thing is named as the() renders it ('%s'): %s" % [want_thing, text])
			if _says(text.to_lower(), room):
				_check(_named_as(text, want_room) or _named_as(text, Readback.sentence_start(want_room)),
					"the room is named as the() renders it ('%s'): %s" % [want_room, text])

	# The no-door refusal, which named two rooms at once and read neither
	# through _place().
	for entry in [{"names": ["room_1", "room_2"], "labelled": true},
			{"names": ["hall", "vault"], "labelled": false}]:
		var case: Dictionary = entry
		var rooms: Array = []
		for n in (case["names"] as Array):
			rooms.append({"name": n})
		var result := NpcGoals.validate_door(
			{"between": (case["names"] as Array).duplicate()}, rooms, {"doors": []})
		var text := ", ".join(PackedStringArray(result["errors"]))
		_remember([text])
		for n in (case["names"] as Array):
			var plain := str(n).replace("_", " ")
			var want := plain if bool(case["labelled"]) else "the " + plain
			_check(_named_as(text, want),
				"the no-door refusal names '%s' as the() renders it: %s" % [want, text])


# --- a dungeon readback, measured and unmeasured, numbered and named ---
#
# The unmeasured half is what log_022_test has always asked. The measured
# half is the one every real room takes and the one that was wrong.
func _a_dungeon_readback() -> void:
	var d := DungeonModule.new()
	for sized in [true, false]:
		for entry in [{"rooms": ["room_1", "room_2"], "thing": "key_2", "labelled": true},
				{"rooms": ["hall", "vault"], "thing": "red_key", "labelled": false}]:
			var case: Dictionary = entry
			var rooms: Array = []
			for n in (case["rooms"] as Array):
				rooms.append({"name": n, "width": 12 if sized else null, "depth": 12 if sized else null})
			var text := d.readback({"rooms": rooms, "doors": [[1, 2]],
				"things": [{"name": case["thing"], "in": 1}]})
			_remember([text])
			var labelled: bool = case["labelled"]
			for n in (case["rooms"] as Array):
				var plain := str(n).replace("_", " ")
				var body := ("12 m " + plain) if sized else plain
				var want := body if Readback.is_label(body) else Readback.article(body)
				_check(_named_as(text, want),
					"a %s room reads as article() renders it ('%s'): %s" % [
						"measured" if sized else "unmeasured", want, text])
			var thing := str(case["thing"]).replace("_", " ")
			var want_thing := thing if labelled else Readback.article(thing)
			_check(_named_as(text, want_thing),
				"the thing reads as article() renders it ('%s'): %s" % [want_thing, text])
			# And the room AFTER "in", which is the definite article in the
			# same sentence as the indefinite one.
			var first := str((case["rooms"] as Array)[0]).replace("_", " ")
			_check(_named_as(text, "in %s" % Readback.the(first)),
				"and the room it is in reads as the() renders it: %s" % text)

	# An 8 m room, which is the size the letter test got wrong.
	var eight := d.readback({"rooms": [{"name": "hall", "width": 8, "depth": 8}], "doors": []})
	_remember([eight])
	_check(_says(eight, "an 8 m hall"), "an 8 m room is spoken with a vowel: %s" % eight)


# --- the refusal that wrote "a" twice in one sentence ---
#
# Enumerated from SectionValidator.SECTION_TYPES, never typed in, so a type
# the owner opens is covered without editing this.
func _a_sections_refusal() -> void:
	for t in SectionValidator.SECTION_TYPES:
		var mine: Array = SectionValidator.FIELDS.get(t, [])
		var foreign := ""
		for type in SectionValidator.FIELDS:
			for key in (SectionValidator.FIELDS[type] as Array):
				if foreign == "" and not (key in mine):
					foreign = str(key)
		if foreign == "":
			continue
		var section := {"type": t, foreign: 10}
		for key in mine:
			section[key] = 10
		var result := SectionValidator.validate({"sections": [section]})
		var text := ", ".join(PackedStringArray(result.get("errors", [])))
		if not text.contains("setting"):
			continue
		_remember([text])
		_check(_named_as(text, "is not %s setting" % Readback.article(t)),
			"'%s' is refused with the article article() gives it: %s" % [t, text])


# --- the sweep, in BOTH directions, which is 042's lesson ---
#
# Every sentence this suite caused to be produced. One pass looks for an
# article in front of a numbered name; the other looks for a name that
# should have one and does not. A sweep for either alone is blind to half
# the class, which is exactly how 034's regex missed what 042 found.
func _sweep() -> void:
	var article_on_label := RegEx.new()
	# ONE word between the article and the number, deliberately. The first
	# draft allowed two and caught "a track needs 2 to 40 sections" ten
	# times over, because is_label() answers yes to "track needs 2" - the
	# rule is about a NAME and a regex cannot tell a name from a verb. One
	# word is the narrower claim and it is the one that is true.
	article_on_label.compile("\\b([Tt]he|[Aa]n?) ([a-z_]+) ([0-9]+)\\b")
	var caught: Array = []
	for sentence in said:
		for raw in str(sentence).split("\n"):
			var line := str(raw)
			var hit := article_on_label.search(line)
			if hit != null and Readback.is_label("%s %s" % [hit.get_string(2), hit.get_string(3)]):
				caught.append("\"%s\" in: %s" % [hit.get_string(), line])
	_check(caught.is_empty(), "no sentence puts an article in front of a numbered name%s" % (
		"" if caught.is_empty() else " - %s" % "; ".join(PackedStringArray(caught))))

	# The other direction: an ordinary name that LOST the article it should
	# have. A function that returned the bare name always would pass the
	# sweep above and fail this one, which is the point of having both -
	# 034's regex could see one direction and that is how 042's fault
	# survived it.
	#
	# A size sits between the article and the name ("an 8 m hall"), so the
	# measurement is allowed through; anything else is not.
	var dropped: Array = []
	for name in ["hall", "vault", "red key", "other"]:
		var has_article := RegEx.new()
		has_article.compile("\\b([Tt]he|[Aa]n?) (?:[0-9.]+(?: by [0-9.]+)? m )?%s\\b" % (
			name.replace(" ", "[ ]")))
		for sentence in said:
			var line := str(sentence)
			if not _says(line, name):
				continue
			if has_article.search(line) == null:
				dropped.append("'%s' bare in: %s" % [name, line])
	_check(dropped.is_empty(), "and no ordinary name loses the article it should have%s" % (
		"" if dropped.is_empty() else " - %s" % "; ".join(PackedStringArray(dropped))))
