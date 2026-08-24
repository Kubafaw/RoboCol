extends Node

class_name SimpleNavigation

var target : Vector3 = Vector3(INF, INF, INF) # in tile map cords
var x_movement_prior : bool = true 

@export var path_max_lenght : int = 5 # in tiles
@export var move_component : MoveComponent

# Getting next path point for navigation
func _get_next_point(_current_pos : Vector3) -> Vector3: # global position
	# Not processing if no point set
	if not target.is_finite():
		return _current_pos
	
	# Checking if already on new target
	if target == _current_pos:
		move_component._same_position()
		return MainMap.current_Map._global_tile_position(_current_pos)

 	# Getting x and z difference between current position and target
	var next_nav_point : Vector3 = Vector3()
	var pos_diff : Vector3 = abs(target - _current_pos)
	var x_vector : Vector3 = Vector3(target.x - _current_pos.x, 0, 0).normalized()
	var z_vector : Vector3 = Vector3(0, 0, target.z - _current_pos.z).normalized()
	
	# Swithching movement priority if already on proper x or z
	if x_movement_prior:
		if pos_diff.x <= 0:
			x_movement_prior = false
	else:
		if pos_diff.z <= 0:
			x_movement_prior = true
	
	# Processing if x_movement priority
	if x_movement_prior:
		for x in range(1, path_max_lenght+1):
			var current_tile_position = _current_pos + x_vector * x
			var tile_occupancy : Node3D = MainMap.current_Map._get_tile_occupancy(Vector2i(current_tile_position.x, current_tile_position.z))
			if !tile_occupancy == null:
				if next_nav_point == Vector3(0, 0, 0):
					var z_diff : float = abs(_current_pos.z - tile_occupancy.tile_position.y)
					var z_diff2 : float = abs(_current_pos.z - (tile_occupancy.tile_position.y - tile_occupancy._get_size().y + 1))
					if abs(target.z - (_current_pos.z + z_diff + 1)) < abs(target.z - (_current_pos.z - z_diff2 - 1)):
						next_nav_point = Vector3(0, 0, z_diff + 1)
					else:
						next_nav_point = Vector3(0, 0, -z_diff2 - 1)
					x_movement_prior = true
					move_component.move_direction = next_nav_point
					return MainMap.current_Map._global_tile_position(next_nav_point + _current_pos)
				break
			next_nav_point += x_vector
			if next_nav_point.x + _current_pos.x == target.x:
				break	
	# Processing if z_movement priority
	else:
		for z in range(1, path_max_lenght+1):
			var current_tile_position = _current_pos + z_vector * z
			var tile_occupancy : Node3D = MainMap.current_Map._get_tile_occupancy(Vector2i(current_tile_position.x, current_tile_position.z))
			if !tile_occupancy == null:
				if next_nav_point == Vector3(0, 0, 0):
					var x_diff : float = abs(_current_pos.x - tile_occupancy.tile_position.x)
					var x_diff2 : float = abs(_current_pos.x - (tile_occupancy.tile_position.x - tile_occupancy._get_size().x + 1))
					if abs(target.x - (_current_pos.x + x_diff + 1)) < abs(target.x - (_current_pos.x - x_diff2 - 1)):
						next_nav_point = Vector3(x_diff + 1, 0, 0)
					else:
						next_nav_point = Vector3(-x_diff2 - 1, 0, 0)
					x_movement_prior = false
					move_component.move_direction = next_nav_point
					return MainMap.current_Map._global_tile_position(next_nav_point + _current_pos)
				break
			next_nav_point += z_vector
			if next_nav_point.y + _current_pos.y == target.y:
				break
				
	# Returnig new path point for navigation
	move_component.move_direction = next_nav_point
	return MainMap.current_Map._global_tile_position(next_nav_point + _current_pos) 


# Setting new navigation target
func _set_target(_target : Vector3) -> void:
	target = _target
	
	
# Getting current navigation target
func _get_target() -> Vector3:
	return MainMap.current_Map._global_tile_position(target)
	
