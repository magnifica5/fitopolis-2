extends LineEdit
@onready var label = $Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.text = ""


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func is_valid_email(email: String):
	email = email.strip_edges()
	var pattern = r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$"
	var regex = RegEx.new()
	var error = regex.compile(pattern)
	if error != OK:
		print("Eroare la compilarea regex-ului")
		return false
	return regex.search(email) != null


func _on_text_changed(new_text: String) -> void:
	if !is_valid_email(new_text):
		label.text = "Adresa de email invalida."
	else:
		label.text = ""
