extends LineEdit
# label da cu rosu msj daca nu e corect, cand e corect se face verde in input
@onready var label = $"Label-somn"
func _ready():
	connect("text_changed", Callable(self, "_on_text_changed"))
	add_theme_color_override("font_color", Color.WHITE)
	label.text = ""
	Globals.somn = 0
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
		Globals.somn = 0
		label.text = "Format invalid (HH:MM)"
		return
	
	var hour = int(text.substr(0, 2))
	var minute = int(text.substr(3, 2))
	var total_minutes = hour * 60 + minute
	var min_allowed = 20 * 60 + 40 
	var max_allowed = 22 * 60  
	if minute < 0 or minute > 59:
		Globals.somn = 0
		#add_theme_color_override("font_color", Color.RED)
		#placeholder_text = "Minute invalide (0–59)"
		label.text = "Minute invalide (0–59)" 

	elif total_minutes < min_allowed or total_minutes > max_allowed:
		Globals.somn = 0
		label.text = "În afara intervalului (20:40–22:00)"
		return
	elif total_minutes <= Globals.cina and Globals.cina != 0:
		label.text = "Respectati ordinea activităților."
		Globals.somn = 0
		return
	elif Globals.cina == 0:
		label.text = "Stergeti si completati casetele anterioare."
		Globals.somn = 0
		return
	elif total_minutes - Globals.trezire < 600:
		add_theme_color_override("font_color", Color.WHITE)
		label.text = "Nu sunt 10 ore de somn in intervalul selectat."
	else:
		Globals.somn = total_minutes
		add_theme_color_override("font_color", Color.GREEN)
		label.text = ""
