extends Node2D

class_name Building

@export var _name : String
@export var size_x : int
@export var size_y : int

var tile_position : Vector2

var transparent_areas_overlapping : Array[Area2D] = []

func _ready() -> void:
	tile_position = Gamedata._Main_Map._get_tile_position(global_position)
	for _y in range(size_y):
		for _x in range(size_x):
			Gamedata._Main_Map._add_collision_on_tile_map(tile_position - Vector2(_x, _y))

func _on_make_transparent_area_area_entered(area: Area2D) -> void:
	transparent_areas_overlapping.append(area)
	$AnimatedSprite2D.self_modulate = Color(1.0, 1.0, 1.0, 0.4)

func _on_make_transparent_area_area_exited(area: Area2D) -> void:
	transparent_areas_overlapping.erase(area)
	if transparent_areas_overlapping.size() < 1:
		$AnimatedSprite2D.self_modulate = Color(1.0, 1.0, 1.0, 1.0)

func _interaction(player : Player) -> void:
	pass
