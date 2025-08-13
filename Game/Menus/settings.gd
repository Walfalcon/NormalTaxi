class_name Settings
extends Control

const slider_controller_speed: float = 0.5

@onready var main_volume_slider: Slider = %MainVolumeSlider
@onready var music_volume_slider: Slider = %MusicVolumeSlider
@onready var other_volume_slider: Slider = %OtherVolumeSlider
@onready var inputs_button: Button = %InputsButton
@onready var back_button_audio: Button = %BackButtonAudio
@onready var audio_tab: Label = %Audio

@onready var inputs_tab: Label = %Inputs
@onready var back_button_inputs: Button = %BackButtonInputs
@onready var audio_button: Button = %AudioButton

signal close_settings

var settings_open: bool = false

func _ready() -> void:
	main_volume_slider.value = GameVariables.game_volume
	music_volume_slider.value = GameVariables.music_volume
	other_volume_slider.value = GameVariables.other_volume

func _process(delta: float) -> void:
	if !settings_open:
		return
	var left_right: float = Input.get_axis("ui_left", "ui_right")
	if left_right != 0.0:
		if main_volume_slider.has_focus():
			main_volume_slider.value += left_right * slider_controller_speed * delta
		elif music_volume_slider.has_focus():
			music_volume_slider.value += left_right * slider_controller_speed * delta
		elif other_volume_slider.has_focus():
			other_volume_slider.value += left_right * slider_controller_speed * delta

func _on_settings_open() -> void:
	settings_open = true
	_on_audio_button_pressed()


func _on_inputs_button_pressed() -> void:
	audio_tab.visible = false
	inputs_tab.visible = true


func _on_back_button_pressed() -> void:
	close_settings.emit()
	settings_open = false


func _on_main_volume_slider_value_changed(value: float) -> void:
	GameVariables.game_volume = value


func _on_music_volume_slider_value_changed(value: float) -> void:
	GameVariables.music_volume = value


func _on_other_volume_slider_value_changed(value: float) -> void:
	GameVariables.other_volume = value


func _on_audio_button_pressed() -> void:
	inputs_button.grab_focus()
	audio_tab.visible = true
	inputs_tab.visible = false
