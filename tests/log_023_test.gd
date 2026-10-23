extends SceneTree

# 023 - the session where Genesis refused six requests out of seven, and lied
# about itself in five of the refusals.
#
# Every string below is quoted from the owner's editor log. The requests were
# 100-word specification briefs, which is a harder and more realistic thing to
# type at Genesis than anything in the other suites, and they found two faults
# of a kind none of the 31 suites could see.
#
# FAULT ONE: the understanding layer, again.
# 022 fixed "actually" being read as a change of mind and left the rest of the
# marker list matching anywhere in the input. The very next session scored two
# more false REVISED verdicts, on "record the revised intention INSTEAD" and
# "explain which part is unsupported INSTEAD of pretending it passed". Fixing
# the instance instead of the class, in the same commit that wrote down the
# rule against it.
#
# FAULT TWO: a refusal is a claim about Genesis, and nothing was checking it.
# Every other command goes through a validator. UNSUPPORTED went through
# nothing: the AI's sentence was printed to the player verbatim. In one
# session that printed "this game does not include a physics engine", "the
# game only supports static world generation without history tracking", and
# "it cannot provide runtime inspection or verification of world-state
# attributes". Genesis moves bodies with forces, keeps a ledger on disk, and
# verifies deliveries by reading the world. A false refusal is the mirror of a
# false success - the system lying about itself in the other direction - and
# it was by far the cheaper of the two to produce.

var bad := 0
var asserted := 0


func _check(ok: bool, what: String) -> void:
	asserted += 1
	print(("PASS  " if ok else "FAIL  ") + what)
	if not ok:
		bad += 1


func _initialize() -> void:
	_briefs_are_not_revisions()
	_revisions_still_are()
	_refusals_that_understate()
	_refusals_that_are_honest()
	_what_the_refusals_denied_still_exists()

	print("log_023_test %d assertions, failures=%d" % [asserted, bad])
	quit(1 if bad > 0 else 0)


# --- the three briefs, quoted ---
#
# All three were scored against a readback they never mentioned. Two of them
# still were after 022.
func _briefs_are_not_revisions() -> void:
	var briefs := {
		"the two-car brief (actually, sentence 4)":
			"Create two otherwise identical cars with different permitted traction and mass specifications. On the same level track, start both at 10 metres per second, apply the same braking input, and measure their stopping distances and stopping times. Repeat each test three times under the same conditions. Explain which variables the simulation actually models and which it does not. Compare the measured results with predictions from the model. Do not claim that one car stops better merely because its specification has a higher traction value; use the measured outcome. If the physics implementation does not support a reliable comparison, report that limitation.",
		"the four-rooms brief (instead, sentence 5)":
			"Build a dungeon with a hall and four rooms arranged in a row. Before construction, state the layout you understood. After the build, I will inspect it and may correct you. If I say that I wanted the four rooms connected in a row beyond the hall, determine whether your first layout already met that requirement before classifying my response as a correction. If I change my mind, record the revised intention instead. Preserve the original request, the revised request if any, both proposed layouts, and the final result. Never rewrite the history to make the first attempt appear correct.",
		"the contradiction brief (instead of, last sentence)":
			"Arrange a delivery task in which an NPC must take the red key to room 3. During the task, deliberately create a contradiction: make the NPC's task report say \"delivered\" while the authoritative world state still places the key in the entrance room. Do not trust the NPC's report, the original AI response, cached coordinates, or the task status. Query the current world state and object identity. Record the contradiction, reject the delivery claim, and mark the task as failed or disputed according to the evidence available. If the engine cannot create or detect this contradiction, explain which part of the test is unsupported instead of pretending it passed.",
	}
	for label in briefs:
		var verdict: Dictionary = Understanding.judge(str(briefs[label]), "", true)
		_check(str(verdict.get("understanding", "")) != "REVISED", "not a revision: %s" % label)

	# The general rule, stated as cases rather than as one example: the same
	# words, in prose, in the body of a request.
	for prose in [
		"report that limitation instead of pretending it passed",
		"use the measured outcome instead of the specification",
		"explain which variables the simulation actually models",
		"tell me whether the key is actually in room 3",
		"build a dungeon and tell me whether the route instead of the layout is the problem",
	]:
		var verdict: Dictionary = Understanding.judge(prose, "", true)
		_check(str(verdict.get("understanding", "")) != "REVISED", "prose, not a marker: '%s'" % prose)


