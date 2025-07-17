extends Camera3D

@onready var body: RigidBody3D = get_parent()

@export var look_at_offset: Vector3 = Vector3(0.0, 2.0, 0.0)

var target_position: Vector3 = position
@onready var target_look_at: Vector3 = body.global_position + look_at_offset

func _ready() -> void:
	top_level = true

func _process(delta: float) -> void:
	look_at(target_look_at)
