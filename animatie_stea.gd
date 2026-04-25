extends PathFollow2D

func _ready():
	self.visible = false

func _star_movement() -> void:
	self.visible = true
	progress_ratio = 0
	var tween = create_tween()
	tween.tween_property(self, "progress_ratio", 1.0, 1.2)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
	await tween.finished
	self.visible = false
