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
	Globals.code = Globals.citeste_code()
	var query = SupabaseQuery.new().from("children").select().eq("connection_code", Globals.code)
	var task = Supabase.database.query(query)
	var result = await task.completed
	if result.error == null and result.data.size() > 0:
		var data = result.data[0]
		var trezire = change_type(data.trezire)
		var somn = change_type(data.culcare)
		var ora_curenta = Time.get_datetime_dict_from_system()
		var actual = ora_curenta.hour * 60 + ora_curenta.minute
		if actual >= trezire and actual <= trezire + 60:
			get_tree().change_scene_to_file("res://get_dressed.tscn")
		elif actual >= somn and actual <= somn + 60:
			get_tree().change_scene_to_file("res://culcare.tscn")
		
func change_type(string):
	var parti = string.split(":")
	var ore = parti[0].to_int()
	var minute = parti[1].to_int()
	var total_minute = (ore * 60) + minute
	return total_minute
