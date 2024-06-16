class_name AM2RMapTile
extends RefCounted

var corner:
	set(value):
		var prev_state = clone()
		_corner = value
		var new_state = clone()
		if UndoManager.recording_undo:
			UndoManager.record_mutation_in_undo_frame(prev_state, new_state, coordinates)
	get:
		return _corner
var _corner = 0


var special:
	set(value):
		var prev_state = clone()
		_special = value
		var new_state = clone()
		if UndoManager.recording_undo:
			UndoManager.record_mutation_in_undo_frame(prev_state, new_state, coordinates)
	get:
		return _special
var _special = 0


var color:
	set(value):
		var prev_state = clone()
		_color = value
		var new_state = clone()
		if UndoManager.recording_undo:
			UndoManager.record_mutation_in_undo_frame(prev_state, new_state, coordinates)
	get:
		return _color
var _color = -1


var walls = {Vector2.UP: 0, Vector2.DOWN: 0, Vector2.LEFT: 0, Vector2.RIGHT: 0}
var coordinates = Vector2.ZERO

func _init(coords: Vector2):
	coordinates = coords

func get_wall_in_dir(dir: Vector2):
	return walls[dir]
	
func set_wall_in_dir(dir: Vector2, wall: int):
	var prev_state = clone()
	walls[dir] = wall
	var new_state = clone()
	if UndoManager.recording_undo:
		UndoManager.record_mutation_in_undo_frame(prev_state, new_state, coordinates)
	
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
	
func clone():
	var clone = AM2RMapTile.new(coordinates)
	clone._corner = corner
	clone._color = color
	clone._special = special
	for key in clone.walls.keys():
		clone.walls[key] = walls[key]
	return clone
