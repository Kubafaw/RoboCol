extends Control

class_name ResourcePopup

@export var life_span : float

var amount : int = 0
var resource : String = ""

func _change_icon(_icon : String) -> void:
	$Sprite2D.texture = Graphics.Icons[_icon]
	
func _change_amount(_add : int, total : int) -> void:
	$Lifespan.start(life_span)
	amount += _add
	$Amount.text = str(amount) + "(" + str(total) + ")"

func _on_lifespan_timeout() -> void:
	queue_free()
