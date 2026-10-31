extends RefCounted
class_name Readback

# --- 003: what Genesis understood ---
# A one-line description of the command Genesis is about to carry out, in
# plain English, shown to the player before anything is built.
#
# THE RULE THAT MAKES THIS WORTH ANYTHING
# The readback is generated from the STRUCTURED COMMAND, never from what the
# player typed. A readback built from the player's own words would repeat
# their sentence back at them and confirm nothing: they would recognise their
# own request and agree with it, whatever Genesis had actually understood.
# Built from the command, it says what Genesis is really going to do, so when
# a word has been dropped the line visibly does not match what was asked.
#
# This is why a lost relationship is the thing it must show. Nobody mishears
# "farm". What goes missing is "inside", "around", "four", "bigger". So a
# plan reads out how its worlds are related, and when nothing relates them
# the readback says so plainly.
#
# A successful build is not evidence of understanding. This line is the only
# place a player can catch Genesis building the wrong thing correctly.

# This file depends on nothing. Composing a whole command's description
# needs the registry, and the registry needs the modules, which need these
# helpers - so that part lives in WorldRegistry.readback() and this stays a
# leaf. A cycle of class_name references is a parse error waiting to happen.

const MAX_LISTED := 6


# --- shared wording, so every world sounds like the same game ---

# "two 300 m straights", "a 200 m orchard": a count, a size, a thing.
static func count_of(count: int, singular: String, plural: String = "") -> String:
	var name := plural if plural != "" else singular + "s"
	match count:
		1:
			return article(singular)
		2:
			return "two " + name
		3:
			return "three " + name
		4:
			return "four " + name
		5:
			return "five " + name
		6:
			return "six " + name
	return "%d %s" % [count, name]


# A square thing is "200 m"; anything else is "200 by 150 m", because a
# player who asked for a long thin field needs to see it stayed long and thin.
static func size_of(width: float, depth: float) -> String:
	# A measurement that is not a number is left out, never printed as 0. A
	# readback that states a number the player never gave is trap 8, and it
	# reads perfectly fluently: "a 0 by 10 m barn" for a barn whose width was
	# the word "ten". The refusal names the field; this line does not invent
	# a value for it.
	if is_nan(width) or is_nan(depth):
		return ""
	if absf(width - depth) < 1.0:
		return "%.0f m" % width
	return "%.0f by %.0f m" % [width, depth]


# --- one reading, applied to a number that came out of a request ---
#
# Every number in a request arrives through JSON.parse, so it may be any type
# at all. "width": null, "width": {} and "width": [10, 10] are JSON the parser
# accepts and hands on unchanged, and a model writes all three: null for a
# field it has nothing to say about, an object or a list for one whose shape
# it has misunderstood.
#
# float() has no constructor for those. The call does not return a wrong
# number - it THROWS, and a throw inside a GDScript function abandons the rest
# of that function and leaves the caller holding whatever the variable was
# initialised to. So this fault is never visible as a bad measurement. It was
# visible as a validator that found nothing wrong with a room 0 m across
# (DungeonModule.validate returned ok=true, errors=[]), as a validate() that
# returned an empty dictionary with no "ok" in it at all when a door pair held
# an object, and as three world readbacks that returned the empty string.
#
# So the decision about whether a value out of a request IS a number is made
# here and nowhere else, and every reader of a raw request asks it.
#
# A string is not a number, even one that parses. float("10") is 10 and
# float("ten") is 0, so a reader that takes the first silently takes the
# second as a request for nothing: _side() accepted "10" as 10 m and refused
# "ten" as "width is 0 m". Every other validator in Genesis already refuses a
# string outright, and now this does too.
static func as_number(value: Variant) -> float:
	if typeof(value) != TYPE_FLOAT and typeof(value) != TYPE_INT:
		return NAN
	return float(value)


# The same decision, for a value behind a key. A key that is absent is not a
# number either, so a caller that only needs "is this usable" asks one
# question; a caller that must tell MISSING from NOT A NUMBER asks has() first,
# the way the validators do, because those are different sentences to a player.
static func measure(source: Dictionary, key: String) -> float:
	if not source.has(key):
		return NAN
	return as_number(source[key])


