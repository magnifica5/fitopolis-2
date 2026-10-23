extends Area2D
signal modificare
var item_id := ""
var _pressed_at := -1
var _buying := false
@onready var price_label: Label = $Label

func _ready() -> void:
	Globals.sticker_inventory_updated.connect(_refresh)
	_refresh()

func _refresh() -> void:
	var available := (
		Globals.sticker_shop_ready
		and Globals.sticker_catalog.has(item_id)
	)

	# Cumpărarea este permisă după verificarea pe server.
	input_pickable = (
		available
		and not Globals.este_cumparat(item_id)
	)

	# Actualizăm prețul când sosește răspunsul serverului.
	# Până atunci păstrăm textul deja existent în scenă.
	if available:
		price_label.text = str(
			int(Globals.sticker_catalog[item_id])
		)

func _input_event(_viewport, event, _shape_idx) -> void:
	if not event is InputEventMouseButton or event.button_index != MOUSE_BUTTON_LEFT:
		return
	if event.pressed:
		_pressed_at = Time.get_ticks_msec()
		return
	var short_click := _pressed_at >= 0 and Time.get_ticks_msec() - _pressed_at < 200
	_pressed_at = -1
	if not short_click or _buying or not input_pickable:
		return
	_buying = true
	var result: Dictionary = await Globals.buy_sticker(item_id)
	_buying = false
	if not is_inside_tree():
		return
	if bool(result.get("ok", false)):
		modificare.emit()
	else:
		var popup := AcceptDialog.new()
		popup.title = "Stickere"
		popup.dialog_text = str(result.get("message", "Cumpararea nu a fost confirmata. Reincearca."))
		get_tree().root.add_child(popup)
		popup.confirmed.connect(popup.queue_free)
		popup.canceled.connect(popup.queue_free)
		popup.popup_centered()

func dispare_tot() -> void:
	_refresh()
