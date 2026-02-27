extends MapObject

class_name ResourceNode

@export var amount_to_extract : int = 0
@export var resource : String
@export var gather_time : float = 1.0
@export var size : Vector2i

var region : Region

func _ready() -> void:
	tile_position = MN._MainM._get_current_tile_position(global_position)
	
	for _position : Vector2i in PosFuncs._get_occupied_tiles(size):
		MN._MainM.tiles_occupancy[tile_position + _position] = self
	
func _action(player: Player) -> bool:
	player._add_resource(resource, 1)
	amount_to_extract -= 1
	
	if amount_to_extract < 1:
		for _position : Vector2i in PosFuncs._get_occupied_tiles(size):
			MN._MainM._clear_tile_occupancy(tile_position + _position)
		region._resource_gathered()
		queue_free()
		return false
	return true

func _set_sprite(texture: Texture):
	%Sprite2D.texture = texture
	%Sprite2D.offset.y = -%Sprite2D.texture.get_height() / 2 + 16
	%MakeTransparentShape.shape.size = Vector2(%Sprite2D.texture.get_width(), %Sprite2D.texture.get_height() - 11.0)
	%MakeTransparentArea.position.y = -%MakeTransparentShape.shape.size.y/2 + 6.0
	
func _get_size() -> Vector2i:
	return size
