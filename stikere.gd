extends Node2D
@onready var audio = $AudioStreamPlayer
@onready var label = $CanvasLayer/TextureButton/Label
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _back_home() -> void:
	audio.play()
	get_tree().change_scene_to_file("res://login.tscn")
