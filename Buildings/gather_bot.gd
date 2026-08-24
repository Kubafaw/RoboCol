extends Node3D

class_name GatherBot

@export var graphic : Node3D
@export var gather_timer : Timer
@export var wait_timer : Timer
@export var navigation : SimpleNavigation
@export var move_component : MoveComponent

var interaction_node : ResourceNode
var hub : HUB
var gather_building : GatherBuilding
var stored_amount : int = 0:
	set(value):
		stored_amount = value
		# graphic.material.set_shader_parameter("fullness", float(stored_amount) / float(max_stored_amount))

		
var max_stored_amount : int = 6
var going_back_to_hub : bool = false
var hub_side : int = 0
#var hub_signal : Signal

func _ready() -> void:
	var new_tile : Vector3i = MainMap.current_Map._get_current_tile_position(global_position)
	var new_pos : Vector3 = MainMap.current_Map._global_tile_position(new_tile)
	global_position = new_pos
	move_component.next_position = new_pos
	move_component.actual_position = new_pos
	_find_node_to_gather()


func _process(_delta: float) -> void:
	_change_graphic()
	
	
func _find_node_to_gather() -> void:
	if stored_amount >= max_stored_amount:
		_go_back_to_hub()
		going_back_to_hub = true
		return
		
	var nodes : Array[ResourceNode] = []
	for region : Region in hub.regions:
		nodes += region._get_resource_nodes(gather_building.building_stats.resource)
	var closest : ResourceNode = null
	var closest_distance : int = 10000
	var current_pos : Vector3i = MainMap.current_Map._get_current_tile_position(global_position)
	for node in nodes:
		var distance : int = abs(node.tile_position.x - current_pos.x) + abs(node.tile_position.y - current_pos.z)
		if distance < closest_distance:
			closest = node
			closest_distance = distance
	
	if closest != null:
		var _positions_array : Array[Vector2i] = []
		for _position in PosFuncs._get_neighbouring_tiles(closest._get_size()):
			_positions_array.append(closest.tile_position + _position)
		var new_pos : Vector2i = PosFuncs._get_closest_tile(current_pos, _positions_array)
		navigation._set_target(Vector3i(new_pos.x, 0, new_pos.y))
		move_component._get_new_point()
		interaction_node = closest
		interaction_node.bots_gathering += 1
		if MainMap.current_Map._global_tile_position(Vector3i(new_pos.x, 0, new_pos.y)) == global_position:
			_on_move_component_target_reached()
	else:
		wait_timer.start()
	
	
# Logic for gathering after reaching node
func _on_move_component_target_reached() -> void:
	if going_back_to_hub:
		#hub_signal = hub._transfer_in_resource(hub_side)
		#hub_signal.connect(_door_opened)
		_door_opened()
		return
	if interaction_node != null:
		# tool.play("Tool")
		gather_timer.start(interaction_node.node_data.GatherTime)
		navigation._set_target(Vector3(INF, INF, INF))
	else:
		wait_timer.start()
		
		
func _add_resource(_resoure : ResD.possible_resources, _amount : int) -> void:
	stored_amount += 1
	
	
func _on_gather_timer_timeout() -> void:
	if interaction_node != null and interaction_node._action(self):
		gather_timer.start(interaction_node.node_data.GatherTime)
	else:
		#tool.stop()
		wait_timer.start()


func _go_back_to_hub() -> void:
	var current_pos = MainMap.current_Map._get_current_tile_position(global_position)
	var _positions_array : Array[Vector2i] = [hub.tile_position + Vector2i(-1, 1), hub.tile_position + Vector2i(-1,-3)]
	var new_pos : Vector2i = PosFuncs._get_closest_tile(current_pos, _positions_array)
	var index : int = 0
	for _pos in _positions_array:
		if new_pos == _pos:
			hub_side = index
			break
		index += 1
	navigation._set_target(Vector3i(new_pos.x, 0, new_pos.y))
	move_component._get_new_point()
	
	
func _on_wait_timeout() -> void:
	if not going_back_to_hub:
		_find_node_to_gather()
		
		
func _door_opened() -> void:
	hub._add_resource(gather_building.building_stats.resource, stored_amount)
	stored_amount = 0
	going_back_to_hub = false
	wait_timer.start()
	# hub_signal.disconnect(_door_opened)
	
	
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
