extends Node

class_name MoveComponent

@export var Actor: Node2D
@export var Navigation_Component: IsometricNavigation
@export var Speed : float

var actual_position : Vector2
var next_position : Vector2
var moved : bool = false

signal target_reached

func _ready() -> void:
	actual_position = Actor.global_position
	
func _get_new_point() -> void:
	var tile_map_position = Gamedata._Main_Map._get_tile_position(Actor.global_position)
	if Actor.global_position != Gamedata._Main_Map._global_tile_position(tile_map_position):
		next_position = Gamedata._Main_Map._global_tile_position(tile_map_position)
	else:
		next_position = Navigation_Component._get_next_point(tile_map_position)

func _physics_process(delta: float) -> void:
	moved = false
	var direction : Vector2 = Actor.global_position.direction_to(next_position)
	var distance : float = Actor.global_position.distance_to(next_position)
	
	if distance > 0.0:
		moved = true
	
	var move_range = direction * Speed * delta
	actual_position += move_range
	
	if move_range.length() > distance:
		actual_position = next_position
		
	Actor.global_position = actual_position.round()
	
	if moved and Navigation_Component._get_target() == Actor.global_position:
		emit_signal("target_reached")
	elif moved and Actor.global_position == next_position:
		_get_new_point()
		
	Actor._change_animation(move_range)

func _same_position() -> void:
	emit_signal("target_reached")
