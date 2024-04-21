class_name HealthBar
extends ProgressBar

@export var hurtable: Hurtable

func _ready():
	if not hurtable:
		printerr("No hurtable object linked")
		return
	hurtable.health_changed.connect(update_health)
	update_health(hurtable.current_health, hurtable.max_health)

func update_health(current_health: int, max_health: int):
	value = 100*current_health/max_health
