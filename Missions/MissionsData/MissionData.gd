extends Resource

class_name MissionData

@export var icon : Texture
@export var time : float
@export var missions_to_unlock : Array[MissionData]
@export var Gains : Dictionary[ResD.possible_resources, int]
@export var Quota : Dictionary[ResD.possible_resources, int]
