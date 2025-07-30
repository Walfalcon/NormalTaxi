class_name Passenger
extends Node3D

@export var radius: float = 6.0
@export var walk_speed: float = 2.0
@export var run_speed: float = 3.0
@export var dodge_speed: float = 14.0
@export var dodge_distance: float = 5.0

@onready var placement_raycast: RayCast3D = %PlacementRaycast
@onready var target_model: MeshInstance3D = %TargetModel
@onready var passenger_sprite: Sprite3D = %PassengerSprite
@onready var passenger_base: Node3D = %PassengerBase

var passenger_ready: bool = true
var dodging: bool = false
var dodge_target: Vector3 = Vector3.ZERO
var normal: Vector3 = Vector3.ZERO

func _ready() -> void:
	placement_raycast.force_raycast_update()
	if placement_raycast.is_colliding():
		target_model.mesh.top_radius = radius
		target_model.mesh.bottom_radius = radius
		position = placement_raycast.get_collision_point()
		normal = placement_raycast.get_collision_normal()
		target_model.look_at(position + normal)
		target_model.transform = target_model.transform.rotated_local(Vector3.RIGHT, -PI/2)
	else:
		print("WHOOPS the passenger couldn't find solid ground")

func _enable_passenger_ready() -> void:
	passenger_ready = true
	target_model.visible = true

func _disable_passenger_ready() -> void:
	passenger_ready = false
	target_model.visible = false

func _physics_process(delta: float) -> void:
	var distance_to_player: float = GameVariables.current_player.global_position.distance_to(passenger_base.global_position)
	if dodging or (distance_to_player < 3.0 and GameVariables.current_player.speed > 8.0):
		if not dodging:
			var dodge_direction: Vector3 = passenger_base.position - to_local(GameVariables.current_player.global_position)
			dodge_direction = dodge_direction.slide(normal).normalized()
			dodge_target = passenger_base.position + dodge_direction * dodge_distance
			if dodge_target.length() > radius:
				dodge_target = dodge_target.normalized() * radius
				if passenger_base.position.distance_to(dodge_target) < 3.0:
					dodge_target = -dodge_target
			dodging = true
		passenger_base.position = passenger_base.position.move_toward(dodge_target, dodge_speed * delta)
		if passenger_base.position == dodge_target:
			dodging = false
	elif distance_to_player > 15.0:
		passenger_base.position = passenger_base.position.move_toward(Vector3.ZERO, walk_speed * delta)
