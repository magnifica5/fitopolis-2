extends Node

const SESSION_PATH := "user://child_session.save"
var last_error := ""
var needs_pairing := false
var _user_id := ""
var _child_id := ""
var _busy := false
signal preparation_finished
const VALIDATION_WINDOW_MS := 15000
var _verified_at := -1
var _verified_context := ""
var _last_preparation_ok := false

func _session_context() -> String:
	var user = Supabase.auth.client
	if not _is_child(user) or _child_id.is_empty():
		return ""
	return str(user.id) + ":" + _child_id + ":" + str(user.access_token)

func has_recent_validation() -> bool:
	return _verified_at >= 0 and Time.get_ticks_msec() - _verified_at < VALIDATION_WINDOW_MS and not _verified_context.is_empty() and _verified_context == _session_context()

func _finish_preparation(ok: bool) -> void:
	_last_preparation_ok = ok
	if ok:
		_verified_context = _session_context()
		_verified_at = Time.get_ticks_msec()
	else:
		_verified_context = ""
		_verified_at = -1
	_busy = false
	preparation_finished.emit()

func _receive(box: Dictionary, result) -> void:
	box.result = result
	box.done = true



func _ready() -> void:
	Supabase.auth.token_refreshed.connect(_on_token_refreshed)
	Supabase.auth.signed_out.connect(_on_signed_out)


func _is_child(user) -> bool:
	return user != null and bool(user.dict.get("is_anonymous", false))


func _save() -> bool:
	var user = Supabase.auth.client
	if not _is_child(user) or user.id != _user_id or _child_id.is_empty():
		last_error = "Sesiunea copilului nu poate fi salvata."
		return false
	var file := FileAccess.open_encrypted(
		SESSION_PATH, FileAccess.WRITE, Globals.get_secure_key()
	)
	if file == null:
		last_error = "Nu pot scrie fisierul sesiunii copilului."
		return false
	file.store_string(JSON.stringify({
		"version": 1,
		"user_id": _user_id,
		"child_id": _child_id,
		"refresh_token": user.refresh_token
	}))
	file.flush()
	var status := file.get_error()
	file.close()
	if status != OK:
		last_error = "Salvarea sesiunii a esuat."
		return false
	return true


func _on_token_refreshed(user) -> void:
	if _is_child(user) and user.id == _user_id and not _child_id.is_empty():
		if not _save():
			push_error(last_error)


func _on_signed_out() -> void:
	if not _user_id.is_empty():
		forget_child()


func _clear_profile_cache() -> void:
	Globals.clear_sticker_inventory()
	if FileAccess.file_exists("user://user_data.json"):
		DirAccess.remove_absolute("user://user_data.json")
	Globals.code = ""
	Globals.connection_coded = ""
	Globals.usernamed = ""
	Globals.scored = 0
	Globals.badgesd = {}
	Globals.activitiesd = 0
	HourActivity.complete_trezire = 0
	HourActivity.complete_ex = 0
	HourActivity.complete_dejun = 0
	HourActivity.complete_pranz = 0
	HourActivity.complete_ex2 = 0
	HourActivity.complete_cina = 0
	HourActivity.complete_somn = 0
	HourActivity.activities = 0
	HourActivity.missed = 0


func forget_child() -> void:
	_verified_at = -1
	_verified_context = ""
	_last_preparation_ok = false
	_user_id = ""
	_child_id = ""
	if FileAccess.file_exists(SESSION_PATH):
		DirAccess.remove_absolute(SESSION_PATH)
	_clear_profile_cache()
	if _is_child(Supabase.auth.client):
		Supabase.auth.clear_local_session()


