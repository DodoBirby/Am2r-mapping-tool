extends TileMap

#region Atlas coord constants
const BASEBLUE = Vector2i(0, 0)
const BASECYAN = Vector2i(1, 0)
const BASEGREEN = Vector2i(2, 0)
const BASEPURPLE = Vector2i(3, 0)
const CORNERTL = Vector2i(0, 1)
const CORNERBL = Vector2i(1, 1)
const CORNERTR = Vector2i(2, 1)
const CORNERBR = Vector2i(3, 1)
const PIPEH = Vector2i(0, 2)
const ELEVATOR = Vector2i(1, 2)
const BLUEPIPEH = Vector2i(2, 2)
const BLUEPIPEV = Vector2i(3, 2)
const CYANPIPEH = Vector2i(4, 2)
const CYANPIPEV = Vector2i(5, 2)
const GREENPIPEH = Vector2i(0, 3)
const GREENPIPEV = Vector2i(1, 3)
const BLUEDIAGTL = Vector2i(2, 3)
const BLUEDIAGTR = Vector2i(3, 3)
const BLUEDIAGBL = Vector2i(2, 4)
const BLUEDIAGBR = Vector2i(3, 4)
const CYANDIAGTL = Vector2i(4, 3)
const CYANDIAGTR = Vector2i(5, 3)
const CYANDIAGBL = Vector2i(4, 4)
const CYANDIAGBR = Vector2i(5, 4)
const GREENDIAGTL = Vector2i(6, 3)
const GREENDIAGTR = Vector2i(7, 3)
const GREENDIAGBL = Vector2i(6, 4)
const GREENDIAGBR = Vector2i(7, 4)
const BLUEROUNDTL = Vector2i(2, 5)
const BLUEROUNDTR = Vector2i(3, 5)
const BLUEROUNDBL = Vector2i(2, 6)
const BLUEROUNDBR = Vector2i(3, 6)
const CYANROUNDTL = Vector2i(4, 5)
const CYANROUNDTR = Vector2i(5, 5)
const CYANROUNDBL = Vector2i(4, 6)
const CYANROUNDBR =  Vector2i(5, 6)
const WALLD = Vector2i(6, 5)
const WALLU = Vector2i(7, 5)
const WALLL = Vector2i(8, 5)
const WALLR = Vector2i(9, 5)
const DOORD = Vector2i(6, 6)
const DOORU = Vector2i(7, 6)
const DOORL = Vector2i(8, 6)
const DOORR = Vector2i(9, 6)
const SAVE = Vector2i(0, 4)
const RECHARGE = Vector2i(1, 4)
const ITEM = Vector2i(0, 5)
const MAJOR = Vector2i(1, 5)
const SHIP = Vector2i(0, 6)
const ARROWUP = Vector2i(2, 7)
const ARROWDOWN = Vector2i(3, 7)
const ARROWLEFT = Vector2i(4, 7)
const ARROWRIGHT = Vector2i(5, 7)
#endregion

var dirs = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]

enum LAYERS {BACKGROUND, BASE, CORNERTL, CORNERTR, CORNERBR, CORNERBL, WALLD, WALLU, WALLL, WALLR, SPECIAL}

var model = {}

func get_hovered_cell():
	return snap_coords_to_grid(get_global_mouse_position())

func snap_coords_to_grid(pos: Vector2) -> Vector2:
	var grid_size = 8
	var x_coord = floor(pos.x / grid_size)
	var y_coord = floor(pos.y / grid_size)
	return Vector2(x_coord, y_coord)
	
func grid_coord_to_map_coord(pos: Vector2) -> Vector2:
	var grid_size = 8
	var x_coord = pos.x * grid_size
	var y_coord = pos.y * grid_size
	return Vector2(x_coord, y_coord)

func get_neighbours(pos: Vector2) -> Array[Vector2]:
	var neighbours = [] as Array[Vector2]
	for x in range(-1, 2):
		for y in range(-1, 2):
			if x == 0 and y == 0:
				continue
			neighbours.append(Vector2(pos.x + x, pos.y + y))
	return neighbours

func is_drawable(pos: Vector2):
	return get_cell_source_id(LAYERS.BACKGROUND, pos) != -1

func set_special(pos: Vector2, special: int):
	var am2rmaptile = model.get(pos) as AM2RMapTile
	if am2rmaptile == null:
		return
	am2rmaptile.special = special
	draw_mapblock(pos)

