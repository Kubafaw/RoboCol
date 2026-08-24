@abstract
extends MapObject

class_name Building

@abstract func _interaction() -> void
@abstract func _end_interaction() -> void

var building_stats : BuildingStats

func _ready() -> void:
	# Set graphic and position it in the middle of occupied tiles
	var graphic : Node3D = building_stats.graphic.instantiate()
	graphic.position = Vector3(-building_stats.size.x, 0.0, -building_stats.size.y)/1.5
	add_child(graphic)


func _get_size() -> Vector2i:
	return building_stats.size


func _start() -> void:
	pass
