class_name CollisionContact
extends RefCounted
## Result of an overlap test. The normal points from the first box to the second.
## Moving the first box by -normal * depth separates the two.

var normal: Vector2 = Vector2.ZERO
var depth: float = 0.0
var point: Vector2 = Vector2.ZERO
