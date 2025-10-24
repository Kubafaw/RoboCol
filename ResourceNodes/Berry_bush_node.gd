extends Node

@export var regrow_time : float
@export var Actor : Node2D
@export var AnimatedSprite_2D : AnimatedSprite2D
@export var regrow_timer : Timer

func _ready() -> void:
	regrow_timer.timeout.connect(_regrow)
	var shader_material : ShaderMaterial = AnimatedSprite_2D.material
	shader_material.set_shader_parameter("red_density", randf_range(0.7, 1.2))
	shader_material.set_shader_parameter("green_density", randf_range(0.7, 1.2))
	shader_material.set_shader_parameter("blue_density", randf_range(0.7, 1.2))

func _gather() -> void:
	if AnimatedSprite_2D.frame == 1:
		AnimatedSprite_2D.frame = 0
		Actor.resource_scene = load("res://ResourceDrops/Sticks.tscn")
		regrow_timer.start(regrow_time)
		
func _regrow() -> void:
	AnimatedSprite_2D.frame = 1
	Actor.resource_scene = load("res://ResourceDrops/Berries.tscn")
		
		
		
