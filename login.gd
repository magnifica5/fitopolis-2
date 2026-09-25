extends Node2D
# Called when the node enters the scene tree for the first time.
@onready var avatar_final = $bg/TextureRect2/TextureButton
@onready var label_username = $bg/TextureRect2/Label4
@onready var label_level = $bg/TextureRect2/Label2
@onready var progres_bar = $bg/TextureProgressBar
@onready var leaderboard = $leaderboard
@onready var leaderboard_scroll = $leaderboard/Leaderboard/ListOfUsers
@onready var listofusers = $leaderboard/Leaderboard/ListOfUsers
@onready var listofbadges = $leaderboard/Leaderboard/VBoxContainer
@onready var medalii = $leaderboard/Leaderboard/BADGES
@onready var clasament = $leaderboard/Leaderboard/CLASAMENT
@onready var badge1 = $leaderboard/Leaderboard/VBoxContainer/HBoxContainer/TextureRect
@onready var badge2 = $leaderboard/Leaderboard/VBoxContainer/HBoxContainer/TextureRect2
@onready var badge3 = $leaderboard/Leaderboard/VBoxContainer/HBoxContainer/TextureRect3
@onready var badge4 = $leaderboard/Leaderboard/VBoxContainer/HBoxContainer/TextureRect4
@onready var badge5 = $leaderboard/Leaderboard/VBoxContainer/HBoxContainer2/TextureRect5
@onready var badge6 = $leaderboard/Leaderboard/VBoxContainer/HBoxContainer2/TextureRect6
@onready var badge7 = $leaderboard/Leaderboard/VBoxContainer/HBoxContainer2/TextureRect7
@onready var badge8 = $leaderboard/Leaderboard/VBoxContainer/HBoxContainer2/TextureRect8
@onready var new_badge = $meniu/HBoxContainer/TextureButton2/TextureRect
@onready var new_badge2 = $leaderboard/Leaderboard/HBoxContainer/TextureButton2/TextureRect
var badge_nodes
var sprite_sheet := preload("res://assets/animals.png")
var cols := 7
var rows := 3
func _ready() -> void:
	new_badge.hide()
	new_badge2.hide()
	badge_nodes = [
		badge1, badge2, badge3, badge4,
		badge5, badge6, badge7, badge8
	]
	leaderboard.hide()
	await get_tree().process_frame
	SoundManager.sound_stop_menu()
	SoundManager.sound_stop_win()
	SoundManager.play_music(preload("res://audio/background_sound.mp3"))
	
	await HourActivity.load_progress()
	var level_now = ControlLevel.get_level(HourActivity.activities)
	var level_saved = Globals.citeste_level()
	if level_saved != level_now:
		Globals.adauga_level(str(level_now))
		get_tree().change_scene_to_file("res://upgrade_level.tscn")
		
	label_level.text = str(ControlLevel.get_level(HourActivity.activities))
	progres_bar.value = ControlLevel.get_progress(HourActivity.activities)
	Globals.code = Globals.citeste_code()
	var query = SupabaseQuery.new().from("children").select().eq("connection_code", Globals.code)
	var task = Supabase.database.query(query)
	var result = await task.completed
	if result.error == null and result.data.size() > 0:
		var data = result.data[0]
		Globals.adauga_scor(data.scor)
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
		var badges_vechi = data.get("badges", {})
		var badges_calculate = calculeaza_badges(data)

		var badges_noi = combina_badges(
			badges_vechi,
			badges_calculate
		)

		aplica_badges(badges_noi)

		var schimbari = compara_badges(
			badges_vechi,
			badges_noi
		)

		if schimbari.size() > 0:
			new_badge.show()
			new_badge2.show()
			print("Badge-uri noi: ", schimbari)
			await salveaza_badges(badges_noi)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _catre_oras_pressed() -> void:
	$AudioStreamPlayer.play()
	await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_file("res://oras2.0.tscn")


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

func _on_level_up(new_level: int):
	get_tree().change_scene_to_file("res://upgrade_level.tscn")


func _on_esc() -> void:
	leaderboard.hide()


func _leaderboard() -> void:
	leaderboard.show()
	listofusers.show()
	listofbadges.hide()
	clasament.show()
	medalii.hide()
	await leaderboard_scroll.deschide_leaderboard()

func _on_leaderboard() -> void:
	listofbadges.hide()
	listofusers.show()
	clasament.show()
	medalii.hide()

func _on_badges() -> void:
	listofbadges.show()
	listofusers.hide()
	clasament.hide()
	medalii.show()
	new_badge.hide()
	new_badge2.hide()

func seteaza_badge(deblocat: bool, badge) -> void:
	var material := badge.material as ShaderMaterial
	if material == null:
		return

	material.set_shader_parameter(
		"grayscale_enabled",
		not deblocat
	)

func calculeaza_badges(data: Dictionary) -> Dictionary:
	var zile = 0
	var date = data.created_at
	print(data.created_at)
	if date != "":
		var date_dict = Time.get_datetime_dict_from_datetime_string(date, false)
		var data_acum = Time.get_datetime_dict_from_system()
		var t_cont = Time.get_unix_time_from_datetime_dict(date_dict)
		var t_azi = Time.get_unix_time_from_datetime_dict(data_acum)
		zile = int((t_azi - t_cont) / 86400)
	var badges = {
		"badge1": int(zile >= 1),
		"badge2": int(zile >= 7),
		"badge3": int(Globals._nr_stickere() >= 12),
		"badge4": 0,
		"badge5": 0,
		"badge6": int(ControlLevel.get_level(HourActivity.activities) >= 5),
		"badge7": int(Itemshop.nr_cladiri() >= 20),
		"badge8": int(data.scor >= 1000)
	}
	return badges

func salveaza_badges(badges: Dictionary) -> void:
	var query = SupabaseQuery.new() \
		.from("children") \
		.update({"badges": badges}) \
		.eq("connection_code", Globals.code)

	var task = Supabase.database.query(query)
	var result = await task.completed

	if result.error != null:
		print("Eroare la salvarea badge-urilor: ", result.error)
	else:
		print("Badge-urile au fost salvate!")

func aplica_badges(badges: Dictionary) -> void:
	for i in range(badge_nodes.size()):
		var key = "badge" + str(i + 1)
		var deblocat = int(badges.get(key, 0)) == 1
		seteaza_badge(deblocat, badge_nodes[i])

func compara_badges(vechi: Dictionary, noi: Dictionary) -> Array:
	var schimbari = []
	for key in noi.keys():
		var valoare_veche = int(vechi.get(key, 0))
		var valoare_noua = int(noi.get(key, 0))
		if valoare_veche != valoare_noua:
			schimbari.append({
				"badge": key,
				"veche": valoare_veche,
				"noua": valoare_noua
			})
	return schimbari

func combina_badges(vechi: Dictionary, noi: Dictionary) -> Dictionary:
	var rezultat = {}

	for key in noi.keys():
		var valoare_veche = int(vechi.get(key, 0))
		var valoare_noua = int(noi.get(key, 0))

		rezultat[key] = max(valoare_veche, valoare_noua)

	return rezultat
