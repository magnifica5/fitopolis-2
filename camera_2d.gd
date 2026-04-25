extends Camera2D

# Definim limitele (le poți schimba din Inspector dacă pui @export)
@export var limit_min = Vector2(0, 0) # Stânga Sus
@export var limit_max = Vector2(4500, 3000)   # Dreapta Jos

var dragging = false

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed

	if event is InputEventMouseMotion and dragging:
		# Calculăm noua poziție dorită
		var new_pos = position - event.relative * zoom
		
		# Limităm poziția folosind clamp
		# Astfel, camera nu va trece niciodată de marginile setate
		position.x = clamp(new_pos.x, limit_min.x, limit_max.x)
		position.y = clamp(new_pos.y, limit_min.y, limit_max.y)
