# trebuie revenit pt supabase
extends Node2D
var path = "user://start.save"
var main_scene = "res://login.tscn"
var background_login = "res://background_login.tscn"
var interfata_parinte = "res://interfata_parinte.tscn"
var alege_interfata = "res://alege_interfata.tscn"
var _starting := false
func _ready() -> void:
	await get_tree().process_frame
	SoundManager.play_music(preload("res://audio/background_sound.mp3"))
	preload_scene(main_scene)
	preload_scene(background_login)
	preload_scene(interfata_parinte)
	preload_scene(alege_interfata)
	_create_status()
	_prepare_child_early()

func _process(delta: float) -> void:
	pass

func preload_scene(path: String):
	if ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
		ResourceLoader.load_threaded_request(path)

func _create_status() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 50
	add_child(layer)

func _child_selected() -> bool:
	if not FileAccess.file_exists(path):
		return false
	var file := FileAccess.open_encrypted(path, FileAccess.READ, Globals.get_secure_key())
	return file != null and file.get_as_text().strip_edges() == "copil"

func _prepare_child_early() -> void:
	if not _child_selected():
		return
	var ok := await ChildSession.restore_and_sync()

func _enter_scene(scene_path: String) -> void:
	preload_scene(scene_path)
	var deadline := Time.get_ticks_msec() + 60000
	while ResourceLoader.load_threaded_get_status(scene_path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		if Time.get_ticks_msec() >= deadline:
			_show_session_error("Scena se incarca prea greu. Reincearca.")
			return
		await get_tree().create_timer(0.02).timeout
	var ready = get_scene(scene_path)
	if ready == null:
		_show_session_error("Scena nu a putut fi incarcata.")
		return
	get_tree().change_scene_to_packed(ready)

func get_scene(path: String):
	var status = ResourceLoader.load_threaded_get_status(path)
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		return ResourceLoader.load_threaded_get(path)
	return null

func _on_texture_button_pressed() -> void:
	if _starting:
		return
	_starting = true
	await _start_selected_account()
	_starting = false

func _show_session_error(message: String) -> void:
	var popup := AcceptDialog.new()
	popup.title = "Conectare"
	popup.dialog_text = message
	add_child(popup)
	popup.confirmed.connect(popup.queue_free)
	popup.canceled.connect(popup.queue_free)
	popup.popup_centered()

func _start_selected_account() -> void:
	#$AudioStreamPlayer.play()
	if FileAccess.file_exists(path):
		var key = Globals.get_secure_key()
		var f = FileAccess.open_encrypted(path, FileAccess.READ, key)
		if f == null:
			_show_session_error("Preferinta contului nu poate fi citita.")
			return
		var content = f.get_as_text()
		f.close()
		print(content)
		if content.strip_edges() == "copil":
			if not await ChildSession.restore_and_sync():
				if ChildSession.needs_pairing:
					get_tree().change_scene_to_file("res://autentificare_copil.tscn")
				else:
					_show_session_error(ChildSession.last_error)
				return
			await _enter_scene(main_scene)
		else:
			if await try_auto_login():
				print("Autentificare automată reușită. Navighez la dashboard.")
				await SyncManager.load_parent_data()
				var ready = get_scene(interfata_parinte)
				if ready:
					get_tree().change_scene_to_packed(ready)
				else:
					print("not ready yet")
			else:
				print("Nu s-a putut autentifica automat. Navighez la alegerea interfeței.")
				var ready = get_scene(background_login)
				if ready:
					get_tree().change_scene_to_packed(ready)
				else:
					print("not ready yet")
	else:
		var ready = get_scene(alege_interfata)
		if ready:
			get_tree().change_scene_to_packed(ready)
		else:
			print("not ready yet")

func try_auto_login() -> bool:
	if FileAccess.file_exists("user://session.save"):
		var key = Globals.get_secure_key()
		var file = FileAccess.open_encrypted("user://session.save", FileAccess.READ, key)
		if file:
			var content = file.get_as_text()
			file.close()
			var session_data = JSON.parse_string(content)
			if session_data and session_data.has("refresh_token"):
				print("Încerc să reînnoiesc sesiunea cu refresh_token...")
				var refresh_task = await Supabase.auth.refresh_token(session_data.refresh_token, 0.0)
				await refresh_task.completed
				# Verificăm dacă există o eroare
				if refresh_task.error == null:
					# IMPORTANT: Verificăm dacă user-ul a fost populat în task
					# Dacă refresh_task.user este null, încercăm să luăm datele din clientul global al plugin-ului
					var user = refresh_task.user if refresh_task.user != null else Supabase.auth.client
					if user != null:
						# Salvăm datele noi (access_token-ul se schimbă la fiecare refresh!)
						var updated_session_data = {
							"access_token": user.access_token,
							"refresh_token": user.refresh_token,
							"expires_in": user.expires_in,
							"user_id": user.id,
							"email": user.email
						}
						var updated_file = FileAccess.open_encrypted("user://session.save", FileAccess.WRITE, key)
						if updated_file:
							updated_file.store_string(JSON.stringify(updated_session_data))
							updated_file.close()
							print("Sesiune actualizată cu succes.")
						return true
					else:
						print("Eroare: Sesiunea a fost confirmată, dar datele utilizatorului lipsesc.")
						_clear_local_session()
						return false
				else:
					print("Eroare la reînnoirea sesiunii: ", refresh_task.error.message)
					# Sesiunea a expirat sau refresh_token-ul este invalid
					_clear_local_session()
					return false
			else:
				print("Fișierul de sesiune este gol sau nu conține refresh_token.")
				_clear_local_session()
				return false
		else:
			print("Eroare la deschiderea fișierului de sesiune.")
			return false
	else:
		return false # Nu există fișier de sesiune

func _clear_local_session():
	if FileAccess.file_exists("user://session.save"):
		DirAccess.remove_absolute("user://session.save")
		print("Sesiune locală ștearsă.")

func _functionare() -> void:
	#$AudioStreamPlayer.play()
	#await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_file("res://functionare.tscn")
