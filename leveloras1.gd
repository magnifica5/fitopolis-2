extends TileMapLayer

func _ready() -> void:
	if Itemshop.cladiri.is_empty():
		Itemshop.incarca_jocul()
	
	for date_casa in Itemshop.cladiri:
		recreaza_casa(date_casa)

func recreaza_casa(date: Dictionary) -> void:
	if not date.has("position_x") or not date.has("position_y"):
		print("Eroare: Datele clădirii sunt incomplete (lipsesc coordonatele)!")
		return

	var calea_normala = date.get("texture", "")
	if calea_normala == "" or calea_normala == "res://":
		print("Ignorat: Textură invalidă în fișier (cale goală).")
		return

	if not ResourceLoader.exists(calea_normala):
		print("Eroare: Nu s-a găsit textura normală la calea: ", calea_normala)
		return

	var tex_normala = load(calea_normala)
	if not tex_normala:
		print("Eroare: Nu s-a putut încărca textura normală.")
		return

	const CALE_DISTRUSA = "res://casa.distrusa.png"
	var tex_finala = tex_normala
	
	# Factorii de corecție pentru a forța casa distrusă să aibă exact aceleași dimensiuni fizice ca cea normală
	var corectie_x = 1.0
	var corectie_y = 1.0

	var este_distrusa = date.get("distrusa", false)
	if este_distrusa:
		if ResourceLoader.exists(CALE_DISTRUSA):
			var tex_distrusa = load(CALE_DISTRUSA)
			if tex_distrusa:
				tex_finala = tex_distrusa
				
				var dim_normala = tex_normala.get_size()
				var dim_distrusa = tex_distrusa.get_size()
				
				# Calculăm exact raportul dintre textura normală și cea distrusă
				# Astfel, indiferent cât de mare sau mică e imaginea "casa.distrusa.png", 
				# ea va fi redimensionată automat la pixel exact cu imaginea normală a casei respective.
				if dim_distrusa.x > 0 and dim_distrusa.y > 0:
					corectie_x = dim_normala.x / dim_distrusa.x
					corectie_y = dim_normala.y / dim_distrusa.y
		else:
			print("Atenție: Textura distrusă nu există la calea: ", CALE_DISTRUSA)

	var casa := Sprite2D.new()
	casa.texture = tex_finala
	
	# Setează Z-Index global mare pentru ca clădirea să stea PESTE distrugeri
	casa.z_index = date.get("z_index", 10)
	casa.z_as_relative = date.get("z_as_relative", false)
	
	add_child(casa)
	
	# Extragem scala salvată în JSON (dacă nu există dintr-o salvare veche, punem fallback 1.0)
	var s_factor = date.get("scale_casa", 1.0)
	
	# Aplicăm scala de bază a casei înmulțită cu factorul de corecție a texturii distruse
	var scala_baza = Vector2(s_factor, s_factor) / scale
	casa.scale = Vector2(scala_baza.x * corectie_x, scala_baza.y * corectie_y)
	
	casa.global_position = Vector2(date["position_x"], date["position_y"])
