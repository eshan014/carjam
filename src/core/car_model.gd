class_name CarModel
extends RefCounted
## Car movement (bicycle model). Pure math: no nodes, no engine physics.


static func step(state: CarState, input: CarInput, params: CarParams, dt: float) -> CarState:
	var next := state.copy()

	# The wheel angle moves toward the requested angle at a limited rate.
	var target_steer := clampf(input.steer, -1.0, 1.0) * params.max_steer
	next.steer = move_toward(state.steer, target_steer, params.steer_rate * dt)

	# Without fuel the engine does nothing: the car only coasts or brakes.
	var throttle := clampf(input.throttle, -1.0, 1.0)
	if state.fuel <= 0.0:
		throttle = 0.0

	# Speed along the heading. Heavier cars accelerate slower (force / mass).
	var speed := state.speed
	if input.handbrake:
		speed = move_toward(speed, 0.0, params.parking_drag() * dt)
	elif throttle == 0.0:
		speed = move_toward(speed, 0.0, params.coast_drag() * dt)
	else:
		var rate := params.braking()
		if throttle * speed >= 0.0:
			# Pushing along the direction of travel: force fades as speed nears the top speed.
			var top := params.max_speed if throttle > 0.0 else params.max_reverse_speed
			rate = params.acceleration() * maxf(0.0, 1.0 - absf(speed) / top)
		speed += throttle * rate * dt
	next.speed = clampf(speed, -params.max_reverse_speed, params.max_speed)

	# Fuel burns in proportion to how hard the throttle is pressed.
	if not input.handbrake:
		next.fuel = maxf(0.0, state.fuel - absf(throttle) * params.fuel_burn * dt)

	# Sideways slide and impact spin (from pushes) fade as the tires grip.
	next.slide = state.slide.move_toward(Vector2.ZERO, params.lateral_grip * dt)
	next.spin = move_toward(state.spin, 0.0, params.spin_grip * dt)

	# Turning scales with speed, so a stopped car cannot rotate.
	var turn_rate := next.speed / params.wheelbase * tan(next.steer)
	next.heading = state.heading + (turn_rate + state.spin) * dt
	var forward := Vector2.from_angle(next.heading) * next.speed
	next.position = state.position + (forward + state.slide) * dt
	return next
