extends Node

func _get_neighbouring_tiles(_object : Node2D) -> Array[Vector2]:
	var neighbouring_tiles : Array[Vector2] = []
	for _x in range(_object.size_x):
		neighbouring_tiles.append(Vector2(-_x, 1)) 
		neighbouring_tiles.append(Vector2(-_x, -_object.size_y))
	for _y in range(_object.size_y):
		neighbouring_tiles.append(Vector2(1, -_y)) 
		neighbouring_tiles.append(Vector2(-_object.size_x, -_y))
	return neighbouring_tiles

func _get_occupied_tiles(_object : Node2D) -> Array[Vector2]:
	var _occupied_tiles : Array[Vector2] = []
	for _x in range(_object.size_x):
		for _y in range(_object.size_y):
			_occupied_tiles.append(Vector2(-_x, -_y))
	return _occupied_tiles
