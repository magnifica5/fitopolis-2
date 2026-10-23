extends Sprite2D
var item_id := ""

func _ready() -> void:
	Globals.sticker_inventory_updated.connect(_refresh)
	_refresh()

func _refresh() -> void:
	# Pastram capacul vizibil pana cand serverul confirma achizitia.
	visible = not Globals.este_cumparat(item_id)

func _on_area_2d_input_event(_viewport, _event, _shape_idx) -> void:
	pass
