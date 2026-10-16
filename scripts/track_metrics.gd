extends RefCounted
class_name TrackMetrics

# --- Prototype 002B: Track metrics ---
# Measures a composition from its geometry alone. Nothing here trusts a label:
# a track is "technical" only if these numbers say so.
#
# Every section type in the validator must appear here, or tracks using it are
# silently mismeasured. Adding a type means touching the validator, the
# geometry, the builder AND this file.

# 049: these three lists were declared HERE as well as in TrackGeometry, and
# every other reader in Genesis - the closure solver, the feasibility gate and
# two suites - reads TrackGeometry's. The copies were byte-identical, so
# nothing was ever mismeasured; what was wrong is that the panel decided which
# sections are straight and which turn from a list nothing else obeyed, in the
# one file whose header warns that a new type has to be added in four places.
# One reading (TRAPS 36). tests/panel_geometry_test.gd asserts the
# consequence rather than the list: for every type the validator accepts, the
# panel's classification is the geometry's.


static func measure(sections: Array) -> Dictionary:
	# 049: enumerated from the validator's own list, not written out here.
	# This was the fourth copy of a section-type list in this file, and the
	# one with teeth: `counts.has(t)` below decides whether a section is
	# counted at all, and RacingModule._counted() - which renders the
	# parenthetical after SECTIONS - already enumerates from
	# SectionValidator.SECTION_TYPES and reads counts.get(type, 0). So a type
	# added to the validator and not to this literal would have made the
	# panel say "0 loop_segments" on a circuit with one, on the same line as a
	# SECTIONS count that included it. Byte-identical today: the literal held
	# all ten (TRAPS 11, TRAPS 31).
	var counts := {}
	for type in SectionValidator.SECTION_TYPES:
		counts[type] = 0
	var total := 0.0
	var straight_total := 0.0
	var straights: Array = []
	var min_radius := INF
	var direction_change := 0.0
	var net_turn := 0.0

	# Vertical measurements
	var climb_total := 0.0
	var descent_total := 0.0
	var max_grade := 0.0
	var max_bank := 0.0
	var height := 0.0
	var highest := 0.0
	var lowest := 0.0

	for s in sections:
		var t := str(s["type"])
		if counts.has(t):
			counts[t] += 1

		var length := TrackGeometry.section_length(s)
		total += length

		if t in TrackGeometry.STRAIGHT_FAMILY:
			straight_total += length
			straights.append(length)
		if t in TrackGeometry.CURVED_TYPES:
			min_radius = minf(min_radius, float(s.get("radius", INF)))
		if t in TrackGeometry.YAW_TYPES:
			var angle := float(s["angle"])
			net_turn += angle
			direction_change += absf(angle)
		if t == "chicane":
			# Two arcs, each turning theta: 2 * theta of direction change, no net turn.
			direction_change += 2.0 * rad_to_deg(absf(TrackGeometry.chicane_turn(s)))

		max_grade = maxf(max_grade, absf(float(s.get("grade", 0.0))))
		max_bank = maxf(max_bank, absf(float(s.get("bank", 0.0))))

		# Height: crests and dips return to their starting height, but they
		# still climb and descend on the way.
		var change := TrackGeometry.height_change(s)
		if t == "crest" or t == "dip":
			var swing := absf(float(s.get("length", 0.0)) * sin(TrackGeometry.pitch_of(s))) * 0.5
			climb_total += swing
			descent_total += swing
			highest = maxf(highest, height + swing) if t == "crest" else highest
			lowest = minf(lowest, height - swing) if t == "dip" else lowest
		elif change > 0.0:
			climb_total += change
		else:
			descent_total += absf(change)

		height += change
		highest = maxf(highest, height)
		lowest = minf(lowest, height)

	var longest := 0.0
	var shortest := 0.0
	var average := 0.0
	if not straights.is_empty():
		longest = straights.max()
		shortest = straights.min()
		average = straight_total / float(straights.size())

	return {
		"section_count": sections.size(),
		"counts": counts,
		"total_length": total,
		"straight_length": straight_total,
		"straight_ratio": straight_total / total if total > 0.0 else 0.0,
		"number_of_straights": straights.size(),
		"longest_straight": longest,
		"shortest_straight": shortest,
		"average_straight": average,
		"minimum_radius": min_radius if min_radius < INF else -1.0,
		"direction_change_total": direction_change,
		"net_turn": net_turn,
		"climb_total": climb_total,
		"descent_total": descent_total,
		"height_range": highest - lowest,
		"height_closure_error": height,
		"max_grade": max_grade,
		"max_bank": max_bank,
	}
