class_name Collision
extends RefCounted
## Overlap test between two rotated rectangles (Separating Axis Theorem).
##
## Two convex shapes overlap only if no straight line separates them. For
## rectangles it is enough to check the edge directions of both boxes.


## Returns null when the boxes do not overlap. Touching counts as not overlapping.
static func test(a: OrientedBox, b: OrientedBox) -> CollisionContact:
	var axes: Array[Vector2] = [a.axis_x(), a.axis_y(), b.axis_x(), b.axis_y()]
	var offset := b.center - a.center
	var best_depth := INF
	var best_normal := Vector2.ZERO

	for axis in axes:
		var distance := offset.dot(axis)
		var overlap := a.radius_on(axis) + b.radius_on(axis) - absf(distance)
		if overlap <= 0.0:
			return null
		if overlap < best_depth:
			best_depth = overlap
			best_normal = axis if distance >= 0.0 else -axis

	var contact := CollisionContact.new()
	contact.normal = best_normal
	contact.depth = best_depth
	contact.point = _contact_point(a, b, best_normal)
	return contact


## Where the boxes touch: the average of every corner that sits inside the other box.
## Rare plus-shaped overlaps have no such corner, so they use the middle of the overlap.
static func _contact_point(a: OrientedBox, b: OrientedBox, normal: Vector2) -> Vector2:
	var sum := Vector2.ZERO
	var count := 0
	for corner in a.corners():
		if b.contains_point(corner):
			sum += corner
			count += 1
	for corner in b.corners():
		if a.contains_point(corner):
			sum += corner
			count += 1
	if count > 0:
		return sum / float(count)

	var along_a := a.center.dot(normal) + a.radius_on(normal)
	var along_b := b.center.dot(normal) - b.radius_on(normal)
	var middle := (a.center + b.center) / 2.0
	return middle + normal * ((along_a + along_b) / 2.0 - middle.dot(normal))
