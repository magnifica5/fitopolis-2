# LocalizedLabel.gd
extends Label

@export var translation_key: String = "Afternoon exercises:"

func _ready() -> void:
	Localization.language_changed.connect(_update_text)
	_update_text()

func _update_text() -> void:
	text = Localization.get_text(translation_key)
