extends Control

@export var image : Texture2D
@export var building_stats : BuildingStats

var hovered_over : bool = false

func _ready() -> void:	
	%Image.texture = image

func _on_mouse_entered() -> void:
	hovered_over = true

func _on_mouse_exited() -> void:
	hovered_over = false
	
func _process(_delta: float) -> void:
	if not hovered_over:
		return
		
	if Input.is_action_just_pressed("Main_Action"):
		MN._GameN._set_building(building_stats)
		MN._MainM._hide_region_middle()
		if building_stats.type == building_stats.building_type.HUB:
			MN._MainM._show_region_middle()