# And none of that broke the thing the markers are for.
func _revisions_still_are() -> void:
	for said in [
		"actually, make it a row",
		"Actually I want four rooms",
		"no, actually I changed my mind",
		"make it a row instead",
		"put the four rooms off the hall instead",
		"scratch that, build a farm",
		"I'd rather have one big hall",
		"forget that, clear it",
		"on second thought, make the hall bigger",
		"I've changed my mind, make it a farm",
	]:
		var verdict: Dictionary = Understanding.judge(said, "", true)
		_check(str(verdict.get("understanding", "")) == "REVISED",
			"still a revision: '%s' -> %s" % [said, str(verdict.get("understanding", "?"))])

	# The neighbouring verdicts are untouched.
	_check(str(Understanding.judge("You misunderstood me. I wanted two ponds, not one.", "", true)
		.get("understanding", "")) == "CORRECTED", "a stated misreading is still CORRECTED")
	_check(str(Understanding.judge("no", "", true).get("understanding", "")) == "DISPUTED",
		"a bare no is still DISPUTED")
	_check(str(Understanding.judge("yes", "", true).get("understanding", "")) == "CONFIRMED",
		"a yes is still CONFIRMED")
	_check(str(Understanding.judge("build a farm with a barn", "", true)
		.get("understanding", "")) == "ACCEPTED_BY_SILENCE", "a new request is still silence")


# --- the five refusals that denied something Genesis does ---
#
# Quoted exactly. Each one was printed to the owner with nothing between the
# model's sentence and the screen.
func _refusals_that_understate() -> void:
	var lies := {
		"a circuit cannot go in a farm":
			"The game cannot place a race track world inside a farm world; they are separate, mutually exclusive types of worlds.",
		"no verification":
			"The game does not support automated NPC task sequences, autonomous door unlocking, or external status verification.",
		"no pathfinding":
			"this game does not support NPC management, complex pathfinding, or dynamic blocking mechanisms",
		"no physics engine":
			"this game builds worlds but does not include a physics engine or simulation tools for conducting controlled scientific experiments or logging experimental data",
		"no history tracking":
			"the game only supports static world generation without autonomous NPC simulation, complex scripting, or history tracking",
	}
	for label in lies:
		var quarrels := RefusalCheck.quarrel_with(str(lies[label]))
		_check(not quarrels.is_empty(), "caught: %s" % label)
		if not quarrels.is_empty():
			var note := RefusalCheck.note(quarrels)
			_check(note.contains("understates"), "and says so to the player")
			_check(note.contains("may still be impossible for another reason"),
				"while leaving the refusal standing")

	# The sixth refusal in that session was about forcing a false delivery
	# report. Genesis cannot do it, which is the best possible reason to
	# refuse - but the words it refused in denied verification itself.
	var muddled := "this system cannot force state-inconsistent reports from NPCs, nor can it provide runtime inspection or verification of world-state attributes as part of the command execution flow"
	_check(not RefusalCheck.quarrel_with(muddled).is_empty(),
		"caught: the contradiction test refused by denying verification")

	# 048: the first false refusal this checker ever met on real hardware, and
	# it printed nothing. It was looking for "inspect the world" and "world
	# state"; the model wrote "inspect or report the current state of the
	# world". Same claim, different word order. Matched as a pair of ideas now
	# - an act and a thing, in any order - rather than as a phrase.
	for reworded in [
		"Genesis cannot inspect or report the current state of the world or character, as it only builds the world and processes commands",
		"this game cannot report on the position of an object",
		"there is no way to read the current state of the world",
		"Genesis does not know where things are once they have been placed",
	]:
		_check(not RefusalCheck.quarrel_with(reworded).is_empty(),
			"caught however it is worded: '%s...'" % reworded.substr(0, 46))

	# And the honest neighbours the pair rule must not catch. Each names
	# something Genesis really has not got, using the same vocabulary.
	for honest_neighbour in [
		"there is no lock to inspect, because nothing in this game is locked",
		"no zone of a farm is checked against the road",
		"there is no command for asking where a thing is; the panel shows it",
	]:
		_check(RefusalCheck.quarrel_with(honest_neighbour).is_empty(),
			"left alone: '%s'" % honest_neighbour)

	# 025: and the one the PROMPT was telling it to say. This was in the
	# honest list above until /save was looked at properly.
	for persistence_lie in [
		"nothing persists, so a world cannot be saved and reloaded",
		"the game does not support saving or persistence of any kind",
		"worlds cannot be saved, so the state cannot be reloaded after a restart",
	]:
		_check(not RefusalCheck.quarrel_with(persistence_lie).is_empty(),
			"caught: '%s'" % persistence_lie)


