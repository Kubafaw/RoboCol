extends Building

class_name GatherBuilding

@export var bots_container : Node2D

var inventory : Dictionary[String, int] = {}
var inventory_shown : bool = false

var hub : HUB = null

func _start() -> void:
	var _pos : Vector2i = [Vector2i(1, 1), Vector2(0, 2)].pick_random()
	var bot_pos : Vector2 = MN._MainM._global_tile_position(_pos) 
	var bot : GatherBot = building_stats.bot_scene.instantiate()
	bot.sprite_frames = building_stats.bot_image
	bot.global_position = bot_pos
	bot.hub = hub
	bot.gather_building = self
	bots_container.add_child(bot)

	
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

func update_shader(_color: Color) -> void:
	pass
