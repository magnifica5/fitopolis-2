extends Node
# Instantiat sub Itemshop de butoane. Nu necesita autoload nou.
var busy := false
var selected_request := ""
var selected_context := ""
var timeout_seconds := 15.0

func context() -> String:
	var user = Supabase.auth.client
	if user == null or not bool(user.dict.get("is_anonymous", false)):
		return ""
	var code := str(Globals.connection_coded).strip_edges()
	return "" if code.is_empty() else str(user.id) + ":" + code

func pending_path(identity: String) -> String:
	return "user://house_payment_" + identity.sha256_text() + ".json"

func _read_pending(identity: String) -> Dictionary:
	var path := pending_path(identity)
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null or file.get_length() > 4096:
		return {"invalid":true}
	var value = JSON.parse_string(file.get_as_text())
	if not value is Dictionary or not value.has_all(["item_id","request_id"]):
		return {"invalid":true}
	return value

func _write_pending(identity: String, pending: Dictionary) -> bool:
	var path := pending_path(identity)
	var temporary := path + ".tmp"
	var file := FileAccess.open(temporary, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(pending))
	file.flush()
	var ok := file.get_error() == OK
	file.close()
	return ok and DirAccess.rename_absolute(temporary, path) == OK

func _clear_pending(identity: String) -> bool:
	var path := pending_path(identity)
	return not FileAccess.file_exists(path) or DirAccess.remove_absolute(path) == OK

func _saved_locally(request_id: String) -> bool:
	# Citim acelasi fisier criptat ca Itemshop; nu modificam inventarul din memorie.
	if request_id.is_empty() or not FileAccess.file_exists(Itemshop.SAVE_PATH):
		return false
	var file := FileAccess.open_encrypted(Itemshop.SAVE_PATH, FileAccess.READ, Globals.get_secure_key())
	if file == null:
		return false
	var rows = JSON.parse_string(file.get_as_text())
	if not rows is Array:
		return false
	for row in rows:
		if row is Dictionary and str(row.get("house_payment_request", "")) == request_id:
			return true
	return false

func _failure(message: String) -> Dictionary:
	return {"ok":false,"message":message}

func purchase(item_id: String) -> Dictionary:
	if busy:
		return _failure("Asteapta cumpararea curenta.")
	busy = true
	var response := await _purchase(item_id)
	busy = false
	return response

func _purchase(item_id: String) -> Dictionary:
	var identity := context()
	if identity.is_empty():
		return _failure("Conecteaza profilul copilului.")
	var pending := _read_pending(identity)
	if pending.has("invalid"):
		return _failure("Fisierul cererii de plata nu poate fi citit. Pastreaza-l pentru verificare; plata nu a fost trimisa.")
	if not pending.is_empty() and (bool(pending.get("settled", false)) or _saved_locally(str(pending.request_id))):
		if not _clear_pending(identity):
			return _failure("Nu pot inchide cererea salvata pe dispozitiv.")
		pending = {}
	if not pending.is_empty() and str(pending.item_id) != item_id:
		return _failure("Ai o cumparare neterminata. Reapasa aceeasi casa din magazin si plaseaz-o inainte de a cumpara alta.")
	if pending.is_empty():
		var hex := Crypto.new().generate_random_bytes(16).hex_encode()
		var id := "%s-%s-%s-%s-%s" % [hex.substr(0,8),hex.substr(8,4),hex.substr(12,4),hex.substr(16,4),hex.substr(20,12)]
		pending = {"item_id":item_id,"request_id":id}
		if not _write_pending(identity, pending):
			return _failure("Nu pot salva cererea pe dispozitiv. Plata nu a fost trimisa.")
	var reply := {"done":false,"result":null}
	var task = Supabase.database.Rpc("fitopolis_pay_house", {
		"p_item_id":item_id,"p_request_id":str(pending.request_id)
	})
	task.completed.connect(func(result):
		reply.result = result
		reply.done = true
	, CONNECT_ONE_SHOT)
	var deadline := Time.get_ticks_msec() + int(timeout_seconds * 1000)
	while not bool(reply.done) and Time.get_ticks_msec() < deadline:
		await get_tree().create_timer(0.05).timeout
	if context() != identity:
		return _failure("Profilul s-a schimbat. Plata nu este aplicata profilului afisat; revino la profilul initial pentru a o relua.")
	if not bool(reply.done):
		return _failure("Nu am primit confirmarea platii. Apasa din nou aceeasi casa; aceeasi cerere nu se taxeaza de doua ori.")
	var result = reply.result
	if result.error != null:
		return _failure(str(result.error.message))
	var data = result.data
	if not data is Dictionary or not data.has_all(["ok","status","request_id","item_id","score"]):
		return _failure("Raspuns de plata invalid. Reincearca aceeasi casa.")
	if str(data.request_id) != str(pending.request_id) or str(data.item_id) != item_id:
		return _failure("Confirmarea nu corespunde cererii. Reincearca aceeasi casa.")
	print("[PLATA] produs=", item_id, " | debit=", data.get("charged", 0), " | sold_server=", data.score, " | reluare=", data.get("already_processed", false))
	Globals.scored = int(data.score)
	HourActivity.score = int(data.score)
	SyncManager.save_local_data()
	if not bool(data.ok):
		if str(data.status) == "insufficient_funds":
			_clear_pending(identity)
			return _failure("Stelute insuficiente.")
		return _failure("Plata nu a fost confirmata.")
	if str(data.status) != "paid":
		return _failure("Confirmare de plata invalida.")
	selected_context = identity
	selected_request = str(pending.request_id)
	return data

