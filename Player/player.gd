extends Node3D

class_name Player

static var current_player : Player

@export var camera_move_speed : float = 10
@export var camera_rotate_speed : float = 2
@export var move_component : MoveComponent
@export var navigation_component : SimpleNavigation
@export var gather_timer : Timer
@export var graphic : Node3D
@export var camera_pivot : Node3D
@export var target_marker : MeshInstance3D
@export var pointer_marker : MeshInstance3D

var inventory : Dictionary[ResD.possible_resources, int] = {}

var interaction_node : MapObject
var gather_action_time : float

func _ready() -> void:
	current_player = self
	
	# Setting player starting position
	var new_tile : Vector3i = _get_tile_position()
	var new_pos : Vector3 = MainMap.current_Map._global_tile_position(new_tile)
	global_position = new_pos
	move_component.next_position = new_pos
	move_component.actual_position = new_pos
	MainMap.current_Map._update_regions(new_tile)


func _process(delta: float) -> void:
	# Camera movement
	var camera_rotation : float = Input.get_axis("Rotate_clockwise", "Rotate_counterclockwise")
	camera_pivot.rotate_y(camera_rotation * delta * camera_rotate_speed)
	
	## Processing gather action timer if gathering
	#if interaction_node != null:
		#action_progress.value = (gather_action_time - %GatherTimer.time_left) / gather_action_time
	
	# Updating currently visible regions
	var current_tile : Vector3i = _get_tile_position()
	MainMap.current_Map._update_regions(current_tile)


func _unhandled_input(event):
	# Quiting the game
	if Input.is_action_just_pressed("Main_Menu"):
		get_tree().quit()
		
	# Displaying player inventory
	if Input.is_action_just_pressed("inventory"):
		HUD.active_HUD._player_inventory(inventory)
		
	# Get mouse click position
	var result : Dictionary = _get_current_click_position()
	var point : Vector3i =  MainMap.current_Map.gridmap.local_to_map(MainMap.current_Map.gridmap.to_local(result.position))
	point.y = 0
	
	# Setting pointer and building marker positions 
	_set_markers(point)
	
	# Mouse cursor click actions
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			
			# Resetting action after input
			interaction_node = null
			gather_timer.stop()
			# MN._GameN.action_progress.hide()

			# Checking if object present on tile
			var tile_occupancy : MapObject = MainMap.current_Map._get_tile_occupancy(Vector2i(point.x, point.z))
			
			# Logic for clicking on MapObject
			if tile_occupancy != null:
				interaction_node = tile_occupancy
				point = _closest_point_to_object()
				
			# Logic for constructing
			if GameNode.Game.selected_building != null:		
				if Input.is_action_just_pressed("Main_Action"):
					var building : Building = GameNode.Game.selected_building.building.instantiate()
					building.building_stats = GameNode.Game.selected_building
					MainMap.current_Map._add_building(Vector2i(point.x, point.z), building)
				return
			
			# Setting new point for movement if not over hud and not constructing
			if not HUD.active_HUD._build_list_hover() and GameNode.Game.building_pointer == null:
				_set_new_nav_target(point)
				_set_target_marker(MainMap.current_Map._global_tile_position(point))


# Logic for interaction after reaching it
func _on_move_component_target_reached() -> void:
	target_marker.hide()
	if interaction_node != null:
		if interaction_node is ResourceNode:
			gather_timer.start(interaction_node.node_data.GatherTime)
			gather_action_time = interaction_node.node_data.GatherTime
			#action_progress.show()
		if interaction_node is HUB:
			interaction_node._interaction()
		
	navigation_component._set_target(Vector3(INF, INF, INF))


# Logic for adding resource to player inventory
func _add_resource(_resource : ResD.possible_resources, _amount : int) -> void:
	if _resource in inventory.keys():
		inventory[_resource] += _amount
	else:
		inventory[_resource] = _amount
	# Updating hud
	HUD.active_HUD._update_player_inventory(inventory)
	

# Removing resource from player inventory
func _remove_resource(_resource : ResD.possible_resources, _amount : int) -> void:
	inventory[_resource] -= _amount
	if inventory[_resource] == 0:
		inventory.erase(_resource)
	# Updating hud
	HUD.active_HUD._update_player_inventory(inventory)


# Logic for gathering resource node
func _on_gather_timer_timeout() -> void:
	if interaction_node._action(self):
		gather_timer.start(gather_action_time)
		# action_progress.show()
	else:
		# action_progress.hide()
		pass
		
		
# Setting new target for navigation
func _set_new_nav_target(new_tile : Vector3) -> void:
	navigation_component._set_target(new_tile)
	move_component._get_new_point()


# Getting current tile position
func _get_tile_position() -> Vector3i:
	return MainMap.current_Map._get_current_tile_position(global_position)


# Setting target marker
func _set_target_marker(_new_pos: Vector3):
	target_marker.global_position = _new_pos
	target_marker.global_position.y = 0.2
	target_marker.show()
	

# Setting pointer marker
func _set_pointer_marker(_new_pos: Vector3):
	pointer_marker.global_position = _new_pos
	pointer_marker.global_position.y = 0.2
	

# Mouse cursor click position
func _get_current_click_position() -> Dictionary:
	var camera : Camera3D = get_viewport().get_camera_3d()
	var mouse_pos : Vector2 = get_viewport().get_mouse_position()
	var ray_origin  : Vector3 = camera.project_ray_origin(mouse_pos)
	var ray_end : Vector3 = ray_origin + camera.project_ray_normal(mouse_pos) * 1000.0
	var query : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	return get_world_3d().direct_space_state.intersect_ray(query)


# Setting markers
func _set_markers(_position : Vector3) -> void:
		_set_pointer_marker(MainMap.current_Map._global_tile_position(_position))
		GameNode.Game._set_building_marker(_position)


# Getting closest point to the clicked object
func _closest_point_to_object() -> Vector3:
	var new_tile : Vector2i = Vector2i(0, 0)
	var _positions_array : Array[Vector2i] = []
	for _position : Vector2i in PosFuncs._get_neighbouring_tiles(interaction_node._get_size()):
		_positions_array.append(interaction_node.tile_position + _position)
	
	new_tile = PosFuncs._get_closest_tile(_get_tile_position(), _positions_array)

	return Vector3(new_tile.x, 0, new_tile.y)


# Changing rotation based on movement direction
func _change_graphic():
	var x_change : int = int(global_position.x - move_component.next_position.x)
	var z_change : int = int(global_position.z - move_component.next_position.z)
	
	x_change = clamp(x_change, -1, 1)
	z_change = clamp(z_change, -1, 1)
	
	var direction : Vector2i = Vector2i(x_change, z_change) 
	
	match direction:
		Vector2i(0, -1):
			graphic.rotation.y = deg_to_rad(0)
		Vector2i(-1, 0):
			graphic.rotation.y = deg_to_rad(90)
		Vector2i(0, 1):
			graphic.rotation.y = deg_to_rad(180)
		Vector2i(1, 0):
			graphic.rotation.y = deg_to_rad(270)
