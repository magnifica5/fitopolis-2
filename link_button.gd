extends LinkButton
signal start_programs

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text = ""


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_link() -> void:
	text = "Click aici pentru Site"
	start_programs.emit()
