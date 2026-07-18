extends Node

signal schimba_poza_mouse(textura: Texture2D)

# Poza curentă stocată în memorie pentru preview/drag
var textura_salvata: Texture2D = null

# NOU: Stocăm calea texturii sub formă de text curat pentru a fi salvată corect în JSON
var cale_textura_salvata: String = ""

# Starea globală pentru mișcarea obiectelor
var dragging_item := false

# Vectorul în care vom ține lista de clădiri plasate
var cladiri: Array = []

# Calea către fișierul de salvare pe dispozitivul utilizatorului
const SAVE_PATH = "user://salvare_cladiri.json"


# Funcție care convertește array-ul de clădiri în text și îl salvează pe disc
func salveaza_jocul() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		# JSON.stringify transformă array-ul nostru într-un string simplu
		var json_string = JSON.stringify(cladiri)
		file.store_string(json_string)
		file.close()
		print("Progres salvat cu succes în user://")
	else:
		print("Eroare la crearea fișierului de salvare!")


# Funcție care citește fișierul text și încarcă datele înapoi în array-ul 'cladiri'
func incarca_jocul() -> void:
	# Dacă jocul e pornit pentru prima dată și nu există salvare, ne oprim
	if not FileAccess.file_exists(SAVE_PATH):
		print("Nu s-a găsit niciun fișier de salvare existent. Pornire curată.")
		return

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()

		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result == OK:
			# Încărcăm datele salvate înapoi în structura noastră din memorie
			cladiri = json.get_data()
			print("Clădirile au fost restaurate cu succes în Autoload.")
		else:
			print("Eroare la procesarea fișierului JSON!")
