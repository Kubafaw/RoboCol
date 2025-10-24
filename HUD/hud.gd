extends Node2D

class_name HUD

@export var inventory_slot_scene : PackedScene
@export var popup_scene : PackedScene

var inventory_slots : HFlowContainer = null
var _visible : bool = false

func _ready() -> void:
	Gamedata._HUD = self
	inventory_slots = %Inventory_slots

# TO DO add search and filter for buildings to inventory
# TO DO Add signal for inventory refresh while it is open
func _show_inventory() -> void:
	var _inventory : Array[Array] = []
	#var _inventory_slots : Array[Sprite2D] = []
	#var _inventory_numbers : Array[Label] = []
	
	for slot : InventorySlot in inventory_slots.get_children():
		slot.free()
		
	for _item in Gamedata._Main_Player.inventory:
		_inventory.append([_item, Gamedata._Main_Player.inventory[_item]])
	
	_inventory.sort_custom(_sort_by_amount)
	
	for _item in _inventory:
		var inventory_slot : InventorySlot = inventory_slot_scene.instantiate()
		inventory_slot._change_icon(_item[0])
		inventory_slot._change_number(_item[1])
		inventory_slots.add_child(inventory_slot)
	
	%Inventory.show()
	%Backgorund.show()
	_visible = true
		
func _hide_inventory() -> void:
	%Inventory.hide()
	%Backgorund.hide()
	_visible = false
	
func _reload_inventory() -> void:
	if _visible:
		_show_inventory()
		
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
		
func _sort_by_amount(a, b) -> bool:
	if a[1] > b[1]:
		return true
	return false
