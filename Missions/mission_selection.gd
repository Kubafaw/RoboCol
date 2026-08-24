extends Control

class_name ObjectiveSelection

@export var missions : MissionsSet
@export var missions_container : HBoxContainer


# Get new objectives
func _get_objectives() -> void:
	get_tree().paused = true
	show()
	missions._check_for_unlocks()
	missions.available_missions.shuffle()
	var selections : Array[Node] = missions_container.get_children()
	var index : int = 0
	for objective : Mission in selections:
		if index == len(missions.available_missions):
			break
		objective._set_data(missions.available_missions[index])
		index += 1

	for i in range(index, 3):
		selections[i].hide()
	
	
# Finishing quota
func _quota_met(mission : MissionData) -> void:
	missions.finishedMissions.append(mission)
	missions.available_missions.erase(mission)


# Process choice of objective
func _on_objective_clicked(index: int) -> void:
	GameNode.Game._start_quota_timer(missions.available_missions[index].time)
	GameNode.Game._new_quota(missions.available_missions[index].Quota, 
		missions.available_missions[index].Gains)
	GameNode.Game.current_mission = missions.available_missions[index]
	hide()
	get_tree().paused = false
