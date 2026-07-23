extends TextureButton

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	print("Modul de editare activat!")
	Itemshop.edit_mode = true
	
	# Schimbăm butoanele din CanvasLayer
	var canvas = get_parent()
	if canvas:
		canvas.get_node("return").visible = true
		canvas.get_node("TextureButton").visible = false
		canvas.get_node("TextureButton2").visible = false
		canvas.get_node("TextureButton3").visible = false
		canvas.get_node("TextureButton5").visible = false
		canvas.get_node("TextureButton4").visible = false
		canvas.get_node("TextureButton6").visible = true
		canvas.get_node("Label").visible = true
		$"../CanvasLayer2".visible = false
