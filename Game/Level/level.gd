class_name Level
extends MainScene


func _ready() -> void:
	GameVariables.start_music.emit()
	GameVariables.current_timer = %GameTimer
	GameVariables.current_timer.start(GameVariables.initial_time)
	GameVariables.score = 0

func _on_game_timer_timeout() -> void:
	change_scene.emit(2)
