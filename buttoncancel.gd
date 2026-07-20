extends TextureButton

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	# Luăm părintele direct (TextureRect) și îl facem invizibil
	get_parent().visible = false
