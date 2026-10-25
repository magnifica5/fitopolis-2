#extends RefCounted
## Doar starea notificarii locale; nu acorda medalii pe server.
#var context := ""
#var seen: Dictionary = {}
#
#func configure(profile: String) -> void:
	#if context == profile:
		#return
	#context = profile
	#seen = {}
	#if context.is_empty() or not FileAccess.file_exists(_path()):
		#return
	#var file := FileAccess.open(_path(), FileAccess.READ)
	#if file == null:
		#return
	#if file.get_length() > 16384:
		#file.close()
		#return
	#var parser := JSON.new()
	#var error := parser.parse(file.get_as_text())
	#file.close()
	#if error != OK or not parser.data is Dictionary:
		#return
	#for i in range(1, 9):
		#var key := "badge" + str(i)
		#if parser.data.get(key) == true:
			#seen[key] = true
#
#func _path() -> String:
	#return "user://badges_seen_v1_" + context.sha256_text() + ".json"
#
#func has_unseen(badges: Dictionary) -> bool:
	#if context.is_empty():
		#return false
	#for i in range(1, 9):
		#var key := "badge" + str(i)
		#if int(badges.get(key, 0)) == 1 and not seen.has(key):
			#return true
	#return false
#
#func mark_seen(badges: Dictionary) -> void:
	#if context.is_empty():
		#return
	#var changed := false
	#for i in range(1, 9):
		#var key := "badge" + str(i)
		#if int(badges.get(key, 0)) == 1 and not seen.has(key):
			#seen[key] = true
			#changed = true
	#if not changed:
		#return
	#var file := FileAccess.open(_path(), FileAccess.WRITE)
	#if file == null:
		#push_warning("Nu am putut salva medaliile vazute pe acest dispozitiv.")
		#return
	#file.store_string(JSON.stringify(seen))
	#file.close()

extends RefCounted

var context: String = ""
var seen: Dictionary = {}

const BADGE_COUNT := 8

func configure(profile: String) -> void:
	context = profile
	seen.clear()

	if context.is_empty():
		return

	if not FileAccess.file_exists(_path()):
		return

	var file := FileAccess.open(_path(), FileAccess.READ)
	if file == null:
		return

	if file.get_length() > 16384:
		file.close()
		return

	var json_text := file.get_as_text()
	file.close()

	var data = JSON.parse_string(json_text)

	if not data is Dictionary:
		return

	for i in range(1, BADGE_COUNT + 1):
		var key := "badge" + str(i)

		if data.get(key, false) == true:
			seen[key] = true


func _path() -> String:
	return "user://badges_seen_v1_" + context.sha256_text() + ".json"


func has_unseen(badges: Dictionary) -> bool:
	if context.is_empty():
		return false

	for i in range(1, BADGE_COUNT + 1):
		var key := "badge" + str(i)

		var unlocked := int(badges.get(key, 0)) == 1

		if unlocked and not seen.get(key, false):
			print("Medalie noua detectata: ", key)
			return true

	return false


func mark_seen(badges: Dictionary) -> void:
	if context.is_empty():
		return

	var new_seen := seen.duplicate()
	var changed := false

	for i in range(1, BADGE_COUNT + 1):
		var key := "badge" + str(i)

		var unlocked := int(badges.get(key, 0)) == 1

		if unlocked and not new_seen.get(key, false):
			new_seen[key] = true
			changed = true

	if not changed:
		return

	var file := FileAccess.open(_path(), FileAccess.WRITE)

	if file == null:
		push_warning("Nu am putut salva medaliile.")
		return

	file.store_string(JSON.stringify(new_seen))
	file.close()

	seen = new_seen

	print("Medalii vazute salvate: ", seen)
