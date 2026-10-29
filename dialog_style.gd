extends RefCounted

# Setari comune pentru avertizari, erori si confirmari.
const MESSAGE_FONT_SIZE := 70
const BUTTON_FONT_SIZE := 50
const PANEL_SIZE := Vector2i(850, 500)
const BUTTON_SIZE := Vector2(280, 130)

static func show_dialog(dialog: AcceptDialog) -> void:
	# Se apeleaza dupa add_child(), in loc de popup_centered().
	var label := dialog.get_label()
	dialog.dialog_autowrap = true

	label.add_theme_font_size_override("font_size", MESSAGE_FONT_SIZE)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_style_button(dialog.get_ok_button())
	if dialog is ConfirmationDialog:
		_style_button((dialog as ConfirmationDialog).get_cancel_button())
	dialog.add_theme_constant_override("buttons_min_width", int(BUTTON_SIZE.x))
	dialog.add_theme_constant_override("buttons_min_height", int(BUTTON_SIZE.y))
	var available := dialog.get_parent().get_viewport().get_visible_rect().size
	var target := Vector2i(mini(PANEL_SIZE.x, int(available.x * 0.9)), mini(PANEL_SIZE.y, int(available.y * 0.8)))
	dialog.min_size = target
	label.set_deferred("size", Vector2(maxf(1.0, target.x - 40.0), label.size.y))
	# Actualizeaza dimensiunea minima dupa schimbarea fontului si impachetarii.
	await dialog.get_tree().process_frame
	if not is_instance_valid(dialog) or not dialog.is_inside_tree():
		return
	dialog.popup_centered(target)

static func _style_button(button: Button) -> void:
	button.add_theme_font_size_override("font_size", BUTTON_FONT_SIZE)
	button.custom_minimum_size = BUTTON_SIZE
