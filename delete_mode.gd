extends TextureButton

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	$AudioStreamPlayer.play()
	await get_tree().create_timer(0.1).timeout
	print("Modul de ștergere activat!")
	Itemshop.delete_mode = true
	Itemshop.edit_mode = false # Ne asigurăm că nu se suprapun modurile
	
	# Schimbăm vizibilitatea butoanelor din CanvasLayer
	var canvas = get_parent()
	if canvas:
		canvas.get_node("return").visible = true
		canvas.get_node("TextureButton").visible = false
		canvas.get_node("TextureButton2").visible = false
		canvas.get_node("TextureButton3").visible = false
		canvas.get_node("TextureButton4").visible = false
		canvas.get_node("Label2").visible = true
		canvas.get_node("Label").visible = false
		if canvas.has_node("TextureButton5"): canvas.get_node("TextureButton5").visible = false
		visible = false # Ascundem butonul curent de ștergere
