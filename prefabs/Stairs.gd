extends Node3D

@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var game_manager : GameManager = get_tree().get_first_node_in_group("game_manager")

var found_stairs = false

func _physics_process(delta):
	if !found_stairs and player.global_position.distance_to(self.global_position) < 1:
		found_stairs = true
		game_manager.level_finished.emit()
