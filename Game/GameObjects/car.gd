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

@onready var tire_front_left: Tire = %TireFrontLeft
@onready var tire_front_right: Tire = %TireFrontRight
@onready var tire_back_left: Tire = %TireBackLeft
@onready var tire_back_right: Tire = %TireBackRight

var gas_brake: float = 0.0 ## Should be from -1 to +1
var steering: float = 0.0 ## Should be from -max_steering_angle to +max_steering_angle

func _physics_process(delta: float) -> void:
	tire_front_left.drive(delta)
	tire_front_right.drive(delta)
	tire_back_left.drive(delta)
	tire_back_right.drive(delta)
	
	if tire_front_left.is_colliding() or tire_front_right.is_colliding() or tire_back_left.is_colliding() or tire_back_right.is_colliding():
		var drive_speed: float = -global_basis.tdotz(linear_velocity) ##How fast the car is moving forwards
		## Gas/Brake
		if gas_brake > 0.0:
			if drive_speed < 0.0:
				apply_central_force(-global_basis.z * gas_brake * brake_force)
			else:
				var normalized_speed: float = drive_speed / max_speed
				if normalized_speed < 1.0:
					var torque: float = (sin(normalized_speed * PI) / 2.0) + 0.5
					apply_central_force(-global_basis.z * torque * gas_brake * gas_force)
		elif gas_brake < 0.0:
			if drive_speed > 0.0:
				apply_central_force(-global_basis.z * gas_brake * brake_force)
			else:
				var normalized_reverse_speed: float = drive_speed / max_reverse_speed
				if normalized_reverse_speed < 1.0:
					var torque: float = (sin(normalized_reverse_speed * PI) / 2.0) + 0.5
					apply_central_force(-global_basis.z * torque * gas_brake * gas_force)
		elif linear_velocity.length() > stopping_speed:
			apply_central_force(global_basis.z * drive_speed * roll_friction)
		else:
			apply_central_force(-linear_velocity * mass / delta)
		## Steering
		var target_angular_velocity: Vector3 = global_basis.y * steering * drive_speed
		var flat_angular_velocity: Vector3 = angular_velocity.project(global_basis.y)
		apply_torque((target_angular_velocity - flat_angular_velocity) * mass)
	## Prevent slipping
	var slip_speed: float = -global_basis.tdotx(linear_velocity)
	apply_central_force(global_basis.x * slip_speed * tire_grip * mass / delta)
