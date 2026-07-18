extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SoundManager.stop_music()
	SoundManager.play_music(preload("res://audio/menu_music.mp3"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _to_start() -> void:
	$AudioStreamPlayer.play()
	await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_file("res://start.tscn")
