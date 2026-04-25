extends TextureButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.connect("final_settings", Callable(self, "_on_final_settings"))
	self.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_final_settings():
	self.visible = true
	
