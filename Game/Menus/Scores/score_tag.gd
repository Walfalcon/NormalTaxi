class_name ScoreTag
extends Control

var score_string: String = "" :
	set(new_score):
		%Score.text = new_score

var name_string: String = "" :
	set(new_name):
		%Name.text = new_name

var rank_string: String = "" :
	set(new_rank):
		%Rank.text = new_rank
