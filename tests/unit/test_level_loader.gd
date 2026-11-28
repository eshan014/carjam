extends GutTest


func _valid_level() -> Dictionary:
	return {
		"arena": {"center": [0, 0], "half": [500, 200]},
		"goal": {"center": [450, 0], "half": [50, 200]},
		"walls": [{"center": [0, 0], "half": [10, 10], "angle": 45}],
		"cars":
		[
			{"type": "compact", "position": [-300, 0], "heading": 0, "primary": true},
			{"type": "truck", "position": [0, 100], "heading": 90},
		],
	}


func test_valid_level_builds_world() -> void:
	var result := LevelLoader.from_dictionary(_valid_level())
	assert_eq(result.error, "")
	assert_not_null(result.world)
	assert_eq(result.world.cars.size(), 2)
	assert_eq(result.world.walls.size(), 5)
	assert_eq(result.world.primary, result.world.cars[0])
	assert_not_null(result.world.goal)


func test_heading_is_read_in_degrees() -> void:
	var result := LevelLoader.from_dictionary(_valid_level())
	assert_almost_eq(result.world.cars[1].state.heading, PI / 2.0, 0.0001)


func test_car_type_sets_params() -> void:
	var result := LevelLoader.from_dictionary(_valid_level())
	assert_eq(result.world.cars[0].params.mass, 1000.0)
	assert_eq(result.world.cars[1].params.mass, 3000.0)


func test_missing_arena_is_an_error() -> void:
	var data := _valid_level()
	data.erase("arena")
	var result := LevelLoader.from_dictionary(data)
	assert_null(result.world)
	assert_string_contains(result.error, "arena")


func test_missing_goal_is_an_error() -> void:
	var data := _valid_level()
	data.erase("goal")
	var result := LevelLoader.from_dictionary(data)
	assert_null(result.world)
	assert_string_contains(result.error, "goal")


func test_unknown_car_type_is_an_error() -> void:
	var data := _valid_level()
	data["cars"][1]["type"] = "bus"
	var result := LevelLoader.from_dictionary(data)
	assert_null(result.world)
	assert_string_contains(result.error, "unknown type")


func test_no_primary_car_is_an_error() -> void:
	var data := _valid_level()
	data["cars"][0]["primary"] = false
	var result := LevelLoader.from_dictionary(data)
	assert_null(result.world)
	assert_string_contains(result.error, "primary")


func test_two_primary_cars_is_an_error() -> void:
	var data := _valid_level()
	data["cars"][1]["primary"] = true
	var result := LevelLoader.from_dictionary(data)
	assert_null(result.world)
	assert_string_contains(result.error, "primary")


func test_bad_car_position_names_the_car() -> void:
	var data := _valid_level()
	data["cars"][0]["position"] = [1, 2, 3]
	var result := LevelLoader.from_dictionary(data)
	assert_null(result.world)
	assert_string_contains(result.error, "Car 0")


func test_invalid_json_is_an_error() -> void:
	var result := LevelLoader.from_json("{not json")
	assert_null(result.world)
	assert_string_contains(result.error, "JSON")


func test_json_that_is_not_an_object_is_an_error() -> void:
	var result := LevelLoader.from_json("[1, 2]")
	assert_null(result.world)
	assert_string_contains(result.error, "object")


func test_every_shipped_level_loads() -> void:
	var checked := 0
	for file_name in DirAccess.get_files_at("res://levels"):
		if file_name.ends_with(".json"):
			var result := LevelLoader.from_file("res://levels/" + file_name)
			assert_eq(result.error, "", file_name)
			checked += 1
	assert_gt(checked, 0)


func test_fuel_defaults_to_full_tank() -> void:
	var result := LevelLoader.from_dictionary(_valid_level())
	assert_eq(result.world.cars[0].state.fuel, 100.0)
	assert_eq(result.world.cars[1].state.fuel, 200.0)


func test_fuel_can_be_set_per_car() -> void:
	var data := _valid_level()
	data["cars"][0]["fuel"] = 40
	var result := LevelLoader.from_dictionary(data)
	assert_eq(result.world.cars[0].state.fuel, 40.0)


func test_negative_fuel_is_an_error() -> void:
	var data := _valid_level()
	data["cars"][0]["fuel"] = -5
	var result := LevelLoader.from_dictionary(data)
	assert_null(result.world)
	assert_string_contains(result.error, "fuel")


func test_non_number_fuel_is_an_error() -> void:
	var data := _valid_level()
	data["cars"][0]["fuel"] = "lots"
	var result := LevelLoader.from_dictionary(data)
	assert_null(result.world)
	assert_string_contains(result.error, "fuel")
