extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	HourActivity.score -= (50 * HourActivity.missed)
	if HourActivity.score < 0:
		HourActivity.score = 0
	self.text = str(int(HourActivity.score))
	HourActivity.missed = 0
	HourActivity.save_progress()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
