extends Control

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var button = $TextureButton
const DURATA_ANIMATIE := 10.0 
const NUMAR_ANIMATII := 5

var animatii_selectate: Array[StringName] = []
var i = 0


func _ready() -> void:
	button.hide()
	# Obținem numele animațiilor și le transformăm în Array.
	var toate_animatiile: Array = \
		Array(sprite.sprite_frames.get_animation_names())

	# Amestecăm animațiile aleatoriu.
	toate_animatiile.shuffle()

	# Selectăm 5 animații diferite.
	animatii_selectate.clear()

	for i in range(min(NUMAR_ANIMATII, toate_animatiile.size())):\
		animatii_selectate.append(StringName(toate_animatiile[i]))

	# Le rulăm succesiv.
	await ruleaza_animatiile()



func ruleaza_animatiile() -> void:
	button.hide()
	print("Rulează animația: ", animatii_selectate[i])
	sprite.play(animatii_selectate[i])
	# Așteptăm 90 de secunde înainte de următoarea animație.
	await get_tree().create_timer(DURATA_ANIMATIE).timeout
	button.show()
	sprite.stop()
	sprite.frame = 0
	print("Toate cele 5 animații au fost rulate!")


func _on_continue() -> void:
	if i < 4:
		i += 1
		ruleaza_animatiile()
	else:
		get_tree().change_scene_to_file("res://complete_activity.tscn")
