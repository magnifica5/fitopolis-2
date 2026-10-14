extends TextureButton

# Poți schimba acest număr direct din Inspectorul Godot
@export var numar_case_de_distrus: int = 1

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	# Verificăm dacă avem clădiri salvate
	if Itemshop.cladiri.is_empty():
		print("Eroare: Nu există nicio clădire salvată în joc pentru a o distruge!")
		return

	randomize()
	
	# Copiem indicii tuturor clădirilor care sunt momentan NEDISTRUSE
	var indici_disponibili: Array = []
	for i in range(Itemshop.cladiri.size()):
		if not Itemshop.cladiri[i].get("distrusa", false):
			indici_disponibili.append(i)

	if indici_disponibili.is_empty():
		print("Toate clădirile sunt deja distruse!")
		return

	# Amestecăm aleatoriu indicii disponibili
	indici_disponibili.shuffle()

	# Determinăm câte case putem distruge efectiv (fără să depășim câte au mai rămas nedistruse)
	var cate_distrugem = min(numar_case_de_distrus, indici_disponibili.size())
	
	# Marcăm ca distruse primele N case din lista amestecată
	for j in range(cate_distrugem):
		var index_ales = indici_disponibili[j]
		Itemshop.cladiri[index_ales]["distrusa"] = true
		print("Test: Clădirea de la indexul ", index_ales, " a fost marcată ca DISTRUSĂ.")

	# Salvăm modificările în fișierul JSON criptat
	Itemshop.salveaza_jocul()

	# Restartăm scena curentă pentru a reîncărca clădirile și a vedea efectul vizual
	print("Se repornește scena pentru a aplica modificările...")
	get_tree().reload_current_scene()
