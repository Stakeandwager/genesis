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
#
# --- 071: every name this suite was ever given had ONE word and a number ---
#
# HANDOVER's live entry said this suite's sweep "cannot see an article in
# front of a two-word numbered label" and asked for the pattern to be
# widened. Read off the file rather than taken from the entry (TRAPS 66),
# the pattern is \b([Tt]he|[Aa]n?) ([a-z_]+) ([0-9]+)\b - the entry quoted
# \b(The|A|An) and the code is case-folded in its first letter - and THE
# WIDENING IS THE WRONG FIX, for the reason the comment on that pattern
# already gave: with two words allowed it matches "a track needs 2 to 40
# sections", and is_label() cannot rule it out, because
# is_label("track needs 2") is TRUE. A regex over free text cannot tell a
# name from a verb. So the breadth was not widened; the sweep was moved
# onto the NAMES THE FIXTURES ACTUALLY USE (names_used below), which is
# TRAPS 59's rule - guard against the state, not against the spelling.
#
# WHAT THE BLIND SPOT WAS WORTH, measured before anything was changed.
# One character in Readback.is_label() - `words.size() < 2` to
# `words.size() != 2` - makes every multi-word numbered name take an
# article: the("great_hall_2") returns "the great hall 2", and one dungeon
# readback carries THREE of them. All 71 suites stayed green and the
# `--all` output was BYTE-IDENTICAL to the baseline. It is reachable, not
# hypothetical: DungeonModule.validate() lowercases and trims whatever
# name the model sent and stores it with no shape constraint, so a room
# called "great hall 2" validates ok, errors=[], and is read back verbatim.
#
# AND NOTHING IN scripts/ WAS WRONG. Every sentence family in this class
# was fed a multi-word numbered name before anything was touched and all of
# them were already correct, because all of them already read
# Readback.the() or article(). This commit changed no file in scripts/. The
# fault it closes is one that could be INTRODUCED without any suite saying
# so, which is a claim about the guard and not about Genesis.
#
# THE SAME LIST LIVED IN TWO SUITES (TRAPS 11). log_022_test holds the
# is_label fact too, with the same shape of list, and the same one-character
# fault passed it. Both are fixed.

# 103: the three article words, typed in as a fact about English rather than
# read out of Readback. Two of 103's own new assertions passed an injected
# fault because they were built from the same constant they were holding, and
# these are what replaced the circular half of them (TRAPS 6).
const ARTICLE_WORDS := ["a", "an", "the"]

const SPOKEN_AN := ["8", "11", "18", "80", "88", "800", "888", "8000", "11000", "18000"]
const SPOKEN_A := ["1", "2", "4", "7", "9", "10", "12", "20", "40", "110", "180", "1100", "1800", "110000"]

var failures: Array = []
var asserted := 0
var lines: Array = []
var said: Array = []        # every sentence this suite caused to be produced

# 071: every NAME this suite put into play, in the form a sentence renders it
# (underscores already spaces). The sweep below reads this instead of a list
# typed into it: a name added to a fixture is swept without anybody
# remembering to add it in a second place, which is the half of TRAPS 59 a
# regex cannot do - "guard against the state, not against the spelling".
var names_used: Dictionary = {}


func _check(ok: bool, what: String) -> void:
	asserted += 1
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


# 071: every position in `line` where `name` stands as a whole word AND is
# not part of a longer name the suite also put into play.
#
# The containment matters as soon as a fixture uses a multi-word name:
# "great hall 2" contains "hall", and _says() finds it there because " hall
# " has a boundary either side - so checking "hall" for a dropped article in
# a sentence that says "12 m great hall 2" would report a fault that is not
# one. Done PER OCCURRENCE rather than per line, deliberately: a sentence
# that says both "the hall" and "great hall 2" must still fail on the first,
# and a per-line skip would hide it.
func _occurrences(line: String, name: String) -> Array:
	var out: Array = []
	var find := RegEx.new()
	find.compile("(^|[^0-9A-Za-z_])(%s)([^0-9A-Za-z_]|$)" % name.replace(" ", "[ ]"))
	var from := 0
	while from <= line.length():
		var hit := find.search(line, from)
		if hit == null:
			break
		var at := hit.get_start(2)
		from = maxi(at + 1, hit.get_end(2))
		if not _inside_longer(line, at, name):
			out.append(at)
	return out


