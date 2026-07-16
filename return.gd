extends TextureButton

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	# Elimină textura salvată
	Itemshop.textura_salvata = null

	# Dacă sprite-ul ascultă semnalul, îi trimitem valoarea null
	Itemshop.schimba_poza_mouse.emit(null)

	# Schimbă vizibilitatea butoanelor
	visible = false
	get_parent().get_node("TextureButton").visible = true
	get_parent().get_node("TextureButton2").visible = true
	get_parent().get_node("TextureButton3").visible = true
	get_parent().get_node("TextureButton4").visible = false
