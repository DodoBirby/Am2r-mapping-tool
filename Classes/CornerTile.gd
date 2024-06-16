class_name CornerTile
extends AM2RMapTile

var rotation:
	set(value):
		var prev_state = clone()
		_rotation = value
		fix_walls()
		var new_state = clone()
		if UndoManager.recording_undo:
			UndoManager.record_mutation_in_undo_frame(prev_state, new_state, coordinates)
	get:
		return _rotation
var _rotation = Vector2.RIGHT
	
var corner_type:
	set(value):
		var prev_state = clone()
		_corner_type = value
		var new_state = clone()
		if UndoManager.recording_undo:
			UndoManager.record_mutation_in_undo_frame(prev_state, new_state, coordinates)
	get:
		return _corner_type
var _corner_type = GlobalSettings.CORNER_TYPES.DIAG
			
var dirs = [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]

func get_wall_in_dir_for_corners(dir: Vector2):
	var rotated_rot = rotation.rotated(PI / 2).round()
	if dir != rotation and dir != rotated_rot:
		return 1
	return walls[dir]

func fix_walls():
	for k in walls.keys():
		var rotated_rot = rotation.rotated(PI / 2).round()
		if k != rotation and k != rotated_rot:
			walls[k] = 0

func set_wall_in_dir(dir: Vector2, wall: int):
	var rotated_rot = rotation.rotated(PI / 2).round()
	if dir != rotation and dir != rotated_rot:
		return
	var prev_state = clone()
	walls[dir] = wall
	var new_state = clone()
	if UndoManager.recording_undo:
		UndoManager.record_mutation_in_undo_frame(prev_state, new_state, coordinates)
	
func convert_to_map_init_string():
	var str = "%s%s%s%s" % [walls[Vector2.UP], walls[Vector2.RIGHT], walls[Vector2.DOWN], walls[Vector2.LEFT]]
	str += "0"
	str += convert_special_to_init_string()
	str += GlobalSettings.corner_tile_list[dirs.find(rotation) + color * 4 + corner_type * 12]
	return str

func clone():
	var clone = CornerTile.new(coordinates)
	clone._corner = corner
	clone._color = color
	clone._special = special
	clone._corner_type = corner_type
	for key in clone.walls.keys():
		clone.walls[key] = walls[key]
	clone._rotation = rotation
	return clone
