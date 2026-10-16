extends RefCounted
class_name RefusalCheck

# --- 023: the one command nothing was ever checking ---
#
# Every other command Genesis can receive goes through a wall. A world is
# validated against its module, a tool against its bounds, an order against
# the rooms that exist, a plan against whether the outer world can hold the
# inner one. UNSUPPORTED went through nothing at all: the AI wrote a sentence
# and Genesis printed it, word for word, to the player.
#
# WHY THAT MATTERS, AND WHY IT IS NOT A SMALL THING
# A refusal is a CLAIM ABOUT GENESIS. "this game does not include a physics
# engine", "the game only supports static world generation without history
# tracking", "it cannot provide verification of world-state attributes" - all
# three were printed to the owner, unchallenged, in one session, and all three
# are false. Genesis moves bodies with forces, keeps a ledger on disk, and
# verifies deliveries by reading the world. Those are not features it hopes
# to have; they are the features it exists for.
#
# This is the mirror of the failure the whole project is built against. A
# false success says a thing happened that did not. A false refusal says a
# thing is impossible that is not. Both are the system lying about itself, and
# the second one is cheaper to produce, because nothing was checking.
#
# WHAT THIS DOES, AND WHAT IT DELIBERATELY DOES NOT DO
# It reads a refusal's stated reason and, when that reason denies something
# from the list below, says so to the player and writes a note in the record.
#
# It does NOT overturn the refusal, build anything, or change a verdict, and
# it is counted in no rate anywhere. That restraint is the design, not
# timidity: this is phrase matching, and 022 and 023 are two consecutive
# sessions in which phrase matching on a tester's English produced confident
# nonsense. So the cost of a wrong flag here is a sentence the player can
# disagree with, and nothing else. A note that might be wrong is worth having;
# a verdict that might be wrong is not.
#
# ONE READING
# Each capability names the function that makes it true. If that function is
# ever deleted, the test asserts the claim goes with it, so this list cannot
# drift into claiming things Genesis has stopped doing - the same rule the
# readbacks live under.

# --- how a denial is recognised ---
#
# The obvious design is a list of phrases to look for, and it was the first
# one here. It missed three of the six real refusals, because a model does not
# deny one thing at a time. It writes a LIST under one negation:
#
#   "does not support automated NPC task sequences, autonomous door
#    unlocking, or external status verification"
#   "only supports static world generation without autonomous NPC
#    simulation, complex scripting, or history tracking"
#
# The negation is at the front and the capability is three items later, so no
# phrase like "does not verify" ever appears. What is actually being looked
# for is a NEGATION FRAME followed, in the same sentence, by a word naming
# something Genesis does.
#
# Order matters and is the reason this stays reasonably quiet: the negation
# must come BEFORE the capability word. "verification of two NPCs is not
# possible" is an honest refusal about the one character, and the negation
# arrives after the word, so it is left alone.
const NEGATIONS := [
	"not", "no ", "none", "never", "cannot", "cant", "unable", "lacks",
	"lack of", "without", "only supports", "only builds", "limited to",
	"does nt", "doesnt", "unsupported", "missing",
]

# --- when a denial is about NUMBER, it is probably honest ---
#
# Every real limit Genesis has is a limit of number. ONE character. ONE order
# at a time. ONE set of equipment. So a refusal that turns on a quantity is
# usually telling the truth even when it names something Genesis does:
#
#   "there is no second character to route"        - honest, and routing exists
#   "no way to simulate two NPCs at once"          - honest, and physics exists
#   "two cars cannot be compared side by side"     - honest
#
# Each of those would otherwise be flagged, and a flag on an honest refusal is
# noise, and noise is how a warning stops being read. So a sentence carrying
# one of these is left alone. The cost is that a refusal could hide a real
# understatement behind the word "two"; that is the right way round, because
# the player still has the refusal itself in front of them.
const ABOUT_NUMBER := [
	"two", "three", "second", "both", "multiple", "several", "each other",
	"at once", "simultaneously", "side by side", "more than one",
	"concurrent", "in parallel", "separate characters", "another character",
]

