extends Label

func _ready() -> void:
	
	var rezultat = GameState.valoare_globala + 1
	
	# Afișăm rezultatul în Label
	text = str(rezultat)
