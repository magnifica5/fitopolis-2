extends TextureButton

func _ready() -> void:
	pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
	print("Butonul a fost apasat cu succes!")
	var poza_y = preload("res://assets/nigu22.png")
	
	# --- PASUL DE REDIMENSIONARE (Corectat pentru Godot 4) ---
	var img: Image = poza_y.get_image()
	
	# Am schimbat în Image.INTERPOLATE_LANCZOS

	
	var poza_modificata = ImageTexture.create_from_image(img)
	# ---------------------------------------------------------
	
	# Salvăm în Autoload
	Itemshop.textura_salvata = poza_modificata
	Itemshop.schimba_poza_mouse.emit(poza_modificata) 
	
	# Schimbăm scena
	var tree = get_tree()
	if tree:
		tree.change_scene_to_file("res://oras2.0.tscn")
	else:
		print("Eroare: Nodul nu este încă în Scene Tree!")
