extends MapObject

class_name ResourceNode

var node_data : ResourceNodeData

@export var amount_left : int = 0
@export var animations : AnimationPlayer

var region : Region
var bots_gathering : int = 0
var wind_resistance : float

func _ready() -> void:
	tile_position = MN._MainM._get_current_tile_position(global_position)
	_set_sprite(node_data.image.pick_random())
	amount_left = node_data.DropAmount
	wind_resistance = 0.4 + randf() / 3.0 
	
	for _position : Vector2i in PosFuncs._get_occupied_tiles(node_data.size):
		MN._MainM.tiles_occupancy[tile_position + _position] = self
	
func _process(_delta: float) -> void:
	if !visible:
		return

	if node_data.wind_effected:	
		sprite.skew = sprite.skew * wind_resistance + MN._MainM.wind_strength	
	
func _action(object: Node2D) -> bool:
	if amount_left < 1:
		return false
	object._add_resource(node_data.Drop, 1)
	amount_left -= 1
	animations.play("Gather")
	if amount_left < 1:
		for _position : Vector2i in PosFuncs._get_occupied_tiles(node_data.size):
			MN._MainM._clear_tile_occupancy(tile_position + _position)
		region._resource_gathered()
		animations.play("Vanish")
		animations.animation_finished.connect(_remove)
		return false
	return true
	
func _set_sprite(texture: Texture2D):
	sprite.texture = texture
	sprite.offset.y = int(-sprite.texture.get_height() / 2.0) + 17.0
	%MakeTransparentShape.shape.size = Vector2(%Sprite2D.texture.get_width(), %Sprite2D.texture.get_height() - 11.0)
	%MakeTransparentArea.position.y = -%MakeTransparentShape.shape.size.y/2 + 4.0
	
func _get_size() -> Vector2i:
	return node_data.size
	
func update_shader(_color: Color) -> void:
	pass

func _remove() -> void:
	queue_free()
