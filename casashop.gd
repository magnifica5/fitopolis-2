extends TextureButton

func _ready() -> void:
	pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
	print("Butonul a fost apasat cu succes!")
	var poza_y = preload("res://assets/nigu14.png")
	
	# PASUL NOU: Salvăm poza în Autoload ca să nu se piardă la schimbarea scenei
	Itemshop.textura_salvata = poza_y
	
	Itemshop.schimba_poza_mouse.emit(poza_y) 
	get_tree().change_scene_to_file("res://oras2.0.tscn")
