extends MapObject

class_name ResourceNode

var node_data : ResourceNodeData

@export var amount_left : int = 0
@export var animations : AnimationPlayer

var region : Region
var bots_gathering : int = 0


func _ready() -> void:
	global_position -= MainMap.current_Map.grid_map_cell_size / 2.0
	global_position.y = MainMap.current_Map.grid_map_cell_size.y * 20
	amount_left = node_data.DropAmount
	_set_graphic()
	_set_occupancy()
			

# Starting gather action on resource node
func _action(object: Node3D) -> bool:
	# Return true if still can be gathred false otherwise
	object._add_resource(node_data.Drop, 1)
	amount_left -= 1
	animations.play("Gather")
	# Processing removal of resource node
	if amount_left < 1:
		# Starting vanish animation
		animations.play("Vanish")
		animations.animation_finished.connect(_remove)
		return false
	return true

	
# Setting initial tile occupancy
func _set_occupancy():
	for _position : Vector2i in PosFuncs._get_occupied_tiles(node_data.size):
		MainMap.current_Map.tiles_occupancy[tile_position + _position] = self


# Setting up graphic
func _set_graphic():
	var new_mesh = node_data.Graphic.instantiate()
	add_child(new_mesh)
	
	# Cords for debugging
	if OS.is_debug_build():
		new_mesh.get_child(1).text = str(tile_position)
	else:
		new_mesh.get_child(1).text = ""
	
	
# Getting size of resource node
func _get_size() -> Vector2i:
	return node_data.size
	
	
# processing removal of resource node
func _remove(_name : StringName) -> void:
	# Clearing tile occupancy
	for _position : Vector2i in PosFuncs._get_occupied_tiles(node_data.size):
			MainMap.current_Map._clear_tile_occupancy(tile_position + _position)
			
	region._resource_gathered()
	region.spawned_resources -= 1
	queue_free()
