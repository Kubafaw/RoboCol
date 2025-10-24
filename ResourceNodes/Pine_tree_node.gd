extends Node

func _ready() -> void:
	var shader_material : ShaderMaterial = get_parent().get_child(0).material
	shader_material.set_shader_parameter("red_density", randf_range(0.7, 1.2))
	shader_material.set_shader_parameter("green_density", randf_range(0.7, 1.2))
	shader_material.set_shader_parameter("blue_density", randf_range(0.7, 1.2))
