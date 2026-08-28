extends Label


@export var translation_key: String = "start_mission"
func _ready() -> void:
	#Localization.language_changed.connect(_update_text)
	#_update_text()
	pass
func _update_text() -> void:
	text = Localization.get_text(translation_key)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
