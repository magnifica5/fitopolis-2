extends LineEdit
# label da cu rosu msj daca nu e corect, cand e corect se face verde in input
@onready var label = $"Label-ex2"
func _ready():
	connect("text_changed", Callable(self, "_on_text_changed"))
	add_theme_color_override("font_color", Color.WHITE)
	label.text = ""
	Globals.ex2 = 0
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
		Globals.ex2 = 0
		label.text = "Format invalid (HH:MM)"
		return
	
	var hour = int(text.substr(0, 2))
	var minute = int(text.substr(3, 2))
	var total_minutes = hour * 60 + minute
	var min_allowed = 16 * 60 
	var max_allowed = 19 * 60 + 30  
	if minute < 0 or minute > 59:
		#add_theme_color_override("font_color", Color.RED)
		#placeholder_text = "Minute invalide (0–59)"
		Globals.ex2 = 0
		label.text = "Minute invalide (0–59)" 

	elif total_minutes < min_allowed or total_minutes > max_allowed:
		Globals.ex2 = 0
		label.text = "În afara intervalului (16:00–19:30)"
		return
	elif total_minutes <= Globals.pranz and Globals.pranz != 0:
		label.text = "Respectati ordinea activităților."
		Globals.ex2 = 0
		return
	elif Globals.pranz == 0:
		label.text = "Stergeti si completati casetele anterioare."
		Globals.ex2 = 0
		return
	else:
		Globals.ex2 = total_minutes
		add_theme_color_override("font_color", Color.GREEN)
		label.text = ""
