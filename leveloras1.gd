extends TileMapLayer

func _ready() -> void:
	if Itemshop.cladiri.is_empty():
		Itemshop.incarca_jocul()
	
	for date_casa in Itemshop.cladiri:
		recreaza_casa(date_casa)

func recreaza_casa(date: Dictionary) -> void:
	if not date.has("texture") or not date.has("position_x") or not date.has("position_y"):
		print("Eroare: Datele clădirii sunt corupte sau incomplete în fișier!")
		return
		
	if date["texture"] == "res://" or date["texture"] == "":
		print("Ignorat: Textură invalidă în fișier (cale goală).")
		return

	var tex = load(date["texture"])
	if not tex:
		print("Eroare: Nu s-a putut încărca textura de la calea: ", date["texture"])
		return

	var casa := Sprite2D.new()
	casa.texture = tex
	
	add_child(casa)
	
	# NOU: Extragem scala salvată în JSON (dacă nu există dintr-o salvare veche, punem fallback 1.0)
	var s_factor = date.get("scale_casa", 1.0)
	
	# Înlocuim Vector2(2,2) cu scala dinamică stocată în s_factor
	casa.scale = Vector2(s_factor, s_factor) / scale 
	
	casa.global_position = Vector2(date["position_x"], date["date_casa" if date.has("date_casa") else "position_y"]) 
	# (Siguranță pentru axa Y pe care o aveai deja):
	casa.global_position.y = date["position_y"]
