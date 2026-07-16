extends Node2D
# Called when the node enters the scene tree for the first time.
@onready var avatar_final = $bg/VBoxContainer/PanelContainer/TextureButton
@onready var label_username = $bg/VBoxContainer/Label
var sprite_sheet := preload("res://assets/animals.png")
var cols := 7
var rows := 3
func _ready() -> void:
	await get_tree().process_frame
	SoundManager.sound_stop_menu()
	SoundManager.sound_stop_win()
	SoundManager.play_music(preload("res://audio/background_sound.mp3"))
	Globals.code = Globals.citeste_code()
	var query = SupabaseQuery.new().from("children").select().eq("connection_code", Globals.code)
	var task = Supabase.database.query(query)
	var result = await task.completed
	if result.error == null and result.data.size() > 0:
		var data = result.data[0]
		label_username.text = data.username
		var avatar = int(data.avatar_number)
		var sheet_size = sprite_sheet.get_size()
		var cell_size = sheet_size / Vector2(cols, rows)
		var row = int(avatar / cols)
		var col = avatar % cols
		var atlas = AtlasTexture.new()
		atlas.atlas = sprite_sheet
		atlas.region = Rect2(Vector2(col, row) * cell_size, cell_size)
		avatar_final.texture_normal = atlas
		avatar_final.texture_pressed = atlas
		avatar_final.texture_hover = atlas
		avatar_final.texture_focused = atlas
		avatar_final.texture_disabled = atlas
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
	HourActivity._on_choose_activity()

func _catre_stikere() -> void:
	$AudioStreamPlayer.play()
	get_tree().change_scene_to_file("res://stikere.tscn")
