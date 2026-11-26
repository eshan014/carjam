class_name CarModel
extends RefCounted
## Car movement (bicycle model). Pure math: no nodes, no engine physics.


static func step(state: CarState, input: CarInput, params: CarParams, dt: float) -> CarState:
	var next := state.copy()

	# The wheel angle moves toward the requested angle at a limited rate.
	var target_steer := clampf(input.steer, -1.0, 1.0) * params.max_steer
	next.steer = move_toward(state.steer, target_steer, params.steer_rate * dt)

	# Speed: throttle pushes it, and pushing against the motion uses the stronger brake.
	var throttle := clampf(input.throttle, -1.0, 1.0)
	var speed := state.speed
	if throttle == 0.0:
		speed = move_toward(speed, 0.0, params.friction * dt)
	else:
		var rate := params.accel
		if throttle * speed < 0.0:
			rate = params.brake
		speed += throttle * rate * dt
	next.speed = clampf(speed, -params.max_reverse_speed, params.max_speed)

	# Turning scales with speed, so a stopped car cannot rotate.
	var turn_rate := next.speed / params.wheelbase * tan(next.steer)
	next.heading = state.heading + turn_rate * dt
	next.position = state.position + Vector2.from_angle(next.heading) * next.speed * dt
	return next
