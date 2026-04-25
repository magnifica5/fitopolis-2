extends Camera2D

# limitele 
@export var limit_min = Vector2(0, 0) # St Sus
@export var limit_max = Vector2(4500, 3000)   # Dr Jos

var dragging = false

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed

	if event is InputEventMouseMotion and dragging:
		var new_pos = position - event.relative * zoom
		
		#  clamp
		position.x = clamp(new_pos.x, limit_min.x, limit_max.x)
		position.y = clamp(new_pos.y, limit_min.y, limit_max.y)