# --- 095: one reading, applied to the TEXT behind a key ---
#
# measure() above is this decision for a number. This is the same decision for
# a word, and it exists because Genesis had the number half and not the text
# half, so thirteen readers each decided for themselves what a value that was
# GIVEN and said NOTHING meant.
#
# There are three ways a text field can say nothing, and every reader in
# Genesis was reading at most two of them:
#
#   absent          a default stands in, which is what a default is for
#   ""              the empty string
#   "   "           whitespace, which some readers stripped and some did not
#   null            and this is the one that got through: str(null) in GDScript
#                   is the SIX-CHARACTER STRING "<null>", which is not empty,
#                   so a guard written `if label == ""` lets it past as a NAME.
#
# Measured in 095 by driving the validators, not by reading them (TRAPS 48):
# a dungeon whose room was named null validated ok=true and the room was KEPT
# as `<null>`; a thing named null was kept the same way while a thing named ""
# was correctly refused one branch above it; TrackBuilder.readback() said "to
# make corner 1 <null>"; and CommandParser's UNSUPPORTED reason came back
# blank or as `<null>`, which is 094's finding and the same rule one site
# along. Nothing in scripts/ or tests/ contained the substring "<null>" at
# all, so nothing could have noticed any of it.
#
# said() returns what the value actually SAYS - the text with its edges
# stripped - or "" when there is nothing there. Every site that already had a
# correct `== ""` branch then answers all four cases WITHOUT CHANGING ITS OWN
# POLICY, which is the reason this is one reader rather than a decision taken
# thirteen times (TRAPS 11).
static func said(source: Dictionary, key: String) -> String:
	if not source.has(key):
		return ""
	var got = source[key]
	if got == null:
		return ""
	return str(got).strip_edges()


# The same reading at a site whose answer to "it says nothing" is a word
# rather than a branch of its own.
#
# A value that DOES say something is returned AS IT WAS SENT, edges and all,
# and not as said() strips it: what a player asked for is not this function's
# to tidy, and every one of these sites is a readback, whose whole job is to
# show what was heard. So this changes exactly one thing - which values get
# the default - and nothing about the ones that do not.
static func said_or(source: Dictionary, key: String, fallback: String) -> String:
	if said(source, key) == "":
		return fallback
	return str(source[key])


# --- 096: the engine's own spelling of nothing, in a sentence a player reads
#          ---
#
# 095 closed the half of the says-nothing class where a value that says
# nothing was KEPT - as a room's name, a thing's name, a nickname, a
# difficulty - by answering all four forms in said() above. It MEASURED and
# deliberately left the other half: a value that is REFUSED either way, where
# the refusal QUOTES it back at the player. The reason it was left is in
# HANDOVER and it is a good one: at every one of those doors the empty string
# already gets a BETTER sentence than the quoting one, so routing them through
# said() would change WHICH SENTENCE FIRES on several doors at once, and a
# refusal's wording is the owner's (PROTOCOL 6).
#
# This is the other thing a quoting site can do, and it needs no decision at
# all. It changes the SPELLING and never the branch: every caller refuses,
# skips or keeps exactly what it refused, skipped or kept before. A null is
# said as "null" - which is the notation the model actually sent it in, since
# every one of these values arrives from JSON.parse - rather than as the
# engine's debug spelling.
#
# AND THE FIGURE THAT HAD BEEN WRONG SINCE 094, CORRECTED HERE AND IN ELEVEN
# OTHER PLACES: str(null) in GDScript is "<null>", which is SIX characters and
# not five. Measured with String(str(null)).length() rather than counted by
# eye. It changed no behaviour and it was in this file, in two code comments,
# in says_nothing_test and in both docs - TRAPS 14 in its smallest form, a
# figure nobody rechecked.
#
# A NULL NESTED INSIDE A CONTAINER IS THE SAME FAULT ONE LEVEL DOWN, which is
# why this answers the RENDERING and not only `value == null`: str([null]) is
# "[<null>]", and a quoting site handed an array reaches it. Measured, not
# assumed.
#
# WHAT IT COSTS, SAID RATHER THAN GLOSSED: a player who literally sends the
# six characters "<null>" as a word is quoted back "null" instead of their own
# six characters. Every request that reaches one of these doors is refused
# either way, so no world and no name is wrong; and "<null>" was never
# distinguishable from nothing in this engine's spelling to begin with. TRAPS 8
# says a readback does not tidy a player's words, and this is the one place it
# is knowingly traded against not handing a player a debug token.
const ENGINE_NOTHING := "<" + "null>"


