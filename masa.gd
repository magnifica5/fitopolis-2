extends Node2D
@onready var timer = $replica_b_masa
@onready var label = $CanvasLayer4/TextureRect/Label
var char_index = 0
var current_text = ""
var replica = "Haide să luăm masa"
func _ready():
	var speed = 0.07
	timer.wait_time = speed
	timer.connect("timeout", Callable(self, "_on_TypeTimer_timeout"))
	timer.start()
	
func _on_TypeTimer_timeout():
	if char_index < replica.length():
		current_text += replica[char_index]
		label.text = current_text
		char_index += 1
	else:
		timer.stop()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
