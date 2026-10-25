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
	var file := FileAccess.open(pending_path(identity), FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(pending))
	file.flush()
	var ok := file.get_error() == OK
	file.close()
	return ok

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
	if not pending.is_empty() and _saved_locally(str(pending.request_id)):
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

func finish_placement() -> bool:
	var id := placement_request()
	if id.is_empty() or not _saved_locally(id):
		return false
	# Daca stergerea esueaza, markerul din casa previne reluarea platii la urmatorul click.
	_clear_pending(selected_context)
	selected_request = ""
	selected_context = ""
	return true

func show_error(message: String) -> void:
	var popup := AcceptDialog.new()
	popup.title = "Cumparare casa"
	popup.dialog_text = message
	get_tree().root.add_child(popup)
	popup.confirmed.connect(popup.queue_free)
	popup.canceled.connect(popup.queue_free)
	popup.popup_centered()

func guard_navigation() -> void:
	busy = true
	await get_tree().process_frame
	busy = false
