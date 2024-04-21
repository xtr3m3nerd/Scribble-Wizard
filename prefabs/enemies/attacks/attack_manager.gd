class_name AttackManager
extends Node3D

signal start_attack
signal attack

@export var attack_range = 2.0
@export var min_attack_range = 0.0
@export var damage_dealt: int = 1
@export var attack_cooldown = 0.5
var cooldown_timer: Timer
var can_attack = true

@onready var unit: Enemy = get_parent() as Enemy
@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("player")

func _ready():
	cooldown_timer = Timer.new()
	cooldown_timer.wait_time = attack_cooldown
	cooldown_timer.one_shot = true
	cooldown_timer.timeout.connect(cooldown_finished)
	add_child(cooldown_timer)

func _physics_process(_delta):
	if unit.dead:
		return
	if player == null:
		return
		
	attempt_to_kill_player()

func attempt_to_kill_player():
	if !can_attack:
		return
	var dist_to_player = global_position.distance_to(player.global_position)
	if dist_to_player > attack_range:
		return
	if dist_to_player < min_attack_range:
		return
	
	if can_see_player():
		can_attack = false
		start_attack.emit()
		cooldown_timer.start()

func can_see_player():
	var eye_line = Vector3.UP * 1.5
	var query = PhysicsRayQueryParameters3D.create(global_position+eye_line, player.global_position+eye_line, 1)
	var result = get_world_3d().direct_space_state.intersect_ray(query)
	return result.is_empty()

func cooldown_finished():
	can_attack = true

func perform_attack():
	attack.emit()