# Each entry: what Genesis does, the words that name it, the phrases that deny
# it outright with no frame needed, and what the player is told.
const CAPABILITIES := [
	{
		"name": "measurement and physics",
		"words": [
			"physics", "physics engine", "simulate", "simulation",
			"measure", "measurement", "measured", "model the",
		],
		"denials": ["static world generation"],
		# 028: this sentence carried the same over-wide claim as the prompt
		# did - "and then measures the real one". Nothing in the game does
		# that; tests/behaviour_test.gd does, and a player cannot reach it.
		# A checker written to catch Genesis overstating its limits was
		# overstating its capabilities, which is TRAPS 14 in the other
		# direction and the same lesson: a rebuttal is a claim about Genesis.
		#
		# The last clause is here because this note cannot tell the two apart
		# by phrase matching, and should not try: a refusal that denies the
		# MEASURED stop is correct, so the player is told which half was
		# understated and which half the refusal got right.
		"but": "Genesis does measure what it builds, and moves bodies with forces on a mass against drag. A boots spec is given a predicted stopping distance from its own numbers before anything moves. What no command does is measure a real stop and report it beside the prediction - a refusal about THAT part is right.",
	},
	{
		# --- 048: matched as a PAIR of ideas, not as a phrase ---
		#
		# The owner's machine, first real outing of this checker, 2026-10-16:
		#
		#   "Genesis cannot inspect or report the current state of the world
		#    or character, as it only builds the world and processes commands"
		#
		# False - a delivery is decided by reading the thing's position - and
		# this file printed NOTHING. It was looking for "inspect the world" and
		# "world state"; the model wrote "inspect or report the current state
		# of the world". Same claim, different word order, straight through the
		# net. Third time word order has beaten a phrase list here, after
		# "actually" (022) and "instead" (023).
		#
		# So this capability is matched as a pair: one word for the ACT and one
		# for the THING, anywhere in the same sentence, after a negation. No
		# order, no adjacency, so the paraphrase space a model can reach does
		# not have to be guessed in advance. Still three conditions deep -
		# negation, act, subject - plus the number rule, which is what keeps it
		# from firing on everything.
		"name": "verification from the world",
		"words": ["verify", "verification", "verified", "verifying"],
		"pairs": [
			["inspect", "inspection", "report", "query", "check", "read",
				"tell you", "know"],
			["state", "world", "position", "location", "where", "attribute"],
		],
		"denials": [],
		"but": "Genesis does read the world and report what it finds. A delivery is decided by reading the thing's position afterwards - that is the whole of how it answers - and a character has no way to report its own success. What it has no command for is being ASKED, in so many words, where something is; a refusal about THAT is right, and the answer is to look at the panel or to give an order and read what it reports.",
	},
	{
		"name": "the record",
		"words": [
			"history", "history tracking", "logging", "log of", "ledger",
			"record keeping", "recording",
		],
		"denials": [],
		"but": "Genesis does keep a record. Every request, reading, validation, build, attempt and outcome goes to a ledger on disk, and the session report separates what succeeded, what failed and what could not be verified.",
	},
	{
		"name": "routing",
		"words": [
			"pathfinding", "path finding", "navigation", "navigate",
			"route", "routing",
		],
		"denials": [],
		"but": "Genesis does route. A character finds its way room to room through doors that are actually passable, and a door shut while it is walking is handled.",
	},
	{
		# 027. This entry exists for the same reason the one below it does: the
		# PROMPT was inviting the lie. It said "a sequence of steps to be done
		# in order is not possible", which is true of a CHAIN OF ORDERS and
		# false of carry - the one errand Genesis has that is itself staged.
		# The character walks to the thing, picks it up at the waypoint where
		# it stands, and carries it on to the room. "take the red key to room
		# 3" is one ORDER, and 023's own session asked for exactly that.
		"name": "fetching and carrying",
		"words": [
			"carry", "carries", "carrying", "carried",
			"fetch", "fetches", "fetching",
			"pick up", "picks up", "picked up", "picking up", "pick it up",
		],
		"denials": [],
		"but": "Genesis does have a character fetch a thing and take it somewhere. ORDER carry is a staged errand: it walks to the thing, picks it up where the thing stands, and carries it on to the room - and whether it arrived is then read from the thing's own position.",
	},
	{
		# 025. This entry exists because of a claim the PROMPT made, not one
		# the AI invented: "Nothing persists ... so nothing can be saved and
		# reloaded" was written into the capability list in 023 and was false
		# when it was written. /save and /load have existed for releases. The
		# commit that built a checker for false capability denials shipped
		# one. What is true is narrower and is now said instead: a world comes
		# back as it was BUILT, not as it was LEFT.
		"name": "saving and loading a world",
		"words": [
			"persist", "persists", "persistence", "saved and reloaded",
			"save a world", "saving", "cannot be saved", "reload",
		],
		"denials": ["nothing persists"],
		"but": "Genesis does save and load a world, and checks the one that comes back against the measurements taken the day it was saved. What it does not keep is the STATE it was left in - equipment, shut doors, and where things had been carried to.",
	},
	{
		"name": "one world inside another",
		"words": [
			"inside a farm", "inside another world", "nest", "nested",
			"world inside", "combined",
		],
		"denials": ["mutually exclusive", "separate worlds"],
		"but": "Genesis does put one world inside another, with a PLAN and \"around\". The outer world is grown until the inner one fits with room to spare, and the growth is recorded.",
	},
]


