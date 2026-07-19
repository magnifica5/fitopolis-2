extends TextureButton

func _ready() -> void:
	pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
	print("Butonul a fost apasat cu succes!")
	
	var cale_imagine = "res://assets/nigu22.png"
	var poza_y = preload("res://assets/nigu22.png")
	
	var img: Image = poza_y.get_image()
	var poza_modificata = ImageTexture.create_from_image(img)
	
	# 1. Configurațiile din Autoload
	Itemshop.textura_salvata = poza_modificata
	Itemshop.cale_textura_salvata = cale_imagine
	
	# AICI SETEZI MARIMEA DORITA (de exemplu 4.5, sau 6.0, sau 2.0)
	Itemshop.scale_salvat = 2.0 
	
	# 2. Emitem semnalul
	Itemshop.schimba_poza_mouse.emit(poza_modificata) 
	
	var tree = get_tree()
	if tree:
		tree.change_scene_to_file("res://oras2.0.tscn")
