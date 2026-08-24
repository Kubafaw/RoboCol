extends Control

class_name InventorySlot

@export var icon : Sprite2D
@export var animations : AnimationPlayer
@export var amount_label : Label

var in_focus : bool = false
var resource : ResD.possible_resources
var inventory_main_node : Inventory = null

# Initial setup
func _setup(_positon : Vector2) -> void:
	icon.texture = null
	amount_label.text = ""
	self.position = _positon
	
	
# Changing data and animation pplaying
func _change_data(amount : int, _resource : ResD.possible_resources) -> void:
	if resource == _resource and amount != int(%Amount.text) and animations.assigned_animation != "hover":
		animations.stop()
		animations.play("value_update")
	icon.texture = ResD.Resources[_resource].graphic
	amount_label.text = str(amount)
	resource = _resource


# Checking if clicked and transfering resource if so
func _process(_delta: float) -> void:
	if in_focus and Input.is_action_just_pressed("Main_Action"):
		inventory_main_node._transfer_reosurces(1, resource)
			

# Detecting mouse hover and playing animation if so
func _on_mouse_entered() -> void:
	if animations != null:
		animations.play("hover")
		in_focus = true
	
	
# Detecting mouse exit and playing animation if so
func _on_mouse_exited() -> void:
	if animations != null:
		animations.play("RESET")
		animations.stop()
		in_focus = false