# Is the occurrence of `name` at `at` the inside of a longer registered
# name standing at the position that would put it there?
func _inside_longer(line: String, at: int, name: String) -> bool:
	for key in names_used:
		var other := str(key)
		if other.length() <= name.length() or not other.contains(name):
			continue
		var offset := other.find(name)
		var start := at - offset
		if start < 0 or start + other.length() > line.length():
			continue
		if line.substr(start, other.length()) == other:
			return true
	return false


func _remember(texts) -> void:
	for t in texts:
		said.append(str(t))


# Register a name the suite is about to put into a sentence, and hand it
# back unchanged so a call site reads as it did before. The PLAIN form is
# what gets stored, because that is the form a sentence carries.
func _use(raw) -> String:
	var plain := str(raw).replace("_", " ").strip_edges()
	if plain != "":
		names_used[plain] = true
	return str(raw)


func _initialize() -> void:
	_the_one_reading()
	_the_sound_not_the_letter()
	_an_errand()
	_a_dungeon_readback()
	# 103: both of these run BEFORE _sweep(), because they add sentences and
	# names to the collections the sweep reads. A section added after it would
	# be swept by nothing and would look exactly like one that was.
	_the_hub_clause()
	_a_room_nobody_named()
	_a_sections_refusal()
	_sweep()

	for line in lines:
		print(line)
	print("")
	print("SAID ARTICLE %d assertions, failures=%d" % [asserted, failures.size()])
	quit(1 if failures.size() > 0 else 0)


