extends SceneTree

# VERIFIED LIVING WORLD, condition 5 - independent reproducibility.
#
# Every other test asks "did the code do the right thing?" This one asks a
# different question: "does the LEDGER say what happened?" - and it answers it
# the way an outsider would have to, by reading the records back off disk after
# the fact and auditing them against the world.
#
# That distinction is the whole product. A system can behave correctly and
# still keep a record nobody can check. If the ledger is the thing being sold,
# the ledger has to be auditable without trusting the process that wrote it.
#
# Two kinds of check, kept apart on purpose:
#
#   STRUCTURE   can the record be audited at all, by itself? Every order
#               resolved exactly once, every outcome pointing at a real order,
#               what was carried and where it started written down, the
#               carrier's account kept apart from the world's answer.
#
#   AGREEMENT   does the record's last claim match the world as it stands?
#               Only the LAST claim can be checked this way, because the
#               world has moved on since the earlier ones - and saying so is
#               part of being honest about what an audit can do.

var main: Node3D
var lines: Array = []
var failures: Array = []
var tag := ""

const ROOMS := "{\"name\": \"entrance\", \"width\": 12, \"depth\": 12}, {\"name\": \"middle\", \"width\": 12, \"depth\": 12}, {\"name\": \"vault\", \"width\": 12, \"depth\": 12}"


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


func _settle(limit := 90) -> void:
	var ticks := 0
	while ticks < Engine.physics_ticks_per_second * limit and main.npc != null and main.npc.state == Npc.GOING:
		ticks += 1
		await physics_frame


func _node_of(label: String) -> Node3D:
	for entry in (main.controller.standable.get("things", []) as Array):
		var t: Dictionary = entry
		if str(t["name"]) == label:
			var n = t["node"]
			return n if is_instance_valid(n) else null
	return null


func _room_of(node: Node3D) -> int:
	var module := DungeonModule.new()
	var holder: Node3D = main.controller.standable["node"]
	var local: Vector3 = holder.to_local(node.global_position)
	return module.room_of(main.controller.standable["layout"], Vector2(local.x, local.z))


