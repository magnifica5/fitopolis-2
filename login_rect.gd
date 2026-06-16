extends ColorRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.self_modulate = Color(1.0, 1.0, 1.0, 0.5)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