func convert_corner_tile_to_atlas_coords(corner: CornerTile):
	if corner.corner_type == GlobalSettings.CORNER_TYPES.DIAG:
		var x_coord = corner.color * 2 + 2
		var y_coord = 3
		match corner.rotation:
			Vector2.LEFT:
				x_coord += 1
				y_coord += 1
			Vector2.UP:
				y_coord += 1
			Vector2.DOWN:
				x_coord += 1
		return Vector2i(x_coord, y_coord)
	if corner.corner_type == GlobalSettings.CORNER_TYPES.ROUND:
		var x_coord = corner.color * 2 + 2
		var y_coord = 5
		match corner.rotation:
			Vector2.LEFT:
				x_coord += 1
				y_coord += 1
			Vector2.UP:
				y_coord += 1
			Vector2.DOWN:
				x_coord += 1
		return Vector2i(x_coord, y_coord)

func draw_mapblock(pos: Vector2):
	var maptile = model.get(pos)
	for i in range(LAYERS.BASE, LAYERS.SPECIAL + 1):
		erase_cell(i, pos)
	if maptile == null:
		return
	var am2rmaptile = maptile as AM2RMapTile
	for i in range(LAYERS.BASE, LAYERS.SPECIAL + 1):
		erase_cell(i, pos)
	if am2rmaptile is CornerTile:
		set_cell(LAYERS.CORNERBL, pos, 1, convert_corner_tile_to_atlas_coords(am2rmaptile))
	else:
		match am2rmaptile.color:
			GlobalSettings.COLORS.BLUE:
				set_cell(LAYERS.BASE, pos, 1, BASEBLUE)
			GlobalSettings.COLORS.CYAN:
				set_cell(LAYERS.BASE, pos, 1, BASECYAN)
			GlobalSettings.COLORS.GREEN:
				set_cell(LAYERS.BASE, pos, 1, BASEGREEN)
			GlobalSettings.COLORS.PURPLE:
				set_cell(LAYERS.BASE, pos, 1, BASEPURPLE)
		if am2rmaptile.corner < 16:
			if am2rmaptile.corner & 1:
				set_cell(LAYERS.CORNERBL, pos, 1, CORNERBL)
			if am2rmaptile.corner & 2:
				set_cell(LAYERS.CORNERBR, pos, 1, CORNERBR)
			if am2rmaptile.corner & 4:
				set_cell(LAYERS.CORNERTL, pos, 1, CORNERTL)
			if am2rmaptile.corner & 8:
				set_cell(LAYERS.CORNERTR, pos, 1, CORNERTR)
		match am2rmaptile.corner:
			16:
				set_cell(LAYERS.CORNERBL, pos, 1, PIPEH)
			17:
				set_cell(LAYERS.CORNERBL, pos, 1, ELEVATOR)
			18:
				set_cell(LAYERS.CORNERBL, pos, 1, BLUEPIPEH)
			19:
				set_cell(LAYERS.CORNERBL, pos, 1, BLUEPIPEV)
			20:
				set_cell(LAYERS.CORNERBL, pos, 1, CYANPIPEH)
			21:
				set_cell(LAYERS.CORNERBL, pos, 1, CYANPIPEV)
			22:
				set_cell(LAYERS.CORNERBL, pos, 1, GREENPIPEH)
			23:
				set_cell(LAYERS.CORNERBL, pos, 1, GREENPIPEV)
	for dir in dirs:
		var wall = am2rmaptile.walls.get(dir)
		var offset = convert_dir_to_offset(dir)
		var layer = LAYERS.WALLD + offset
		var atlas_coord = WALLD + Vector2i.RIGHT * offset
		if wall == 2:
			atlas_coord.y += 1
		if wall:
			set_cell(layer, pos, 1, atlas_coord)
	match am2rmaptile.special:
		1:
			set_cell(LAYERS.SPECIAL, pos, 1, SAVE)
		2:
			set_cell(LAYERS.SPECIAL, pos, 1, RECHARGE)
		3:
			set_cell(LAYERS.SPECIAL, pos, 1, ITEM)
		4:
			set_cell(LAYERS.SPECIAL, pos, 1, MAJOR)
		5:
			set_cell(LAYERS.SPECIAL, pos, 1, SHIP)
		6:
			set_cell(LAYERS.SPECIAL, pos, 1, ARROWUP)
		7:
			set_cell(LAYERS.SPECIAL, pos, 1, ARROWDOWN)
		8:
			set_cell(LAYERS.SPECIAL, pos, 1, ARROWLEFT)
		9:
			set_cell(LAYERS.SPECIAL, pos, 1, ARROWRIGHT)
		
