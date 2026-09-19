extends ScrollContainer
@onready var badge_texture: TextureRect = $VBoxContainer/HBoxContainer/TextureRect


func seteaza_badge(deblocat: bool) -> void:
	var material := badge_texture.material as ShaderMaterial

	if material == null:
		return

	material.set_shader_parameter(
		"grayscale_enabled",
		not deblocat
	)
func _ready() -> void:
	seteaza_badge(true)
