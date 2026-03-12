extends Node2D

class_name GatherBot

@export var animated_sprite : AnimatedSprite2D
@export var tool : AnimatedSprite2D
@export var gather_timer : Timer
@export var wait_timer : Timer
@export var navigation : IsometricNavigation
@export var move_component : MoveComponent

var interaction_node : ResourceNode
var sprite_frames : SpriteFrames
var hub : HUB
var gather_building : GatherBuilding
var stored_amount : int = 0
var max_stored_amount : int = 6
var going_back_to_hub : bool = false
var hub_side : int = 0
var hub_signal : Signal

func _ready() -> void:
	animated_sprite.sprite_frames = sprite_frames
	var new_tile : Vector2i = MN._MainM._get_current_tile_position(global_position)
	var new_pos : Vector2 = MN._MainM._global_tile_position(new_tile)
	global_position = new_pos
	move_component.next_position = new_pos
	move_component.actual_position = new_pos
	_find_node_to_gather()
	
func _find_node_to_gather() -> void:
	if stored_amount >= max_stored_amount:
		_go_back_to_hub()
		going_back_to_hub = true
		return
		
	var nodes : Array[ResourceNode] = []
	for region : Region in hub.regions:
		nodes += region.get_resource_nodes(gather_building.building_stats.resource)
	var closest : ResourceNode = null
	var closest_distance : int = 10000
	var current_pos = MN._MainM._get_current_tile_position(global_position)
	for node in nodes:
		var distance : int = abs(node.tile_position.x - current_pos.x) + abs(node.tile_position.y - current_pos.y)
		if distance < closest_distance:
			closest = node
			closest_distance = distance
	
	if closest != null:
		var _positions_array : Array[Vector2i] = []
		for _position in PosFuncs._get_neighbouring_tiles(closest._get_size()):
			_positions_array.append(closest.tile_position + _position)
		var new_pos : Vector2i = PosFuncs._get_closest_tile(current_pos, _positions_array)
		navigation._set_target(new_pos)
		move_component._get_new_point()
		interaction_node = closest
		interaction_node.bots_gathering += 1
		if MN._MainM._global_tile_position(new_pos) == global_position:
			_on_move_component_target_reached()
		%TargetMarker.global_position = MN._MainM._global_tile_position(new_pos)
	else:
		wait_timer.start()
	
# Logic for gathering after reaching it
func _on_move_component_target_reached() -> void:
	if going_back_to_hub:
		hub_signal = hub._transfer_in_resource(hub_side)
		hub_signal.connect(_door_opened)
		return
	if interaction_node != null:
		tool.play("Tool")
		gather_timer.start(interaction_node.node_data.GatherTime)
		navigation._set_target(Vector2(INF, INF))
	else:
		wait_timer.start()
		
func _add_resource(_resoure : ResD.possible_resources, _amount : int) -> void:
	stored_amount += 1
	
# To make into animation player
func _change_animation(direction: Vector2) -> void:
	if direction.length() == 0:
		animated_sprite.pause()
		return
	if direction.x > 0.3 and direction.y > 0.3:
		animated_sprite.play("Move_down_right")
		tool.position = Vector2(13, -10)
		tool.skew = deg_to_rad(15)
	if direction.x < -0.3 and direction.y > 0.3:
		animated_sprite.play("Move_down_left") 
		tool.position = Vector2(-9, -10)
		tool.skew = deg_to_rad(-15)
	if direction.x > 0.3 and direction.y < -0.3:
		animated_sprite.play("Move_up_right")
		tool.position = Vector2(14, -10)
		tool.skew = deg_to_rad(-30)
	if direction.x < -0.3 and direction.y < -0.3:
		animated_sprite.play("Move_up_left")
		tool.position = Vector2(-11, -10)
		tool.skew = deg_to_rad(30)

func _on_gather_timer_timeout() -> void:
	if interaction_node != null and interaction_node._action(self):
		gather_timer.start(interaction_node.node_data.GatherTime)
	else:
		tool.stop()
		wait_timer.start()

func _go_back_to_hub() -> void:
	var current_pos = MN._MainM._get_current_tile_position(global_position)
	var _positions_array : Array[Vector2i] = [hub.tile_position + Vector2i(0, 1), hub.tile_position + Vector2i(1, 0)]
	var new_pos : Vector2i = PosFuncs._get_closest_tile(current_pos, _positions_array)
	var index : int = 0
	for _pos in _positions_array:
		if new_pos == _pos:
			hub_side = index
			break
		index += 1
	navigation._set_target(new_pos)
	move_component._get_new_point()
	%TargetMarker.global_position = MN._MainM._global_tile_position(new_pos)
	
func _on_wait_timeout() -> void:
	if not going_back_to_hub:
		_find_node_to_gather()
		
func _door_opened() -> void:
	hub._add_resource(gather_building.building_stats.resource, stored_amount)
	stored_amount = 0
	going_back_to_hub = false
	wait_timer.start()
	hub_signal.disconnect(_door_opened)
