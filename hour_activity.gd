extends Node
var complete_trezire = 0
var complete_ex = 0
var complete_dejun = 0
var complete_pranz = 0
var complete_ex2 = 0
var complete_cina = 0
var complete_somn = 0
var score = 0
var missed = 0
var nr_day = 0
var date
func save_progress():
	var data = {
		"trezire": complete_trezire,
		"ex": complete_ex,
		"dejun": complete_dejun,
		"pranz": complete_pranz,
		"ex2": complete_ex2,
		"cina": complete_cina,
		"somn": complete_somn,
		"score": score,
		"missed": missed,
		"nr_day": nr_day,
		"date": Time.get_date_string_from_system()
	}
	var json_string = JSON.stringify(data)
	var file = FileAccess.open("user://progress.json", FileAccess.WRITE)
	file.store_string(json_string)
	file.close()
	
func load_progress():
	if not FileAccess.file_exists("user://progress.json"):
		return  

	var file = FileAccess.open("user://progress.json", FileAccess.READ)
	var content = file.get_as_text()
	file.close()

	var result = JSON.parse_string(content)

	if result:
		complete_trezire = result.get("trezire", 0)
		complete_ex = result.get("ex", 0)
		complete_dejun = result.get("dejun", 0)
		complete_pranz = result.get("pranz", 0)
		complete_ex2 = result.get("ex2", 0)
		complete_cina = result.get("cina", 0)
		complete_somn = result.get("somn", 0)
		score = result.get("score", 0)
		missed = result.get("missed", 0)
		date = result.get("date", "")
		nr_day = result.get("nr_day", 0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_progress()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_choose_activity():
	Globals.load_hours()
	var trezire = int(Globals.trezire)
	var ex_dimineata = int(Globals.ex)
	var dejun = int(Globals.dejun)
	var pranz = int(Globals.pranz)
	var ex_seara = int(Globals.ex2)
	var cina = int(Globals.cina)
	var somn = int(Globals.somn)
	var ora_curenta = Time.get_datetime_dict_from_system()
	var mins = ora_curenta.hour * 60 + ora_curenta.minute
	print(mins)
	print(pranz)
	if (not(mins >= trezire and mins <= trezire + 7) 
	and not(mins >= ex_dimineata and mins <= ex_dimineata + 7)
	and not(mins >= dejun and mins <= dejun + 7) 
	and not(mins >= pranz and mins <= pranz + 7)
	and not(mins >= ex_seara and mins <= ex_seara + 7)
	and not(mins >= cina and mins <= cina + 7)
	and not(mins >= somn and mins <= somn + 7)):
		get_tree().change_scene_to_file("res://revino_mai_tarziu.tscn")
	elif mins >= trezire and mins <= trezire + 7:
		if complete_trezire == 0:
			complete_trezire = 1
			save_progress()
			get_tree().change_scene_to_file("res://trezire.tscn")
		else:
			get_tree().change_scene_to_file("res://revino_mai_tarziu.tscn")
	elif mins >= ex_dimineata and mins <= ex_dimineata + 7:
		if complete_ex == 0:
			complete_ex = 1
			save_progress()
			get_tree().change_scene_to_file("res://exercitii_dimineata.tscn")
		else:
			get_tree().change_scene_to_file("res://revino_mai_tarziu.tscn")
	elif mins >= dejun and mins <= dejun + 7:
		if complete_dejun == 0:
			complete_dejun = 1
			save_progress()
			get_tree().change_scene_to_file("res://spalat_maini.tscn")
		else:
			get_tree().change_scene_to_file("res://revino_mai_tarziu.tscn")
	elif mins >= pranz and mins <= pranz + 7:
		if complete_pranz == 0:
			complete_pranz = 1
			save_progress()
			get_tree().change_scene_to_file("res://spalat_maini.tscn")
		else:
			get_tree().change_scene_to_file("res://revino_mai_tarziu.tscn")
	elif mins >= ex_seara and mins <= ex_seara + 7:
		if complete_ex2 == 0:
			complete_ex2 = 1
			save_progress()
			get_tree().change_scene_to_file("res://exercitii_dimineata.tscn")
		else:
			get_tree().change_scene_to_file("res://revino_mai_tarziu.tscn")
	elif mins >= cina and mins <= cina + 7:
		if complete_cina == 0:
			complete_cina = 1
			save_progress()
			get_tree().change_scene_to_file("res://spalat_maini.tscn")
		else:
			get_tree().change_scene_to_file("res://revino_mai_tarziu.tscn")
	elif mins >= somn and mins <= somn + 7:
		if complete_somn == 0:
			complete_somn = 1
			save_progress()
			get_tree().change_scene_to_file("res://baie_dimineata.tscn")
		else:
			get_tree().change_scene_to_file("res://revino_mai_tarziu.tscn")
