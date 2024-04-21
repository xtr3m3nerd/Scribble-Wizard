class_name GameManager
extends Node

signal level_finished
signal kills_changed(kills: int)

var kills: int = 0

func add_kill():
	kills += 1
	kills_changed.emit(kills)
