extends CharacterBody3D

@onready var ray_cast_3d = $RayCast3D as RayCast3D
@onready var animation_player = $AnimationPlayer as AnimationPlayer
@onready var death_screen = $CanvasLayer/DeathScreen as Control
@onready var restart_button = $CanvasLayer/DeathScreen/PanelContainer/MarginContainer/VBoxContainer/RestartButton as Button
@onready var cooldown_timer = $CooldownTimer as Timer

const SPEED = 5.0
const TURN_SPEED = 90.0

var can_shoot = true
var dead = false

func _ready():
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	animation_player.animation_finished.connect(shoot_anim_done)
	restart_button.button_up.connect(restart)
	death_screen.hide()

func _input(_event):
	if dead:
		return

func _process(_delta):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	if Input.is_action_just_pressed("restart"):
		restart()
	
	if dead:
		return
	if Input.is_action_just_pressed("shoot"):
		shoot()

func _physics_process(delta):
	if dead:
		return
	var input_dir = Input.get_vector("move_left", "move_right", "move_forwards", "move_backwards")
	rotation_degrees.y -= input_dir.x * TURN_SPEED * delta
	var direction = (transform.basis * Vector3(0, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()


func restart():
	get_tree().reload_current_scene()

func shoot():
	if !can_shoot:
		return
	can_shoot = false
	#animated_sprite_2d.play("shoot")
	#shoot_sound.play()
	cooldown_timer.start()
	if ray_cast_3d.is_colliding() and ray_cast_3d.get_collider().has_method("kill"):
		ray_cast_3d.get_collider().kill()

func shoot_anim_done():
	can_shoot = true

func kill():
	dead = true
	death_screen.show()
	#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	