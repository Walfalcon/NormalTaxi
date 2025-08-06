class_name Player
extends Car

@export var engine_pitch_scale: float = 1.0
@export var engine_pitch_base: float = 1.2
@export var airborne_engine_pitch_scale: float = 3.0
@export var engine_pitch_delta: float = 2.5
@export var restart_node: Node3D

@onready var clue_label: Label = %Clue
@onready var shotgun_seat: Node3D = %Shotgun
@onready var get_in_point: Node3D = %GetInPoint
@onready var engine_sound: AudioStreamPlayer = %EngineSound
@onready var car_model: Node3D = %TheCar

var current_destination: Destination = null
var has_passenger: bool = false

func _ready() -> void:
	GameVariables.current_player = self
	freeze = true
	GameVariables.start_music.connect(start)
	%TireFrontLeft.tire_model = car_model.find_child("Tire-FL")
	%TireFrontRight.tire_model = car_model.find_child("Tire-FR")
	%TireBackLeft.tire_model = car_model.find_child("Tire-RL")
	%TireBackRight.tire_model = car_model.find_child("Tire-RR")

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("Restart"):
		global_transform = restart_node.global_transform
		angular_velocity = Vector3.ZERO
		linear_velocity = Vector3.ZERO
		return
	if freeze:
		engine_sound.pitch_scale = move_toward(engine_sound.pitch_scale, engine_pitch_base, engine_pitch_delta * delta)
		return
	## Get inputs
	steering = Input.get_axis("Right", "Left") * max_steering_angle
	gas = Input.get_action_strength("Gas")
	brake = Input.get_action_strength("Brake")
	
	if Input.is_action_just_pressed("Shift"):
		gear_forward = !gear_forward
	
	super(delta)
	
	if airborne:
		center_of_mass.y = -1.0
		engine_sound.pitch_scale = move_toward(engine_sound.pitch_scale, engine_pitch_base + gas * airborne_engine_pitch_scale, engine_pitch_delta * delta)
	else:
		var normalized_speed: float = speed / max_speed
		center_of_mass.y = -0.2
		engine_sound.pitch_scale = move_toward(engine_sound.pitch_scale, engine_pitch_base + normalized_speed * engine_pitch_scale, engine_pitch_delta * delta)

func stop() -> void:
	freeze = true

func start() -> void:
	freeze = false

## Called when the player stops to pick up a passenger. Add a thing to wait until the passenger is on board.
func passenger_enter(new_passenger: Passenger) -> void:
	for i in GameVariables.destinations:
		if i.name == new_passenger.take_me_to:
			current_destination = i
			current_destination.is_active = true
			break
	assert(current_destination != null, "Picked up passenger did not have a valid destination")
	clue_label.text = new_passenger.clue
	has_passenger = true
	shotgun_seat.visible = true
	start()

func passenger_exit() -> void:
	has_passenger = false
	current_destination = null
	clue_label.text = ""
	shotgun_seat.visible = false
	GameVariables.drop_off_passenger.emit()
