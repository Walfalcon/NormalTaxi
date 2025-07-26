class_name Car
extends RigidBody3D

@export_category("Gas/Brake")
@export var gas_force: float = 900.0
@export var brake_force: float = 1200.0
@export var max_speed: float = 60.0 ## Positive number
@export var max_reverse_speed: float = -50.0 ## Negative number
@export_category("Steering")
@export var max_steering_angle: float = 0.25
@export var stopping_speed: float = 0.15 ## If idling at less than this speed, just stop moving
@export var tire_grip: float = 0.9 ## How much the car slides left/right
@export var roll_friction: float = 0.05 ## Drag force on the car when not accelerating/braking

@export var tires: Array[Tire]

var gas_brake: float = 0.0 ## Should be from -1 to +1
var steering: float = 0.0 ## Should be from -max_steering_angle to +max_steering_angle

func _physics_process(delta: float) -> void:
	for tire in tires:
		if tire.steering:
			tire.steer(steering)
		tire.suspension()
		if tire.driven:
			tire.drive(gas_brake)
	if linear_velocity.length() < stopping_speed:
		apply_central_force(-linear_velocity * mass / delta)
	#	## Steering
	#	var target_angular_velocity: Vector3 = global_basis.y * steering * drive_speed
	#	var flat_angular_velocity: Vector3 = angular_velocity.project(global_basis.y)
	#	apply_torque((target_angular_velocity - flat_angular_velocity) * mass)
	## Prevent slipping
	#var slip_speed: float = -global_basis.tdotx(linear_velocity)
	#force += global_basis.x * slip_speed * tire_grip * mass / delta
	
	#apply_central_force(force)

func get_point_velocity(point: Vector3) -> Vector3:
	return linear_velocity + angular_velocity.cross(point - global_position)
