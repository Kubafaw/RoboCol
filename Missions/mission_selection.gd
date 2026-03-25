extends Control

@export var Missions : MissionsSet
@export var MissionsSelect : HBoxContainer

func _ready() -> void:
	_get_objectives()

func _get_objectives() -> void:
	get_tree().paused = true
	Missions.EntryMissions.shuffle()
	var selections : Array[Node] = MissionsSelect.get_children()
	var index : int = 0
	for objective : Mission in selections:
		if index == len(Missions.EntryMissions):
			break
		objective._set_data(Missions.EntryMissions[index])
		index += 1

	for i in range(index, 3):
		selections[i].hide()
		
	
