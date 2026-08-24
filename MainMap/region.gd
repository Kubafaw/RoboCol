extends Node3D

class_name Region

@export var gridmap : GridMap
@export var coords : Vector2i
@export var initial : bool
@export var resource_nodes : Node3D
@export var region_middle_node : Node3D
@export var buildings_node : Node3D
@export var res_resp_timer : Timer
@export var distance_from_player_for_resource_respawn : int

var max_nodes : int = 0
var spawned_resources : int = 0
var hub : HUB = null
var hub_center : bool = false

# Generating new region
func _generate_region() -> void:
	MainMap.current_Map.regions[coords] = self
	_generate_region_tiles()
	max_nodes = MainMap.current_Map._get_resources_per_region()
		
	for i : int in range(max_nodes):
		_generate_resource(0)
	
	# Set middle point
	region_middle_node.global_position = Vector3(MainMap.current_Map.region_size_x + 3, 0.2, MainMap.current_Map.region_size_z + 1)
		

# Generating tiles of the region
func _generate_region_tiles() -> void:
	var noise : FastNoiseLite = MainMap.current_Map.noise
	var terrain_types : int = MainMap.current_Map.terrain_types
	for z : int in range(MainMap.current_Map.region_size_z):
		for x : int in range(MainMap.current_Map.region_size_x):
			var new_coords : Vector3i = Vector3i(x, 0, z)
			var noise_coords : Vector2i = Vector2i(new_coords.x, new_coords.z) + coords * MainMap.current_Map.region_size_x
			gridmap.set_cell_item(new_coords, 
				floor((noise.get_noise_2d(noise_coords.x, noise_coords.y) + 1.0)/2.0*float(terrain_types)*2.0),
			 	MainMap.current_Map.tile_orientations.pick_random())


# Ganerating a new resource in the region
func _generate_resource(_try: int) -> void:
	if _try >= 5:
		return
	
	# Getting random position
	var random_x : int = randi_range(0, MainMap.current_Map.region_size_x)
	var random_z : int = randi_range(0, MainMap.current_Map.region_size_z)
	
	# Getting noise coords for getting terrain type
	var noise : FastNoiseLite = MainMap.current_Map.noise
	var noise_cords : Vector2i = Vector2i(
		coords.x * MainMap.current_Map.region_size_x + random_x,
		coords.y * MainMap.current_Map.region_size_z + random_z)
		
	# Checking if far enaugh from the player
	var player_position : Vector3i = Player.current_player._get_tile_position()
	if (abs(noise_cords.x - player_position.x) < distance_from_player_for_resource_respawn
	 or abs(noise_cords.y - player_position.z) < distance_from_player_for_resource_respawn):
		_generate_resource(_try + 1)
		return
	
	# Getting terrain type and possible resources for set biome
	var terrain_types : int = MainMap.current_Map.terrain_types
	var noise_value : int = floor((noise.get_noise_2d(noise_cords.x, noise_cords.y) + 1.0)/2.0*float(terrain_types))
	noise_value += 1
	var biome : String = RgD.Regions[int(noise_value)]
	var _resource_nodes : Array = RgD.biome_resource_nodes[biome]

	# Spawning resource if any aviable and position is valid
	if _resource_nodes.size() > 0:
		var res_data : ResourceNodeData = ResD.Nodes[_resource_nodes.pick_random()]
		
		for pos in PosFuncs._get_surrounding_tiles(res_data.size*3):
			if MainMap.current_Map._get_tile_occupancy(noise_cords + pos) != null:
				_generate_resource(_try + 1)
				return
				
		var resource_node : ResourceNode = MainMap.current_Map.resource_node_scene.instantiate()
		resource_node.node_data = res_data
		resource_node.position = MainMap.current_Map._global_tile_position(Vector3(random_x, 0, random_z))
		resource_node.tile_position = noise_cords
		resource_node.region = self
		resource_nodes.add_child(resource_node)
		spawned_resources += 1


# Spawning new resource with resources spawner timer and 
# 	only if not a hub center region
func _on_resource_respawn_timer_timeout() -> void:
	if !hub_center:
		_generate_resource(0)
	if spawned_resources < max_nodes:
		res_resp_timer.start()


# Getting region middle coordinates
func _get_region_middle() -> Vector2i:
	var middle : Vector2i = Vector2i(1, 1) * int(MainMap.current_Map.region_size_x/2.0+1)
	return middle
	
	
# Getting region middle global position
func _get_global_region_middle():
	return _get_region_middle() + coords * Vector2i(MainMap.current_Map.region_size_x, MainMap.current_Map.region_size_z)
		
		
# Function for regenerating resources after gathering one
func _resource_gathered() -> void:
	if res_resp_timer.is_stopped():
		res_resp_timer.start()
		
		
# Toggle on the visibility of region center marks
func _toggle_on_middle() -> void:
	region_middle_node.show()
	
	
# Toggle of the visibility of region center marks
func _toggle_of_middle() -> void:
	region_middle_node.hide()
	
	
# Getting all resource nodes in the region
func _get_resource_nodes(resource: ResD.possible_resources) -> Array[ResourceNode]:
	var nodes : Array[ResourceNode]
	for node : ResourceNode in resource_nodes.get_children():
		if node.bots_gathering == 0 and node.node_data.Drop == resource:
			nodes.append(node)
	return nodes


# Getting tile type
func _get_tile_type(_coords : Vector2i) -> String:
	var noise : FastNoiseLite = MainMap.current_Map.noise
	var noise_cords : Vector2i = Vector2i(
		_coords.x * MainMap.current_Map.region_size_x,
		_coords.y * MainMap.current_Map.region_size_z)
	return RgD.possible_regions.find_key(int(floor((noise.get_noise_2d(noise_cords.x, noise_cords.y) + 1.0)/2.0)))
	

# Function to add building
func _add_building(_tile: Vector2i, _building : Building) -> void:
	buildings_node.add_child(_building)
	if hub != null:
		hub.buildings.append(_building)
	_building.global_position = MainMap.current_Map._global_tile_position(Vector3(_tile.x, -0.1, _tile.y))
