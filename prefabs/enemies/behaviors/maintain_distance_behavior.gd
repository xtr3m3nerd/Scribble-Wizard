class_name MaintainDistanceBehavior
extends Behavior

@export var close_dist = 5.0
@export var far_dist = 10.0

func check_for_transition():
	if unit.dead:
		change_state("DEAD")
	
	match current_state.state_name:
		"IDLE":
			maintain_dist()
		"ROAM":
			maintain_dist()
		"CHASE":
			if dist_to_player < far_dist:
				change_state("IDLE")
		"RUN_AWAY":
			if dist_to_player > close_dist:
				change_state("IDLE")
				

func maintain_dist():
	if is_player_seen:
		if dist_to_player > far_dist:
			change_state("CHASE")
		if dist_to_player < close_dist:
			change_state("RUN_AWAY")
	
func _on_state_idle_idle_timeout():
	change_state("ROAM")


func _on_state_roam_roam_timeout():
	change_state("IDLE")


func _on_state_chase_unseen_timeout():
	change_state("IDLE")


func _on_state_run_away_unseen_timeout():
	change_state("IDLE")
