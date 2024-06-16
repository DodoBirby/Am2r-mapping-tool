extends Node2D
@onready var map_camera = %MapCamera
@onready var cursor = %Cursor
@onready var tile_map = %TileMap
@onready var back_rect = %BackRect
@onready var ui = %UI
@onready var save_dialog = %SaveDialog
@onready var load_dialog = %LoadDialog
@onready var export_dialog = %ExportDialog


const MOVESPEED = 400
const MINZOOM = 1
const MAXZOOM = 6

var map_zoom = 1

var prev_click_coord = Vector2.ZERO

var selected_color = 0

var middle_click_dragging = false
var left_click_dragging = false
var right_click_dragging = false
var wall_type = 0
var wall_place_start_pos = Vector2.ZERO
var area_selecting = false
var area_select_start = Vector2.ZERO
var area_selected: Rect2i
var is_area_selected = false
var is_moving_area = false
var move_area_start = Vector2.ZERO

var corner_mode = false
var selected_special = 0
var selected_corner = 0

var prev_save_path = "":
	set(value):
		prev_save_path = value
		ui.update_file_path(value)

func _ready():
	back_rect.show()
	
func _process(delta):
	queue_redraw()
	cursor.self_modulate = Color(1, 0, 0) if wall_type else Color(1, 1, 1)
	var mousepos = tile_map.get_hovered_cell()
	ui.update_coords(mousepos)
	cursor.global_position = tile_map.grid_coord_to_map_coord(mousepos)
	if Input.is_action_pressed("MouseClick") and left_click_dragging:
		drag_tile(mousepos)
	elif Input.is_action_pressed("Erase") and right_click_dragging:
		erase_tile(mousepos)
	if wall_type:
		wall_placement(mousepos)
	if Input.is_action_just_pressed("RotateCorner"):
		tile_map.rotate_corner_tile(mousepos)
	if Input.is_action_just_pressed("ChangeCornerType"):
		tile_map.change_corner_type(mousepos)
	if !Input.is_action_pressed("CreateDoor") and wall_type == 2:
		wall_type = 0
	if !Input.is_action_pressed("CreateWall") and wall_type == 1:
		wall_type = 0
	if !Input.is_action_pressed("MiddleClick"):
		middle_click_dragging = false
	if !Input.is_action_pressed("MouseClick"):
		if left_click_dragging:
			UndoManager.end_undoable_action()
			left_click_dragging = false
		if area_selecting:
			area_selecting = false
			select_area(area_select_start, mousepos)
		if is_moving_area:
			is_moving_area = false
			is_area_selected = false
			tile_map.move_area(area_selected, tile_map.get_hovered_cell() - move_area_start)
	if !Input.is_action_pressed("Erase"):
		if right_click_dragging:
			right_click_dragging = false
			UndoManager.end_undoable_action()
	move_camera(delta)

#TODO: Clean up
func _draw():
	var selected_rect = Rect2(area_selected.position * 8, area_selected.size * 8)
	if is_area_selected:
		draw_rect(selected_rect, Color.RED, false, 1)
	var mousepos = tile_map.get_hovered_cell()
	if area_selecting and mousepos.x >= area_select_start.x and mousepos.y >= area_select_start.y:
		draw_rect(Rect2(area_select_start * 8, (Vector2.ONE + tile_map.get_hovered_cell() - area_select_start) * 8), Color.RED, false, 1)
	if is_moving_area:
		var moved_rect = Rect2(selected_rect)
		moved_rect.position += (tile_map.get_hovered_cell() - move_area_start) * 8
		draw_rect(moved_rect, Color.BLUE, false, 1)

func select_area(start: Vector2, end: Vector2):
	if start.x > end.x or start.y > end.y:
		return
	area_selected = Rect2(start.x, start.y, end.x - start.x + 1, end.y - start.y + 1)
	is_area_selected = true

func move_camera(delta):
	var zoom_speed_mod = 1.0 / map_zoom
	if Input.is_action_pressed("CamUp"):
		map_camera.position += Vector2.UP * MOVESPEED * zoom_speed_mod * delta
	if Input.is_action_pressed("CamDown"):
		map_camera.position += Vector2.DOWN * MOVESPEED * zoom_speed_mod * delta
	if Input.is_action_pressed("CamLeft"):
		map_camera.position += Vector2.LEFT * MOVESPEED * zoom_speed_mod * delta
	if Input.is_action_pressed("CamRight"):
		map_camera.position += Vector2.RIGHT * MOVESPEED * zoom_speed_mod * delta

