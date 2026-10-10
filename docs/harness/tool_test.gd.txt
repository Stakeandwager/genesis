extends SceneTree
func _initialize() -> void:
	var t := CarTool.new()
	var bad := 0
	var cases := [
		["asked for nothing", {"tool":"car"}, true, "the ordinary red car"],
		["more power", {"tool":"car","spec":{"power":1600}}, true, "accelerates hard"],
		["weak and slippery", {"tool":"car","spec":{"power":450,"grip":3}}, true, "is slow off the line"],
		["painted", {"tool":"car","spec":{"paint":"blue"}}, true, "ordinary blue car"],
		["named", {"tool":"car","spec":{"paint":"black","nickname":"The Ghost"}}, true, "The Ghost"],
		["everything up", {"tool":"car","spec":{"power":1800,"braking":30,"steering":40,"grip":20}}, true, "grips well"],
	]
	for c in cases:
		var r := t.validate(c[1])
		if bool(r["ok"]) != bool(c[2]):
			bad += 1; print("FAIL  %s: %s" % [c[0], r["errors"]]); continue
		var line := t.readback(r["spec"])
		if not line.contains(str(c[3])):
			bad += 1; print("FAIL  %-18s %s\n      expected to contain: %s" % [c[0], line, c[3]])
		else:
			print("PASS  %-18s %s" % [c[0], line])

	# out of range is refused, not quietly clamped
	for bad_spec in [{"power":5000}, {"power":10}, {"grip":100}, {"steering":90}]:
		var r := t.validate({"tool":"car","spec":bad_spec})
		if bool(r["ok"]):
			bad += 1; print("FAIL  out of range accepted: ", bad_spec)
	print("PASS  out-of-range specs refused")

	# a field that does not exist, and a paint that does not exist
	if bool(t.validate({"tool":"car","spec":{"wings":true}})["ok"]):
		bad += 1; print("FAIL  invented field accepted")
	else:
		print("PASS  invented field refused")
	if bool(t.validate({"tool":"car","spec":{"paint":"octarine"}})["ok"]):
		bad += 1; print("FAIL  invented paint accepted")
	else:
		print("PASS  invented paint refused")

	# the registry
	if ToolRegistry.find("car") == null: bad += 1; print("FAIL  car not registered")
	if ToolRegistry.find("hovercraft") != null: bad += 1; print("FAIL  unregistered tool found")
	var free: Dictionary = ToolRegistry.free_kit()
	if absf(float(free["car"]["power"]) - 900.0) > 0.001:
		bad += 1; print("FAIL  free car is not the old car: ", free["car"])
	else:
		print("PASS  free kit is exactly the old car (power 900, grip 9, 29 deg)")
	print("TOOL TEST failures=%d" % bad)
	quit(bad)
