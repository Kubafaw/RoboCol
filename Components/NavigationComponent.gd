extends Node

class_name NavigationComponent

@export var Actor: Node2D
@export var navigation_agent : NavigationAgent2D
@export var move_component : MoveComponent

func _generate_new_path(target: Vector2) -> void:
	if navigation_agent.target_position == target and !move_component.moved:
		move_component._same_position()
	else:
		navigation_agent.target_position = target

func _get_next_point() -> Vector2:
	return navigation_agent.get_next_path_position()

func _get_target() -> Vector2:
	return navigation_agent.target_position
