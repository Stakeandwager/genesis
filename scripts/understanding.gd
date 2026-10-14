extends RefCounted
class_name Understanding

# --- 003 Stage 2: did Genesis understand the player? ---
# A readback says what Genesis thinks it was asked for. This decides what the
# player's NEXT action says about whether that was right, and writes it down.
#
# THE RULE THIS EXISTS TO ENFORCE
# A successful build is not evidence of understanding. Genesis can construct
# exactly the wrong thing, perfectly. So understanding is judged only from
# what the player does, never from whether the geometry worked, and it is
# kept in its own field that no build result can touch.
#
# EVIDENCE HAS STRENGTHS, AND THEY MUST NOT BE ADDED UP
#   CONFIRMED            strong   they said yes
#   CORRECTED            strong   they said Genesis had it wrong, or asked
#                                 again for the same thing in other words
#   DISPUTED             strong   they said no, without saying whether
#                                 Genesis misread them or they changed their
#                                 mind. Real evidence of dissatisfaction,
#                                 and not attributable to either.
#   REVISED              none     they asked for something different on
#                                 purpose. Says nothing about whether the
#                                 first reading was right, so it is kept out
#                                 of the understanding score entirely.
#   ACCEPTED_BY_USE      medium   they drove it, raced it or saved it
#   ACCEPTED_BY_SILENCE  weak     they moved on and did not object
#   UNKNOWN              none     no evidence either way
#
# Silence is the easiest to collect and the least worth having. A session
# whose score is mostly silence has not shown that anyone was understood, so
# the report keeps the strengths apart rather than summing them.
#
# WHAT THIS CANNOT KNOW
# It records what the player SAID about the reading, not what was true of
# it. Someone who asks for "a pond", is shown "a pond", and then says "you
# misunderstood, I wanted two" has revised while using the words of a
# misreading - and Genesis will believe them. The report prints the original
# readback beside every such claim so that a person can see the difference.
# Taking the player at their word is the honest default; treating their word
# as proof is not.
#
# WHY "NO" IS NOT ENOUGH ON ITS OWN
# "No" means two different things that look identical in text: "you misread
# me" and "I have changed my mind". A player who asks for a hall with four
# rooms off it, gets exactly that, and then decides they would rather have a
# row has not been misunderstood - they have revised. Scoring both as a
# misunderstanding would measure how often people change their minds and
# call it comprehension.
#
# So a bare "no" is DISPUTED, not CORRECTED, and the report carries the
# doubt forward as a RANGE rather than resolving it with a guess.
#
# Nothing here edits the original record. Evidence is written as its own
# record pointing back by id: history is added to, never rewritten.

const CONFIRM := ["yes", "yeah", "yep", "yup", "correct", "exactly", "right",
	"thats right", "that is right", "thats it", "that is it", "perfect", "spot on"]
const DENY := ["no", "nope", "nah", "wrong", "not that", "thats wrong",
	"that is wrong", "not quite", "thats not it", "that is not it"]

# Said Genesis read them wrongly. These attribute the fault to the reading.
const MISREAD := ["not what i meant", "not what i said", "you misunderstood",
	"i didnt say", "i did not say", "thats not what i", "that is not what i",
	"you got it wrong", "you misread", "i never said"]

# --- 023: a revision is announced, not mentioned ---
#
# These used to be matched anywhere in the input, and that is wrong twice over.
#
# 022 found the first half: "actually" is two different words. At the front of
# a clause it announces a change of mind - "actually, make it a row". Anywhere
# else it is an ordinary intensifier, and in a tester's hands a very common
# one: "confirm delivery only if the key itself is ACTUALLY in room 3". Two of
# eight requests in that session were scored REVISED on the strength of it.
#
# 022 then fixed "actually" and left the rest of the list alone, reasoning
# that the others were unambiguous. The very next session proved otherwise, in
# the same way, twice: "record the revised intention INSTEAD", "explain which
# part of the test is unsupported INSTEAD of pretending it passed". Fixing the
# instance and not the class, in the same commit that wrote down "do not fix
# the instance" - see TRAPS 9 and 11.
#
# So position now governs ALL of them, and the rule is one rule: a revision is
# ANNOUNCED. Somebody changing their mind says so at the start - first
# sentence, start of a clause. A marker in the fifth sentence of a 120-word
# brief is prose about the marker's ordinary meaning.
#
# WHAT THIS GIVES UP, ON PURPOSE
# "Make it bigger. Actually, make it a row." is now missed, because the
# announcement is in the second sentence. A miss costs a weak
# ACCEPTED_BY_SILENCE, which is excluded from the understanding score anyway.
# A false REVISED costs a verdict the player never gave, inside the report.
# Those two are not the same size, so the rule errs towards the cheap failure.
# There are two kinds of marker and they need different tests, which is the
# part 022 got wrong by merging them.
#
# OPENERS announce. They come at the START of a clause and the rest of the
# clause is the new request: "actually, make it a row", "scratch that, build a
# farm". Mid-clause the same words are ordinary English - "does the door
# ACTUALLY shut" is a question, not a change of mind - so position inside the
# clause is what separates the two.
const REVISE_OPENERS := ["actually", "no actually", "scratch that",
	"on reflection", "on second thought", "forget that", "forget it",
	"lets try", "let us try"]

