class_name StateRunAway
extends State

signal unseen_timeout

@export var move_speed = 2.0

@export var unseen_time = 1.0
var unseen_timer: Timer

@onready var behavior: Behavior = get_parent() as Behavior

func _ready():
	unseen_timer = Timer.new()
	unseen_timer.wait_time = unseen_time
	unseen_timer.one_shot = true
	unseen_timer.timeout.connect(emit_unseen_timeout)
	add_child(unseen_timer)

func emit_unseen_timeout():
	unseen_timeout.emit()

func during_physics_process(_delta):
	if not behavior.is_player_seen and unseen_timer.is_stopped():
		unseen_timer.start()
	elif behavior.is_player_seen and not unseen_timer.is_stopped():
		unseen_timer.stop()
	
	var dir = behavior.player.global_position - behavior.unit.global_position
	dir.y = 0.0
	dir = dir.normalized() * -1.0
	
	behavior.unit.look_at(behavior.unit.global_position + dir)
	
	behavior.unit.velocity = dir * move_speed
	behavior.unit.move_and_slide()

func on_state_leave():
	unseen_timer.stop()

func on_state_enter():
	pass


