class_name StateIdle
extends State

signal idle_timeout

@export var idle_time_range: Vector2 = Vector2(1.0, 2.0)
var idle_timer: Timer

func _ready():
	state_name = "IDLE"
	idle_timer = Timer.new()
	idle_timer.wait_time = idle_time_range.x
	idle_timer.one_shot = true
	idle_timer.timeout.connect(emit_idle_timeout)
	add_child(idle_timer)

func emit_idle_timeout():
	idle_timeout.emit()

func during_physics_process(_delta):
	pass

func on_state_leave():
	idle_timer.stop()

func on_state_enter():
	idle_timer.start(randf_range(idle_time_range.x, idle_time_range.y))
