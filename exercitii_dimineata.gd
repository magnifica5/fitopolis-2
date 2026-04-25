extends Node2D

@onready var timer = $Timer
@onready var canvas = $CanvasLayer
var animations = [
	"res://ex1.tscn",
	"res://ex2.tscn",
	"res://ex3.tscn",
	"res://ex4.tscn",
	"res://ex5.tscn",
	"res://ex6.tscn",
	"res://ex7.tscn",
	"res://ex8.tscn",
	"res://ex9.tscn",
	"res://ex10.tscn",
	"res://ex11.tscn",
	"res://ex12.tscn",
	"res://ex13.tscn",
	"res://ex14.tscn",
	"res://ex15.tscn",
	"res://ex16.tscn",
	"res://ex17.tscn",
	"res://ex18.tscn",
	"res://ex19.tscn",
	"res://ex20.tscn"
]

var ex_azi = []
var index = 0
var ex_curent = null

func alege_ex():
	var list = animations.duplicate()
	list.shuffle()
	return list.slice(0, 4)

func _ready():
	SoundManager.stop_music()
	SoundManager.play_sport_music(preload("res://audio/Children's March Theme.mp3"))
	randomize()
	index = 0
	ex_azi = alege_ex()
	timer.timeout.connect(_on_timer_timeout)
	self.visible = false
	await get_tree().create_timer(0.1).timeout
	self.visible = true
	canvas.visible = true
	porneste_ex()
	timer.start()

func porneste_ex():
	if ex_curent != null:
		ex_curent.queue_free()

	if index < ex_azi.size():
		var scena = load(ex_azi[index])
		ex_curent = scena.instantiate()
		add_child(ex_curent)
		var anim = ex_curent.get_node("AnimatedSprite2D")
		anim.play()
		canvas.visible = false

func _on_timer_timeout():
	index += 1

	if index >= ex_azi.size():
		get_tree().change_scene_to_file("res://complete_activity.tscn")
	else:
		porneste_ex()
