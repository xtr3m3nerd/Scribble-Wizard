class_name GameManager
extends Node

signal level_finished
signal game_win
signal kills_changed(kills: int)

@export var victory_screen_prefab: PackedScene
@export var loading_screen_prefab: PackedScene
@onready var canvas_layer = $CanvasLayer

@export var map_generator: MapGenerator

var current_level = -1
@export var levels: Array[DungeonLevel] = []

var kills: int = 0
var loading_screen = null

func _ready():
	map_generator.level_generated.connect(on_level_generated)
	start_next_level()

func add_kill():
	kills += 1
	kills_changed.emit(kills)

func start_next_level():
	current_level += 1
	if current_level < levels.size():
		print("Next Level")
		loading_screen = loading_screen_prefab.instantiate()
		canvas_layer.add_child(loading_screen)
		await get_tree().process_frame
		await get_tree().process_frame
		await get_tree().process_frame
		await get_tree().process_frame
		await get_tree().process_frame
		map_generator.generate_level.call_deferred(levels[current_level])
	else:
		print("You Win")
		game_win.emit()
		var victory_screen = victory_screen_prefab.instantiate() as VictoryScreen
		victory_screen.kills = kills
		canvas_layer.add_child(victory_screen)

func on_level_generated():
	if loading_screen != null:
		loading_screen.queue_free()
