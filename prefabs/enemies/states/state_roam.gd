class_name StateRoam
extends State

signal roam_timeout

@export var move_speed = 2.0

@export var roam_time_range: Vector2 = Vector2(1.0, 2.0)
var roam_timer: Timer

var target_dir: Vector3 = Vector3.ZERO

@onready var behavior: Behavior = get_parent() as Behavior

func _ready():
	roam_timer = Timer.new()
	roam_timer.wait_time = roam_time_range.x
	roam_timer.one_shot = true
	roam_timer.timeout.connect(emit_roam_timeout)
	add_child(roam_timer)

func emit_roam_timeout():
	roam_timeout.emit()

func during_physics_process(_delta):
	if target_dir == Vector3.ZERO:
		target_dir = Vector3.FORWARD.rotated(Vector3.UP,deg_to_rad(randf_range(0.0, 360.0))).normalized()
		target_dir.y = 0.0
	
	# TODO - make enemy look in direction they are moving
	#unit.look_at()
	
	behavior.unit.velocity = target_dir * move_speed
	behavior.unit.move_and_slide()

func on_state_leave():
	target_dir = Vector3.ZERO
	roam_timer.stop()

func on_state_enter():
	roam_timer.start(randf_range(roam_time_range.x, roam_time_range.y))


