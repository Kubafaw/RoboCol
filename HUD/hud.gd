extends Node2D

class_name HUD

@export var inventory_slot_scene : PackedScene
@export var popup_scene : PackedScene

var inventory_slots : HFlowContainer = null

func _ready() -> void:
	Gamedata._HUD = self
	inventory_slots = %Inventory_slots

# TO DO add search and filter for buildings to inventory
# TO DO Add signal for inventory refresh while it is open
func _show_inventory(_inventory: Dictionary[String, int]) -> void:
	var _inventory_slots : Array[Sprite2D] = []
	var _inventory_numbers : Array[Label] = []
	
	for slot : InventorySlot in inventory_slots.get_children():
		slot.free()
	
	for _item in _inventory:
		var inventory_slot : InventorySlot = inventory_slot_scene.instantiate()
		inventory_slot._change_icon(_item)
		inventory_slot._change_number(_inventory[_item])
		inventory_slots.add_child(inventory_slot)
	
	%Inventory.show()
	%Backgorund.show()
		
func _hide_inventory() -> void:
	%Inventory.hide()
	%Backgorund.hide()
		
func _add_popup(resource: String, amount: int, total: int) -> void:
	for popup : ResourcePopup in %Popups.get_children():
		if popup.resource == resource:
			popup._change_amount(amount, total)
			return
			
	var popup : ResourcePopup = popup_scene.instantiate()
	popup.resource = resource
	popup._change_amount(amount, total)
	popup._change_icon(resource)
	%Popups.add_child(popup)
		
