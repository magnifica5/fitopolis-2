# LocalizedLabel.gd
extends Label

@export var translation_key: String = "greeting"

func _ready() -> void:
	pass

#func _update_text() -> void:
	#text = Localization.get_text(translation_key)
