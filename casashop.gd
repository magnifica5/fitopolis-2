extends TextureButton


func _on_button_pressed() -> void:
	var poza_y = preload("res://assets/nigu14.png")
	Itemshop.schimba_poza_mouse.emit(poza_y) # Trimitem semnalul global
