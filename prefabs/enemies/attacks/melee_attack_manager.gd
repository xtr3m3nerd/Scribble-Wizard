class_name MeleeAttackManager
extends AttackManager

func _ready():
	super._ready()
	start_attack.connect(perform_attack)

func perform_attack():
	super.perform_attack()
	player.take_damage(damage_dealt)
