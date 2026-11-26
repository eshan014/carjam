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
	return contact
