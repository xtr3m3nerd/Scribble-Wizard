class_name Behavior
extends Node

signal state_changed(current_state: State, new_state: State)

@export var vision_range = 15.0

@onready var unit: Enemy = get_parent() as Enemy
@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("player")
@onready var states = get_children() as Array[State]

var current_state: State 
var dist_to_player: float
var is_player_seen: bool = false

func _ready():
	change_state(states[0].state_name)
	
func _physics_process(delta):
	if unit.dead:
		return
	if player == null:
		return
		
	dist_to_player = unit.global_position.distance_to(player.global_position)
	is_player_seen = can_see_player()
	
	check_for_transition()
	current_state.during_physics_process(delta)

func check_for_transition():
	pass


func can_see_player():
	if dist_to_player > vision_range:
		return false
	var eye_line = Vector3.UP * 1.5
	var query = PhysicsRayQueryParameters3D.create(unit.global_position+eye_line, player.global_position+eye_line, 1)
	var result = unit.get_world_3d().direct_space_state.intersect_ray(query)
	return result.is_empty()

func change_state(new_state_name: String):
	var new_state: State = null
	for state in states:
		if state.state_name == new_state_name:
			new_state = state
			break
	if new_state == null:
		return
	if new_state == current_state:
		return
	
	if current_state != null:
		current_state.on_state_leave()
	new_state.on_state_enter()
	state_changed.emit(current_state, new_state)
	current_state = new_state

