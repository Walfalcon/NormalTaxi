class_name Tire
extends RayCast3D

@export_category("Suspension Settings")
@export var target_offset: float = 0.4
@export var spring_strength: float = 1000.0
@export var damping: float = 100.0
@export_category("Wheel Settings")
@export_category("Model")
@export var tire_model: Node3D
@export var tire_radius: float = 0.3

@onready var body: RigidBody3D = get_parent()

@onready var last_position: Vector3 = global_position
var force: Vector3 = Vector3()

func _ready() -> void:
	target_position.y = -target_offset * 2
	tire_model.position.y = -target_offset + tire_radius

func _physics_process(delta: float) -> void:
	## Suspension
	if is_colliding():
		var velocity: float = basis.tdoty(global_position - last_position) / delta
		var current_offset: float = (global_position - get_collision_point()).length()
		var compression: float = (target_offset - current_offset) / target_offset ## How compressed the suspension is. 1.0 is fully compressed.
		force.y = (compression * spring_strength) - velocity * damping
		tire_model.position.y = -current_offset + tire_radius
	else:
		force.y = 0.0
		tire_model.position.y = -target_offset + tire_radius
	last_position = global_position
	
	body.apply_force(force, position)
