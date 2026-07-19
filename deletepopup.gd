extends ColorRect

# Memoria pop-up-ului: ce index din Itemshop.cladiri vrem să ștergem?
var index_casa_de_sters: int = -1

func _ready() -> void:
	# Ne asigurăm că la începutul jocului pop-up-ul este ascuns
	visible = false

# Funcție publică apelată din modul tău de Delete când dai click pe o casă
func deschide_confirmare(index_cladire: int) -> void:
	index_casa_de_sters = index_cladire
	visible = true # Afișăm întregul pop-up

# Logica pentru butonul YES
func confirma_stergerea() -> void:
	if index_casa_de_sters != -1 and index_casa_de_sters < Itemshop.cladiri.size():
		# 1. Ștergem datele din array-ul global din Autoload
		Itemshop.cladiri.remove_at(index_casa_de_sters)
		
		# 2. Salvăm modificarea în fișier
		Itemshop.salveaza_jocul()
		
		Itemshop.delete_mode = false
		
		# 3. Reîncărcăm scena curentă pentru a curăța fizic Sprite2D-ul de pe hartă
		get_tree().reload_current_scene()
	
	inchide_pop_up()

# Logica pentru butoanele NO și X
func inchide_pop_up() -> void:
	index_casa_de_sters = -1
	visible = false
