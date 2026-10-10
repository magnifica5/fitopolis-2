extends TextureButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:

# Trebuie să adaugi și reîncărcarea scenei ca să se vadă modificarea:
	Itemshop.distruge_case(3)
	get_tree().reload_current_scene()
