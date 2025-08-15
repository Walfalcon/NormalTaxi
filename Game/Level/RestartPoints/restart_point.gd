class_name RestartPoint
extends Area3D

const player_height: float = 1.5

@onready var point: Node3D = find_child("Node3D")

func _ready() -> void:
	body_exited.connect(_on_player_left)
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(point.global_position, point.global_position + (Vector3.DOWN * 15.0))
	var result = space_state.intersect_ray(query)
	point.global_position = result.position + result.normal * player_height
	var point_forward = (-point.global_basis.z).slide(result.normal)
	point.look_at(point.global_position + point_forward, result.normal)

func _on_player_left(body: Node3D) -> void:
	if body.is_in_group("Player"):
		body.restart_node = point
