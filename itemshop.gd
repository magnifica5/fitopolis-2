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
		var cale_tex = ""
		
		if este_distrusa:
			# Verificăm dacă clădirii i s-a atribuit deja o variantă distrusă în salvare
			cale_tex = date.get("cale_distrusa_salvata", "")
			
			# Dacă nu are una salvată, alegem una random din cele 6 posibile
			if cale_tex == "" or not ResourceLoader.exists(cale_tex):
				var variante_distruse = [
					"res://casa.distrusa.png",
					"res://casa.distrusa1.png",
					"res://casa.distrusa2.png",
					"res://casa.distrusa3.png"
				]
				# Filtrăm doar variantele care există fizic în proiect
				var variante_valide = []
				for v in variante_distruse:
					if ResourceLoader.exists(v):
						variante_valide.append(v)
				
				if not variante_valide.is_empty():
					variante_valide.shuffle()
					cale_tex = variante_valide[0]
					# O salvăm în dicționar ca să rămână aceeași textură când dai reload
					date["cale_distrusa_salvata"] = cale_tex
				else:
					cale_tex = "res://casa.distrusa.png" # Fallback final
		else:
			cale_tex = date.get("texture", "")

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
