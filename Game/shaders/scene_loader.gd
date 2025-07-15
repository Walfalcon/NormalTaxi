extends Node

@export var level: PackedScene

func _ready() -> void:
	var loaded_scene: Node = level.instantiate()
	add_child(loaded_scene)
