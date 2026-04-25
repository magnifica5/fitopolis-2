extends Node2D
@onready var check1 = $CanvasLayer4/CheckBox
@onready var check2 = $CanvasLayer4/CheckBox2
@onready var fin = $CanvasLayer3/TextureButton2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SoundManager.stop_music()
	SoundManager.play_menu_music(preload("res://audio/menu_music.mp3"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_button_pressed() -> void:
	$AudioStreamPlayer.play()
	await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_file("res://email.tscn")


func _termeni_pressed() -> void:
	$AudioStreamPlayer.play()
	await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_file("res://termeni.tscn")


func _on_politica_pressed() -> void:
	$AudioStreamPlayer.play()
	await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_file("res://politica.tscn")
	
func _verifica():
	if check1.button_pressed and check2.button_pressed:
		fin.visible = true
	else:
		fin.visible = false


func _on_check_box_toggled(toggled_on: bool) -> void:
	_verifica()

func _on_check_box_2_toggled(toggled_on: bool) -> void:
	_verifica()