func _run() -> void:
	_make_main()
	await process_frame

	# A session of its own, so the audit reads only this run's records even
	# though the ledger is a file that outlives it.
	await _type("/session audit-%d" % Time.get_ticks_msec())
	# The session's id is its name AND the moment it started, so the real id
	# has to be read rather than guessed - which is the same rule the whole
	# project runs on, applied to a test.
	tag = str(TrackLog.session.get("id", ""))
	_check(tag != "", "a session is running, tagged %s" % tag)

	await _type("{\"command\": \"CREATE_DUNGEON\", \"parameters\": {\"rooms\": [%s], \"doors\": [[1, 2], [2, 3]], \"things\": [{\"name\": \"red_key\", \"in\": 1}, {\"name\": \"blue_key\", \"in\": 1}]}}" % ROOMS)

	# Errand 1: a real delivery.
	await _type("{\"command\": \"ORDER\", \"parameters\": {\"goal\": \"carry\", \"thing\": \"red_key\", \"room\": \"vault\"}}")
	await _settle()

	# Errand 2: stopped short, so the blue key never leaves the entrance.
	await _type("{\"command\": \"ORDER\", \"parameters\": {\"goal\": \"carry\", \"thing\": \"blue_key\", \"room\": \"vault\"}}")
	await physics_frame
	main.npc.halt("stopped walking")
	await physics_frame

	# Errand 3: plain arrival, no object at all.
	await _type("{\"command\": \"ORDER\", \"parameters\": {\"goal\": \"go_to\", \"room\": 1}}")
	await _settle()

	await _type("/session end")
	await process_frame

	# --- read the ledger back off disk, as an outsider would ---
	var records: Array = TrackLog.read_session(tag)
	_check(not records.is_empty(), "the ledger can be read back from disk (%d records)" % records.size())

	var orders := {}
	var outcomes: Array = []
	for r in records:
		var record: Dictionary = r
		if str(record.get("command", "")) == "ORDER" and str(record.get("result", "")) == "VALID":
			orders[str(record["id"])] = record
		elif str(record.get("type", "")) == "outcome":
			outcomes.append(record)

	lines.append("  %d orders accepted, %d outcomes written" % [orders.size(), outcomes.size()])

	# --- STRUCTURE ---
	_check(orders.size() == 3, "every order the player gave is in the ledger")
	_check(outcomes.size() == 3, "and every one of them was resolved")

	var resolved := {}
	var orphans := 0
	for o in outcomes:
		var outcome: Dictionary = o
		var about := str(outcome.get("about", ""))
		if not orders.has(about):
			orphans += 1
		elif resolved.has(about):
			orphans += 1
		else:
			resolved[about] = outcome
	_check(orphans == 0, "no outcome points at an order that is not there, and none is resolved twice")
	_check(resolved.size() == orders.size(), "every order has exactly one outcome")

	var carried := 0
	for id in orders:
		var order: Dictionary = orders[id]
		var outcome: Dictionary = resolved.get(id, {})
		if str(order.get("thing", "")) == "":
			continue
		carried += 1
		_check(str(order.get("thing_from", "")) != "",
			"   the %s's order records where it started: %s" % [
				str(order["thing"]), str(order.get("thing_from", "(nothing)"))])
		_check(str(outcome.get("thing", "")) == str(order.get("thing", "")),
			"   and its outcome is about the same object")
		_check(outcome.has("carrier") and typeof(outcome["carrier"]) == TYPE_DICTIONARY,
			"   with the carrier's own account kept apart from the verdict")
		var account: Dictionary = outcome["carrier"]
		_check(str(account.get("said", "")) != str(outcome.get("outcome", "")),
			"   and the two are different statements: \"%s\" against %s" % [
				str(account.get("said", "")), str(outcome.get("outcome", ""))])
	_check(carried == 2, "two of the three errands carried something")

	# A record that can be audited WITHOUT the world: everything an outsider
	# needs is written down.
	var complete := true
	for o in outcomes:
		var outcome: Dictionary = o
		for field in ["outcome", "about", "time", "room_name"]:
			if not outcome.has(field):
				complete = false
	_check(complete, "every outcome carries what, where and when, without needing the game running")

	# --- AGREEMENT ---
	# Only the last claim about each object can be checked against the world,
	# because the world has moved on since the earlier ones. Saying which
	# claims an audit can and cannot settle is part of the audit.
	var module := DungeonModule.new()
	var rooms: Array = main.controller.standable["layout"]["rooms"]
	var checkable := 0
	for label in ["red_key", "blue_key"]:
		var last := {}
		for o in outcomes:
			var outcome: Dictionary = o
			if str(outcome.get("thing", "")) == label:
				last = outcome
		if last.is_empty():
			continue
		var node := _node_of(label)
		if node == null:
			continue
		checkable += 1
		var here := _room_of(node)
		var here_name := str(rooms[here]["name"]) if here >= 0 else "(no room)"
		var claim := str(last["outcome"])
		var said_room := str(last["room_name"])
		var said_where := str(last.get("thing_in", ""))
		var agrees := false
		if claim == "DELIVERED":
			agrees = here_name == said_room
		elif claim == "NOT_DELIVERED":
			agrees = here_name != said_room and (said_where == "" or said_where == here_name)
		lines.append("  %s: ledger says %s (%s), world says %s" % [
			label, claim, said_where if said_where != "" else said_room, here_name])
		_check(agrees, "   the ledger's last claim about the %s matches the world" % label.replace("_", " "))
	_check(checkable == 2, "both objects could be checked against the world")

	print("")
	for l in lines:
		print(l)
	print("LEDGER AUDIT failures=%d" % failures.size())
	quit(failures.size())
