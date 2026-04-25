extends CanvasLayer
@onready var stea1 = $TextureRect/TextureRect
@onready var stea2 = $TextureRect/TextureRect2
@onready var stea3 = $TextureRect/TextureRect3
@onready var timer = $afisare_stele
var stars = []
var index = 0 
signal spawn_stars
func _ready() -> void:
	stars = [stea1, stea2, stea3]
	for s in stars:
		s.visible = false
	await get_tree().create_timer(0.3).timeout
	timer.start()

func _on_afisare_stele_timeout():
	if index < stars.size():
		stars[index].visible = true
		index += 1
	else:
		timer.stop()
		spawn_stars.emit()
		
		
