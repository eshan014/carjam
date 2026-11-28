extends Node2D
## Prototype player. W/A/S/D or arrows drive, 1-9 pick the car, R reloads the level.
## Get the blue (primary) car into the green zone.

const LEVEL_PATH := "res://levels/level_01.json"
const PRIMARY_COLOR := Color.STEEL_BLUE
const OTHER_COLORS: Array[Color] = [Color.SEA_GREEN, Color.INDIAN_RED, Color.DARK_ORANGE]
const GOAL_COLOR := Color(0.2, 0.9, 0.3, 0.35)

var _world: SimWorld = null
var _driven: SimCar = null
var _error := ""


func _ready() -> void:
	_reset()


func _physics_process(delta: float) -> void:
	if Input.is_physical_key_pressed(KEY_R):
		_reset()
	if _world == null:
		return
	for number in range(mini(_world.cars.size(), 9)):
		if Input.is_physical_key_pressed((KEY_1 + number) as Key):
			_driven = _world.cars[number]

	for car in _world.cars:
		car.input = CarInput.make(0.0, 0.0, true)
	var throttle := clampf(_axis(KEY_S, KEY_W) + _axis(KEY_DOWN, KEY_UP), -1.0, 1.0)
	var steer := clampf(_axis(KEY_A, KEY_D) + _axis(KEY_LEFT, KEY_RIGHT), -1.0, 1.0)
	_driven.input = CarInput.make(throttle, steer)

	_world.step(delta)
	queue_redraw()


func _draw() -> void:
	if _world == null:
		draw_set_transform(Vector2.ZERO, 0.0)
		_draw_text(_error, Color.TOMATO)
		return
	_draw_box(_world.goal, GOAL_COLOR)
	for wall in _world.walls:
		_draw_box(wall, Color.DIM_GRAY)
	for i in range(_world.cars.size()):
		var car := _world.cars[i]
		var color := (
			PRIMARY_COLOR if car == _world.primary else OTHER_COLORS[i % OTHER_COLORS.size()]
		)
		_draw_box(car.box(), color)
		var half := car.box().half_size
		# Yellow block marks the front of the car.
		draw_rect(Rect2(Vector2(half.x - 15.0, -half.y), Vector2(15.0, half.y * 2.0)), Color.GOLD)
		if car == _driven:
			draw_rect(Rect2(-half, half * 2.0), Color.WHITE, false, 3.0)
		draw_set_transform(Vector2.ZERO, 0.0)
		_draw_fuel_bar()
		if _world.is_won():
			_draw_text("SOLVED! Press R to reset", Color.WHITE)
		elif _world.is_lost():
			_draw_text("OUT OF FUEL. Press R to retry", Color.TOMATO)


func _draw_box(box: OrientedBox, color: Color) -> void:
	draw_set_transform(box.center, box.angle)
	draw_rect(Rect2(-box.half_size, box.half_size * 2.0), color)


func _draw_text(text: String, color: Color) -> void:
	draw_string(
		ThemeDB.fallback_font, Vector2(40.0, 50.0), text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 32, color
	)


func _draw_fuel_bar() -> void:
	var fraction := clampf(_driven.state.fuel / _driven.params.fuel_capacity, 0.0, 1.0)
	var bar := Rect2(Vector2(40.0, 70.0), Vector2(240.0, 16.0))
	draw_rect(bar, Color(0.0, 0.0, 0.0, 0.5))
	var color := Color.GOLD if fraction > 0.25 else Color.TOMATO
	draw_rect(Rect2(bar.position, Vector2(bar.size.x * fraction, bar.size.y)), color)
	draw_rect(bar, Color.WHITE, false, 2.0)


func _reset() -> void:
	var result := LevelLoader.from_file(LEVEL_PATH)
	_world = result.world
	_error = result.error
	_driven = null if _world == null else _world.primary
	queue_redraw()


func _axis(negative: Key, positive: Key) -> float:
	return (
		float(Input.is_physical_key_pressed(positive))
		- float(Input.is_physical_key_pressed(negative))
	)
