class_name OrientedBox
extends RefCounted
## A rotated rectangle on the ground plane. Used for cars and walls.

var center: Vector2 = Vector2.ZERO
var angle: float = 0.0
var half_size: Vector2 = Vector2.ONE


static func make(
	center_value: Vector2, angle_value: float, half_size_value: Vector2
) -> OrientedBox:
	var result := OrientedBox.new()
	result.center = center_value
	result.angle = angle_value
	result.half_size = half_size_value
	return result


func axis_x() -> Vector2:
	return Vector2.from_angle(angle)


func axis_y() -> Vector2:
	return axis_x().orthogonal()


func contains_point(point: Vector2) -> bool:
	var offset := point - center
	return absf(offset.dot(axis_x())) <= half_size.x and absf(offset.dot(axis_y())) <= half_size.y


## Half the width of this box when seen along a unit-length direction.
func radius_on(direction: Vector2) -> float:
	return half_size.x * absf(direction.dot(axis_x())) + half_size.y * absf(direction.dot(axis_y()))