func corners_empty(pos: Vector2):
	var am2rmaptile = model.get(pos)
	if am2rmaptile == null:
		return true
	return am2rmaptile.corner == 0

func set_corner(pos: Vector2, corner: int):
	var am2rmaptile = model.get(pos)
	if am2rmaptile == null:
		model[pos] = AM2RMapTile.new()
		am2rmaptile = model[pos]
	if am2rmaptile.corner != 0 and am2rmaptile.corner < 16:
		return
	am2rmaptile.corner = corner + 15
	draw_mapblock(pos)
	 
func create_corner_tile(pos: Vector2, color: int):
	if color == GlobalSettings.COLORS.PURPLE:
		color = 0
	var am2rmaptile = model.get(pos)
	if am2rmaptile is AM2RMapTile:
		return
	if am2rmaptile == null:
		model[pos] = CornerTile.new()
		am2rmaptile = model[pos]
	am2rmaptile.color = color
	draw_mapblock(pos)

func rotate_corner_tile(pos: Vector2):
	var cornertile = model.get(pos)
	if not cornertile is CornerTile:
		return
	cornertile.rotation = cornertile.rotation.rotated(PI / 2).round()
	draw_mapblock(pos)
	
func change_corner_type(pos: Vector2):
	var cornertile = model.get(pos)
	if not cornertile is CornerTile:
		return
	if cornertile.corner_type == GlobalSettings.CORNER_TYPES.DIAG:
		if cornertile.color == GlobalSettings.COLORS.GREEN:
			return
		cornertile.corner_type = GlobalSettings.CORNER_TYPES.ROUND
	elif cornertile.corner_type == GlobalSettings.CORNER_TYPES.ROUND:
		cornertile.corner_type = GlobalSettings.CORNER_TYPES.DIAG
	draw_mapblock(pos)
	
func convert_dir_to_offset(dir: Vector2):
	match dir:
		Vector2.DOWN:
			return 0
		Vector2.UP:
			return 1
		Vector2.LEFT:
			return 2
		Vector2.RIGHT:
			return 3
	return -1
	
func set_tile(pos: Vector2, color: int, wallU: int, wallD: int, wallL: int, wallR: int):
	var am2rmaptile = model.get(pos)
	if am2rmaptile != null:
		return
	var newtile = AM2RMapTile.new()
	model[pos] = newtile
	newtile.color = color
	set_wall_in_dir(pos, Vector2.UP, wallU)
	set_wall_in_dir(pos, Vector2.DOWN, wallD)
	set_wall_in_dir(pos, Vector2.RIGHT, wallR)
	set_wall_in_dir(pos, Vector2.LEFT, wallL)
	draw_mapblock(pos)

func set_wall_in_dir(pos: Vector2, dir: Vector2, wall: int):
	var am2rmaptile = model.get(pos)
	if am2rmaptile == null:
		return
	am2rmaptile.set_wall_in_dir(dir, wall)
	update_neighbour_tiles(pos)
	draw_mapblock(pos)

func get_wall_in_dir(pos: Vector2, dir: Vector2):
	var am2rmaptile = model.get(pos)
	if am2rmaptile == null:
		return 0
	return am2rmaptile.get_wall_in_dir(dir)

func get_wall_in_dir_for_corner_check(pos: Vector2, dir: Vector2):
	var am2rmaptile = model.get(pos)
	if am2rmaptile == null:
		return 0
	return am2rmaptile.get_wall_in_dir_for_corners(dir)
	
func clear_cell(pos: Vector2):
	model.erase(pos)
	for neighbour in get_neighbours(pos):
		var dir = pos - neighbour
		if dir.length_squared() != 1:
			continue
		if tile_base_exists(neighbour):
			set_wall_in_dir(neighbour, dir, 1)
	draw_mapblock(pos)
	update_neighbour_tiles(pos)

func tile_base_exists(pos: Vector2):
	var am2rmaptile = model.get(pos)
	if am2rmaptile == null:
		return false
	if am2rmaptile is CornerTile:
		return true
	return am2rmaptile.color != -1

func should_have_corner(pos: Vector2, dir: Vector2):
	var dir1 = Vector2(dir.x, 0)
	var dir2 = Vector2(0, dir.y)
	var cell1 = get_wall_in_dir_for_corner_check(pos + dir1, dir2) != 0
	var cell2 = get_wall_in_dir_for_corner_check(pos + dir2, dir1) != 0
	var wall1 = get_wall_in_dir(pos, dir1) == 0
	var wall2 = get_wall_in_dir(pos, dir2) == 0
	return cell1 and cell2 and wall1 and wall2
	
