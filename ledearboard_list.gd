extends ScrollContainer

@onready var user_list: VBoxContainer = $VBoxContainer
var user_row_scene = preload("res://HboxLedearboard.tscn")
const REFRESH_MS := 30000
const TIMEOUT_MS := 15000
const MAX_CACHE_BYTES := 262144
var _context := ""
var _busy := false
var _serial := 0
var _last_success := -1
var _payload: Dictionary = {}
var _rows: Array[Control] = []
var _status: Label
var _scroll_tween: Tween

func _ready() -> void:
	_status = Label.new()
	_status.text = "Se incarca..."
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status.mouse_filter = Control.MOUSE_FILTER_IGNORE
	user_list.add_child(_status)

func _identity() -> String:
	var user = Supabase.auth.client
	if user == null or not bool(user.dict.get("is_anonymous", false)):
		return ""
	var code := str(Globals.connection_coded)
	if code.is_empty():
		return ""
	return str(user.id) + ":" + code

func _cache_path() -> String:
	return "user://leaderboard_v1_" + _context.sha256_text() + ".json"

func _valid_payload(value) -> bool:
	if not value is Dictionary:
		return false
	if typeof(value.get("version")) not in [TYPE_INT, TYPE_FLOAT] or value.version != 1:
		return false
	if not value.get("entries") is Array or value.entries.size() > 101:
		return false
	if not value.get("generated_at") is String or value.generated_at.length() > 64:
		return false
	for entry in value.entries:
		if not entry is Dictionary:
			return false
		for field in ["rank", "activities", "avatar_number"]:
			if typeof(entry.get(field)) not in [TYPE_INT, TYPE_FLOAT]:
				return false
		if not entry.get("username") is String or entry.username.length() > 48:
			return false
		if not entry.get("is_me") is bool:
			return false
		if int(entry.rank) < 1 or int(entry.activities) < 0 or int(entry.avatar_number) < 0 or int(entry.avatar_number) > 20:
			return false
	return true

func _clear_rows() -> void:
	if _scroll_tween != null:
		_scroll_tween.kill()
	for row in _rows:
		if is_instance_valid(row):
			user_list.remove_child(row)
			row.queue_free()
	_rows.clear()

func _render(data: Dictionary) -> void:
	_clear_rows()
	for entry in data.entries:
		var row = user_row_scene.instantiate()
		user_list.add_child(row)
		row.setup(int(entry.rank), str(entry.username), int(entry.activities), int(entry.avatar_number))
		row.set_meta("is_me", bool(entry.is_me))
		_rows.append(row)
	user_list.move_child(_status, user_list.get_child_count() - 1)

func _read_cache() -> void:
	if not FileAccess.file_exists(_cache_path()):
		return
	var file := FileAccess.open(_cache_path(), FileAccess.READ)
	if file == null:
		return
	if file.get_length() > MAX_CACHE_BYTES:
		file.close()
		return
	var parser := JSON.new()
	var parse_error := parser.parse(file.get_as_text())
	file.close()
	if parse_error != OK:
		return
	var parsed = parser.data
	if _valid_payload(parsed):
		_payload = parsed
		_render(_payload)

func _save_cache() -> void:
	# Daca aplicatia este inchisa in timpul scrierii, cache-ul invalid e ignorat la citire.
	var file := FileAccess.open(_cache_path(), FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(_payload))
		file.close()

func _cached_message() -> String:
	return "Date salvate: " + str(_payload.get("generated_at", ""))

func incarca_leaderboard() -> bool:
	var context := _identity()
	if context != _context:
		_serial += 1
		_busy = false
		_context = context
		_payload = {}
		_last_success = -1
		_clear_rows()
		if not context.is_empty():
			_read_cache()
	if context.is_empty():
		_status.text = "Conecteaza profilul copilului."
		return false
	if _busy:
		return false
	if _last_success >= 0 and Time.get_ticks_msec() - _last_success < REFRESH_MS:
		return true
	_busy = true
	_serial += 1
	var request := _serial
	_status.text = "Se incarca..." if _payload.is_empty() else _cached_message() + " — Se actualizeaza..."
	var reply := {"done": false, "result": null}
	var task = Supabase.database.Rpc("fitopolis_leaderboard")
	task.completed.connect(func(result):
		reply.result = result
		reply.done = true
	, CONNECT_ONE_SHOT)
	var deadline := Time.get_ticks_msec() + TIMEOUT_MS
	while not bool(reply.done) and Time.get_ticks_msec() < deadline:
		await get_tree().create_timer(0.05).timeout
		if request != _serial:
			return false
	if request != _serial:
		return false
	_busy = false
	if context != _identity():
		_context = ""
		_payload = {}
		_clear_rows()
		_status.text = "Profil schimbat. Redeschide clasamentul."
		return false
	if not bool(reply.done):
		_show_failure("Serverul raspunde greu. Redeschide clasamentul pentru a reincerca.")
		return false
	var result = reply.result
	if result.error != null:
		_show_failure("Nu am putut actualiza clasamentul. Verifica internetul sau sesiunea.")
		push_warning("Clasament: " + str(result.error.message))
		return false
	if not _valid_payload(result.data):
		_show_failure("Raspuns invalid. Redeschide clasamentul pentru a reincerca.")
		return false
	if _payload.get("entries", []) != result.data.entries or _payload.is_empty():
		_render(result.data)
	_payload = result.data.duplicate(true)
	_last_success = Time.get_ticks_msec()
	_save_cache()
	_status.text = "Clasament actualizat." if not _payload.entries.is_empty() else "Clasamentul este gol."
	return true

func _show_failure(message: String) -> void:
	_status.text = message if _payload.is_empty() else _cached_message() + " — " + message

func animeaza_leaderboard() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	if not is_visible_in_tree():
		return
	for row in _rows:
		if is_instance_valid(row) and bool(row.get_meta("is_me", false)):
			scroll_to_current_row(row)
			return

func scroll_to_current_row(row: Control) -> void:
	if _scroll_tween != null:
		_scroll_tween.kill()
	var scrollbar := get_v_scroll_bar()
	var target := clampf(row.position.y - (size.y - row.size.y) / 2.0, 0.0, maxf(0.0, scrollbar.max_value - scrollbar.page))
	_scroll_tween = create_tween()
	_scroll_tween.tween_property(self, "scroll_vertical", int(target), 0.35)
	if row.has_method("highlight_current_player"):
		row.highlight_current_player()
