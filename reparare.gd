extends TextureButton # sau Button

func _ready() -> void:
	pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
	# 1. Apelăm funcția globală care setează is_destroyed = false pentru toate casele
	Itemshop.repara_toate_casele()
	
	print("Toate casele au fost reparate!")
	
	# 2. Reîncărcăm scena curentă (sau facem reload la TileMapLayer) 
	# ca să se aplice texturile originale pe ecran
	var tree = get_tree()
	if tree:
		tree.reload_current_scene()
