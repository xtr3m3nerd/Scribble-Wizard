class_name MainMenu
extends Control

@onready var play_game_button = $Buttons/PlayGameButton
@onready var quit_button = $Buttons/QuitButton

func _ready():
	play_game_button.grab_focus()
	if OS.get_name() == "Web":
		quit_button.hide()

func _process(_delta):
	if Input.is_action_just_pressed("quit"):
		quit()
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()

func _on_play_game_button_pressed():
	get_tree().change_scene_to_packed(SceneManager.game_scene)

func _on_quit_button_pressed():
	quit()

func quit():
	if OS.get_name() == "Web":
		return
	get_tree().quit()
