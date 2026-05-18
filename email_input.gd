extends LineEdit
signal complete
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_theme_color_override("font_color", Color.WHITE)
	

func is_valid_email(email: String):
	email = email.strip_edges()
	var pattern = r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$"
	var regex = RegEx.new()
	var error = regex.compile(pattern)
	if error != OK:
		print("Eroare la compilarea regex-ului")
		return false
	return regex.search(email) != null
	
func _on_text_changed(email_input: String):
	if is_valid_email(email_input):
		add_theme_color_override("font_color", Color.GREEN)
		Globals.adauga_email(email_input)
		complete.emit()
	else:
		add_theme_color_override("font_color", Color.RED)
	# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
