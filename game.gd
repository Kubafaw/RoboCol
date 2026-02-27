extends Node2D

class_name GameNode

var ActionProgress : TextureProgressBar
var selected_building : BuildingStats = null

func _ready() -> void:
	MN._GameN = self
	ActionProgress = %ActionProgress

func _process(_delta: float) -> void:
	# Get mouse global and tile position
	var mouse_pos : Vector2 = get_global_mouse_position() + Vector2(0, 8)
	var tile_pos : Vector2i = MN._MainM._get_current_tile_position(mouse_pos)
	
	# Set tile_pointer, action progress bar and camer global positions
	%Pointer.global_position = MN._MainM._global_tile_position(tile_pos) + Vector2(0, 1)
	%ActionProgress.global_position = $Player.global_position + Vector2(-16, -44)
	%Camera.global_position = %Player.global_position
	
	# Process building pointer
	%Building.global_position = MN._MainM._global_tile_position(tile_pos) + Vector2(0, -12)
	if %Building.texture != null:
		%Building.self_modulate = Color(1.0, 1.0, 1.0, 0.7)
		if !_check_if_can_build():
			%Building.self_modulate = Color(1.0, 0.2, 0.2, 0.7)
		
	# Proess building deselect action
	if Input.is_action_just_pressed("Secondary_Action"):
		%Building.texture = null
		if selected_building.hub:
			MN._MainM._hide_region_middle()
		selected_building = null

func _check_if_can_build() -> bool:
	# Get mouse global and tile position
	var mouse_pos : Vector2 = get_global_mouse_position() + Vector2(0, 8)
	var tile_pos : Vector2i = MN._MainM._get_current_tile_position(mouse_pos)
	
	# Check for any neighbouring obstacles, if not allowed to build
	if !MN._MainM._check_if_pos_valid(tile_pos, selected_building.size):
		return false
		
	# Get current region if it exists
	var current_region_cords = MN._MainM._get_current_region(tile_pos)
	if !MN._MainM.regions.has(current_region_cords):
		return false
	var pointer_current_region : Region = MN._MainM.regions[current_region_cords]
	
	# Checks for hub
	if selected_building.hub:
		# Check if middle of region while building hub
		if pointer_current_region._get_global_region_middle() + Vector2i(1, 0) != tile_pos:
			return false
		# Check if no hub regions overlap
		for region_pos : Vector2i in PosFuncs._get_surrounding_tiles(Vector2i(1, 1)):
			var _cords : Vector2i = pointer_current_region.cords + region_pos
			if MN._MainM.regions.has(_cords) and MN._MainM.regions[_cords].hub != null:
				return false
				
	# Checks for other buildings
	else:
		# Check if in hub center region
		for tile_cords in PosFuncs._get_occupied_tiles(selected_building.size):
			var _cords : Vector2i = tile_pos + tile_cords + Vector2i(-1, -1)
			var _current_region_cords : Vector2i = MN._MainM._get_current_region(_cords)
			if !MN._MainM.regions.has(_current_region_cords) or !MN._MainM.regions[_current_region_cords].hub_center:
				return false
		# Check if proper tile type under the extraction building
		if selected_building.extraction_building:
			for tile_cords in PosFuncs._get_occupied_tiles(selected_building.building_size):
				var _cords : Vector2i = tile_pos + tile_cords + Vector2i(-1, 0)
				var _current_region_cords : Vector2i = MN._MainM._get_current_region(tile_pos)
				if !MN._MainM.regions.has(_current_region_cords) or RgD.Regions[selected_building.extraction_tile_type] != MN._MainM.regions[_current_region_cords]._get_tile_type(_cords):
					return false
	return true

func _set_target_marker(_new_pos: Vector2):
	%TargetMarker.global_position = _new_pos + Vector2(0, 1)
	%TargetMarker.show()

func _hide_target_marker():
	%TargetMarker.hide()
	
func _set_building(building_stats : BuildingStats):
	%Building.texture = building_stats.image
	selected_building = building_stats
	
