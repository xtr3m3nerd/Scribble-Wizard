class_name Projectile
extends CharacterBody3D


@export var move_speed = 20.0
@export var damage = 1

func _physics_process(delta):
	var dir = -transform.basis.z
	var collision = move_and_collide(dir * move_speed * delta)
	print(global_position)
	if collision:
		if collision.get_collider().has_method("take_damage"):
			collision.get_collider().take_damage(damage)
		queue_free()
