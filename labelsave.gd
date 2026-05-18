extends Label


# Called when the node enters the scene tree for the first time.
@export var translation_key: String = "Save"
func _ready() -> void:
	Localization.language_changed.connect(_update_text)
	_update_text()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _update_text() -> void:
	self.text = Localization.get_text(translation_key)
