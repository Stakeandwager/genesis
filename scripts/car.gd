extends VehicleBody3D
class_name Car

# --- Prototype 002B: a drivable car ---
# Deliberately high grip and high power: this exists to find out whether the
# AI's tracks are worth driving, and to stress the machine.
#
# Controls: W or Up accelerate, S or Down brake and reverse, A/D or Left/Right
# steer, Space handbrake, R back to the start line.
#
# It builds its own body, wheels and chase camera, so there is no scene to set
# up. Physics runs at 120 steps a second (set in main) because a fast car can
# otherwise pass straight through a barrier between frames.

const ENGINE_POWER := 900.0
const REVERSE_POWER := 350.0
const BRAKE_POWER := 18.0
const MAX_STEER := 0.5           # radians, about 29 degrees
const STEER_SPEED := 3.5
const STEER_AT_SPEED := 0.45     # steering tightens less the faster you go
const DOWNFORCE := 9.0

var start_position := Vector3.ZERO
var start_heading := 0.0
var camera: Camera3D
# Lets something other than the keyboard drive: automated tests today,
# computer-controlled opponents later. Throttle and steering are -1 to 1.
var auto_drive := false
var auto_throttle := 0.0
var auto_steer := 0.0
var _steer_target := 0.0


func _ready() -> void:
	mass = 900.0
	center_of_mass_mode = RigidBody3D.CENTER_OF_MASS_MODE_CUSTOM
	center_of_mass = Vector3(0.0, -0.35, 0.0)
	_build_body()
	_build_wheels()
	_build_camera()


func place_at(pos: Vector3, heading: float) -> void:
	start_position = pos + Vector3.UP * 1.2
	start_heading = heading
	reset()


func reset() -> void:
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	engine_force = 0.0
	brake = 0.0
	steering = 0.0
	# The track's heading turns clockwise seen from above, which is the
	# opposite sense to a rotation about the up axis.
	global_transform = Transform3D(Basis(Vector3.UP, -start_heading), start_position)


func speed_kmh() -> float:
	return linear_velocity.length() * 3.6


func _physics_process(delta: float) -> void:
	var accelerate := Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP)
	var backwards := Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN)
	var left := Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT)
	var right := Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT)
	var handbrake := Input.is_physical_key_pressed(KEY_SPACE)

	if auto_drive:
		accelerate = auto_throttle > 0.1
		backwards = auto_throttle < -0.1
		left = auto_steer < -0.05
		right = auto_steer > 0.05
		handbrake = false
	elif Input.is_physical_key_pressed(KEY_R):
		reset()
		return

	var forward_speed := linear_velocity.dot(-global_transform.basis.z)

	# Positive engine force drives the car towards its own +Z, which is
	# backwards, so forwards is negative.
	if accelerate:
		engine_force = -ENGINE_POWER
		brake = 0.0
	elif backwards:
		if forward_speed > 1.0:
			engine_force = 0.0
			brake = BRAKE_POWER
		else:
			engine_force = REVERSE_POWER
			brake = 0.0
	else:
		engine_force = 0.0
		brake = 1.0

	if handbrake:
		engine_force = 0.0
		brake = BRAKE_POWER * 1.5

	# Steering eases in, and tightens less at speed so the car stays stable.
	_steer_target = 0.0
	if left:
		_steer_target += 1.0
	if right:
		_steer_target -= 1.0
	var limit: float = MAX_STEER * lerpf(1.0, STEER_AT_SPEED, clampf(absf(forward_speed) / 60.0, 0.0, 1.0))
	steering = move_toward(steering, _steer_target * limit, STEER_SPEED * delta)

	# Downforce: the faster it goes, the harder it is pressed onto the road.
	apply_central_force(-global_transform.basis.y * DOWNFORCE * forward_speed * absf(forward_speed) * 0.01)

	_follow_with_camera(delta)


# --- construction ---

func _build_body() -> void:
	# The chassis must sit clear of the road, or it rests on its belly and the
	# wheels have nothing to push against.
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(1.9, 0.6, 4.2)
	shape.shape = box
	shape.position = Vector3(0.0, 0.75, 0.0)
	add_child(shape)

	_add_box(Vector3(1.9, 0.55, 4.2), Vector3(0.0, 0.75, 0.0), Color(0.85, 0.20, 0.16))
	_add_box(Vector3(1.3, 0.5, 1.7), Vector3(0.0, 1.25, -0.2), Color(0.10, 0.10, 0.12))
	_add_box(Vector3(1.8, 0.10, 0.5), Vector3(0.0, 1.35, 1.9), Color(0.12, 0.12, 0.14))


func _add_box(size: Vector3, at: Vector3, colour: Color) -> void:
	var part := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	part.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = colour
	part.material_override = material
	part.position = at
	add_child(part)


func _build_wheels() -> void:
	_add_wheel(Vector3(-0.85, 0.55, -1.5), true)
	_add_wheel(Vector3(0.85, 0.55, -1.5), true)
	_add_wheel(Vector3(-0.85, 0.55, 1.5), false)
	_add_wheel(Vector3(0.85, 0.55, 1.5), false)


func _add_wheel(at: Vector3, front: bool) -> void:
	var wheel := VehicleWheel3D.new()
	wheel.position = at
	wheel.use_as_steering = front
	wheel.use_as_traction = true
	wheel.wheel_radius = 0.35
	wheel.wheel_rest_length = 0.2
	wheel.wheel_friction_slip = 4.5
	wheel.wheel_roll_influence = 0.08
	wheel.suspension_travel = 0.2
	wheel.suspension_stiffness = 45.0
	wheel.damping_compression = 0.6
	wheel.damping_relaxation = 0.8
	add_child(wheel)

	var mesh := MeshInstance3D.new()
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = 0.35
	cylinder.bottom_radius = 0.35
	cylinder.height = 0.3
	mesh.mesh = cylinder
	mesh.rotation_degrees = Vector3(0.0, 0.0, 90.0)
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.07, 0.07, 0.07)
	mesh.material_override = material
	wheel.add_child(mesh)


func _build_camera() -> void:
	camera = Camera3D.new()
	camera.name = "ChaseCamera"
	camera.fov = 78.0
	camera.near = 0.1
	camera.far = 6000.0
	camera.top_level = true
	add_child(camera)


func _follow_with_camera(delta: float) -> void:
	if camera == null:
		return
	var behind := global_transform.origin + global_transform.basis.z * 9.0 + Vector3.UP * 3.6
	camera.global_transform.origin = camera.global_transform.origin.lerp(behind, clampf(delta * 6.0, 0.0, 1.0))
	camera.look_at(global_transform.origin + Vector3.UP * 1.2, Vector3.UP)
