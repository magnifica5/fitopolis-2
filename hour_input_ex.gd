extends LineEdit
# label da cu rosu msj daca nu e corect, cand e corect se face verde in input
@onready var label = $"Label-ex"
@export var translation_key: String = "between 07:00 and 08:00"
@export var translation_key1: String = ""
func _ready():
	connect("text_changed", Callable(self, "_on_text_changed"))
	add_theme_color_override("font_color", Color.WHITE)
	label.text = ""
	Globals.ex = 0
	Globals.connect("verif_trezire", Callable(self, "_on_verif_trezire"))
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
		Globals.ex = 0
		translation_key1 = "Invalid format (HH:MM)"
		label.text = Localization.get_text(translation_key1)
		return
	
	var hour = int(text.substr(0, 2))
	var minute = int(text.substr(3, 2))
	var total_minutes = hour * 60 + minute
	var min_allowed = 7 * 60  
	var max_allowed = 8 * 60 
	if minute < 0 or minute > 59:
		#add_theme_color_override("font_color", Color.RED)
		#placeholder_text = "Minute invalide (0–59)"
		translation_key1 ="Invalid minutes (0–59)"
		label.text = Localization.get_text(translation_key1)
		Globals.ex = 0

	elif total_minutes < min_allowed or total_minutes > max_allowed:
		translation_key1 ="Outside the interval (07:00–08:00)"
		label.text = Localization.get_text(translation_key1)
		Globals.ex = 0
		return
	elif total_minutes <= Globals.trezire and Globals.trezire != 0:
		translation_key1 ="Respect the order of activities"
		label.text = Localization.get_text(translation_key1)
		Globals.ex = 0
		return
	elif Globals.trezire == 0:
		translation_key1 ="Delete and complete the previous boxes."
		label.text = Localization.get_text(translation_key1)
		Globals.ex = 0
		return
	elif total_minutes - Globals.trezire < 15:
		translation_key1 ="There must be at least 15 minutes between activities."
		label.text = Localization.get_text(translation_key1)
		Globals.ex = 0
		return
	else:
		Globals.ex = total_minutes
		add_theme_color_override("font_color", Color.GREEN)
		label.text = ""
		if Globals.dejun != 0:
			Globals.emit_signal("verif_ex")
func _on_verif_trezire():
	if Globals.ex <= Globals.trezire and Globals.trezire != 0:
		translation_key1 ="Respect the order of activities"
		label.text = Localization.get_text(translation_key1)
		Globals.ex = 0
		return
	elif Globals.trezire == 0:
		translation_key1 ="Delete and complete the previous boxes."
		label.text = Localization.get_text(translation_key1)
		Globals.ex = 0
		return
	elif Globals.ex - Globals.trezire < 10:
		translation_key1 ="There must be at least 15 minutes between activities."
		label.text = Localization.get_text(translation_key1)
		Globals.ex = 0
		return
	
#alinaepure@nutribalance.ro
