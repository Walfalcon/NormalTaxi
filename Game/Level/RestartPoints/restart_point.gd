class_name RestartPoint
extends Area3D

@onready var point: Node3D = find_child("Node3D")

func _ready() -> void:
	body_exited.connect(_on_player_left)

func _on_player_left(body: Node3D) -> void:
	if body.is_in_group("Player"):
		print("player left")
		body.restart_node = point
