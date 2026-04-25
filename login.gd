extends Node2D
# Called when the node enters the scene tree for the first time.
@onready var menu = $menu
func _ready() -> void:
	await get_tree().process_frame
	SoundManager.sound_stop_menu()
	SoundManager.sound_stop_win()
	SoundManager.play_music(preload("res://audio/background_sound.mp3"))
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _catre_oras_pressed() -> void:
	$AudioStreamPlayer.play()
	get_tree().change_scene_to_file("res://oras.tscn")


func _catre_parinti() -> void:
	$AudioStreamPlayer.play()
	SoundManager.stop_music()
	SoundManager.play_menu_music(preload("res://audio/menu_music.mp3"))
	await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_file("res://parola.tscn")


func _catre_exercitii() -> void:
	$AudioStreamPlayer.play()
	await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_file("res://exercitii_dimineata.tscn")


func _on_level_1() -> void:
	$AudioStreamPlayer.play()
	await get_tree().create_timer(0.1).timeout


func _catre_stikere() -> void:
	$AudioStreamPlayer.play()
	get_tree().change_scene_to_file("res://stikere.tscn")