# --- the fact itself, and the two readers of it ---
func _the_one_reading() -> void:
	# 071: A LABEL IS A NAME WHOSE LAST WORD IS A NUMBER, and nothing in
	# is_label() says how many words come before it. Every member this list
	# used to hold had exactly ONE, so narrowing the function from
	# `words.size() < 2` to `words.size() != 2` - one character - left all
	# 71 suites byte-identical while the("great_hall_2") came back "the
	# great hall 2" and one dungeon readback carried THREE articles in front
	# of numbered names. Measured, not reasoned about.
	#
	# It is reachable: DungeonModule.validate() lowercases and trims
	# whatever name the model sent and stores it with NO shape constraint,
	# so a room called "great hall 2" - with real spaces - validates ok,
	# errors=[], and is rendered to the player verbatim. Both spellings are
	# here because the validator accepts both.
	for label in ["room 2", "room_2", "chamber 3", "level 2", "key 2",
			"great hall 2", "great_hall_2", "spare key 2", "small_vault_3",
			"the long hall 12"]:
		_check(Readback.is_label(label), "'%s' is a label" % label)
	# A number anywhere but the END does not make a label, however many
	# words are in front of it.
	for name in ["vault", "large hall", "red key", "2", "",
			"great hall", "spare key", "hall 2 a", "room 2 exit"]:
		_check(not Readback.is_label(name), "'%s' is not a label" % name)

	# the() and article() are two readers of the same fact: whatever
	# is_label() says, BOTH must act on it, in both directions.
	# 071: the multi-word labels are in here too, because the() and
	# article() are the two readers that a narrowed is_label() makes wrong,
	# and "great hall" (not a label) sits beside "great hall 2" (a label)
	# so the pair cannot both pass by accident.
	for name in ["room_1", "chamber 3", "hall", "red key", "great hall",
			"great_hall_2", "great hall 2", "spare_key_2", "small vault 3"]:
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
	# 071: the third pair is the member the first two were standing in for -
	# a numbered name of MORE THAN ONE WORD, in the underscored spelling and
	# (below) in the real-space spelling, both of which
	# DungeonModule.validate() accepts and stores verbatim. Nothing in this
	# family needed changing for it: every one of these sentences already
	# reads Readback.the(). What needed changing was that no fixture had
	# ever handed them one.
	var pairs := [
		{"thing": "key_2", "room": "room_1", "labelled": true},
		{"thing": "red_key", "room": "vault", "labelled": false},
		{"thing": "spare_key_2", "room": "great_hall_2", "labelled": true},
		{"thing": "spare key 2", "room": "great hall 2", "labelled": true}]
	for entry in pairs:
		var case: Dictionary = entry
		var thing := _use(str(case["thing"]).replace("_", " "))
		var room := _use(str(case["room"]).replace("_", " "))
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
			NpcGoals.door_readback({"between": [case["room"], _use("other")]}, true),
			NpcGoals.door_line({"a_name": case["room"], "b_name": _use("other")}, true, true)])
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
			{"names": ["hall", "vault"], "labelled": false},
			{"names": ["great_hall_2", "small vault 3"], "labelled": true}]:
		var case: Dictionary = entry
		var rooms: Array = []
		for n in (case["names"] as Array):
			_use(n)
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
		# 071: the third case is a MULTI-WORD numbered room and thing, and
		# the fourth is the same names spelled with real spaces, which is
		# how DungeonModule.validate() stores them when the model sends
		# them that way. The measured half matters most: a size is rendered
		# in front of the name ("12 m great hall 2"), which is the shape
		# that hides an article from a pattern anchored on the name.
		for entry in [{"rooms": ["room_1", "room_2"], "thing": "key_2", "labelled": true},
				{"rooms": ["hall", "vault"], "thing": "red_key", "labelled": false},
				{"rooms": ["great_hall_2", "small_vault_3"], "thing": "spare_key_2", "labelled": true},
				{"rooms": ["great hall 2", "small vault 3"], "thing": "spare key 2", "labelled": true}]:
			var case: Dictionary = entry
			var rooms: Array = []
			for n in (case["rooms"] as Array):
				_use(n)
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
			var thing := _use(str(case["thing"]).replace("_", " "))
			var want_thing := thing if labelled else Readback.article(thing)
			_check(_named_as(text, want_thing),
				"the thing reads as article() renders it ('%s'): %s" % [want_thing, text])
			# And the room AFTER "in", which is the definite article in the
			# same sentence as the indefinite one.
			var first := str((case["rooms"] as Array)[0]).replace("_", " ")
			_check(_named_as(text, "in %s" % Readback.the(first)),
				"and the room it is in reads as the() renders it: %s" % text)

	# An 8 m room, which is the size the letter test got wrong.
	var eight := d.readback({"rooms": [{"name": _use("hall"), "width": 8, "depth": 8}], "doors": []})
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

	# --- 071: the same two directions, asked of THE NAMES IN PLAY ---
	#
	# The pattern above guesses what a name looks like, and the guess is
	# "one word then a number". That is why it cannot see "the great hall
	# 2", and it is why widening it is not the fix: with two words allowed
	# it matches "a track needs 2 to 40 sections", and is_label() cannot
	# save it, because is_label("track needs 2") is TRUE. A regex over
	# free text cannot tell a name from a verb, so no amount of widening
	# makes it the right instrument.
	#
	# These two loops read names_used instead - every name a fixture
	# actually handed to a sentence - so nothing has to be guessed and
	# nothing has to be typed in twice. TRAPS 59: guard against the state,
	# not against the spelling. The pattern stays above it as the backstop
	# for a numbered name no fixture registered.
	#
	# A size sits between the article and the name ("an 8 m hall"), so the
	# measurement is allowed through in both directions; anything else is
	# not.
	# Anchored at the END of the text in FRONT of the name, so what is read
	# is the article immediately before this occurrence and not one
	# somewhere else in the sentence.
	var leading := RegEx.new()
	leading.compile("\\b([Tt]he|[Aa]n?) (?:[0-9.]+(?: by [0-9.]+)? m )?$")
	var on_label: Array = []
	var dropped: Array = []
	for key in names_used:
		var name := str(key)
		var is_label: bool = Readback.is_label(name)
		for sentence in said:
			for raw in str(sentence).split("\n"):
				var line := str(raw)
				for at in _occurrences(line, name):
					var has := leading.search(line.substr(0, at)) != null
					if is_label and has:
						on_label.append("'%s' in: %s" % [name, line])
					elif not is_label and not has:
						dropped.append("'%s' bare in: %s" % [name, line])
	_check(on_label.is_empty(),
		"no sentence puts an article in front of any numbered name it was given%s" % (
			"" if on_label.is_empty() else " - %s" % "; ".join(PackedStringArray(on_label))))
	_check(dropped.is_empty(), "and no ordinary name loses the article it should have%s" % (
		"" if dropped.is_empty() else " - %s" % "; ".join(PackedStringArray(dropped))))

	# --- 103: TWO ARTICLES IN A ROW, over every sentence collected ---
	#
	# The two loops above read names_used, so they can only see a doubled
	# article in front of a name a fixture registered. 095's fallback for a
	# room nobody named was "a room" - the article inside the word - and the
	# two sentences that render a room through a reader said it twice:
	# "entered through a 10 m a room" and "with a lamp in the a room". Neither
	# loop above could see it, because the name in play was the fallback and
	# no fixture registers that.
	#
	# This is the narrower, more general question and it needs no name at all:
	# an article immediately followed by another article is wrong in English
	# wherever it appears. The words are typed in here as a fact (ARTICLE_WORDS)
	# and not read out of Readback, which is what makes this hold a fallback
	# built out of the same function.
	# A SIZE MAY SIT BETWEEN THE TWO, which the first draft of this screen did
	# not allow - and that draft failed its own probe below, which is how it
	# was found rather than shipped. "entered through a 10 m a room" is the
	# MEASURED half of the fault and its two articles are four words apart, so
	# the optional size is read here exactly as the leading-article loop above
	# reads it.
	var doubled: Array = []
	var pair := RegEx.new()
	pair.compile("\\b(a|an|the) (?:[0-9.]+(?: by [0-9.]+)? m )?(a|an|the)\\b")
	for sentence in said:
		for raw in str(sentence).split("\n"):
			var line := str(raw)
			var hit := pair.search(line.to_lower())
			if hit != null:
				doubled.append("\"%s\" in: %s" % [hit.get_string(), line])
	_check(doubled.is_empty(), "no sentence says two articles in a row%s" % (
		"" if doubled.is_empty() else " - %s" % "; ".join(PackedStringArray(doubled))))
	# And the fact the screen rests on, so a regex that stopped matching
	# anything cannot pass as an absence (TRAPS 78).
	for measured in ["entered through a 10 m a room", "with a lamp in the a room",
			"along with a 80 by 20 m a room"]:
		_check(pair.search(measured) != null,
			"the two-article screen matches a sentence 095's fallback produced: %s" % measured)
	for word in ARTICLE_WORDS:
		_check(pair.search("%s %s x" % [word, word]) != null,
			"and it matches '%s %s'" % [word, word])
	# And the other direction, so a screen that matched everything would be
	# caught too: a size after ONE article is ordinary and must not match.
	for sound in ["entered through a 10 m hall", "with a lamp in the vault",
			"a dungeon of a room joined by 0 doors"]:
		_check(pair.search(sound) == null,
			"and it leaves an ordinary sentence alone: %s" % sound)

	# ANTI-VACUITY, because both loops above are over a collection the
	# suite fills itself: an empty names_used would pass them silently,
	# which is 067's lesson about a scan whose class comes from the thing
	# it is checking. Pinned to the shapes that must be in there, not to a
	# count that drifts: at least one multi-word numbered name, at least
	# one one-word numbered name, and at least one ordinary name.
	var shapes := {"multi_label": false, "one_label": false, "ordinary": false}
	for key in names_used:
		var name := str(key)
		var words := name.split(" ", false).size()
		if Readback.is_label(name):
			shapes["multi_label"] = bool(shapes["multi_label"]) or words > 2
			shapes["one_label"] = bool(shapes["one_label"]) or words == 2
		else:
			shapes["ordinary"] = true
	for shape in shapes:
		_check(bool(shapes[shape]),
			"the sweep was given a %s name to sweep (%d names in play)" % [
				shape, names_used.size()])


