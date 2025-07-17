class_name Car
extends RigidBody3D

@export_category("Gas/Brake")
@export var gas_force: float = 80.0
@export var brake_force: float = 80.0
@export var max_speed: float = 50.0
@export var max_reverse_speed: float = 40.0
@export_category("Steering")
@export var max_steering_angle: float = 0.4
@export var stopping_speed: float = 0.1 ## If idling at less than this speed, just stop moving

@onready var tire_front_left: Tire = %TireFrontLeft
@onready var tire_front_right: Tire = %TireFrontRight
@onready var tire_back_left: Tire = %TireBackLeft
@onready var tire_back_right: Tire = %TireBackRight

func _physics_process(delta: float) -> void:
	tire_front_left.drive(delta)
	tire_front_right.drive(delta)
	tire_back_left.drive(delta)
	tire_back_right.drive(delta)
