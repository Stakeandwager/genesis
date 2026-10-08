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
	if absf(width - depth) < 1.0:
		return "%.0f m" % width
	return "%.0f by %.0f m" % [width, depth]


static func article(word: String) -> String:
	if word == "":
		return ""
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
