class_name Player
extends Car

func _physics_process(delta: float) -> void:
	## Get inputs
	var target_steering: float = Input.get_axis("Right", "Left")
	if target_steering > 1.0:
		target_steering = 1.0
	elif target_steering < -1.0:
		target_steering = -1.0
	var steering: float = target_steering * max_steering_angle
	var gas: float = Input.get_action_strength("Gas") * gas_force
	var brake: float = Input.get_action_strength("Brake") * brake_force
	
	## Apply steering to front tires
	tire_front_left.rotation = Vector3(0.0, steering, 0.0)
	tire_front_right.rotation = Vector3(0.0, steering, 0.0)
	## Apply gas/braking to all tires
	tire_front_left.gas = gas
	tire_front_right.gas = gas
	tire_back_left.gas = gas
	tire_back_right.gas = gas
	tire_front_left.brake = brake
	tire_front_right.brake = brake
	tire_back_left.brake = brake
	tire_back_right.brake = brake
	
	super(delta)
