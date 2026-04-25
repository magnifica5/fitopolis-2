extends CanvasLayer
@onready var label = $ColorRect/Label
@onready var timer = $Timer 
@onready var fundal = $ColorRect
signal final_dinti
var time_left = 25
# Called when the node enters the scene tree for the first time.
	
func _ready() -> void:
	fundal.color = Color(0.5, 1, 0.5)
	timer.timeout.connect(_on_timer_timeout)
	label.text = str(time_left)
	timer.start()

func _on_timer_timeout():
	if time_left % 2 == 0:
		fundal.color = Color(0.5, 0.7, 1)
	else:
		fundal.color = Color(0.5, 1, 0.5)
	time_left -= 1
	if time_left <= 0:
		timer.stop()
		final_dinti.emit()
		time_left = 1
	label.text = str(time_left)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
