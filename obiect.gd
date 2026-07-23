extends Sprite2D

@export var poza: Texture2D
var dragging := false
var drag_offset := Vector2.ZERO
var indicator_fundal: ColorRect = null

func _ready():
	indicator_fundal = ColorRect.new()
	add_child(indicator_fundal)
	indicator_fundal.show_behind_parent = true 
	
	if Itemshop.textura_salvata != null:
		texture = Itemshop.textura_salvata
		scale = Vector2(Itemshop.scale_salvat, Itemshop.scale_salvat)
	else:
		texture = poza
		scale = Vector2.ONE

	Itemshop.schimba_poza_mouse.connect(schimba_textura)
	Itemshop.schimba_poza_mouse.connect(_on_schimba_poza)
	if Itemshop.textura_salvata != null:
		_on_schimba_poza(Itemshop.textura_salvata)
		actualizeaza_dimensiune_indicator()

func _on_schimba_poza(_textura: Texture2D):
	var canvas = get_parent().get_node_or_null("CanvasLayer")
	if canvas:
		canvas.get_node("return").visible = true
		canvas.get_node("TextureButton").visible = false
		canvas.get_node("TextureButton2").visible = false
		canvas.get_node("TextureButton3").visible = false
		canvas.get_node("TextureButton4").visible = true
		canvas.get_node("TextureButton5").visible = false

func actualizeaza_dimensiune_indicator() -> void:
	if texture and indicator_fundal:
		var marime_tex = texture.get_size()
		indicator_fundal.size = marime_tex
		indicator_fundal.position = -marime_tex / 2

func _process(_delta):
	var layer = get_tree().current_scene.get_node_or_null("Layer1")
	if layer == null: return
	var mouse_pos = get_global_mouse_position()
#LOGICA DE ȘTERGERE CASĂ ÎN MODUL DELETE
	if Itemshop.delete_mode:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			# Adunăm layerele active (excluzând apa Layer0 ca mai devreme)
			var layere_valide: Array[TileMapLayer] = []
			for copil in get_tree().current_scene.get_children():
				if copil is TileMapLayer and copil.name.begins_with("Layer") and copil.name != "Layer0" and copil.visible:
					layere_valide.append(copil)
			
			# Căutăm casa pe toate layerele active
			for l in layere_valide:
				var copii = l.get_children()
				for i in range(copii.size()):
					var copil = copii[i]
					if copil is Sprite2D:
						var dim_copil = copil.texture.get_size() * copil.scale * l.scale
						var rect_copil := Rect2(copil.global_position - (dim_copil / 2), dim_copil)
						
						if rect_copil.has_point(mouse_pos):
							# Am găsit casa! O căutăm în baza de date JSON după poziție
							for j in range(Itemshop.cladiri.size()):
								var c = Itemshop.cladiri[j]
								if abs(c["position_x"] - copil.global_position.x) < 5 and abs(c["position_y"] - copil.global_position.y) < 5:
									
									# AICI ESTE SCHIMBAREA: În loc să ștergem, deschidem pop-up-ul!
									# Folosim %ColorRect pentru a apela direct meniul tău unic
									var pop_up = get_tree().current_scene.find_child("ColorRect", true, false) as ColorRect
									if pop_up:
										pop_up.deschide_confirmare(j) # Îi trimitem indexul 'j'
									
									break
							break
		return
	#SELECTARE CASĂ ÎN MODUL EDITARE
	if Itemshop.edit_mode and texture == null:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not dragging:
			var copii = layer.get_children()
			for i in range(copii.size()):
				var copil = copii[i]
				if copil is Sprite2D:
					var dim_copil = copil.texture.get_size() * copil.scale * layer.scale
					var rect_copil := Rect2(copil.global_position - (dim_copil / 2), dim_copil)
					
					if rect_copil.has_point(mouse_pos):
						print("Am selectat o casă pentru mutare!")
						
						texture = copil.texture
						scale = copil.scale * layer.scale
						global_position = copil.global_position
						actualizeaza_dimensiune_indicator()
						
						for j in range(Itemshop.cladiri.size()):
							var c = Itemshop.cladiri[j]
							if abs(c["position_x"] - copil.global_position.x) < 5 and abs(c["position_y"] - copil.global_position.y) < 5:
								Itemshop.casa_editata_index = j
								Itemshop.cale_textura_salvata = c["texture"]
								Itemshop.scale_salvat = c.get("scale_casa", 1.0)
								break
						
						copil.queue_free()
						
						dragging = true
						drag_offset = global_position - mouse_pos
						Itemshop.dragging_item = true
						break
		return

	# --- LOGICA DE DRAG STANDARD ---
	if texture == null:
		if indicator_fundal: indicator_fundal.visible = false
		return

	var rect = Rect2(global_position - (texture.get_size() * scale) / 2, texture.get_size() * scale)

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if !dragging and rect.has_point(mouse_pos):
			dragging = true
			drag_offset = global_position - mouse_pos
			Itemshop.dragging_item = true
			var cam = get_viewport().get_camera_2d()
			if cam: cam.dragging = false
		if dragging:
			global_position = mouse_pos + drag_offset
	else:
		if dragging:
			dragging = false
			Itemshop.dragging_item = false
			
			if Itemshop.edit_mode:
				incearca_plasare_editata()

	actualizeaza_culoare_indicator()

