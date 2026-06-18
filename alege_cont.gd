extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_copil_pressed() -> void:
	get_tree().change_scene_to_file("res://parental_code.tscn")


func _on_parinte_pressed() -> void:
	get_tree().change_scene_to_file("res://register_parrent.tscn")
