extends Node

signal schimba_poza_mouse(textura: Texture2D)

var textura_salvata: Texture2D = null
var cale_textura_salvata: String = ""

# Stocăm scala curentă stabilită de buton (implicit 1.0)
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

# --- RECONSTRUIEȘTE CASELE ÎN SCENĂ CU VARIETATE DE TEXTURI DISTRUSE ---
func populeaza_scena_cu_cladiri(target_layer: TileMapLayer) -> void:
	if target_layer == null:
		print("Eroare: Layer-ul țintă pentru încărcarea clădirilor este null!")
		return

	for date in cladiri:
		var este_distrusa = date.get("distrusa", false)
		var calea_normala = date.get("texture", "")
		var cale_tex = calea_normala
		
		if este_distrusa and calea_normala != "":
			# Generăm automat calea texturii distruse (ex: "res://casa1.png" devine "res://casa1x.png")
			var baza = calea_normala.get_basename() # Ia calea fără extensie (ex: "res://casa1")
			var calea_generata = baza + "x.png"
			
			# Verificăm dacă există fișierul specific, altfel punem un fallback (ex: "res://casa.distrusa.png")
			if ResourceLoader.exists(calea_generata):
				cale_tex = calea_generata
			else:
				print("Atenție: Nu s-a găsit textura specifică ", calea_generata, ", se folosește fallback-ul.")
				cale_tex = "res://casa.distrusa.png"

		if cale_tex == "" or not ResourceLoader.exists(cale_tex):
			continue

		var casa := Sprite2D.new()
		casa.texture = load(cale_tex)
		casa.global_position = Vector2(date.get("position_x", 0.0), date.get("position_y", 0.0))
		
		casa.z_index = date.get("z_index", 10)
		casa.z_as_relative = date.get("z_as_relative", false)
		
		target_layer.add_child(casa)
		
		var scale_val = date.get("scale_casa", 1.0)
		if typeof(scale_val) == TYPE_FLOAT or typeof(scale_val) == TYPE_INT:
			casa.scale = Vector2(scale_val, scale_val) / target_layer.scale
		elif typeof(scale_val) == TYPE_VECTOR2:
			casa.scale = scale_val / target_layer.scale
func nr_cladiri() -> int:
	if not FileAccess.file_exists(SAVE_PATH):
		print("Nu s-a găsit niciun fișier de salvare existent. Pornire curată.")
		return 0

	var key = Globals.get_secure_key()
	var file = FileAccess.open_encrypted(SAVE_PATH, FileAccess.READ, key)
	if file:
		var json_string = file.get_as_text()
		file.close()

		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result == OK:
			cladiri = json.get_data()
			return cladiri.size()
		return 0
	return 0
