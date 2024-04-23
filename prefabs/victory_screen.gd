class_name VictoryScreen
extends Control

@export var main_menu: PackedScene
@onready var kill_count_label = $ColorRect/VBoxContainer/KillCountLabel

@export var kills: int:
	set(value):
		kills = value
		update_kill_count_label(value)

func _ready():
	update_kill_count_label(kills)

func update_kill_count_label(value):
	if !kill_count_label:
		return
	kill_count_label.text = "You killed %d enemies" % value


func _on_play_again_button_pressed():
	get_tree().reload_current_scene()

func _on_main_menu_button_pressed():
	get_tree().change_scene_to_packed(main_menu)
