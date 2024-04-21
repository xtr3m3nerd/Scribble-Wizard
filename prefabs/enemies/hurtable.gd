class_name Hurtable
extends Node

signal dead
signal health_changed (current_health:int , max_health:int)

@export var current_health: int = 10
@export var max_health: int = 10

var is_dead = false

func take_damage(damage: int):
	if is_dead:
		return
	current_health = current_health - damage
	health_changed.emit(current_health, max_health)
	if current_health <= 0:
		is_dead = true
		dead.emit()
