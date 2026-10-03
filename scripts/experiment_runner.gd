extends Node
class_name ExperimentRunner

# --- Prototype 002A - Step A8: The experiment (Protocol 002, sections 43-46) ---
# Asks the AI for the same kind of track many times over, changing only the
# style word, and compares what actually got built.
#
# Requests are deliberately identical apart from that one word, so any
# difference in the geometry can only come from the word. Every attempt goes
# through exactly the same pipeline as a hand-typed one: nothing is skipped
# or made easier for the experiment.
#
# 002C: with closure feedback on, a trial whose first circuit misses the start
# line gets one correction. The trial counts once, by its final result; the
# summary reports first-try and corrected results separately, and whether the
# correction kept the design. /revise off gives a like-for-like baseline.

signal finished(summary_text: String)
signal progress(text: String)

const STYLES := ["technical", "high speed", "balanced"]
const PHRASE := "build me a %s circuit"
const MAX_RETRIES := 2

# Pauses, in seconds. The free API tier limits how fast requests may arrive.
var delay_between := 5.0
var delay_after_busy := 30.0

var running := false
var trials_per_style := 20
var results: Array = []
var run_id := ""

var _style_index := 0
var _trial := 0
var _retries := 0
var _main: Node
var _controller: GameController
var _interpreter: AIInterpreter


func setup(main_node: Node, controller: GameController, interpreter: AIInterpreter) -> void:
	_main = main_node
	_controller = controller
	_interpreter = interpreter
	_controller.track_measured.connect(_on_track_measured)
	_interpreter.interpretation_failed.connect(_on_ai_failed)


func start(count: int) -> String:
	if running:
		return "An experiment is already running. Type /stop to end it."
	if not _interpreter.is_available():
		return "No API key, so the experiment cannot run."

	trials_per_style = clampi(count, 1, 50)
	results.clear()
	_style_index = 0
	_trial = 0
	_retries = 0
	running = true
	run_id = "run_" + Time.get_datetime_string_from_system().replace(":", "-")

	var total := trials_per_style * STYLES.size()
	_next()
	var feedback_note := "Closure feedback is ON (one correction per missed circuit)." if _controller.revision_enabled else "Closure feedback is OFF (baseline)."
	return feedback_note + "\nExperiment %s started: %d tracks for each of %d styles, %d in total.\nAt about %d seconds each this takes roughly %d minutes. Type /stop to end it early." % [run_id, trials_per_style, STYLES.size(), total, int(delay_between) + 5, int(ceil(total * (delay_between + 5.0) / 60.0))]


func stop() -> String:
	if not running:
		return "No experiment is running."
	running = false
	return "Experiment stopped after %d tracks. Type /experiment to start a new one." % results.size()


func status() -> String:
	if not running:
		return "No experiment is running."
	return "Experiment %s: %d of %d done, currently asking for %s circuits." % [run_id, results.size(), trials_per_style * STYLES.size(), STYLES[mini(_style_index, STYLES.size() - 1)]]


# --- the loop ---

func _next() -> void:
	if not running:
		return
	if _style_index >= STYLES.size():
		_summarise()
		return

	var style: String = STYLES[_style_index]
	progress.emit("Experiment: %s circuit %d of %d (%d done overall)" % [style, _trial + 1, trials_per_style, results.size()])
	_main._handle_request(PHRASE % style, {
		"run_id": run_id,
		"style_asked": style.replace(" ", "_"),
		"trial": _trial + 1,
		"revision_enabled": _controller.revision_enabled,
	})


func _on_track_measured(record: Dictionary) -> void:
	if not running:
		return
	# A first attempt that is about to be corrected is logged, but the trial
	# is decided by the correction.
	if bool(record.get("revision_pending", false)):
		progress.emit("Experiment: circuit missed the start line, asking for one correction...")
		return
	results.append(record)
	_retries = 0
	_advance()


func _on_ai_failed(reason: String) -> void:
	if not running:
		return

	# Network trouble and rate limits are worth retrying; they are not results.
	if _retries < MAX_RETRIES:
		_retries += 1
		var wait := delay_after_busy if reason.contains("busy") or reason.contains("too many") else delay_between
		progress.emit("Experiment: the AI failed (%s). Retry %d of %d in %d seconds." % [reason, _retries, MAX_RETRIES, int(wait)])
		_wait_then(wait, _next)
		return

	var record := {
		"time": Time.get_datetime_string_from_system(),
		"experiment": {"run_id": run_id, "style_asked": STYLES[_style_index].replace(" ", "_"), "trial": _trial + 1},
		"result": "FAILED",
		"category": "FAILED_AI",
		"reasons": [reason],
	}
	TrackLog.append(record)
	results.append(record)
	_retries = 0
	_advance()


func _advance() -> void:
	_trial += 1
	if _trial >= trials_per_style:
		_trial = 0
		_style_index += 1
	_wait_then(delay_between, _next)