func _fetch_and_apply(expected_child_id: String) -> bool:
	var user = Supabase.auth.client
	if not _is_child(user):
		last_error = "Este necesara sesiunea copilului."
		return false
	var expected_user_id: String = user.id
	# RLS limiteaza ambele raspunsuri la copilul asociat sesiunii.
	# Le cerem impreuna, apoi verificam explicit ca apartin aceluiasi profil.
	var child_reply := {"done":false,"result":null}
	var progress_reply := {"done":false,"result":null}
	var task = Supabase.database.query(SupabaseQuery.new().from("children").select())
	_connect_reply(task, child_reply)
	var progress_task = Supabase.database.query(SupabaseQuery.new().from("progres_copil").select())
	_connect_reply(progress_task, progress_reply)
	var deadline := Time.get_ticks_msec() + 15000
	while not (bool(child_reply.done) and bool(progress_reply.done)):
		if Time.get_ticks_msec() >= deadline:
			last_error = "Serverul raspunde greu. Reincearca verificarea profilului."
			return false
		await get_tree().create_timer(0.01).timeout
	var result = child_reply.result
	var progress_result = progress_reply.result
	if result.error != null or not result.data is Array:
		last_error = "Profilul nu a putut fi verificat online. Reincearca."
		return false
	if result.data.is_empty():
		last_error = "Sesiunea nu mai este asociata. Cere un cod nou parintelui."
		needs_pairing = true
		forget_child()
		return false
	if result.data.size() != 1 or str(result.data[0].get("id", "")) != expected_child_id:
		last_error = "Profil diferit de cel asteptat. Acces oprit."
		return false
	var child: Dictionary = result.data[0]
	var code := str(child.get("connection_code", ""))
	if progress_result.error != null or not progress_result.data is Array:
		last_error = "Progresul nu a putut fi incarcat. Reincearca."
		return false
	if progress_result.data.size() != 1:
		last_error = "Este necesar exact un rand de progres pentru copil."
		return false
	if not _is_child(Supabase.auth.client) or Supabase.auth.client.id != expected_user_id:
		last_error = "Sesiunea s-a schimbat in timpul incarcarii."
		return false

	var progress: Dictionary = progress_result.data[0]
	if str(progress.get("connection_code", "")) != code:
		last_error = "Progresul nu corespunde copilului verificat. Acces oprit."
		return false
	_clear_profile_cache()
	Globals.adauga_code(code)
	Globals.connection_coded = code
	Globals.usernamed = child.username
	Globals.scored = child.scor
	Globals.badgesd = child.get("badges", {})
	Globals.avatar_numberd = child.avatar_number
	Globals.created_atd = child.created_at
	Globals.trezire = child.trezire
	Globals.ex = child.ex1
	Globals.dejun = child.masa_dimineata
	Globals.pranz = child.masa_pranz
	Globals.ex2 = child.ex2
	Globals.cina = child.masa_seara
	Globals.somn = child.culcare
	HourActivity.complete_trezire = int(progress.trezire)
	HourActivity.complete_ex = int(progress.ex1)
	HourActivity.complete_dejun = int(progress.masa_dimineata)
	HourActivity.complete_pranz = int(progress.masa_pranz)
	HourActivity.complete_ex2 = int(progress.ex2)
	HourActivity.complete_cina = int(progress.masa_seara)
	HourActivity.complete_somn = int(progress.somn)
	HourActivity.missed = int(progress.missed)
	HourActivity.activities = int(progress.activities)
	Globals.activitiesd = HourActivity.activities
	_user_id = expected_user_id
	_child_id = expected_child_id
	SyncManager.save_local_data()
	# Magazinul de stickere isi verifica inventarul in propriul _ready().
	return _is_child(Supabase.auth.client) and Supabase.auth.client.id == expected_user_id


func activate_current_session(child_id: String) -> bool:
	if _busy:
		return false
	_busy = true
	last_error = ""
	needs_pairing = false
	var valid := await _fetch_and_apply(child_id)
	if valid:
		valid = _save()
	_finish_preparation(valid)
	return valid


func restore_and_sync() -> bool:
	if _busy:
		await preparation_finished
		return _last_preparation_ok and has_recent_validation()
	if has_recent_validation():
		return true
	_busy = true
	last_error = ""
	needs_pairing = false
	var result := await _restore()
	_finish_preparation(result)
	return result

func _connect_reply(task, box: Dictionary) -> void:
	task.completed.connect(func(result):
		_receive(box, result)
	, CONNECT_ONE_SHOT)


func _restore() -> bool:
	if Supabase.auth.client != null and not _is_child(Supabase.auth.client):
		last_error = "Deconecteaza mai intai contul parintelui."
		return false
	if not FileAccess.file_exists(SESSION_PATH):
		last_error = "Asociaza dispozitivul folosind un cod nou."
		needs_pairing = true
		return false
	var file := FileAccess.open_encrypted(
		SESSION_PATH, FileAccess.READ, Globals.get_secure_key()
	)
	if file == null:
		last_error = "Fisierul sesiunii nu poate fi citit."
		return false
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if not data is Dictionary:
		last_error = "Fisierul sesiunii este invalid."
		return false
	_user_id = str(data.get("user_id", ""))
	_child_id = str(data.get("child_id", ""))
	var token := str(data.get("refresh_token", ""))
	if _user_id.is_empty() or _child_id.is_empty() or token.is_empty():
		last_error = "Fisierul sesiunii este incomplet."
		return false
	# La o reincercare in aceeasi rulare folosim tokenul cel mai recent.
	if _is_child(Supabase.auth.client):
		if Supabase.auth.client.id == _user_id:
			token = Supabase.auth.client.refresh_token
		else:
			Supabase.auth.clear_local_session()
	var task = await Supabase.auth.refresh_token(token, 0.0)
	var result = await task.completed
	if result.error != null:
		var status := int(result.error._error.get("_http_status", 0))
		if status in [400, 401, 403]:
			last_error = "Sesiunea a expirat sau a fost revocata. Cere un cod nou."
			needs_pairing = true
			forget_child()
		else:
			last_error = "Sesiunea nu a putut fi reinnoita. Verifica internetul si reincearca."
		return false
	if not _is_child(Supabase.auth.client) or Supabase.auth.client.id != _user_id:
		last_error = "Sesiunea restaurata nu corespunde copilului salvat."
		return false
	# Salvam tokenul rotit chiar daca urmatoarea cerere de profil esueaza.
	if not _save():
		return false
	return await _fetch_and_apply(_child_id)


func logout() -> void:
	if Supabase.auth.client != null and not _is_child(Supabase.auth.client):
		last_error = "Foloseste deconectarea contului de parinte."
		return
	if _is_child(Supabase.auth.client):
		var task = Supabase.auth.sign_out()
		await task.completed
	forget_child()
	if FileAccess.file_exists("user://start.save"):
		DirAccess.remove_absolute("user://start.save")
	get_tree().change_scene_to_file("res://alege_interfata.tscn")
