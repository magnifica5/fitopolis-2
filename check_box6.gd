extends CheckBox


# Called when the node enters the scene tree for the first time.
@export var translation_key: String = "Activities before bed"
func _ready() -> void:
	Localization.language_changed.connect(_update_text)
	_update_text()

func _update_text() -> void:
	text = Localization.get_text(translation_key)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
