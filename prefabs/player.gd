class_name Player
extends CharacterBody3D

@export var projectile_prefab: PackedScene
@export var lightning_prefab: PackedScene
@onready var ray_cast_3d = $RayCast3D as RayCast3D
@onready var animation_player = $AnimationPlayer as AnimationPlayer
@onready var death_screen = $CanvasLayer/DeathScreen as Control
@onready var restart_button = $CanvasLayer/DeathScreen/PanelContainer/MarginContainer/VBoxContainer/RestartButton as Button
@onready var cooldown_timer = $CooldownTimer as Timer
@onready var projectile_spawn_point = $ProjectileSpawnPoint as Marker3D
@onready var cast_zone = $CanvasLayer/CastZone
@onready var casting_charge = $CastingCharge as CastingCharge
@onready var hurtable = $Hurtable
@onready var health_label = $CanvasLayer/VBoxContainer/HealthLabel as HealthLabel
@onready var blood_vision = $CanvasLayer/BloodVision
@onready var shield_vision = $CanvasLayer/ShieldVision

const SPEED = 5.0
const TURN_SPEED = 90.0
const EYE_LEVEL = 1.0

var can_shoot = true
var dead = false

func _ready():
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	hurtable.dead.connect(kill)
	hurtable.dead.connect(blood_vision.dead)
	hurtable.health_changed.connect(blood_vision.hurt)
	hurtable.health_changed.connect(health_label.update_health)
	hurtable.lost_shield.connect(shield_vision.lost_shield)
	health_label.update_health(hurtable.current_health, hurtable.max_health)
	
	animation_player.animation_finished.connect(shoot_anim_done)
	restart_button.button_up.connect(restart)
	death_screen.hide()
	cast_zone.start_draw.connect(casting_charge.drawing)
	cast_zone.start_cast.connect(casting_charge.charge)
	cast_zone.cast.connect(shoot)
	cast_zone.bad_cast.connect(casting_charge.fizzle)
	casting_charge.emitting = false

func _input(_event):
	if dead:
		return

func _process(_delta):
	if Input.is_action_just_pressed("quit"):
		get_tree().change_scene_to_packed(SceneManager.main_menu_scene)
	if Input.is_action_just_pressed("restart"):
		restart()
	
	if dead:
		return

var strafe_left_timer: SceneTreeTimer = null
var is_strafing_left = false
var strafe_right_timer: SceneTreeTimer = null
var is_strafing_right = false

func _physics_process(delta):
	if dead:
		return
	var input_dir = Input.get_vector("move_left", "move_right", "move_forwards", "move_backwards")
	
	if strafe_left_timer and strafe_left_timer.time_left > 0 and Input.is_action_just_pressed("move_left"):
		is_strafing_left = true
	elif Input.is_action_just_pressed("move_left"):
		strafe_left_timer = get_tree().create_timer(0.5)
	elif is_strafing_left and not Input.is_action_pressed("move_left"):
		is_strafing_left = false
		
	if strafe_right_timer and strafe_right_timer.time_left > 0 and Input.is_action_just_pressed("move_right"):
		is_strafing_right = true
	elif Input.is_action_just_pressed("move_right"):
		strafe_right_timer = get_tree().create_timer(0.5)
	elif is_strafing_right and not Input.is_action_pressed("move_right"):
		is_strafing_right = false
	
	if input_dir:
		if is_strafing_left:
			var dir = (transform.basis * Vector3(-1, -1, 0)).normalized()
			velocity.x = dir.x * SPEED
			velocity.z = dir.z * SPEED
		elif is_strafing_right:
			var dir = (transform.basis * Vector3(1, 1, 0)).normalized()
			velocity.x =  dir.x * SPEED
			velocity.z = dir.z * SPEED
		else:
			rotation_degrees.y -= input_dir.x * TURN_SPEED * delta
			var direction = (transform.basis * Vector3(0, 0, input_dir.y)).normalized()
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()

func restart():
	get_tree().reload_current_scene()

