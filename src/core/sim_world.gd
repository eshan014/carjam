class_name SimWorld
extends RefCounted
## All cars and walls. One step() moves everything, then resolves overlaps.

const SOLVER_PASSES := 4

var cars: Array[SimCar] = []
var walls: Array[OrientedBox] = []
var goal: OrientedBox = null
var primary: SimCar = null


func add_car(car: SimCar) -> void:
	cars.append(car)


func add_wall(wall: OrientedBox) -> void:
	walls.append(wall)


func is_won() -> bool:
	if goal == null or primary == null:
		return false
	return goal.contains_point(primary.state.position)


## True when nothing can add energy to the puzzle any more: every car is out of fuel.
func is_lost() -> bool:
	if is_won() or cars.is_empty():
		return false
	for car in cars:
		if car.state.fuel > 0.0:
			return false
	return true


## The car under a point, or null. Later cars win where cars overlap.
func car_at(point: Vector2) -> SimCar:
	for index in range(cars.size() - 1, -1, -1):
		if cars[index].box().contains_point(point):
			return cars[index]
	return null


## The car `step` places after `current` in the list, wrapping around. Use -1 for the previous.
func car_after(current: SimCar, step: int) -> SimCar:
	if cars.is_empty():
		return null
	var index := cars.find(current)
	if index < 0:
		return cars[0]
	return cars[posmod(index + step, cars.size())]


func step(dt: float) -> void:
	for car in cars:
		car.state = CarModel.step(car.state, car.input, car.params, dt)
	for _pass in range(SOLVER_PASSES):
		for car in cars:
			for wall in walls:
				_resolve_wall(car, wall)
		for i in range(cars.size()):
			for j in range(i + 1, cars.size()):
				_resolve_pair(cars[i], cars[j])


# Walls never move: push the car out, then cancel the motion of the touching point into the wall.
func _resolve_wall(car: SimCar, wall: OrientedBox) -> void:
	var contact := Collision.test(car.box(), wall)
	if contact == null:
		return
	var offset := contact.point - car.state.position
	car.state.position -= contact.normal * contact.depth
	var closing := car.velocity_at(offset).dot(contact.normal)
	if closing <= 0.0:
		return
	var impulse := -contact.normal * closing / car.lever_factor(offset, contact.normal)
	car.apply_impulse(impulse, offset)


# Separate by mass (the lighter car moves more), then exchange a shove at the touching point.
func _resolve_pair(a: SimCar, b: SimCar) -> void:
	var contact := Collision.test(a.box(), b.box())
	if contact == null:
		return
	var offset_a := contact.point - a.state.position
	var offset_b := contact.point - b.state.position
	var total_mass := a.params.mass + b.params.mass
	a.state.position -= contact.normal * contact.depth * (b.params.mass / total_mass)
	b.state.position += contact.normal * contact.depth * (a.params.mass / total_mass)

	var closing := (b.velocity_at(offset_b) - a.velocity_at(offset_a)).dot(contact.normal)
	if closing >= 0.0:
		return
	var effective := (
		a.lever_factor(offset_a, contact.normal) + b.lever_factor(offset_b, contact.normal)
	)
	var impulse := contact.normal * (-closing / effective)
	a.apply_impulse(-impulse, offset_a)
	b.apply_impulse(impulse, offset_b)
