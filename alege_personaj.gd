extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_santos_pressed() -> void:
	$AudioStreamPlayer.play()
	await get_tree().create_timer(0.1).timeout
	Globals.adauga_personaj(0)
	get_tree().change_scene_to_file("res://login.tscn")


func _on_miss_nutri_pressed() -> void:
	$AudioStreamPlayer.play()
	await get_tree().create_timer(0.1).timeout
	Globals.adauga_personaj(1)
	get_tree().change_scene_to_file("res://login.tscn")
