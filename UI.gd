extends CanvasLayer
@onready var map_coords = %MapCoords

func update_coords(pos: Vector2):
	map_coords.text = "(%s, %s)" % [pos.x, pos.y]


