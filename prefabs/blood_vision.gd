extends ColorRect

@onready var animation_player = $AnimationPlayer as AnimationPlayer

func hurt(_current_health, _max_health):
	animation_player.play("hurt")

func dead():
	animation_player.play("dead")
