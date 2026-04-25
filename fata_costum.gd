extends TextureRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var personaj = Globals.citeste_personaj()
	if personaj == 0:
		self.visible = true
	else:
		self.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
