class_name Hurtable

extends Node
signal dead
signal health_changed (currentHealth:int , maxHealth:int)

@export var currentHealth: int = 2
@export var maxHealth: int = 2

func take_damage(damage: int):
	currentHealth = currentHealth - damage
	print(currentHealth)
	health_changed.emit(currentHealth, maxHealth)
	if currentHealth <= 0:
		dead.emit()