static func spelled(value: Variant) -> String:
	if value == null:
		return "null"
	return str(value).replace(ENGINE_NOTHING, "null")


# --- 040: one reading of a reference by its POSITION in a list ---
#
# The prompt tells the model to name a piece of a world by its number,
# counting from 1, at five doors: a dungeon's door pairs, a thing's "in", an
# ORDER's "room", a SHUT or OPEN's "between", and a plan step's "around".
#
# A number counting from 1 is a WHOLE number. 2.9 is not the third room, and
# it is not the second one either. Four of those five doors took int() to it
# and carried on with room 2 IN SILENCE - a drop, which is worse than a
# refusal because a refusal is visible and a drop is not (TRAPS 31). The
# fifth, "around", refused it and named the range, because 036 was the one
# session that thought to ask. This is 036's answer, applied to the class
# (TRAPS 11), and it is also what Genesis says about itself in the prompt:
# "It REFUSES rather than clamping." Truncation is clamping, done quietly.
#
# Returns the index counting from 0, or -1 when the value cannot be used. In
# GDScript array[-1] is the LAST element, so every caller must treat -1 as a
# refusal and never as an index.
static func ordinal_index(value: Variant, count: int) -> int:
	var number := as_number(value)
	if is_nan(number) or number != floor(number):
		return -1
	var at := int(number)
	if at < 1 or at > count:
		return -1
	return at - 1


# Is this a number, but not a whole one? The one case the four doors had no
# sentence for. "Not a number at all" and "out of range" are different faults
# with sentences of their own at each door, so this answers only its own.
static func is_fraction(value: Variant) -> bool:
	var number := as_number(value)
	return not is_nan(number) and number != floor(number)


# A number out of a request, said back as the player wrote it. 1 is "1" and
# not "1.0": every number arrives from JSON.parse as a float, so a refusal
# that prints the raw value tells a player they wrote a decimal they did not
# write. TRAPS 10 and 23's family - a sentence stating something the request
# never said.
#
# 041: THIS IS THE ONE READING FOR EVERY DOOR THAT SAYS A REQUEST'S NUMBER
# BACK, not only the five reference doors 040 built it for. Eight other doors
# rendered the same number by hand - five validators, the boots consequence
# and this file's own `around` clause - and every one of them ROUNDED, which
# is how a refusal came to name a value inside the range it said the value
# was outside: "room 1: width is 40 m, and must be 4 to 40 m" for a width of
# 40.4. A refusal a player cannot act on (TRAPS 18) out of a fix that was
# written once and not carried to its class (TRAPS 11, 34).
#
# So the precision is FAITHFUL and not fixed. String.num(number, 2) was the
# 040 reading and it rounds: 1.504 came back as "1.50" against a bound
# printed "1.50". String.num(number, -1) says as many places as the number
# has, so what comes back is what was sent and the sentence cannot contradict
# itself. A BOUND is not said this way and must not be: a bound is a constant
# rendered at its own natural precision (TRAPS 28), which is why "0.40 to
# 1.50" keeps its places while the value between them is said exactly.
static func number_said(value: Variant) -> String:
	var number := as_number(value)
	if is_nan(number):
		return "nothing"
	if number == floor(number) and absf(number) < 1.0e15:
		return "%d" % int(number)
	return String.num(number, -1)


# What a legal reference by number would be, as a clause a refusal ends with.
# Written ONCE: five doors ask this question, and five hand-written copies
# diverge, with the one that diverges being the one nobody is reading
# (TRAPS 31, the rule 037's intent_problem() came out of).
static func whole_number_rule(noun: String, count: int) -> String:
	return "a %s number is a whole number, 1 to %d" % [noun, count]


