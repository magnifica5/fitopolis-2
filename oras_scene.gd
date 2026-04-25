extends Node2D

@onready var layers := [
	$Layer10,
	$Layer11,
	$Layer12,
	$Layer13,
	$Layer14,
	$Layer15,
	$Layer16,
	$Layer17,
	$Layer18,
	$Layer19,
	$Layer20,
	$Layer21,
	$Layer22,
	$Layer23,
	$Layer24,
	$Layer25,
	$Layer26,
	$Layer27,
	$Layer28,
	$Layer29,
	$Layer30,
	$Layer31,
	$Layer32,
	$Layer33
	
]

var layers_hidden := false

# Durata fade-ului (în secunde)
var fade_duration := 1.5
# Delay înainte de fade (în secunde)
var fade_delay := 0.5

func _process(_delta):
	if Input.is_action_just_pressed("fade_layer"):
		toggle_layers()

func toggle_layers():
	layers_hidden = !layers_hidden
	for layer in layers:
		var tween = create_tween()
		tween.tween_interval(fade_delay) # delay înainte de fade
		var target_alpha = 0.0 if layers_hidden else 1.0
		tween.tween_property(
			layer,
			"modulate",
			Color(layer.modulate.r, layer.modulate.g, layer.modulate.b, target_alpha),
			fade_duration
		)


func _acasa_pressed() -> void:
	$AudioStreamPlayer.play()
	await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_file("res://login.tscn")
