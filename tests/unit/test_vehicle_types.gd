extends GutTest


func test_every_listed_type_builds_with_its_own_name() -> void:
	for type_name in CarParams.type_names():
		var params := CarParams.by_name(type_name)
		assert_not_null(params, type_name)
		if params == null:
			continue
		assert_eq(params.type_name, type_name)


func test_unknown_type_gives_null() -> void:
	assert_null(CarParams.by_name("hovercraft"))


func test_every_type_has_sane_numbers() -> void:
	for type_name in CarParams.type_names():
		var p := CarParams.by_name(type_name)
		assert_gt(p.mass, 0.0, type_name)
		assert_gt(p.acceleration(), 0.0, type_name)
		assert_gt(p.braking(), 0.0, type_name)
		assert_gt(p.max_speed, 0.0, type_name)
		assert_gt(p.max_reverse_speed, 0.0, type_name)
		assert_gt(p.length, p.width, type_name)
		assert_gt(p.length, p.wheelbase, type_name)
		assert_gt(p.max_steer, 0.0, type_name)
		assert_lt(p.max_steer, 1.5, type_name)
		assert_gt(p.turning_radius(), 0.0, type_name)


func test_full_tank_lasts_at_least_eight_seconds_of_full_throttle() -> void:
	for type_name in CarParams.type_names():
		var p := CarParams.by_name(type_name)
		assert_gte(p.fuel_capacity / p.fuel_burn, 8.0, type_name)


func test_heavier_classes_have_more_mass() -> void:
	assert_lt(CarParams.bike().mass, CarParams.compact().mass)
	assert_lt(CarParams.compact().mass, CarParams.van().mass)
	assert_lt(CarParams.van().mass, CarParams.truck().mass)
	assert_lt(CarParams.truck().mass, CarParams.bus().mass)


func test_turning_circles_grow_with_size() -> void:
	assert_lt(CarParams.bike().turning_radius(), CarParams.compact().turning_radius())
	assert_lt(CarParams.compact().turning_radius(), CarParams.van().turning_radius())
	assert_lt(CarParams.van().turning_radius(), CarParams.truck().turning_radius())
	assert_lt(CarParams.truck().turning_radius(), CarParams.bus().turning_radius())
