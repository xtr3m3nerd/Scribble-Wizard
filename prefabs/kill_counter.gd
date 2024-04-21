extends Label

@onready var game_manager : GameManager = get_tree().get_first_node_in_group("game_manager")

func _ready():
	game_manager.kills_changed.connect(update_kill_count)
	update_kill_count(game_manager.kills)

func update_kill_count(kills: int):
	text = "Kills: %d" % kills
