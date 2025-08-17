extends Node

signal start_music
signal stop_music

const initial_time: float = 75.0 ## Seconds left on timer at start of game
const additional_time: float = 16.5 ## Seconds added when you pick up a passenger

var current_player: Player = null
var destinations: Array[Destination] = []
var current_timer: Timer = null
var score: int = 0

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

func _ready() -> void:
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	if err != OK:
		for action in InputMap.get_actions():
			for event in InputMap.action_get_events(action):
				if event is InputEventKey:
					config.set_value("Controls", action, event)
		config.set_value("Volume", "Master", 1.0)
		config.set_value("Volume", "Music", 1.0)
		config.set_value("Volume", "Other", 1.0)
		config.save("user://settings.cfg")
	else:
		for action in InputMap.get_actions():
			for event in InputMap.action_get_events(action):
				if event is InputEventKey:
					InputMap.action_erase_event(action, event)
					InputMap.action_add_event(action, config.get_value("Controls", action, event))
		game_volume = config.get_value("Volume", "Master", 1.0)
		music_volume = config.get_value("Volume", "Music", 1.0)
		other_volume = config.get_value("Volume", "Other", 1.0)
