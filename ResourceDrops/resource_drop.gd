extends Node2D

class_name ResourceDrop

@export var resource : String = ""

func _on_gather_area_area_entered(area: Area2D) -> void:
	if area.get_parent()._add_resource(resource):
		Gamedata._HUD._reload_inventory()
		queue_free()
