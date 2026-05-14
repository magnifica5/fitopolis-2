# LanguageSwitcher.gd
extends TextureButton

@export var languages: Array[String] = ["ro", "en"]
var current_index := 0

func _pressed() -> void:
	current_index = (current_index + 1) % languages.size()
	Localization.set_language(languages[current_index])
# Localization.gd (Autoload/Singleton)
