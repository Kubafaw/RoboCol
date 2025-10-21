extends Node2D

class_name MapGenerator

@export var biomes : Array[String]
@export var neigbouring_impact : int

var regions : Dictionary[Vector2, String]

func _ready() -> void:
	Gamedata._Map_generator = self

func _generate_region(region_x, region_y) -> String:
	var region : Array[int]
	var biome = _get_biome(region_x, region_y)
	regions[Vector2(region_x, region_y)] = biome
	return biome
	
func _get_biome(region_x, region_y) -> String:
	var _possible_biomes = biomes.duplicate()
	for x in [-1, 1]:
		if regions.has(Vector2(region_x + x, region_y)):
			for t in neigbouring_impact:
				_possible_biomes.append(regions[Vector2(region_x + x, region_y)])
				
	for y in [-1, 1]:
		if regions.has(Vector2(region_x, region_y + y)):
			for t in neigbouring_impact:
				_possible_biomes.append(regions[Vector2(region_x, region_y + y)])
	
	_possible_biomes.shuffle()
	return _possible_biomes[0]