# --- 113: a rule the PROMPT states, for a name two members cannot share ---
#
# DungeonModule refuses three name collisions and STATED one of them. The
# ROOM line said nothing about two rooms and the THING line nothing about two
# things, so a model asked for "a dungeon with two store rooms" earned a
# refusal for a rule it had never been given. This is that rule, and it is
# written ONCE because the same file states it at two doors: two hand-written
# copies diverge, and the one that diverges is the one nobody is reading
# (TRAPS 11, which is the rule member_error() below came out of, for the same
# two doors of the same file).
#
# THE REFUSAL IS A DIFFERENT SENTENCE AND STAYS WHERE IT FIRES. It names the
# offender - "thing 2: two things are both called 'key'" - and a rule cannot
# name one, so the two are deliberately NOT forced through one reading: they
# answer different questions for different readers. What is held in one place
# is the rule, across the two lines that state it.
#
# Takes the lists() entry rather than a noun, like list_rule() below, so the
# plural comes from the module's own declaration of that list.
static func unique_name_rule(entry: Dictionary) -> String:
	var many := str(entry.get("many", str(entry.get("key", "members"))))
	return "no two %s may have the same name" % many


# --- 044: the same reference, at the layer that SAYS it back ---
#
# ordinal_index() above is the validation layer's reading: it answers "which
# position is this, or is it none", and it returns a resolved INDEX or -1.
# A READBACK cannot use that answer at all. Its whole job is to show a player
# what Genesis heard so a dropped or misread clause is visible (TRAPS 8), so
# it must say the value the request CARRIED and never the thing that value
# resolves to. 040 carried ordinal_index() to all five reference doors and
# every one of those doors is a validator or a handler; the six readbacks
# beside them went on calling int() by hand, because the one reading's RETURN
# TYPE made it unusable where they stood. That is 043's question - can
# everything that needs this function reach it? - answered by the shape of
# the answer rather than by the scope of the file.
#
# What it cost, measured headless before anything was changed: "room": 2.9
# read back as "to send someone to room 2" next to a refusal reading "there
# is no room 2.9", and "room": 0.5 as "room 0", a room no dungeon has. Two
# sentences about one request, printed in the same exchange, disagreeing
# about the number - and the one the player is invited to check is the one
# that was wrong.
#
# So this is the readback's reading of the same fact: the noun and the value
# exactly as sent, through number_said() (041), whole or not, in range or
# not. It states no range and refuses nothing - the refusal beside it does
# both, and in its own words (TRAPS 34's rule that each door keeps its own
# locator sentence).
static func position_said(value: Variant, noun: String) -> String:
	return "%s %s" % [noun, number_said(value)]


# --- one reading, applied to the article in front of a name (TRAPS 10) ---
#
# "Got to the room 2." "Fetching the red key to the chamber 3." A numbered
# name is a LABEL, and a label takes no article. 019 found that, 022 found it
# again a release later in a second function, and the rule it produced is
# written about the thing that makes it true: the NUMBER on the end, not the
# word in front of it.
#
# NpcGoals._place() has carried that rule since 022 for the DEFINITE article.
# It was never asked of the indefinite one, and DungeonModule's readback puts
# "a" in front of a room's name and a thing's name - so a dungeon whose rooms
# the model called room_1..4 was read back as "entered through a room 1", and
# a key called key_2 as "a key 2". One fact, two renderings, and only one of
# them was being applied: TRAPS 10's own lesson, which is to delete every
# other way of saying it in the same breath.
#
# So the fact lives here, in the leaf both files already read, and `the` and
# `a` are two readers of it. An empty name is not a label; neither is a bare
# number, which has no name in front of it to label.
static func is_label(name: String) -> bool:
	var words := name.replace("_", " ").strip_edges().split(" ", false)
	if words.size() < 2:
		return false
	return str(words[words.size() - 1]).is_valid_int()


# 103: THE TWO READERS OF THE SAME FACT ANSWERED A WORD THAT SAYS NOTHING
# DIFFERENTLY. the() below has read `replace("_", " ").strip_edges()` before
# testing since 022, and is_label() has read it since 031; this one tested the
# raw string, so `article("   ")` returned "a    " - an article with nothing
# after it - where `the("   ")` returned "". Measured, and reachable: a room or
# a thing the model named "_" arrives here as a single space, because the two
# dungeon readback doors swap underscores for spaces before they test whether
# the name says anything (see DungeonModule).
#
# The EMPTINESS TEST is what moves and nothing else. A word that says something
# is returned AS SENT, not as strip_edges() would tidy it, so every rendering
# this function already produced is byte-identical - and the underscore swap is
# deliberately NOT done here, because article() is also handed section types
# like "left_hairpin", whose refusal wording is the owner's and is not this
# commit's to respell.
static func article(word: String) -> String:
	if word.strip_edges() == "":
		return ""
	if is_label(word):
		return word
	return ("an " if _takes_an(word) else "a ") + word


