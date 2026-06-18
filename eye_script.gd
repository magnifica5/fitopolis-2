extends LineEdit
@onready var eye = $TextureButton
# Called when the node enters the scene tree for the first time.
var eye_open = preload("res://assets/icon_open_eye.png")
var eye_closed = preload("res://assets/icon_closed_eye.png")
@onready var label = $Label
func _ready() -> void:
	if secret:
		eye.texture_normal = eye_closed
	else:
		eye.texture_normal = eye_open



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_eye_pressed() -> void:
	secret = !secret
	if secret:
		eye.texture_normal = eye_closed
	else:
		eye.texture_normal = eye_open


func is_valid_email(password: String):
	var regex = RegEx.new()
	regex.compile("[^a-zA-Z0-9]")
	var rezultat = regex.search(password)
	if len(password) < 12:
		label.text = "Parola trebuie sa aiba minim 12 caractere"
		return false
	elif rezultat == false:
		label.text = "Parola nu este destul de sigura"
		

func _on_text_changed(new_text: String) -> void:
	if is_valid_email(password):
		add_theme_color_override("font_color", Color.GREEN)
		Globals.adauga_email(password)
		complete.emit()
	else:
		add_theme_color_override("font_color", Color.RED)
