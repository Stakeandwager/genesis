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


static func article(word: String) -> String:
	if word == "":
		return ""
	if is_label(word):
		return word
	return ("an " if word[0] in ["a", "e", "i", "o", "u"] else "a ") + word


# "a, b and c" - the list separator people actually read.
static func _join(parts: PackedStringArray) -> String:
	if parts.is_empty():
		return ""
	if parts.size() == 1:
		return parts[0]
	var head: Array = []
	for i in parts.size() - 1:
		head.append(parts[i])
	return ", ".join(head) + " and " + parts[parts.size() - 1]


static func join_list(parts: PackedStringArray) -> String:
	return _join(parts)


# Long lists are cut short rather than printed in full: a readback nobody
# reads to the end cannot catch anything.
static func join_capped(parts: PackedStringArray) -> String:
	if parts.size() <= MAX_LISTED:
		return _join(parts)
	var shown := PackedStringArray()
	for i in MAX_LISTED:
		shown.append(parts[i])
	return _join(shown) + " and %d more" % (parts.size() - MAX_LISTED)
