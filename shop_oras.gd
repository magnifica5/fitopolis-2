extends Control
const SERVICE = preload("res://house_payment_service.gd")
var oras = "res://oras2.0.tscn"
var _payments: Node
func _ready() -> void:
	_payments = Itemshop.get_node_or_null("HousePayments")
	if _payments == null:
		_payments = SERVICE.new()
		_payments.name = "HousePayments"
		Itemshop.add_child(_payments)
	_payments.prepare_city()
func _catre_oras() -> void:
	if not _payments.busy:
		_payments.open_city()
