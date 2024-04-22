class_name Enemy
extends CharacterBody3D

@onready var collision_shape_3d = $CollisionShape3D
@onready var graphics = $Graphics as Node3D
@onready var animation_player = $Graphics/AnimationPlayer as AnimationPlayer
@onready var hurtable = $Hurtable as Hurtable

@export var move_speed = 2.0

@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("player")
@onready var game_manager : GameManager = get_tree().get_first_node_in_group("game_manager")

var dead = false

func _ready():
	hurtable.dead.connect(kill)
	animation_player.animation_finished.connect(on_animation_finished)
	await get_tree().create_timer(randf_range(0.0,1.0)).timeout
	animation_player.stop()
	animation_player.play("idle", 0.5)
	if game_manager:
		hurtable.dead.connect(game_manager.add_kill)
	
func _physics_process(_delta):
	if dead:
		return
	if player == null:
		return
	
	if can_see_player():
		var dir = player.global_position - global_position
		dir.y = 0.0
		dir = dir.normalized()
		
		look_at(player.global_position)
		
		velocity = dir * move_speed
		move_and_slide()

func can_see_player():
	var eye_line = Vector3.UP * 1.5
	var query = PhysicsRayQueryParameters3D.create(global_position+eye_line, player.global_position+eye_line, 1)
	var result = get_world_3d().direct_space_state.intersect_ray(query)
	return result.is_empty()

func kill():
	dead = true
	#$DeathSound.play()
	animation_player.play("death", 0.5, 0.5)
	collision_shape_3d.disabled = true

func take_damage(damage):
	hurtable.take_damage(damage)

func on_animation_finished(anim_name):
	match anim_name:
		"attack":
			animation_player.play("idle", 0.5)
		_:
			pass
