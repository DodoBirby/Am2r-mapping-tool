class_name AM2RMapTile
extends RefCounted

var corner = 0
var special = 0
var color = -1
var walls = {Vector2.UP: 0, Vector2.DOWN: 0, Vector2.LEFT: 0, Vector2.RIGHT: 0}


func get_wall_in_dir(dir: Vector2):
	return walls[dir]
	
func set_wall_in_dir(dir: Vector2, wall: int):
	walls[dir] = wall
	
func get_wall_in_dir_for_corners(dir: Vector2):
	return get_wall_in_dir(dir)

func convert_special_to_init_string():
	match special:
		6:
			return "U"
		7:
			return "D"
		8:
			return "L"
		9:
			return "R"
	return str(special)

func convert_to_map_init_string():
	var str = "%s%s%s%s" % [walls[Vector2.UP], walls[Vector2.RIGHT], walls[Vector2.DOWN], walls[Vector2.LEFT]]
	str += str(color + 1)
	str += convert_special_to_init_string()
	str += convert_corner_to_map_init()
	return str

func convert_corner_to_map_init():
	return GlobalSettings.corner_conversion[corner]
