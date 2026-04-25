extends Node2D

@onready var sound = $AudioStreamPlayer
@onready var sound2 = $AudioStreamPlayer2
@onready var menu = $menu
@onready var win = $win
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func play_music(stream):
	sound.stream = stream
	sound.play()

func play_menu_music(stream):
	menu.stream = stream
	menu.play()

func play_win_music(stream):
	win.stream = stream
	win.play()
	
func stop_music():
	sound.stop()

func sound_stop_music():
	sound2.stop()

func sound_stop_menu():
	menu.stop()
	
func sound_stop_win():
	win.stop()
	
func play_sport_music(stream1):
	sound2.stream = stream1
	sound2.play()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
