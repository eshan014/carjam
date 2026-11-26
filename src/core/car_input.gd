class_name CarInput
extends RefCounted
## What the driver asks for. Both values range from -1 to 1.

var throttle: float = 0.0
var steer: float = 0.0


static func make(throttle_value: float, steer_value: float) -> CarInput:
	var result := CarInput.new()
	result.throttle = throttle_value
	result.steer = steer_value
	return result
