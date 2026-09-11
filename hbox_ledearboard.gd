extends HBoxContainer

@onready var rank_label = $Rank
@onready var username_label = $Username
@onready var activities_label = $Activities

func setup(rank: int, username: String, activities: int):
	rank_label.text = str(rank)
	username_label.text = username
	activities_label.text = str(activities)
