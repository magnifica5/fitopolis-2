extends LineEdit
# label da cu rosu msj daca nu e corect, cand e corect se face verde in input
@onready var label = $"Label-parinte"
@export var translation_key: String = "between 22:00 and 00:00"
@export var translation_key1: String = ""
func _ready():
	connect("text_changed", Callable(self, "_on_text_changed"))
	add_theme_color_override("font_color", Color.WHITE)
	label.text = ""
	Globals.parinte = 0
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
		Globals.parinte = 0
		translation_key1 = "Invalid format (HH:MM)"
		label.text = Localization.get_text(translation_key1)
		return
	
	var hour = int(text.substr(0, 2))
	var minute = int(text.substr(3, 2))
	var total_minutes = hour * 60 + minute
	var min_allowed = 22 * 60
	var max_allowed = 24 * 60  
	if minute < 0 or minute > 59:
		Globals.parinte = 0
		#add_theme_color_override("font_color", Color.RED)
		#placeholder_text = "Minute invalide (0–59)"
		translation_key1 ="Invalid minutes (0–59)"
		label.text = Localization.get_text(translation_key1)

	elif total_minutes < min_allowed or total_minutes > max_allowed:
		Globals.parite = 0
		translation_key1 ="Outside the interval (22:00–00:00)"
		label.text = Localization.get_text(translation_key1)
		return
	elif total_minutes <= Globals.somn and Globals.somn != 0:
		translation_key1 ="Respect the order of activities"
		label.text = Localization.get_text(translation_key1)
		Globals.parinte = 0
		return
	elif Globals.somn == 0:
		translation_key1 ="Delete and complete the previous boxes."
		label.text = Localization.get_text(translation_key1)
		Globals.parinte = 0
		return
	else:
		Globals.parinte = total_minutes
		add_theme_color_override("font_color", Color.GREEN)
		label.text = ""
		translation_key1 = ""
		Globals.verif_hours = 1
		Globals.emit_signal("final_settings")
