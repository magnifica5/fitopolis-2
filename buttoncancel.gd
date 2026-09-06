extends TextureButton

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	$AudioStreamPlayer.play()
	await get_tree().create_timer(0.1).timeout
	# Luăm părintele direct (TextureRect) și îl facem invizibil
	get_parent().visible = false
