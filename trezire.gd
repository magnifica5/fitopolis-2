extends Node2D
@onready var timer = $replica_dimi
@onready var label = $CanvasLayer3/TextureRect/Label
@onready var rm = $miss_nutri
@onready var rs = $santos
var char_index = 0
var replica_aleatorie = ""
var current_text = ""
func _ready():
	#randomize()
	#var replici = []
	## Deschide fișierul
	#if FileAccess.file_exists("res://replici/replici_dimineata.json"):
		#var file = FileAccess.open("res://replici/replici_dimineata.json", FileAccess.READ)
		#var json_text = file.get_as_text()
		#var result = JSON.parse_string(json_text)
		#replici = result
	# Alege aleatoriu
	replica_aleatorie = "Bună dimineața, mic erou! Fitopolis te așteaptă — dar mai întâi, fă-ți patul ca un adevărat campion!"#replici[randi() % replici.size()]
	var speed = 0.07
	timer.wait_time = speed
	timer.connect("timeout", Callable(self, "_on_TypeTimer_timeout"))
	timer.start()
	var personaj = Globals.citeste_personaj()
	if personaj == 1:
		rm.play()
	else:
		rs.play()
	
func _on_TypeTimer_timeout():
	if char_index < replica_aleatorie.length():
		current_text += replica_aleatorie[char_index]
		label.text = current_text
		char_index += 1
	else:
		timer.stop()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _mission_completed() -> void:
	$AudioStreamPlayer.play()
	await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_file("res://baie_dimineata.tscn")
