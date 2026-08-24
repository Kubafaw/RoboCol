extends Control

@export var image : Texture2D
@export var graphic : Sprite2D
@export var building_stats : BuildingStats

var hovered_over : bool = false

func _ready() -> void:	
	graphic.texture = image
	pass


func _on_mouse_entered() -> void:
	hovered_over = true


func _on_mouse_exited() -> void:
	hovered_over = false
	
	
func _process(_delta: float) -> void:
	if not hovered_over:
		return
	
	# Process being clicked on
	if Input.is_action_just_pressed("Main_Action"):
		GameNode.Game._set_building(building_stats)
		MainMap.current_Map._hide_region_middle()
		if building_stats.type == building_stats.building_type.HUB:
			MainMap.current_Map._show_region_middle()
