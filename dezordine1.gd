extends TileMapLayer # sau Node2D / CanvasItem

@export var x: int 

func _ready() -> void:
	actualizeaza_vizibilitate()

func actualizeaza_vizibilitate() -> void:
	if x == 1:
		# 1. Testăm mai întâi dacă nodul curent este Layer4
		if name == "Layer4":
			visible = true
			return

		# 2. Extragerea numărului din denumire (ex: "Layer7" -> 7)
		# Înlocuim textul "Layer" cu un șir vid pentru a rămâne doar numărul
		var text_numar = name.replace("Layer", "")
		
		if text_numar.is_valid_int():
			var numar_layer = text_numar.to_int()
			var limita_maxima = GameState.valoare_globala
			
			# 3. Parcurgere for(i = 2; i <= GameState.valoare_globala; i++)
			for i in range(2, limita_maxima + 1):
				# Calculăm formula specifiică: (numar - 3) / 2
				var calcul_formula = (numar_layer - 3) / 2.0
				
				# Verificăm dacă rezultatul formulei este exact i (sau <= limita_maxima)
				if calcul_formula == i and calcul_formula <= limita_maxima:
					visible = true
					break # Am găsit potrivirea, oprim bucla
