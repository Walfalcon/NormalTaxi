class_name Player
extends Car

@onready var clue_label: Label = %Clue

var current_destination: Destination = null
var has_passenger: bool = false

func _ready() -> void:
	GameVariables.current_player = self

func _physics_process(delta: float) -> void:
	## Get inputs
	steering = Input.get_axis("Right", "Left") * max_steering_angle
	gas = Input.get_action_strength("Gas")
	brake = Input.get_action_strength("Brake")
	
	if Input.is_action_just_pressed("Shift"):
		gear_forward = !gear_forward
	
	super(delta)

func stop() -> void:
	freeze = true

func start() -> void:
	freeze = false

## Called when the player stops to pick up a passenger. Add a thing to wait until the passenger is on board.
func passenger_enter(new_passenger: Passenger) -> void:
	for i in GameVariables.destinations:
		if i.name == new_passenger.take_me_to:
			current_destination = i
			break
	assert(current_destination != null, "Picked up passenger did not have a valid destination")
	clue_label.text = new_passenger.clue
	has_passenger = true

func passenger_exit() -> void:
	has_passenger = false
	current_destination = null
	clue_label.text = ""
