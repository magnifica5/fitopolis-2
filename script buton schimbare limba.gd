# LanguageSwitcher.gd
extends TextureButton

@export var languages: Array[String] = ["ro", "en"]
@onready var label = $Label
var current_index := 0

func _pressed() -> void:
	current_index = (current_index + 1) % languages.size()
	Localization.set_language(languages[current_index])
	if languages[current_index] == "ro":
		label.text = "RO"
	else:
		label.text = "EN"
# Localization.gd (Autoload/Singleton)
