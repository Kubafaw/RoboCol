extends Node3D

class_name MainMap

static var current_Map

@export var region_size_x : int
@export var region_size_z : int
@export var region_scene : PackedScene
@export var regions_node : Node3D
@export var gridmap : GridMap
@export var player : Player
@export var resource_node_scene : PackedScene
@export var terrain_types : int = 2
@export var tile_variations : int = 2
@export var tiles_per_resource_node : int = 12

@onready var x_offset : float = gridmap.cell_size.x / 2.0
@onready var z_offset : float = gridmap.cell_size.z / 2.0

var noise : FastNoiseLite
var tiles_occupancy : Dictionary[Vector2i, Node3D] = {}
var tile_orientations : Array[int] = [0, 10, 16, 22]
var regions : Dictionary[Vector2i, Region] = {}
var last_region : Vector2i = Vector2i(-100, -100)
var grid_map_cell_size : Vector3
var resource_nodes_per_region : int = 1

func _ready() -> void:
	current_Map = self
	grid_map_cell_size = gridmap.cell_size
	
	# Setting up the noise for map generation
	randomize()
	noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.frequency = 0.02
	
	# Setting resource nodes per region
	resource_nodes_per_region = region_size_x * int(region_size_z / float(tiles_per_resource_node))
			
				
func _get_current_tile_position(_position: Vector3) -> Vector3i:
	return gridmap.local_to_map(to_local(_position))
	
	
func _global_tile_position(_tile: Vector3) -> Vector3:
	return Vector3(
		x_offset + _tile.x * gridmap.cell_size.x,
		0,
		z_offset + _tile.z * gridmap.cell_size.z
	)
	
	
# Clearing tile occupancy of map object
func _clear_tile_occupancy(point: Vector2i) -> void:
	tiles_occupancy.erase(point)
	
	
# Getting current occupancy map object of a tile
func _get_tile_occupancy(point: Vector2i) -> MapObject:
	if tiles_occupancy.has(point):
		return tiles_occupancy[point]
	return null
	
	
# Adding building if it's possible to proper region
func _add_building(_tile: Vector2i, _building : Building) -> void:
	# Checking if position is valid
	if !GameNode.Game._check_if_can_build(_tile):
		return
		
	for _position : Vector2i in PosFuncs._get_occupied_tiles(_building.building_stats.size):
		tiles_occupancy[_tile + _position] = _building
	var current_region : Vector2i = _get_current_region(Vector3(_tile.x, 0, _tile.y))
	regions[current_region]._add_building(_tile, _building)
	_building.global_position = _global_tile_position(Vector3(_tile.x, 0, _tile.y))
	_building.tile_position = _tile
	
	# Logic for HUB
	if _building is HUB:
		regions[current_region].hub_center = true
		for region_pos : Vector2i in PosFuncs._get_surrounding_tiles(Vector2i(1, 1)):
			var region_cords : Vector2i = current_region + region_pos
			if !regions.has(region_cords):
				_generate_region(region_cords)
				regions[region_cords].hide()
			regions[region_cords].hub = _building
			_building.regions.append(regions[region_cords])
			
	# Logic for other buildings
	if _building is not HUB:
		_building.hub = regions[current_region].hub
		
	_building._start()
	GameNode.Game.available_tokens[ResD.token_ids[_building.building_stats.category]] -= 1
	HUD.active_HUD._update_build_list()
	
	
# Generating new regions on set coordinats
func _generate_region(coords: Vector2i) -> void:
	var region : Region = region_scene.instantiate()
	region.coords = coords
	regions_node.add_child(region)
	region.global_position = _global_tile_position(Vector3(
		coords.x * region_size_x,
		0,
		coords.y * region_size_z
	))
	region._generate_region()
	
	
# Getting resource nodes per region
func _get_resources_per_region() -> int:
	return resource_nodes_per_region


# Getting currently occupied region
func _get_current_region(tile_position : Vector3i) -> Vector2i:
	if tile_position.x - 1 < 0:
		tile_position.x -= region_size_x - 1
	if tile_position.z < 0:
		tile_position.z -= region_size_z - 1
		
	return Vector2i(int((tile_position.x - 1) / float(region_size_x)), int(tile_position.z / float(region_size_z)))


# Updating wich regions are visible and generating new if needed
func _update_regions(tile: Vector3i) -> void:
	var reg_cords : Vector2i = _get_current_region(tile)
	# Checking if in new region
	if reg_cords != last_region:
		# Hiding currently visible regions
		for _y : int in range(-1, 2):
			for _x : int in range(-1, 2):
				var _reg_cords : Vector2i = Vector2i(last_region.x + _x, last_region.y + _y)
				if regions.has(_reg_cords):
					regions[_reg_cords].hide()
					
		# Setting current region occupation
		last_region = reg_cords
		
		# Showing regions and creating new if needed
		for _y : int in range(-1, 2):
			for _x : int in range(-1, 2):
				var _reg_cords : Vector2i = Vector2i(reg_cords.x + _x, reg_cords.y + _y)
				if regions.has(_reg_cords):
					regions[_reg_cords].show()
				else:
					_generate_region(_reg_cords)
					
					
# Checking if position is available for new object
func _check_if_pos_valid(_tile : Vector2i, _building_size : Vector2i) -> bool:
	for _position : Vector2i in PosFuncs._get_surrounding_tiles(_building_size):
		if tiles_occupancy.has(_tile + _position) and tiles_occupancy[_tile + _position] != null:
			return false
	return true


# Showing middle of each region 
func _show_region_middle():
	for region : Vector2i in regions:
		regions[region]._toggle_on_middle()
		

# Hiding middle of each region 	
func _hide_region_middle():
	for region : Vector2i in regions:
		regions[region]._toggle_of_middle()
