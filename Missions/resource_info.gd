extends Control

class_name  ResourceInfo

@export var icon : Sprite2D
@export var amount_label : Label

# Updating value and amount for inital setup
func _update_data(image: Texture, amount: int) -> void:
	icon.texture = image
	amount_label.text = "x " + str(amount)


# Updating value
func _update_value(amount: int) -> void:
	amount_label.text = "x " + str(amount)
