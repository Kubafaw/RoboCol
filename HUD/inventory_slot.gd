extends Control

class_name InventorySlot

var _resource : String

func _change_icon(_name : String) -> void:
	$Icon.texture = Graphics.Icons[_name]
	_resource = _name

func _change_number(nmb : int) -> void:
	$Number.text = str(nmb)

func _process(_delta: float) -> void:
	if visible:
		_hover(get_viewport().get_mouse_position())

func _hover(mouse_pos: Vector2) -> void:
	if _check_for_mouse_hover(mouse_pos):
		%Background.material.set_shader_parameter("_brightness_modifier", 1.25)
	else:
		%Background.material.set_shader_parameter("_brightness_modifier", 1.0)

func _check_for_mouse_hover(mouse_pos: Vector2) -> bool:
	var container_pos : Vector2 = get_parent().get_parent().position
	if position + container_pos <= mouse_pos and mouse_pos <= position + container_pos + size :
		return true
	return false
