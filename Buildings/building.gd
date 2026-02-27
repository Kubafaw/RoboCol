@abstract
extends MapObject

class_name Building

@abstract func _interaction() -> void
@abstract func _end_interaction() -> void

var building_stats : BuildingStats

func _get_size() -> Vector2i:
	return building_stats.size