# --- 103: the two renderings of a room's name this suite could not produce ---
#
# 043 built this file to ask TRAPS 10 and 23's question - is the article in
# ONE function, and does every sentence read it - and answered it for the
# dungeon readback with a two-room, one-door fixture. That fixture is a
# CHAIN, and readback()'s hub clause only exists for a dungeon where one room
# carries most of the doors, so the sentence ", with five rooms off <name>"
# was never produced here at all. It named its room RAW. Measured on 102's
# code, before anything was changed:
#
#   with five rooms off vault          (a real name, no article)
#   with five rooms off a room         (the 095 fallback, article inside it)
#
# and the fallback was a NOUN PHRASE WITH THE ARTICLE IN IT, so the two
# sentences that DO read a function said it twice: "entered through a 10 m a
# room" and "with a lamp in the a room". Every one of those is reachable with
# a room name of plain `null`, which is one of the four forms 095 was written
# for. TRAPS 6 in this suite's own shape: the assertions were right and the
# fixture could not make them fail.
#
# WHAT THESE TWO SECTIONS ASSERT
#  - the hub room is named exactly as Readback.the() renders it, both
#    directions, numbered name and ordinary one, like every other room here.
#  - a room the request did not name reads EXACTLY as it would if the player
#    had written the fallback noun himself. That is the assertion that cannot
#    be satisfied by rewording: whatever word DungeonModule.UNNAMED_ROOM
#    holds, the nameless room must go through the same one reader as any other
#    name, so the article is applied once. Reword the fallback and this still
#    passes; put an article back inside it and all five forms fail.
#
# NOT ASSERTED. The fallback WORD is the owner's and nothing here has an
# opinion on it. And the new sentences are handed to _remember() but the
# fallback noun is deliberately NOT registered in names_used: "room" is an
# ordinary English word in sentences this suite already collects - "is not in
# any room" - and the sweep's dropped-article loop would read those as a name
# with its article missing. The equality below is the stronger check anyway,
# because it holds the whole sentence rather than one word of it.
func _the_hub_clause() -> void:
	# The hub must not be room 1: when it is, the clause says "off it" and
	# names nothing, which is the branch that was already right.
	for hub_name in ["vault", "vault_2", "great_vault_3"]:
		var rooms: Array = [{"name": _use("entrance"), "width": 10, "depth": 10}]
		rooms.append({"name": _use(hub_name), "width": 9, "depth": 9})
		for i in range(2, 6):
			rooms.append({"name": _use("r%d" % i), "width": 8, "depth": 8})
		var doors: Array = [[2, 1], [2, 3], [2, 4], [2, 5], [2, 6]]
		var text := DungeonModule.new().readback({"rooms": rooms, "doors": doors})
		_remember([text])
		var plain := str(hub_name).replace("_", " ")
		var want := plain if Readback.is_label(plain) else Readback.the(plain)
		_check(_says(text, "rooms off %s" % want),
			"the hub room is named as the() renders it ('off %s'): %s" % [want, text])
		_check(_named_as(text, want),
			"and it carries no second article of its own ('%s'): %s" % [want, text])


