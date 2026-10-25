extends TextureButton
const PAYMENT_SERVICE = preload("res://house_payment_service.gd")
var item_id := ""
var image_path := ""
var image_scale := 1.0
var display_price := 0
var _payments: Node
@onready var label: Label = $Sprite2D/Label

func _ready() -> void:
	label.text = str(display_price)
	_payments = Itemshop.get_node_or_null("HousePayments")
	if _payments == null:
		_payments = PAYMENT_SERVICE.new()
		_payments.name = "HousePayments"
		Itemshop.add_child(_payments)
	_payments.prepare_city()
	if not pressed.is_connected(_on_button_pressed):
		pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
	if _payments.busy:
		return
	var image := load(image_path) as Texture2D
	if image == null:
		_payments.show_error("Imaginea casei nu poate fi incarcata. Plata nu a fost trimisa.")
		return
	disabled = true
	var result: Dictionary = await _payments.purchase(item_id)
	if not bool(result.get("ok", false)):
		disabled = false
		_payments.show_error(str(result.get("message", "Plata nu a reusit.")))
		return
	# Serviciul persistent gestioneaza tranzitia dupa disparitia butonului.
	_payments.open_city(image, image_path, image_scale)
	disabled = false
