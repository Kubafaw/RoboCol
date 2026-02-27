@abstract
extends Node2D

class_name MapObject

@export var sprite : Sprite2D
@export var make_transparent_area : Area2D

var transparent_areas_overlapping : Array[Area2D] = []
var tile_position : Vector2i

@abstract func _get_size() -> Vector2i

func _ready() -> void:
	make_transparent_area.area_entered.connect(_on_make_transparent_area_area_entered)
	make_transparent_area.area_exited.connect(_on_make_transparent_area_area_exited)

func _on_make_transparent_area_area_entered(area: Area2D) -> void:
	transparent_areas_overlapping.append(area)
	sprite.self_modulate = Color(1.0, 1.0, 1.0, 0.4)

func _on_make_transparent_area_area_exited(area: Area2D) -> void:
	transparent_areas_overlapping.erase(area)
	if transparent_areas_overlapping.size() < 1:
		sprite.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
