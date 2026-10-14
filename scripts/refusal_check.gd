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
		"but": "Genesis does measure what it builds, and moves bodies with forces on a mass against drag. It predicts a stopping distance from the numbers and then measures the real one.",
	},
	{
		"name": "verification from the world",
		"words": [
			"verify", "verification", "verified", "verifying",
			"runtime inspection", "inspect the world", "world state",
			"world-state", "query the world",
		],
		"denials": [],
		"but": "Genesis does verify from the world. A delivery is decided by reading the thing's position afterwards, and a character has no way to report its own success.",
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
	for entry in CAPABILITIES:
		var capability: Dictionary = entry
		var caught := _denial_in(_plain(reason), capability)
		if caught != "":
			found.append({
				"capability": str(capability["name"]),
				"denial": caught,
				"but": str(capability["but"]),
			})
	return found


# The phrase that denied this capability, or "". Outright denials are matched
# anywhere; a capability word counts only with a negation before it in the
# same sentence.
static func _denial_in(said: String, capability: Dictionary) -> String:
	for denial in (capability["denials"] as Array):
		if said.contains(str(denial)):
			return str(denial)

	for sentence in said.split(".", false):
		var one := " %s " % str(sentence).strip_edges()
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
