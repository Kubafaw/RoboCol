extends Control

class_name  ResourceInfo

@export var icon : Sprite2D
@export var amount_label : Label

func _update_data(image: Texture, amount: int) -> void:
	icon.texture = image
	amount_label.text = "x " + str(amount)
