extends Building

class_name HUB

var inventory : Dictionary[String, int] = {}
var inventory_shown : bool = false

var regions : Array[Region] = []
var buildings : Array[Building] = []

func _interaction() -> void:
	inventory_shown = true
	MN._HUD._hub_inventory(inventory, self)
	
func _end_interaction() -> void:
	inventory_shown = false
	MN._HUD._hub_inventory(inventory, self)

func _add_resource(_resource : String, _amount : int) -> void:
	if _resource in inventory.keys():
		inventory[_resource] += _amount
	else:
		inventory[_resource] = _amount
		
	if inventory_shown:
		MN._HUD._hub_update(inventory, self)

func _remove_resource(_resource : String, _amount : int) -> void:
	inventory[_resource] -= _amount
	if inventory[_resource] == 0:
		inventory.erase(_resource)
	MN._HUD._hub_update(inventory, self)
	
