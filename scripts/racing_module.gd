extends WorldModule
class_name RacingModule

# --- 002F: the racing circuit as a world module ---
# Racing was the first world, and every other world copies its division of
# labour. Here it takes the same path as them. Nothing about racing changes:
# each step calls the same classes, in the same order, with the same
# arguments, and writes the same fields to the log.
#
#   validate       SectionValidator   every piece must be a legal piece
#   pre_check      FeasibilityGate    refuse what could never close
#   solve          ClosureSolver      close the loop within the 20% limit
#   correction     closure feedback   what the AI is told, once
#   post_check     SeparationCheck    the road must not cross itself
#   measure        TrackMetrics
#   build          CircuitBuilder
#
# The AI's rules for circuits stay in the standing instructions in
# ai_interpreter.gd, so prompt_section() is empty and the AI is shown exactly
# the same text as before.

func command() -> String:
	return "CREATE_TRACK"


func display_name() -> String:
	return "circuit"


# Racing's rules are already in the standing instructions. Moving them here
# would change the AI's prompt, so they stay where they are.
func prompt_section() -> String:
	return ""


# The record fields racing has always written, in the same order. Racing
# records never had a "world" field, so they still don't.
func record_fields(parameters: Dictionary, attempt: Dictionary) -> Dictionary:
	var intent = parameters.get("intent", {})
	var fields := {
		"intent": intent if typeof(intent) == TYPE_DICTIONARY else {},
		"command": "CREATE_TRACK",
		"proposed_sections": parameters.get("sections", []),
		"attempt": int(attempt.get("attempt", 1)),
	}
	if attempt.has("revision_of"):
		fields["revision_of"] = attempt["revision_of"]
	return fields


# Step A1: every piece must be a legal piece.
func validate(parameters: Dictionary) -> Dictionary:
	var check := SectionValidator.validate(parameters)
	return {"ok": check["ok"], "errors": check["errors"], "content": {"sections": check["sections"]}}


# Step A3: refuse compositions that could never close, before building
# anything. The proposal is measured first, so even a refused design can be
# compared with its correction.
func pre_check(content: Dictionary, record: Dictionary) -> Dictionary:
	var sections: Array = content["sections"]
	record["proposed_metrics"] = TrackMetrics.measure(sections)
	if record.has("revision_of"):
		record["revision_comparison"] = _compare_designs(record["revision_of"].get("proposed_metrics", {}), record["proposed_metrics"])

	var gate := FeasibilityGate.check(sections)
	record["feasibility"] = {
		"net_turn": gate["net_turn"],
		"reachable_min": gate["reachable_min"],
		"reachable_max": gate["reachable_max"],
		"target_turn": gate["target_turn"],
	}
	return {
		"ok": gate["ok"],
		"category": gate["category"],
		"reasons": gate["reasons"],
		"content": {"sections": sections, "target_turn": gate["target_turn"]},
	}


# Step A4: close the circuit, within the permitted adjustment.
# The solver's whole answer is kept, for the record and the feedback.
func solve(content: Dictionary) -> Dictionary:
	var solved := ClosureSolver.solve(content["sections"], content["target_turn"])
	var out := {
		"ok": solved["ok"],
		"category": solved["category"],
		"reasons": [],
		"layout": {"sections": solved["sections"], "target_turn": content["target_turn"]},
		"solver": solved,
	}
	if not solved["ok"]:
		out["reasons"] = [
			"best attempt ends %.1f m from the start, heading off by %.1f deg" % [solved["closure_distance"], solved["closure_heading_error"]],
			"closed means within %.1f m and %.0f deg" % [solved["distance_tolerance"], solved["heading_tolerance"]],
			"adjustment used: corners up to %.1f%%, straights up to %.1f%% (limit %.0f%%)" % [solved["max_angle_adjustment"] * 100.0, solved["max_length_adjustment"] * 100.0, solved["angle_limit"] * 100.0],
		]
	return out


func solve_record(result: Dictionary) -> Dictionary:
	var solved: Dictionary = result["solver"]
	var fields := {
		"closure": {
			"closure_distance": solved["closure_distance"],
			"closure_heading_error": solved["closure_heading_error"],
			"distance_tolerance": solved["distance_tolerance"],
			"heading_tolerance": solved["heading_tolerance"],
			"iterations": solved["iterations"],
			"remaining_ahead": solved["remaining_ahead"],
			"remaining_right": solved["remaining_right"],
			"proposal": solved["proposal"],
			"length_reach": solved["length_reach"],
		},
		"drift": {
			"max_angle_adjustment": solved["max_angle_adjustment"],
			"max_length_adjustment": solved["max_length_adjustment"],
			"angle_limit": solved["angle_limit"],
			"length_limit": solved["length_limit"],
			"proposed_net_turn": solved["proposed_net_turn"],
			"final_net_turn": solved["final_net_turn"],
		},
	}
	if solved["ok"]:
		fields["final_sections"] = solved["sections"]
	return fields


# Step A5: a closed track must not cross itself or run into itself.
func post_check(layout: Dictionary) -> Dictionary:
	var separation := SeparationCheck.check(layout["sections"])
	return {
		"ok": separation["ok"],
		"category": separation["category"],
		"reasons": separation["reasons"],
		"record": {
			"separation": {
				"minimum_separation": _finite(separation["minimum_separation"]),
				"required_separation": separation["required_separation"],
				"self_intersections": separation["self_intersections"],
			},
		},
	}


func measure(layout: Dictionary) -> Dictionary:
	return TrackMetrics.measure(layout["sections"])


