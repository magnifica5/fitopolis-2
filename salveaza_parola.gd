extends Node2D
@onready var input = $CanvasLayer2/Password_Input
@onready var butoane = $CanvasLayer4
var path_hours = "user://hours.save"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	butoane.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_password_changed(new_text: String) -> void:
	if input.text != "":
		butoane.visible = true
	else:
		butoane.visible = false 


func _on_salveaza_pressed() -> void:
	$AudioStreamPlayer.play()
	await get_tree().create_timer(0.1).timeout
	Globals.adauga_parola(input.text)
	var file = FileAccess.open(path_hours, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	var result = JSON.parse_string(content)
	if result.has("personaj"):
		get_tree().change_scene_to_file("res://parola.tscn")
	else:
		get_tree().change_scene_to_file("res://alege_personaj.tscn")
	
