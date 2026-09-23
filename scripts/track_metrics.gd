extends RefCounted
class_name TrackMetrics

# --- Prototype 002A - Step A6: Track metrics (Protocol 002, sections 22-29) ---
# Measures a composition from its geometry alone. Nothing here trusts a label:
# a track is "technical" only if these numbers say so.

static func measure(sections: Array) -> Dictionary:
	var counts := {"straight": 0, "corner": 0, "hairpin": 0, "chicane": 0}
	var total := 0.0
	var straight_total := 0.0
	var straights: Array = []
	var min_radius := INF
	var direction_change := 0.0
	var net_turn := 0.0

	for s in sections:
		var t := str(s["type"])
		if counts.has(t):
			counts[t] += 1
		var length := TrackGeometry.section_length(s)
		total += length
		match t:
			"straight":
				straight_total += length
				straights.append(length)
			"corner", "hairpin":
				min_radius = minf(min_radius, float(s["radius"]))
				var angle := float(s["angle"])
				net_turn += angle
				direction_change += absf(angle)
			"chicane":
				min_radius = minf(min_radius, float(s["radius"]))
				# Two arcs, each turning theta: 2 * theta of direction change.
				direction_change += 2.0 * rad_to_deg(absf(TrackGeometry.chicane_turn(s)))

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
	}
