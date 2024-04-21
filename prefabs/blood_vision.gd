extends ColorRect

@onready var animation_player = $AnimationPlayer as AnimationPlayer

func hurt(current_health, max_health):
	animation_player.play("hurt")

func dead():
	animation_player.play("dead")