func shoot(glyph_list):
	# type input is "lightning", "fire", or "water" at the moment
	if !can_shoot:
		return
	can_shoot = false
	#animated_sprite_2d.play("shoot")
	#shoot_sound.play()
	cooldown_timer.start()
	#if ray_cast_3d.is_colliding() and ray_cast_3d.get_collider().has_method("kill"):
		#ray_cast_3d.get_collider().kill()
	
	casting_charge.shoot()
	for glyph in glyph_list:
		match glyph:
			"lightning":
				if ray_cast_3d.is_colliding() and ray_cast_3d.get_collider().has_method("take_damage"):
					var target = ray_cast_3d.get_collider()
					
					var already_hit_targets = [target]
					
					if target.has_method("is_wet") and target.is_wet():
						var enemies = get_tree().get_nodes_in_group("enemies")
						for i in range(2): # number of bounces
							var source_enemy_position = already_hit_targets[-1].collision_shape_3d.global_position
							var closest_enemy = null
							var closest_distance = 100000000000000
							for enemy in enemies:
								if !already_hit_targets.has(enemy) and !enemy.dead:
									var space_state = get_world_3d().direct_space_state
									var params = PhysicsRayQueryParameters3D.new()
									params.from = source_enemy_position
									params.to = enemy.global_position
									params.exclude = [enemy, already_hit_targets[-1]]
									var result = space_state.intersect_ray(params)
									if !result:
										var distance_to_enemy = source_enemy_position.distance_to(enemy.global_position)
										if distance_to_enemy < closest_distance:
											closest_enemy = enemy
											closest_distance = distance_to_enemy
							if closest_enemy != null:
								var chain_lightning: Lightning = lightning_prefab.instantiate()
								get_tree().current_scene.add_child(chain_lightning)
								chain_lightning.global_position = closest_enemy.collision_shape_3d.global_position
								chain_lightning.look_at(already_hit_targets[-1].collision_shape_3d.global_position)
								chain_lightning.scale = Vector3(1,1,closest_distance/2)
								chain_lightning.rotation_degrees.z = RandomNumberGenerator.new().randf_range(0, 360)
								already_hit_targets.append(closest_enemy)
					print(len(already_hit_targets))
					for already_hit_target in already_hit_targets:
						if already_hit_target.has_method("is_wet") and already_hit_target.is_wet():
							already_hit_target.take_damage(5)
						else:
							already_hit_target.take_damage(3)
				
				var lightning = lightning_prefab.instantiate()
				get_tree().current_scene.add_child(lightning)
				lightning.global_position = projectile_spawn_point.global_position	
				lightning.global_basis = global_basis
				lightning.rotation_degrees.z = RandomNumberGenerator.new().randf_range(0, 360)
			"fire":
				hurtable.receive_shield()
				shield_vision.shielded()
			"water":
				var projectile = projectile_prefab.instantiate() as Projectile
				projectile.add_collision_exception_with(self)
				get_tree().current_scene.add_child(projectile)
				projectile.global_position = projectile_spawn_point.global_position
				projectile.global_basis = global_basis
			"push":
				var projectile = projectile_prefab.instantiate() as Projectile
				projectile.add_collision_exception_with(self)
				get_tree().current_scene.add_child(projectile)
				projectile.global_position = projectile_spawn_point.global_position
				projectile.global_basis = global_basis
				projectile.damage = 0
				projectile.move_speed = 100
				projectile.wet = false
				projectile.pushing_force = 3
			"trap":
				var projectile = projectile_prefab.instantiate() as Projectile
				projectile.add_collision_exception_with(self)
				get_tree().current_scene.add_child(projectile)
				projectile.global_position = projectile_spawn_point.global_position
				projectile.global_basis = global_basis
				projectile.damage = 5
				projectile.move_speed = 0
				projectile.wet = false
				projectile.pushing_force = 0
				projectile.offset = Vector3(0, -1, 0)
			_:
				printerr("Glyph: %s is not currently supported" % glyph)

func shoot_anim_done():
	can_shoot = true

func kill():
	dead = true
	death_screen.show()
	#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	

func take_damage(damage):
	hurtable.take_damage(damage)
