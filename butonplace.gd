extends TextureButton

func _ready():
	pressed.connect(_on_pressed)

func _on_pressed():
	var preview = get_tree().current_scene.get_node("Sprite2D")
	var layer = get_tree().current_scene.get_node("Layer1")

	var casa := Sprite2D.new()
	casa.texture = preview.texture
	casa.scale = Vector2(0.1, 0.1)

	layer.add_child(casa)

	# Abia după ce este adăugată în Layer1 îi setezi poziția
	casa.global_position = preview.global_position
