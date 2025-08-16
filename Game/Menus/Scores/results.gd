class_name Results
extends MainScene

const alphabet: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

@export var letter_labels: Array[Control]
@export var frown_mat: Material

@onready var player_animator: AnimationPlayer = %TheCar.find_child("AnimationPlayer")
@onready var leaderboards: Leaderboards = %Leaderboards
@onready var name_input: Control = %NameInput
@onready var head_mesh: MeshInstance3D = %TheCar.find_child("Armature").find_child("Skeleton3D").find_child("Head_2").find_child("Head_2")

var selected_letter: int = 0
var inputting_name: bool = false


func _ready() -> void:
	%Passengers.text = str(GameVariables.score) + " Passengers"
	leaderboards.load_scores()
	if leaderboards.check_new_score(GameVariables.score):
		player_animator.play("Stand_Idle")
		%LeaderboardsLayer.visible = false
		name_input.visible = true
		inputting_name = true
		letter_labels[0].grab_focus.call_deferred()
	else:
		player_animator.play("Sad_Idle")
		head_mesh.material_override = frown_mat
		%LeaderboardsLayer.visible = true
		name_input.visible = false
		leaderboards.display_scores()
		%DoneButton.grab_focus()

func _process(delta: float) -> void:
	if not inputting_name:
		return
	for i in letter_labels.size():
		if i == 3:
			if letter_labels[i].has_focus():
				%Selector.visible = false
			else:
				letter_labels[i].grab_focus()
			selected_letter = i
		elif letter_labels[i].has_focus():
			%Selector.position.x = -20 + 20 * i
			%Selector.visible = true
			selected_letter = i
			break

func _input(event: InputEvent) -> void:
	if (not inputting_name) or selected_letter == 3:
		return
	if event is InputEventKey and event.unicode:
		letter_labels[selected_letter].text = OS.get_keycode_string(event.unicode)[0]
	elif event.is_action_released("ui_up"):
		var alphabet_index: int = alphabet.find(letter_labels[selected_letter].text)
		if alphabet_index != -1:
			letter_labels[selected_letter].text = alphabet[(alphabet_index-1)%alphabet.length()]
		else:
			letter_labels[selected_letter].text = "A"
		
	elif event.is_action_released("ui_down"):
		var alphabet_index: int = alphabet.find(letter_labels[selected_letter].text)
		if alphabet_index != -1:
			letter_labels[selected_letter].text = alphabet[(alphabet_index+1)%alphabet.length()]
		else:
			letter_labels[selected_letter].text = "A"


func _on_save_button_pressed() -> void:
	var new_name = letter_labels[0].text + letter_labels[1].text + letter_labels[2].text
	var new_score = GameVariables.score
	leaderboards.save_new_score(new_name, new_score)
	%LeaderboardsLayer.visible = true
	name_input.visible = false
	%DoneButton.grab_focus()
	inputting_name = false

func _on_done_button_pressed() -> void:
	GameVariables.stop_music.emit()
	change_scene.emit(0)
