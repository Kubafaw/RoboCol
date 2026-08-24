extends Control

class_name Mission

signal clicked(index: int)

@export var index : int
@export var mission_icon : Sprite2D
@export var time_label : Label
@export var gains_list : VBoxContainer
@export var quota_list : VBoxContainer
@export var resource_info_scene : PackedScene

# Setting up mission info
func _set_data(data : MissionData):
	mission_icon.texture = data.icon
	time_label.text = ComDP._float_into_data_min_sec(data.time)

	# Cleanup of lists
	for previous : ResourceInfo in gains_list.get_children():
		previous.queue_free()
		
	for previous : ResourceInfo in quota_list.get_children():
		previous.queue_free()
	
	# adding resources to lists
	for gain : ResD.possible_resources in data.Gains:
		var gain_info : ResourceInfo = resource_info_scene.instantiate()
		gain_info._update_data(ResD.Resources[gain].graphic, data.Gains[gain])
		gains_list.add_child(gain_info)
		
	for quota : ResD.possible_resources in data.Quota:
		var quota_info : ResourceInfo = resource_info_scene.instantiate()
		quota_info._update_data(ResD.Resources[quota].graphic, data.Quota[quota])
		quota_list.add_child(quota_info)


# Proccesing mission being clicked
func _on_button_pressed() -> void:
	clicked.emit(index)
