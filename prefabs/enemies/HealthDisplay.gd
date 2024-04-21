class_name HealthBar

extends ProgressBar

func updateHealth(currentHealth: int, maxHealth: int):
	value = 100*currentHealth/maxHealth
