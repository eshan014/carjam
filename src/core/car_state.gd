class_name CarState
extends RefCounted
## Everything about a car that changes while it moves.
## slide is sideways velocity (from being pushed), separate from speed along the heading.

var position: Vector2 = Vector2.ZERO
var heading: float = 0.0
var speed: float = 0.0
var steer: float = 0.0
var slide: Vector2 = Vector2.ZERO


func copy() -> CarState:
	var result := CarState.new()
	result.position = position
	result.heading = heading
	result.speed = speed
	result.steer = steer
	result.slide = slide
	return result
