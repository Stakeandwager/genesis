extends RefCounted
class_name SeparationCheck

# --- Prototype 002A - Step A5: Road separation (Protocol 002, sections 18-20) ---
# A track can close perfectly and still cross itself, or bring two stretches of
# road so close that their surfaces merge. This check requires separate
# stretches of road to stay at least MIN_SEPARATION apart, and records the
# closest approach as a metric for every track.
#
# What counts as "separate" (section 20, adjacency): two bits of road are
# separate when the driving distance between them is more than SEPARATE_RATIO
# times their straight-line distance. An ordinary bend never qualifies (even a
# 200 degree hairpin's own curve only reaches about 1.8x), while a road that
# loops back past itself qualifies easily. Pieces that follow each other,
# including across the start/finish join, are never compared, because driving
# distance is measured the short way round the loop.

const ROAD_WIDTH := 12.0
const SAFETY_MARGIN := 6.0
const MIN_SEPARATION := ROAD_WIDTH + SAFETY_MARGIN     # 18 m between centrelines
const SEPARATE_RATIO := 2.0
const ALONG_FLOOR := MIN_SEPARATION                    # never compare road closer than this along the track
const SPACING := 4.0


# sections must be the final, closed composition from the solver.
static func check(sections: Array) -> Dictionary:
	# A dense centreline: points, distance driven, and which section owns each point.
	var points := PackedVector2Array([Vector2.ZERO])
	var along := PackedFloat64Array([0.0])
	var owner := PackedInt32Array([0])
	var pos := Vector3.ZERO
	var heading := 0.0
	var driven := 0.0

	for i in sections.size():
		var samples := TrackGeometry.sample(pos, heading, sections[i])
		for k in range(1, samples.size()):
			var a: Vector3 = samples[k - 1][0]
			var b: Vector3 = samples[k][0]
			var length := a.distance_to(b)
			var pieces := maxi(1, int(ceil(length / SPACING)))
			for p in range(1, pieces + 1):
				var q := a.lerp(b, float(p) / float(pieces))
				driven += length / float(pieces)
				points.append(Vector2(q.x, q.z))
				along.append(driven)
				owner.append(i)
		var end_sample: Array = samples[samples.size() - 1]
		pos = end_sample[0]
		heading = end_sample[1]

	var total := driven
	var segments := points.size() - 1
	# Two segments are each at most SPACING long, so their true distance is at
	# least the distance between their start points minus this much.
	var slack := 2.0 * SPACING + 1.0

	var closest := INF
	var closest_pair := Vector2i(-1, -1)
	var crossings := {}

	for j in segments:
		var a1 := points[j]
		var a2 := points[j + 1]
		var mid_a := (along[j] + along[j + 1]) * 0.5
		for k in range(j + 1, segments):
			var mid_b := (along[k] + along[k + 1]) * 0.5
			var gap := absf(mid_b - mid_a)
			gap = minf(gap, total - gap)
			if gap <= ALONG_FLOOR:
				continue
			var b1 := points[k]
			# Quick reject: this pair can't be closer than the closest found so far.
			if a1.distance_to(b1) - slack > closest:
				continue
			var near := Geometry2D.get_closest_points_between_segments(a1, a2, b1, points[k + 1])
			var d := near[0].distance_to(near[1])
			# Same stretch of road bending, not a separate stretch.
			if gap <= SEPARATE_RATIO * d:
				continue
			var sa := owner[j + 1]
			var sb := owner[k + 1]
			if d < closest:
				closest = d
				closest_pair = Vector2i(mini(sa, sb), maxi(sa, sb))
			if d < 0.01:
				crossings["%d-%d" % [mini(sa, sb), maxi(sa, sb)]] = Vector2i(mini(sa, sb), maxi(sa, sb))

	var ok := closest >= MIN_SEPARATION
	var reasons: Array = []
	if not ok:
		for key in crossings:
			var pair: Vector2i = crossings[key]
			reasons.append("the road crosses itself: section %d (%s) and section %d (%s)" % [
				pair.x + 1, sections[pair.x]["type"], pair.y + 1, sections[pair.y]["type"]])
		if crossings.is_empty():
			reasons.append("section %d (%s) and section %d (%s) come within %.1f m of each other" % [
				closest_pair.x + 1, sections[closest_pair.x]["type"],
				closest_pair.y + 1, sections[closest_pair.y]["type"], closest])
		reasons.append("separate stretches of road must stay at least %.0f m apart" % MIN_SEPARATION)

	return {
		"ok": ok,
		"category": "" if ok else "FAILED_SEPARATION",
		"reasons": reasons,
		"minimum_separation": closest,
		"closest_sections": closest_pair,
		"self_intersections": crossings.size(),
		"required_separation": MIN_SEPARATION,
	}
