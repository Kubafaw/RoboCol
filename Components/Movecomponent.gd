extends Node

class_name MoveComponent

@export var Actor: Node3D
@export var Navigation_Component: SimpleNavigation
@export var Speed : float

var actual_position : Vector3
var next_position : Vector3
var moved : bool = false
var move_direction : Vector3

signal target_reached
	
# Function for getting new navigation point
func _get_new_point() -> void:
	var tile_map_position : Vector3i = MainMap.current_Map._get_current_tile_position(Actor.global_position + Vector3(0,0,0))
	if Actor.global_position != MainMap.current_Map._global_tile_position(tile_map_position):
		next_position = MainMap.current_Map._global_tile_position(tile_map_position)
	else:
		next_position = Navigation_Component._get_next_point(tile_map_position)
		
	Actor._change_graphic()


# Processing movement
func _physics_process(delta: float) -> void:
	moved = false
	var direction : Vector3 = Actor.global_position.direction_to(next_position)
	var distance : float = Actor.global_position.distance_to(next_position)
	if distance > 0.0:
		moved = true
	
	var move_range = direction * Speed * delta
	actual_position += move_range
	
	if move_range.length() > distance:
		actual_position = next_position
		
	Actor.global_position = actual_position
	
	if moved and not Navigation_Component._get_target().is_finite():
		emit_signal("target_reached")
	elif moved and Actor.global_position == next_position:
		_get_new_point()
	
	if !moved:
		move_direction = Vector3i(0, 0, 0)


# Emiting signal if navigated to current point
func _same_position() -> void:
	emit_signal("target_reached")
