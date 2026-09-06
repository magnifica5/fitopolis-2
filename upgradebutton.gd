extends TextureButton

# Căutăm TextureRect-ul care este și el copil al aceluiași CanvasLayer
@onready var textura_tinta: TextureRect = $"../TextureRect" 
func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	$AudioStreamPlayer.play()
	await get_tree().create_timer(0.1).timeout
	if textura_tinta:
		textura_tinta.visible = true
