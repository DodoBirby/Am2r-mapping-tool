class_name UndoFrame
extends RefCounted

var prev_tiles = {}
var new_tiles = {}

func add_state_to_frame(prev_state, new_state, coordinates: Vector2):
	if !prev_tiles.has(coordinates):
		prev_tiles[coordinates] = prev_state
	new_tiles[coordinates] = new_state
