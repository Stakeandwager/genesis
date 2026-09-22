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

	for s in sections:
		match str(s["type"]):
			"straight":
				straights += 1
			"corner", "hairpin":
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
			"composition has %d straight(s) and %d corner(s)" % [straights, turns],
			"closing a circuit needs at least %d straights and %d corners" % [MIN_STRAIGHTS, MIN_TURNS],
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
			"a circuit must turn exactly +360 or -360 deg",
			"with up to %.0f%% adjustment per corner, this composition reaches only %+.0f to %+.0f deg" % [MAX_ANGLE_ADJUSTMENT * 100.0, lowest, highest],
		]
		return result

	# If both directions are somehow reachable, take the one nearer the proposal.
	var target: float = reachable[0]
	if reachable.size() > 1 and absf(-FULL_TURN - net) < absf(FULL_TURN - net):
		target = -FULL_TURN

	result["ok"] = true
	result["target_turn"] = target
	return result
