extends TextureButton

@onready var program_label = $Label
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.visible = false
	program_label.text = ""


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_link_button_start_programs() -> void:
	self.visible = true
	program_label.text = "Program 3"