func placement_request() -> String:
	return selected_request if context() == selected_context else ""

func _settle_selected() -> bool:
	var id := placement_request()
	if id.is_empty():
		return false
	var pending := _read_pending(selected_context)
	if str(pending.get("request_id", "")) != id:
		return false
	pending["settled"] = true
	if not _write_pending(selected_context, pending):
		return false
	# Markerul settled ramane utilizabil chiar daca stergerea nu reuseste.
	_clear_pending(selected_context)
	selected_request = ""
	selected_context = ""
	return true

func finish_placement() -> bool:
	var id := placement_request()
	return not id.is_empty() and _saved_locally(id) and _settle_selected()

func abandon_placement() -> bool:
	# Inchide doar o plata deja confirmata pentru profilul curent.
	if selected_request.is_empty():
		return true
	if placement_request().is_empty() or not _settle_selected():
		show_error("Nu pot finaliza cumpararea pe dispozitiv. Reincearca inainte sa inchizi jocul.")
		return false
	return true

func upgrade_city() -> bool:
	if busy:
		show_error("Asteapta operatia curenta.")
		return false
	var target := int(GameState.valoare_globala) + 1
	var pending := _read_pending(context())
	# O confirmare pierduta poate fi reluata chiar dupa salvarea nivelului.
	if not bool(pending.get("settled", false)):
		if str(pending.get("item_id", "")) == "city_upgrade_2":
			target = 2
		elif str(pending.get("item_id", "")) == "city_upgrade_3":
			target = 3
	if target not in [2,3]:
		show_error("Ai deblocat toate zonele disponibile.")
		return false
	busy = true
	var result := await _purchase("city_upgrade_" + str(target))
	if not bool(result.get("ok", false)):
		busy = false
		show_error(str(result.get("message", "Plata nu a fost confirmata.")))
		return false
	var old_level: int = GameState.valoare_globala
	GameState.valoare_globala = maxi(old_level, target)
	if not GameState.salveaza_jocul():
		GameState.valoare_globala = old_level
		busy = false
		show_error("Plata este confirmata, dar nivelul nu s-a salvat. Reincearca upgrade-ul; nu se taxeaza din nou.")
		return false
	GameState.level_updated.emit()
	var settled := _settle_selected()
	busy = false
	if not settled:
		show_error("Nivel salvat. Finalizarea cererii locale a esuat; reincearca upgrade-ul fara o noua taxare.")
	return settled

func show_error(message: String) -> void:
	var popup := AcceptDialog.new()
	popup.title = "Cumparare casa"
	popup.dialog_text = message
	get_tree().root.add_child(popup)
	popup.confirmed.connect(popup.queue_free)
	popup.canceled.connect(popup.queue_free)
	popup.popup_centered()

const CITY_SCENE := "res://oras2.0.tscn"

func prepare_city() -> void:
	if ResourceLoader.load_threaded_get_status(CITY_SCENE) == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
		ResourceLoader.load_threaded_request(CITY_SCENE)

func _load_city() -> PackedScene:
	prepare_city()
	var deadline := Time.get_ticks_msec() + 60000
	while Time.get_ticks_msec() < deadline:
		var status := ResourceLoader.load_threaded_get_status(CITY_SCENE)
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			return ResourceLoader.load_threaded_get(CITY_SCENE) as PackedScene
		if status == ResourceLoader.THREAD_LOAD_FAILED or status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			return null
		await get_tree().create_timer(0.05).timeout
	return null

func _cover_scene() -> CanvasLayer:
	var overlay := CanvasLayer.new()
	overlay.name = "HouseSceneTransition"
	overlay.layer = 1000
	var panel := TextureRect.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	panel.stretch_mode = TextureRect.STRETCH_SCALE
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	if DisplayServer.get_name() != "headless":
		var picture := get_viewport().get_texture().get_image()
		if picture != null and not picture.is_empty():
			panel.texture = ImageTexture.create_from_image(picture)
	get_tree().root.add_child(overlay)
	overlay.add_child(panel)
	if panel.texture == null:
		var background := ColorRect.new()
		background.color = Color("344d39")
		background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		panel.add_child(background)
	var text := Label.new()
	text.text = "Se incarca orasul..."
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	text.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	text.add_theme_color_override("font_color", Color.WHITE)
	text.add_theme_color_override("font_shadow_color", Color.BLACK)
	text.add_theme_font_size_override("font_size", 30)
	panel.add_child(text)
	return overlay

func open_city(image: Texture2D = null, path: String = "", image_scale: float = 1.0) -> bool:
	if busy:
		return false
	busy = true
	var identity := context()
	var overlay := _cover_scene()
	# Afisam acoperirea inainte de incarcarea/instantierea scenei grele.
	await get_tree().process_frame
	var scene := await _load_city()
	if scene == null or context() != identity:
		overlay.queue_free()
		busy = false
		show_error("Orasul nu poate fi deschis acum. Reincearca; plata confirmata se pastreaza.")
		return false
	if image != null:
		Itemshop.textura_salvata = image
		Itemshop.cale_textura_salvata = path
		Itemshop.scale_salvat = image_scale
		Itemshop.edit_mode = false
		Itemshop.delete_mode = false
	var error := get_tree().change_scene_to_packed(scene)
	if error != OK:
		overlay.queue_free()
		busy = false
		show_error("Scena orasului nu s-a deschis. Plata confirmata se pastreaza.")
		return false
	await get_tree().scene_changed
	await get_tree().process_frame
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
	overlay.queue_free()
	busy = false
	return true
