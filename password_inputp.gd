extends LineEdit
@onready var label = $Label
@export var translation_key: String = ""
signal apari
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.text = ""
	Localization.language_changed.connect(_update_text)
	_update_text()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_text_changed(code_input: String) -> void:
	if str(code_input) == Globals.citeste_codep():
		translation_key = "Cod valid"
		Localization.language_changed.connect(_update_text)
		_update_text()
		add_theme_color_override("font_color", Color.GREEN)
		apari.emit()
	else:
		translation_key = "Cod invalid"
		Localization.language_changed.connect(_update_text)
		_update_text()
		add_theme_color_override("font_color", Color.RED)
func _update_text() -> void:
	label.text = Localization.get_text(translation_key)
