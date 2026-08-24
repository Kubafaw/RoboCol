extends Node3D

class_name HUD

static var active_HUD : HUD = self

@export var quota_time : Label
@export var objective_selection : ObjectiveSelection
@export var quota_list : VBoxContainer
@export var build_list : BuildList
@export var hub_inventory : Inventory
@export var player_inventory : Inventory
@export var resource_info_scene : PackedScene

func _ready() -> void:
	active_HUD = self


# updating quota timer
func _update_timer(time : float) -> void:
	quota_time.text = "Quota: " + ComDP._float_into_data_min_sec(time)


# Opening player inventory
func _player_inventory(inventory : Dictionary[ResD.possible_resources, int]) -> void:
	player_inventory._process_inventory(inventory, Player.current_player)
	
	
# Updating player inventory if opened
func _update_player_inventory(inventory : Dictionary[ResD.possible_resources, int]) -> void:
	player_inventory._update_inventory(inventory, Player.current_player)
	
	
# Opening hub inventory
func _hub_inventory(inventory : Dictionary[ResD.possible_resources, int], hub: HUB) -> void:
	hub_inventory._process_inventory(inventory, hub)
	
	
# Updating hud inventory if opened
func _hub_update(inventory : Dictionary[ResD.possible_resources, int], hub : HUB) -> void:
	hub_inventory._update_inventory(inventory, hub)
	
	
# Transfering resources bettwen player and hub
func _transfer_resource(amount : int, resource : ResD.possible_resources, sender : Node3D) -> bool:
	if sender is Player:
		if hub_inventory._inventory_visible:
			hub_inventory.target._add_resource(resource, amount)
			return true
	if sender is HUB:
		Player.current_player._add_resource(resource, amount)
		return true
	return false
	
# Getting new quota
func _get_new_quota() -> void:
	objective_selection._get_objectives()
	
	
# Checking if mouse is hovering over build list
func _build_list_hover() -> bool:
	return build_list.mouse_hover
	

# Updating quota resources requirments
func _update_quota(quota : Dictionary[ResD.possible_resources, int]) -> void:
	var index : int = 0
	for key in quota:
		quota_list.get_child(index)._update_value(quota[key])
		index += 1
	
	
# Finishing quota
func _quota_met(mission : MissionData) -> void:
	objective_selection._quota_met(mission)
	
		
# Setting new quota resources requirments
func _new_quota(quota : Dictionary[ResD.possible_resources, int]) -> void:
	for child in quota_list.get_children():
		child.queue_free()
		
	for key in quota:
		var _new_resource_info : ResourceInfo = resource_info_scene.instantiate()
		quota_list.add_child(_new_resource_info)
		_new_resource_info._update_data(ResD.Resources[key].graphic, quota[key])

func _update_build_list() -> void:
	build_list._update_build_list()
