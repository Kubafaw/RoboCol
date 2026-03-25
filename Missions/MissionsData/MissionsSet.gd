extends Resource

class_name  MissionsSet

@export var EntryMissions : Array[MissionData]
@export var UnlockableMissons : Array[MissionData]

var finishedMissions : Array[MissionData]

func _check_for_unlocks() -> void:
	var	missions_unlocked : Array[MissionData] = [] 
	
	for mission : MissionData in UnlockableMissons:
		var add_to_list : bool = true
		for needed : MissionData in mission.missions_to_unlock:
			if needed not in finishedMissions:
				add_to_list = false
				break
		if add_to_list:
			EntryMissions.append(mission)
			missions_unlocked.append(mission)
			
	for mission : MissionData in missions_unlocked:
		UnlockableMissons.erase(mission)
