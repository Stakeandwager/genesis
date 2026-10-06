extends SceneTree
func _initialize() -> void:
	var bad := 0
	var dir := DirAccess.open("res://scripts")
	for f in dir.get_files():
		if not f.ends_with(".gd"):
			continue
		var s = load("res://scripts/" + f)
		if s == null or not (s as Script).can_instantiate():
			print("CANNOT LOAD: ", f); bad += 1
	print("LOADCHECK bad=%d" % bad)
	quit(bad)