func update_tile_corners(pos: Vector2):
	var am2rmaptile = model.get(pos)
	if am2rmaptile == null or am2rmaptile is CornerTile:
		return
	if am2rmaptile.corner >= 16:
		return
	var bits = 0
	if should_have_corner(pos, Vector2(1, 1)):
		bits += 2
	if should_have_corner(pos, Vector2(-1, 1)):
		bits += 1
	if should_have_corner(pos, Vector2(-1, -1)):
		bits += 4
	if should_have_corner(pos, Vector2i(1, -1)):
		bits += 8
	am2rmaptile.corner = bits
	draw_mapblock(pos)

func update_neighbour_tiles(pos: Vector2):
	update_tile_corners(pos)
	for neighbour in get_neighbours(pos):
		update_tile_corners(neighbour)
		
func move_area(selected_area: Rect2i, movement: Vector2):
	var dest_rect = Rect2(selected_area)
	dest_rect.position += movement
	# Check if destination has tiles or is out of bounds
	for x in range(dest_rect.position.x, dest_rect.end.x):
		for y in range(dest_rect.position.y, dest_rect.end.y):
			if !is_drawable(Vector2(x, y)):
				return
			if model.has(Vector2(x, y)) and !selected_area.has_point(Vector2(x, y)):
				return
	var tiles_to_move = {}
	for x in range(selected_area.position.x, selected_area.end.x):
		for y in range(selected_area.position.y, selected_area.end.y):
			if model.has(Vector2(x, y)):
				tiles_to_move[Vector2(x, y)] = model[Vector2(x, y)]
	for key in tiles_to_move.keys():
		model.erase(key)
		draw_mapblock(key)
	for key in tiles_to_move.keys():
		model[key + movement] = tiles_to_move[key]
		draw_mapblock(key + movement)

func export_map_init():
	var str = "# Copy this section into init_map\n"
	for k in model.keys():
		str += ("global.map[%s, %s] = \"" % [k.x, k.y]) + model[k].convert_to_map_init_string() + '"\n'
	str += "--------\n# Copy this section into draw_surface_map\n"
	for k in model.keys():
		str += ("draw_map_surf(%s, %s)" % [k.x, k.y]) + '\n'
	return str



func save(path: String):
	var save_list = []
	for k in model.keys():
		var maptile_dict = {}
		maptile_dict["x"] = k.x
		maptile_dict["y"] = k.y
		maptile_dict["isCorner"] = model[k] is CornerTile
		if model[k] is CornerTile:
			maptile_dict["corner_type"] = model[k].corner_type
			maptile_dict["rotation_x"] = model[k].rotation.x
			maptile_dict["rotation_y"] = model[k].rotation.y
		maptile_dict["corner"] = model[k].corner
		maptile_dict["color"] = model[k].color
		maptile_dict["special"] = model[k].special
		maptile_dict["wallU"] = model[k].walls[Vector2.UP]
		maptile_dict["wallD"] = model[k].walls[Vector2.DOWN]
		maptile_dict["wallL"] = model[k].walls[Vector2.LEFT]
		maptile_dict["wallR"] = model[k].walls[Vector2.RIGHT]
		save_list.append(maptile_dict)
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(save_list))
	file.close()

func load_file(path: String):
	var file = FileAccess.open(path, FileAccess.READ)
	var save_list = JSON.parse_string(file.get_as_text())
	for k in model.keys():
		model.erase(k)
		draw_mapblock(k)
	for maptile in save_list:
		var x = int(maptile["x"])
		var y = int(maptile["y"])
		var isCorner = maptile["isCorner"]
		var am2rtiledata
		if isCorner:
			am2rtiledata = CornerTile.new()
			am2rtiledata.corner_type = int(maptile["corner_type"])
			am2rtiledata.rotation.x = int(maptile["rotation_x"])
			am2rtiledata.rotation.y = int(maptile["rotation_y"])
		else:
			am2rtiledata = AM2RMapTile.new()
		am2rtiledata.corner = int(maptile["corner"])
		am2rtiledata.color = int(maptile["color"])
		am2rtiledata.special = int(maptile["special"])
		am2rtiledata.walls[Vector2.UP] = maptile["wallU"]
		am2rtiledata.walls[Vector2.DOWN] = maptile["wallD"]
		am2rtiledata.walls[Vector2.LEFT] = maptile["wallL"]
		am2rtiledata.walls[Vector2.RIGHT] = maptile["wallR"]
		model[Vector2(x, y)] = am2rtiledata
		draw_mapblock(Vector2(x, y))
	file.close()
			
		
		
