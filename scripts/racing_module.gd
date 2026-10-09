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
# --- 002H: racing describes itself ---
# Racing's rules used to live in the standing instructions in
# ai_interpreter.gd, which made it the one world the AI was told about by
# hand. They are now here, where every other world keeps its own, so adding
# or removing a world is one file and nothing else.
#
# SECTION TYPES and RULES FOR A CLOSED CIRCUIT below are byte for byte what
# the standing instructions used to say; only their place has changed. Two
# things did change: the heading now names the command the way every other
# world does, and the STYLE paragraph moved into the core instructions,
# because every world records a style, not just this one. The AI is also no
# longer introduced to Genesis as a racing game. PROMPT_VERSION moves with
# all of that, so these tracks are not compared with the old ones.

func command() -> String:
	return "CREATE_TRACK"


func display_name() -> String:
	return "circuit"


# Everything the AI needs to compose a closed circuit, and nothing about
# style: what a style word does to the geometry is what the experiment
# measures, so it is never described here.
func prompt_section() -> String:
	return """CREATE_TRACK - design a closed racing circuit
{"command": "CREATE_TRACK", "parameters": {"mode": "circuit", "intent": {"style": STYLE}, "sections": [SECTION, SECTION, ...]}}

SECTION TYPES (only these four, with exactly these fields)
straight: {"type": "straight", "length": L} where L is 20 to 1000 metres
corner: {"type": "corner", "radius": R, "angle": A} where R is 15 to 300 metres and A is 10 to 120 degrees
hairpin: {"type": "hairpin", "radius": R, "angle": A} where R is 10 to 60 metres and A is 120 to 200 degrees
chicane: {"type": "chicane", "radius": R, "offset": O, "direction": "left" or "right"} where R is 15 to 150 metres and O is more than 0 and at most 2 x R
Angles are signed: positive turns right, negative turns left. Never give a corner, hairpin or chicane a length; it is calculated. A chicane steps the track sideways by O metres and returns to its original direction.

RULES FOR A CLOSED CIRCUIT
- Sections join end to end, in order, starting at the start line. After the last section the track must arrive back at the start line, facing the way it started.
- Corner and hairpin angles must add up to exactly +360 (clockwise) or -360 (anticlockwise). Chicanes do not count.
- Travel in opposite directions must balance. Every metre the track travels away from the start line must be matched by a metre travelled back towards it, and every metre to the right of the start line by a metre back to the left. Angles adding up to 360 is necessary but not enough on its own: a hairpin reverses the direction of travel, but by itself carries the track back only by its own width, twice its radius.
- Use at least 2 straights and at least 2 corners or hairpins.
- The game can adjust each angle and each straight length by up to 20% to close the loop, so plan where every section takes the track so that it very nearly closes by itself.
- The road must never cross itself, and separate parts of the road must stay at least 18 metres apart."""


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


# How much ground the circuit covers, measured from the sections rather than
# from built geometry, so a plan can know it before building anything.
func extent(layout: Dictionary) -> Vector2:
	var box := TrackGeometry.bounds(layout["sections"])
	return (box[1] as Vector2) - (box[0] as Vector2)


# A circuit cannot grow. Its shape IS the design: the straights are the
# lengths the player asked for and the corners the radii they asked for.
# Stretching it to fit round something else would quietly hand them a
# different track. So racing opts out, and the other world grows instead.
func can_grow() -> bool:
	return false


# The circuit is built by its own CircuitBuilder, a child of root, so a plan
# can move it by moving root. Driving finds it through the "drivable" entry.
func build(root: Node3D, layout: Dictionary) -> Dictionary:
	var circuit := CircuitBuilder.new()
	circuit.name = "CircuitBuilder"
	root.add_child(circuit)
	var report := circuit.build(layout["sections"], false)
	report["drivable"] = {"node": circuit, "road_height": CircuitBuilder.ROAD_HEIGHT}
	report["direction"] = "clockwise" if float(layout["target_turn"]) > 0.0 else "anticlockwise"
	return report


func summary(_metrics: Dictionary, report: Dictionary) -> String:
	return "CREATE_TRACK built a closed %s circuit: %d sections, %.0f m of road\n(full measurements in the metrics panel)" % [
		report["direction"], report["section_count"], report["total_length"]]


