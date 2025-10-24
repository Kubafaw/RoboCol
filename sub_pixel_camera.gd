extends Camera2D

var actual_cam_pos : Vector2

@export var object : Node2D = null

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	
	actual_cam_pos = position.lerp(object.global_position, delta * 3)
	
	var cam_subpixel_offset = actual_cam_pos.round() - actual_cam_pos
	
	get_parent().get_parent().get_parent().material.set_shader_parameter("cam_offset", cam_subpixel_offset)

	global_position = actual_cam_pos.round()
