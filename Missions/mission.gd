extends Control

class_name Mission

@export var mission_icon : Sprite2D
@export var time_label : Label
@export var gains_list : VBoxContainer
@export var quota_list : VBoxContainer
@export var resource_info_scene : PackedScene

func _set_data(data : MissionData):
	mission_icon.texture = data.icon
	time_label.text = str(int(data.time / 60)) + ":" + \
		(str(int(data.time) % 60) if int(data.time) % 60 > 9 else "0" + str(int(data.time) % 60))
	for gain in data.Gains:
		var gain_info : ResourceInfo = resource_info_scene.instantiate()
		gain_info._update_data(ResD.Drops[gain], data.Gains[gain])
		gains_list.add_child(gain_info)
		
	for quota in data.Quota:
		var quota_info : ResourceInfo = resource_info_scene.instantiate()
		quota_info._update_data(ResD.Drops[quota], data.Quota[quota])
		quota_list.add_child(quota_info)
	
