class_name Hurtable
extends Node

signal dead
signal health_changed (current_health:int , max_health:int)
signal lost_shield

@export var current_health: int = 10
@export var max_health: int = 10

var is_dead = false
var is_shielded = 0

func take_damage(damage: int):
	if is_dead:
		return
	if is_shielded > 0:
		is_shielded = is_shielded - 1
		if is_shielded == 0:
			lost_shield.emit()
	else:
		current_health = current_health - damage
		health_changed.emit(current_health, max_health)
	if current_health <= 0:
		is_dead = true
		dead.emit()

func receive_shield():
	is_shielded = 1
