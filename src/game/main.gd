extends Node2D
## Prototype puzzle. W/A/S/D or arrows drive, 1-4 pick the car, R resets.
## Get the blue car into the green zone.

const ARENA_CENTER := Vector2(576, 324)
const ARENA_HALF := Vector2(500, 180)
const WALL_THICKNESS := 20.0
const CAR_COLORS: Array[Color] = [
	Color.STEEL_BLUE, Color.SEA_GREEN, Color.INDIAN_RED, Color.DARK_ORANGE
]
const GOAL_COLOR := Color(0.2, 0.9, 0.3, 0.35)

var _world: SimWorld
var _driven: SimCar


func _ready() -> void:
	_reset()


func _physics_process(delta: float) -> void:
	if Input.is_physical_key_pressed(KEY_R):
		_reset()
	for number in range(_world.cars.size()):
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
	_draw_box(_world.goal, GOAL_COLOR)
	for wall in _world.walls:
		_draw_box(wall, Color.DIM_GRAY)
	for i in range(_world.cars.size()):
		var car := _world.cars[i]
		_draw_box(car.box(), CAR_COLORS[i])
		var half := car.box().half_size
		# Yellow block marks the front of the car.
		draw_rect(Rect2(Vector2(half.x - 15.0, -half.y), Vector2(15.0, half.y * 2.0)), Color.GOLD)
		if car == _driven:
			draw_rect(Rect2(-half, half * 2.0), Color.WHITE, false, 3.0)
	if _world.is_won():
		draw_set_transform(Vector2.ZERO, 0.0)
		draw_string(
			ThemeDB.fallback_font,
			Vector2(40.0, 50.0),
			"SOLVED! Press R to reset",
			HORIZONTAL_ALIGNMENT_LEFT,
			-1.0,
			32,
			Color.WHITE
		)


func _draw_box(box: OrientedBox, color: Color) -> void:
	draw_set_transform(box.center, box.angle)
	draw_rect(Rect2(-box.half_size, box.half_size * 2.0), color)


func _reset() -> void:
	_world = SimWorld.new()
	var half_thick := WALL_THICKNESS / 2.0
	var wide := Vector2(ARENA_HALF.x + WALL_THICKNESS, half_thick)
	var tall := Vector2(half_thick, ARENA_HALF.y + WALL_THICKNESS)
	var edge_x := ARENA_HALF.x + half_thick
	var edge_y := ARENA_HALF.y + half_thick
	_world.add_wall(OrientedBox.make(ARENA_CENTER + Vector2(0, -edge_y), 0.0, wide))
	_world.add_wall(OrientedBox.make(ARENA_CENTER + Vector2(0, edge_y), 0.0, wide))
	_world.add_wall(OrientedBox.make(ARENA_CENTER + Vector2(-edge_x, 0), 0.0, tall))
	_world.add_wall(OrientedBox.make(ARENA_CENTER + Vector2(edge_x, 0), 0.0, tall))

	var primary := SimCar.make(ARENA_CENTER + Vector2(-380, 0), 0.0, CarParams.compact())
	_world.add_car(primary)
	_world.primary = primary
	_world.add_car(SimCar.make(ARENA_CENTER + Vector2(0, -100), PI / 2.0, CarParams.truck()))
	_world.add_car(SimCar.make(ARENA_CENTER + Vector2(0, 25), PI / 2.0, CarParams.compact()))
	_world.add_car(SimCar.make(ARENA_CENTER + Vector2(0, 115), PI / 2.0, CarParams.compact()))
	_world.goal = OrientedBox.make(ARENA_CENTER + Vector2(440, 0), 0.0, Vector2(50, ARENA_HALF.y))
	_driven = primary


func _axis(negative: Key, positive: Key) -> float:
	return (
		float(Input.is_physical_key_pressed(positive))
		- float(Input.is_physical_key_pressed(negative))
	)
