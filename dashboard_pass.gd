extends LineEdit
@onready var eye = $TextureButton
# Called when the node enters the scene tree for the first time.
var eye_open = preload("res://assets/icon_open_eye.png")
var eye_closed = preload("res://assets/icon_closed_eye.png")
@onready var label = $Label
var regex_upper = RegEx.create_from_string("[A-Z]")
var regex_lower = RegEx.create_from_string("[a-z]")
var regex_digit = RegEx.create_from_string("[0-9]")
var regex_special = RegEx.create_from_string("[^a-zA-Z0-9]")
func _ready() -> void:
	eye.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_eye_pressed() -> void:
	secret = !secret
	if secret:
		eye.texture_normal = eye_closed
	else:
		eye.texture_normal = eye_open


func is_valid_password(password: String):
	if len(password) < 8:
		label.text = "Parola trebuie sa aiba minim 8 caractere"
		return false
	if regex_upper.search(password) == null:
		label.text = "Parola trebuie sa contina cel putin o litera mare"
		return false
	if regex_lower.search(password) == null:
		label.text = "Parola trebuie sa contina cel putin o litera mica"
		return false
	if regex_digit.search(password) == null:
		label.text = "Parola trebuie sa contina cel putin o cifra"
		return false
	if regex_special.search(password) == null:
		label.text = "Parola trebuie sa contina cel putin un caracter special"
		return false
	label.text = ""
	return true
	
		

func _on_text_changed(password: String) -> void:
	if is_valid_password(password):
		add_theme_color_override("font_color", Color.GREEN)
	else:
		add_theme_color_override("font_color", Color.RED)


func _on_start_eye() -> void:
	eye.show()
	if secret:
		eye.texture_normal = eye_closed
	else:
		eye.texture_normal = eye_open
