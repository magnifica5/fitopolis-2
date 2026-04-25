extends Sprite2D  # Această linie este obligatorie!
var item_id = "1"
func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		queue_free()
func _ready():
	if Globals.este_cumparat(item_id):
		queue_free()
