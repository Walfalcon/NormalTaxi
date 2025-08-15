extends Node

@export var scenes: Array[PackedScene]
var loaded_scene: MainScene = null

@onready var control_animations: AnimationPlayer = %SceneFadeAnimation

func _ready() -> void:
	loaded_scene = scenes[0].instantiate()
	add_child(loaded_scene)
	loaded_scene.change_scene.connect(_on_change_scene)

func _on_change_scene(new_scene: int) -> void:
	get_tree().paused = true
	control_animations.play("Fade")
	await control_animations.animation_finished
	loaded_scene.queue_free()
	loaded_scene = scenes[new_scene].instantiate()
	add_child(loaded_scene)
	loaded_scene.change_scene.connect(_on_change_scene)
	control_animations.play_backwards("Fade")
	await control_animations.animation_finished
	get_tree().paused = false
