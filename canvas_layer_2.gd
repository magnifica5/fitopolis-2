extends CanvasLayer

@onready var label = $Label
@onready var timer = $Timer

var full_text = "Bine ai venit în Fitopolis! Orașul are nevoie de tine!"
var current_text = ""
var char_index = 0
var typing_speed = 0.05 # secunde între litere

func _ready():
	label.text = ""
	timer.wait_time = typing_speed
	timer.connect("timeout", Callable(self, "_on_TypeTimer_timeout"))
	timer.start()

func _on_TypeTimer_timeout():
	if char_index < full_text.length():
		current_text += full_text[char_index]
		label.text = current_text
		char_index += 1
	else:
		timer.stop()
