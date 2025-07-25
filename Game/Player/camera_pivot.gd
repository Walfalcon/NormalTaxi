extends Node3D

@onready var body: RigidBody3D = get_parent()
@export var rotation_speed: float = 4.0 ##How quickly the pivot follows the car's rotation
@export var max_angle: float = 0.2 * PI

func _ready() -> void:
	top_level = true

func _process(delta: float) -> void:
	position = body.global_position
	var body_forward: Vector3 = (-body.global_basis.z).slide(Vector3.UP)
	if body_forward != Vector3.ZERO:
		body_forward = body_forward.normalized()
		var angle: float = (-global_basis.z).signed_angle_to(body_forward, Vector3.UP)
		if abs(angle) <= (angle * rotation_speed)* delta:
			look_at(global_position + body_forward)
		elif angle > max_angle:
			look_at(global_position + (-global_basis.z).rotated(Vector3.UP, angle - max_angle))
		elif angle < -max_angle:
			look_at(global_position + (-global_basis.z).rotated(Vector3.UP, angle + max_angle))
		else:
			look_at(global_position + (-global_basis.z).rotated(Vector3.UP, (angle * rotation_speed)* delta))
			#look_at(global_position - global_basis.z.slerp(body_forward, rotation_speed * delta))
