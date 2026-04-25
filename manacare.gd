extends Node2D
@onready var rm = $miss_nutri
@onready var rs = $santos

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var personaj = Globals.citeste_personaj()
	if personaj == 1:
		rm.play()
	else:
		rs.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _back_to_levels() -> void:
	$AudioStreamPlayer.play()
	await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_file("res://complete_activity.tscn")
