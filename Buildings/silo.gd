extends Building

class_name Silo

signal rocket_delivered(resource : ResD.possible_resources, amount : int)

@export var rocket_graphic : PackedScene
@export var rocket_acceleration : float
@export var rocket_capacity : int

var inventory : Dictionary[String, int] = {}
var inventory_shown : bool = false

var rocket_present : bool = false
var rocket : Node3D = null
var resource : ResD.possible_resources
var amount : int


var hub : HUB = null

func _ready() -> void:
	super()
	# Setup rocket
	rocket = rocket_graphic.instantiate()
	rocket.position = Vector3(
		building_stats.size.x * -1, -0.40, building_stats.size.y * -1) / 1.5
	add_child(rocket)
	rocket.hide()
	# Connect signal
	rocket_delivered.connect(GameNode.Game._update_quota)


func _process(_delta: float) -> void:
	# Processing rocket movement if it's present
	if rocket_present:
		_rocket_movement()
	
		
func _check_if_can_launch() -> void:
	if rocket_present:
		return
		
	for key in GameNode.Game.current_quota:
		if hub.inventory.has(key):
			amount = min(rocket_capacity, hub.inventory[key], GameNode.Game.current_quota[key])
			if amount == 0:
				return
			resource = key
			GameNode.Game.current_quota[resource] -= amount
			hub._remove_resource(key, amount)
			_launch_rocket()
			return
	

		
func _rocket_movement() -> void:
	rocket.position.y += rocket_acceleration
	rocket_acceleration *= 1.02
	
	if rocket.position.y > 50.0:
		rocket_present = false
		rocket.hide()
		rocket_delivered.emit(resource, amount)
		_check_if_can_launch()
			
			
func _launch_rocket() -> void:
	rocket_acceleration = 0.01
	rocket.position.y = -0.25
	rocket_present = true
	rocket.show()
		
		
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
