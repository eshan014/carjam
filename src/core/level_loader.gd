class_name LevelLoader
extends RefCounted
## Builds a SimWorld from level data. Units are pixels, angles are degrees.
## The arena box generates the four outer walls; "walls" adds extra obstacles.

const WALL_THICKNESS := 20.0


static func from_file(path: String) -> LevelLoadResult:
	if not FileAccess.file_exists(path):
		return LevelLoadResult.fail("File not found: " + path)
	return from_json(FileAccess.get_file_as_string(path))


static func from_json(text: String) -> LevelLoadResult:
	var json := JSON.new()
	if json.parse(text) != OK:
		return LevelLoadResult.fail("Invalid JSON: " + json.get_error_message())
	if typeof(json.data) != TYPE_DICTIONARY:
		return LevelLoadResult.fail("Level must be a JSON object")
	return from_dictionary(json.data)


static func from_dictionary(data: Dictionary) -> LevelLoadResult:
	var arena := _box(data.get("arena"))
	if arena == null:
		return LevelLoadResult.fail("'arena' needs 'center' and 'half' as [x, y]")
	var goal := _box(data.get("goal"))
	if goal == null:
		return LevelLoadResult.fail("'goal' needs 'center' and 'half' as [x, y]")

	var world := SimWorld.new()
	world.goal = goal
	_add_arena_walls(world, arena)

	var extra_walls: Variant = data.get("walls", [])
	if typeof(extra_walls) != TYPE_ARRAY:
		return LevelLoadResult.fail("'walls' must be a list")
	for index in range(extra_walls.size()):
		var wall := _box(extra_walls[index])
		if wall == null:
			return LevelLoadResult.fail("Wall %d needs 'center' and 'half' as [x, y]" % index)
		world.add_wall(wall)

	var cars: Variant = data.get("cars", [])
	if typeof(cars) != TYPE_ARRAY:
		return LevelLoadResult.fail("'cars' must be a list")
	for index in range(cars.size()):
		var problem := _add_car(world, cars[index], index)
		if problem != "":
			return LevelLoadResult.fail(problem)

	if world.primary == null:
		return LevelLoadResult.fail('One car needs "primary": true')
	return LevelLoadResult.ok(world)


static func _add_car(world: SimWorld, entry: Variant, index: int) -> String:
	if typeof(entry) != TYPE_DICTIONARY:
		return "Car %d must be an object" % index
	var params := CarParams.by_name(str(entry.get("type", "")))
	if params == null:
		return "Car %d has unknown type (use compact or truck)" % index
	var start: Variant = _vec(entry.get("position"))
	if start == null:
		return "Car %d needs 'position' as [x, y]" % index
	var degrees: Variant = entry.get("heading", 0.0)
	if not _is_number(degrees):
		return "Car %d 'heading' must be a number (degrees)" % index

	var fuel: Variant = entry.get("fuel", params.fuel_capacity)
	if not _is_number(fuel) or float(fuel) < 0.0:
		return "Car %d 'fuel' must be a number, 0 or more" % index

	var car := SimCar.make(start, deg_to_rad(float(degrees)), params)
	car.state.fuel = float(fuel)
	world.add_car(car)
	if entry.get("primary", false) == true:
		if world.primary != null:
			return "Only one car can be primary"
		world.primary = car
	return ""


static func _add_arena_walls(world: SimWorld, arena: OrientedBox) -> void:
	var inner := arena.half_size
	var half_thick := WALL_THICKNESS / 2.0
	var wide := Vector2(inner.x + WALL_THICKNESS, half_thick)
	var tall := Vector2(half_thick, inner.y + WALL_THICKNESS)
	var edge_x := inner.x + half_thick
	var edge_y := inner.y + half_thick
	world.add_wall(OrientedBox.make(arena.center + Vector2(0, -edge_y), 0.0, wide))
	world.add_wall(OrientedBox.make(arena.center + Vector2(0, edge_y), 0.0, wide))
	world.add_wall(OrientedBox.make(arena.center + Vector2(-edge_x, 0), 0.0, tall))
	world.add_wall(OrientedBox.make(arena.center + Vector2(edge_x, 0), 0.0, tall))


## Returns null when the entry is not a valid box description.
static func _box(entry: Variant) -> OrientedBox:
	if typeof(entry) != TYPE_DICTIONARY:
		return null
	var center: Variant = _vec(entry.get("center"))
	var half: Variant = _vec(entry.get("half"))
	if center == null or half == null:
		return null
	var degrees: Variant = entry.get("angle", 0.0)
	if not _is_number(degrees):
		return null
	return OrientedBox.make(center, deg_to_rad(float(degrees)), half)


## Returns null unless the value is a list of exactly two numbers.
static func _vec(value: Variant) -> Variant:
	if typeof(value) != TYPE_ARRAY or value.size() != 2:
		return null
	if not _is_number(value[0]) or not _is_number(value[1]):
		return null
	return Vector2(float(value[0]), float(value[1]))


static func _is_number(value: Variant) -> bool:
	return typeof(value) == TYPE_FLOAT or typeof(value) == TYPE_INT
