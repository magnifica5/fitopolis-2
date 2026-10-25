extends RefCounted
# Doar starea notificarii locale; nu acorda medalii pe server.
var context := ""
var seen: Dictionary = {}

func configure(profile: String) -> void:
	if context == profile:
		return
	context = profile
	seen = {}
	if context.is_empty() or not FileAccess.file_exists(_path()):
		return
	var file := FileAccess.open(_path(), FileAccess.READ)
	if file == null:
		return
	if file.get_length() > 16384:
		file.close()
		return
	var parser := JSON.new()
	var error := parser.parse(file.get_as_text())
	file.close()
	if error != OK or not parser.data is Dictionary:
		return
	for i in range(1, 9):
		var key := "badge" + str(i)
		if parser.data.get(key) == true:
			seen[key] = true

func _path() -> String:
	return "user://badges_seen_v1_" + context.sha256_text() + ".json"

func has_unseen(badges: Dictionary) -> bool:
	if context.is_empty():
		return false
	for i in range(1, 9):
		var key := "badge" + str(i)
		if int(badges.get(key, 0)) == 1 and not seen.has(key):
			return true
	return false

func mark_seen(badges: Dictionary) -> void:
	if context.is_empty():
		return
	var changed := false
	for i in range(1, 9):
		var key := "badge" + str(i)
		if int(badges.get(key, 0)) == 1 and not seen.has(key):
			seen[key] = true
			changed = true
	if not changed:
		return
	var file := FileAccess.open(_path(), FileAccess.WRITE)
	if file == null:
		push_warning("Nu am putut salva medaliile vazute pe acest dispozitiv.")
		return
	file.store_string(JSON.stringify(seen))
	file.close()
