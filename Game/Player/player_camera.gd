extends Node3D

@onready var body: RigidBody3D = get_parent()
@export var min_angle: float = 0.1 ## If the angle to body forward is less than min_angle, snap to look forward (radians)
@export var rotation_speed: float = 0.5 ##How quickly the pivot follows the car's rotation (slerp)


func _ready() -> void:
	top_level = true

func _process(delta: float) -> void:
	position = body.global_position
	var body_forward: Vector3 = (-body.global_basis.z).slide(Vector3.UP)
	if body_forward != Vector3.ZERO:
		body_forward = body_forward.normalized()
		if body_forward.angle_to(-global_basis.z):
			look_at(to_global(body_forward))
		else:
			look_at(-global_basis.z.slerp(body_forward, rotation_speed))
	print($Camera3D.position)
