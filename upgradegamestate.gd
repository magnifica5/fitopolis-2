extends TextureButton
const SERVICE = preload("res://house_payment_service.gd")
func _ready() -> void:
	if not pressed.is_connected(_on_pressed):
		pressed.connect(_on_pressed)
func _on_pressed() -> void:
	var payments = Itemshop.get_node_or_null("HousePayments")
	if payments == null:
		payments = SERVICE.new()
		payments.name = "HousePayments"
		Itemshop.add_child(payments)
	if payments.busy:
		return
	disabled = true
	if await payments.upgrade_city():
		get_parent().hide()
	disabled = false