# THE REST carry the revision in themselves, wherever they sit in the clause,
# because they are about the speaker's own mind rather than the sentence they
# introduce: "make it a row INSTEAD", "I'd RATHER have one big hall", "no,
# actually I've CHANGED MY MIND". These are matched anywhere in the first
# sentence - but only the first.
const REVISE := ["instead", "id rather", "i would rather",
	"ive changed my mind", "i have changed my mind", "changed my mind"]

# "instead OF something" is a preposition - "report that limitation instead of
# pretending it passed" - and carries no revision at all. Bare "instead" at
# the end of a clause does: "make it a row instead". Same word, two jobs, and
# only one of them is a marker.
const NOT_A_MARKER := ["instead of"]

# Where the first sentence ends, and where one clause gives way to the next.
# Both are read from the RAW input, before punctuation is stripped, because
# the punctuation is the only thing that says where either boundary is.
const SENTENCE_BREAKS := [".", "!", "?", "\n"]
const CLAUSE_BREAKS := [",", ";", ":", " - ", " but ", " and "]

# Words that carry no intent, dropped before two requests are compared.
const NOISE := ["a", "an", "the", "me", "my", "i", "it", "to", "for", "of",
	"and", "with", "in", "on", "at", "make", "build", "create", "want", "please",
	"can", "you", "give", "some", "that", "this", "but", "now"]

# How alike two requests must be to count as asking again for the same thing.
const SAME_REQUEST := 0.6


# What a player's next input says about the readback before it.
# Returns {"understanding", "evidence", "strength", "consumed"}.
# consumed is true when the input was an answer to the readback and nothing
# else - "yes" is not a request to build a world called yes.
# NOT inferred here: asking for a change to the world ("make the corners
# tighter") is acceptance of it, and the amendment counts it as medium
# evidence. But at the moment the player presses the button, Genesis cannot
# tell a change from an unrelated new request - only the AI's answer reveals
# which it was. Guessing would manufacture medium evidence out of nothing,
# which is the exact failure this layer exists to prevent, so such a request
# counts as silence until the evidence is real.
# was_built says whether the readback being judged produced a world. Driving,
# racing or saving can only be acceptance of something that exists: if the
# request was refused or unsupported, the player is using an earlier world
# and that says nothing about this readback.
static func judge(input: String, previous_request: String, was_built: bool) -> Dictionary:
	var text := _plain(input)
	if text == "":
		return {}

	if text in CONFIRM:
		return _verdict("CONFIRMED", "SAID_SO", "strong", true)

	# Said in so many words that the reading was wrong.
	for phrase in MISREAD:
		if text.contains(phrase):
			return _verdict("CORRECTED", "SAID_MISREAD", "strong", false)

	# Said in so many words that they want something else now. This is not
	# evidence about the first reading at all. 023: judged on the FIRST
	# SENTENCE only, and on whole words, because that is where an announcement
	# lives and anywhere else the same words are prose.
	if _announces_a_revision(input):
		return _verdict("REVISED", "SAID_REVISED", "none", false)

	# "No, in a row" rejects what they were shown without saying why. The
	# rejection is real; which of the two it is cannot be known from this.
	for word in DENY:
		if text == word or text.begins_with(word + " ") or text.begins_with(word + ", "):
			return _verdict("DISPUTED", "SAID_NO", "strong", text == word)

	if input.begins_with("/"):
		var command := input.substr(1).split(" ")[0].to_lower()
		if not was_built:
			# Nothing was built from the readback being judged, so whatever
			# is being driven or saved belongs to an earlier request.
			return {}
		match command:
			"drive":
				return _verdict("ACCEPTED_BY_USE", "DROVE_IT", "medium", false)
			# 008: a dungeon could never be used, only built and left, so the
			# strongest evidence it could ever earn was silence. Walking into
			# one is the same act as driving a track and counts the same.
			"explore":
				return _verdict("ACCEPTED_BY_USE", "WALKED_IT", "medium", false)
			"race":
				return _verdict("ACCEPTED_BY_USE", "RACED_IT", "medium", false)
			"save":
				return _verdict("ACCEPTED_BY_USE", "SAVED_IT", "medium", false)
		# Any other slash command says nothing about understanding.
		return {}

	# Asking again, in different words, for the thing just asked for. The
	# player never says "you misunderstood me"; they simply try again.
	#
	# Typed JSON is excluded: two commands of the same kind share most of
	# their words ("command", "parameters", "sections", "straight") and would
	# look like someone repeating themselves when they are debugging.
	if previous_request != "" and not input.begins_with("{") and not previous_request.begins_with("{"):
		if _alike(input, previous_request) >= SAME_REQUEST:
			return _verdict("CORRECTED", "ASKED_AGAIN", "strong", false)

	return _verdict("ACCEPTED_BY_SILENCE", "MOVED_ON", "weak", false)


