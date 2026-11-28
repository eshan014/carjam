extends Node2D
## Prototype player.
## W/A/S/D or arrows: drive.  1-9, Tab / Shift+Tab or a mouse click: pick the car to drive.
## R: restart.  [ and ]: previous / next level.
## Get the primary (blue) car into the green zone.

const LEVEL_FOLDER := "res://levels"
const PRIMARY_COLOR := Color.STEEL_BLUE
const OTHER_COLORS: Array[Color] = [
	Color.SEA_GREEN,
	Color.INDIAN_RED,
	Color.DARK_ORANGE,
	Color.MEDIUM_PURPLE,
	Color.TEAL,
	Color.SADDLE_BROWN,
]
const GOAL_COLOR := Color(0.2, 0.9, 0.3, 0.35)

var _level_paths: Array[String] = []
var _level_index := 0
var _world: SimWorld = null
var _driven: SimCar = null
var _error := ""


func _ready() -> void:
	for file_name in DirAccess.get_files_at(LEVEL_FOLDER):
		if file_name.ends_with(".json"):
			_level_paths.append(LEVEL_FOLDER + "/" + file_name)
	_level_paths.sort()
	_reset()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_BRACKETRIGHT:
			_change_level(1)
		elif event.keycode == KEY_BRACKETLEFT:
			_change_level(-1)
		elif event.keycode == KEY_TAB and _world != null:
			var step := -1 if event.shift_pressed else 1
			_select(_world.car_after(_driven, step))
	elif (
		event is InputEventMouseButton
		and event.pressed
		and event.button_index == MOUSE_BUTTON_LEFT
		and _world != null
	):
		_select(_world.car_at(get_global_mouse_position()))


func _physics_process(delta: float) -> void:
	if Input.is_physical_key_pressed(KEY_R):
		_reset()
	if _world == null:
		return
	for number in range(mini(_world.cars.size(), 9)):
		if Input.is_physical_key_pressed((KEY_1 + number) as Key):
			_select(_world.cars[number])

	# Cars you are not driving stay parked with the handbrake on.
	for car in _world.cars:
		car.input = CarInput.make(0.0, 0.0, true)
	var throttle := clampf(_axis(KEY_S, KEY_W) + _axis(KEY_DOWN, KEY_UP), -1.0, 1.0)
	var steer := clampf(_axis(KEY_A, KEY_D) + _axis(KEY_LEFT, KEY_RIGHT), -1.0, 1.0)
	_driven.input = CarInput.make(throttle, steer)

	_world.step(delta)
	queue_redraw()


func _draw() -> void:
	draw_set_transform(Vector2.ZERO, 0.0)
	if _world == null:
		_draw_text(_error, Vector2(40.0, 50.0), 32, Color.TOMATO)
		return
	_draw_box(_world.goal, GOAL_COLOR)
	for wall in _world.walls:
		_draw_box(wall, Color.DIM_GRAY)
	for index in range(_world.cars.size()):
		_draw_car(_world.cars[index], index)
	draw_set_transform(Vector2.ZERO, 0.0)
	_draw_hud()


func _draw_car(car: SimCar, index: int) -> void:
	var box := car.box()
	_draw_box(box, _car_color(car, index))
	# Yellow block marks the front of the car.
	var half := box.half_size
	draw_rect(Rect2(Vector2(half.x - 15.0, -half.y), Vector2(15.0, half.y * 2.0)), Color.GOLD)
	if car == _driven:
		draw_rect(Rect2(-half, half * 2.0), Color.WHITE, false, 3.0)

	draw_set_transform(Vector2.ZERO, 0.0)
	var origin := car.state.position + Vector2(-30.0, 6.0)
	var font := ThemeDB.fallback_font
	draw_string(font, origin, str(index + 1), HORIZONTAL_ALIGNMENT_CENTER, 60.0, 20, Color.WHITE)
	draw_string(
		font,
		origin + Vector2(0.0, 14.0),
		car.params.type_name,
		HORIZONTAL_ALIGNMENT_CENTER,
		60.0,
		11,
		Color.WHITE
	)


func _draw_hud() -> void:
	var car := _driven
	var params := car.params
	var number := _world.cars.find(car) + 1
	_draw_text("Driving %d: %s" % [number, params.type_name], Vector2(40.0, 40.0), 24, Color.WHITE)
	_draw_fuel_bar(car)
	var stats := (
		"mass %d   accel %d   top speed %d   speed %d"
		% [params.mass, params.acceleration(), params.max_speed, absf(car.state.speed)]
	)
	_draw_text(stats, Vector2(40.0, 100.0), 16, Color.WHITE)
	var level_name := _level_paths[_level_index].get_file()
	var hint := "Tab / click / 1-9: switch car    R: restart    [ ]: level (%s)" % level_name
	_draw_text(hint, Vector2(40.0, get_viewport_rect().size.y - 14.0), 16, Color.WHITE)
	if _world.is_won():
		_draw_text("SOLVED! Press R to reset", Vector2(40.0, 150.0), 32, Color.WHITE)
	elif _world.is_lost():
		_draw_text("OUT OF FUEL. Press R to retry", Vector2(40.0, 150.0), 32, Color.TOMATO)


func _draw_fuel_bar(car: SimCar) -> void:
	var fraction := clampf(car.state.fuel / car.params.fuel_capacity, 0.0, 1.0)
	var bar := Rect2(Vector2(40.0, 56.0), Vector2(240.0, 16.0))
	draw_rect(bar, Color(0.0, 0.0, 0.0, 0.5))
	var color := Color.GOLD if fraction > 0.25 else Color.TOMATO
	draw_rect(Rect2(bar.position, Vector2(bar.size.x * fraction, bar.size.y)), color)
	draw_rect(bar, Color.WHITE, false, 2.0)
	var label := "fuel %d / %d" % [car.state.fuel, car.params.fuel_capacity]
	_draw_text(label, Vector2(290.0, 70.0), 16, Color.WHITE)


func _draw_box(box: OrientedBox, color: Color) -> void:
	draw_set_transform(box.center, box.angle)
	draw_rect(Rect2(-box.half_size, box.half_size * 2.0), color)


func _draw_text(text: String, at: Vector2, size: int, color: Color) -> void:
	draw_string(ThemeDB.fallback_font, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, size, color)


func _car_color(car: SimCar, index: int) -> Color:
	if car == _world.primary:
		return PRIMARY_COLOR
	return OTHER_COLORS[index % OTHER_COLORS.size()]


func _select(car: SimCar) -> void:
	if car != null:
		_driven = car


func _change_level(step: int) -> void:
	if _level_paths.is_empty():
		return
	_level_index = posmod(_level_index + step, _level_paths.size())
	_reset()


func _reset() -> void:
	if _level_paths.is_empty():
		_world = null
		_driven = null
		_error = "No level files in " + LEVEL_FOLDER
		queue_redraw()
		return
	var result := LevelLoader.from_file(_level_paths[_level_index])
	_world = result.world
	_error = result.error
	_driven = null if _world == null else _world.primary
	queue_redraw()


func _axis(negative: Key, positive: Key) -> float:
	return (
		float(Input.is_physical_key_pressed(positive))
		- float(Input.is_physical_key_pressed(negative))
	)
