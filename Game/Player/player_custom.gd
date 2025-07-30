class_name Player
extends Car

func _ready() -> void:
	GameVariables.current_player = self

func _physics_process(delta: float) -> void:
	## Get inputs
	steering = Input.get_axis("Right", "Left") * max_steering_angle
	gas_brake = Input.get_axis("Brake", "Gas")
	
	## Apply steering to front tires
	## Apply gas/braking to all tires
	#tire_front_left.gas = gas
	#tire_front_right.gas = gas
	#tire_back_left.gas = gas
	#tire_back_right.gas = gas
	#tire_front_left.brake = brake
	#tire_front_right.brake = brake
	#tire_back_left.brake = brake
	#tire_back_right.brake = brake
	
	super(delta)
