class_name CarInput
extends RefCounted
## What the driver asks for. throttle and steer range from -1 to 1.

var throttle: float = 0.0
var steer: float = 0.0
var handbrake: bool = false


static func make(
	throttle_value: float, steer_value: float, handbrake_value: bool = false
) -> CarInput:
	var result := CarInput.new()
	result.throttle = throttle_value
	result.steer = steer_value
	result.handbrake = handbrake_value
	return result
