extends Node

signal schimba_poza_mouse(textura: Texture2D)

var textura_salvata: Texture2D = null
var cale_textura_salvata: String = ""

# NOU: Stocăm scala curentă stabilită de buton (implicit 1.0)
var scale_salvat: float = 1.0

var dragging_item := false
var cladiri: Array = []
const SAVE_PATH = "user://salvare_cladiri.json"

var edit_mode := false
var casa_editata_index := -1 # Reține poziția casei în Array ca să o putem actualiza în JSON

var delete_mode := false

func salveaza_jocul() -> void:
	var key = Globals.get_secure_key()
	var file = FileAccess.open_encrypted(SAVE_PATH, FileAccess.WRITE, key)
	if file:
		var json_string = JSON.stringify(cladiri)
		file.store_string(json_string)
		file.close()
		print("Progres salvat cu succes în user://")
	else:
		print("Eroare la crearea fișierului de salvare!")

func incarca_jocul() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		print("Nu s-a găsit niciun fișier de salvare existent. Pornire curată.")
		return
	var key = Globals.get_secure_key()
	var file = FileAccess.open_encrypted(SAVE_PATH, FileAccess.READ, key)
	if file:
		var json_string = file.get_as_text()
		file.close()

		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result == OK:
			cladiri = json.get_data()
			print("Clădirile au fost restaurate cu succes în Autoload.")
		else:
			print("Eroare la procesarea fișierului JSON!")
