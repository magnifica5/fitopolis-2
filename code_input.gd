extends LineEdit
@onready var code = Globals.citeste_code()
signal apari
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_text_changed(code_input: String) -> void:
	if str(code_input) == code:
		add_theme_color_override("font_color", Color.GREEN)
		apari.emit()
	else:
		add_theme_color_override("font_color", Color.RED)
