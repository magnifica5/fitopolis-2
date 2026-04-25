extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_password_entered(new_text: String) -> void:
	self.visible = true
