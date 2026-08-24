extends Resource

class_name  MissionsSet


@export var missions : Array[MissionData]

var available_missions : Array[MissionData]

var finishedMissions : Array[MissionData]

# Checking if new missions avialable to be picked
func _check_for_unlocks() -> void:
	var missions_unlocked : Array[MissionData] = [] 
	
	# Check if mission can be added to unlocked
	for mission : MissionData in missions:
		var add_to_list : bool = true
		for needed : MissionData in mission.missions_to_unlock:
			if needed not in finishedMissions:
				add_to_list = false
				break
		if add_to_list:
			available_missions.append(mission)
			missions_unlocked.append(mission)
	
	# Remove unlocked missions from missions array
	for mission : MissionData in missions_unlocked:
		missions.erase(mission)
