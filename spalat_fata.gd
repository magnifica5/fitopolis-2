extends Node2D
@onready var animationb = $CanvasLayer2/AnimatedSprite2D
@onready var animationf = $CanvasLayer2/AnimatedSprite2D2
@onready var rm = $miss_nutri
@onready var rs = $santos
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var personaj = Globals.citeste_personaj()
	if personaj == 0:
		animationb.visible = true
		animationf.visible = false
		rs.play()
	else:
		animationb.visible = false
		animationf.visible = true
		rm.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _final_preg_dimi() -> void:
	$AudioStreamPlayer.play()
	await get_tree().create_timer(0.1).timeout
	Globals.load_hours()
	var ora_curenta = Time.get_datetime_dict_from_system()
	var actual = ora_curenta.hour * 60 + ora_curenta.minute
	if actual >= Globals.trezire and actual <= Globals.trezire + 60:
		get_tree().change_scene_to_file("res://get_dressed.tscn")
	elif actual >= Globals.somn and actual <= Globals.somn + 60:
		get_tree().change_scene_to_file("res://culcare.tscn")
