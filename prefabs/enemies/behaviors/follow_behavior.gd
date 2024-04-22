class_name FollowBehavior
extends Node3D

@export var vision_range = 15.0
@export var move_speed = 2.0

@onready var unit: Enemy = get_parent() as Enemy
@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("player")


enum States {
	IDLE,
	ROAM,
	CHASE,
	DEAD,
}
var current_state: States = States.IDLE

var target_dir: Vector3

func _ready():
	pass
	
func _physics_process(delta):
	if unit.dead:
		return
	match current_state:
		States.IDLE:
			idle(delta)
		States.ROAM:
			roam(delta)
		States.CHASE:
			chase(delta)
		States.DEAD:
			pass
	if player == null:
		return

func idle(delta):
	pass

func roam(delta):
	if target_dir == null:
		target_dir = Vector3.FORWARD.rotated(Vector3.UP,deg_to_rad(randf_range(0.0, 360.0))).normalized()
		target_dir.y = 0.0
	
	# TODO - make enemy look in direction they are moving
	#unit.look_at()
	
	unit.velocity = target_dir * move_speed
	unit.move_and_slide()

func chase(delta):
	var dir = player.global_position - global_position
	dir.y = 0.0
	dir = dir.normalized()
	
	unit.look_at(player.global_position)
	
	unit.velocity = dir * move_speed
	unit.move_and_slide()
