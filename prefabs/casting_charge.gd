class_name CastingCharge
extends GPUParticles3D

signal charged
signal shot_finished

@onready var animation_player = $AnimationPlayer as AnimationPlayer

func drawing():
	animation_player.play("drawing")
	
func charge():
	animation_player.play("charging")

func fizzle():
	animation_player.play("fizzle")

func shoot():
	animation_player.play("shoot")
	
func on_charged():
	charged.emit()

func on_shot_finished():
	shot_finished.emit()
