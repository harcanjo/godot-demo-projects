extends CharacterBody3D

const MAX_SPEED = 3
const JUMP_SPEED = 5
const ACCELERATION = 2
const DECELERATION = 4

@onready var camera = $Target/Camera3D
@onready var gravity = -ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var start_position = position
var velocity: Vector3

func _physics_process(delta):
	if Input.is_action_just_pressed(&"exit"):
		get_tree().quit()
	if Input.is_action_just_pressed(&"reset_position"):
		position = start_position

	var dir = Vector3()
	dir.x = Input.get_axis(&"move_left", &"move_right")
	dir.z = Input.get_axis(&"move_forward", &"move_back")

	# Get the camera's transform basis, but remove the X rotation such
	# that the Y axis is up and Z is horizontal.
	var cam_basis = camera.global_transform.basis
	var basis = cam_basis.rotated(cam_basis.x, -cam_basis.get_euler().x)
	dir = basis * (dir)

	# Limit the input to a length of 1. length_squared is faster to check.
	if dir.length_squared() > 1:
		dir /= dir.length()

	# Apply gravity.
	velocity.y += delta * gravity

	# Using only the horizontal velocity, interpolate towards the input.
	var hvel = velocity
	hvel.y = 0

	var target = dir * MAX_SPEED
	var acceleration
	if dir.dot(hvel) > 0:
		acceleration = ACCELERATION
	else:
		acceleration = DECELERATION

	hvel = hvel.lerp(target, acceleration * delta)

	# Assign hvel's values back to velocity, and then move.
	velocity.x = hvel.x
	velocity.z = hvel.z
	# TODO: This information should be set to the CharacterBody properties instead of arguments: , Vector3.UP
	# TODO: Rename velocity to linear_velocity in the rest of the script.
	move_and_slide()

	# TODO: This information should be set to the CharacterBody properties instead of arguments.
	# Jumping code. is_on_floor() must come after move_and_slide().
	if is_on_floor() and Input.is_action_pressed(&"jump"):
		velocity.y = JUMP_SPEED


func _on_tcube_body_entered(body):
	if body == self:
		get_node(^"WinText").show()
