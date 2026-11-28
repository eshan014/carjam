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


func test_fuel_burns_with_throttle() -> void:
	var start := CarState.new()
	start.fuel = 10.0
	var end := _run(start, CarInput.make(1.0, 0.0), 1.0)
	assert_almost_eq(end.fuel, 5.0, 0.01)


func test_no_throttle_burns_no_fuel() -> void:
	var start := CarState.new()
	start.fuel = 10.0
	var end := _run(start, CarInput.new(), 2.0)
	assert_eq(end.fuel, 10.0)


func test_handbrake_burns_no_fuel() -> void:
	var start := CarState.new()
	start.fuel = 10.0
	start.speed = 50.0
	var end := _run(start, CarInput.make(1.0, 0.0, true), 0.5)
	assert_eq(end.fuel, 10.0)


func test_empty_tank_gives_no_acceleration() -> void:
	var start := CarState.new()
	start.fuel = 0.0
	var end := _run(start, CarInput.make(1.0, 0.0), 1.0)
	assert_eq(end.speed, 0.0)
	assert_eq(end.position, Vector2.ZERO)


func test_empty_tank_car_coasts_to_a_stop() -> void:
	var start := CarState.new()
	start.fuel = 0.0
	start.speed = 50.0
	var end := _run(start, CarInput.make(1.0, 0.0), 5.0)
	assert_eq(end.speed, 0.0)
	assert_gt(end.position.x, 0.0)


func test_fuel_never_goes_negative() -> void:
	var start := CarState.new()
	start.fuel = 0.01
	var end := _run(start, CarInput.make(1.0, 0.0), 1.0)
	assert_eq(end.fuel, 0.0)


func test_default_state_has_unlimited_fuel() -> void:
	var end := _run(CarState.new(), CarInput.make(1.0, 0.0), 30.0)
	assert_true(is_inf(end.fuel))
