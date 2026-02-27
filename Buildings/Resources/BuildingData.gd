extends Resource

class_name BuildingStats

@export_category("Base Values")
@export var size : Vector2i = Vector2i(0, 0)
@export var building : PackedScene
@export var image : Texture2D

@export_category("HUB")
@export var hub : bool = false

@export_category("Extraction Building")
@export var extraction_building : bool = false
@export var extraction_time : float = 1.0
@export var resource : ResD.possible_resources
@export var extraction_tile_type : RgD.possible_regions
