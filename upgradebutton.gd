extends TextureButton

# Căutăm TextureRect-ul care este și el copil al aceluiași CanvasLayer
@onready var textura_tinta: TextureRect = $"../TextureRect" 

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	if textura_tinta:
		textura_tinta.visible = true
