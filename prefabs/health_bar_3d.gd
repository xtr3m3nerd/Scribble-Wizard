class_name HealthBar3D
extends Node3D

@onready var health_bar = $SubViewport/HealthBar

@export var hurtable: Hurtable:
	set(value):
		hurtable = value
		set_hurtable(value)

func set_hurtable(value):
	if health_bar == null:
		return
	health_bar.hurtable = hurtable

func _ready():
	set_hurtable(hurtable)