# The circuit is built by its own CircuitBuilder, a child of root, so a plan
# can move it by moving root. Driving finds it through the "drivable" entry.
func build(root: Node3D, layout: Dictionary) -> Dictionary:
	var circuit := CircuitBuilder.new()
	circuit.name = "CircuitBuilder"
	root.add_child(circuit)
	var report := circuit.build(layout["sections"], false)
	report["drivable"] = circuit
	report["direction"] = "clockwise" if float(layout["target_turn"]) > 0.0 else "anticlockwise"
	return report


func summary(_metrics: Dictionary, report: Dictionary) -> String:
	return "CREATE_TRACK built a closed %s circuit: %d sections, %.0f m of road\n(full measurements in the metrics panel)" % [
		report["direction"], report["section_count"], report["total_length"]]


# --- closure feedback (002C), moved here unchanged from game_controller.gd ---

# What the AI is told. Plain facts Godot measured; no advice about style.
func correction_feedback(result: Dictionary) -> String:
	var solved: Dictionary = result["solver"]
	var p: Dictionary = solved["proposal"]
	var lines := PackedStringArray()
	lines.append("Godot measured your circuit and it does not close.")
	lines.append("")
	lines.append("Measured from the start line, your sections as proposed end %s and %s%s." % [
		_along(float(p["ahead"])), _across(float(p["right"])), _above(float(p["height"]))])
	lines.append("They end %.0f m from the start line. A closed circuit must end exactly on it." % float(p["distance"]))
	lines.append("Your sections turn a total of %+.0f degrees. A closed circuit must turn exactly %+.0f degrees." % [float(p["net_turn"]), float(p["target_turn"])])
	lines.append("Even after the game adjusted every corner and straight by up to %.0f%%, the track still ended %.0f m from the start line, and it must be within %.0f m." % [
		float(solved["angle_limit"]) * 100.0, float(solved["closure_distance"]), float(solved["distance_tolerance"])])
	var reach: Dictionary = solved["length_reach"]
	if not bool(reach["closable"]):
		lines.append("")
		lines.append("Godot also tested every possible length for your straights, from %.0f to %.0f m each, keeping your turns as they are. No choice of lengths closes this layout: the best possible still ends %.0f m from the start line." % [
			ClosureSolver.REACH_MIN_LENGTH, ClosureSolver.REACH_MAX_LENGTH, float(reach["best_miss"])])
		lines.append("To close, the track would still need to travel %s, and %s." % [
			_facing_words(float(reach["needed_facing"])),
			"none of your straights travel that way" if int(reach["helpful_straights"]) == 0 else "your straights that travel that way are already at their limits"])
		lines.append("So stretching or shrinking sections cannot fix it. The order or direction of your turns must change.")
	lines.append("")
	lines.append("Where each of your sections ends, in metres from the start line (ahead is along the start direction, negative means behind; right is to the right of it, negative means left), and which way the track faces there (0 is the start direction, positive is clockwise):")
	for e in p["section_ends"]:
		lines.append("  %d %s: ahead %.0f, right %.0f, facing %.0f" % [int(e["section"]), str(e["type"]), float(e["ahead"]), float(e["right"]), float(e["facing"])])
	lines.append("")
	lines.append("Revise the sections so the circuit closes by itself: it must end on the start line, facing the start direction. Keep everything else about your design that you can. Return ONLY the complete JSON command, in the same format as before.")
	return "\n".join(lines)


# A facing angle in words: 0 is the start direction, positive is clockwise.
func _facing_words(facing: float) -> String:
	var names := ["in the start direction", "ahead and to the right", "to the right", "back and to the right",
		"back towards the start line, opposite to the start direction", "back and to the left", "to the left", "ahead and to the left"]
	var index := int(round(wrapf(facing, 0.0, 360.0) / 45.0)) % 8
	return "%s (facing about %.0f degrees, where 0 is the start direction and 180 the opposite)" % [names[index], facing]


func _along(ahead: float) -> String:
	if absf(ahead) < 0.5:
		return "level with the start line"
	return "%.0f m past the start line" % ahead if ahead > 0.0 else "%.0f m short of the start line" % -ahead


func _across(right: float) -> String:
	if absf(right) < 0.5:
		return "directly in line with it"
	return "%.0f m to its right" % right if right > 0.0 else "%.0f m to its left" % -right


func _above(height: float) -> String:
	if absf(height) < 1.0:
		return ""
	return ", %.0f m %s it" % [absf(height), "above" if height > 0.0 else "below"]


# Did the correction keep the design, or replace it with something simpler?
# Compares the two proposals, not the built tracks, so a refused correction
# can be compared too.
func _compare_designs(before: Dictionary, after: Dictionary) -> Dictionary:
	if before.is_empty() or after.is_empty():
		return {}
	var before_counts: Dictionary = before.get("counts", {})
	var after_counts: Dictionary = after.get("counts", {})
	var type_changes := {}
	for key in before_counts:
		var change := int(after_counts.get(key, 0)) - int(before_counts[key])
		if change != 0:
			type_changes[key] = change
	var before_length := float(before.get("total_length", 0.0))
	var before_turning := float(before.get("direction_change_total", 0.0))
	return {
		"sections_before": int(before.get("section_count", 0)),
		"sections_after": int(after.get("section_count", 0)),
		"length_before": before_length,
		"length_after": float(after.get("total_length", 0.0)),
		"length_ratio": float(after.get("total_length", 0.0)) / before_length if before_length > 0.0 else 0.0,
		"turning_before": before_turning,
		"turning_after": float(after.get("direction_change_total", 0.0)),
		"type_changes": type_changes,
		"same_piece_counts": type_changes.is_empty(),
	}


# JSON can't hold infinity, so "nothing measured" is stored as -1.
func _finite(value: float) -> float:
	return value if is_finite(value) else -1.0
