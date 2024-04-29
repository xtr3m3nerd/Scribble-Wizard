class_name HealthBar
extends ProgressBar

@export var hurtable: Hurtable:
	set(value):
		if hurtable != null and hurtable.health_changed.is_connected(update_health):
			hurtable.health_changed.disconnect(update_health)
		hurtable = value
		if hurtable != null:
			hurtable.health_changed.connect(update_health)
			update_health(hurtable.current_health, hurtable.max_health)
		else:
			update_health(0,1)

func update_health(current_health: int, max_health: int):
	#warning-ignore:integer_division
	value = 100*current_health/float(max_health)
