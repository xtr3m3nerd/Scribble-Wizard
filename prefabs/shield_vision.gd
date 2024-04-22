extends ColorRect

@onready var animation_player = $AnimationPlayer as AnimationPlayer

func lost_shield():
	animation_player.play("RESET")

func shielded():
	animation_player.play("shielded")
