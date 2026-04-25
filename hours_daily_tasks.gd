extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_button_pressed() -> void:
	$AudioStreamPlayer.play()
	await get_tree().create_timer(0.1).timeout
	Unlock_levels.save_data()
	if Globals.trezire != 0 and Globals.dejun != 0 and Globals.ex != 0 and Globals.ex2 != 0 and Globals.somn != 0 and Globals.pranz != 0 and Globals.cina != 0:
		Globals.salveaza_avertisment()
		get_tree().change_scene_to_file("res://salvare_parola.tscn")