# The DEFINITE article, and the same reader of the same fact. 022 put this
# rule in NpcGoals._place(), which is a room-naming function in a dungeon
# file, so nothing else could reach it: the thing in "The key 2 is in the
# vault", the two room names in "there is no door between the room 1 and the
# room 2", and the room in "a lamp in the room 1" each wrote "the" by hand,
# in the very file whose own comment said there was no other way to name a
# room in it. "the" and "a" are now two readers of is_label() and nothing
# else writes either of them.
#
# An empty name has nothing to put an article in front of.
static func the(name: String) -> String:
	var said := name.replace("_", " ").strip_edges()
	if said == "":
		return ""
	if is_label(said):
		return said
	return "the " + said


# The same name at the start of a sentence. Godot's String.capitalize()
# title-cases every word ("The Red Key"), which is not this.
static func sentence_start(said: String) -> String:
	if said == "":
		return ""
	return said.substr(0, 1).to_upper() + said.substr(1)


# --- which article, decided by the SOUND and not by the letter ---
#
# TRAPS 10's rule is to write the rule about the thing that makes it true,
# and the thing that makes an article "an" is the sound the word starts
# with. This function tested the LETTER, which is the same mistake one level
# down: "a 8 m hall", "a 11 m vault", "a 80 by 20 m barn" - reachable in
# every dungeon readback through _room_said() and in every farm readback
# through count_of(), because a size is rendered in front of the name and a
# size starts with a digit.
#
# A leading 8 is always read "eight" something - 8, 80, 800, 8000 - so the
# digit alone decides it. "eleven" and "eighteen" survive only on a
# thousands boundary: 11 and 11000 take "an", while 110 is "one hundred ten"
# and 1100 is "one thousand one hundred" and both take "a".
#
# NOT FIXED, and deliberately: a word beginning with a LETTER is still
# decided by that letter, so "an hour" and "a unicorn" come out wrong. That
# needs how a word is pronounced, which Genesis does not have and will not
# get from a rule about spelling. The half that is a NUMBER is decided by
# arithmetic, which is why it is the half that is fixed here.
static func _takes_an(word: String) -> bool:
	var digits := ""
	for i in word.length():
		if not word[i].is_valid_int():
			break
		digits += word[i]
	if digits == "":
		return word[0] in ["a", "e", "i", "o", "u"]
	if digits[0] == "8":
		return true
	var head := digits.substr(0, 2)
	if head != "11" and head != "18":
		return false
	return (digits.length() - 2) % 3 == 0


# "a, b and c" - the list separator people actually read.
static func _join(parts: PackedStringArray, conjunction: String = "and") -> String:
	if parts.is_empty():
		return ""
	if parts.size() == 1:
		return parts[0]
	var head: Array = []
	for i in parts.size() - 1:
		head.append(parts[i])
	return ", ".join(head) + " %s " % conjunction + parts[parts.size() - 1]


static func join_list(parts: PackedStringArray) -> String:
	return _join(parts)


# "a, b or c" - the same list when the members are ALTERNATIVES rather than
# things that are all present. 035 needed it because the AI's prompt names a
# farm's crops that way, and the six names were typed out beside the six the
# validator accepts instead of being read from them.
static func join_or(parts: PackedStringArray) -> String:
	return _join(parts, "or")


# Long lists are cut short rather than printed in full: a readback nobody
# reads to the end cannot catch anything.
static func join_capped(parts: PackedStringArray) -> String:
	if parts.size() <= MAX_LISTED:
		return _join(parts)
	var shown := PackedStringArray()
	for i in MAX_LISTED:
		shown.append(parts[i])
	return _join(shown) + " and %d more" % (parts.size() - MAX_LISTED)