func wall_placement(mousepos: Vector2):
	
	var dir = mousepos - wall_place_start_pos
	var wall_to_place = wall_type
	var length = dir.length()
	if length == 0:
		return
	wall_type = 0
	if length != 1:
		return
	var is_valid = tile_map.tile_base_exists(wall_place_start_pos)
	if is_valid:
		if !UndoManager.start_undoable_action():
			return
	if tile_map.tile_base_exists(wall_place_start_pos):
		tile_map.set_wall_in_dir(wall_place_start_pos, dir, wall_to_place)
	if tile_map.tile_base_exists(mousepos) and tile_map.get_wall_in_dir(mousepos, dir * -1) == 0:
		tile_map.set_wall_in_dir(mousepos, dir * -1, 1)
	if is_valid:
		UndoManager.end_undoable_action()
		
func click_tile(pos: Vector2):
	if !tile_map.is_drawable(pos):
		return
	prev_click_coord = pos
	if selected_corner:
		tile_map.set_corner(pos, selected_corner)
		return
	if selected_special:
		tile_map.set_special(pos, selected_special)
		return
	if tile_map.tile_base_exists(pos):
		return
	if corner_mode:
		tile_map.create_corner_tile(pos, selected_color)
	else:
		tile_map.set_tile(pos, selected_color, 1, 1, 1, 1)

func drag_tile(pos: Vector2):
	if !tile_map.is_drawable(pos):
		return
	if prev_click_coord == pos:
		return
	var dir = pos - prev_click_coord
	if dir.length_squared() != 1:
		click_tile(pos)
		return
	tile_map.set_wall_in_dir(prev_click_coord, dir, 0)
	click_tile(pos)
	tile_map.set_wall_in_dir(pos, dir * -1, 0)

func click_in_selected_area():
	return is_area_selected and area_selected.has_point(tile_map.get_hovered_cell())

func erase_tile(pos: Vector2):
	tile_map.clear_cell(pos)
	
func _unhandled_input(event):
	if event is InputEventMouseMotion and middle_click_dragging:
		map_camera.position -= event.relative / map_zoom
	if event.is_action_pressed("ZoomIn"):
		map_zoom += 1
		map_zoom = clamp(map_zoom, MINZOOM, MAXZOOM)
		map_camera.zoom = Vector2(map_zoom, map_zoom)
	elif event.is_action_pressed("ZoomOut"):
		map_zoom -= 1
		map_zoom = clamp(map_zoom, MINZOOM, MAXZOOM)
		map_camera.zoom = Vector2(map_zoom, map_zoom)
	elif event.is_action_pressed("MiddleClick"):
		middle_click_dragging = true
	elif event.is_action_pressed("MouseClick"):
		if Input.is_action_pressed("DragClick"):
			area_selecting = true
			area_select_start = tile_map.get_hovered_cell()
		else:
			if click_in_selected_area():
				is_moving_area = true
				move_area_start = tile_map.get_hovered_cell()
				return
			if !UndoManager.start_undoable_action():
				return
			click_tile(tile_map.get_hovered_cell())
			left_click_dragging = true
	elif event.is_action_pressed("Export"):
		export_dialog.show()
	elif event.is_action_pressed("Save"):
		save()
	elif event.is_action_pressed("Open"):
		load_dialog.show()
	elif event.is_action_pressed("CreateDoor"):
		wall_place_start_pos = tile_map.get_hovered_cell()
		wall_type = 2
	elif event.is_action_pressed("CreateWall"):
		wall_place_start_pos = tile_map.get_hovered_cell()
		wall_type = 1
	elif event.is_action_pressed("DragClick"):
		is_area_selected = false
	elif event.is_action_pressed("Undo"):
		tile_map.undo()
	elif event.is_action_pressed("Redo"):
		tile_map.redo()
	elif event.is_action_pressed("Erase"):
		if !UndoManager.start_undoable_action():
			return
		right_click_dragging = true
		erase_tile(tile_map.get_hovered_cell())

func save():
	if prev_save_path != "":
		tile_map.save(prev_save_path)
	else:
		save_dialog.show()

func _on_save_dialog_file_selected(path):
	tile_map.save(path)
	prev_save_path = path

func _on_load_dialog_file_selected(path):
	tile_map.load_file(path)
	prev_save_path = path

func _on_export_dialog_file_selected(path):
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(tile_map.export_map_init())
	file.close()

func _on_ui_changed_corner_mode(value):
	corner_mode = value

func _on_ui_changed_selected_color(value):
	selected_color = value

func _on_ui_changed_special_selection(value):
	selected_special = value

func _on_ui_changed_corner_selection(value):
	selected_corner = value

func _on_ui_export_pressed():
	export_dialog.show()

func _on_ui_load_pressed():
	load_dialog.show()

func _on_ui_save_pressed():
	save()

func _on_ui_saveas_pressed():
	save_dialog.show()