func actualizeaza_culoare_indicator() -> void:
	if indicator_fundal == null or texture == null:
		if indicator_fundal: indicator_fundal.visible = false
		return
	
	# Adunăm layerele vizibile în mod dinamic
	var layere_valide: Array[TileMapLayer] = []
	for copil in get_tree().current_scene.get_children():
		if copil is TileMapLayer and copil.name.begins_with("Layer") and copil.name != "Layer0" and copil.visible:
			layere_valide.append(copil)

	if layere_valide.is_empty(): return
	indicator_fundal.visible = true

	var layer_ref = layere_valide[0]
	var dimensiune_pixel = texture.get_size() * scale
	var colt_stanga_sus = global_position - (dimensiune_pixel / 2)
	
	var grila_stanga_sus = layer_ref.local_to_map(layer_ref.to_local(colt_stanga_sus))
	var grila_dreapta_jos = layer_ref.local_to_map(layer_ref.to_local(global_position + (dimensiune_pixel / 2)))
	
	var se_poate_plasa := true
	for x in range(grila_stanga_sus.x, grila_dreapta_jos.x + 1):
		for y in range(grila_stanga_sus.y, grila_dreapta_jos.y + 1):
			var celula = Vector2i(x, y)
			var gasit_pe_vreun_layer := false
			for l in layere_valide:
				if l.get_cell_source_id(celula) != -1:
					gasit_pe_vreun_layer = true
					break
			if not gasit_pe_vreun_layer:
				se_poate_plasa = false
				break
		if not se_poate_plasa: break

	if se_poate_plasa:
		var rect_casa_noua := Rect2(colt_stanga_sus, dimensiune_pixel)
		for l in layere_valide:
			for copil in l.get_children():
				if copil is Sprite2D:
					var dim_copil = copil.texture.get_size() * copil.scale * l.scale
					var rect_copil := Rect2(copil.global_position - (dim_copil / 2), dim_copil)
					if rect_casa_noua.intersects(rect_copil):
						se_poate_plasa = false
						break

	if se_poate_plasa:
		indicator_fundal.color = Color(0.0, 1.0, 0.0, 0.4)
	else:
		indicator_fundal.color = Color(1.0, 0.0, 0.0, 0.4)


func incearca_plasare_editata() -> void:
	var layere_valide: Array[TileMapLayer] = []
	for copil in get_tree().current_scene.get_children():
		if copil is TileMapLayer and copil.name.begins_with("Layer") and copil.name != "Layer0" and copil.visible:
			layere_valide.append(copil)

	if layere_valide.is_empty(): return
	var layer_ref = layere_valide[0]
	
	var dimensiune_pixel = texture.get_size() * scale
	var colt_stanga_sus = global_position - (dimensiune_pixel / 2)
	var grila_stanga_sus = layer_ref.local_to_map(layer_ref.to_local(colt_stanga_sus))
	var grila_dreapta_jos = layer_ref.local_to_map(layer_ref.to_local(global_position + (dimensiune_pixel / 2)))
	
	var valida := true
	for x in range(grila_stanga_sus.x, grila_dreapta_jos.x + 1):
		for y in range(grila_stanga_sus.y, grila_dreapta_jos.y + 1):
			var celula = Vector2i(x, y)
			var gasit = false
			for l in layere_valide:
				if l.get_cell_source_id(celula) != -1: gasit = true; break
			if not gasit: valida = false; break
		if not valida: break

	if valida:
		var rect_casa_noua := Rect2(colt_stanga_sus, dimensiune_pixel)
		for l in layere_valide:
			for copil in l.get_children():
				if copil is Sprite2D:
					var dim_copil = copil.texture.get_size() * copil.scale * l.scale
					var rect_copil := Rect2(copil.global_position - (dim_copil / 2), dim_copil)
					if rect_casa_noua.intersects(rect_copil): valida = false; break

	if not valida:
		print("Nu poți lașa casa aici!")
		return

	# Fixăm clădirea pe primul layer activ (de exemplu Layer1)
	var target_layer = layere_valide[0]
	var casa := Sprite2D.new()
	casa.texture = texture
	target_layer.add_child(casa)
	casa.scale = scale / target_layer.scale
	casa.global_position = global_position

	if Itemshop.casa_editata_index != -1:
		Itemshop.cladiri[Itemshop.casa_editata_index] = {
			"texture": Itemshop.cale_textura_salvata,
			"position_x": casa.global_position.x,
			"position_y": casa.global_position.y,
			"scale_casa": Itemshop.scale_salvat
		}
	
	Itemshop.salveaza_jocul()

	texture = null
	Itemshop.casa_editata_index = -1
	if indicator_fundal: indicator_fundal.visible = false
	
func schimba_textura(textura_noua: Texture2D) -> void:
	if textura_noua != null:
		texture = textura_noua
		scale = Vector2(Itemshop.scale_salvat, Itemshop.scale_salvat)  
	else:
		texture = poza
		scale = Vector2.ONE
	actualizeaza_dimensiune_indicator()
