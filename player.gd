extends Node2D

class_name Player

class gather_interaction:
	var time : float
	var node : ResourceNode
	
class building_interaction:
	var building : Building

	
var gather_action : gather_interaction = null
var building_action : building_interaction = null
var inventory : Dictionary[String, int] = {}
var hud_visible : bool = false

func _ready() -> void:
	$Components/MoveComponent.next_position = global_position

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Inventory"):
		if hud_visible:
			Gamedata._HUD._hide_inventory()
		else:
			Gamedata._HUD._show_inventory(inventory)
		hud_visible = !hud_visible

	if not hud_visible and Input.is_action_just_pressed("Main_Action"):
		var mouse_pos : Vector2 = get_global_mouse_position() + Vector2(0, 4)
		var new_tile : Vector2 = Gamedata._Main_Map._get_tile_position(mouse_pos)
		var tile_occupancy : Node2D = Gamedata._Main_Map._get_tile_occupancy(new_tile)
		
		Gamedata._Action_Progress.hide()
		$ActionTimer.stop()
		
		var _positions_array : Array[Vector2] =	[]
		
		if tile_occupancy != null:
			for _position in Positionfunctions._get_neighbouring_tiles(tile_occupancy):
				_positions_array.append(tile_occupancy.tile_position + _position)
			while true:
				new_tile = _get_closest_tile(_positions_array)
				if Gamedata._Main_Map._get_tile_occupancy(new_tile) == null:
					break
				else:
					_positions_array.erase(new_tile)
					if _positions_array.size() < 1:
						return
			
		gather_action = null
		building_action = null
		
		if tile_occupancy is ResourceNode:
			gather_action = gather_interaction.new()
			gather_action.time = tile_occupancy.gather_time
			gather_action.node = tile_occupancy
			
		if tile_occupancy is Building:
			building_action = building_interaction.new()
			building_action.building = tile_occupancy
			 

		var new_pos : Vector2 = Gamedata._Main_Map._global_tile_position(new_tile)
		Gamedata._Game_Node._set_target_marker(new_pos)
		$Components/IsometricNavigation._set_target(new_tile)
		$Components/MoveComponent._get_new_point()

func _process(_delta: float) -> void:
	global_position = global_position.round()
	if gather_action != null:
		Gamedata._Action_Progress.value = (gather_action.time - $ActionTimer.time_left) / gather_action.time
	
func _change_animation(direction: Vector2) -> void:
	if direction.length() == 0:
		$AnimatedSprite2D.pause()
		return
	if direction.x > 0.3 and direction.y > 0.3:
		$AnimatedSprite2D.play("Move_down_right")
	if direction.x < -0.3 and direction.y > 0.3:
		$AnimatedSprite2D.play("Move_down_left") 
	if direction.x > 0.3 and direction.y < -0.3:
		$AnimatedSprite2D.play("Move_up_right")
	if direction.x < -0.3 and direction.y < -0.3:
		$AnimatedSprite2D.play("Move_up_left")

func _on_move_component_target_reached() -> void:
	Gamedata._Game_Node._hide_target_marker()
	$Components/IsometricNavigation._set_target(Vector2(INF, INF))
	if gather_action != null:
		_start_action()
		Gamedata._Action_Progress.show()
	if building_action != null:
		building_action.building._interaction(self)

func _add_resource(_resource : String) -> bool:
	if _resource in inventory.keys():
		inventory[_resource] += 1
	else:
		inventory[_resource] = 1
	
	Gamedata._HUD._add_popup(_resource, 1, inventory[_resource])
	
	return true

func _start_action() -> void:
	$ActionTimer.start(gather_action.time)

func _on_action_timer_timeout() -> void:
	gather_action.node._gather()
	Gamedata._Action_Progress.hide()
	gather_action.node = null
	
func _get_closest_tile(positions: Array[Vector2]) -> Vector2:
	var current_tile : Vector2 = Gamedata._Main_Map._get_tile_position(global_position)
	var current_min : float = positions[0].distance_to(current_tile)
	var current_closest_position : Vector2 = positions[0]
	for _position in positions:
		if current_min > _position.distance_to(current_tile):
			current_min = _position.distance_to(current_tile)
			current_closest_position = _position
	return current_closest_position
