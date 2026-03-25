extends Node2D

class_name Region

@export var map_tiles : TileMapLayer
@export var cords : Vector2i
@export var initial : bool
@export var resource_nodes : Node2D
@export var region_middle_node : Node2D
@export var buildings_node : Node2D
@export var res_resp_timer : Timer

var max_nodes : int = 0
var spawned_resources : int = 0
var hub : HUB = null
var hub_center : bool = false

func _generate_region() -> void:
	MN._MainM.regions[cords] = self
	_generate_region_tiles()
	max_nodes = MN._MainM._get_resources_per_region()
		
	for i : int in range(max_nodes):
		_generate_resource(0)
	
	var middle_tiles : Array[Node] = region_middle_node.get_children()
	middle_tiles[0].position = MN._MainM._global_tile_position(_get_region_middle() - Vector2i(1, 1)) + Vector2(0, 1)
	middle_tiles[1].position = MN._MainM._global_tile_position(_get_region_middle() - Vector2i(1, 0)) + Vector2(0, 1)
	middle_tiles[2].position = MN._MainM._global_tile_position(_get_region_middle() - Vector2i(0, 1)) + Vector2(0, 1)
	middle_tiles[3].position = MN._MainM._global_tile_position(_get_region_middle() - Vector2i(0, 0)) + Vector2(0, 1)
		

func _generate_region_tiles() -> void:
	var noise : FastNoiseLite = MN._MainM.noise
	var terrain_types : int = MN._MainM.terrain_types
	for y : int in range(MN._MainM.region_size_y):
		for x : int in range(MN._MainM.region_size_x):
			var new_cords : Vector2i = Vector2i(x, y)
			var noise_cords : Vector2i = new_cords + cords * MN._MainM.region_size_x
			map_tiles.set_cells_terrain_connect([new_cords],
				0, floor((noise.get_noise_2d(noise_cords.x, noise_cords.y) + 1.0)/2.0*float(terrain_types)))
			# print(floor((noise.get_noise_2d(new_cords.x, new_cords.y) + 1.0)/2.0*float(terrain_types)))

func _generate_resource(_try: int) -> void:
	var random_x : int = randi_range(0, MN._MainM.region_size_x - 1)
	var random_y : int = randi_range(0, MN._MainM.region_size_y - 1)
		
	for _x : int in range(-1, 2):
		for _y : int in range(-1, 2):
			if MN._MainM._get_tile_occupancy(cords * MN._MainM.region_size_x + Vector2i(random_x+1, random_y) + Vector2i(_x, _y)) != null:
				if _try < 5:
					_generate_resource(_try + 1)
				return
				
	var noise : FastNoiseLite = MN._MainM.noise
	var noise_cords : Vector2 = Vector2(
		cords.x * MN._MainM.region_size_x + random_x,
		cords.y * MN._MainM.region_size_y + random_y)
	
	var terrain_types : int = MN._MainM.terrain_types
	var noise_value : int = floor((noise.get_noise_2d(noise_cords.x, noise_cords.y) + 1.0)/2.0*float(terrain_types))
	var biome : String = RgD.Regions[int(noise_value)]
	var _resource_nodes : Array = RgD.biome_resource_nodes[biome]

	if _resource_nodes.size() > 0:
		var resource_node : ResourceNode = MN._MainM.resource_node_scene.instantiate()
		var res_data : ResourceNodeData = ResD.Nodes[_resource_nodes.pick_random()]
		resource_node.node_data = res_data
		resource_node.position = MN._MainM._global_tile_position(Vector2(random_x, random_y))
		resource_node.region = self
		resource_nodes.add_child(resource_node)
		spawned_resources += 1

func _on_resource_respawn_timer_timeout() -> void:
	if !visible and !hub_center:
		_generate_resource(0)
	if spawned_resources < max_nodes:
		res_resp_timer.start()

func _get_region_middle() -> Vector2i:
	var middle : Vector2i = Vector2i(1, 1) * int(MN._MainM.region_size_x/2.0+1)
	return middle
	
func _get_global_region_middle():
	return _get_region_middle() + cords * Vector2i(MN._MainM.region_size_x, MN._MainM.region_size_y)
		
# Function for regenerating resources
func _resource_gathered() -> void:
	if res_resp_timer.is_stopped():
		res_resp_timer.start()
		
# Toggle on the visibility of region center marks
func _toggle_on_middle() -> void:
	region_middle_node.show()
	
# Toggle of the visibility of region center marks
func _toggle_of_middle() -> void:
	region_middle_node.hide()
	
func get_resource_nodes(resource: ResD.possible_resources) -> Array[ResourceNode]:
	var nodes : Array[ResourceNode]
	for node : ResourceNode in resource_nodes.get_children():
		if node.bots_gathering == 0 and node.node_data.Drop == resource:
			nodes.append(node)
	return nodes
	
# Get tile type
func _get_tile_type(_tile_cords : Vector2i) -> String:
	var local_cords : Vector2i = _tile_cords - Vector2i(cords.x * MN._MainM.region_size_x, cords.y * MN._MainM.region_size_y) 
	var tile_data : TileData = map_tiles.get_cell_tile_data(local_cords)
	if tile_data != null:
		return RgD.Regions[tile_data.terrain]
	return ""

# Function to add building
func _add_building(_tile: Vector2i, _building : Building) -> void:
	buildings_node.add_child(_building)
	_building.global_position = MN._MainM._global_tile_position(_tile)
