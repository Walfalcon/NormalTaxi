extends Button

@export var action: StringName

@onready var indicator: Label = get_child(0)
@onready var buttons: Array[Node] = get_parent().get_children()
@onready var input_timer: Timer = %Timer

var reading_player_input: bool = false

func _ready() -> void:
	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			indicator.text = OS.get_keycode_string(event.get_physical_keycode_with_modifiers())
	pressed.connect(_on_press)
	input_timer.timeout.connect(_on_timer_timeout)

func _on_press() -> void:
	for item in buttons:
		if item is Button:
			item.disabled = true
	indicator.text = "AWAITING INPUT"
	reading_player_input = true
	input_timer.start(5.0)

func disable_buttons() -> void:
	for item in buttons:
		if item is Button:
			item.disabled = true

func enable_buttons() -> void:
	for item in buttons:
		if item is Button:
			item.disabled = false

func _input(new_event: InputEvent) -> void:
	if reading_player_input:
		if (new_event is InputEventKey):
			input_timer.stop()
			reading_player_input = false
			new_event.keycode = 0
			new_event.unicode = 0
			for event in InputMap.action_get_events(action):
				if event is InputEventKey:
					InputMap.action_erase_event(action, event)
					InputMap.action_add_event(action, new_event)
					indicator.text = OS.get_keycode_string(new_event.get_physical_keycode_with_modifiers())
			enable_buttons()

func _on_timer_timeout() -> void:
	if reading_player_input:
		enable_buttons()
		for event in InputMap.action_get_events(action):
			if event is InputEventKey:
				indicator.text = OS.get_keycode_string(event.get_physical_keycode_with_modifiers())
		reading_player_input = false
