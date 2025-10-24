extends Node2D

class_name MainMap

@export var map_size_x : int
@export var map_size_y : int
@export var region_size_x : int
@export var region_size_y : int
@export var region_scene : PackedScene

@onready var map_tiles : TileMapLayer = %MapTiles
@onready var tile_set : TileSet = map_tiles.tile_set

var tiles_occupancy : Dictionary[Vector2, Node2D] = {}
var regions : Dictionary[Vector2i, Region]
var regions_generated : Dictionary[Vector2i, bool]

func _ready():
	# set to GAMEDATA
	Gamedata._Main_Map = self

			
func _get_tile_position(_position: Vector2) -> Vector2:
	return map_tiles.local_to_map(to_local(_position))

func _get_tile_global_position(_position: Vector2) -> Vector2:
	var tile_cords : Vector2 =  _get_tile_position(_position)
	return _global_tile_position(tile_cords)
	
func _global_tile_position(_tile: Vector2) -> Vector2:
	return Vector2(
		8 + _tile.x * 8 - _tile.y * 8,
		_tile.y * 4 + _tile.x * 4
	)

func _add_resource_node(_tile: Vector2, _resource_node: ResourceNode) -> void:
	for _position in Positionfunctions._get_occupied_tiles(_resource_node):
		tiles_occupancy[_tile + _position] = _resource_node
	_resource_node.global_position = _global_tile_position(_tile)
	$ResourceNodes.call_deferred("add_child", _resource_node)
	
func _add_building(_tile: Vector2, _building : Building) -> void:
	for _position in Positionfunctions._get_occupied_tiles(_building):
		tiles_occupancy[_tile + _position] = _building
	_building.global_position = _global_tile_position(_tile)
	$Buildings.call_deferred("add_child", _building)
	
func _clear_tile_occupancy(point: Vector2) -> void:
	tiles_occupancy.erase(point)
	
func _get_tile_occupancy(point: Vector2) -> Node2D:
	if tiles_occupancy.has(point):
		return tiles_occupancy[point]
	return null
	
func _add_resource(_resource: Node2D) -> void:
	$Resources.add_child(_resource)
	
func _add_collision_on_tile(_position: Vector2) -> void:
	var _tile_position : Vector2 = _get_tile_position(_position)
	var _tile_set_cords = map_tiles.get_cell_atlas_coords(_tile_position)
	map_tiles.set_cell(_tile_position, 2, _tile_set_cords, 1)
	
func _remove_collision_on_tile(_position: Vector2) -> void:
	var _tile_position : Vector2 = _get_tile_position(_position)
	var _tile_set_cords = map_tiles.get_cell_atlas_coords(_tile_position)
	map_tiles.set_cell(_tile_position, 2, _tile_set_cords, 0)
	
func _add_collision_on_tile_map(_tile: Vector2) -> void:
	var _tile_set_cords = map_tiles.get_cell_atlas_coords(_tile)
	map_tiles.set_cell(_tile, 2, _tile_set_cords, 1)
	
func _remove_collision_on_tile_map(_tile: Vector2) -> void:
	var _tile_set_cords = map_tiles.get_cell_atlas_coords(_tile)
	map_tiles.set_cell(_tile, 2, _tile_set_cords, 0)

func _create_region(biome: String, cords: Vector2i) -> void:
	for y in range(region_size_y):
		for x in range(region_size_x):
			map_tiles.set_cells_terrain_connect([
				cords * region_size_x + Vector2i(x, y)], 0, Biomes.biome_tile[biome])
				
func _add_regions(cords: Vector2i) -> void:
	var region_middle : Vector2i = Vector2i(region_size_x, region_size_x) / 2
	for x in [-1, 1]:
		if !regions.has(cords + Vector2i(x, 0)):
			var region : Region = region_scene.instantiate()
			region.cords = cords + Vector2i(x, 0)
			region.global_position = _global_tile_position(region.cords * region_size_x + region_middle)
			regions[cords + Vector2i(x, 0)] = region
			$Regions.call_deferred("add_child", region)
			
	for y in [-1, 1]:
		if !regions.has(cords + Vector2i(0, y)):
			var region : Region = region_scene.instantiate()
			region.cords = cords + Vector2i(0, y)
			region.global_position = _global_tile_position(region.cords * region_size_x + region_middle)
			regions[cords + Vector2i(0, y)] = region
			$Regions.call_deferred("add_child", region)
			
func _get_resources_per_region() -> int:
	return int(region_size_x * region_size_y / 12.0)
