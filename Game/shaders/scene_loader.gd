extends Node

@export var level: PackedScene

func _ready() -> void:
	var loaded_scene: MainScene = level.instantiate()
	add_child(loaded_scene)
	loaded_scene.change_scene.connect(_on_change_scene)

func _on_change_scene(new_scene: PackedScene) -> void:
	pass
