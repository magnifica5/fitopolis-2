extends Node2D
@onready var i1 = $"CanvasLayer9/ScrollContainer/VBoxContainer/HBoxContainer/HourInput-trezire"
@onready var i2 = $"CanvasLayer9/ScrollContainer/VBoxContainer/HBoxContainer2/HourInput-ex"
@onready var i3 = $"CanvasLayer9/ScrollContainer/VBoxContainer/HBoxContainer3/HourInput-dejun"
@onready var i4 = $"CanvasLayer9/ScrollContainer/VBoxContainer/HBoxContainer4/HourInput-pranz"
@onready var i5 = $"CanvasLayer9/ScrollContainer/VBoxContainer/HBoxContainer5/HourInput-ex2"
@onready var i6 = $"CanvasLayer9/ScrollContainer/VBoxContainer/HBoxContainer6/HourInput-cina"
@onready var i7 = $"CanvasLayer9/ScrollContainer/VBoxContainer/HBoxContainer7/HourInput-somn"
@onready var i8 = $"CanvasLayer9/ScrollContainer/VBoxContainer/HBoxContainer8/HourInput-parinte"

@onready var l1 = $"CanvasLayer9/ScrollContainer/VBoxContainer/HBoxContainer/HourInput-trezire/Label-trezire"
@onready var l2 = $"CanvasLayer9/ScrollContainer/VBoxContainer/HBoxContainer2/HourInput-ex/Label-ex"
@onready var l3 = $"CanvasLayer9/ScrollContainer/VBoxContainer/HBoxContainer3/HourInput-dejun/Label-dejun"
@onready var l4 = $"CanvasLayer9/ScrollContainer/VBoxContainer/HBoxContainer4/HourInput-pranz/Label-pranz"
@onready var l5 = $"CanvasLayer9/ScrollContainer/VBoxContainer/HBoxContainer5/HourInput-ex2/Label-ex2"
@onready var l6 = $"CanvasLayer9/ScrollContainer/VBoxContainer/HBoxContainer6/HourInput-cina/Label-cina"
@onready var l7 = $"CanvasLayer9/ScrollContainer/VBoxContainer/HBoxContainer7/HourInput-somn/Label-somn"
@onready var l8 = $"CanvasLayer9/ScrollContainer/VBoxContainer/HBoxContainer8/HourInput-parinte/Label-parinte"
var path_hours = "user://hours.save"
@onready var list = [l1, l2, l3, l4, l5, l6, l7, l8]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.load_hours()
	i1.text = "%02d:%02d" % [int(Globals.trezire) / 60, int(Globals.trezire) % 60]
	i2.text = "%02d:%02d" % [int(Globals.ex) / 60, int(Globals.ex) % 60]
	i3.text = "%02d:%02d" % [int(Globals.dejun) / 60, int(Globals.dejun) % 60]
	i4.text = "%02d:%02d" % [int(Globals.pranz) / 60, int(Globals.pranz) % 60]
	i5.text = "%02d:%02d" % [int(Globals.ex2) / 60, int(Globals.ex2) % 60]
	i6.text = "%02d:%02d" % [int(Globals.cina) / 60, int(Globals.cina) % 60]
	i7.text = "%02d:%02d" % [int(Globals.somn) / 60, int(Globals.somn) % 60]
	i8.text = "%02d:%02d" % [int(Globals.parinte) / 60, int(Globals.parinte) % 60]
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _salveaza_ore_noi() -> void:
	$AudioStreamPlayer.play()
	await get_tree().create_timer(0.1).timeout
	var ok = true
	for l in list:
		if l.text != "":
			ok = false
	if ok == true:
		var data_existenta = {}
		var file = FileAccess.open(path_hours, FileAccess.READ)
		var content = file.get_as_text()
		file.close()
		var result = JSON.parse_string(content)
		data_existenta = result
		data_existenta["trezire"] = Globals.trezire
		data_existenta["ex"] = Globals.ex
		data_existenta["dejun"] = Globals.dejun
		data_existenta["pranz"] = Globals.pranz
		data_existenta["ex2"] = Globals.ex2
		data_existenta["cina"] = Globals.cina
		data_existenta["somn"] = Globals.somn
		data_existenta["parinte"] = Globals.parinte
		var file1 = FileAccess.open(path_hours, FileAccess.WRITE)
		file1.store_string(JSON.stringify(data_existenta, "\t"))
		file1.close()
		SoundManager.sound_stop_menu()
		SoundManager.play_music(preload("res://audio/background_sound.mp3"))
		get_tree().change_scene_to_file("res://login.tscn")


func _acasa() -> void:
	$AudioStreamPlayer.play()
	await get_tree().create_timer(0.1).timeout
	SoundManager.sound_stop_menu()
	SoundManager.play_music(preload("res://audio/background_sound.mp3"))
	get_tree().change_scene_to_file("res://login.tscn")