func _wait_then(seconds: float, action: Callable) -> void:
	if not running:
		return
	await get_tree().create_timer(seconds).timeout
	action.call()


# --- results ---

func _summarise() -> void:
	running = false

	var lines := PackedStringArray()
	lines.append("EXPERIMENT %s COMPLETE: %d tracks" % [run_id, results.size()])

	var summary := {"run_id": run_id, "type": "experiment_summary", "trials_per_style": trials_per_style, "revision_enabled": _controller.revision_enabled, "styles": {}}
	lines.append("Closure feedback: " + ("on" if _controller.revision_enabled else "off"))

	for entry in STYLES:
		var style := str(entry)
		var key := style.replace(" ", "_")
		var mine: Array = []
		var valid: Array = []
		var failures := {}
		for r in results:
			var experiment = r.get("experiment", {})
			if typeof(experiment) != TYPE_DICTIONARY or str(experiment.get("style_asked", "")) != key:
				continue
			mine.append(r)
			if str(r.get("result", "")) == "VALID":
				valid.append(r)
			else:
				var category := str(r.get("category", "unknown"))
				failures[category] = int(failures.get(category, 0)) + 1

		var style_summary := {"asked": mine.size(), "valid": valid.size(), "failures": failures}
		lines.append("")
		lines.append("%s: %d of %d became a track" % [style, valid.size(), mine.size()])

		# First try versus after one correction.
		var corrected: Array = []
		var rescued: Array = []
		for r in mine:
			if int(r.get("attempt", 1)) == 2:
				corrected.append(r)
				if str(r.get("result", "")) == "VALID":
					rescued.append(r)
		var first_try := valid.size() - rescued.size()
		style_summary["first_try_valid"] = first_try
		style_summary["corrected"] = corrected.size()
		style_summary["rescued"] = rescued.size()
		if not corrected.is_empty():
			lines.append("  first try %d, corrections asked %d, rescued %d" % [first_try, corrected.size(), rescued.size()])
			var first_miss := 0.0
			for r in corrected:
				first_miss += float(r.get("revision_of", {}).get("proposal_distance", 0.0))
			first_miss /= float(corrected.size())
			style_summary["average_first_miss"] = first_miss
			lines.append("  first attempts missed by %.0f m on average" % first_miss)
		if not rescued.is_empty():
			var kept := 0
			var sections_before := 0.0
			var sections_after := 0.0
			var length_ratio := 0.0
			for r in rescued:
				var c: Dictionary = r.get("revision_comparison", {})
				if bool(c.get("same_piece_counts", false)):
					kept += 1
				sections_before += float(c.get("sections_before", 0))
				sections_after += float(c.get("sections_after", 0))
				length_ratio += float(c.get("length_ratio", 0.0))
			var n := float(rescued.size())
			style_summary["rescued_kept_pieces"] = kept
			style_summary["rescued_sections_before"] = sections_before / n
			style_summary["rescued_sections_after"] = sections_after / n
			style_summary["rescued_length_ratio"] = length_ratio / n
			lines.append("  rescued designs: %d of %d kept the same pieces; sections %.1f -> %.1f; length x%.2f" % [
				kept, rescued.size(), sections_before / n, sections_after / n, length_ratio / n])

		if valid.is_empty():
			lines.append("  no valid tracks to measure")
		else:
			var averages := {
				"straight_ratio": _average(valid, "straight_ratio"),
				"longest_straight": _average(valid, "longest_straight"),
				"minimum_radius": _average(valid, "minimum_radius"),
				"direction_change_total": _average(valid, "direction_change_total"),
				"total_length": _average(valid, "total_length"),
				"section_count": _average(valid, "section_count"),
			}
			style_summary["averages"] = averages
			lines.append("  straight ratio %.0f%%, longest straight %.0f m" % [averages["straight_ratio"] * 100.0, averages["longest_straight"]])
			lines.append("  tightest radius %.0f m, direction change %.0f deg" % [averages["minimum_radius"], averages["direction_change_total"]])
			lines.append("  length %.0f m, %.1f sections" % [averages["total_length"], averages["section_count"]])

		if not failures.is_empty():
			var parts := PackedStringArray()
			for category in failures:
				parts.append("%d %s" % [failures[category], str(category).replace("FAILED_", "").to_lower()])
			lines.append("  failures: " + ", ".join(parts))

		summary["styles"][key] = style_summary

	lines.append("")
	lines.append("Full data: " + TrackLog.location())

	TrackLog.append(summary)
	finished.emit("\n".join(lines))


func _average(records: Array, field: String) -> float:
	var total := 0.0
	var count := 0
	for r in records:
		var m = r.get("metrics", {})
		if typeof(m) == TYPE_DICTIONARY and m.has(field):
			total += float(m[field])
			count += 1
	return total / float(count) if count > 0 else 0.0
