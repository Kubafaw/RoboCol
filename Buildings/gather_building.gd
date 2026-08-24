extends Building

class_name GatherBuilding

@export var bots_container : Node3D

var inventory : Dictionary[String, int] = {}
var inventory_shown : bool = false

var hub : HUB = null

func _start() -> void:
	var _pos : Vector3i = [Vector3i(1, 0, 0), Vector3(0, 0, 1)].pick_random()
	var bot_pos : Vector3 = MainMap.current_Map._global_tile_position(_pos) 
	var bot : GatherBot = building_stats.bot_scene.instantiate()
	bot.hub = hub
	bot.gather_building = self
	bots_container.add_child(bot)
	bot.global_position = bot_pos

	
func _interaction() -> void:
	pass
	
	
func _end_interaction() -> void:
	pass


func _add_resource(_resource : String, _amount : int) -> void:
	if _resource in inventory.keys():
		inventory[_resource] += _amount
	else:
		inventory[_resource] = _amount
		
	if inventory_shown:
		pass


func _update_shader(_color: Color) -> void:
	pass
