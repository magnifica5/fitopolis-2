extends TextureButton

func _ready():
	pressed.connect(_on_pressed)

func _on_pressed():
	var preview = get_tree().current_scene.get_node("Sprite2D")
	var layer = get_tree().current_scene.get_node("Layer1")

	var casa := Sprite2D.new()
	casa.texture = preview.texture

	layer.add_child(casa)

	casa.scale = preview.scale / layer.scale
	print(preview.texture.resource_path)
	casa.global_position = preview.global_position
	Itemshop.cladiri.append({
	"texture": preview.texture.resource_path,
	"position": casa.global_position
})
