class_name GameManager
extends Node

signal level_finished
signal game_win
signal kills_changed(kills: int)

@export var map_generator: MapGenerator

var current_level = -1
@export var levels: Array[DungeonLevel] = []

var kills: int = 0

func _ready():
	start_next_level()

func add_kill():
	kills += 1
	kills_changed.emit(kills)

func start_next_level():
	current_level += 1
	if current_level < levels.size():
		print("Next Level")
		map_generator.generate_level(levels[current_level])
	else:
		print("You Win")
		game_win.emit()
