extends Node2D

class_name MainMap

@export var region_size_x : int
@export var region_size_y : int
@export var region_scene : PackedScene
@export var resource_node_scene : PackedScene

@onready var map_tiles : TileMapLayer = %MapTiles
@onready var tile_set : TileSet = map_tiles.tile_set
@onready var x_offset : int = int(map_tiles.tile_set.tile_size.x / 2.0)
@onready var y_offset : int = int(map_tiles.tile_set.tile_size.y / 2.0)

var noise : FastNoiseLite
var tiles_occupancy : Dictionary[Vector2i, Node2D] = {}
var regions : Dictionary[Vector2i, Region] = {}
var terrain_types : int 
var last_region : Vector2i = Vector2i(-100, -100)

func _ready():
	# set to GAMEDATA
	MN._MainM = self
	terrain_types = map_tiles.tile_set.get_terrains_count(0)
	randomize()
	noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.frequency = 0.02
	
func _get_current_tile_position(_position: Vector2) -> Vector2i:
	return map_tiles.local_to_map(to_local(_position))

func _global_tile_position(_tile: Vector2) -> Vector2:
	return Vector2(
		x_offset + _tile.x * x_offset - _tile.y * x_offset,
		_tile.y * y_offset + _tile.x * y_offset
	)

func _clear_tile_occupancy(point: Vector2i) -> void:
	tiles_occupancy.erase(point)
	
func _get_tile_occupancy(point: Vector2i) -> MapObject:
	if tiles_occupancy.has(point):
		return tiles_occupancy[point]
	return null
	
func _add_building(_tile: Vector2i, _building : Building) -> void:
	if !MN._GameN._check_if_can_build():
		return
	for _position : Vector2i in PosFuncs._get_occupied_tiles(_building.building_stats.size):
		tiles_occupancy[_tile + _position] = _building
	_building.global_position = _global_tile_position(_tile)
	_building.tile_position = _tile
	var current_region : Vector2i = _get_current_region(_tile)
	regions[current_region]._add_building(_tile, _building)
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
	# Logic for extraction building
	if _building is ExstractBuilding:
		_building.hub = regions[current_region].hub
	
func _generate_region(cords: Vector2i) -> void:
	var region : Region = region_scene.instantiate()
	region.global_position = _global_tile_position(Vector2(
		cords.x * region_size_x,
		cords.y * region_size_y
	))
	region.global_position += Vector2(0, 8)
	region.cords = cords
	%Regions.add_child(region)
	region._generate_region()

func _get_resources_per_region() -> int:
	return int(region_size_x * region_size_y / 12.0)
	
func _get_current_region(tile_position : Vector2i) -> Vector2i:
	if tile_position.x - 1 < 0:
		tile_position.x -= region_size_x - 1
	if tile_position.y < 0:
		tile_position.y -= region_size_y - 1
		
	return Vector2i(int((tile_position.x - 1) / float(region_size_x)), int(tile_position.y / float(region_size_y)))

func _update_regions(reg_cords: Vector2i) -> void:
	if reg_cords != last_region:
		for _y : int in range(-1, 2):
			for _x : int in range(-1, 2):
				var _reg_cords : Vector2i = Vector2i(last_region.x + _x, last_region.y + _y)
				if regions.has(_reg_cords):
					regions[_reg_cords].hide()
					
		last_region = reg_cords

		for _y : int in range(-1, 2):
			for _x : int in range(-1, 2):
				var _reg_cords : Vector2i = Vector2i(reg_cords.x + _x, reg_cords.y + _y)
				if regions.has(_reg_cords):
					regions[_reg_cords].show()
				else:
					_generate_region(_reg_cords)
					
func _check_if_pos_valid(_tile : Vector2i, _building_size : Vector2i) -> bool:
	for _position : Vector2i in PosFuncs._get_surrounding_tiles(_building_size):
		if tiles_occupancy.has(_tile + _position) and tiles_occupancy[_tile + _position] != null:
			return false
	return true
	
func _show_region_middle():
	for region : Vector2i in regions:
		regions[region]._toggle_on_middle()
		
func _hide_region_middle():
	for region : Vector2i in regions:
		regions[region]._toggle_of_middle()
