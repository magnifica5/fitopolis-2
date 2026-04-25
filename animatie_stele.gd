extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _star_movement() -> void:
	self.visible = true
	#progress_ratio = 0
	var tween = create_tween()
	tween.tween_property(self, "progress_ratio", 1.0, 1.2)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
	await tween.finished
	self.visible = false
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
