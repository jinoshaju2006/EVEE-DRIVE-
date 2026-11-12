extends CharacterBody3D

@export var acceleration := 22.0
@export var reverse_acceleration := 10.0
@export var max_speed := 34.0
@export var steering_speed := 1.7
@export var drag := 7.0
@export var handbrake_drag := 18.0

var forward_speed := 0.0

func _physics_process(delta: float) -> void:
	var throttle := Input.get_action_strength("accelerate")
	var braking := Input.get_action_strength("brake")
	var steering := Input.get_action_strength("steer_right") - Input.get_action_strength("steer_left")

	if throttle > 0.0:
		forward_speed = move_toward(forward_speed, max_speed, acceleration * throttle * delta)
	elif braking > 0.0:
		if forward_speed > 0.5:
			forward_speed = move_toward(forward_speed, 0.0, acceleration * braking * 1.8 * delta)
		else:
			forward_speed = move_toward(forward_speed, -max_speed * 0.35, reverse_acceleration * braking * delta)
	else:
		forward_speed = move_toward(forward_speed, 0.0, drag * delta)

	var handbrake_amount := Input.get_action_strength("handbrake")
	if handbrake_amount > 0.0:
		forward_speed = move_toward(forward_speed, 0.0, handbrake_drag * handbrake_amount * delta)

	var speed_factor := clamp(absf(forward_speed) / 8.0, 0.15, 1.0)
	rotate_y(-steering * steering_speed * speed_factor * delta * signf(forward_speed if absf(forward_speed) > 0.1 else 1.0))

	var forward := -global_transform.basis.z
	velocity.x = forward.x * forward_speed
	velocity.z = forward.z * forward_speed
	if not is_on_floor():
		velocity.y -= 24.0 * delta
	else:
		velocity.y = 0.0
	move_and_slide()
