extends Node

class_name IsometricNavigation

var target : Vector2 = Vector2(INF, INF) # in tile map cords
var x_movement_prior : bool = true 

@export var path_max_lenght : int = 5 # in tiles
@export var move_component : MoveComponent

func _get_next_point(_current_pos : Vector2) -> Vector2: # global position
	if target == Vector2(INF, INF):
		return _current_pos
	
	if target == _current_pos:
		move_component._same_position()
		return 	MN._MainM._global_tile_position(_current_pos)

	var next_nav_point : Vector2 = Vector2()
	var pos_diff : Vector2 = abs(target - _current_pos)
	var x_vector : Vector2 = Vector2(target.x - _current_pos.x, 0).normalized()
	var y_vector : Vector2 = Vector2(0, target.y - _current_pos.y).normalized()
	
	if x_movement_prior:
		if pos_diff.x <= 0:
			x_movement_prior = false
	else:
		if pos_diff.y <= 0:
			x_movement_prior = true
	
	if x_movement_prior:
		for x in range(1, path_max_lenght+1):
			var tile_occupancy : Node2D = MN._MainM._get_tile_occupancy(_current_pos + x_vector * x)
			if !tile_occupancy == null:
				if next_nav_point == Vector2(0, 0):
					var y_diff = abs(_current_pos.y - tile_occupancy.tile_position.y)
					var y_diff2 = abs(_current_pos.y - (tile_occupancy.tile_position.y - tile_occupancy.size.y + 1))
					if abs(target.y - (_current_pos.y + y_diff + 1)) < abs(target.y - (_current_pos.y - y_diff2 - 1)):
						next_nav_point = Vector2(0, y_diff + 1)
					else:
						next_nav_point = Vector2(0, -y_diff2 - 1)
					x_movement_prior = true
					return MN._MainM._global_tile_position(next_nav_point + _current_pos)
				break
			next_nav_point += x_vector
			if next_nav_point.x + _current_pos.x == target.x:
				break	
	else:
		for y in range(1, path_max_lenght+1):
			var tile_occupancy : Node2D = MN._MainM._get_tile_occupancy(_current_pos + y_vector * y)
			if !tile_occupancy == null:
				if next_nav_point == Vector2(0, 0):
					var x_diff = abs(_current_pos.x - tile_occupancy.tile_position.x)
					var x_diff2 = abs(_current_pos.x - (tile_occupancy.tile_position.x - tile_occupancy.size.x + 1))
					if abs(target.x - (_current_pos.x + x_diff + 1)) < abs(target.x - (_current_pos.x - x_diff2 - 1)):
						next_nav_point = Vector2(x_diff + 1, 0)
					else:
						next_nav_point = Vector2(-x_diff2 - 1, 0)
					x_movement_prior = false
					return MN._MainM._global_tile_position(next_nav_point + _current_pos)
				break
			next_nav_point += y_vector
			if next_nav_point.y + _current_pos.y == target.y:
				break
				
	return MN._MainM._global_tile_position(next_nav_point + _current_pos) 

func _set_target(_target : Vector2) -> void:
	target = _target
	
func _get_target() -> Vector2:
	return MN._MainM._global_tile_position(target)
	
