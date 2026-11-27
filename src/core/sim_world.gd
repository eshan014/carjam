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


# Walls never move: push the car out and cancel its speed into the wall.
func _resolve_wall(car: SimCar, wall: OrientedBox) -> void:
	var contact := Collision.test(car.box(), wall)
	if contact == null:
		return
	car.state.position -= contact.normal * contact.depth
	var velocity := car.velocity()
	var into_wall := velocity.dot(contact.normal)
	if into_wall > 0.0:
		car.set_velocity(velocity - contact.normal * into_wall)


# Separate by mass (the lighter car moves more), then share speed along the contact line.
func _resolve_pair(a: SimCar, b: SimCar) -> void:
	var contact := Collision.test(a.box(), b.box())
	if contact == null:
		return
	var total_mass := a.params.mass + b.params.mass
	a.state.position -= contact.normal * contact.depth * (b.params.mass / total_mass)
	b.state.position += contact.normal * contact.depth * (a.params.mass / total_mass)

	var a_velocity := a.velocity()
	var b_velocity := b.velocity()
	var a_normal := a_velocity.dot(contact.normal)
	var b_normal := b_velocity.dot(contact.normal)
	if b_normal - a_normal >= 0.0:
		return
	var shared := (a.params.mass * a_normal + b.params.mass * b_normal) / total_mass
	a.set_velocity(a_velocity + contact.normal * (shared - a_normal))
	b.set_velocity(b_velocity + contact.normal * (shared - b_normal))
