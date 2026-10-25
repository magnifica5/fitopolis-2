extends TextureButton
var item_id := ""
@onready var label: Label = $Sprite2D/Label
func _ready() -> void:
	Itemshop.city_changed.connect(_refresh)
	_refresh()
func _refresh() -> void:
	if Itemshop.catalog.has(item_id):
		label.text = str(int(Itemshop.catalog[item_id].price))
func _on_button_pressed() -> void:
	if Itemshop.busy:
		return
	disabled = true
	var ok: bool = await Itemshop.buy_building(item_id)
	if ok:
		get_tree().change_scene_to_file("res://oras2.0.tscn")
	else:
		disabled = false
