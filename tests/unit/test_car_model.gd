extends GutTest

const DT := 1.0 / 60.0

var _params: CarParams


func before_each() -> void:
	_params = CarParams.new()


func _run(state: CarState, input: CarInput, seconds: float) -> CarState:
	var current := state
	for _i in range(roundi(seconds / DT)):
		current = CarModel.step(current, input, _params, DT)
	return current


func test_no_input_at_rest_changes_nothing() -> void:
	var end := _run(CarState.new(), CarInput.new(), 1.0)
	assert_eq(end.position, Vector2.ZERO)
	assert_eq(end.speed, 0.0)
	assert_eq(end.heading, 0.0)


func test_throttle_moves_car_forward() -> void:
	var end := _run(CarState.new(), CarInput.make(1.0, 0.0), 1.0)
	assert_gt(end.speed, 100.0)
	assert_lt(end.speed, 200.0)
	assert_gt(end.position.x, 0.0)
	assert_almost_eq(end.position.y, 0.0, 0.001)


func test_stopped_car_cannot_rotate() -> void:
	var end := _run(CarState.new(), CarInput.make(0.0, 1.0), 1.0)
	assert_eq(end.heading, 0.0)
	assert_eq(end.position, Vector2.ZERO)
	assert_almost_eq(end.steer, _params.max_steer, 0.0001)


func test_moving_car_turns_both_ways_equally() -> void:
	var moving := CarState.new()
	moving.speed = 100.0
	var right := _run(moving, CarInput.make(0.0, 1.0), 0.5)
	var left := _run(moving, CarInput.make(0.0, -1.0), 0.5)
	assert_gt(right.heading, 0.0)
	assert_lt(left.heading, 0.0)
	assert_almost_eq(right.heading, -left.heading, 0.0001)


func test_speed_approaches_but_never_exceeds_max() -> void:
	var end := _run(CarState.new(), CarInput.make(1.0, 0.0), 5.0)
	assert_gt(end.speed, _params.max_speed * 0.95)
	assert_lt(end.speed, _params.max_speed)
	var long_run := _run(CarState.new(), CarInput.make(1.0, 0.0), 30.0)
	assert_true(long_run.speed <= _params.max_speed)


func test_reverse_moves_car_backward() -> void:
	var end := _run(CarState.new(), CarInput.make(-1.0, 0.0), 1.0)
	assert_lt(end.speed, 0.0)
	assert_lt(end.position.x, 0.0)


func test_friction_stops_car_without_reversing() -> void:
	var forward := CarState.new()
	forward.speed = 50.0
	assert_eq(_run(forward, CarInput.new(), 5.0).speed, 0.0)
	var backward := CarState.new()
	backward.speed = -50.0
	assert_eq(_run(backward, CarInput.new(), 5.0).speed, 0.0)


func test_opposing_throttle_brakes_harder_than_friction() -> void:
	var moving := CarState.new()
	moving.speed = 100.0
	var end := _run(moving, CarInput.make(-1.0, 0.0), 0.1)
	assert_almost_eq(end.speed, 60.0, 0.01)


func test_step_does_not_modify_input_state() -> void:
	var start := CarState.new()
	start.speed = 10.0
	var after := CarModel.step(start, CarInput.make(1.0, 1.0), _params, DT)
	assert_eq(start.speed, 10.0)
	assert_eq(start.steer, 0.0)
	assert_eq(start.heading, 0.0)
	assert_eq(start.position, Vector2.ZERO)
	assert_gt(after.speed, 10.0)


func test_heavier_car_accelerates_slower() -> void:
	var light := _run(CarState.new(), CarInput.make(1.0, 0.0), 1.0)
	_params.mass = 2000.0
	var heavy := _run(CarState.new(), CarInput.make(1.0, 0.0), 1.0)
	assert_lt(heavy.speed, light.speed)


func test_handbrake_slows_car_at_parking_rate() -> void:
	var moving := CarState.new()
	moving.speed = 50.0
	var end := _run(moving, CarInput.make(0.0, 0.0, true), 0.2)
	assert_almost_eq(end.speed, 30.0, 0.01)


func test_sideways_slide_moves_car_then_fades() -> void:
	var sliding := CarState.new()
	sliding.slide = Vector2(0.0, 60.0)
	var end := _run(sliding, CarInput.new(), 1.0)
	assert_gt(end.position.y, 0.0)
	assert_eq(end.slide, Vector2.ZERO)
	assert_eq(end.heading, 0.0)


func test_acceleration_tapers_as_speed_rises() -> void:
	var first_half := _run(CarState.new(), CarInput.make(1.0, 0.0), 0.5)
	var full := _run(CarState.new(), CarInput.make(1.0, 0.0), 1.0)
	assert_lt(full.speed - first_half.speed, first_half.speed)
