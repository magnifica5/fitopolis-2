extends Node2D
@onready var timer = $CanvasLayer3/replica_b_seara
@onready var label = $CanvasLayer3/TextureRect/Label
@onready var rm = $miss_nutri
@onready var rs = $santos
@export var translation_key: String = "It's bedtime!"
var char_index = 0
var current_text = ""
var replica = ""
func _ready():
	var speed = 0.07
	timer.wait_time = speed
	timer.connect("timeout", Callable(self, "_on_TypeTimer_timeout"))
	timer.start()
	var personaj = Globals.citeste_personaj()
	if personaj == 1:
		rm.play()
	else:
		rs.play()
	Localization.language_changed.connect(_update_text)
	_update_text()

func _on_TypeTimer_timeout():
	if char_index < replica.length():
		current_text += replica[char_index]
		label.text = current_text
		char_index += 1
	else:
		timer.stop()
func _update_text() -> void:
	replica = Localization.get_text(translation_key)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _back_to_levels() -> void:
	$AudioStreamPlayer.play()
	await get_tree().create_timer(0.1).timeout
	Globals.completeaza = 1
	get_tree().change_scene_to_file("res://complete_activity.tscn")
