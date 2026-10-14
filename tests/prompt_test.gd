extends SceneTree
func _initialize() -> void:
	print(ToolRegistry.prompt_sections())
	print("")
	print("--- EQUIP readbacks as the player would see them ---")
	for p in [
		{"tool":"car","spec":{}},
		{"tool":"car","spec":{"grip":18,"braking":27}},
		{"tool":"car","spec":{"paint":"yellow","nickname":"Banana","power":1500}},
		{"tool":"hovercraft","spec":{}},
	]:
		print("  %s" % WorldRegistry.readback("EQUIP", p))
	quit(0)
