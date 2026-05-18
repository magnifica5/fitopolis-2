## LanguageSwitcher.gd
#extends TextureButton
#
#@export var languages: Array[String] = ["ro", "en"]
#@onready var label = $Label
#var current_index := 0
#
#func _ready() -> void:
	#pass
#func _pressed() -> void:
	#current_index = (current_index + 1) % languages.size()
	#Localization.set_language(languages[current_index])
	#if languages[current_index] == "ro":
		#label.text = "EN"
	#else:
		#label.text = "RO"
# LanguageSwitcher.gd
extends TextureButton

@onready var label = $Label

func _ready() -> void:
	update_label()

	# actualizează automat dacă limba se schimbă din altă parte
	Localization.language_changed.connect(update_label)

func _pressed() -> void:
	if Localization.current_language == "ro":
		Localization.set_language("en")
	else:
		Localization.set_language("ro")

func update_label() -> void:
	# butonul arată limba în care vei schimba
	if Localization.current_language == "ro":
		label.text = "EN"
	else:
		label.text = "RO"
