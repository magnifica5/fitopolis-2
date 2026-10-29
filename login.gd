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
const BADGE_SEEN_STORE = preload("res://badge_seen_store.gd")
var _badge_seen = BADGE_SEEN_STORE.new()
var badge_nodes
var leaderboard_ready = false
var _badges_loading := false
var sprite_sheet := preload("res://assets/animals.png")
var cols := 7
var rows := 3
var oras = "res://oras2.0.tscn"
var stickere = "res://stikere.tscn"
var exercitii = "res://exercitii_fizice_fin.tscn"
signal modifica_score
func _ready() -> void:
	leaderboard_ready = false
	preload_scene(oras)
	preload_scene(stickere)
	preload_scene(exercitii)
	new_badge.hide()
	new_badge2.hide()
	leaderboard.hide()
	await get_tree().process_frame
	badge_nodes = [
		badge1, badge2, badge3, badge4,
		badge5, badge6, badge7, badge8
	]
	SoundManager.sound_stop_menu()
	SoundManager.sound_stop_win()
	SoundManager.play_music(preload("res://audio/background_sound.mp3"))
	var badges_anterioare: Dictionary = Globals.badgesd.duplicate(true) if Globals.badgesd is Dictionary else {}
	for badge_node in badge_nodes:
		if badge_node.material != null:
			badge_node.material = badge_node.material.duplicate()
	aplica_badges(badges_anterioare)
	_actualizeaza_notificarea_badges()
	_porneste_verificarea_badges()
	afiseaza_ui()
	await SyncManager.sync_data()
	afiseaza_ui()
	leaderboard_ready = true
	actualizeaza_medalii(badges_anterioare)
func afiseaza_ui():
	await get_tree().process_frame
	var level_now = ControlLevel.get_level(int(HourActivity.activities))
	var level_saved = Globals.citeste_level()
	if level_saved != level_now:
		Globals.adauga_level(str(level_now))
		get_tree().change_scene_to_file("res://upgrade_level.tscn")
		
	label_level.text = str(ControlLevel.get_level(int(HourActivity.activities)))
	progres_bar.value = ControlLevel.get_progress(int(HourActivity.activities))
	#Globals.code = Globals.citeste_code()
	#var query = SupabaseQuery.new().from("children").select().eq("connection_code", Globals.code)
	#var task = Supabase.database.query(query)
	#var result = await task.completed
	#if result.error == null and result.data.size() > 0:
		#var data = result.data[0]
		#Globals.adauga_scor(data.scor)
	label_username.text = Globals.usernamed
	var avatar = int(Globals.avatar_numberd)
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
	modifica_score.emit()

func preload_scene(path: String):
	ResourceLoader.load_threaded_request(path)

func get_scene(path: String):
	var status = ResourceLoader.load_threaded_get_status(path)
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		return ResourceLoader.load_threaded_get(path)
	return null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _catre_oras_pressed() -> void:
	var ready = get_scene(oras)
	if ready:
		#$AudioStreamPlayer.play()
		#await get_tree().create_timer(0.1).timeout
		get_tree().change_scene_to_packed(ready)


func _catre_exercitii() -> void:
	var ready = get_scene(exercitii)
	if ready:
		#$AudioStreamPlayer.play()
		#await get_tree().create_timer(0.1).timeout
		get_tree().change_scene_to_packed(ready)


func _on_level_1() -> void:
	#$AudioStreamPlayer.play()
	#await get_tree().create_timer(0.1).timeout
	HourActivity._on_choose_activity()

func _catre_stikere() -> void:
	var ready = get_scene(stickere)
	if ready:
		#$AudioStreamPlayer.play()
		get_tree().change_scene_to_packed(ready)

func _on_level_up(new_level: int):
	get_tree().change_scene_to_file("res://upgrade_level.tscn")


func _on_esc() -> void:
	leaderboard.hide()
	_actualizeaza_notificarea_badges()


