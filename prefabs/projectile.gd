class_name Projectile
extends CharacterBody3D

@onready var destroy_timer = $DestroyTimer
@onready var fireball = $Graphics/fireball

@export var move_speed = 20.0
@export var damage = 5
@export var wet = true
@export var pushing_force = 0
@export var offset = Vector3(0,0,0)

func _physics_process(delta):
	var dir = -transform.basis.z
	var collision = move_and_collide(dir * move_speed * delta)
	
	fireball.position = offset
	
	if move_speed == 0:
		destroy_timer.stop()
		
	if collision:
		if damage > 0:
			if collision.get_collider().has_method("take_damage"):
				collision.get_collider().take_damage(damage)
		if wet:
			if collision.get_collider().has_method("get_wet"):
				collision.get_collider().get_wet()
		if pushing_force > 0:
			if collision.get_collider().has_method("get_pushed"):
				collision.get_collider().get_pushed(pushing_force, dir)
		queue_free()
