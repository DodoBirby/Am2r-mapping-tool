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
var wall_type = 0
var wall_place_start_pos = Vector2.ZERO

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
	cursor.self_modulate = Color(1, 0, 0) if wall_type else Color(1, 1, 1)
	var mousepos = tile_map.get_hovered_cell()
	ui.update_coords(mousepos)
	cursor.global_position = tile_map.grid_coord_to_map_coord(mousepos)
	if Input.is_action_pressed("MouseClick") and left_click_dragging:
		drag_tile(mousepos)
	elif Input.is_action_pressed("Erase"):
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
		left_click_dragging = false
	move_camera(delta)

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
	if tile_map.tile_base_exists(wall_place_start_pos):
		tile_map.set_wall_in_dir(wall_place_start_pos, dir, wall_to_place)
	if tile_map.tile_base_exists(mousepos) and tile_map.get_wall_in_dir(mousepos, dir * -1) == 0:
		tile_map.set_wall_in_dir(mousepos, dir * -1, 1)

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