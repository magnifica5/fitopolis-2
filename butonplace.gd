extends TextureButton

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	var preview = get_tree().current_scene.get_node("Sprite2D")
	
	if preview == null or preview.texture == null:
		print("Eroare: Preview lipsă!")
		return 

	if Itemshop.cale_textura_salvata == "" or Itemshop.cale_textura_salvata == "res://":
		print("Eroare: Calea texturii nu a fost înregistrată corect din Shop!")
		return

	# --- NOU: ADUNĂM TOATE LAYERELE ACTIVE/VIZIBILE ---
	var layere_valide: Array[TileMapLayer] = []
	
	# Căutăm în rădăcina scenei curente toate layerele active
	for copil in get_tree().current_scene.get_children():
		# Verificăm dacă nodul este un TileMapLayer, dacă numele lui începe cu "Layer" și este vizibil în joc
		if copil is TileMapLayer and copil.name.begins_with("Layer") and copil.name != "Layer0" and copil.visible:
			layere_valide.append(copil)

	if layere_valide.is_empty():
		print("Eroare: Nu s-a găsit niciun layer activ în scenă!")
		return

	# --- VERIFICARE ACOPERIRE TILE-URI PE TOATE LAYERELE ACTIVE ---
	# Luăm primul layer doar ca referință pentru calculele de grilă (au același scale)
	var layer_ref = layere_valide[0]
	
	var dimensiune_pixel = preview.texture.get_size() * preview.scale
	var colt_stanga_sus = preview.global_position - (dimensiune_pixel / 2)
	var colt_dreapta_jos = preview.global_position + (dimensiune_pixel / 2)
	
	var grila_stanga_sus = layer_ref.local_to_map(layer_ref.to_local(colt_stanga_sus))
	var grila_dreapta_jos = layer_ref.local_to_map(layer_ref.to_local(colt_dreapta_jos))
	
	var este_zona_valida := true
	
	# Scanăm fiecare celulă de sub casă
	for x in range(grila_stanga_sus.x, grila_dreapta_jos.x + 1):
		for y in range(grila_stanga_sus.y, grila_dreapta_jos.y + 1):
			var celula_curenta := Vector2i(x, y)
			var gasit_pe_vreun_layer := false
			
			# Verificăm dacă ACEASTĂ celulă are iarbă pe MĂCAR UNUL dintre layerele vizibile
			for l in layere_valide:
				if l.get_cell_source_id(celula_curenta) != -1:
					gasit_pe_vreun_layer = true
					break # Am găsit tile valid pe acest layer, trecem la următoarea celulă
			
			# Dacă pentru celula curentă niciun layer activ nu are tile, atunci zona e invalidă
			if not gasit_pe_vreun_layer:
				este_zona_valida = false
				break
				
		if not este_zona_valida:
			break

	if not este_zona_valida:
		print("Nu poți plasa aici! Casa trebuie să fie complet pe iarbă/pământ deblocat.")
		return

	# --- VERIFICARE 2: SUPRAPUNERE CU ALTE CASE ---
	var rect_casa_noua := Rect2(colt_stanga_sus, dimensiune_pixel)
	
	# Verificăm suprapunerea trecând prin casele din TOATE layerele
	for l in layere_valide:
		for copil in l.get_children():
			if copil is Sprite2D:
				var dim_copil = copil.texture.get_size() * copil.scale * l.scale
				var pos_copil_tl = copil.global_position - (dim_copil / 2)
				var rect_copil := Rect2(pos_copil_tl, dim_copil)
				
				if rect_casa_noua.intersects(rect_copil):
					print("Nu poți plasa aici! Zona este deja ocupată de o altă clădire.")
					return

	# --- PLASAREA PROPRIU-ZISĂ ---
	# Decidem să adăugăm noua casă fizic pe primul layer vizibil (Layer1 în mod normal)
	var target_layer = layere_valide[0]
	
	var casa := Sprite2D.new()
	casa.texture = preview.texture
	target_layer.add_child(casa)

	casa.scale = preview.scale / target_layer.scale
	casa.global_position = preview.global_position
	
	Itemshop.cladiri.append({
		"texture": Itemshop.cale_textura_salvata,
		"position_x": casa.global_position.x,
		"position_y": casa.global_position.y,
		"scale_casa": Itemshop.scale_salvat
	})
	
	Itemshop.salveaza_jocul()

	# --- CURĂȚARE ȘI IEȘIRE DIN MODUL PLASARE ---
	Itemshop.textura_salvata = null
	Itemshop.cale_textura_salvata = ""
	Itemshop.schimba_poza_mouse.emit(null)

	var canvas = get_parent()
	if canvas:
		canvas.get_node("return").visible = false
		canvas.get_node("TextureButton").visible = true
		canvas.get_node("TextureButton2").visible = true
		canvas.get_node("TextureButton3").visible = true
		canvas.get_node("TextureButton4").visible = false
		canvas.get_node("TextureButton5").visible = true
