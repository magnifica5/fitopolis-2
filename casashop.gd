extends TextureButton

func _ready() -> void:
	pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
	print("Butonul a fost apasat cu succes!")
	
	# Păstrăm calea într-o variabilă tip String ca să o trimitem la Autoload
	var cale_imagine = "res://assets/nigu22.png"
	var poza_y = preload("res://assets/nigu22.png")
	
	# --- PASUL DE REDIMENSIONARE (Corectat pentru Godot 4) ---
	var img: Image = poza_y.get_image()
	
	# Dacă ai nevoie de resize, poți de-comenta linia de mai jos:
	# img.resize(128, 128, Image.INTERPOLATE_LANCZOS)
	
	var poza_modificata = ImageTexture.create_from_image(img)
	# ---------------------------------------------------------
	
	# 1. Salvăm textura modificată în memorie (pentru preview)
	Itemshop.textura_salvata = poza_modificata
	
	# 2. NOU & CRUCIAL: Salvăm calea originală ca text în variabila nouă din Autoload
	Itemshop.cale_textura_salvata = cale_imagine
	
	# Emitem semnalul
	Itemshop.schimba_poza_mouse.emit(poza_modificata) 
	
	# Schimbăm scena
	var tree = get_tree()
	if tree:
		tree.change_scene_to_file("res://oras2.0.tscn")
	else:
		print("Eroare: Nodul nu este încă în Scene Tree!")