func _a_room_nobody_named() -> void:
	var d := DungeonModule.new()
	var noun: String = DungeonModule.UNNAMED_ROOM
	_check(noun.strip_edges() != "", "the fallback for a room nobody named says something")
	# THE ARTICLE IS NOT IN THE WORD. Asserted against the three article words
	# typed in here as a fact about English, and NOT by re-reading the function
	# under test: the equality below compares two sentences built from this same
	# constant, so with "a room" back in it BOTH sides double the article and
	# the equality is satisfied by the fault. That is TRAPS 6 in an assertion
	# written to catch this very thing, found by injecting it.
	_check(not str(noun.strip_edges().split(" ", false)[0]).to_lower() in ARTICLE_WORDS,
		"and the article is not inside it ('%s' begins a sentence as '%s')" % [
			noun, Readback.article(noun)])

	# Absent, null, "", whitespace, and a name that becomes whitespace once the
	# underscores the format asks for are spelled as spaces. The last is the
	# one that reached Readback.article() as " " and read back as "a 10 m  ".
	var forms: Array = ["ABSENT", null, "", "   ", "_", "__", " _ "]
	for sized in [true, false]:
		var side = 10 if sized else null
		for form in forms:
			var room := {"width": side, "depth": side}
			if str(form) != "ABSENT":
				room["name"] = form
			var thing := {"name": "lamp", "in": 1}
			var asked := {"rooms": [room], "doors": [], "things": [thing]}
			var text := d.readback(asked)
			var named := {"rooms": [{"name": noun, "width": side, "depth": side}],
				"doors": [], "things": [thing]}
			var want := d.readback(named)
			_remember([text])
			_check(text == want,
				"a %s room named %s reads as one the player called '%s' would: '%s' vs '%s'" % [
					"measured" if sized else "unmeasured",
					"ABSENT" if str(form) == "ABSENT" else "'%s'" % str(form),
					noun, text, want])
			# And the thing's room is the same name through the OTHER reader,
			# which is where the doubled definite article showed.
			_check(_says(text, "in %s" % Readback.the(noun)),
				"and the thing's room reads as the() renders it ('in %s'): %s" % [
					Readback.the(noun), text])

	# --- 103: the EDGES of a name that does say something ---
	#
	# A SECOND, SMALLER CHANGE FELL OUT OF READING THE NAME IN ONE PLACE, and
	# it is asserted here rather than only recorded. 095's said_or() returned a
	# value that says something AS IT WAS SENT, edges and all, on the principle
	# that a readback does not tidy a player's words - and the edges are not the
	# player's words, they are whitespace. MEASURED on 102: a room called
	# " hall " read back as "entered through a 10 m  hall ", with the padding
	# inside the sentence and the comma pushed out. It now reads exactly as the
	# same name without the padding, which is what _room_name() stripping
	# before the emptiness test gives for free.
	#
	# The INSIDE of a name is untouched - "great  hall" keeps its double space,
	# because that IS the player's spelling and this function has no business
	# with it. Driven, not argued: the pair below would fail if the strip were
	# applied to the whole string.
	for padded in [" hall ", "  hall", "hall  ", " room_1 "]:
		var plain := str(padded).strip_edges()
		var with_pad := d.readback({"rooms": [{"name": padded, "width": 10, "depth": 10}],
			"doors": []})
		var without := d.readback({"rooms": [{"name": plain, "width": 10, "depth": 10}],
			"doors": []})
		_remember([with_pad])
		_check(with_pad == without,
			"a room called '%s' reads exactly as one called '%s': '%s' vs '%s'" % [
				padded, plain, with_pad, without])
	# Registered with _use(), like every other name a fixture puts into play:
	# the sweep below skips an occurrence of "hall" that is the inside of a
	# LONGER registered name, and without this the inner "hall" of "great  hall"
	# reads as an ordinary name with its article missing. Found by running it.
	var inner := d.readback({"rooms": [{"name": _use("great  hall"), "width": 10, "depth": 10}],
		"doors": []})
	_remember([inner])
	_check(inner.contains("great  hall"),
		"and the double space INSIDE a name is the player's spelling and is kept: %s" % inner)

	# --- and the THING's own name, which is the same two readings in the
	#     other door of the same function ---
	#
	# _things_said() swaps underscores for spaces and then asks whether the
	# name says anything, in that order, so a thing named "_" was a single
	# space, was not skipped, and read back as ", with a   in the hall" - an
	# article, three spaces, and the room it is in. Its own comment says the
	# policy is that a name saying nothing is skipped exactly as an empty one
	# is, so the assertion is that EQUALITY: a thing whose name says nothing
	# leaves the sentence the dungeon would have had with no thing at all.
	var bare := d.readback({"rooms": [{"name": "hall", "width": 10, "depth": 10}],
		"doors": [], "things": []})
	_remember([bare])
	for form in ["ABSENT", null, "", "   ", "_", "__", " _ "]:
		var thing_said := {}
		if str(form) != "ABSENT":
			thing_said["name"] = form
		thing_said["in"] = 1
		var text := d.readback({"rooms": [{"name": "hall", "width": 10, "depth": 10}],
			"doors": [], "things": [thing_said]})
		_remember([text])
		_check(text == bare,
			"a thing named %s is left out of the sentence, as an empty name is: '%s' vs '%s'" % [
				"ABSENT" if str(form) == "ABSENT" else "'%s'" % str(form), text, bare])
