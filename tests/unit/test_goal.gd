extends GutTest

var _world: SimWorld
var _primary: SimCar


func before_each() -> void:
	_world = SimWorld.new()
	_primary = SimCar.make(Vector2.ZERO, 0.0, CarParams.compact())
	_world.add_car(_primary)
	_world.primary = _primary
	_world.goal = OrientedBox.make(Vector2(500, 0), 0.0, Vector2(50, 100))


func test_box_contains_point_respects_rotation() -> void:
	var bar := OrientedBox.make(Vector2.ZERO, PI / 4.0, Vector2(10, 2))
	assert_true(bar.contains_point(Vector2(5, 5)))
	assert_false(bar.contains_point(Vector2(5, -5)))


func test_not_won_at_start() -> void:
	assert_false(_world.is_won())


func test_won_when_primary_center_is_in_goal() -> void:
	_primary.state.position = Vector2(500, 0)
	assert_true(_world.is_won())


func test_not_won_when_primary_is_outside_goal() -> void:
	_primary.state.position = Vector2(500, 150)
	assert_false(_world.is_won())


func test_other_car_in_goal_does_not_win() -> void:
	var other := SimCar.make(Vector2(500, 0), 0.0, CarParams.compact())
	_world.add_car(other)
	assert_false(_world.is_won())


func test_no_goal_means_not_won() -> void:
	_world.goal = null
	_primary.state.position = Vector2(500, 0)
	assert_false(_world.is_won())