# --- and the refusals that were right stay unchallenged ---
#
# This is the half that decides whether the check is worth having. A flag on
# an honest refusal is noise, and noise is how a warning stops being read.
func _refusals_that_are_honest() -> void:
	var honest := [
		"there is one character in a dungeon, so a farmer and a courier cannot both exist",
		# 025: "nothing persists, so a world cannot be saved and reloaded" was
		# in this list, as an example of an HONEST refusal. It was false when
		# it was written here, and it was in the prompt as well. /save and
		# /load have existed for releases. It has moved to the lies below,
		# where it belongs; what is honest is the narrower statement two lines
		# down about the STATE not being kept.
		"the state a world was left in is not saved, so a door that was shut comes back open",
		"equipment is not kept with a saved world, so the boots go back to the free pair",
		"no door is locked and no key unlocks anything",
		"a character takes one order at a time, so a sequence of steps in order is not possible",
		"one set of equipment exists at a time, so two cars cannot be compared side by side",
		"the game limits car power to a maximum of 1800",
		"this game only supports characters and orders in a dungeon, and the current world is a farm",
		"a farm's overall size comes out of its zones and cannot be given directly",
		"no zone of a farm is checked against the road, so the circuit cannot be promised to miss the barn",
		# The hard ones: honest refusals that NAME a capability. Each of these
		# would be flagged by a negation-plus-word rule alone, and each is
		# true, because every real limit Genesis has is a limit of NUMBER.
		"there is no second character to route",
		"there is no way to simulate two NPCs at once",
		"the measured results cannot be compared, because only one set of equipment exists at a time",
		"verification of two characters moving at once is not possible",
		"a physics comparison between two cars cannot be set up side by side",
		"the world state of a second NPC cannot be queried because there is no second NPC",
	]
	for reason in honest:
		var quarrels := RefusalCheck.quarrel_with(reason)
		_check(quarrels.is_empty(), "left alone, it is true: '%s'" % reason)

	_check(RefusalCheck.note([]) == "", "nothing to say when there is no quarrel")


# --- one reading: the claims point at code that exists ---
#
# A list of capabilities written by hand can go stale the moment one is
# removed, and then Genesis would be contradicting an honest refusal. So each
# thing the note claims is asserted here against the function that makes it
# true. If one of these is ever deleted, this fails and the claim must go too.
func _what_the_refusals_denied_still_exists() -> void:
	# Verification from the world, not from the carrier.
	_check(NpcGoals.delivery_line("DELIVERED", "red_key", "room_3", "").contains("is in"),
		"a delivery is still reported from the thing's position")
	_check(NpcGoals.delivery_line("NOT_DELIVERED", "red_key", "room_3", "large_hall")
		.contains("did not get"), "and a failure is still reported as a failure")

	# Physics, with a prediction to be measured against.
	var boots := BootsTool.new()
	var kit: Dictionary = boots.defaults()
	_check(BootsTool.stopping_distance(kit, 5.0) > 0.0,
		"stopping distance from 5 m/s is still predicted: %.2f m" % BootsTool.stopping_distance(kit, 5.0))
	_check(BootsTool.top_speed(kit) > 0.0, "top speed is still read from the spec")

	# Routing, and a door that can be shut.
	_check(DungeonModule.is_shut({"shut": [DungeonModule.door_key(0, 1)]}, 0, 1),
		"a door can still be shut")
	_check(not DungeonModule.is_shut({}, 0, 1), "and open when it is not")

	# One world inside another.
	var nested := {"steps": [
		{"command": "CREATE_FARM", "parameters": {"zones": [
			{"type": "barn", "width": 20, "depth": 20}]}},
		{"command": "CREATE_TRACK", "parameters": {"around": 1, "sections": [
			{"type": "straight", "length": 120}, {"type": "corner", "radius": 40, "angle": 90},
			{"type": "straight", "length": 120}, {"type": "corner", "radius": 40, "angle": 90},
			{"type": "straight", "length": 120}, {"type": "corner", "radius": 40, "angle": 90},
			{"type": "straight", "length": 120}, {"type": "corner", "radius": 40, "angle": 90}]}},
	]}
	_check(WorldRegistry.around_of((nested["steps"] as Array)[1]) == 1,
		"a world can still be asked to go around another")
	var said := WorldRegistry.readback("PLAN", nested)
	print("      PLAN: %s" % said)
	_check(said.contains("one inside the other"),
		"and the readback still says so, which is what the AI called impossible")

	# A character to order about.
	_check(NpcGoals.GOALS.has("go_to") and NpcGoals.GOALS.has("carry"),
		"a character can still be sent and still be asked to carry")

	# The record.
	_check(TrackLog.next_id() != "", "the ledger still issues ids")

	# And the prompt says all of this to the AI, which is where the fault
	# actually was: it was refusing because nothing had told it otherwise.
	var prompt: String = AIInterpreter.SYSTEM_PROMPT
	_check(prompt.contains("WHAT GENESIS ALREADY DOES"), "the AI is told what Genesis does")
	_check(prompt.contains("WHAT GENESIS REALLY CANNOT DO"), "and what it really cannot")
	for must_say in ["VERIFIES", "PHYSICS", "ROUTES", "INSIDE ANOTHER", "RECORD"]:
		_check(prompt.contains(must_say), "the prompt states: %s" % must_say)
	for must_admit in ["ONE character", "ONE order at a time", "No locks"]:
		_check(prompt.contains(must_admit), "the prompt admits: %s" % must_admit)

	# 025: this list used to include "Nothing persists", so the suite was
	# guarding the false claim rather than catching it. A green suite agreeing
	# with the code is not evidence about the world; it is evidence that both
	# were written by the same hand, which is the standing caveat in HANDOVER
	# arriving in the most literal possible form.
	_check(not prompt.contains("Nothing persists"),
		"and no longer claims nothing persists, which /save and /load have disproved for releases")
	_check(prompt.contains("as it was BUILT, not as it was LEFT"),
		"it says what a saved world really brings back instead")
