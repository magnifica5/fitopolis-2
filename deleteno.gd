extends TextureButton

var pop_up_principal: ColorRect

func _ready() -> void:
	pressed.connect(_on_pressed)
	# Urcăm: Buton -> ColorRect2 -> ColorRect (Cel Mare)
	pop_up_principal = get_parent().get_parent() as ColorRect

func _on_pressed() -> void:
	if pop_up_principal:
		pop_up_principal.inchide_pop_up()