# "a closed circuit with two 300 m straights, two 200 m straights and
#  50 m corners"
#
# Straights are grouped by length and corners by radius, because that is how
# a player describes a track: "two long straights", "tight corners". The
# number of sections is not read out - nobody asks for eight sections.
func readback(parameters: Dictionary) -> String:
	var raw = parameters.get("sections", null)
	if typeof(raw) != TYPE_ARRAY or (raw as Array).is_empty():
		return "a closed racing circuit"

	# Straights before corners, however the AI ordered the sections. The
	# sections go round in a sequence, but a player hears a description as a
	# list of parts, and "two straights, two corners" reads where "straights,
	# corners, more straights" does not.
	# Every section type the validator accepts, not only the four the AI is
	# told about. A track typed as raw JSON, or a later prompt that offers
	# more pieces, must still be described in full. A readback that silently
	# drops a piece is the worst kind: not wrong, just absent, so the player
	# has no way to see that it went missing. A headless test caught exactly
	# that - four straights and four banked corners read back as "four 250 m
	# straights", with the banking gone.
	var rank := {
		"straight": 0, "uphill": 1, "downhill": 1, "crest": 1, "dip": 1,
		"corner": 2, "banked_corner": 2, "hairpin": 3, "loop_segment": 4,
		"chicane": 5,
	}
	var order: Array = []
	var groups := {}
	for entry in (raw as Array):
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var section: Dictionary = entry
		var type := str(section.get("type", "")).to_lower()
		if type == "":
			continue
		var measure := 0.0
		var singular := ""
		var plural := ""
		match type:
			"straight":
				measure = float(section.get("length", 0.0))
				singular = "%.0f m straight" % measure
				plural = "%.0f m straights" % measure
			"uphill", "downhill":
				measure = float(section.get("length", 0.0))
				singular = "%.0f m %s at %.0f%%" % [measure, type, float(section.get("grade", 0.0))]
				plural = "%.0f m %ss at %.0f%%" % [measure, type, float(section.get("grade", 0.0))]
			"crest", "dip":
				measure = float(section.get("length", 0.0))
				singular = "%.0f m %s" % [measure, type]
				plural = "%.0f m %ss" % [measure, type]
			"corner", "hairpin":
				measure = float(section.get("radius", 0.0))
				singular = "%.0f m %s" % [measure, type]
				plural = "%.0f m %ss" % [measure, type]
			"banked_corner":
				measure = float(section.get("radius", 0.0))
				singular = "%.0f m corner banked at %.0f deg" % [measure, float(section.get("bank", 0.0))]
				plural = "%.0f m corners banked at %.0f deg" % [measure, float(section.get("bank", 0.0))]
			"loop_segment":
				measure = float(section.get("radius", 0.0))
				singular = "%.0f m loop" % measure
				plural = "%.0f m loops" % measure
			"chicane":
				measure = float(section.get("offset", 0.0))
				singular = "%.0f m chicane" % measure
				plural = "%.0f m chicanes" % measure
			_:
				# A piece this readback has never heard of is named rather
				# than dropped, so adding a section type can make the wording
				# plain but can never make a piece disappear.
				singular = type.replace("_", " ")
				plural = singular + "s"
		var key := "%s|%.0f" % [type, measure]
		if not groups.has(key):
			groups[key] = {"singular": singular, "plural": plural, "count": 0,
				"rank": int(rank.get(type, 9)), "measure": measure}
			order.append(key)
		groups[key]["count"] = int(groups[key]["count"]) + 1

	# Longest first within a kind, so "two 800 m straights" leads.
	order.sort_custom(func(a, b): return _before(groups[a], groups[b]))

	var parts := PackedStringArray()
	for key in order:
		var g: Dictionary = groups[key]
		parts.append(Readback.count_of(int(g["count"]), str(g["singular"]), str(g["plural"])))

	if parts.is_empty():
		return "a closed racing circuit"
	return "a closed circuit with " + Readback.join_capped(parts)


func _before(a: Dictionary, b: Dictionary) -> bool:
	if int(a["rank"]) != int(b["rank"]):
		return int(a["rank"]) < int(b["rank"])
	return float(a["measure"]) > float(b["measure"])


func readback_short(_parameters: Dictionary) -> String:
	return "a race circuit"


# The panel racing has always shown, in the same order, moved here from
# main.gd unchanged. The last three come from the record rather than the
# measurements: they describe how the track came to be built.
func metric_lines(metrics: Dictionary, record: Dictionary) -> Array:
	var counts: Dictionary = metrics.get("counts", {})
	var lines: Array = [
		["SECTIONS", "%d  (%d straight, %d corner, %d hairpin, %d chicane)" % [
			int(metrics["section_count"]), int(counts.get("straight", 0)), int(counts.get("corner", 0)),
			int(counts.get("hairpin", 0)), int(counts.get("chicane", 0))]],
		["LENGTH", "%.0f m" % float(metrics["total_length"])],
		["STRAIGHT RATIO", "%.0f%%" % (float(metrics["straight_ratio"]) * 100.0)],
		["LONGEST STRAIGHT", "%.0f m" % float(metrics["longest_straight"])],
		["SHORTEST STRAIGHT", "%.0f m" % float(metrics["shortest_straight"])],
		["TIGHTEST RADIUS", "%.0f m" % float(metrics["minimum_radius"])],
		["DIRECTION CHANGE", "%.0f deg" % float(metrics["direction_change_total"])],
	]

	if record.has("closure"):
		var c: Dictionary = record["closure"]
		lines.append(["CLOSURE ERROR", "%.2f m, %.2f deg" % [
			float(c["closure_distance"]), float(c["closure_heading_error"])]])
	if record.has("separation"):
		var sep: Dictionary = record["separation"]
		lines.append(["SELF-INTERSECTIONS", "%d" % int(sep["self_intersections"])])
		# -1 means no two stretches of road are far enough apart along the
		# track to count as separate (a round track, say): nothing could cross.
		if float(sep["minimum_separation"]) < 0.0:
			lines.append(["MIN SEPARATION", "none (no separate stretches)"])
		else:
			lines.append(["MIN SEPARATION", "%.1f m" % float(sep["minimum_separation"])])
	if record.has("drift"):
		var d: Dictionary = record["drift"]
		lines.append(["SOLVER CHANGE", "corners %.1f%%, straights %.1f%%" % [
			float(d["max_angle_adjustment"]) * 100.0, float(d["max_length_adjustment"]) * 100.0]])
	return lines


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
