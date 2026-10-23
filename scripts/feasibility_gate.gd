extends RefCounted
class_name FeasibilityGate

# --- Prototype 002A - Step A3: Closure feasibility gate ---
# Runs BEFORE any geometry is built, and rejects compositions that could never
# close into a circuit however the solver adjusted them (Amendments D and E).
#
# A simple closed loop turns through exactly one revolution:
# +360 deg (clockwise) or -360 deg (anticlockwise).
#
# The solver may scale each corner or hairpin independently by up to
# MAX_ANGLE_ADJUSTMENT. So the reachable net turn is widest when right-hand
# turns are opened and left-hand turns tightened, or the reverse:
#   highest = (1 + max) * right_total - (1 - max) * left_total
#   lowest  = (1 - max) * right_total - (1 + max) * left_total
# (Amendment D's simpler 0.8N-1.2N range is only exact when every corner
#  turns the same way.)
#
# Chicanes turn and turn back, so they add nothing to net turn.

const MAX_ANGLE_ADJUSTMENT := 0.20
const FULL_TURN := 360.0
const MIN_STRAIGHTS := 2
const MIN_TURNS := 2


# sections must already be validated by SectionValidator.
static func check(sections: Array) -> Dictionary:
	var right_total := 0.0
	var left_total := 0.0
	var straights := 0
	var turns := 0

	# The type lists come from TrackGeometry, so the gate, the solver and the
	# geometry always agree on what turns and what can stretch. (002C cleanup:
	# banked corners turn the track but used to be invisible here.)
	for s in sections:
		var t := str(s["type"])
		if t in TrackGeometry.STRAIGHT_FAMILY:
			straights += 1
		elif t in TrackGeometry.YAW_TYPES:
			turns += 1
			var angle := float(s["angle"])
			if angle > 0.0:
				right_total += angle
			else:
				left_total += -angle

	var net := right_total - left_total
	var lowest := (1.0 - MAX_ANGLE_ADJUSTMENT) * right_total - (1.0 + MAX_ANGLE_ADJUSTMENT) * left_total
	var highest := (1.0 + MAX_ANGLE_ADJUSTMENT) * right_total - (1.0 - MAX_ANGLE_ADJUSTMENT) * left_total

	var result := {
		"ok": false,
		"category": "",
		"reasons": [],
		"net_turn": net,
		"reachable_min": lowest,
		"reachable_max": highest,
		"target_turn": 0.0,
		"straights": straights,
		"turns": turns,
	}

	if straights < MIN_STRAIGHTS or turns < MIN_TURNS:
		result["category"] = "FAILED_DEGREES_OF_FREEDOM"
		result["reasons"] = [
			# 042: "(s)" is the plural written out by hand, wearing a dodge.
			# 068: and the noun was "corner" for a count of YAW_TYPES, which
			# is corners, hairpins and banked corners - so a composition of
			# one hairpin was reported as "1 corner". The same two words, at
			# the same door, one line apart (TRAPS 11).
			"composition has %s and %s" % [
				Readback.plural(straights, "straight"), Readback.plural(turns, "turn")],
			# 068: "corners" understated what satisfies this door. MIN_TURNS
			# is compared against a count of TrackGeometry.YAW_TYPES, so a
			# hairpin answers it as well as a corner - measured, not supposed:
			# a composition of MIN_STRAIGHTS straights and MIN_TURNS hairpins
			# and no corner at all clears this door, which is what
			# prompt_bounds_test's floor fixture builds. The prompt has always
			# said "corners or hairpins"; this sentence, which is the one the
			# PLAYER reads, said "corners".
			"closing a circuit needs at least %d straights and %d corners or hairpins" % [MIN_STRAIGHTS, MIN_TURNS],
		]
		return result

	var reachable: Array = []
	for target in [FULL_TURN, -FULL_TURN]:
		if target >= lowest and target <= highest:
			reachable.append(target)

	if reachable.is_empty():
		result["category"] = "FAILED_INFEASIBLE"
		result["reasons"] = [
			"proposed net turn: %+.0f deg" % net,
			# 068: read from FULL_TURN, not typed out. The prompt stated the
			# same number by hand in three places and this refusal in a
			# fourth, and no file in tests/ named FULL_TURN at all.
			"a circuit must turn exactly %+.0f or %+.0f deg" % [FULL_TURN, -FULL_TURN],
			# 069: "per corner" named a narrower set than the number covers. The
			# reach this sentence reports is computed from right_total and left_total
			# above, which are summed over TrackGeometry.YAW_TYPES - corner, hairpin
			# and banked_corner - so a hairpin's angle is adjusted by exactly this
			# percentage and the sentence said it was not. The noun is the SET the
			# measurement covers, which is a turn. 068 fixed the two sentences of
			# this class that state a RULE and left the four that DESCRIBE; this is
			# one of them (TRAPS 11).
			"with up to %.0f%% adjustment per turn, this composition reaches only %+.0f to %+.0f deg" % [MAX_ANGLE_ADJUSTMENT * 100.0, lowest, highest],
		]
		return result

	# If both directions are somehow reachable, take the one nearer the proposal.
	var target: float = reachable[0]
	if reachable.size() > 1 and absf(-FULL_TURN - net) < absf(FULL_TURN - net):
		target = -FULL_TURN

	result["ok"] = true
	result["target_turn"] = target
	return result
