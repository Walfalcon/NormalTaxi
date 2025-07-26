class_name Tire
extends RayCast3D

@export_category("Suspension Settings")
@export var target_offset: float = 0.4
@export var spring_strength: float = 500.0
@export var damping: float = 10.0
@export var ray_overextend: float = 0.1
@export_category("Wheel Settings")
@export var tire_grip: float = 0.5
@export var roll_friction: float = 15.0 ## Slows the car when not braking
@export var steering: bool = false
@export var driven: bool = true
@export_category("Model")
@export var tire_model: Node3D
@export var tire_radius: float = 0.3

@export var debug: bool = false

@onready var body: Car = get_parent()

var gas: float = 0.0
var brake: float = 0.0
var last_compression: float = 0.0

func _ready() -> void:
	target_position.y = -(target_offset + tire_radius + ray_overextend)
	tire_model.position.y = -target_offset

## Apply suspension and prevent slipping
func suspension() -> void:
	if is_colliding():
		var wheel_point: Vector3 = get_collision_point()
		var spring_length: float = global_position.distance_to(wheel_point) - tire_radius
		var offset: float = (target_offset - spring_length) ## How compressed the suspension is.
		var spring_force: float = offset * spring_strength
		
		var damp_force: float = global_basis.tdoty(body.get_point_velocity(wheel_point)) * damping
		tire_model.position.y = -spring_length
		body.apply_force((spring_force - damp_force) * global_basis.y, tire_model.global_position - body.global_position)
	else:
		tire_model.position.y = -target_offset

func steer(angle: float) -> void:
	rotation.y = angle

func drive(gas_brake: float) -> void:
	if is_colliding():
		var wheel_point: Vector3 = tire_model.global_position
		var projected_forward: Vector3 = (-global_basis.z).slide(get_collision_normal()).normalized()
		var drive_speed: float = projected_forward.dot(body.linear_velocity) ##How fast the wheel is moving forwards
		tire_model.rotate_x(-drive_speed * get_process_delta_time() * 2 * PI * tire_radius)
		
		## Gas/Brake
		if gas_brake > 0.0:
			if drive_speed < 0.0:
				body.apply_force(projected_forward * gas_brake * body.brake_force, wheel_point - body.global_position)
			else:
				var normalized_speed: float = drive_speed / body.max_speed
				if normalized_speed < 1.0:
					var torque: float = (sin(normalized_speed * PI) / 2.0) + 0.5
					body.apply_force(projected_forward * torque * gas_brake * body.gas_force, wheel_point - body.global_position)
		elif gas_brake < 0.0:
			if drive_speed > 0.0:
				body.apply_force(projected_forward * gas_brake * body.brake_force, wheel_point - body.global_position)
			else:
				var normalized_reverse_speed: float = drive_speed / body.max_reverse_speed
				if normalized_reverse_speed < 1.0:
					var torque: float = (sin(normalized_reverse_speed * PI) / 2.0) + 0.5
					body.apply_force(projected_forward * torque * gas_brake * body.gas_force, wheel_point - body.global_position)
		else:
			body.apply_force(-projected_forward * drive_speed * roll_friction)
