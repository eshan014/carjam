extends GutTest


func _box(x: float, y: float, angle: float, half_x: float, half_y: float) -> OrientedBox:
	return OrientedBox.make(Vector2(x, y), angle, Vector2(half_x, half_y))


func test_far_apart_boxes_do_not_collide() -> void:
	assert_null(Collision.test(_box(0, 0, 0, 50, 20), _box(500, 0, 0, 50, 20)))


func test_touching_boxes_do_not_collide() -> void:
	assert_null(Collision.test(_box(0, 0, 0, 50, 20), _box(100, 0, 0, 50, 20)))


func test_overlap_reports_smallest_depth_and_direction() -> void:
	var contact := Collision.test(_box(0, 0, 0, 50, 20), _box(90, 0, 0, 50, 20))
	assert_not_null(contact)
	assert_almost_eq(contact.depth, 10.0, 0.001)
	assert_almost_eq(contact.normal.x, 1.0, 0.001)
	assert_almost_eq(contact.normal.y, 0.0, 0.001)


func test_swapping_boxes_flips_normal_only() -> void:
	var first := _box(0, 0, 0, 50, 20)
	var second := _box(90, 0, 0, 50, 20)
	var forward := Collision.test(first, second)
	var backward := Collision.test(second, first)
	assert_almost_eq(forward.depth, backward.depth, 0.001)
	assert_almost_eq(forward.normal.x, -backward.normal.x, 0.001)


func test_rotated_box_overlap_depth() -> void:
	var contact := Collision.test(_box(0, 0, 0, 10, 10), _box(20, 0, PI / 4.0, 10, 10))
	assert_not_null(contact)
	assert_almost_eq(contact.depth, 10.0 * sqrt(2.0) + 10.0 - 20.0, 0.001)


func test_rotated_thin_bars_can_miss_each_other() -> void:
	# The bars' bounding squares overlap, but the bars themselves do not.
	assert_null(Collision.test(_box(0, 0, 0, 50, 2), _box(40, 40, PI / 4.0, 50, 2)))
