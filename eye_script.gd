extends LineEdit
@onready var eye = $TextureButton
# Called when the node enters the scene tree for the first time.
var eye_open = preload("res://assets/icon_open_eye.png")
var eye_closed = preload("res://assets/icon_closed_eye.png")
func _ready() -> void:
	if secret:
		eye.texture_normal = eye_closed
	else:
		eye.texture_normal = eye_open



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_eye_pressed() -> void:
	secret = !secret
	if secret:
		eye.texture_normal = eye_closed
	else:
		eye.texture_normal = eye_open
