class_name SoundtrackPlayer
extends AudioStreamPlayer

@export var songs: Array[String]
@export var song_files: Dictionary[String, AudioStream]

@onready var song_label: Label = %SongLabel
@onready var song_label_animation: AnimationPlayer = %SongLabelAnimation

var song_counter: int = 0

func _ready() -> void:
	songs.shuffle()
	GameVariables.start_music.connect(_on_start_music)
	GameVariables.stop_music.connect(_on_stop_music)

func _on_start_music() -> void:
	song_label.text = songs[song_counter]
	stream = song_files[song_label.text]
	play()
	song_label_animation.play("Show")
	song_counter += 1
	song_counter %= songs.size()

func _on_stop_music() -> void:
	stop()
	songs.shuffle()
	song_label.text = ""
