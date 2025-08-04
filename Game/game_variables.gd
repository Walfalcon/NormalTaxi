extends Node

signal pick_up_passenger
signal drop_off_passenger
signal start_music
signal stop_music

var current_player: Player = null
var destinations: Array[Destination] = []
var game_started: bool = false

func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	start_music.emit()
