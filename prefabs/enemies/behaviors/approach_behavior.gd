class_name ApproachBehavior
extends Behavior

func check_for_transition():
	if unit.dead:
		change_state("DEAD")
	
	match current_state.state_name:
		"STUNNED":
			return
		"IDLE":
			chase_if_player_seen()
		"ROAM":
			chase_if_player_seen()

func chase_if_player_seen():
	if is_player_seen:
		change_state("CHASE")
	
func _on_state_idle_idle_timeout():
	change_state("ROAM")


func _on_state_roam_roam_timeout():
	change_state("IDLE")


func _on_state_chase_unseen_timeout():
	change_state("IDLE")

func _on_state_stunned_stunned_timeout():
	change_state("IDLE")
