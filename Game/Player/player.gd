extends VehicleBody3D

const max_steering_angle: float = 0.55 ##How far the wheels can turn, in radians
const accel_force: float = 150.0
const brake_force: float = 150.0

func _physics_process(delta: float) -> void:
	var target_steering: float = Input.get_axis("Right", "Left")
	if target_steering > 1.0:
		target_steering = 1.0
	elif target_steering < -1.0:
		target_steering = -1.0
	steering = target_steering * max_steering_angle
	
	engine_force = Input.get_action_strength("Gas") * accel_force
	brake = Input.get_action_strength("Brake") * brake_force
	
	print(steering)
