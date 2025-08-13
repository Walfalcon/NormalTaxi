class_name MainMenu
extends MainScene

@export var level: PackedScene
@export var settings_scene: PackedScene

@onready var player_animator: AnimationPlayer = %TheCar.find_child("AnimationPlayer")
@onready var start_button: Button = %StartButton
@onready var scores_button: Button = %ScoresButton
@onready var settings_button: Button = %SettingsButton
@onready var settings_layer: CanvasLayer = %SettingsLayer
@onready var settings_menu: Settings = %Settings

func _ready() -> void:
	settings_button.grab_focus()
	settings_menu.close_settings.connect(_on_settings_close)
	

func _on_start_button_pressed() -> void:
	change_scene.emit(level)


func _on_scores_button_pressed() -> void:
	pass # Replace with function body.


func _on_settings_button_pressed() -> void:
	settings_layer.visible = true
	settings_menu._on_settings_open()

func _on_settings_close() -> void:
	settings_layer.visible = false
	settings_button.grab_focus()
