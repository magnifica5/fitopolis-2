extends TextureRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var personaj = Globals.citeste_personaj()
	if personaj == 0:
		self.visible = false
	else:
		self.visible = true
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
