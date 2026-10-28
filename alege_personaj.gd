extends Node2D

const LOADING_SCREEN = preload("res://start_loading_overlay.gd")
const NEXT_SCENE := "res://login.tscn"

var path := "user://start.save"
var _loading: CanvasLayer
var _opening := false


func _on_santos_pressed() -> void:
	await _open_character(0)


func _on_miss_nutri_pressed() -> void:
	await _open_character(1)


func _open_character(character_id: int) -> void:
	# Ignoră apăsările repetate, inclusiv pe celălalt personaj.
	if _opening:
		return

	_opening = true
	$AudioStreamPlayer.play()

	_loading = LOADING_SCREEN.new()
	get_tree().root.add_child(_loading)

	# Afișează mesajul înainte de încărcarea scenei.
	await _loading.wait_until_drawn()
	await get_tree().create_timer(0.1).timeout

	var key = Globals.get_secure_key()
	var file := FileAccess.open_encrypted(
		path,
		FileAccess.WRITE,
		key
	)

	if file == null:
		_show_error("Alegerea nu a putut fi salvată. Încearcă din nou.")
		return

	file.store_line("copil")
	file.close()
	Globals.adauga_personaj(character_id)

	# Încarcă scena în fundal.
	var status := ResourceLoader.load_threaded_get_status(NEXT_SCENE)

	if status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
		var request_error := ResourceLoader.load_threaded_request(NEXT_SCENE)

		if request_error != OK:
			_show_error("Încărcarea scenei nu a putut începe.")
			return

	var deadline := Time.get_ticks_msec() + 60000

	while true:
		status = ResourceLoader.load_threaded_get_status(NEXT_SCENE)

		if status == ResourceLoader.THREAD_LOAD_LOADED:
			break

		if status != ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			_show_error("Scena nu a putut fi încărcată.")
			return

		if Time.get_ticks_msec() >= deadline:
			_show_error("Încărcarea durează prea mult. Încearcă din nou.")
			return

		await get_tree().create_timer(0.02).timeout

	var next_scene := ResourceLoader.load_threaded_get(NEXT_SCENE) as PackedScene

	if next_scene == null:
		_show_error("Scena încărcată nu este validă.")
		return

	var change_error := get_tree().change_scene_to_packed(next_scene)

	if change_error != OK:
		_show_error("Scena nu a putut fi deschisă.")
		return

	# Suprapunerea rămâne până când noua scenă este afișată.
	_loading.finish_when_scene_ready()


func _show_error(message: String) -> void:
	if is_instance_valid(_loading):
		_loading.queue_free()

	_loading = null
	_opening = false

	var popup := AcceptDialog.new()
	popup.title = "Conectare"
	popup.dialog_text = message
	add_child(popup)
	popup.confirmed.connect(popup.queue_free)
	popup.canceled.connect(popup.queue_free)
	popup.popup_centered()
