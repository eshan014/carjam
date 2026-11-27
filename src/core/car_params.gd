class_name CarParams
extends RefCounted
## Fixed numbers that describe one type of car.
## Forces are in mass * px/s^2, so acceleration = force / mass.

var mass: float = 1000.0
var engine_force: float = 200000.0
var brake_force: float = 400000.0
var friction_force: float = 150000.0
var park_brake_force: float = 100000.0
var lateral_grip: float = 120.0
var wheelbase: float = 60.0
var length: float = 90.0
var width: float = 45.0
var max_steer: float = 0.6
var steer_rate: float = 3.0
var max_speed: float = 250.0
var max_reverse_speed: float = 100.0


static func compact() -> CarParams:
	return CarParams.new()


static func truck() -> CarParams:
	var result := CarParams.new()
	result.mass = 3000.0
	result.engine_force = 450000.0
	result.brake_force = 900000.0
	result.friction_force = 450000.0
	result.park_brake_force = 300000.0
	result.wheelbase = 120.0
	result.length = 160.0
	result.width = 60.0
	result.max_steer = 0.45
	result.max_speed = 180.0
	result.max_reverse_speed = 70.0
	return result


func acceleration() -> float:
	return engine_force / mass


func braking() -> float:
	return brake_force / mass


func coast_drag() -> float:
	return friction_force / mass


func parking_drag() -> float:
	return park_brake_force / mass
