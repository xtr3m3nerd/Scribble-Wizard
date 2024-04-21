class_name HealthLabel
extends Label

func update_health(current_health: int, max_health: int):
	text = "Health: %d/%d" % [current_health, max_health]
