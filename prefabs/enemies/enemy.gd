class_name Enemy
extends CharacterBody3D

@onready var collision_shape_3d = $CollisionShape3D
@onready var graphics = $Graphics as Node3D
@onready var animation_player = $Graphics/AnimationPlayer as AnimationPlayer
@onready var hurtable = $Hurtable as Hurtable

@export var move_speed = 2.0
@export var attack_range = 2.0
@export var damage_dealt: int = 1
@export var attack_cooldown = 0.5
var cooldown_timer: Timer
var can_attack = true

@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("player")
@onready var game_manager : GameManager = get_tree().get_first_node_in_group("game_manager")

var dead = false

func _ready():
	cooldown_timer = Timer.new()
	cooldown_timer.wait_time = attack_cooldown
	cooldown_timer.one_shot = true
	cooldown_timer.timeout.connect(cooldown_finished)
	add_child(cooldown_timer)
	
	hurtable.dead.connect(kill)
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
	
	var dir = player.global_position - global_position
	dir.y = 0.0
	dir = dir.normalized()
	
	velocity = dir * move_speed
	move_and_slide()
	attempt_to_kill_player()

func attempt_to_kill_player():
	if !can_attack:
		return
	var dist_to_player = global_position.distance_to(player.global_position)
	if dist_to_player > attack_range:
		return
	
	var eye_line = Vector3.UP * 1.5
	var query = PhysicsRayQueryParameters3D.create(global_position+eye_line, player.global_position+eye_line, 1)
	var result = get_world_3d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		player.take_damage(damage_dealt)
		can_attack = false
		cooldown_timer.start()

func kill():
	dead = true
	#$DeathSound.play()
	animation_player.play("death", 0.5, 0.5)
	collision_shape_3d.disabled = true

func take_damage(damage):
	hurtable.take_damage(damage)

func cooldown_finished():
	can_attack = true
