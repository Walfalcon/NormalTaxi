class_name Player
extends Car

const boost_force: float = 500.0
const boost_wait_time: float = 0.15
const boost_time: float = 0.4
const engine_pitch_scale: float = 1.2
const engine_pitch_base: float = 1.0
const airborne_engine_pitch_scale: float = 3.0
const engine_pitch_delta: float = 2.5
const passenger_leave_speed: float = 15.

@export var restart_node: Node3D


@onready var clue_label: Label = %Clue
@onready var passenger_model: Node3D = %Passenger
@onready var passenger_animator: AnimationPlayer = passenger_model.find_child("AnimationPlayer")
@onready var get_in_point: Node3D = %GetInPoint
@onready var engine_sound: AudioStreamPlayer = %EngineSound
@onready var car_model: Node3D = %TheCar
@onready var boost_timer: Timer = %NormalBoostTimer
@onready var gearshift_icon: Sprite2D = %GearshiftIcon
@onready var passenger_timer: Timer = %PassengerTimer
@onready var seated_position: Transform3D = passenger_model.transform
@onready var gus_animator: AnimationPlayer = car_model.find_child("AnimationPlayer")
@onready var settings_menu: Settings = %Settings
@onready var time_ticker: Label = %TimeTicker

var current_destination: Destination = null
var has_passenger: bool = false
var passenger_leaving: bool = false
var boosting: bool = false

func _ready() -> void:
	time_ticker.text = str(int(GameVariables.initial_time))
	passenger_animator.play("Sit")
	gus_animator.play("Sit_Idle")
	GameVariables.current_player = self
	%TireFrontLeft.tire_model = car_model.find_child("Tire-FL")
	%TireFrontRight.tire_model = car_model.find_child("Tire-FR")
	%TireBackLeft.tire_model = car_model.find_child("Tire-RL")
	%TireBackRight.tire_model = car_model.find_child("Tire-RR")
	settings_menu.close_settings.connect(_on_settings_exit)

func _physics_process(delta: float) -> void:
	if clue_label.visible_characters < 500.0:
		clue_label.visible_characters += 1
	if Input.is_action_just_pressed("Camera"):
		if %MainCamera.current:
			%Camera2.current = true
		else:
			%MainCamera.current = true
	if Input.is_action_just_pressed("Restart"):
		var flip: bool = restart_node.to_local(global_position).z > 0.0
		global_transform = restart_node.global_transform
		if flip:
			basis = basis.rotated(Vector3.UP, PI)
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
	
	if (not airborne) and (not boost_timer.is_stopped()) and (not boosting) and Input.is_action_just_pressed("Gas"):
		apply_central_impulse(basis.z * (-boost_force if gear_forward else boost_force))
		boosting = true
		%Afterimage.visible = true
		boost_timer.start(boost_time)
	
	if Input.is_action_just_pressed("Shift"):
		gear_forward = !gear_forward
		gearshift_icon.frame = 0 if gear_forward else 1
		if (not Input.is_action_pressed("Gas")) and (not boosting):
			boost_timer.start(boost_wait_time)
	
	super(delta)
	
	if airborne:
		center_of_mass.y = -1.0
		engine_sound.pitch_scale = move_toward(engine_sound.pitch_scale, engine_pitch_base + gas * airborne_engine_pitch_scale, engine_pitch_delta * delta)
	else:
		var normalized_speed: float = speed / max_speed
		center_of_mass.y = -0.2
		engine_sound.pitch_scale = move_toward(engine_sound.pitch_scale, engine_pitch_base + normalized_speed * engine_pitch_scale, engine_pitch_delta * delta)
	
	if passenger_leaving:
		passenger_model.position.y += passenger_leave_speed * delta
	
	if Input.is_action_just_pressed("Pause"):
		get_tree().paused = true
		settings_menu._on_settings_open()
		settings_menu.visible = true

func _process(delta: float) -> void:
	if GameVariables.current_timer != null:
		time_ticker.text = str(int(GameVariables.current_timer.time_left))

func stop() -> void:
	freeze = true

func start() -> void:
	freeze = false

## Called when the player stops to pick up a passenger. Add a thing to wait until the passenger is on board.
func passenger_enter(new_passenger: Passenger) -> void:
	passenger_timer.stop()
	passenger_leaving = false
	passenger_model.top_level = false
	passenger_model.transform = seated_position
	passenger_animator.play("Sit")
	for i in GameVariables.destinations:
		if i.name == new_passenger.take_me_to:
			current_destination = i
			current_destination.is_active = true
			current_destination.visible = true
			break
	assert(current_destination != null, "Picked up passenger did not have a valid destination")
	clue_label.text = new_passenger.clue
	clue_label.visible_characters = 0
	has_passenger = true
	passenger_model.visible = true
	GameVariables.current_timer.start(GameVariables.current_timer.time_left + GameVariables.additional_time)
	start()

func passenger_exit() -> void:
	current_destination.is_active = false
	current_destination.visible = false
	has_passenger = false
	current_destination = null
	clue_label.text = ""
	passenger_animator.play("Dive")
	passenger_model.top_level = true
	passenger_model.look_at(passenger_model.position + Vector3.UP)
	passenger_leaving = true
	passenger_timer.start()
	GameVariables.drop_off_passenger.emit()
	GameVariables.score += 1
	print(GameVariables.score)


func _on_passenger_timer_timeout() -> void:
	passenger_leaving = false
	passenger_model.visible = false

func _on_settings_exit() -> void:
	get_tree().paused = false
	settings_menu.visible = false
	


func _on_normal_boost_timer_timeout() -> void:
	if boosting:
		boosting = false
		%Afterimage.visible = false
