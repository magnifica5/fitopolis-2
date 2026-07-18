extends TileMapLayer

func _ready() -> void:
	# 1. Încărcăm datele din fișier în Autoload dacă memoria e goală
	if Itemshop.cladiri.is_empty():
		Itemshop.incarca_jocul()
	
	# 2. Reconstruim toate sprite-urile salvate anterior
	for date_casa in Itemshop.cladiri:
		recreaza_casa(date_casa)

func recreaza_casa(date: Dictionary) -> void:
	# Verificare de siguranță: dicționarul trebuie să aibă cheile corecte
	if not date.has("texture") or not date.has("position_x") or not date.has("position_y"):
		print("Eroare: Datele clădirii sunt corupte sau incomplete în fișier!")
		return
		
	# Filtru pentru erori sau căi invalide generate din shop
	if date["texture"] == "res://" or date["texture"] == "":
		print("Ignorat: Textură invalidă în fișier (cale goală).")
		return

	# Încercăm să încărcăm resursa în mod securizat
	var tex = load(date["texture"])
	if not tex:
		print("Eroare: Nu s-a putut încărca textura de la calea: ", date["texture"])
		return

	var casa := Sprite2D.new()
	casa.texture = tex
	
	# O adăugăm ca și copil direct în acest TileMapLayer
	add_child(casa)
	
	# Păstrăm formula ta de scalare care folosește dimensiunea tilemap-ului
	casa.scale = Vector2(2, 2) / scale 
	
	# Reconstruim poziția globală stabilă
	casa.global_position = Vector2(date["position_x"], date["position_y"])
