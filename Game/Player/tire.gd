class_name Tire
extends RayCast3D

@export_category("Suspension Settings")
@export var target_offset: float = 0.4
@export var spring_strength: float = 1000.0
@export var damping: float = 100.0
@export_category("Wheel Settings")
@export var tire_grip: float = 0.5
@export var roll_friction: float = 0.05 ## Slows the car when not braking
@export_category("Model")
@export var tire_model: Node3D
@export var tire_radius: float = 0.3

@export var debug: bool = false

@onready var body: Car = get_parent()
@onready var last_position: Vector3 = global_position

var gas: float = 0.0
var brake: float = 0.0

func _ready() -> void:
	target_position.y = -target_offset
	tire_model.position.y = -target_offset + tire_radius

func drive(delta: float) -> void:
	var force: Vector3 = Vector3.ZERO
	if is_colliding():
		var velocity: Vector3 = (global_position - last_position) / delta
		var current_offset: float = (global_position - get_collision_point()).length()
		var compression: float = (target_offset - current_offset) / target_offset ## How compressed the suspension is. 1.0 is fully compressed.
		force += global_basis.y * ((compression * spring_strength) - global_basis.tdoty(velocity) * damping)
		tire_model.position.y = -current_offset + tire_radius
	else:
		tire_model.position.y = -target_offset + tire_radius
	last_position = global_position
	body.apply_force(force, position)

func _drive(delta: float) -> void:
	var force: Vector3 = Vector3.ZERO
	if is_colliding():
		var velocity: Vector3 = (global_position - last_position) / delta
		## Steering
		var slide_speed: float = global_basis.tdotx(velocity) ## How fast the wheel is sliding left/right
		if slide_speed > 0.05:
			force += global_basis.x * (-slide_speed * tire_grip / delta) * (body.mass / 4.0)
		## Suspension
		var current_offset: float = (global_position - get_collision_point()).length()
		var compression: float = (target_offset - current_offset) / target_offset ## How compressed the suspension is. 1.0 is fully compressed.
		force += global_basis.y * ((compression * spring_strength) - global_basis.tdoty(velocity) * damping)
		tire_model.position.y = -current_offset + tire_radius
		## Gas/Brake
		var drive_speed: float = -global_basis.tdotz(velocity) ## How fast the wheel is moving forward/back
		if gas > 0.0:
			if drive_speed < 0.0:
				force -= global_basis.z * gas
			else:
				var normalized_speed: float = drive_speed / body.max_speed
				if normalized_speed < 1.0:
					var torque: float = (sin(normalized_speed * PI) / 2.0) + 0.5
					force -= global_basis.z * torque * gas
		if brake > 0.0:
			if drive_speed > 0.0:
				force += global_basis.z * brake
			else:
				var normalized_reverse_speed: float = -drive_speed / body.max_reverse_speed
				if normalized_reverse_speed < 1.0:
					var torque: float = (sin(normalized_reverse_speed * PI) / 2.0) + 0.5
					force += global_basis.z * torque * gas
		if gas == 0.0 and brake == 0.0:
			force -= global_basis.z * drive_speed * roll_friction
	else:
		tire_model.position.y = -target_offset + tire_radius
	last_position = global_position
	body.apply_force(force, position)
