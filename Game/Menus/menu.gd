class_name MainMenu
extends MainScene

@export var settings_scene: PackedScene

@onready var player_animator: AnimationPlayer = %TheCar.find_child("AnimationPlayer")
@onready var start_button: Button = %StartButton
@onready var scores_button: Button = %ScoresButton
@onready var settings_button: Button = %SettingsButton
@onready var settings_layer: CanvasLayer = %SettingsLayer
@onready var settings_menu: Settings = %Settings

func _ready() -> void:
	start_button.grab_focus.call_deferred()
	settings_menu.close_settings.connect(_on_settings_close)
	player_animator.play("Stand_Idle")
	

func _on_start_button_pressed() -> void:
	change_scene.emit(1)


func _on_scores_button_pressed() -> void:
	%Leaderboards.load_scores()
	%Leaderboards.display_scores()
	%ScoresLayer.visible = true
	%MainMenu.visible = false
	%ExitScoresButton.grab_focus()

func _input(event: InputEvent) -> void:
	if get_viewport().gui_get_focus_owner() == null:
		if (event.is_action_released("ui_accept") or event.is_action_released("ui_up") or event.is_action_released("ui_down") or event.is_action_released("ui_left") or event.is_action_released("ui_right")):
			if settings_layer.visible == true:
				pass
#				settings_menu._on_grab_focus()
			elif %ScoresLayer.visible == true:
				%ExitScoresButton.grab_focus.call_deferred()
			elif %InstructionsLayer.visible == true:
				%ExitInstructionsButton.grab_focus.call_deferred()
			else:
				start_button.grab_focus.call_deferred()
		

func _on_settings_button_pressed() -> void:
	settings_layer.visible = true
	%MainMenu.visible = false
	settings_menu._on_settings_open()

func _on_settings_close() -> void:
	settings_layer.visible = false
	%MainMenu.visible = true
	start_button.grab_focus()


func _on_exit_button_pressed() -> void:
	%ScoresLayer.visible = false
	%InstructionsLayer.visible = false
	%MainMenu.visible = true
	start_button.grab_focus()


func _on_instructions_button_pressed() -> void:
	%InstructionsLayer.visible = true
	%MainMenu.visible = false
	%ExitInstructionsButton.grab_focus()
