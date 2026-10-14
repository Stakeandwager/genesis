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

# --- 009: speed is not set, it is reached ---
#
# These were WALK, RUN and TURN: three speeds switched on and off, which is
# why nobody could say whether 4.5 m/s was right. A number picked by hand can
# only be defended by taste.
#
# Movement is now a force on a mass against drag, so top speed is a RESULT:
#
#     top speed  =  push / (mass * drag)  =  240 / (80 * 0.67)  =  4.5 m/s
#
# which is the old WALK, reached in about a second and a half rather than
# instantly. The same arithmetic gives running 8.0 m/s, and stopping is drag
# alone, so a body carries its momentum into a wall instead of halting on the
# frame a key comes up.
#
# This is also what makes an analogue input mean something. A keyboard key
# reports 1 or 0 and has no pressure to read, but a gamepad stick reports its
# magnitude, and here that magnitude scales the FORCE rather than the speed -
# a half-pressed stick is half the push, which settles at half the top speed
# and takes the same time to get there. Nothing special-cases the gamepad.
# --- 010: these are a spec now, not constants ---
# They were constants, so every player moved identically however they
# described themselves - the same trap car.gd was in before 004. They are now
# filled from a spec BootsTool has validated, and the values below are exactly
# what 009 settled on, so a player who asks for nothing moves precisely as
# they always have.
#
# Nothing writes to these except equip(), and equip() only ever receives a
# spec that passed the validator. A number out of range never reaches here,
# and neither does a combination that would carry a body at a car's pace.
var mass := 80.0                   # kg, about a person
var push := 240.0                  # newtons the legs apply, about 3 m/s/s
var run_push := 430.0              # holding shift
var drag := 0.67                   # how fast speed bleeds away, per second
var turn_push := 24.0              # the same arrangement for turning
var brake := 400.0                 # newtons the legs apply to stop
var colour := Color(0.42, 0.30, 0.20)
# 021: appearance, which changes nothing anybody can do.
var skin := Color(0.78, 0.62, 0.48)

# Not part of any spec: how turning settles. The same for every body, because
# it is about how a body is steered rather than what it is.
const TURN_DRAG := 10.0
const GRAVITY := 20.0
const BODY := 1.6                  # metres across, matching DungeonModule.BODY
const TALL := 1.8                  # capsule height, about a person
const HEAD := 0.52                 # a head is about half a metre across
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

# How fast the body is turning, in radians a second. Carried between frames
# because turning now has momentum of its own.
var spin := 0.0


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = BODY * 0.5
	capsule.height = TALL
	shape.shape = capsule
	shape.name = "Shape"
	add_child(shape)

	_build_body()
	_build_head()
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
	material.albedo_color = colour
	material.roughness = 0.9
	mesh.material_override = material
	add_child(mesh)


# --- 021: a head, and a face on it ---
# A capsule with a photo stuck to its side is not a person. The head is a
# small box above the body; the face is a flat panel just in front of it, so
# a picture can be shown without a mesh that knows what a face is.
func _build_head() -> void:
	var head := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(HEAD, HEAD, HEAD)
	head.mesh = box
	head.name = "Head"
	head.position = Vector3(0.0, TALL * 0.5 + HEAD * 0.5, 0.0)
	head.material_override = _skin_material()
	add_child(head)

	var face := MeshInstance3D.new()
	var panel := QuadMesh.new()
	panel.size = Vector2(HEAD * 0.92, HEAD * 0.92)
	face.mesh = panel
	face.name = "Face"
	# Just in front of the head's front face, looking the way the body does.
	face.position = Vector3(0.0, 0.0, -HEAD * 0.5 - 0.01)
	face.rotation = Vector3(0.0, PI, 0.0)
	face.visible = false
	head.add_child(face)


func _skin_material() -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = skin
	material.roughness = 0.85
	return material


