extends Resource

class_name BuildingStats

enum building_type {HUB = 0, LaunchPad = 1, Extract = 2, Gather = 3, Factory = 4}

@export_category("Base Values")
@export var size : Vector2i = Vector2i(0, 0)
@export var building : PackedScene
@export var image : Texture2D
@export var type : building_type
@export var category : ResD.categories

@export_category("HUB")

@export_category("Extraction Building")
@export var extraction_time : float = 1.0
@export var resource : ResD.possible_resources
@export var extraction_tile_type : RgD.possible_regions

@export_category("Gather Building")
@export var gather_time : float = 1.0
@export var bot_scene : PackedScene
@export var bot_image : SpriteFrames
