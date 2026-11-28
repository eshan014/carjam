class_name CarState
extends RefCounted
## Everything about a car that changes while it moves.
## slide is sideways velocity and spin is rotation speed, both from being pushed.

var position: Vector2 = Vector2.ZERO
var heading: float = 0.0
var speed: float = 0.0
var steer: float = 0.0
var slide: Vector2 = Vector2.ZERO
var spin: float = 0.0
var fuel: float = INF


func copy() -> CarState:
	var result := CarState.new()
	result.position = position
	result.heading = heading
	result.speed = speed
	result.steer = steer
	result.slide = slide
	result.spin = spin
	result.fuel = fuel
	return result
