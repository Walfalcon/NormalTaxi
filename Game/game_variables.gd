extends Node

signal pick_up_passenger
signal drop_off_passenger
signal start_music
signal stop_music

var current_player: Player = null
var destinations: Array[Destination] = []
var game_started: bool = false

var input_map


@onready var game_volume: float = AudioServer.get_bus_volume_linear(0) :
	set(new_volume):
		AudioServer.set_bus_volume_linear(0, new_volume)
		game_volume = new_volume
@onready var music_volume: float = AudioServer.get_bus_volume_linear(1) :
	set(new_volume):
		AudioServer.set_bus_volume_linear(1, new_volume)
		music_volume = new_volume
@onready var other_volume: float = AudioServer.get_bus_volume_linear(2) :
	set(new_volume):
		AudioServer.set_bus_volume_linear(2, new_volume)
		other_volume = new_volume
