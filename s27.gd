extends Area2D
@onready var label = $Label
var time_start = 0.0
const CLICK_THRESHOLD = 200 # Milisecunde (0.2 secunde)
signal modificare
func _ready() -> void:
	if Globals.este_cumparat("27"):
		self.visible = false
	else:
		self.visible = true
func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# Memorează momentul apăsării
			time_start = Time.get_ticks_msec()
		else:
			# Calculează durata apăsării
			var duration = Time.get_ticks_msec() - time_start
			
			# Dacă e un click scurt (nu drag/scroll)
			if duration < CLICK_THRESHOLD:
				var score = Globals.citeste_score()
				var text = int(label.text)
				if score >= text:
					Globals.scade_scor(text)
					modificare.emit()
					dispare_tot()

func dispare_tot():
	Globals.marcheaza_cumparat("27")
	get_parent().queue_free()
	# 2. Dezactivează coliziunea acestui Area2D (folosind self)
	# Folosim set_deferred pentru că nu e bine să modifici fizica în timpul unui eveniment
	for child in get_children():
		if child is CollisionShape2D:
			child.set_deferred("disabled", true)
