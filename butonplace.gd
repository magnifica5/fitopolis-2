extends TextureButton

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	var preview = get_tree().current_scene.get_node("Sprite2D")
	var layer = get_tree().current_scene.get_node("Layer1")

	if preview == null or preview.texture == null:
		print("Nu există nicio textură de plasat!")
		return 

	# Siguranță: dacă nu s-a setat nicio cale validă în Autoload
	if Itemshop.cale_textura_salvata == "" or Itemshop.cale_textura_salvata == "res://":
		print("Eroare: Calea texturii nu a fost înregistrată corect din Shop!")
		return

	var casa := Sprite2D.new()
	casa.texture = preview.texture
	layer.add_child(casa)

	casa.scale = preview.scale / layer.scale
	casa.global_position = preview.global_position
	
	# SALVARE CORECTĂ: Folosim calea stocată ca text curat
	Itemshop.cladiri.append({
		"texture": Itemshop.cale_textura_salvata,
		"position_x": casa.global_position.x,
		"position_y": casa.global_position.y
	})
	
	Itemshop.salveaza_jocul()
