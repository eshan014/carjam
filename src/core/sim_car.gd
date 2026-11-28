class_name SimCar
extends RefCounted
## One car inside a SimWorld: changing state, fixed numbers, and current driver input.

const MAX_SPIN := 8.0

var state: CarState = CarState.new()
var params: CarParams = CarParams.new()
var input: CarInput = CarInput.new()


static func make(start: Vector2, heading: float, car_params: CarParams) -> SimCar:
	var result := SimCar.new()
	result.params = car_params
	result.state.position = start
	result.state.heading = heading
	result.state.fuel = car_params.fuel_capacity
	return result


func box() -> OrientedBox:
	return OrientedBox.make(
		state.position, state.heading, Vector2(params.length, params.width) / 2.0
	)


func velocity() -> Vector2:
	return Vector2.from_angle(state.heading) * state.speed + state.slide


## Splits a velocity into speed along the heading and sideways slide.
func set_velocity(value: Vector2) -> void:
	var forward := Vector2.from_angle(state.heading)
	state.speed = value.dot(forward)
	state.slide = value - forward * state.speed


## Velocity of the point `offset` away from the car's center (includes the spin).
func velocity_at(offset: Vector2) -> Vector2:
	return velocity() + Vector2(-offset.y, offset.x) * state.spin


## How easily a push along `direction` at `offset` moves the car (mass and spin together).
func lever_factor(offset: Vector2, direction: Vector2) -> float:
	var arm := offset.cross(direction)
	return 1.0 / params.mass + arm * arm / params.inertia()


## A one-time shove at `offset`: changes velocity, and adds spin when off-center.
func apply_impulse(impulse: Vector2, offset: Vector2) -> void:
	set_velocity(velocity() + impulse / params.mass)
	var spin := state.spin + offset.cross(impulse) / params.inertia()
	state.spin = clampf(spin, -MAX_SPIN, MAX_SPIN)
