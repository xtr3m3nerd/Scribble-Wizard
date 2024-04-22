class_name MeleeFlankBehavior
extends Behavior

@export var melee_attack_manager: MeleeAttackManager

func _ready():
	super._ready()
	melee_attack_manager.attack.connect(_on_attack)

func check_for_transition():
	if unit.dead:
		change_state("DEAD")
	
	match current_state.state_name:
		"IDLE":
			chase_seen_player()
		"ROAM":
			chase_seen_player()

func chase_seen_player():
	if is_player_seen:
		change_state("CHASE")

func _on_attack():
	change_state("FLANK")
	
func _on_state_idle_idle_timeout():
	change_state("ROAM")

func _on_state_roam_roam_timeout():
	change_state("IDLE")

func _on_state_chase_unseen_timeout():
	change_state("IDLE")

func _on_state_flank_flank_timeout():
	change_state("CHASE")

func _on_state_flank_unseen_timeout():
	change_state("IDLE")
