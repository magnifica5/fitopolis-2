extends Node2D
@onready var b1 = $CanvasLayer/CanvasLayer9/ScrollContainer/VBoxContainer/HBoxContainer/CheckBox
@onready var b2 = $CanvasLayer/CanvasLayer9/ScrollContainer/VBoxContainer/HBoxContainer2/CheckBox
@onready var b3 = $CanvasLayer/CanvasLayer9/ScrollContainer/VBoxContainer/HBoxContainer8/CheckBox
@onready var b4 = $CanvasLayer/CanvasLayer9/ScrollContainer/VBoxContainer/HBoxContainer3/CheckBox
@onready var b5 = $CanvasLayer/CanvasLayer9/ScrollContainer/VBoxContainer/HBoxContainer4/CheckBox
@onready var b6 = $CanvasLayer/CanvasLayer9/ScrollContainer/VBoxContainer/HBoxContainer5/CheckBox
@onready var b7 = $CanvasLayer/CanvasLayer9/ScrollContainer/VBoxContainer/HBoxContainer6/CheckBox
var path = "user://progress.json"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _back_to_start() -> void:
	$AudioStreamPlayer.play()
	await get_tree().create_timer(0.1).timeout
	var score = 0
	var missed = 0
	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	var result = JSON.parse_string(content)
	if b1.button_pressed and result["trezire"] == 1:
		score += 200
	else:
		missed += 1
	if b2.button_pressed and result["ex"] == 1:
		score += 200
	else:
		missed += 1
	if b3.button_pressed and result["dejun"] == 1:
		score += 200
	else:
		missed += 1
	if b4.button_pressed and result["pranz"] == 1:
		score += 200
	else:
		missed += 1
	if b5.button_pressed and result["ex2"] == 1:
		score += 200
	else:
		missed += 1
	if b6.button_pressed and result["cina"] == 1:
		score += 200
	else:
		missed += 1
	if b7.button_pressed and result["somn"] == 1:
		score += 200
	else:
		missed += 1
	HourActivity.load_progress()
	HourActivity.missed = missed
	HourActivity.score += score
	HourActivity.save_progress()
	Globals.completeaza = 0
	get_tree().change_scene_to_file("res://login.tscn")
