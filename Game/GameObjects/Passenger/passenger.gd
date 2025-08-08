class_name Passenger
extends Node3D

@export var radius: float = 6.0
@export var points: int = 0
@export var clue: String = "i dunno"
@export var take_me_to: String = "" ## Index destinations by the name of the object

@onready var placement_raycast: RayCast3D = %PlacementRaycast
@onready var target_model: MeshInstance3D = %TargetModel
@onready var passenger_model: Node3D = %PassengerModel
@onready var area: Area3D = %Area
@onready var anim_player: AnimationPlayer = passenger_model.find_child("AnimationPlayer")


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
	anim_player.play("Idle")
	start_random_anim_timer()

func _enable_passenger_ready() -> void:
	passenger_ready = true
	target_model.visible = true
	passenger_model.visible = true
	start_random_anim_timer()

func _disable_passenger_ready() -> void:
	passenger_ready = false
	target_model.visible = false

func start_random_anim_timer() -> void:
	%AnimTimer.start(randf_range(1.0, 10.0))



func _physics_process(delta: float) -> void:
	var distance_to_player: float = GameVariables.current_player.global_position.distance_to(passenger_model.global_position)
	if boarding:
		var target_position = to_local(GameVariables.current_player.get_in_point.global_position).slide(normal)
		passenger_model.position = passenger_model.position.move_toward(target_position, dodge_speed * delta)
		passenger_model.look_at(GameVariables.current_player.get_in_point.global_position)
		if (passenger_model.position -target_position).length() < 0.1:
			passenger_model.visible = false
			GameVariables.current_player.passenger_enter(self)
			boarding = false
			anim_player.play("Idle")
	else:
		if dodging or (distance_to_player < 3.0 and GameVariables.current_player.speed > 8.0):
			anim_player.play("Dive")
			if not dodging:
				var dodge_direction: Vector3 = passenger_model.position - to_local(GameVariables.current_player.global_position)
				dodge_direction = dodge_direction.slide(normal) ## Flatten the dodge_direction vector
				dodge_direction = dodge_direction.normalized() * dodge_distance ## and set it to the proper length
				dodge_target = passenger_model.position + dodge_direction
				if dodge_target.length() > radius:
					if dodge_target.length() > radius + 4.0:
						dodge_target = - dodge_target
					else:
						dodge_target = dodge_target.normalized() * radius
				dodging = true
			passenger_model.position = passenger_model.position.move_toward(dodge_target, dodge_speed * delta)
			if passenger_model.position == dodge_target:
				dodging = false
			else:
				passenger_model.look_at(to_global(dodge_target))
		elif distance_to_player > 15.0:
			if passenger_model.position != Vector3.ZERO:
				passenger_model.look_at(global_position)
				passenger_model.position = passenger_model.position.move_toward(Vector3.ZERO, walk_speed * delta)
				anim_player.play("Walk")
		elif passenger_ready and GameVariables.current_player.speed < 0.1 and area.overlaps_body(GameVariables.current_player):
			GameVariables.pick_up_passenger.emit()
			GameVariables.current_player.stop()
			boarding = true
			anim_player.play("Dive")
		else:
			passenger_model.look_at(Vector3.FORWARD)
			anim_player.play("Idle")


func _on_anim_timer_timeout() -> void:
	if passenger_ready:
		anim_player.play("Hail")
		anim_player.queue("Idle")
