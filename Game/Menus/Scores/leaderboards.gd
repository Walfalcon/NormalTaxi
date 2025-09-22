class_name Leaderboards
extends ColorRect

@export var score_tag_scene: PackedScene

var scores: Array[int] = [0,0,0,0,0,0,0,0,0,0]
var names: Array[String] = ["AAA","AAA","AAA","AAA","AAA","AAA","AAA","AAA","AAA","AAA"]
var tags: Array[ScoreTag]

var scores_displayed: bool = false

func load_scores() -> void:
	if not FileAccess.file_exists("user://scores.save"):
		return
		
	var scores_file = FileAccess.open("user://scores.save", FileAccess.READ)
	var scores_string: String = scores_file.get_line()
	var names_string: String = scores_file.get_line()
	var json_score_array = JSON.parse_string(scores_string)
	var json_name_array = JSON.parse_string(names_string)
	for i in scores.size():
		scores[i] = int(json_score_array[i])
		names[i] = json_name_array[i]
	

func display_scores():
	if scores_displayed:
		return
	for i in range(10):
		tags.push_back(score_tag_scene.instantiate())
		tags[i].rank_string = "#" + str(i+1)
		tags[i].name_string = names[i]
		tags[i].score_string = str(scores[i])
		%Box.add_child(tags[i])
		tags[i].position.y += i * 20
	scores_displayed = true

func check_new_score(new_score: int) -> bool:
	return new_score > scores[9]

func save_new_score(new_name: String, new_score: int) -> void:
	for i in scores.size():
		if new_score > scores[i]:
			scores.insert(i, new_score)
			names.insert(i, new_name)
			scores.pop_back()
			names.pop_back()
			break
	display_scores()
	var scores_string: String = JSON.stringify(scores)
	var names_string: String = JSON.stringify(names)
	var scores_file = FileAccess.open("user://scores.save", FileAccess.WRITE)
	scores_file.store_line(scores_string)
	scores_file.store_line(names_string)