# --- 034: one reading, applied to a count and the noun after it ---
#
# "2 rooms need at least 1 doors to all be reachable (got 0)". The article
# rule (TRAPS 10, 23) said a fact about a WORD belongs in one function that
# every rendering reads; this is the same fact about the OTHER end of the
# noun. Nothing had ever asked what these sentences say when a count is one,
# because a person writing a test for a count writes two.
#
# count_of() above is the WORD form - "a door", "two doors" - which is what
# a readback wants. This is the DIGIT form, which is what a refusal and a
# measurement want, because "at least a door" is not a limit anybody can act
# on. Both read the same plural, so a noun with an irregular one is given
# once, here, at the call.
static func plural(count: int, singular: String, many: String = "") -> String:
	return "%d %s" % [count, agrees(count, singular, many if many != "" else singular + "s")]


# --- 042: the one reading is "IS THIS COUNT ONE", not "what is the plural" ---
#
# 034 put the plural in plural() and swept the validators. The sweep that
# went with it looks for "1 <word>s" in the output, which catches a count of
# ONE wearing a plural - and is blind by construction to the other half of
# the same fault, a count of TWO wearing a singular. That half was reachable
# on every circuit Genesis has ever built ("8  (4 straight, 4 corner, 0
# hairpin, 0 chicane)") and on any farm with two of a kind ("3  (2 orchard,
# 1 barn)"), because a panel that writes "%d %s" with a singular key is
# wrong at every count except one. TRAPS 6's shape at a correct assertion:
# the regex could not fail for half its class.
#
# And the agreement is not only the noun's. "understood: 100% of the 1 that
# bear on it" is the same single fact - count == 1 - decided a third time,
# by hand, at a VERB. So the fact lives here, plural() is one reader of it,
# and a verb or any other agreeing word is another. Anything that needs to
# know whether a count is one asks this and never writes the test again.
static func agrees(count: int, one: String, many: String) -> String:
	return one if count == 1 else many


# --- 034: a value out of a request, written back as the JSON it came as ---
#
# For the one job of showing a player an EXAMPLE of what a request should
# look like. The example is rendered from the real value the validator
# accepts, never typed out beside it, so the sentence cannot promise a shape
# the validator refuses - which is the whole fault 034 is about, one level
# up: a refusal that names no legal value is useless, and a refusal that
# names an illegal one is worse.
#
# JSON.stringify would do this, except that it prints 12.0 for a width a
# player would write as 12 and packs the separators, and this string is
# read by a person mid-refusal. Integral floats print as integers; nothing
# else about the value is changed.
static func as_json(value: Variant) -> String:
	match typeof(value):
		TYPE_DICTIONARY:
			var pairs := PackedStringArray()
			for key in (value as Dictionary):
				pairs.append("\"%s\": %s" % [str(key), as_json((value as Dictionary)[key])])
			return "{" + ", ".join(pairs) + "}"
		TYPE_ARRAY:
			var items := PackedStringArray()
			for item in (value as Array):
				items.append(as_json(item))
			return "[" + ", ".join(items) + "]"
		TYPE_NIL:
			return "null"
		TYPE_BOOL:
			return "true" if bool(value) else "false"
		TYPE_INT:
			return str(int(value))
		TYPE_FLOAT:
			var number := float(value)
			if is_finite(number) and is_equal_approx(number, roundf(number)):
				return str(int(roundf(number)))
			return str(number)
	return "\"%s\"" % str(value)


# --- 034: the sentence every list door is refused with ---
#
# TRAPS 21 one level up. 030 made every FIELD refusal name its limits through
# all three doors - out of range, not a number, missing. The LISTS those
# fields live in were never asked, and all six answered with four words:
# "rooms must be a list", "doors must be a list", "zones must be a list",
# "sections must be a list", "things must be a list", "a plan needs a list of
# steps". None names how many members are allowed, none shows what a member
# is, and `doors` is required with no default - so a dungeon described with
# no doors at all was refused with four words that name nothing to fix.
#
# Written here rather than in each validator for the reason _range_error()
# and around_of() are: six copies of a sentence diverge, and the one that
# diverges is the one nobody is reading. The bounds and the example come from
# the module's own lists() declaration, so a list whose limits change takes
# its refusal with it, and tests/container_door_test.gd builds a request out
# of those same examples and fails if the validator will not accept it.
static func list_error(entry: Dictionary) -> String:
	var key := str(entry.get("key", ""))
	var sample: Array = entry.get("sample", [])
	var shown := "" if sample.is_empty() else ", for example %s" % as_json([sample[0]])
	return "'%s' must be a list of %s%s" % [key, list_rule(entry), shown]


