extends CanvasLayer
@onready var label = $Label
@onready var timer = $Timer
signal appear_heroes
var text = "Apasa pe personajul care te reprezinta:"
var current_text = ""
var char_index = 0
var speed = 0.07
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.text = ""
	timer.wait_time = speed
	timer.connect("timeout", Callable(self, "_on_TypeTimer_timeout"))
	timer.start()
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _on_TypeTimer_timeout():
	if char_index < text.length():
		current_text += text[char_index]
		label.text = current_text
		char_index += 1
	else:
		timer.stop()
		appear_heroes.emit()
func _process(delta: float) -> void:
	pass
