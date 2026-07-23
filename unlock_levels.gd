extends Node

const SAVE_PATH = "user://savegame.json"

var unlocked_levels = []  
var start_time = 0         

func save_data():
	var key = Globals.get_secure_key()
	var file = FileAccess.open_encrypted(SAVE_PATH, FileAccess.WRITE, key)
	if file:
		var data = {
			"unlocked_levels": unlocked_levels,
			"start_time": start_time
		}
		file.store_string(JSON.stringify(data))
		file.close()

func load_data():
	if FileAccess.file_exists(SAVE_PATH):
		var key = Globals.get_secure_key()
		var file = FileAccess.open_encrypted(SAVE_PATH, FileAccess.READ, key)
		var data = JSON.parse_string(file.get_as_text())
		file.close()
		if data:
			unlocked_levels = data.get("unlocked_levels", [])
			start_time = data.get("start_time", 0)
func init_start_time():
	if start_time == 0:
		start_time = Time.get_unix_time_from_system()
		save_data()
