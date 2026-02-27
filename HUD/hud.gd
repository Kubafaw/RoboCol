extends Node2D

class_name HUD

func _player_inventory(inventory : Dictionary[String, int]) -> void:
	%PlayerInventory._process_inventory(inventory, MN._MPlayer)
	
func _update_player_inventory(inventory : Dictionary[String, int]) -> void:
	%PlayerInventory._update_inventory(inventory, MN._MPlayer)
	
func _hub_inventory(inventory : Dictionary[String, int], hub: HUB) -> void:
	%HubInventory._process_inventory(inventory, hub)
	
func _hub_update(inventory : Dictionary[String, int], hub : HUB) -> void:
	%HubInventory._update_inventory(inventory, hub)
	
func transfer_resource(amount : int, resource : String, sender : Node2D) -> bool:
	if sender is Player:
		if %HubInventory._inventory_visible:
			%HubInventory.target._add_resource(resource, amount)
			return true
	if sender is HUB:
		MN._MPlayer._add_resource(resource, amount)
		return true
	return false

func _ready() -> void:
	MN._HUD = self
