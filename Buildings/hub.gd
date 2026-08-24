extends Building

class_name HUB

#signal left_door_opened
#signal right_door_opened

var inventory : Dictionary[ResD.possible_resources, int] = {}
var inventory_shown : bool = false

var regions : Array[Region] = []
var buildings : Array[Building] = []


func _ready() -> void:
	super()
	# Connect Quota changed signal
	GameNode.Game.quota_chenged.connect(_check_if_silos_can_launch)


func _interaction() -> void:
	inventory_shown = true
	HUD.active_HUD._hub_inventory(inventory, self)
	
	
func _end_interaction() -> void:
	inventory_shown = false
	HUD.active_HUD._hub_inventory(inventory, self)


func _add_resource(_resource : ResD.possible_resources, _amount : int) -> void:
	if _resource in inventory.keys():
		inventory[_resource] += _amount
	else:
		inventory[_resource] = _amount
		
	# Check if silos can launch
	if _resource in GameNode.Game.current_quota.keys():
		_check_if_silos_can_launch()
		
	# Update HUD if this hub inventory is visible
	if inventory_shown:
		HUD.active_HUD._hub_update(inventory, self)


func _check_if_silos_can_launch() -> void:
	for building in buildings:
		if building is Silo:
			building._check_if_can_launch()


func _remove_resource(_resource : ResD.possible_resources, _amount : int) -> void:
	inventory[_resource] -= _amount
	if inventory[_resource] == 0:
		inventory.erase(_resource)
	HUD.active_HUD._hub_update(inventory, self)
	
#func _update_shader(_color: Color) -> void:
	#%Beam.material.set_shader_parameter("alpha", _color.a)
	
#func _transfer_in_resource(side: int) -> Signal:
	#if side == 0:
		#if %Door_left.animation == "Open" and !%Door_left.is_playing():
			#call_deferred("emit_signal", "left_door_opened")
		#else:			
			#%Door_left.play("Open")
		#%Left_door_timer.start()
		#return left_door_opened
	#elif side == 1:
		#if %Door_right.animation == "Open" and !%Door_right.is_playing():
			#call_deferred("emit_signal", "right_door_opened")
		#else:			
			#%Door_right.play("Open")
		#%Right_door_timer.start()
		#return right_door_opened
	#
	#return left_door_opened
	
#func _on_door_left_animation_finished() -> void:
	#if %Door_left.animation == "Open":
		#left_door_opened.emit()
#
#func _on_door_right_animation_finished() -> void:
	#if %Door_right.animation == "Open":
		#right_door_opened.emit()
#
#func _on_left_door_timer_timeout() -> void:
	#%Door_left.play("Close")
#
#func _on_right_door_timer_timeout() -> void:
	#%Door_right.play("Close")
