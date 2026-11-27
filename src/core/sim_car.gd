class_name SimCar
extends RefCounted
## One car inside a SimWorld: changing state, fixed numbers, and current driver input.

var state: CarState = CarState.new()
var params: CarParams = CarParams.new()
var input: CarInput = CarInput.new()


static func make(start: Vector2, heading: float, car_params: CarParams) -> SimCar:
	var result := SimCar.new()
	result.params = car_params
	result.state.position = start
	result.state.heading = heading
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
