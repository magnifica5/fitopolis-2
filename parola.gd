extends Node2D
@onready var input = $CanvasLayer2/Password_Input
@onready var butoane = $CanvasLayer4
@onready var label_incorect = $CanvasLayer2/Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	butoane.visible = false
	label_incorect.visible = false
	SoundManager.sound_stop_win()
	SoundManager.sound_stop_music()
	SoundManager.stop_music()
	SoundManager.play_menu_music(preload("res://audio/menu_music.mp3"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_password_changed(new_text: String) -> void:
	if input.text != "":
		butoane.visible = true
		label_incorect.visible = false
	else:
		butoane.visible = false 
		label_incorect.visible = false


func _on_reseteaza_pressed() -> void:
	get_tree().change_scene_to_file("res://salvare_parola.tscn")


func _on_intra_pressed() -> void:
	$AudioStreamPlayer.play()
	await get_tree().create_timer(0.1).timeout
	var parola_corecta = Globals.citeste_parola()
	if parola_corecta == input.text:
		Globals.load_hours()
		var ora_curenta = Time.get_datetime_dict_from_system()
		var actual = ora_curenta.hour * 60 + ora_curenta.minute
		if actual >= Globals.parinte and actual <= Globals.parinte + 60:
			get_tree().change_scene_to_file("res://intra_bifa.tscn")
			label_incorect.visible = false
		else:
			get_tree().change_scene_to_file("res://alege_parinte.tscn")
			label_incorect.visible = false
	else:
		label_incorect.visible = true


func _catre_site() -> void:
	$AudioStreamPlayer.play()
	await get_tree().create_timer(0.1).timeout
	OS.shell_open("https://cngmm.ro/fitopolis/")


func _reseteaza() -> void:
	$AudioStreamPlayer.play()
	await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_file("res://cod_sparola.tscn")


func _back_home() -> void:
	$AudioStreamPlayer.play()
	SoundManager.sound_stop_menu()
	SoundManager.play_music(preload("res://audio/background_sound.mp3"))
	await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_file("res://login.tscn")
