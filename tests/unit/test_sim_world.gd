extends GutTest

const DT := 1.0 / 60.0

var _world: SimWorld


func before_each() -> void:
	_world = SimWorld.new()


func _add_car(x: float, y: float, heading: float, params: CarParams) -> SimCar:
	var car := SimCar.make(Vector2(x, y), heading, params)
	_world.add_car(car)
	return car


func _park(car: SimCar) -> void:
	car.input = CarInput.make(0.0, 0.0, true)


func _run(seconds: float) -> void:
	for _i in range(roundi(seconds / DT)):
		_world.step(DT)


func test_wall_stops_car() -> void:
	_world.add_wall(OrientedBox.make(Vector2(200, 0), 0.0, Vector2(10, 200)))
	var car := _add_car(0, 0, 0.0, CarParams.compact())
	car.input = CarInput.make(1.0, 0.0)
	_run(5.0)
	assert_lt(car.state.position.x, 145.1)
	assert_almost_eq(car.state.speed, 0.0, 5.0)


func test_truck_pushes_parked_compact_far() -> void:
	var truck := _add_car(0, 0, 0.0, CarParams.truck())
	var compact := _add_car(140, 0, 0.0, CarParams.compact())
	_park(compact)
	truck.input = CarInput.make(1.0, 0.0)
	_run(4.0)
	assert_gt(compact.state.position.x, 240.0)


func test_compact_barely_moves_parked_truck() -> void:
	var compact := _add_car(0, 0, 0.0, CarParams.compact())
	var truck := _add_car(140, 0, 0.0, CarParams.truck())
	_park(truck)
	compact.input = CarInput.make(1.0, 0.0)
	_run(4.0)
	assert_lt(truck.state.position.x, 180.0)


func test_collision_shares_speed_by_mass() -> void:
	var compact := _add_car(0, 0, 0.0, CarParams.compact())
	var truck := _add_car(124, 0, 0.0, CarParams.truck())
	compact.state.speed = 100.0
	_world.step(0.0001)
	assert_almost_eq(compact.state.speed, 25.0, 0.5)
	assert_almost_eq(truck.state.speed, 25.0, 0.5)


func test_overlapping_cars_get_pushed_apart() -> void:
	var first := _add_car(0, 0, 0.0, CarParams.compact())
	var second := _add_car(80, 0, 0.0, CarParams.compact())
	_world.step(DT)
	var contact := Collision.test(first.box(), second.box())
	assert_true(contact == null or contact.depth < 0.01)


func test_centered_side_push_slides_car_without_spin() -> void:
	var compact := _add_car(0, 0, 0.0, CarParams.compact())
	_park(compact)
	var truck := _add_car(0, -200, PI / 2.0, CarParams.truck())
	truck.input = CarInput.make(1.0, 0.0)
	_run(2.5)
	assert_gt(compact.state.position.y, 30.0)
	assert_almost_eq(compact.state.heading, 0.0, 0.001)


func test_off_center_push_spins_car() -> void:
	var compact := _add_car(0, 0, 0.0, CarParams.compact())
	_park(compact)
	var truck := _add_car(30, -200, PI / 2.0, CarParams.truck())
	truck.input = CarInput.make(1.0, 0.0)
	_run(2.5)
	assert_gt(compact.state.heading, 0.05)


func test_car_starts_with_full_tank() -> void:
	var car := _add_car(0, 0, 0.0, CarParams.truck())
	assert_eq(car.state.fuel, 200.0)


func test_lost_when_every_car_is_out_of_fuel() -> void:
	var first := _add_car(0, 0, 0.0, CarParams.compact())
	var second := _add_car(300, 0, 0.0, CarParams.compact())
	first.state.fuel = 0.0
	assert_false(_world.is_lost())
	second.state.fuel = 0.0
	assert_true(_world.is_lost())


func test_won_level_is_never_lost() -> void:
	var car := _add_car(0, 0, 0.0, CarParams.compact())
	car.state.fuel = 0.0
	_world.primary = car
	_world.goal = OrientedBox.make(Vector2.ZERO, 0.0, Vector2(50, 50))
	assert_true(_world.is_won())
	assert_false(_world.is_lost())


func test_car_at_finds_the_car_under_a_point() -> void:
	var first := _add_car(0, 0, 0.0, CarParams.compact())
	var second := _add_car(300, 0, 0.0, CarParams.truck())
	assert_eq(_world.car_at(Vector2(10, 5)), first)
	assert_eq(_world.car_at(Vector2(300, 0)), second)


func test_car_at_respects_rotation() -> void:
	# The truck is 160 long and 60 wide, so turned 90 degrees it is tall, not wide.
	var car := _add_car(0, 0, PI / 2.0, CarParams.truck())
	assert_eq(_world.car_at(Vector2(0, 70)), car)
	assert_null(_world.car_at(Vector2(70, 0)))


func test_car_at_returns_null_on_empty_ground() -> void:
	_add_car(0, 0, 0.0, CarParams.compact())
	assert_null(_world.car_at(Vector2(500, 500)))


func test_car_after_cycles_in_both_directions() -> void:
	var first := _add_car(0, 0, 0.0, CarParams.compact())
	var second := _add_car(300, 0, 0.0, CarParams.compact())
	var third := _add_car(600, 0, 0.0, CarParams.compact())
	assert_eq(_world.car_after(first, 1), second)
	assert_eq(_world.car_after(third, 1), first)
	assert_eq(_world.car_after(first, -1), third)
	assert_eq(_world.car_after(second, -1), first)


func test_car_after_with_no_cars_is_null() -> void:
	assert_null(_world.car_after(null, 1))
