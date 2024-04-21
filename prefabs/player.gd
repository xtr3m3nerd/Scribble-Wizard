class_name Player
extends CharacterBody3D

@export var projectile_prefab: PackedScene
@onready var ray_cast_3d = $RayCast3D as RayCast3D
@onready var animation_player = $AnimationPlayer as AnimationPlayer
@onready var death_screen = $CanvasLayer/DeathScreen as Control
@onready var restart_button = $CanvasLayer/DeathScreen/PanelContainer/MarginContainer/VBoxContainer/RestartButton as Button
@onready var cooldown_timer = $CooldownTimer as Timer
@onready var projectile_spawn_point = $ProjectileSpawnPoint as Marker3D
@onready var cast_zone = $CanvasLayer/CastZone as CastZone
@onready var casting_charge = $CastingCharge as CastingCharge

const SPEED = 5.0
const TURN_SPEED = 90.0
const EYE_LEVEL = 1.0

var can_shoot = true
var dead = false

func _ready():
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	animation_player.animation_finished.connect(shoot_anim_done)
	restart_button.button_up.connect(restart)
	death_screen.hide()
	cast_zone.start_cast.connect(start_cast)
	cast_zone.cast.connect(shoot)
	cast_zone.bad_cast.connect(bad_cast)
	casting_charge.emitting = false

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

func start_cast():
	casting_charge.animation_player.play("charging")

func bad_cast():
	casting_charge.animation_player.play("fizzle")
	pass

func shoot(type: String):
	# type input is "lightning", "fire", or "water" at the moment
	if !can_shoot:
		return
	can_shoot = false
	#animated_sprite_2d.play("shoot")
	#shoot_sound.play()
	cooldown_timer.start()
	#if ray_cast_3d.is_colliding() and ray_cast_3d.get_collider().has_method("kill"):
		#ray_cast_3d.get_collider().kill()
		
	casting_charge.animation_player.play("shoot")
	match type:
		"lightning":
			var projectile = projectile_prefab.instantiate() as Projectile
			projectile.add_collision_exception_with(self)
			get_tree().current_scene.add_child(projectile)
			projectile.global_position = projectile_spawn_point.global_position
			projectile.global_basis = global_basis
		"fire":
			pass
		"water":
			pass
		_:
			printerr("Type: %s is not currently supported" % type)

func shoot_anim_done():
	can_shoot = true

func kill():
	dead = true
	death_screen.show()
	#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
