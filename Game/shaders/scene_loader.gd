extends Node

@export var level: PackedScene
var loaded_scene: MainScene = null

func _ready() -> void:
	loaded_scene = level.instantiate()
	add_child(loaded_scene)
	loaded_scene.change_scene.connect(_on_change_scene)

func _on_change_scene(new_scene: PackedScene) -> void:
	loaded_scene.queue_free()
	loaded_scene = new_scene.instantiate()
	add_child(loaded_scene)
	loaded_scene.change_scene.connect(_on_change_scene)
