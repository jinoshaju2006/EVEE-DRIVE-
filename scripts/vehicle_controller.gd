extends CharacterBody3D

@export var acceleration := 25.0
@export var reverse_acceleration := 11.0
@export var max_speed := 42.0
@export var steering_speed := 1.85
@export var rolling_drag := 2.8
@export var brake_force := 38.0
@export var handbrake_drag := 24.0
@export_range(0.0, 1.0) var normal_grip := 0.88
@export_range(0.0, 1.0) var handbrake_grip := 0.22

var forward_speed := 0.0
var spawn_position := Vector3(0.0, 1.0, 0.0)

func _ready() -> void:
	spawn_position = global_position

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("reset_vehicle"):
		_reset_vehicle()

	var throttle := Input.get_action_strength("accelerate")
	var braking := Input.get_action_strength("brake")
	var steering := Input.get_action_strength("steer_right") - Input.get_action_strength("steer_left")
	var handbrake_amount := Input.get_action_strength("handbrake")

	if throttle > 0.0:
		forward_speed = move_toward(forward_speed, max_speed, acceleration * throttle * delta)
	elif braking > 0.0:
		if forward_speed > 0.7:
			forward_speed = move_toward(forward_speed, 0.0, brake_force * braking * delta)
		else:
			forward_speed = move_toward(forward_speed, -max_speed * 0.28, reverse_acceleration * braking * delta)
	else:
		forward_speed = move_toward(forward_speed, 0.0, rolling_drag * delta)

	if handbrake_amount > 0.0:
		forward_speed = move_toward(forward_speed, 0.0, handbrake_drag * handbrake_amount * delta)

	var speed_ratio := clampf(absf(forward_speed) / max_speed, 0.0, 1.0)
	var steering_factor := lerpf(0.2, 1.0, speed_ratio)
	rotate_y(-steering * steering_speed * steering_factor * delta * signf(forward_speed if absf(forward_speed) > 0.1 else 1.0))

	var local_velocity := global_transform.basis.inverse() * Vector3(velocity.x, 0.0, velocity.z)
	var grip := lerpf(normal_grip, handbrake_grip, handbrake_amount)
	local_velocity.x = move_toward(local_velocity.x, 0.0, (8.0 + grip * 34.0) * delta)
	local_velocity.z = -forward_speed
	var world_velocity := global_transform.basis * local_velocity
	velocity.x = world_velocity.x
	velocity.z = world_velocity.z

	if not is_on_floor():
		velocity.y -= 24.0 * delta
	else:
		velocity.y = -0.5

	move_and_slide()

	if global_position.y < -8.0:
		_reset_vehicle()

func _reset_vehicle() -> void:
	global_position = spawn_position
	global_rotation = Vector3.ZERO
	velocity = Vector3.ZERO
	forward_speed = 0.0
