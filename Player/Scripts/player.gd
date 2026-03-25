extends Node2D

class_name Player

@export var animated_sprite : AnimatedSprite2D
@export var move_component : MoveComponent
@export var navigation_component : IsometricNavigation
@export var gather_timer : Timer

var inventory : Dictionary[ResD.possible_resources, int] = {}

var interaction_node : MapObject
var gather_action_time : float
var animations : Dictionary[Vector2i, String] = {
	Vector2i(1, 0) : "Move_down_right",
	Vector2i(0, 1) : "Move_down_left",
	Vector2i(-1, 0) : "Move_up_left",
	Vector2i(0, -1) : "Move_up_right", 
}

func _ready() -> void:
	MN._MPlayer = self
	var new_tile : Vector2i = MN._MainM._get_current_tile_position(global_position)
	var new_pos : Vector2 = MN._MainM._global_tile_position(new_tile)
	global_position = new_pos
	move_component.next_position = new_pos
	move_component.actual_position = new_pos
	MN._MainM._update_regions(MN._MainM._get_current_region(new_tile))

func _process(_delta: float) -> void:
	# Processing gather action timer if gathering
	if interaction_node != null:
		MN._GameN.action_progress.value = (gather_action_time - %GatherTimer.time_left) / gather_action_time
	# Updating currently visible regions
	var current_tile : Vector2 = MN._MainM._get_current_tile_position(global_position - Vector2(0, -8))
	MN._MainM._update_regions(MN._MainM._get_current_region(current_tile))
	
func _unhandled_input(_event: InputEvent) -> void:
	# Displaying player inventory
	if Input.is_action_just_pressed("Inventory"):
		MN._HUD._player_inventory(inventory)
	# Quiting the game
	if Input.is_action_just_pressed("Main_Menu"):
		get_tree().quit()
	# Handling the main action
	if Input.is_action_just_pressed("Main_Action"):
		# Main data from the mouse pos
		var mouse_pos : Vector2 = get_global_mouse_position() + Vector2(0, 8)
		var new_tile : Vector2i = MN._MainM._get_current_tile_position(mouse_pos)
		var tile_occupancy : MapObject = MN._MainM._get_tile_occupancy(new_tile)
		# Resetting action after input
		interaction_node = null
		gather_timer.stop()
		MN._GameN.action_progress.hide()
		# Logic for clicking on MapObject
		if tile_occupancy != null:
			var _positions_array : Array[Vector2i] = []
			interaction_node = tile_occupancy
			for _position : Vector2i in PosFuncs._get_neighbouring_tiles(tile_occupancy._get_size()):
				_positions_array.append(tile_occupancy.tile_position + _position)
			while true:
				new_tile = PosFuncs._get_closest_tile(MN._MainM._get_current_tile_position(global_position), _positions_array)
				if MN._MainM._get_tile_occupancy(new_tile) == null:
					break
				else:
					_positions_array.erase(new_tile)
					if _positions_array.size() < 1:
						return
		# Logic for building
		if MN._GameN.selected_building != null:		
			if Input.is_action_just_pressed("Main_Action"):
				var building : Building = MN._GameN.selected_building.building.instantiate()
				building.building_stats = MN._GameN.selected_building
				MN._MainM._add_building(new_tile, building)
			return
		# Getting new position for pathfinding
		var new_pos : Vector2 = MN._MainM._global_tile_position(new_tile)
		MN._GameN._set_target_marker(new_pos)
		navigation_component._set_target(new_tile)
		move_component._get_new_point()

# Logic for changing animation
func _change_animation(direction: Vector2i) -> void:
	direction = direction.sign()
	
	if direction.length() == 0:
		animated_sprite.pause()
		return
		
	animated_sprite.play(animations[direction])

# Logic for interaction after reaching it
func _on_move_component_target_reached() -> void:
	MN._GameN._hide_target_marker()
	if interaction_node != null:
		if interaction_node is ResourceNode:
			gather_timer.start(interaction_node.node_data.GatherTime)
			gather_action_time = interaction_node.node_data.GatherTime
			MN._GameN.action_progress.show()
		if interaction_node is HUB:
			interaction_node._interaction()
		
	navigation_component._set_target(Vector2(INF, INF))

# Logic for adding resource to player inventory
func _add_resource(_resource : ResD.possible_resources, _amount : int) -> void:
	if _resource in inventory.keys():
		inventory[_resource] += _amount
	else:
		inventory[_resource] = _amount
	# Updating hud
	MN._HUD._update_player_inventory(inventory)

# Removing resource from player inventory
func _remove_resource(_resource : ResD.possible_resources, _amount : int) -> void:
	inventory[_resource] -= _amount
	if inventory[_resource] == 0:
		inventory.erase(_resource)
	# Updating hud
	MN._HUD._update_player_inventory(inventory)

# Logic for gathering resource node
func _on_gather_timer_timeout() -> void:
	if interaction_node._action(self):
		gather_timer.start(gather_action_time)
		MN._GameN.action_progress.show()
	else:
		MN._GameN.action_progress.hide()
