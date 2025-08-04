class_name SoundtrackPlayer
extends AudioStreamPlayer

@export var songs: Array[AudioStream]

@onready var song_label: Label = %SongLabel

var song_counter: int = 0

func _ready() -> void:
	
	songs.shuffle()
	GameVariables.start_music.connect(_on_start_music)
	GameVariables.stop_music.connect(_on_stop_music)

func _on_start_music() -> void:
	stream = songs[song_counter]
	song_label.text = stream.resource_name ## Not working, need to assign names to songs. Custom resources?
	play()

func _on_stop_music() -> void:
	stop()
	songs.shuffle()
	song_label.text = ""


func _on_finished() -> void:
	song_counter += 1
	song_counter %= songs.size()
	_on_start_music()
