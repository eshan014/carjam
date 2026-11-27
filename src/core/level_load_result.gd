class_name LevelLoadResult
extends RefCounted
## Either a ready world, or a message saying what is wrong with the level file.

var world: SimWorld = null
var error: String = ""


static func ok(value: SimWorld) -> LevelLoadResult:
	var result := LevelLoadResult.new()
	result.world = value
	return result


static func fail(message: String) -> LevelLoadResult:
	var result := LevelLoadResult.new()
	result.error = message
	return result
