extends Node2D

class_name GameNode

@export var resource_node_scene_tmp : PackedScene
@export var resource_node_scene_tmp2 : PackedScene
@export var building_scene_tmp : PackedScene

# TO DO add objectives for getting resources
func _ready() -> void:
	Gamedata._Game_Node = self
	Gamedata._Action_Progress = $ActionProgress
	
	Gamedata._Main_Map._add_building(
		Vector2(0, 0), building_scene_tmp.instantiate())

func _process(_delta: float) -> void:
	var mouse_pos : Vector2 = get_global_mouse_position() + Vector2(0, 4)
	$Pointer.global_position = Gamedata._Main_Map._get_tile_global_position(mouse_pos)
	$ActionProgress.global_position = $Player.global_position + Vector2(-8, -22)

func _set_target_marker(_new_pos: Vector2):
	$TargetMarker.global_position = _new_pos
	$TargetMarker.show()

func _hide_target_marker():
	$TargetMarker.hide()
	
func _start_action(set_time: float, target: ResourceNode) -> void:
	$Player.start_action(set_time, target)
