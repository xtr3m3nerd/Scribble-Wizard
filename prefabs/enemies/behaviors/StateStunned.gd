class_name StateStunned
extends State

signal stunned_timeout

@export var stunned_time = 1.0
var stunned_timer: Timer

@onready var behavior: Behavior = get_parent() as Behavior

func _ready():
	stunned_timer = Timer.new()
	stunned_timer.wait_time = stunned_time
	stunned_timer.one_shot = true
	stunned_timer.timeout.connect(emit_stunned_timeout)
	add_child(stunned_timer)

func during_physics_process(_delta):
	behavior.unit.move_and_slide()

func emit_stunned_timeout():
	stunned_timeout.emit()

func on_state_leave():
	stunned_timer.stop()

func on_state_enter():
	stunned_timer.start()


