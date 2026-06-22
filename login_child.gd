extends Control
@onready var inregistreaza = $CanvasLayer3/Panel/Button
@onready var error = $CanvasLayer3/Panel/Label
@onready var username = $CanvasLayer3/Panel/LineEdit
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_inregistreaza() -> void:
	if username.text == "":
		error.text = "Alege un username pentru profilul tau"
		return
	error.text = ""