# A yes or no on its own, with no readback waiting for it. Not a request.
static func is_bare_answer(input: String) -> bool:
	var text := _plain(input)
	return text in CONFIRM or text in DENY


static func _verdict(status: String, evidence: String, strength: String, consumed: bool) -> Dictionary:
	return {"understanding": status, "evidence": evidence, "strength": strength, "consumed": consumed}


# The evidence record. It points at the readback it judges and never touches
# it, so the original interpretation survives exactly as Genesis made it.
static func record(about: Dictionary, verdict: Dictionary, next_input: String) -> Dictionary:
	return {
		"type": "understanding",
		"time": Time.get_datetime_string_from_system(),
		"about": str(about.get("id", "")),
		"request": str(about.get("request", "")),
		"readback": str(about.get("readback", "")),
		"understanding": str(verdict["understanding"]),
		"evidence": str(verdict["evidence"]),
		"strength": str(verdict["strength"]),
		"next_input": next_input,
	}


# What the player is told when they confirm or correct. Short: this is an
# acknowledgement, not a conversation.
static func reply(verdict: Dictionary) -> String:
	match str(verdict["understanding"]):
		"CONFIRMED":
			return "Good - that is what I built."
		"CORRECTED":
			return "Understood, I had that wrong. Tell me what you wanted."
		"DISPUTED":
			return "Right - tell me what you wanted instead."
		"REVISED":
			return "Changing it."
	return ""


# Whether the opening of this input announces a change of mind.
#
# Everything is judged on the FIRST SENTENCE, which is the gate 022 was
# missing: it put "actually" behind a position test and left the rest of the
# list matching the whole input, so the next session scored two more false
# verdicts on "record the revised intention INSTEAD" and "explain which part
# is unsupported INSTEAD of pretending it passed", both in the fifth sentence
# of a specification brief.
#
# Inside that sentence the two lists get the two tests they need: an opener
# must start a clause, the rest may sit anywhere. Both match whole phrases
# only, so "instead" inside a longer word is not a marker, and "instead of"
# is struck out first because it is a preposition.
static func _announces_a_revision(input: String) -> bool:
	var opening := _first_sentence(input)
	for clause in _clauses(opening):
		for phrase in REVISE_OPENERS:
			if clause == phrase or clause.begins_with(phrase + " "):
				return true

	var said := _plain(opening)
	for dead in NOT_A_MARKER:
		said = said.replace(dead, " ")
	var padded := " %s " % said
	for phrase in REVISE:
		if padded.contains(" %s " % phrase):
			return true
	return false


# The clauses of one sentence, flattened the same way _plain flattens
# everything else so the phrase lists need no second spelling.
static func _clauses(sentence: String) -> Array:
	var said := sentence
	for mark in CLAUSE_BREAKS:
		said = said.replace(mark, "|")
	var out: Array = []
	for piece in said.split("|", false):
		var clause := _plain(str(piece))
		if clause != "":
			out.append(clause)
	return out


# Everything up to the first full stop, question mark, exclamation or newline.
# An input with no stop at all is one sentence, however long it is.
static func _first_sentence(input: String) -> String:
	var said := input.strip_edges()
	for mark in SENTENCE_BREAKS:
		var at := said.find(mark)
		if at > 0:
			said = said.substr(0, at)
	return said


static func _plain(text: String) -> String:
	var out := ""
	for c in text.to_lower().strip_edges():
		if c in ["'", ".", "!", "?", ","] and out != "":
			continue
		out += c
	return out.strip_edges()


# How much two requests are asking for the same thing, ignoring the words
# everybody uses. 0.0 is nothing in common, 1.0 is the same content words.
static func _alike(a: String, b: String) -> float:
	var left := _content(a)
	var right := _content(b)
	if left.is_empty() or right.is_empty():
		return 0.0
	var shared := 0
	for word in left:
		if word in right:
			shared += 1
	var union := left.size() + right.size() - shared
	return float(shared) / float(union) if union > 0 else 0.0


static func _content(text: String) -> Array:
	var out: Array = []
	for word in _plain(text).split(" ", false):
		var w := str(word)
		if w == "" or w in NOISE:
			continue
		if not w in out:
			out.append(w)
	return out
