extends SceneTree

# VERIFIED LIVING WORLD - the repeatable row.
#
# "Resetting and replaying the same test under the same conditions produces
# reproducible results."
#
# This matters more than it looks. Every other test here runs an errand once
# and judges the answer. If the answer is not stable, a passing suite means
# only that the dice fell well that time, and a failure found in the editor
# could never be reproduced here. A ledger nobody can reproduce is not
# evidence, it is an anecdote.
#
# So: the same world, the same order, three times over, from a fresh dungeon
# each time. The verdict must be identical, and the measurements must agree
# closely enough that a difference would mean something.

var main: Node3D
var lines: Array = []
var failures: Array = []

const ROOMS := "{\"name\": \"entrance\", \"width\": 12, \"depth\": 12}, {\"name\": \"middle\", \"width\": 12, \"depth\": 12}, {\"name\": \"vault\", \"width\": 12, \"depth\": 12}"
const RUNS := 3
const SPREAD := 0.5          # metres; how far apart two runs may land


func _check(ok: bool, what: String) -> void:
	lines.append(("PASS  " if ok else "FAIL  ") + what)
	if not ok:
		failures.append(what)


func _initialize() -> void:
	_run.call_deferred()


func _make_main() -> void:
	main = Node3D.new()
	main.name = "Main"
	main.set_script(load("res://scripts/main.gd"))
	var cam := Camera3D.new()
	cam.name = "Camera3D"
	cam.position = Vector3(0, 80, 120)
	main.add_child(cam)
	var ground := Node3D.new()
	ground.name = "Ground"
	main.add_child(ground)
	var box := CSGBox3D.new()
	box.name = "CSGBox3D"
	box.size = Vector3(400, 1, 400)
	box.position = Vector3(0, -0.5, 0)
	box.use_collision = true
	ground.add_child(box)
	var ui := CanvasLayer.new()
	ui.name = "UI"
	main.add_child(ui)
	var panel := PanelContainer.new()
	panel.name = "CommandPanel"
	ui.add_child(panel)
	var vb := VBoxContainer.new()
	vb.name = "VBoxContainer"
	panel.add_child(vb)
	for pair in [["InputBox", LineEdit.new()], ["BuildButton", Button.new()], ["StatusLabel", Label.new()]]:
		pair[1].name = pair[0]
		vb.add_child(pair[1])
	get_root().add_child(main)


func _type(text: String) -> void:
	main._handle_request(text)
	await process_frame
	await process_frame


# One run, from a fresh dungeon, returning what the ledger said about it.
func _once() -> Dictionary:
	await _type("{\"command\": \"CREATE_DUNGEON\", \"parameters\": {\"rooms\": [%s], \"doors\": [[1, 2], [2, 3]], \"things\": [{\"name\": \"red_key\", \"in\": 1}]}}" % ROOMS)
	if main.npc != null:
		main.npc.queue_free()
		main.npc = null
	await physics_frame

	await _type("{\"command\": \"ORDER\", \"parameters\": {\"goal\": \"carry\", \"thing\": \"red_key\", \"room\": \"vault\"}}")
	var ticks := 0
	while ticks < Engine.physics_ticks_per_second * 90 and main.npc != null and main.npc.state == Npc.GOING:
		ticks += 1
		await physics_frame

	var record: Dictionary = main.controller.last_outcome_record
	var carrier: Dictionary = record.get("carrier", {})
	var steps := PackedStringArray()
	for step in (carrier.get("attempted", []) as Array):
		steps.append("%s/%s" % [str((step as Dictionary)["action"]), str((step as Dictionary)["result"])])
	return {
		"outcome": str(record.get("outcome", "")),
		"where": str(record.get("thing_in", "")),
		"travelled": float(carrier.get("travelled", 0.0)),
		"seconds": float(carrier.get("seconds", 0.0)),
		"attempted": ", ".join(steps),
	}


func _run() -> void:
	_make_main()
	await process_frame

	var runs: Array = []
	for i in RUNS:
		var result: Dictionary = await _once()
		runs.append(result)
		lines.append("  run %d: %-14s %-6s  %.1f m  %.1f s  [%s]" % [
			i + 1, str(result["outcome"]),
			str(result["where"]) if str(result["where"]) != "" else "vault",
			float(result["travelled"]), float(result["seconds"]), str(result["attempted"])])

	var first: Dictionary = runs[0]
	var same_verdict := true
	var same_attempts := true
	var widest := 0.0
	for r in runs:
		var run: Dictionary = r
		if str(run["outcome"]) != str(first["outcome"]) or str(run["where"]) != str(first["where"]):
			same_verdict = false
		if str(run["attempted"]) != str(first["attempted"]):
			same_attempts = false
		widest = maxf(widest, absf(float(run["travelled"]) - float(first["travelled"])))

	_check(str(first["outcome"]) == "DELIVERED", "the errand succeeds on the first run")
	_check(same_verdict, "all %d runs reach the same verdict" % RUNS)
	_check(same_attempts, "and the same attempted actions, in the same order")
	_check(widest <= SPREAD,
		"and agree on the distance walked to within %.2f m (widest gap %.2f m)" % [SPREAD, widest])

	print("")
	for l in lines:
		print(l)
	print("REPEAT TEST failures=%d" % failures.size())
	quit(failures.size())
