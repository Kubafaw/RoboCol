extends Control

class_name BuildList

@export var category_list : OptionButton
@export var buildings_lists : Array[NinePatchRect]
@export var token_amount_labels : Array[Label]
@export var hover_detection_area : CollisionShape2D

var current_index : int = 0
var mouse_hover : bool = false

func _ready() -> void:
	modulate = Color(1.0, 1.0, 1.0, 0.3)
	
	for category in ResD.categories:
		category_list.add_item(category)
		

func _process(_delta: float) -> void:
	# Checking if mouse is hovering over build list
	var _mouse_pos : Vector2 = get_local_mouse_position()
	if  (_mouse_pos.x > -hover_detection_area.shape.size.x / 2 and 
	_mouse_pos.x < hover_detection_area.shape.size.x / 2
	and _mouse_pos.y > -80
	#and _mouse_pos.y < hover_detection_area.shape.size.y
	):
		mouse_hover = true
		modulate = Color(1.0, 1.0, 1.0, 1.0)
	else: 
		mouse_hover = false
		modulate = Color(1.0, 1.0, 1.0, 0.3)


# Selecting category logic
func _on_category_list_item_selected(index: int) -> void:
	current_index = index
	_update_build_list()


# Updating build list display
func _update_build_list() -> void:
	for buildings_list in buildings_lists:
		buildings_list.hide()
	buildings_lists[current_index].show()
	
	token_amount_labels[current_index].text =  str(GameNode.Game.available_tokens[ResD.token_ids[current_index]])
