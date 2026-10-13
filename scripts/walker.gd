extends CharacterBody3D
class_name Walker

# --- 008: a body that walks the dungeon ---
#
# The sibling of Car. Car exists so a player can find out whether a track is
# worth driving; this exists so a player can find out whether a dungeon is
# worth walking - which no measurement can answer, because "three rooms in a
# row, all reachable" is true of a good dungeon and a dull one alike.
#
# It is also the instrument that caught 007. A CharacterBody3D is the same
# body walker_test.gd drives headlessly, so what a player bumps into and what
# the test bumps into are the same thing. A doorway that stops this stops them.
#
# It builds its own shape and camera, so there is no scene to set up.
#
# Controls are deliberately keyboard-only: W and S walk, A and D turn. No
# mouse capture. Capturing the mouse would take the pointer away from the text
# box the player needs in order to type /view, and a web build makes that
# worse. Turning with keys is clumsier and costs nobody a trapped cursor.

const WALK := 4.5                  # metres a second
const RUN := 8.0                   # holding shift
const TURN := 2.4                  # radians a second
const GRAVITY := 20.0
const BODY := 1.6                  # metres across, matching DungeonModule.BODY
const TALL := 1.8                  # capsule height, about a person
const EYE := 1.25                  # camera height above the body's middle
const BEHIND := 2.4                # how far back the camera sits
const DROP := 0.18                 # how far the camera tilts down

var camera: Camera3D
var start_position := Vector3.ZERO
var start_heading := 0.0

# Lets something other than the keyboard walk, the way Car.auto_drive does:
# -1 to 1 for each.
var auto_walk := false
var auto_forward := 0.0
var auto_turn := 0.0


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = BODY * 0.5
	capsule.height = TALL
	shape.shape = capsule
	shape.name = "Shape"
	add_child(shape)

	_build_body()
	_build_camera()


# A plain marker so the player can see where they are. Nothing about it is
# measured; it exists to be looked at.
func _build_body() -> void:
	var mesh := MeshInstance3D.new()
	var capsule := CapsuleMesh.new()
	capsule.radius = BODY * 0.5
	capsule.height = TALL
	mesh.mesh = capsule
	mesh.name = "Figure"
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.86, 0.74, 0.46)
	material.roughness = 0.9
	mesh.material_override = material
	add_child(mesh)


func _build_camera() -> void:
	camera = Camera3D.new()
	camera.name = "WalkerCamera"
	camera.position = Vector3(0.0, EYE, BEHIND)
	camera.rotation = Vector3(-DROP, 0.0, 0.0)
	camera.near = 0.05
	camera.far = 2000.0
	add_child(camera)


func place_at(pos: Vector3, heading: float) -> void:
	start_position = pos
	start_heading = heading
	reset()


func reset() -> void:
	velocity = Vector3.ZERO
	global_position = start_position
	rotation = Vector3(0.0, start_heading, 0.0)


func _physics_process(delta: float) -> void:
	var forward := auto_forward
	var turn := auto_turn
	if not auto_walk:
		forward = Input.get_axis("ui_down", "ui_up")
		turn = Input.get_axis("ui_right", "ui_left")
		if Input.is_key_pressed(KEY_W):
			forward = 1.0
		elif Input.is_key_pressed(KEY_S):
			forward = -1.0
		if Input.is_key_pressed(KEY_A):
			turn = 1.0
		elif Input.is_key_pressed(KEY_D):
			turn = -1.0
		if Input.is_key_pressed(KEY_R):
			reset()
			return

	rotate_y(turn * TURN * delta)

	var speed := RUN if (not auto_walk and Input.is_key_pressed(KEY_SHIFT)) else WALK
	var heading := -transform.basis.z * forward * speed
	velocity.x = heading.x
	velocity.z = heading.z

	if is_on_floor():
		velocity.y = 0.0
	else:
		velocity.y -= GRAVITY * delta

	move_and_slide()


func speed_mps() -> float:
	return Vector2(velocity.x, velocity.z).length()
