# GameState.gd (Autoload)
extends Node

signal level_updated

# Calea unde se va salva fișierul pe calculatorul/telefonul jucătorului
const SAVE_PATH: String = "user://gamestate_save.json"

var valoare_globala: int = 1

func _ready() -> void:
	# Încărcăm datele imediat ce jocul pornește
	incarca_jocul()

# --- FUNCȚIA DE SALVARE ---
func salveaza_jocul() -> void:
	var date_salvate := {
		"valoare_globala": valoare_globala
	}
	var key = Globals.get_secure_key()
	var json_string := JSON.stringify(date_salvate, "\t")
	var file := FileAccess.open_encrypted(SAVE_PATH, FileAccess.WRITE, key)
	
	if file:
		file.store_string(json_string)
		file.close()
		print("GameState salvat cu succes!")

# --- FUNCȚIA DE ÎNCĂRCARE ---
func incarca_jocul() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		print("Nu există salvări anterioare. Se folosesc valorile implicite.")
		return
	var key = Globals.get_secure_key()
	var file := FileAccess.open_encrypted(SAVE_PATH, FileAccess.READ, key)
	if file:
		var json_string := file.get_as_text()
		file.close()
		
		var json := JSON.new()
		var parse_result := json.parse(json_string)
		
		if parse_result == OK:
			var date: Dictionary = json.data
			if date.has("valoare_globala"):
				valoare_globala = int(date["valoare_globala"])
				level_updated.emit() # Anunțăm UI-ul că s-a încărcat o valoare nouă
				print("GameState încărcat cu succes! Valoare:", valoare_globala)
