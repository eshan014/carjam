class_name CarParams
extends RefCounted
## Fixed numbers that describe one type of vehicle.
## Forces are in mass * px/s^2, so acceleration = force / mass.
## engine_force is the "power" number: more power or less mass means faster acceleration.

var type_name: String = "compact"
var mass: float = 1000.0
var engine_force: float = 200000.0
var brake_force: float = 400000.0
var friction_force: float = 150000.0
var park_brake_force: float = 100000.0
var lateral_grip: float = 120.0
var spin_grip: float = 6.0
var wheelbase: float = 60.0
var length: float = 90.0
var width: float = 45.0
var max_steer: float = 0.6
var steer_rate: float = 3.0
var max_speed: float = 250.0
var max_reverse_speed: float = 100.0
var fuel_capacity: float = 100.0
var fuel_burn: float = 5.0


static func type_names() -> PackedStringArray:
	return PackedStringArray(["compact", "sports", "bike", "van", "truck", "bus", "tractor"])


## Returns null for an unknown type name.
static func by_name(wanted: String) -> CarParams:
	match wanted:
		"compact":
			return compact()
		"sports":
			return sports()
		"bike":
			return bike()
		"van":
			return van()
		"truck":
			return truck()
		"bus":
			return bus()
		"tractor":
			return tractor()
	return null


static func compact() -> CarParams:
	return CarParams.new()


## Light, nimble, quick off the line. Gets launched by anything bigger.
static func bike() -> CarParams:
	var result := CarParams.new()
	result.type_name = "bike"
	result.mass = 200.0
	result.engine_force = 80000.0
	result.brake_force = 120000.0
	result.friction_force = 20000.0
	result.park_brake_force = 40000.0
	result.lateral_grip = 160.0
	result.spin_grip = 8.0
	result.wheelbase = 35.0
	result.length = 55.0
	result.width = 20.0
	result.max_steer = 0.8
	result.steer_rate = 4.0
	result.max_speed = 320.0
	result.max_reverse_speed = 60.0
	result.fuel_capacity = 40.0
	result.fuel_burn = 2.0
	return result


## Fastest vehicle, thirsty, a bit wider turning circle than the compact.
static func sports() -> CarParams:
	var result := CarParams.new()
	result.type_name = "sports"
	result.mass = 1200.0
	result.engine_force = 480000.0
	result.brake_force = 600000.0
	result.friction_force = 120000.0
	result.park_brake_force = 120000.0
	result.lateral_grip = 140.0
	result.wheelbase = 62.0
	result.length = 95.0
	result.width = 46.0
	result.max_steer = 0.5
	result.steer_rate = 3.5
	result.max_speed = 380.0
	result.max_reverse_speed = 100.0
	result.fuel_capacity = 100.0
	result.fuel_burn = 10.0
	return result


static func van() -> CarParams:
	var result := CarParams.new()
	result.type_name = "van"
	result.mass = 2000.0
	result.engine_force = 300000.0
	result.brake_force = 600000.0
	result.friction_force = 240000.0
	result.park_brake_force = 200000.0
	result.spin_grip = 5.0
	result.wheelbase = 90.0
	result.length = 125.0
	result.width = 52.0
	result.max_steer = 0.5
	result.steer_rate = 2.5
	result.max_speed = 210.0
	result.max_reverse_speed = 80.0
	result.fuel_capacity = 150.0
	result.fuel_burn = 8.0
	return result


static func truck() -> CarParams:
	var result := CarParams.new()
	result.type_name = "truck"
	result.mass = 3000.0
	result.engine_force = 450000.0
	result.brake_force = 900000.0
	result.friction_force = 450000.0
	result.park_brake_force = 300000.0
	result.spin_grip = 4.0
	result.wheelbase = 120.0
	result.length = 160.0
	result.width = 60.0
	result.max_steer = 0.45
	result.max_speed = 180.0
	result.max_reverse_speed = 70.0
	result.fuel_capacity = 200.0
	result.fuel_burn = 12.0
	return result


## Huge, slow to move, impossible to push, turns in a very wide circle.
static func bus() -> CarParams:
	var result := CarParams.new()
	result.type_name = "bus"
	result.mass = 8000.0
	result.engine_force = 800000.0
	result.brake_force = 2000000.0
	result.friction_force = 800000.0
	result.park_brake_force = 800000.0
	result.spin_grip = 3.0
	result.wheelbase = 170.0
	result.length = 230.0
	result.width = 70.0
	result.max_steer = 0.45
	result.steer_rate = 2.0
	result.max_speed = 140.0
	result.max_reverse_speed = 50.0
	result.fuel_capacity = 300.0
	result.fuel_burn = 20.0
	return result


## A bulldozer: very slow, but strong and tight-turning.
static func tractor() -> CarParams:
	var result := CarParams.new()
	result.type_name = "tractor"
	result.mass = 4000.0
	result.engine_force = 1000000.0
	result.brake_force = 1200000.0
	result.friction_force = 600000.0
	result.park_brake_force = 600000.0
	result.lateral_grip = 160.0
	result.spin_grip = 5.0
	result.wheelbase = 70.0
	result.length = 110.0
	result.width = 70.0
	result.max_steer = 0.7
	result.steer_rate = 2.5
	result.max_speed = 90.0
	result.max_reverse_speed = 60.0
	result.fuel_capacity = 120.0
	result.fuel_burn = 10.0
	return result


func acceleration() -> float:
	return engine_force / mass


func braking() -> float:
	return brake_force / mass


func coast_drag() -> float:
	return friction_force / mass


func parking_drag() -> float:
	return park_brake_force / mass


## How hard it is to spin the car around its center.
func inertia() -> float:
	return mass * (length * length + width * width) / 12.0


## Approximate tightest circle the vehicle can drive.
func turning_radius() -> float:
	return wheelbase / tan(max_steer)