# What is wrong with this refusal, or an empty array if nothing is.
# Each entry is {"capability", "denial", "but"}.
static func quarrel_with(reason: String) -> Array:
	var found: Array = []
	var whole := _plain(reason)
	var sentences := sentences_of(reason)
	for entry in CAPABILITIES:
		var capability: Dictionary = entry
		var caught := _denial_in(whole, sentences, capability)
		if caught != "":
			found.append({
				"capability": str(capability["name"]),
				"denial": caught,
				"but": str(capability["but"]),
			})
	return found


# The phrase that denied this capability, or "". Outright denials are matched
# anywhere in the refusal; a capability word counts only with a negation
# before it IN THE SAME SENTENCE, and only in a sentence that is not about
# number. Both of those rules are scoped to a sentence, so the sentences are
# worked out once, by sentences_of(), and handed in.
#
# 027: since 023, when this file was written, they were scoped to nothing.
# _plain() replaced every "." with a space, and _denial_in then split on "."
# - so there was always exactly one "sentence", the whole refusal. The
# consequence ran the wrong way: one honest clause about number ANYWHERE
# silenced the check entirely. "There are not two characters to compare. This game does not
# include a physics engine" went through clean, while the second sentence on
# its own was caught. That is the likeliest shape of a real refusal to one of
# the owner's hundred-word briefs: one true limit of number, one false claim
# about a capability.
static func _denial_in(whole: String, sentences: Array, capability: Dictionary) -> String:
	for denial in (capability["denials"] as Array):
		if whole.contains(str(denial)):
			return str(denial)

	for sentence in sentences:
		var one := " %s " % str(sentence)
		var about_number := false
		for quantity in ABOUT_NUMBER:
			if one.contains(quantity):
				about_number = true
				break
		if about_number:
			continue
		var negated_from := -1
		for negation in NEGATIONS:
			var at := one.find(" " + negation.strip_edges() + " ")
			if at < 0:
				at = one.find(" " + negation) if negation.ends_with(" ") else -1
			if at >= 0 and (negated_from < 0 or at < negated_from):
				negated_from = at
		if negated_from < 0:
			continue
		for word in (capability["words"] as Array):
			var where := one.find(str(word), negated_from)
			if where > negated_from:
				return str(word)

		# 048: and the pair form. One word for the ACT and one for the THING,
		# both after the negation, in either order and not necessarily near
		# each other - because the thing being matched is a claim, and a claim
		# survives being reworded while a phrase does not.
		var pairs = capability.get("pairs", [])
		if typeof(pairs) == TYPE_ARRAY and (pairs as Array).size() == 2:
			var act := _first_of((pairs as Array)[0], one, negated_from)
			var thing := _first_of((pairs as Array)[1], one, negated_from)
			if act != "" and thing != "":
				return "%s ... %s" % [act, thing]
	return ""


# The first of these words to appear after `from`, or "".
static func _first_of(words: Variant, sentence: String, from: int) -> String:
	if typeof(words) != TYPE_ARRAY:
		return ""
	for word in (words as Array):
		var at := sentence.find(str(word), from)
		if at > from:
			return str(word)
	return ""


# What the player is told, under the refusal. Never instead of it: the refusal
# stands, because overturning it would mean Genesis deciding it can do
# something on the strength of a phrase match, which is exactly the move this
# file exists to distrust.
static func note(quarrels: Array) -> String:
	if quarrels.is_empty():
		return ""
	var lines := PackedStringArray()
	lines.append("That refusal understates Genesis:")
	for q in quarrels:
		lines.append("- " + str((q as Dictionary)["but"]))
	lines.append("The request may still be impossible for another reason, but not for that one. Worth asking again.")
	return "\n".join(lines)


# What counts as a sentence, in one place, because two rules above depend on
# it. A comma or a semicolon does NOT end one: "does not support A, B, or C"
# is a single list under a single negation, and splitting it would lose the
# negation for every item but the first - which is the shape _denial_in was
# written for in the first place.
const ENDERS := [".", "!", "?", "\n"]


static func sentences_of(text: String) -> Array:
	var out: Array = []
	var current := ""
	for i in text.length():
		var character := text[i]
		if character in ENDERS and not _inside_number(text, i):
			if _plain(current) != "":
				out.append(_plain(current))
			current = ""
		else:
			current += character
	if _plain(current) != "":
		out.append(_plain(current))
	return out


# "the road comes within 1.8 m" is one number, not two sentences.
static func _inside_number(text: String, at: int) -> bool:
	if text[at] != "." or at == 0 or at + 1 >= text.length():
		return false
	return text[at - 1].is_valid_int() and text[at + 1].is_valid_int()


# Lowercased, with the punctuation that gets between a phrase and a match
# taken out. Deliberately not _plain from Understanding: that one is tuned for
# a player's typing, this one for a model's prose.
static func _plain(text: String) -> String:
	var out := text.to_lower()
	for mark in [",", ".", ";", ":", "!", "?", "\"", "'", "(", ")", "\n", "\t"]:
		out = out.replace(mark, " ")
	while out.contains("  "):
		out = out.replace("  ", " ")
	return out.strip_edges()