# Take a validated look spec. A face that cannot be read leaves a plain head
# rather than failing: the picture may have moved since it was asked for, and
# that is not worth a crash.
func wear(spec: Dictionary) -> void:
	if spec.is_empty():
		return
	var named := str(spec.get("skin", ""))
	if LookTool.SKINS.has(named):
		skin = LookTool.SKINS[named]
	var head := get_node_or_null("Head") as MeshInstance3D
	if head == null:
		return
	head.material_override = _skin_material()

	var face := head.get_node_or_null("Face") as MeshInstance3D
	if face == null:
		return
	var picture := LookTool.face_texture(str(spec.get("face", "")))
	if picture == null:
		face.visible = false
		return
	var material := StandardMaterial3D.new()
	material.albedo_texture = picture
	material.roughness = 0.9
	# A photo is already lit; shading it again makes it muddy.
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	face.material_override = material
	face.visible = true


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
	spin = 0.0
	global_position = start_position
	rotation = Vector3(0.0, start_heading, 0.0)


func _physics_process(delta: float) -> void:
	var forward := auto_forward
	var turn := auto_turn
	var running := false
	if not auto_walk:
		# get_axis keeps a gamepad stick's magnitude, which is the pressure
		# there is to read. A key simply pins it to 1.
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
		running = Input.is_key_pressed(KEY_SHIFT)
		if Input.is_key_pressed(KEY_R):
			reset()
			return

	# Turning: a push against its own drag, so a tap nudges and a hold
	# settles at a steady rate instead of snapping to one.
	spin += (turn_push * turn - TURN_DRAG * spin) * delta
	rotate_y(spin * delta)

	# Walking: force over mass, less drag. Nothing assigns a speed.
	var effort := run_push if running else push
	var along := -transform.basis.z
	var drive := Vector3(along.x, 0.0, along.z).normalized() * (effort * forward / mass)
	var flat := Vector3(velocity.x, 0.0, velocity.z)
	flat += (drive - flat * drag) * delta

	# --- 013: stopping is a force, not more drag ---
	# Drag alone meant a 140 kg body stopped in exactly the same distance as
	# an 80 kg one, because velocity * drag has no mass in it. The legs apply
	# a braking FORCE, so deceleration is brake / mass and weight finally
	# tells. It also means asking to stop sharply no longer costs top speed:
	# the two were one number doing two jobs.
	#
	# Clamped so a frame of braking cannot push the body backwards.
	if absf(forward) < 0.05:
		var speed := flat.length()
		if speed > 0.0:
			flat -= flat / speed * minf(brake / mass * delta, speed)
	velocity.x = flat.x
	velocity.z = flat.z

	if is_on_floor():
		velocity.y = 0.0
	else:
		velocity.y -= GRAVITY * delta

	move_and_slide()


# Take a validated spec. Running keeps its ratio to walking, the way a car's
# reverse power keeps its ratio to engine power, so no spec has to mention it.
func equip(spec: Dictionary) -> void:
	if spec.is_empty():
		return
	push = float(spec.get("push", push))
	run_push = push * BootsTool.RUN_RATIO
	mass = float(spec.get("weight", mass))
	drag = float(spec.get("footing", drag))
	turn_push = float(spec.get("turning", turn_push))
	brake = float(spec.get("brake", brake))
	var named := str(spec.get("colour", ""))
	if BootsTool.COLOURS.has(named):
		colour = BootsTool.COLOURS[named]
	_repaint()


func _repaint() -> void:
	var figure := get_node_or_null("Figure") as MeshInstance3D
	if figure == null:
		return
	var material := StandardMaterial3D.new()
	material.albedo_color = colour
	material.roughness = 0.9
	figure.material_override = material


# What this body settles at, from its own numbers. The same arithmetic
# BootsTool bounds, read from the one place that owns it.
func top_speed() -> float:
	return BootsTool.top_speed(_spec())


# How far this body should take to stop from a given speed, by its own
# numbers. The prediction and the body it predicts read the same values.
func stopping_distance(from_speed: float) -> float:
	return BootsTool.stopping_distance(_spec(), from_speed)


func _spec() -> Dictionary:
	return {"push": push, "weight": mass, "footing": drag, "brake": brake}


func speed_mps() -> float:
	return Vector2(velocity.x, velocity.z).length()
