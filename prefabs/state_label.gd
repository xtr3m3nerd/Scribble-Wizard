extends Label3D


func _on_state_changed(_current_state, new_state):
	text = new_state.state_name
