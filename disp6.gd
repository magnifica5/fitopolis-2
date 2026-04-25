extends Sprite2D  # Această linie este obligatorie!
var item_id = "6"
func _ready():
	if Globals.este_cumparat(item_id):
		queue_free()
