extends Control

class_name InventorySlot

func _change_icon(_name : String) -> void:
	$Icon.texture = Graphics.Icons[_name]

func _change_number(nmb : int) -> void:
	$Number.text = str(nmb)
