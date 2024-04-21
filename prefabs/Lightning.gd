class_name Lightning
extends Node3D


@export var time_to_live:float = 0.2
var time_alive = 0

func _physics_process(delta):
	time_alive = time_alive + delta
	if time_alive > time_to_live:
		queue_free()
