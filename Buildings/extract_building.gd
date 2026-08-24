extends Building

class_name ExstractBuilding

@export var extraction_timer : Timer
var inventory : Dictionary[String, int] = {}
var inventory_shown : bool = false

var hub : HUB = null

func _ready() -> void:
	super()
	_extract()


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
		
		
func _extract() -> void:
	# additional extract time calculation 
	extraction_timer.start(building_stats.extraction_time)
	
	
func _on_extraction_timer_timeout() -> void:
	if OS.is_debug_build() and hub == null:
		return
	hub._add_resource(building_stats.resource, 1)
	_extract()
	
	
func _update_shader(_color: Color) -> void:
	pass
