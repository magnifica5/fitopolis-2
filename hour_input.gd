extends LineEdit
# label da cu rosu msj daca nu e corect, cand e corect se face verde in input
@onready var label = $Label
func _ready():
	connect("text_changed", Callable(self, "_on_text_changed"))
	add_theme_color_override("font_color", Color.WHITE)
	label.text = ""
func _on_text_changed(new_text):
	add_theme_color_override("font_color", Color.WHITE)
	var filtered_text = ""
	label.text = ""
	for c in new_text:
		if c.is_valid_int() or c == ":":
			filtered_text += c

	if filtered_text != new_text:
		text = filtered_text
		caret_column = len(text)

	if text.length() != 5 or text[2] != ":":
		#add_theme_color_override("font_color", Color.RED)
		#placeholder_text = "Format invalid (HH:MM)"
		label.text = "Format invalid (HH:MM)"
		return
	
	var hour = int(text.substr(0, 2))
	var minute = int(text.substr(3, 2))

	if minute < 0 or minute > 59:
		#add_theme_color_override("font_color", Color.RED)
		#placeholder_text = "Minute invalide (0–59)"
		label.text = "Minute invalide (0–59)"
	elif hour < 6 or hour > 9:
		#dd_theme_color_override("font_color", Color.ORANGE)
		#placeholder_text = "În afara intervalului (06:00–09:00)"
		label.text = "În afara intervalului (06:00–09:00)"
	else:
		add_theme_color_override("font_color", Color.GREEN)
		#placeholder_text = "Ora validă ✅"
		label.text = ""
