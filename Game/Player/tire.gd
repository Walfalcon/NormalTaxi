class_name Tire
extends RayCast3D

@export_category("Suspension Settings")
@export var target_offset: float = 0.4
@export var spring_strength: float = 500.0
@export var damping: float = 10.0
@export var ray_overextend: float = 0.1
@export_category("Wheel Settings")
@export var tire_grip: float = 1.0
@export var roll_friction: float = 15.0 ## Slows the car when not braking
@export var steering: bool = false
@export var driven: bool = true
@export_category("Model")
@export var tire_model: Node3D
@export var tire_radius: float = 0.3

@export var debug: bool = false

@onready var body: Car = get_parent()
@onready var tire_mass: float = body.mass / body.tires.size()

var gas: float = 0.0
var brake: float = 0.0
var last_compression: float = 0.0

func _ready() -> void:
	target_position.y = -(target_offset + tire_radius + ray_overextend)
	tire_model.position.y = -target_offset

## Prevent tire slipping
func traction() -> void:
	if is_colliding():
		var tire_velocity: Vector3 = body.get_point_velocity(tire_model.global_position) ##How fast the wheel is moving forwards
		var side_velocity: float = global_basis.tdotx(tire_velocity)
		var side_force: Vector3 = -global_basis.x * side_velocity * tire_grip * tire_mass * ProjectSettings.get_setting("physics/3d/default_gravity")
		body.apply_force(side_force, tire_model.global_position - body.global_position)
		

## Apply suspension
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

## Rotate tires, if steering is true
func steer(angle: float) -> void:
	rotation.y = angle

## Apply gas/brake, if drive is true
func drive(gas: float, brake: float, gear_forward: bool) -> void:
	if is_colliding():
		var wheel_point: Vector3 = tire_model.global_position
		var projected_forward: Vector3 = (-global_basis.z).slide(get_collision_normal()).normalized()
		var drive_speed: float = projected_forward.dot(body.linear_velocity) ##How fast the wheel is moving forwards
		tire_model.rotate_x(-drive_speed * get_process_delta_time() / tire_radius)
		
		## Gas/Brake
		if drive_speed:
			body.apply_force(-projected_forward * brake * body.brake_force * drive_speed / abs(drive_speed), wheel_point - body.global_position)
		if gas > 0.0:
			if gear_forward:
				var normalized_speed: float = drive_speed / body.max_speed
				var torque: float = body.accel_curve.sample_baked(normalized_speed)
				body.apply_force(projected_forward * torque * gas * body.gas_force, wheel_point - body.global_position)
			else:
				var normalized_reverse_speed: float = drive_speed / body.max_reverse_speed
				var torque: float = body.accel_curve.sample_baked(normalized_reverse_speed)
				body.apply_force(-projected_forward * torque * gas * body.gas_force, wheel_point - body.global_position)
		else:
			body.apply_force(-projected_forward * drive_speed * roll_friction, wheel_point - body.global_position)
