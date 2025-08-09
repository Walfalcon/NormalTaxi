class_name SoundtrackPlayer
extends Node

var songs: Array[AudioStreamPlayer]

@onready var song_label: Label = %SongLabel

var song_counter: int = 0

func _ready() -> void:
	for i in get_children():
		if i is AudioStreamPlayer:
			songs.push_back(i)
			i.finished.connect(_on_start_music)
	songs.shuffle()
	GameVariables.start_music.connect(_on_start_music)
	GameVariables.stop_music.connect(_on_stop_music)

func _on_start_music() -> void:
	song_label.text = songs[song_counter].name ## Not working, need to assign names to songs. Custom resources?
	songs[song_counter].play()
	song_counter += 1
	song_counter %= songs.size()

func _on_stop_music() -> void:
	songs[song_counter].stop()
	songs.shuffle()
	song_label.text = ""
