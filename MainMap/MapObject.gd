@abstract
extends Node3D

class_name MapObject

@export var model : MeshInstance3D

var tile_position : Vector2i

@abstract func _get_size() -> Vector2i

		
