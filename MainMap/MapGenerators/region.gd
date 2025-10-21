extends Node2D

class_name Region

var cords : Vector2i
var genereted : bool = false
var biome : String
var max_nodes : int = 0

var spawned_resources : Dictionary[PackedScene, int]

func _on_region_center_area_entered(area: Area2D) -> void:
	if genereted:
		return
	genereted = true
	biome = Gamedata._Map_generator._generate_region(cords.x, cords.y)
	Gamedata._Main_Map._create_region(biome, cords)
	Gamedata._Main_Map._add_regions(cords)
	max_nodes = Gamedata._Main_Map._get_resources_per_region()
	
	for node in Biomes.biome_resource_nodes[biome]:
		spawned_resources[node] = 0
	
	for i in range(max_nodes):
		_generate_resource()
	
func _generate_resource() -> void:
	if spawned_resources.is_empty():
		return
	var least_amount_nodes : int = 10000;
	var least_amount_scene : PackedScene
	for key in spawned_resources:
		if spawned_resources[key] < least_amount_nodes:
			least_amount_nodes = spawned_resources[key]
			least_amount_scene = key
	
	var res_node = least_amount_scene.instantiate()
	var random_x = randi_range(0, Gamedata._Main_Map.region_size_x - 1)
	var random_y = randi_range(0, Gamedata._Main_Map.region_size_y - 1)
	
	var pos_vector : Vector2 = Vector2(
		cords.x*Gamedata._Main_Map.region_size_x + random_x,
		cords.y * Gamedata._Main_Map.region_size_y + random_y)
		
	for _x in range(-res_node.size_x, 2):
		for _y in range(-res_node.size_y, 2):
			if Gamedata._Main_Map._get_tile_occupancy(pos_vector + Vector2(_x, _y)) != null:
				_generate_resource()
				return
	
	Gamedata._Main_Map._add_resource_node(pos_vector, res_node)
	
		
	
