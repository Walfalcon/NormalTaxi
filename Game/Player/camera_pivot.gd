extends Node3D

@onready var body: Player = get_parent()
@export var rotation_speed: float = 5.0 ##How quickly the pivot follows the car's rotation
@export var max_angle_yaw: float = 0.2 * PI
@export var max_angle_pitch: float = 0.4 * PI

func _ready() -> void:
	top_level = true

func _process(delta: float) -> void:
	position = body.global_position
	var body_forward: Vector3 = -body.global_basis.z ## the car's forward vector
	var look_target: Vector3 = Vector3.ZERO
	var body_yaw_vector: Vector3 = body_forward.slide(Vector3.UP)
	if body_yaw_vector != Vector3.ZERO:
		body_yaw_vector = body_yaw_vector.normalized()
		
		if not body.airborne:
			var body_pitch: float = body_forward.angle_to(body_yaw_vector)
			var camera_pitch: float = basis.get_euler().x
			if body_pitch < max_angle_pitch:
				if body_forward.y < 0:
					body_pitch = -body_pitch
			else:
				if body_forward.y < 0:
					body_pitch = -max_angle_pitch
				else:
					body_pitch = max_angle_pitch
			var pitch_offset = body_pitch - camera_pitch
			look_target = (-global_basis.z).rotated(global_basis.x, pitch_offset * rotation_speed * delta)
		else:
			var pitch_offset = atan(body.linear_velocity.y / 25) * max_angle_pitch / (PI / 2) - basis.get_euler().x
			look_target = (-global_basis.z).rotated(global_basis.x, pitch_offset * rotation_speed * delta)
		
		var camera_yaw_vector: Vector3 = (-global_basis.z).slide(Vector3.UP)
		var yaw_offset: float = camera_yaw_vector.signed_angle_to(body_yaw_vector, Vector3.UP)
		look_target = look_target.rotated(Vector3.UP, yaw_offset * rotation_speed * delta)
			
	else:
		look_target = (-global_basis.z)
	look_at(global_position + look_target)
