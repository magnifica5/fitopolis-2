extends Node2D
var path = "user://start.save"
func _ready() -> void:
	await get_tree().process_frame
	SoundManager.play_music(preload("res://audio/background_sound.mp3"))

func _process(delta: float) -> void:
	pass
func _on_texture_button_pressed() -> void:
	$AudioStreamPlayer.play()
	if FileAccess.file_exists(path):
		var f = FileAccess.open(path, FileAccess.READ)
		var content = f.get_as_text()
		f.close()
		print(content)
		if content == "copil\n":
			get_tree().change_scene_to_file("res://login.tscn")
		else:
			if await try_auto_login():
				print("Autentificare automată reușită. Navighez la dashboard.")
				get_tree().change_scene_to_file("res://interfata_parinte.tscn")
			else:
				print("Nu s-a putut autentifica automat. Navighez la alegerea interfeței.")
				get_tree().change_scene_to_file("res://background_login.tscn")
	else:
		get_tree().change_scene_to_file("res://alege_interfata.tscn")
func try_auto_login() -> bool:
	if FileAccess.file_exists("user://session.save"):
		var file = FileAccess.open("user://session.save", FileAccess.READ)
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
						var updated_file = FileAccess.open("user://session.save", FileAccess.WRITE)
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
	$AudioStreamPlayer.play()
	await get_tree().create_timer(0.1).timeout
	Globals.adauga_locatie_info("start")
	get_tree().change_scene_to_file("res://functionare.tscn")
