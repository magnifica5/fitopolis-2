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

	var tex_finala = tex_normala
	var corectie_x = 1.0
	var corectie_y = 1.0

	var este_distrusa = date.get("distrusa", false)
	if este_distrusa:
		var calea_distrusa = date.get("cale_distrusa_salvata", "")
		
		# Dacă nu are una salvată, alegem una random
		if calea_distrusa == "" or not ResourceLoader.exists(calea_distrusa):
			var variante_distruse = [
				"res://casa.distrusa.png",
				"res://casa.distrusa1.png",
				"res://casa.distrusa2.png",
				"res://casa.distrusa3.png",
				"res://casa.distrusa4.png",
				"res://casa.distrusa5.png"
			]
			var variante_valide = []
			for v in variante_distruse:
				if ResourceLoader.exists(v):
					variante_valide.append(v)
			
			if not variante_valide.is_empty():
				variante_valide.shuffle()
				calea_distrusa = variante_valide[0]
				date["cale_distrusa_salvata"] = calea_distrusa
			else:
				calea_distrusa = "res://casa.distrusa.png"

		if ResourceLoader.exists(calea_distrusa):
			var tex_distrusa = load(calea_distrusa)
			if tex_distrusa:
				tex_finala = tex_distrusa
				var dim_normala = tex_normala.get_size()
				var dim_distrusa = tex_distrusa.get_size()
				
				if dim_distrusa.x > 0 and dim_distrusa.y > 0:
					corectie_x = dim_normala.x / dim_distrusa.x
					corectie_y = dim_normala.y / dim_distrusa.y

	var casa := Sprite2D.new()
	casa.texture = tex_finala
	
	casa.z_index = date.get("z_index", 10)
	casa.z_as_relative = date.get("z_as_relative", false)
	
	add_child(casa)
	
	var s_factor = date.get("scale_casa", 1.0)
	var scala_baza = Vector2(s_factor, s_factor) / scale
	casa.scale = Vector2(scala_baza.x * corectie_x, scala_baza.y * corectie_y)
	
	casa.global_position = Vector2(date["position_x"], date["position_y"])
