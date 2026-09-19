extends Node3D
class_name OpponentBuilder

# --- Prototype 001 - Stage 7: Opponents ---
# Primitive vehicles only. Not beautiful, not driveable. Visible proof.

const MAX_OPPONENTS := 12

var opponents: Array[Node3D] = []

var colours: Array[Color] = [
	Color(0.90, 0.25, 0.20),
	Color(0.20, 0.45, 0.90),
	Color(0.95, 0.80, 0.15),
	Color(0.30, 0.80, 0.40),
	Color(0.85, 0.40, 0.85),
	Color(0.95, 0.55, 0.15),
]


func spawn(count: int, start_position: Vector3, direction: Vector3) -> String:
	clear()

	count = clampi(count, 1, MAX_OPPONENTS)

	# Line them up behind the start position, staggered left and right.
	var back := -direction.normalized()
	var side := direction.cross(Vector3.UP).normalized()

	for i in count:
		var row := float(i / 2)
		var lane := 1.0 if i % 2 == 0 else -1.0

		var offset := back * (8.0 + row * 9.0) + side * (lane * 3.0)
		_build_vehicle(i, start_position + offset, direction)

	return "SPAWN_OPPONENTS count=%d" % count


func clear() -> void:
	for child in get_children():
		child.queue_free()
	opponents.clear()


func count() -> int:
	return opponents.size()


# --- internal ---

func _build_vehicle(index: int, at: Vector3, direction: Vector3) -> void:
	var holder := Node3D.new()
	holder.name = "Opponent_%d" % (index + 1)
	add_child(holder)

	var colour: Color = colours[index % colours.size()]

	# Body
	var body := MeshInstance3D.new()
	var body_mesh := BoxMesh.new()
	body_mesh.size = Vector3(2.4, 1.0, 4.6)
	body.mesh = body_mesh
	body.material_override = _make_material(colour)
	body.position = Vector3(0.0, 0.9, 0.0)
	holder.add_child(body)

	# Cockpit
	var cockpit := MeshInstance3D.new()
	var cockpit_mesh := BoxMesh.new()
	cockpit_mesh.size = Vector3(1.4, 0.8, 1.6)
	cockpit.mesh = cockpit_mesh
	cockpit.material_override = _make_material(Color(0.10, 0.10, 0.12))
	cockpit.position = Vector3(0.0, 1.7, -0.3)
	holder.add_child(cockpit)

	# Four wheels
	_add_wheel(holder, Vector3(-1.3, 0.5, 1.5))
	_add_wheel(holder, Vector3(1.3, 0.5, 1.5))
	_add_wheel(holder, Vector3(-1.3, 0.5, -1.5))
	_add_wheel(holder, Vector3(1.3, 0.5, -1.5))

	holder.position = at + Vector3(0.0, 2.0, 0.0)
	holder.rotation = Vector3(0.0, atan2(direction.x, direction.z), 0.0)

	opponents.append(holder)


func _add_wheel(parent: Node3D, at: Vector3) -> void:
	var wheel := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.5, 1.0, 1.0)
	wheel.mesh = mesh
	wheel.material_override = _make_material(Color(0.06, 0.06, 0.06))
	wheel.position = at
	parent.add_child(wheel)


func _make_material(colour: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = colour
	return material
