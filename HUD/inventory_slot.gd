extends Control

class_name InventorySlot

var in_focus : bool = false
var resource : ResD.possible_resources
var inventory_main_node : Inventory = null

func _setup(_positon : Vector2) -> void:
	%Icon.texture = null
	%Amount.text = ""
	self.position = _positon
	
func _change_data(amount : int, _resource : ResD.possible_resources) -> void:
	if resource == _resource and amount != int(%Amount.text) and %HoverAnimation.assigned_animation != "hover":
		%HoverAnimation.stop()
		%HoverAnimation.play("value_update")
	%Icon.texture = ResD.Drops[_resource]
	%Amount.text = str(amount)
	resource = _resource

func _process(_delta: float) -> void:
	if in_focus and Input.is_action_just_pressed("Main_Action"):
		inventory_main_node._transfer_reosurces(1, resource)
			
func _on_mouse_entered() -> void:
	if %HoverAnimation != null:
		%HoverAnimation.play("hover")
		in_focus = true
	
func _on_mouse_exited() -> void:
	if %HoverAnimation != null:
		%HoverAnimation.play("RESET")
		%HoverAnimation.stop()
		in_focus = false
