extends SceneTree
func _initialize() -> void:
	var m := FarmModule.new()
	var bad := 0

	# the request that used to be refused
	var one := {"zones": [{"type": "barn", "width": 20, "depth": 20}]}
	var v := m.validate(one)
	if not bool(v["ok"]):
		print("FAIL  one zone rejected: ", v["errors"]); bad += 1
	else:
		var solved := m.solve(v["content"])
		if not bool(solved["ok"]):
			print("FAIL  one zone would not lay out: ", solved["reasons"]); bad += 1
		else:
			var e: Vector2 = m.extent(solved["layout"])
			var metrics := m.measure(solved["layout"])
			print("PASS  one zone: %s  ->  %.0f x %.0f m, %d zone, fence %.0f m" % [
				m.readback(one), e.x, e.y, int(metrics["zone_count"]), float(metrics["fence_length"])])

	# zero zones must still be refused
	if bool(m.validate({"zones": []})["ok"]):
		print("FAIL  zero zones accepted"); bad += 1
	else:
		print("PASS  zero zones still refused")

	# too many still refused
	var many: Array = []
	for i in 30:
		many.append({"type": "crop", "crop": "corn", "width": 20, "depth": 20})
	if bool(m.validate({"zones": many})["ok"]):
		print("FAIL  30 zones accepted"); bad += 1
	else:
		print("PASS  30 zones still refused")

	# a normal farm is unchanged
	var two := {"zones": [{"type": "barn", "width": 20, "depth": 20}, {"type": "pond", "width": 50, "depth": 50}]}
	if not bool(m.validate(two)["ok"]):
		print("FAIL  two zones broke"); bad += 1
	else:
		print("PASS  two zones unchanged: %s" % m.readback(two))

	print("FARM TEST failures=%d" % bad)
	quit(bad)
