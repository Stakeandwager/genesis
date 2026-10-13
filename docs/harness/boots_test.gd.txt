extends SceneTree

# 010 - the boots as something you can ask for, and the first validator in
# Genesis that bounds a CONSEQUENCE rather than a field.
#
# A spec can have every number inside its limits and still be absurd: push 600
# on a 50 kg body with 0.4 footing settles at 30 m/s, a car's pace on foot. So
# the speed the three come to is bounded as well, and the refusal names what
# the combination would do rather than pointing at a field, because no single
# field is at fault.

var lines: Array = []
var failures: Array = []


func _check(ok: bool, what: String) -> void:
	lines.append(("PASS  " if ok else "FAIL  ") + what)
	if not ok:
		failures.append(what)


func _initialize() -> void:
	var boots := BootsTool.new()

	# --- the registry took it without being changed ---
	_check(ToolRegistry.names().has("boots"), "boots are in the registry")
	_check(ToolRegistry.find("boots") != null, "and can be found by name")
	_check(ToolRegistry.free_kit().has("boots") and ToolRegistry.free_kit().has("car"),
		"the free kit now has both tools")
	_check(ToolRegistry.prompt_sections().contains("EQUIP boots"),
		"the AI is told about boots without the prompt being edited")

	# --- what you get for nothing is what 009 settled on ---
	var free: Dictionary = boots.defaults()
	_check(absf(float(free["push"]) - 240.0) < 0.01
		and absf(float(free["weight"]) - 80.0) < 0.01
		and absf(float(free["footing"]) - 0.67) < 0.001,
		"the free boots are exactly 009's numbers")
	_check(absf(BootsTool.top_speed(free) - 4.48) < 0.05,
		"which come to %.2f m/s" % BootsTool.top_speed(free))

	# --- ordinary readbacks ---
	for trial in [
		[{}, "the ordinary brown boots"],
		# 011: a spec that changes the pace says so in the same sentence. The
		# first two of these said only "get you moving quickly" and "stop
		# sharply", each true and each half the story.
		[{"push": 420.0}, "brown boots that get you moving quickly, and walk at 7.8 m/s"],
		[{"footing": 1.3}, "brown boots that stop sharply, though they only walk at 2.3 m/s"],
		[{"colour": "black", "nickname": "Seven League"}, "the ordinary black boots called Seven League"],
		# Weight alone moves the pace without any wording of its own, which is
		# exactly the case a player would otherwise never be told about.
		[{"weight": 130.0}, "brown boots that weigh you down, though they only walk at 2.8 m/s"],
	]:
		var checked: Dictionary = boots.validate({"tool": "boots", "spec": trial[0]})
		var said := boots.readback(checked["spec"]) if bool(checked["ok"]) else "REFUSED: " + str(checked["errors"])
		_check(said == str(trial[1]), "%-44s %s" % [str(trial[0]).substr(0, 42), said])

	# --- a field out of range is refused, not clamped ---
	var over: Dictionary = boots.validate({"tool": "boots", "spec": {"push": 5000.0}})
	_check(not bool(over["ok"]) and str(over["errors"][0]).contains("600"),
		"push out of range is refused and names the limit")
	var invented: Dictionary = boots.validate({"tool": "boots", "spec": {"bounciness": 3}})
	_check(not bool(invented["ok"]), "an invented field is refused")

	# --- the new part: every field legal, the combination not ---
	var absurd := {"push": 600.0, "weight": 50.0, "footing": 0.4}
	_check(float(absurd["push"]) <= float(BootsTool.PUSH[1])
		and float(absurd["weight"]) >= float(BootsTool.WEIGHT[0])
		and float(absurd["footing"]) >= float(BootsTool.FOOTING[0]),
		"the absurd spec has every field inside its limits")
	var combined: Dictionary = boots.validate({"tool": "boots", "spec": absurd})
	_check(not bool(combined["ok"]), "and is refused anyway")
	var why := str(combined["errors"][0]) if not (combined["errors"] as Array).is_empty() else ""
	_check(why.contains("30.0 m/s") and why.contains("top speed"),
		"the refusal names what the combination would do: %s" % why)

	# The other end: a legal-looking spec that is too SLOW to be a person.
	var crawl: Dictionary = boots.validate({"tool": "boots", "spec": {"push": 120.0, "weight": 140.0, "footing": 1.5}})
	_check(not bool(crawl["ok"]), "and so is a spec too slow to walk (%.2f m/s)" % BootsTool.top_speed({"push": 120.0, "weight": 140.0, "footing": 1.5}))

	# --- the spec reaches the body ---
	var walker := Walker.new()
	var quick: Dictionary = boots.validate({"tool": "boots", "spec": {"push": 420.0, "colour": "red"}})
	walker.equip(quick["spec"])
	_check(absf(walker.top_speed() - BootsTool.top_speed(quick["spec"])) < 0.01,
		"an equipped body reports the speed its spec comes to (%.2f m/s)" % walker.top_speed())
	_check(absf(walker.run_push - walker.push * BootsTool.RUN_RATIO) < 0.01,
		"running keeps its ratio to walking without being asked for")
	walker.free()

	# --- the readback goes through the registry, like every other tool ---
	var through := ToolRegistry.readback({"tool": "boots", "spec": {"weight": 130.0}})
	_check(through == "brown boots that weigh you down, though they only walk at 2.8 m/s",
		"the registry reads boots back: " + through)

	# A spec that changes nothing a player would feel says nothing about pace.
	var nudge := ToolRegistry.readback({"tool": "boots", "spec": {"push": 250.0}})
	_check(not nudge.contains("m/s"), "a change too small to feel is not mentioned: " + nudge)

	print("")
	for l in lines:
		print(l)
	print("BOOTS TEST failures=%d" % failures.size())
	quit(failures.size())
