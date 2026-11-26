extends Node2D
## Prototype: drive one car with the keyboard. W/S throttle, A/D steer, R reset.

const START_POSITION := Vector2(576, 324)

var _params := CarParams.new()
var _state := CarState.new()


func _ready() -> void:
	_reset()


func _physics_process(delta: float) -> void:
	if Input.is_physical_key_pressed(KEY_R):
		_reset()
	var throttle := clampf(_axis(KEY_S, KEY_W) + _axis(KEY_DOWN, KEY_UP), -1.0, 1.0)
	var steer := clampf(_axis(KEY_A, KEY_D) + _axis(KEY_LEFT, KEY_RIGHT), -1.0, 1.0)
	_state = CarModel.step(_state, CarInput.make(throttle, steer), _params, delta)
	queue_redraw()


func _draw() -> void:
	draw_set_transform(_state.position, _state.heading)
	var half := Vector2(_params.length, _params.width) / 2.0
	draw_rect(Rect2(-half, half * 2.0), Color.STEEL_BLUE)
	# Yellow block marks the front of the car.
	draw_rect(Rect2(Vector2(half.x - 15.0, -half.y), Vector2(15.0, half.y * 2.0)), Color.GOLD)


func _reset() -> void:
	_state = CarState.new()
	_state.position = START_POSITION


func _axis(negative: Key, positive: Key) -> float:
	return (
		float(Input.is_physical_key_pressed(positive))
		- float(Input.is_physical_key_pressed(negative))
	)
