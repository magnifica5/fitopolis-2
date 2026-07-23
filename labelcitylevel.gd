# LocalizedLabel.gd
extends Label

@export var translation_key: String = "citylevel"

func _ready() -> void:
	Localization.language_changed.connect(_update_text)
	GameState.level_updated.connect(_update_text) # Reîmprospătează textul la semnal!
	_update_text()

func _update_text() -> void:
	var text_tradus = Localization.get_text(translation_key)
	var valoare = GameState.valoare_globala + 1
	
	text = text_tradus + " " + str(valoare)
