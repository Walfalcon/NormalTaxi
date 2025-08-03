class_name Car
extends RigidBody3D

@export_category("Gas/Brake")
@export var gas_force: float = 300.0
@export var brake_force: float = 200
@export var max_speed: float = 60.0 ## Positive number
@export var max_reverse_speed: float = -50.0 ## Negative number
@export var accel_curve: Curve
@export_category("Steering")
@export var max_steering_angle: float = 0.25
@export var stopping_speed: float = 0.15 ## If idling at less than this speed, just stop moving

@export var tires: Array[Tire]

var gas: float = 0.0 ## From 0 to 1
var brake: float = 0.0
var steering: float = 0.0 ## Should be from -max_steering_angle to +max_steering_angle
var speed: float = 0.0
var gear_forward: bool = true

func _physics_process(delta: float) -> void:
	speed = linear_velocity.length()
	for tire in tires:
		tire.force_raycast_update()
		if tire.steering:
			tire.steer(steering)
		tire.suspension()
		if tire.driven:
			tire.drive(gas, brake, gear_forward)
		tire.traction()

func get_point_velocity(point: Vector3) -> Vector3:
	return linear_velocity + angular_velocity.cross(point - global_position)
