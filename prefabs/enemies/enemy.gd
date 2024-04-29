class_name Enemy
extends CharacterBody3D

@onready var collision_shape_3d = $CollisionShape3D
@onready var graphics = $Graphics as Node3D
@onready var animation_player = $Graphics/AnimationPlayer as AnimationPlayer
@onready var hurtable = $Hurtable as Hurtable

@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("player")
@onready var game_manager : GameManager = get_tree().get_first_node_in_group("game_manager")
@onready var behavior: Behavior = null

var dead = false
var wet = false

func _ready():
	hurtable.dead.connect(kill)
	animation_player.animation_finished.connect(on_animation_finished)
	await get_tree().create_timer(randf_range(0.0,1.0)).timeout
	animation_player.stop()
	animation_player.play("idle", 0.5)
	if game_manager:
		hurtable.dead.connect(game_manager.add_kill)
	for child in get_children():
		if child.is_in_group("enemy_behaviors"):
			behavior = child

func kill():
	dead = true
	#$DeathSound.play()
	animation_player.play("death", 0.5, 0.5)
	collision_shape_3d.disabled = true

func take_damage(damage):
	hurtable.take_damage(damage)

func get_wet():
	wet = true

func is_wet():
	return wet

func get_pushed(force: float, direction: Vector3):
	behavior.change_state("STUNNED")
	velocity = direction*force
	velocity.y = 0

func on_animation_finished(anim_name):
	match anim_name:
		"attack":
			animation_player.play("idle", 0.5)
		_:
			pass
