extends TextureRect
const SERVICE = preload("res://house_payment_service.gd")
var _waiting := false
func _on_upgrade() -> void:
	if _waiting:
		return
	var payments = Itemshop.get_node_or_null("HousePayments")
	if payments == null:
		payments = SERVICE.new()
		payments.name = "HousePayments"
		Itemshop.add_child(payments)
	_waiting = true
	if await payments.upgrade_city():
		hide()
	_waiting = false
