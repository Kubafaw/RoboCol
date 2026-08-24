extends Node3D

class_name GameNode

static var Game : GameNode

signal quota_chenged

@export var building_pointer : Node3D = null
@export var directional_light : DirectionalLight3D
@export var quota_timer : Timer

var selected_building : BuildingStats = null
var current_mission : MissionData
var current_quota : Dictionary[ResD.possible_resources, int]
var visible_quota : Dictionary[ResD.possible_resources, int]
var available_tokens : Dictionary[ResD.possible_resources, int] = {
	ResD.possible_resources.Token : 2,
	ResD.possible_resources.ForestryToken : 0,
	ResD.possible_resources.MiningToken : 0,
	ResD.possible_resources.PotteryToken : 0
}


func _ready() -> void:
	Game = self

func _process(delta: float) -> void:
	directional_light.rotate_y(0.2 * delta)
	
	# Updating quota time
	HUD.active_HUD._update_timer(quota_timer.time_left)
	
	# Process building deselect action
	if Input.is_action_just_pressed("Secondary_Action") and selected_building != null:
		_clear_building_pointer()
		MainMap.current_Map._hide_region_middle()

	
func _set_building_marker(_new_pos: Vector3):
	if building_pointer != null:
		var _new_position : Vector3 = MainMap.current_Map._global_tile_position(_new_pos)
		var building_pointer_last_position = building_pointer.global_position
		building_pointer.global_position = _new_position + Vector3(
			-selected_building.size.x, 0.0, -selected_building.size.y)/1.5
		if building_pointer_last_position != building_pointer.global_position:
			_check_if_can_build(Vector2(_new_pos.x, _new_pos.z))
		building_pointer.show()
		
		
	
func _start_quota_timer(time: float):
	quota_timer.start(time / 10.0) 
	
	
func _on_quota_timer_timeout() -> void:
	HUD.active_HUD._get_new_quota()
	
	
func _set_building(building_stats : BuildingStats):
	_clear_building_pointer()
	building_pointer = building_stats.graphic.instantiate()
	building_pointer.hide()
	add_child(building_pointer)
	selected_building = building_stats
	
	
func _clear_building_pointer() -> void:
	if building_pointer == null:
		return
	building_pointer.queue_free()
	building_pointer = null
	selected_building = null
	
	
func _update_quota(resource : ResD.possible_resources, amount : int) -> void:
	if visible_quota.has(resource):
		visible_quota[resource] -= amount
		HUD.active_HUD._new_quota(visible_quota)
		
		for key in visible_quota: 
			if visible_quota[key] > 0:
				return
		
		if quota_timer.time_left > 30.0:
			quota_timer.start(30.0)
		HUD.active_HUD._quota_met(current_mission)
	
	
func _new_quota(quota : Dictionary[ResD.possible_resources, int], 
	gains : Dictionary[ResD.possible_resources, int]) -> void:
	
	# Set quota to the game
	current_quota = quota
	visible_quota = current_quota.duplicate()
	
	# Update HUD
	HUD.active_HUD._new_quota(visible_quota)
	
	# emit signal
	quota_chenged.emit()
	
	# Get gains after selecting quota
	for key in gains:
		if available_tokens.has(key):
			available_tokens[key] += gains[key]
		else:
			available_tokens[key] = gains[key]
	HUD.active_HUD._update_build_list()
	
	
	
func _check_if_can_build(tile_pos: Vector2i) -> bool:
	# Reset model color
	_set_model_color(building_pointer, Color.WHITE)
	
	# Override of constraints for debug
	if OS.is_debug_build() and Input.is_action_pressed("Force_action"):
		return	true
		
	# Check if there is a token available:
	if available_tokens[ResD.token_ids[selected_building.category]] < 1:
		_set_model_color(building_pointer, Color.RED)
		return false
	
	# Check for any neighbouring obstacles, if not allowed to build
	if !MainMap.current_Map._check_if_pos_valid(tile_pos, selected_building.size):
		_set_model_color(building_pointer, Color.RED)
		return false
		
	# Get current region if it exists
	var current_region_cords = MainMap.current_Map._get_current_region(Vector3i(tile_pos.x, 0, tile_pos.y))
	if !MainMap.current_Map.regions.has(current_region_cords):
		_set_model_color(building_pointer, Color.RED)
		return false
	var pointer_current_region : Region = MainMap.current_Map.regions[current_region_cords]
	
	# Checks for hub
	if selected_building.type == selected_building.building_type.HUB:
		# Check if middle of region while building hub
		if pointer_current_region._get_global_region_middle() + Vector2i(1, 0) != tile_pos:
			_set_model_color(building_pointer, Color.RED)
			return false
		# Check if no hub regions overlap
		for region_pos : Vector2i in PosFuncs._get_surrounding_tiles(Vector2i(1, 1)):
			var _cords : Vector2i = pointer_current_region.cords + region_pos
			if MainMap.current_Map.regions.has(_cords) and MainMap.current_Map.regions[_cords].hub != null:
				_set_model_color(building_pointer, Color.RED)
				return false
				
	# Checks for other buildings
	else:
		# Check if in hub center region
		for tile_cords in PosFuncs._get_occupied_tiles(selected_building.size):
			var _cords : Vector2i = tile_pos + tile_cords + Vector2i(-1, -1)
			var _current_region_cords : Vector2i = MainMap.current_Map._get_current_region(Vector3i(_cords.x, 0, _cords.y))
			if !MainMap.current_Map.regions.has(_current_region_cords) or !MainMap.current_Map.regions[_current_region_cords].hub_center:
				_set_model_color(building_pointer, Color.RED)
				return false
	
		# Check if proper tile type under the extraction building
		if selected_building.type == selected_building.building_type.Extract :
			for tile_cords in PosFuncs._get_occupied_tiles(selected_building.size):
				var _cords : Vector2i = tile_pos + tile_cords + Vector2i(-1, 0)
				var _current_region_cords : Vector2i = MainMap.current_Map._get_current_region(Vector3i(tile_pos.x, 0, tile_pos.y))
				if ( !MainMap.current_Map.regions.has(_current_region_cords) or 
				  RgD.Regions[selected_building.extraction_tile_type] != 
				  MainMap.current_Map.regions[_current_region_cords]._get_tile_type(_cords) ):
					_set_model_color(building_pointer, Color.RED)
					return false
					
	return true
	

# Setting custom model color
func _set_model_color(model : Node3D, color : Color):
	var mesh_instance : MeshInstance3D = model.get_child(0)
	var material : Material = mesh_instance.get_active_material(0)

	if material:
		material = material.duplicate()
		material.albedo_color = color
		mesh_instance.set_surface_override_material(0, material)
