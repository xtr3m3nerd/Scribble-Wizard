class_name StateFlank
extends State

signal flank_timeout
signal unseen_timeout

enum FlankDir {
	LEFT,
	RIGHT
}
const ROT_ANGLE = 10.0
@export var flank_dist = 5.0
@export var flank_dir: FlankDir = FlankDir.LEFT
@export var move_speed = 2.0

@export var flank_time_range: Vector2 = Vector2(1.0, 2.0)
var flank_timer: Timer

@export var unseen_time = 1.0
var unseen_timer: Timer

@export var use_random_dir: bool = false

@onready var behavior: Behavior = get_parent() as Behavior

func _ready():
	flank_timer = Timer.new()
	flank_timer.wait_time = flank_time_range.x
	flank_timer.one_shot = true
	flank_timer.timeout.connect(emit_flank_timeout)
	add_child(flank_timer)
	
	unseen_timer = Timer.new()
	unseen_timer.wait_time = unseen_time
	unseen_timer.one_shot = true
	unseen_timer.timeout.connect(emit_unseen_timeout)
	add_child(unseen_timer)
	

func emit_flank_timeout():
	flank_timeout.emit()

func emit_unseen_timeout():
	unseen_timeout.emit()

func during_physics_process(_delta):
	if not behavior.is_player_seen and unseen_timer.is_stopped():
		unseen_timer.start()
	elif behavior.is_player_seen and not unseen_timer.is_stopped():
		unseen_timer.stop()
	
	var dir = behavior.player.global_position - behavior.unit.global_position
	dir.y = 0.0
	dir = dir.normalized() * -1
	var rot_dir = -1
	if flank_dir == FlankDir.LEFT:
		rot_dir = 1
	var target_dir = dir.rotated(Vector3.UP,ROT_ANGLE * rot_dir).normalized()
	target_dir.y = 0.0
	var target_pos = behavior.player.global_position - target_dir * flank_dist
	
	var move_dir = target_pos - behavior.unit.global_position
	move_dir.y = 0.0
	move_dir = move_dir.normalized()
	
	behavior.unit.look_at(behavior.player.global_position)
	
	behavior.unit.velocity = move_dir * move_speed
	behavior.unit.move_and_slide()

func on_state_leave():	
	flank_timer.stop()

func on_state_enter():
	if use_random_dir:
		flank_dir = randi_range(0,1) as FlankDir
	flank_timer.start(randf_range(flank_time_range.x, flank_time_range.y))


