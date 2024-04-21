class_name Hurtable

extends Node
signal dead
signal health_changed (currentHealth:int , maxHealth:int)

@export var currentHealth: int = 10
@export var maxHealth: int = 10

var is_dead = false

func take_damage(damage: int):
	if is_dead:
		return
	currentHealth = currentHealth - damage
	print(currentHealth)
	health_changed.emit(currentHealth, maxHealth)
	if currentHealth <= 0:
		is_dead = true
		dead.emit()
