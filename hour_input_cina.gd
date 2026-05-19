extends LineEdit
# label da cu rosu msj daca nu e corect, cand e corect se face verde in input
@onready var label = $"Label-cina"
@export var translation_key: String = "between 20:00 and 20:30"
@export var translation_key1: String = ""
func _ready():
	connect("text_changed", Callable(self, "_on_text_changed"))
	add_theme_color_override("font_color", Color.WHITE)
	label.text = ""
	Globals.cina = 0
	Localization.language_changed.connect(_update_text)
	_update_text()

func _update_text() -> void:
	placeholder_text = Localization.get_text(translation_key)
	# mărește automat lățimea
	custom_minimum_size.x = get_theme_font("font").get_string_size(
		placeholder_text,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		get_theme_font_size("font_size")
	).x + 20
	label.text = Localization.get_text(translation_key1) #face sa se traduca mereu
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
		Globals.cina = 0
		translation_key1 = "Invalid format (HH:MM)"
		label.text = Localization.get_text(translation_key1)
		return
	
	var hour = int(text.substr(0, 2))
	var minute = int(text.substr(3, 2))
	var total_minutes = hour * 60 + minute
	var min_allowed = 20 * 60   
	var max_allowed = 20 * 60 + 30  
	if minute < 0 or minute > 59:
		#add_theme_color_override("font_color", Color.RED)
		#placeholder_text = "Minute invalide (0–59)"
		Globals.cina = 0
		label.text = "Minute invalide (0–59)" 

	elif total_minutes < min_allowed or total_minutes > max_allowed:
		Globals.cina = 0
		label.text = "În afara intervalului (20:00–20:30)"
		return
	elif total_minutes <= Globals.ex2 and Globals.ex2 != 0:
		label.text = "Respectati ordinea activităților."
		Globals.cina = 0
		return
	elif Globals.ex2 == 0:
		label.text = "Stergeti si completati casetele anterioare."
		Globals.cina = 0
		return
	else:
		Globals.cina = total_minutes
		add_theme_color_override("font_color", Color.GREEN)
		label.text = ""