# --- 035: the same bound, said to the model instead of to the player ---
#
# list_error() tells a PLAYER how many members a list may hold, after the
# request was refused. This says the same thing to the MODEL, before it
# writes one, and it exists because the two had drifted: the AI's prompt
# said "Use 2 to 24 zones" while FarmModule.MIN_ZONES was 1 and had been
# since 003, which lowered it so that "build a farm with a barn" would stop
# being refused. The prompt then told the model not to send one. A bound
# stated narrower than the truth costs a player the request the bound was
# widened for - TRAPS 15's shape, in the prompt rather than in a limitation.
#
# So the sentence the model reads is now written from lists() too, by the
# same branch the refusal uses, and a world that moves a bound moves what
# the model is told along with what the player is refused. The wording is
# deliberately the refusal's: "2 to 24 rooms", "up to 48 doors".
static func list_rule(entry: Dictionary) -> String:
	var one := str(entry.get("one", str(entry.get("key", "item"))))
	var many := str(entry.get("many", ""))
	var low := int(entry.get("low", 0))
	var high := int(entry.get("high", 0))
	if low <= 0:
		return "up to %s" % plural(high, one, many)
	return "%d to %s" % [low, plural(high, one, many)]


# A member of one of those lists, refused on its own. The same example, from
# the same declaration, because "room 2 must be an object" and "'rooms' must
# be a list" are the same player not knowing the same thing. DungeonModule
# showed the shape for a thing and not for a room, in one function, which is
# TRAPS 11 inside a single file.
static func member_error(entry: Dictionary, n: int) -> String:
	var one := str(entry.get("one", "item"))
	var sample: Array = entry.get("sample", [])
	if sample.is_empty():
		return "%s %d is not what this list holds" % [one, n]
	var shape := str(entry.get("member", ""))
	if shape == "":
		shape = "a pair" if typeof(sample[0]) == TYPE_ARRAY else "an object"
	return "%s %d must be %s, for example %s" % [one, n, shape, as_json(sample[0])]


# --- 037: one reading, applied to the field the prompt asks for most ---
#
# "intent" is offered by SIX of the JSON skeletons in
# AIInterpreter.assembled_prompt() - every world and all three tools - which
# makes it the field the model is told to send more often than any other.
# Five doors refused a non-object one and named it; each wrote the sentence
# out by hand with its own example, which is the shape list_error() exists to
# stop. The sixth door, EQUIP, read the field NOWHERE AT ALL: not checked,
# not recorded, so a style the model sent exactly as instructed was dropped
# in silence and the measurements panel said "REQUESTED: not stated" for
# every tool ever asked for.
#
# So the question "is this an object" is asked here and nowhere else, and the
# example is rendered through as_json() from the real value, for the same
# reason member_error() renders its own: an example typed out beside a check
# is an example nothing checks.
#
# Returns "" when there is nothing wrong. An ABSENT intent is not wrong -
# every door has always treated it as optional, and the prompt says a request
# with no description uses "unspecified" rather than leaving the field out,
# which is advice to the model and not a rule Genesis enforces.
static func intent_problem(parameters: Dictionary, example: String) -> String:
	if not parameters.has("intent"):
		return ""
	if typeof(parameters["intent"]) == TYPE_DICTIONARY:
		return ""
	return "intent must be an object, for example %s" % as_json({"style": example})


# The same field, read for the RECORD rather than for the refusal. A
# non-object becomes {} - what WorldModule.record_fields() and
# RacingModule.record_fields() each did by hand - so every record in the
# ledger carries an object here and an auditor reading the file by field
# meets one shape. Both readers are now this one.
static func intent_of(parameters: Dictionary) -> Dictionary:
	var given = parameters.get("intent", {})
	return given if typeof(given) == TYPE_DICTIONARY else {}