func _leaderboard() -> void:
	if leaderboard.visible:
		return

	leaderboard.show()
	listofusers.show()
	listofbadges.hide()
	clasament.show()
	medalii.hide()

	_actualizeaza_notificarea_badges()
	actualizeaza_medalii()

	var loaded: bool = await leaderboard_scroll.incarca_leaderboard()

	if loaded and is_inside_tree() and leaderboard.visible and listofusers.visible:
		leaderboard_scroll.animeaza_leaderboard()


func _on_leaderboard() -> void:
	listofbadges.hide()
	listofusers.show()
	clasament.show()
	medalii.hide()

	_actualizeaza_notificarea_badges()


func _on_badges() -> void:
	listofbadges.show()
	listofusers.hide()
	clasament.hide()
	medalii.show()

	# Afișăm medaliile cunoscute înainte să le marcăm drept văzute.
	var badges: Dictionary = {}
	if Globals.badgesd is Dictionary:
		badges = Globals.badgesd

	aplica_badges(badges)
	_actualizeaza_notificarea_badges()

	# Dacă serverul întoarce alte medalii, funcția le afișează
	# și actualizează din nou notificarea.
	await actualizeaza_medalii()

func seteaza_badge(deblocat: bool, badge) -> void:
	var material := badge.material as ShaderMaterial
	if material == null:
		return

	material.set_shader_parameter(
		"grayscale_enabled",
		not deblocat
	)

# Doar serverul calculeaza si acorda medaliile.
func actualizeaza_medalii(anterioare: Dictionary = {}) -> void:
	if _badges_loading:
		return
	var user = Supabase.auth.client
	if user == null or not bool(user.dict.get("is_anonymous", false)):
		return
	_badges_loading = true
	var expected_user := str(user.id)
	var expected_code := str(Globals.connection_coded)
	var task = Supabase.database.Rpc("fitopolis_refresh_badges")
	var result = await task.completed
	_badges_loading = false
	if not is_inside_tree():
		return
	var current_user = Supabase.auth.client
	if current_user == null or str(current_user.id) != expected_user or str(Globals.connection_coded) != expected_code:
		return
	if result.error != null:
		push_warning("Medaliile nu au putut fi actualizate: " + str(result.error.message))
		return
	if not result.data is Dictionary or not result.data.get("badges") is Dictionary:
		push_warning("Raspuns invalid la actualizarea medaliilor.")
		return
	var badges: Dictionary = result.data.badges
	Globals.badgesd = badges.duplicate(true)
	aplica_badges(badges)
	SyncManager.save_local_data()
	_actualizeaza_notificarea_badges()

func aplica_badges(badges: Dictionary) -> void:
	for i in range(badge_nodes.size()):
		var key = "badge" + str(i + 1)
		var deblocat = int(badges.get(key, 0)) == 1
		seteaza_badge(deblocat, badge_nodes[i])

func _actualizeaza_notificarea_badges() -> void:
	var user = Supabase.auth.client

	if user == null or str(Globals.connection_coded).is_empty():
		new_badge.hide()
		new_badge2.hide()
		return

	# Fișier separat pentru fiecare cont/profil.
	var profile := str(user.id) + ":" + str(Globals.connection_coded)
	_badge_seen.configure(profile)

	var badges: Dictionary = {}
	if Globals.badgesd is Dictionary:
		badges = Globals.badgesd

	# Marcăm medaliile drept văzute doar când fila lor este deschisă.
	if leaderboard.visible and listofbadges.visible:
		_badge_seen.mark_seen(badges)

	var exista_medalii_noi: bool = _badge_seen.has_unseen(badges)

	new_badge.visible = exista_medalii_noi and not leaderboard.visible
	new_badge2.visible = exista_medalii_noi


func _porneste_verificarea_badges() -> void:
	var timer := Timer.new()
	timer.wait_time = 30.0
	timer.timeout.connect(_verifica_badges_periodic)
	add_child(timer)
	timer.start()


func _verifica_badges_periodic() -> void:
	actualizeaza_medalii()
