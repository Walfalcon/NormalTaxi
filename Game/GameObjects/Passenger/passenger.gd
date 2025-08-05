class_name Passenger
extends Node3D

@export var radius: float = 6.0
@export var clue: String = "i dunno"
@export var take_me_to: String = "" ## Index destinations by the name of the object

@onready var placement_raycast: RayCast3D = %PlacementRaycast
@onready var target_model: MeshInstance3D = %TargetModel
@onready var passenger_base: Node3D = %PassengerBase
@onready var area: Area3D = %Area


const walk_speed: float = 6.0
const run_speed: float = 10.0
const dodge_speed: float = 20.0
const dodge_distance: float = 5.0

var passenger_ready: bool = true ## Is the passenger ready to be picked up
var boarding: bool = false ## Is the passenger getting into the car.
var dodging: bool = false
var dodge_target: Vector3 = Vector3.ZERO
var normal: Vector3 = Vector3.ZERO

func _ready() -> void:
	GameVariables.pick_up_passenger.connect(_disable_passenger_ready)
	GameVariables.drop_off_passenger.connect(_enable_passenger_ready)
	placement_raycast.force_raycast_update()
	if placement_raycast.is_colliding():
		target_model.mesh.top_radius = radius
		target_model.mesh.bottom_radius = radius
		var area_shape = area.find_child("CollisionShape3D")
		area_shape.shape.radius = radius
		position = placement_raycast.get_collision_point()
		normal = placement_raycast.get_collision_normal()
		area.look_at(position + normal)
		area.transform = area.transform.rotated_local(Vector3.RIGHT, -PI/2)
	else:
		print("WHOOPS the passenger couldn't find solid ground")

func _enable_passenger_ready() -> void:
	passenger_ready = true
	target_model.visible = true
	passenger_base.visible = true

func _disable_passenger_ready() -> void:
	passenger_ready = false
	target_model.visible = false

func _physics_process(delta: float) -> void:
	var distance_to_player: float = GameVariables.current_player.global_position.distance_to(passenger_base.global_position)
	if boarding:
		var target_position = to_local(GameVariables.current_player.get_in_point.global_position).slide(normal)
		passenger_base.position = passenger_base.position.move_toward(target_position, run_speed * delta)
		if (passenger_base.position -target_position).length() < 0.1:
			passenger_base.visible = false
			GameVariables.current_player.passenger_enter(self)
			boarding = false
	else:
		if dodging or (distance_to_player < 3.0 and GameVariables.current_player.speed > 8.0):
			if not dodging:
				var dodge_direction: Vector3 = passenger_base.position - to_local(GameVariables.current_player.global_position)
				dodge_direction = dodge_direction.slide(normal) ## Flatten the dodge_direction vector
				dodge_direction = dodge_direction.normalized() * dodge_distance ## and set it to the proper length
				dodge_target = passenger_base.position + dodge_direction
				if dodge_target.length() > radius:
					if dodge_target.length() > radius + 4.0:
						dodge_target = - dodge_target
					else:
						dodge_target = dodge_target.normalized() * radius
				dodging = true
			passenger_base.position = passenger_base.position.move_toward(dodge_target, dodge_speed * delta)
			if passenger_base.position == dodge_target:
				dodging = false
		elif distance_to_player > 15.0:
			passenger_base.position = passenger_base.position.move_toward(Vector3.ZERO, walk_speed * delta)
		elif passenger_ready and GameVariables.current_player.speed < 0.1 and area.overlaps_body(GameVariables.current_player):
			GameVariables.pick_up_passenger.emit()
			GameVariables.current_player.stop()
			boarding = true
