class_name Destination
extends Area3D

var is_active: bool = false

func _ready() -> void:
	GameVariables.destinations.append(self)

func _physics_process(delta: float) -> void:
	if is_active and GameVariables.current_player.speed < 0.1 and overlaps_body(GameVariables.current_player):
		GameVariables.current_player.passenger_exit()
		is_active = false
