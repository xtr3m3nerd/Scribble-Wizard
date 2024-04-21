class_name RangeAttackManager
extends AttackManager

@export var projectile_prefab: PackedScene

func _ready():
	super._ready()
	#start_attack.connect(perform_attack)

func perform_attack():
	super.perform_attack()
	var mid_line = 1.0
	var projectile = projectile_prefab.instantiate() as Projectile
	projectile.add_collision_exception_with(unit)
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = global_position
	projectile.look_at(player.global_position + Vector3.UP * mid_line)
	projectile.damage = damage_dealt

