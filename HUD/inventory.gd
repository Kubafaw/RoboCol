extends Control

class_name Inventory

@onready var _inventory : NinePatchRect = %Inventory

@export var _inv_name : String
@export var _inventory_slot : PackedScene
@export var inventory_nodes : NinePatchRect
@export var type : String
@export var inv_size : Vector2i
@export var _name_label : Label
@export var category_list : OptionButton

var _inventory_visible : bool = false
var _inventory_slots : Array[InventorySlot] = []
var _in_focus : bool = false
var mouse_last_pos : Vector2
var last_pos : Vector2 
var _panel_moving : bool = false
var target : Node3D = null
var selected_category : ResD.categories = ResD.categories.All

func _ready() -> void:
	_name_label.text = _inv_name
	self.hide()
	_clear_panel(_inventory)
	var _inv_slot : InventorySlot
	for _y in range(inv_size.y):
		for _x in range(inv_size.x):
			_inv_slot = _inventory_slot.instantiate()
			_inv_slot.inventory_main_node = self
			_inv_slot._setup(Vector2(9 + 16*_x, 10 + 16 *_y))
			inventory_nodes.add_child(_inv_slot)
			_inventory_slots.append(_inv_slot)
	for category in ResD.categories:
		category_list.add_item(category)
			

func _process(_delta: float) -> void:
	# Processing inventory panel movement using mouse
	if _panel_moving and Input.is_action_pressed("Main_Action"):
		position = last_pos - mouse_last_pos + get_viewport().get_mouse_position()
	else:
		_panel_moving = false
		
	if !_in_focus:
		return
	
	if Input.is_action_just_pressed("Main_Action"):
		mouse_last_pos = get_viewport().get_mouse_position()
		last_pos = position
		_panel_moving = true
	
	
# Process acessing inventory
func _process_inventory(inventory: Dictionary[ResD.possible_resources, int], new_target : Node3D) -> void:
	# Hide inventory if same target
	if _inventory_visible and target == new_target:
		_hide_inventory()
	# Display inventory if new target
	else:
		target = new_target
		_display_inventory(inventory)
	
	
# Process updating opened inventory
func _update_inventory(inventory: Dictionary[ResD.possible_resources, int], new_target : Node3D) -> void:
	# Update inventory if it's visible and same target
	if _inventory_visible and target == new_target:
		_display_inventory(inventory)


# Function for displaying inventory
func _display_inventory(inventory: Dictionary[ResD.possible_resources, int]) -> void:
	_inventory_visible = true
	self.mouse_filter = Control.MOUSE_FILTER_STOP
	var _index : int = 0
	for _item in inventory:
		if selected_category != ResD.categories.All and ResD.Resources[_item].category != selected_category:
			continue
		_inventory_slots[_index]._change_data(inventory[_item], _item)
		_inventory_slots[_index].show()
		_index += 1
	while _index < inv_size.x * inv_size.y:
		_inventory_slots[_index].hide()
		_index +=1
	self.show()	
	
				
# Hiding inventory
func _hide_inventory() -> void:
	_inventory_visible = false
	self.mouse_filter = Control.MOUSE_FILTER_IGNORE
	self.hide()
	
	
# Clearing inventory panel
func _clear_panel(_node: Node) -> void:
	for _child in _node.get_children():
		_child.queue_free()
		
		
# Transfering resource beetwen entities
func _transfer_reosurces(amount : int, resource : ResD.possible_resources):
	if HUD.active_HUD._transfer_resource(amount, resource, target):
		target._remove_resource(resource, amount)


# if mouse hovering over inventory
func _on_mouse_entered() -> void:
	_in_focus = true


# if mouse exited inventory
func _on_mouse_exited() -> void:
	_in_focus = false


# Processing category change
func _on_category_list_item_selected(_index: int) -> void:
	selected_category = _index as ResD.categories
	_update_inventory(target.inventory, target)
