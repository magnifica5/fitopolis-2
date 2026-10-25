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

	if not pressed.is_connected(_on_button_pressed):
		pressed.connect(_on_button_pressed)

	print(
		"[CASE] Buton pregatit: ", item_id,
		" | disabled=", disabled
	)

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
	Itemshop.textura_salvata = image
	Itemshop.cale_textura_salvata = image_path
	Itemshop.scale_salvat = image_scale
	Itemshop.edit_mode = false
	Itemshop.delete_mode = false
	Itemshop.schimba_poza_mouse.emit(image)
	_payments.guard_navigation()
	var tree := get_tree()
	var error := tree.change_scene_to_file("res://oras2.0.tscn")
	if error != OK:
		disabled = false
		_payments.show_error("Casa este platita, dar scena nu poate fi deschisa. Reincearca aceeasi casa dupa corectarea scenei.")
