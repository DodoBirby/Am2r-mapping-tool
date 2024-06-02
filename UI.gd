extends CanvasLayer
@onready var map_coords = %MapCoords
@onready var main_list = %MainList
@onready var colors_list = %ColorsList
@onready var specials_menu = %SpecialsMenu
@onready var corners_menu = %CornersMenu
@onready var corner_tiles = %CornerTiles
@onready var colors = %Colors
@onready var specials = %Specials
@onready var corners = %Corners
@onready var loaded_file = %LoadedFile

const SAVE = Vector2i(0, 4)
const RECHARGE = Vector2i(1, 4)
const ITEM = Vector2i(0, 5)
const MAJOR = Vector2i(1, 5)
const SHIP = Vector2i(0, 6)
const ARROWUP = Vector2i(2, 7)
const ARROWDOWN = Vector2i(3, 7)
const ARROWLEFT = Vector2i(4, 7)
const ARROWRIGHT = Vector2i(5, 7)
const PIPEH = Vector2i(0, 2)
const ELEVATOR = Vector2i(1, 2)
const BLUEPIPEH = Vector2i(2, 2)
const BLUEPIPEV = Vector2i(3, 2)
const CYANPIPEH = Vector2i(4, 2)
const CYANPIPEV = Vector2i(5, 2)
const GREENPIPEH = Vector2i(0, 3)
const GREENPIPEV = Vector2i(1, 3)

var corner_list = [PIPEH, ELEVATOR, BLUEPIPEH, BLUEPIPEV, CYANPIPEH, CYANPIPEV, GREENPIPEH, GREENPIPEV]

var special_list = [SAVE, RECHARGE, ITEM, MAJOR, SHIP, ARROWUP, ARROWDOWN, ARROWLEFT, ARROWRIGHT]

signal changed_corner_mode(value)
signal changed_selected_color(value)
signal changed_special_selection(value)
signal changed_corner_selection(value)
signal save_pressed
signal saveas_pressed
signal load_pressed
signal export_pressed

var selected_special = 0:
	set(value):
		emit_signal("changed_special_selection", value)
		selected_special = value
		if value == 0:
			specials.self_modulate = Color(1, 1, 1, 0.5)
			specials.texture.region.position = Vector2(SAVE) * 8
		else:
			corner_mode = false
			selected_corner = 0
			specials.self_modulate = Color(1, 1, 1, 1)
			var coords = special_list[value - 1]
			specials.texture.region.position = Vector2(coords) * 8

var selected_color = 0:
	set(value):
		selected_special = 0
		selected_corner = 0
		selected_color = value
		emit_signal("changed_selected_color", value)
		colors.texture.region.position.x = value * 8

var selected_corner = 0:
	set(value):
		selected_corner = value
		emit_signal("changed_corner_selection", value)
		if value == 0:
			corners.self_modulate = Color(1, 1, 1, 0.5)
			corners.texture.region.position = Vector2(PIPEH) * 8
		else:
			corner_mode = false
			selected_special = 0
			corners.self_modulate = Color(1, 1, 1, 1)
			var coords = corner_list[value - 1]
			corners.texture.region.position = Vector2(coords) * 8
		

var corner_mode: bool:
	set(value):
		corner_mode = value
		emit_signal("changed_corner_mode", value)
		if value:
			selected_special = 0
			selected_corner = 0
			corner_tiles.self_modulate = Color(1, 1, 1, 1)
		else:
			corner_tiles.self_modulate = Color(1, 1, 1, 0.5)

func _input(event: InputEvent):
	if event.is_action_pressed("SelectCornerTile"):
		corner_mode = !corner_mode
	elif event.is_action_pressed("Color1"):
		selected_color = 0
	elif event.is_action_pressed("Color2"):
		selected_color = 1
	elif event.is_action_pressed("Color3"):
		selected_color = 2
	elif event.is_action_pressed("Color4"):
		selected_color = 3
	elif event.is_action_pressed("SelectSpecial"):
		selected_special = (selected_special + 1) % 10
	elif event.is_action_pressed("SelectCorner"):
		selected_corner = (selected_corner + 1) % 9
	elif event.is_action_pressed("DisableAllSpecial"):
		selected_corner = 0
		selected_special = 0
		corner_mode = false

func _ready():
	corner_mode = false
	selected_special = 0
	selected_corner = 0

func update_coords(pos: Vector2):
	map_coords.text = "(%s, %s)" % [pos.x, pos.y]

func update_file_path(path: String):
	loaded_file.text = "Currently loaded file: \n%s" % path

func _on_colors_gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			main_list.hide()
			colors_list.show()


func _on_blue_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			selected_color = 0
			colors_list.hide()
			main_list.show()


func _on_cyan_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			selected_color = 1
			colors_list.hide()
			main_list.show()


func _on_green_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			selected_color = 2
			colors_list.hide()
			main_list.show()


func _on_purple_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			selected_color = 3
			colors_list.hide()
			main_list.show()
			


func _on_specials_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			specials_menu.show()
			main_list.hide()

func _on_save_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			selected_special = 1
			specials_menu.hide()
			main_list.show()


func _on_recharge_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			selected_special = 2
			specials_menu.hide()
			main_list.show()


func _on_item_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			selected_special = 3
			specials_menu.hide()
			main_list.show()

func _on_major_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			selected_special = 4
			specials_menu.hide()
			main_list.show()

func _on_ship_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			selected_special = 5
			specials_menu.hide()
			main_list.show()

func _on_up_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			selected_special = 6
			specials_menu.hide()
			main_list.show()


func _on_down_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			selected_special = 7
			specials_menu.hide()
			main_list.show()


func _on_left_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			selected_special = 8
			specials_menu.hide()
			main_list.show()


func _on_right_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			selected_special = 9
			specials_menu.hide()
			main_list.show()


func _on_pipe_h_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			selected_corner = 1
			corners_menu.hide()
			main_list.show()

func _on_elevator_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			selected_corner = 2
			corners_menu.hide()
			main_list.show()


func _on_blue_pipe_h_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			selected_corner = 3
			corners_menu.hide()
			main_list.show()


func _on_blue_pipe_v_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			selected_corner = 4
			corners_menu.hide()
			main_list.show()


func _on_cyan_pipe_h_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			selected_corner = 5
			corners_menu.hide()
			main_list.show()


func _on_cyan_pipe_v_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			selected_corner = 6
			corners_menu.hide()
			main_list.show()


func _on_green_pipe_h_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			selected_corner = 7
			corners_menu.hide()
			main_list.show()


func _on_green_pipe_v_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			selected_corner = 8
			corners_menu.hide()
			main_list.show()


func _on_corners_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			corners_menu.show()
			main_list.hide()


func _on_corner_tiles_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			corner_mode = !corner_mode

func _on_save_pressed():
	emit_signal("save_pressed")

func _on_save_as_pressed():
	emit_signal("saveas_pressed")

func _on_load_pressed():
	emit_signal("load_pressed")

func _on_export_pressed():
	emit_signal("export_pressed")
