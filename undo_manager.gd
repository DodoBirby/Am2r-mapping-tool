extends Node

var undo_stack: Array[UndoFrame] = []
var recording_undo = false
var current_undo_frame = -1

#TODO: We can optimise this significantly by only recording new_state once the undoable_action ends
# Right now we're recording mutations every time they happen

# Returns false if an undoable action was already in progress, if that is the case then the action should be stopped
func start_undoable_action():
	if recording_undo:
		return false
	recording_undo = true
	while can_redo():
		undo_stack.pop_back()
	undo_stack.append(UndoFrame.new())
	current_undo_frame += 1
	return true
	
func end_undoable_action():
	assert(recording_undo == true)
	recording_undo = false
	
func record_mutation_in_undo_frame(prev_state, new_state, coordinates: Vector2):
	var undo_frame = undo_stack[current_undo_frame]
	undo_frame.add_state_to_frame(prev_state, new_state, coordinates)

func can_undo():
	return current_undo_frame > -1

func can_redo():
	return current_undo_frame + 1 < len(undo_stack)

func undo() -> Dictionary:
	assert(can_undo())
	current_undo_frame -= 1
	return undo_stack[current_undo_frame + 1].prev_tiles

func redo() -> Dictionary:
	assert(can_redo())
	current_undo_frame += 1
	return undo_stack[current_undo_frame].new_tiles
