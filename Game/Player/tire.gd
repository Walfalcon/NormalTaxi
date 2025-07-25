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
var last_compression: float = 0.0

func _ready() -> void:
	target_position.y = -target_offset
	tire_model.position.y = -target_offset + tire_radius

func drive(delta: float) -> void:
	var force: Vector3 = Vector3.ZERO
	if is_colliding():
		var current_offset: float = (global_position - get_collision_point()).length()
		var compression: float = (target_offset - current_offset) / target_offset ## How compressed the suspension is. 1.0 is fully compressed.
		var compression_velocity: float = (compression - last_compression) * target_offset / delta
		last_compression = compression
		force += global_basis.y * ((compression * spring_strength) + compression_velocity * damping)
		tire_model.position.y = -current_offset + tire_radius
	else:
		tire_model.position.y = -target_offset + tire_radius
	last_position = global_position
	body.apply_force(force, position)
