extends Camera2D

# limitele 
@export var limit_min = Vector2(0, 0) # St Sus
@export var limit_max = Vector2(4500, 3000)   # Dr Jos

var dragging = false

func _unhandled_input(event):
	# Dacă mutăm un item, camera NU are voie să se miște absolut deloc
	if Itemshop.dragging_item:
		dragging = false
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed

	if event is InputEventMouseMotion and dragging:
		# Împărțirea la zoom asigură că mișcarea camerei 
		# ține pasul cu mouse-ul indiferent de nivelul de zoom
		var new_pos = position - event.relative / zoom

		position.x = clamp(new_pos.x, limit_min.x, limit_max.x)
		position.y = clamp(new_pos.y, limit_min.y, limit_max.y)
