extends Label

signal start_text
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_text.emit()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
