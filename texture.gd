extends TextureRect

@export var camera: Camera2D

var dragging = false
var last_pos = Vector2.ZERO

func _input(event):
	if not camera:
		return

	# --- MOUSE ---
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and get_local_mouse_position().distance_to(Vector2.ZERO) >= 0: 
				dragging = true
				last_pos = event.position
			elif not event.pressed:
				dragging = false

	# --- TOUCH ---
	elif event is InputEventScreenTouch:
		if event.pressed:
			dragging = true
			last_pos = event.position
		else:
			dragging = false

	# --- DRAGGING ---
	if event is InputEventMouseMotion and dragging:
		var delta = last_pos - event.position
		camera.global_position += delta
		last_pos = event.position
	elif event is InputEventScreenDrag and dragging:
		var delta = last_pos - event.position
		camera.global_position += delta
		last_pos = event.position
