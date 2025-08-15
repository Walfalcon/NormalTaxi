extends Node3D

@onready var parent: Node3D = get_parent()
@onready var buffer: Array[Transform3D] = [parent.global_transform, parent.global_transform]

func _process(delta: float) -> void:
	global_transform = buffer[0]
	buffer.pop_front()
	buffer.push_back(parent.global_transform)
