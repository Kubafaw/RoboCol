extends Node

# get tiles next to the object
func _get_neighbouring_tiles(_obj_size : Vector2i) -> Array[Vector2i]:
	var neighbouring_tiles : Array[Vector2i] = []
	for _x in range(_obj_size.x):
		neighbouring_tiles.append(Vector2i(-_x, 1)) 
		neighbouring_tiles.append(Vector2i(-_x, -_obj_size.y))
	for _y in range(_obj_size.y):
		neighbouring_tiles.append(Vector2i(1, -_y)) 
		neighbouring_tiles.append(Vector2i(-_obj_size.x, -_y))
	return neighbouring_tiles


# get tiles occupied by the object
func _get_occupied_tiles(_obj_size : Vector2i) -> Array[Vector2i]:
	var occupied_tiles : Array[Vector2i] = []
	for _x in range(_obj_size.x):
		for _y in range(_obj_size.y):
			occupied_tiles.append(Vector2i(-_x, -_y))
	return occupied_tiles
	
	
# get the whole tile occupied by the object with all surrounding tiles
func _get_surrounding_tiles(_obj_size : Vector2i) -> Array[Vector2i]:
	var surrounding_tiles : Array[Vector2i] = []
	for _x in range(-1, _obj_size.x + 1):
		for _y in range(-1, _obj_size.y + 1):
			surrounding_tiles.append(Vector2i(-_x, -_y))
	return surrounding_tiles
	
	
# Get closest neighbouring tile for interacting with map object
func _get_closest_tile(object_position: Vector3i, positions: Array[Vector2i]) -> Vector2i:
	var xy_object_position = Vector2i(object_position.x, object_position.z)
	var current_min : float = positions[0].distance_to(xy_object_position)
	var current_closest_position : Vector2i = positions[0]
	for _position : Vector2i in positions:
		if current_min > _position.distance_to(xy_object_position):
			current_min = _position.distance_to(xy_object_position)
			current_closest_position = _position
	return current_closest_position
