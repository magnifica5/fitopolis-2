extends Node2D
@export var star_scene : PackedScene
@onready var label = $CanvasLayer4/TextureRect/Label
func _ready() -> void:
	SoundManager.stop_music()
	SoundManager.sound_stop_menu()
	SoundManager.sound_stop_music()
	SoundManager.play_win_music(preload("res://audio/voices/win music 3.wav"))
	
func _process(delta: float) -> void:
	pass
	
func _back_to_levels() -> void:
	$AudioStreamPlayer.play()
	await get_tree().create_timer(0.1).timeout
	HourActivity.load_progress()
	if HourActivity.missed != 0 and HourActivity.nr_day != 1:
		get_tree().change_scene_to_file("res://missed_activity.tscn")
	else:
		HourActivity.missed = 0
		HourActivity.save_progress()
		get_tree().change_scene_to_file("res://login.tscn")
func _spawn_stars() -> void:
	for i in range(20):
		var star = star_scene.instantiate()
		add_child(star)
		var path_f1 = star.get_node("CanvasLayer6/Path2D/PathFollow2D")
		path_f1._star_movement()
		await get_tree().create_timer(0.1).timeout
	label.text = str(int(HourActivity.score))
